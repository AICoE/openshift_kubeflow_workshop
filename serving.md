# Serving

TensorFlow Serving is a flexible, high-performance serving system for machine learning models, designed for production environments. TensorFlow Serving makes it easy to deploy new algorithms and experiments, while keeping the same server architecture and APIs. TensorFlow Serving provides out-of-the-box integration with TensorFlow models, but can be easily extended to serve other types of models and data.

## Deploy the tf-serving component

Now that you have a trained model, it's time to put it in a server so it can be used to handle requests. This task is handled by tf-serving. Unlike the tf-job, no custom container is required for the server process. Instead, all the information the server needs is stored in the model file. We simply need to point the server component to our bucket where the model data is stored, and it will spin up to handle requests.

~~~
oc process -f openshift/tf-serving-template.yaml --param BUCKET=userN --param APPLICATION_NAME=tf-serving-userN | oc apply -f -
deployment.extensions/tf-serving configured
~~~

One interesting detail to note is that you don't need to add a VERSION_TAG, even though you may have multiple versions of your model saved in your bucket. Instead, the serving component will pick up on the most recent tag, and serve it.

Like during training, you can check the logs of the running server pod to ensure everything is working as expected:

~~~
oc get pods
oc logs -f tf-serving-59c859d5b9-j9ccq
~~~

> **Note**
> 
> You'll see some errors from `aws_logging.cc`. These can be ignored.

And finally we want to expose the GRPC Port 9000 as a service.

~~~
oc expose deployment/tf-serving-userN --port=9000
~~~

## Add a web-ui

Now we need something to talk to the tf-serving component: a web interface that can interact with our trained model server. This code is stored in the [containers/web-ui]({{WORKSHOP_BASE_URL}}/containers/web-ui) directory.

The web page for this task is fairly basic; it consists of a simple flask server hosting HTML/CSS/Javascript files. The flask server makes use of mnist_client.py, which contains a python function that directly interacts with the TensorFlow server.

We will again use the OpenShift build feature. The following command will create a BuildConfig.

~~~
oc process -f openshift/build_config_web-ui-template.yaml --param APPLICATION_NAME=tf-web-ui-userN | oc apply -f -
buildconfig.build.openshift.io/tf-web-ui configured
imagestream.image.openshift.io/tf-web-ui unchanged
~~~

Now trigger a build

~~~
oc start-build tf-web-ui-userN --wait --follow
~~~

And finally deploy the app and expose it:

~~~
oc new-app --image-stream=tf-web-ui-userN
oc expose svc/tf-web-ui-userN
~~~

Then find the hostname where the application was deployed to:

~~~
oc get routes/tf-web-ui-userN
NAME        HOST/PORT                                                      PATH      SERVICES    PORT       TERMINATION   WILDCARD
tf-web-ui   tf-web-ui-kubeflow.{{OCP_APPS_BASE_URL}}             tf-web-ui   5000-tcp                 None
~~~

And open it in a Browser

![MNIST UI]({% image_path mnist-ui.png %})

> **Note**
>
> You'll want to add `tf-serving-userN.kubeflow.svc` as the Server Address
