# Training a model

The code for our Tensorflow project can be found in the [containers/training]({{WORKSHOP_BASE_URL}}/containers/training) folder. It contains a python file called model.py that contains TensorFlow code, and a Dockerfile to build it into a container image.

model.py defines a fairly straight-forward program. First it defines a simple feed-forward neural network with two hidden layers. Next, it defines tensor ops to train and evaluate the model's weights. Finally, after a number of training cycles, it saves the trained model up to a Object Storage bucket. Of course, before we can use the storage bucket, we need to create it.

The code was taken from the [Kubeflow MNIST example)[https://github.com/kubeflow/examples/tree/master/mnist]

## Setting up file storage

Our next step is to create two things: the storage bucket that will hold our trained model.

You can [download Minio client](https://minio.io/downloads.html) to your operating system of choice to access the minio S3 compatible object storage.

~~~bash
ACCESS_KEY=minio
ACCESS_SECRET_KEY=minio123
S3_ENDPOINT=http://minio-service-kubeflow.{{OCP_APPS_BASE_URL}}
mc config host add minio $S3_ENDPOINT $ACCESS_KEY $ACCESS_SECRET_KEY
~~~


Creating a bucket.

> **Caution**
> 
> Make sure you replace userN with your username

~~~console
BUCKET_NAME=userN

mc mb minio/$BUCKET_NAME

mc stat minio/$BUCKET_NAME

Name      : userN/
Date      : 2019-01-22 11:27:45 CET
Size      : 0B
Type      : folder
~~~

Alternatively you can also use the [Web-UI](http://minio-service-kubeflow.{{OCP_APPS_BASE_URL}}) of minio. The login credentials are the same as above.

## Building the Container

While we could build the container locally and push it to the OpenShift registry, we'll leverage the OpenShift build pipeline and image stream capabilities. This will allow us to build container images right in OpenShift, push them to an ImageStream and use them in our job and pod definitions.

Let's create the BuildConfig and ImageStream:

~~~console
oc process -f openshift/build_config_training-template.yaml --param APPLICATION_NAME=training-userN | oc apply -f -
buildconfig.build.openshift.io/training created
imagestream.image.openshift.io/training created
~~~

Have a look at the BuildConfig you've created:

~~~
oc describe bc/training-userN
Name:           training
Namespace:      user8
Created:        26 seconds ago
Labels:         name=training
Annotations:    kubectl.kubernetes.io/last-applied-configuration={"apiVersion":"build.openshift.io/v1","kind":"BuildConfig","metadata":{"annotations":{},"labels":{"name":"training"},"name":"training","namespace":"user8"},"spec":{"output":{"to":{"kind":"ImageStreamTag","name":"training:latest"}},"postCommit":{},"resources":{},"runPolicy":"Serial","source":{"contextDir":"containers/training/","git":{"uri":"https://github.com/durandom/openshift_kubeflow_workshop.git"},"type":"Git"},"strategy":{"type":"Docker"}}}

Latest Version: Never built

Strategy:       Docker
URL:            https://github.com/durandom/openshift_kubeflow_workshop.git
ContextDir:     containers/training
Output to:      ImageStreamTag training:latest

Build Run Policy:       Serial
Triggered by:           <none>
Builds History Limit:
        Successful:     5
        Failed:         5

Events: <none>
~~~

> **Note**
>
> If you forked the repo previously, you might have to adjust URL in the buildconig yaml

Let's trigger a build:

~~~
oc start-build training-userN --wait --follow
build.build.openshift.io/training-1 started
Cloning "https://github.com/durandom/openshift_kubeflow_workshop.git" ...
        Commit: 28e5a8a797eda167444499bf2c52cb73c9034d92 (asdf)
        Author: Marcel Hild <hild@b4mad.net>
        Date:   Mon Jan 21 19:19:45 2019 +0100
Step 1/10 : FROM tensorflow/tensorflow:1.12.0
 ---> 2054925f3b43
Step 2/10 : MAINTAINER "Marcel Hild <mhild@redhat.com>"
 ---> Using cache
 ---> 82d3bc88f2f3
~~~

Later, if you make modifications to the code, you can also start a build by uploading the contents of your directory. We call this a binary build:

~~~
oc start-build training-userN --from-dir=. --wait --follow
~~~

Now we have the training image in our ImageStream

~~~
oc describe is/training-userN
Name:                   training
Namespace:              user8
Created:                20 minutes ago
Labels:                 <none>
Annotations:            kubectl.kubernetes.io/last-applied-configuration={"apiVersion":"image.openshift.io/v1","kind":"ImageStream","metadata":{"annotations":{},"name":"training","namespace":"user8"},"spec":{"dockerImageRepository":"training","lookupPolicy":{"local":true},"tags":[{"name":"latest"}]}}

                        openshift.io/image.dockerRepositoryCheck=2019-01-22T10:39:24Z
Docker Pull Spec:       docker-registry.default.svc:5000/user8/training
Image Lookup:           local=true
Unique Images:          0
Tags:                   1

latest
  tag without source image
  
  * docker-registry.default.svc:5000/user8/training@sha256:f671516ab10cb21c10567f57d18f01b69e769053efd1d24d2cd980906d9f6a7c
      About a minute ago
~~~


