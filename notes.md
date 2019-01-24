# Random Notes
## tensorboard?!

TODO: This section needs to be updated

Tensorboard is deployed just before training starts. To connect:

```
PODNAME=$(kubectl get pod -l app=tensorboard-${JOB_NAME} -o jsonpath='{.items[0].metadata.name}')
kubectl port-forward ${PODNAME} 6006:6006
```

Tensorboard can now be accessed at [http://127.0.0.1:6006](http://127.0.0.1:6006).


## Create tf-serve via ksonnet

```
ks env add local
MODEL_COMPONENT=mnist-model-component
MODEL_NAME=mnist-model-name
MODEL_PATH=s3://kubeflow-models/inception
ks generate tf-serving-deployment-aws ${MODEL_COMPONENT} --name=${MODEL_NAME}
ks param set ${MODEL_COMPONENT} modelBasePath ${MODEL_PATH}
ks param set ${MODEL_COMPONENT} s3Enable true
ks param set ${MODEL_COMPONENT} s3SecretName secretname
ks param set ${MODEL_COMPONENT} s3AwsRegion us-west-1
ks param set ${MODEL_COMPONENT} s3VerifySsl false
ks param set ${MODEL_COMPONENT} s3UseHttps false
ks param set ${MODEL_COMPONENT} s3Endpoint minio-service.kubeflow.svc:9000
ks show local -c ${MODEL_COMPONENT}
```

## talking to tf-serve locally

MODEL_NAME=mnist-model-name
oc expose deployment/${MODEL_NAME} --port=9000
export TF_MODEL_SERVER_HOST=$(kubectl get svc ${MODEL_NAME} --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")
oc port-forward svc/${MODEL_NAME} 9000:9000

export TF_MNIST_IMAGE_PATH=data/7.png
export TF_MODEL_SERVER_PORT=9000
export TF_MODEL_SERVER_HOST=localhost
python mnist_client.py

# Issues

## OpenShift / RHDPS

### on RHPDS, can't create tf-job in user1 NS

```
oc apply -f tf-job.yaml
Error from server (Forbidden): error when retrieving current configuration of:
Resource: "kubeflow.org/v1beta1, Resource=tfjobs", GroupVersionKind: "kubeflow.org/v1beta1, Kind=TFJob"
Name: "mnist-train-local", Namespace: "user1"
Object: &{map["apiVersion":"kubeflow.org/v1beta1" "kind":"TFJob" "metadata":map["name":"mnist-train-local" "namespace":"user1" "annotations":map["kubectl.kubernetes.io/last-applied-configuration":""]] "spec":map["tfReplicaSpecs":map["Worker":map["replicas":'\x01' "template":map["spec":map["containers":[map["env":[map["name":"VERSION" "value":"1"] map["name":"BUCKET" "value":"bla"] map["name":"STEPS" "value":"1000"]] "image":"training" "name":"tensorflow"]] "restartPolicy":"OnFailure"]]]]]]}
from server for: "tf-job.yaml": tfjobs.kubeflow.org "mnist-train-local" is forbidden: User "user1" cannot get tfjobs.kubeflow.org in the namespace "user1": no RBAC policy matched
```

### on RHDPS, training image pull err

can't `oc run training --image training`

### TFJobs don't schedule pods in other NS 

need to issue: 
oc adm policy add-role-to-user cluster-admin -z tf-job-operator

see: https://github.com/kubeflow/kubeflow/pull/641/files

otherwise tf-job-operator does not start tf-jobs
in my own project it still doesnt work:

```
{"filename":"tensorflow/job.go:85","job":"mhild.mnist-train-local","level":"info","msg":"TFJob mnist-train-local is created.","time":"2019-01-14T10:10:23Z","uid":"9b773653-17e4-11e9-9161-246e9606163c"}
{"filename":"tensorflow/controller.go:338","job":"mhild.mnist-train-local","level":"info","msg":"Reconcile TFJobs mnist-train-local","time":"2019-01-14T10:10:23Z","uid":"9b773653-17e4-11e9-9161-246e9606163c"}
{"filename":"tensorflow/pod.go:75","job":"mhild.mnist-train-local","level":"info","msg":"Need to create new pod: worker-0","replica-type":"worker","time":"2019-01-14T10:10:23Z","uid":"9b773653-17e4-11e9-9161-246e9606163c"}
{"filename":"tensorflow/pod.go:173","job":"mhild.mnist-train-local","level":"warning","msg":"Restart policy in pod template will be overwritten by restart policy in replica spec","replica-type":"worker","time":"2019-01-14T10:10:23Z","uid":"9b773653-17e4-11e9-9161-246e9606163c"}
{"filename":"record/event.go:218","level":"info","msg":"Event(v1.ObjectReference{Kind:\"TFJob\", Namespace:\"mhild\", Name:\"mnist-train-local\", UID:\"9b773653-17e4-11e9-9161-246e9606163c\", APIVersion:\"kubeflow.org/v1beta1\", ResourceVersion:\"13525839\", FieldPath:\"\"}): type: 'Warning' reason: 'SettedPodTemplateRestartPolicy' Restart policy in pod template will be overwritten by restart policy in replica spec","time":"2019-01-14T10:10:23Z"}
{"filename":"tensorflow/controller.go:390","job":"mhild.mnist-train-local","level":"warning","msg":"reconcilePods error pods \"mnist-train-local-worker-0\" is forbidden: cannot set blockOwnerDeletion if an ownerReference refers to a resource you can't set finalizers on: no RBAC policy matched, \u003cnil\u003e","time":"2019-01-14T10:10:24Z","uid":"9b773653-17e4-11e9-9161-246e9606163c"}
{"filename":"tensorflow/controller.go:279","job":"mhild.mnist-train-local","level":"info","msg":"Finished syncing tfjob \"mhild/mnist-train-local\" (52.087745ms)","time":"2019-01-14T10:10:24Z"}
E0114 10:10:24.033468       1 controller.go:255] Error syncing tfjob: pods "mnist-train-local-worker-0" is forbidden: cannot set blockOwnerDeletion if an ownerReference refers to a resource you can't set finalizers on: no RBAC policy matched, <nil>
{"filename":"record/event.go:218","level":"info","msg":"Event(v1.ObjectReference{Kind:\"TFJob\", Namespace:\"mhild\", Name:\"mnist-train-local\", UID:\"9b773653-17e4-11e9-9161-246e9606163c\", APIVersion:\"kubeflow.org/v1beta1\", ResourceVersion:\"13525839\", FieldPath:\"\"}): type: 'Warning' reason: 'FailedCreatePod' Error creating: pods \"mnist-train-local-worker-0\" is forbidden: cannot set blockOwnerDeletion if an ownerReference refers to a resource you can't set finalizers on: no RBAC policy matched, \u003cnil\u003e","time":"2019-01-14T10:10:24Z"}
```

## Kubeflow

* dont see tf-jobs in UI


## tf-serve

aws logging error:
https://github.com/tensorflow/serving/issues/789 

