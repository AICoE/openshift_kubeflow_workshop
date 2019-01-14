# Distributed TensorFlow with `TFJob`

## Summary

Distributed TensorFlow trainings can be complicated. In this module, we will see how `TFJob`, one of the components of Kubeflow, can be used to simplify the deployment and monitoring of distributed TensorFlow trainings.
  
## "Vanilla" Distributed TensorFlow is Hard

First let's see how we would setup a distributed TensorFlow training without Kubernetes or `TFJob` (fear not, we are not actually going to do that).
First, you would have to find or setup a bunch of idle VMs, or physical machines. In most companies, this would already be a feat, and likely require the coordination of multiple department (such as IT) to get the VMs up, running and reserved for your experiment. 
Then you would likely have to do some back and forth with the IT department to be able to setup your training: the VMs need to be able to talk to each others and have stable endpoints. Work might be needed to access the data, you would need to upload your TF code on every single machine etc.  
If you add GPU to the mix, it would likely get even harder since GPUs aren't usually just waiting there because of their high cost.  

Assuming you get through this, you now need to modify your model for distributed training.  
Among other things, you will need to setup the `ClusterSpec` ([`tf.train.ClusterSpec`](https://www.tensorflow.org/api_docs/python/tf/train/ClusterSpec)):  a TensorFlow class that allows you to describe the architecture of your cluster. 
For example, if you were to setup a distributed training with a mere 2 workers and 2 parameter servers, your cluster spec would look like this (the `clusterSpec` would most likely not be hardcoded, but passed as argument to your training script as we will see below, this is for illustration):

~~~python
cluster = tf.train.ClusterSpec({"worker": ["<IP_GPU_VM_1>:2222",
                                           "<IP_GPU_VM_2>:2222"],
                                "ps": ["<IP_CPU_VM_1>:2222",
                                       "<IP_CPU_VM_2>:2222"]})
~~~
Here we assume that you want your workers to run on GPU VMs and your parameter servers to run on CPU VMs.  

We will not go through the rest of the modifications needed (splitting operation across devices, getting the master session etc.), as we will look at them later and this would be pretty much the same thing no matter how you run your distributed training.

Once your model is ready, you need to start the training.  
You will need to connect to every single VM, and pass the `ClusterSpec` as well as the assigned job name (ps or worker) and task index to each VM. 
So it would look something like this:

~~~bash
# On ps0:
$ python trainer.py \
     --ps_hosts=<IP_CPU_VM_1>:2222,<IP_CPU_VM_2>:2222 \
     --worker_hosts=<IP_GPU_VM_1>:2222,<IP_GPU_VM_2>:2222 \
     --job_name=ps --task_index=0
# On ps1:
$ python trainer.py \
     --ps_hosts=<IP_CPU_VM_1>:2222,<IP_CPU_VM_2>:2222 \
     --worker_hosts=<IP_GPU_VM_1>:2222,<IP_GPU_VM_2>:2222 \
     --job_name=ps --task_index=1
# On worker0:
$ python trainer.py \
     --ps_hosts=<IP_CPU_VM_1>:2222,<IP_CPU_VM_2>:2222 \
     --worker_hosts=<IP_GPU_VM_1>:2222,<IP_GPU_VM_2>:2222 \
     --job_name=worker --task_index=0
# On worker1:
$ python trainer.py \
     --ps_hosts=<IP_CPU_VM_1>:2222,<IP_CPU_VM_2>:2222 \
     --worker_hosts=<IP_GPU_VM_1>:2222,<IP_GPU_VM_2>:2222 \
     --job_name=worker --task_index=1
~~~

At this point your training would finally start.  
However, if for some reason an IP changes (a VM restarts for example), you would need to go back on every VM in your cluster, and restart the training with an updated `ClusterSpec` (If the IT department of your company is feeling extra-generous they might assign a DNS name to every VM which would already make your life much easier).
If you see that your training is not doing well and you need to update the code, you have to redeploy it on every VM and restart the training everywhere.
If for some reason you want to retrain after a while, you would most likely need to go back to step 1: ask for the VMs to be allocated, redeploy, update the `clusterSpec`.

All this hurdles means that in practice very few people actually bother with distributed training as the time gained during training might not be worth the energy and time necessary to set it up correctly.

## Distributed TensorFlow with Kubernetes and `TFJob`

Thankfully, with Kubernetes and `TFJob` things are much, much simpler, making distributed training something you might actually be able to benefit from. Before submitting a training job, you should have deployed Kubeflow to your cluster. Doing so ensures that the `TFJob` custom resource is available when you submit the training job. 

### Overview of `TFJob` distributed training

So, how does `TFJob` work for distributed training?
Let's look again at what the `TFJobSpec`and `TFReplicaSpec` objects looks like:

**`TFJobSpec` Object**

| Field | Type| Description |
|-------|-----|-------------|
| ReplicaSpecs | `TFReplicaSpec` array | Specification for a set of TensorFlow processes, defined below |


**`TFReplicaSpec` Object**

| Field | Type| Description |
|-------|-----|-------------|
| TfReplicaType | `string` | What type of replica are we defining? Can be `Chief`, `Worker` or `Ps`. When not doing distributed TensorFlow, we just use `Chief` which happens to be the default value. | 
| Replicas | `int` | Number of replicas of `TfReplicaType`. Again this is useful only for distributed TensorFLow. Default value is `1`. |
| Template | [`PodTemplateSpec`](https://kubernetes.io/docs/api-reference/v1.8/#podtemplatespec-v1-core) | Describes the pod that will be created when executing a job. This is the standard Pod description that we have been using everywhere.  |

In case the distinction between chief and workers is not clear, there is a single chief per TensorFlow cluster, and it is in fact a worker. The difference is that the chief is the worker that is going to handle the creation of the `tf.Session`, write logs and save the model.

As you can see, `TFJobSpec` and `TFReplicaSpec` allow us to easily define the architecture of the TensorFlow cluster we would like to setup.

Once we have defined this architecture in a `TFJob` template and deployed it with `oc create`, the operator will do most of the work for us.
For each chief, worker and parameter server in our TensorFlow cluster, the operator will create a service exposing it so they can communicate.   
It will then create an internal representation of the cluster with each node and it's associated internal DNS name.  

For example, if you were to create a `TFJob` with 1 `Chief`, 2 `Workers` and 1 `Ps`, this representation would look similar to this:

~~~json
{  
    "chief":[  
        "distributed-mnist-chief-5oz2-0:2222"
    ],
    "ps":[  
        "distributed-mnist-ps-5oz2-0:2222"
    ],
    "worker":[  
        "distributed-mnist-worker-5oz2-0:2222",
        "distributed-mnist-worker-5oz2-1:2222"
    ]
}
~~~

Finally, the operator will create all the necessary pods, and in each one, inject an environment variable named `Tf_CONFIG`, containing the cluster specification above, as well as the respective job name and task id that each node of the TensorFlow cluster should assume.  

For example, here is the value of the `TF_CONFIG` environment variable that would be sent to worker 1:

~~~json
{  
   "cluster":{  
      "master":[  
         "distributed-mnist-chief-5oz2-0:2222"
      ],
      "ps":[  
         "distributed-mnist-ps-5oz2-0:2222"
      ],
      "worker":[  
         "distributed-mnist-worker-5oz2-0:2222",
         "distributed-mnist-worker-5oz2-1:2222"
      ]
   },
   "task":{  
      "type":"worker",
      "index":1
   },
   "environment":"cloud"
}
~~~

As you can see, this completely takes the responsibility of building and maintaining the `ClusterSpec` away from you.
All you have to do, is modify your code to read the `TF_CONFIG` and act accordingly.

### Modifying your model to use `TFJob`'s `TF_CONFIG`

As for any distributed TensorFlow training, you will then also need to modify your model to split the operations and variables among the workers and parameter servers as well as create on session on the master.

Have a look at [containers/training/model.py]({{WORKSHOP_BASE_URL}}/containers/training/model.py) to see how the distinction between Chief and Workers is being implemented.

### Schedule a distributed training job

Again we'll use OpenShift templates to create a valid `TFJob` resource.

~~~console
oc process -f openshift/tf-job_distributed-template.yaml --param JOB_NAME=training-distributed-userN --param IMAGE_NAME=training-userN --param BUCKET=userN --param WORKERS=2 | oc apply -f -
~~~

Now see how many pods are being spun up for you:

~~~console
oc get pods | grep userN
training-distributed-userN-chief-0                      0/1       ContainerCreating   0          9s
training-distributed-userN-ps-0                         0/1       ContainerCreating   0          9s
training-distributed-userN-worker-0                     0/1       ContainerCreating   0          9s
training-distributed-userN-worker-1                     0/1       ContainerCreating   0          9s
~~~

And follow the logs for the workers and chief:

~~~console
oc logs -f training-distributed-userN-chief-0
~~~

The newly created model should be automatically picked up by the Web-UI

