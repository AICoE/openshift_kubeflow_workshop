## Training with TF-Job

In this module you will learn how to describe a TensorFlow training using `TFJob` object.


### Kubernetes Custom Resource Definition

Kubernetes has a concept of [Custom Resources](https://kubernetes.io/docs/concepts/api-extension/custom-resources/) (often abbreviated CRD) that allows us to create custom object that we will then be able to use.
In the case of Kubeflow, after installation, a new `TFJob` object will be available in our cluster. This object allows us to describe a TensorFlow training.

#### `TFJob` Specifications

Before going further, let's take a look at what the `TFJob` object looks like:

> Note: Some of the fields are not described here for brevity.

**`TFJob` Object**

| Field | Type| Description |
|-------|-----|-------------| 
| apiVersion | `string` | Versioned schema of this representation of an object. In our case, it's `kubeflow.org/v1beta1` |
| kind | `string` |  Value representing the REST resource this object represents. In our case it's `TFJob` |
| metadata | [`ObjectMeta`](https://github.com/kubernetes/community/blob/master/contributors/devel/api-conventions.md#metadata)| Standard object's metadata. |
| spec | `TFJobSpec` | The actual specification of our TensorFlow job, defined below. |

`spec` is the most important part, so let's look at it too:

**`TFJobSpec` Object**

| Field | Type| Description |
|-------|-----|-------------|
| TFReplicaSpec | `TFReplicaSpec` array | Specification for a set of TensorFlow processes, defined below |

Let's go deeper: 

**`TFReplicaSpec` Object**

| Field | Type| Description |
|-------|-----|-------------|
| TfReplicaType | `string` | What type of replica are we defining? Can be `Chief`, `Worker` or `PS`. When not doing distributed TensorFlow, we just use `Chief` which happens to be the default value. | 
| Replicas | `int` | Number of replicas of `TfReplicaType`. Again this is useful only for distributed TensorFLow. Default value is `1`. |
| Template | [`PodTemplateSpec`](https://kubernetes.io/docs/api-reference/v1.8/#podtemplatespec-v1-core) | Describes the pod that will be created when executing a job. This is the standard Pod description that we have been using everywhere.  |

Here is what a simple TensorFlow training looks like using this `TFJob` object:

~~~yaml
apiVersion: kubeflow.org/v1beta1
kind: TFJob
metadata:
  name: example-tfjob
spec:
  tfReplicaSpecs:
    Chief:
      replicas: 1
      template:
        spec:
          containers:
            - image: <DOCKER_USERNAME>/tf-mnist:gpu
              name: tensorflow
              resources:
                limits:
                  nvidia.com/gpu: 1
          restartPolicy: OnFailure
~~~

### A Simple `TFJob`

Have a look at [openshift/tf-job.yaml]({{WORKSHOP_BASE_URL}}/openshift/tf-job.yaml). This file contains a simple job definition. Instead of applying the tf-job.yaml directly, we'll make use of OpenShift templates. They let us add parameters to resources and generate the objects for us. 

~~~console
oc process -f openshift/tf-job-template.yaml --param JOB_NAME=training-userN --param IMAGE_NAME=training-userN --param BUCKET=userN | oc apply -f -
tfjob.kubeflow.org/training created
~~~

Let's look at what has been created in our cluster.

First a `TFJob` was created:

~~~console
oc get tfjob

NAME       CREATED AT
training   2m
~~~

As well as a `Pod`, which was actually created by the operator:

~~~console
oc get pods training-chief-0
NAME               READY     STATUS      RESTARTS   AGE
training-chief-0   0/1       Completed   0          37s
~~~

Note that the `Pod` might take a few minutes before actually running, the docker image needs to be pulled on the node first.

Once the `Pod`'s status is either `Running` or `Completed` we can start looking at it's logs:

~~~console 
oc logs training-chief-0
~~~

This container is pretty verbose, but you should see a TensorFlow training happening: 

~~~
[...]
INFO:tensorflow:2017-11-20 20:57:22.314198: Step 480: Cross entropy = 0.142486
INFO:tensorflow:2017-11-20 20:57:22.370080: Step 480: Validation accuracy = 85.0% (N=100)
INFO:tensorflow:2017-11-20 20:57:22.896383: Step 490: Train accuracy = 98.0%
INFO:tensorflow:2017-11-20 20:57:22.896600: Step 490: Cross entropy = 0.075210
INFO:tensorflow:2017-11-20 20:57:22.945611: Step 490: Validation accuracy = 91.0% (N=100)
INFO:tensorflow:2017-11-20 20:57:23.407756: Step 499: Train accuracy = 94.0%
INFO:tensorflow:2017-11-20 20:57:23.407980: Step 499: Cross entropy = 0.170348
INFO:tensorflow:2017-11-20 20:57:23.457325: Step 499: Validation accuracy = 89.0% (N=100)
INFO:tensorflow:Final test accuracy = 88.4% (N=353)
[...]
~~~

For watching the transitions of a TFJob use the `describe` command. At the end you'll see the Status conditions. These are described in more detail [in the docs](https://www.kubeflow.org/docs/components/tftraining/#monitoring-your-job)

~~~
oc describe tfjob
Name:         training
Namespace:    kubeflow
Labels:       <none>
Annotations:  kubectl.kubernetes.io/last-applied-configuration={"apiVersion":"kubeflow.org/v1beta1","kind":"TFJob","metadata":{"annotations":{},"name":"training","namespace":"kubeflow"},"spec":{"tfReplicaSpecs":{"C...
API Version:  kubeflow.org/v1beta1
Kind:         TFJob
Metadata:
  Cluster Name:
  Creation Timestamp:  2019-01-22T11:29:28Z
  Generation:          1
  Resource Version:    988946
  Self Link:           /apis/kubeflow.org/v1beta1/namespaces/kubeflow/tfjobs/training
  UID:                 fa8a9cd4-1e38-11e9-8c08-029ef79ec102
Spec:
  Clean Pod Policy:  Running
  Tf Replica Specs:
    Chief:
      Replicas:        1
      Restart Policy:  Never
      Template:
        Metadata:
          Creation Timestamp:  <nil>
        Spec:
          Containers:
            Env:
              Name:   TF_MODEL_DIR
              Value:  s3://kubeflow/inception
            Image:    training
            Name:     tensorflow
            Ports:
              Container Port:  2222
              Name:            tfjob-port
            Resources:
          Restart Policy:  OnFailure
Status:
  Completion Time:  2019-01-22T11:29:57Z
  Conditions:
    Last Transition Time:  2019-01-22T11:29:28Z
    Last Update Time:      2019-01-22T11:29:28Z
    Message:               TFJob training is created.
    Reason:                TFJobCreated
    Status:                True
    Type:                  Created
    Last Transition Time:  2019-01-22T11:29:31Z
    Last Update Time:      2019-01-22T11:29:31Z
    Message:               TFJob training is running.
    Reason:                TFJobRunning
    Status:                False
    Type:                  Running
    Last Transition Time:  2019-01-22T11:29:57Z
    Last Update Time:      2019-01-22T11:29:57Z
    Message:               TFJob training is successfully completed.
    Reason:                TFJobSucceeded
    Status:                True
    Type:                  Succeeded
  Replica Statuses:
    Chief:
    Master:
    PS:
    Worker:
  Start Time:  2019-01-22T11:29:31Z
Events:
  Type     Reason                          Age   From         Message
  ----     ------                          ----  ----         -------
  Warning  SettedPodTemplateRestartPolicy  1m    tf-operator  Restart policy in pod template will be overwritten by restart policy in replica spec
  Normal   SuccessfulCreatePod             1m    tf-operator  Created pod: training-chief-0
  Normal   SuccessfulCreateService         1m    tf-operator  Created service: training-chief-0
  Normal   ExitedWithCode                  1m    tf-operator  Pod: kubeflow.training-chief-0 exited with code 0
~~~

In case you want to re-run the same job again, you'll have to delete it first:

~~~
oc delete tfjob/training
~~~

And you should see the model stored in our $BUCKET

~~~
mc ls --recursive minio/$BUCKET

[2019-01-22 12:29:55 CET]  30KiB inception/export/1548156594/saved_model.pb
[2019-01-22 12:29:56 CET]  12MiB inception/export/1548156594/variables/variables.data-00000-of-00001
[2019-01-22 12:29:56 CET]   428B inception/export/1548156594/variables/variables.index
[2019-01-22 12:29:54 CET]   128B inception/training/1548156572/checkpoint
[2019-01-22 12:29:54 CET] 296KiB inception/training/1548156572/events.out.tfevents.1548156573.training-chief-0
[2019-01-22 12:29:34 CET] 210KiB inception/training/1548156572/graph.pbtxt
[2019-01-22 12:29:35 CET]  12MiB inception/training/1548156572/model.ckpt-0.data-00000-of-00001
[2019-01-22 12:29:35 CET]   428B inception/training/1548156572/model.ckpt-0.index
[2019-01-22 12:29:35 CET]  91KiB inception/training/1548156572/model.ckpt-0.meta
[2019-01-22 12:29:54 CET]  12MiB inception/training/1548156572/model.ckpt-200.data-00000-of-00001
[2019-01-22 12:29:54 CET]   428B inception/training/1548156572/model.ckpt-200.index
[2019-01-22 12:29:54 CET]  91KiB inception/training/1548156572/model.ckpt-200.meta
~~~


