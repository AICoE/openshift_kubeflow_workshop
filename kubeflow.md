# Kubeflow - Overview

## Summary

In this module we are going to get an overview of the different components that make up [Kubeflow](https://github.com/kubeflow/kubeflow).

### Kubeflow Overview

From [Kubeflow](https://github.com/kubeflow/kubeflow)'s own documetation:

> The Kubeflow project is dedicated to making deployments of machine learning (ML) workflows on Kubernetes simple, portable and scalable. Our goal is not to recreate other services, but to provide a straightforward way to deploy best-of-breed open-source systems for ML to diverse infrastructures. Anywhere you are running Kubernetes, you should be able to run Kubeflow.

Kubeflow is composed of multiple components:

* [JupyterHub](https://jupyterhub.readthedocs.io/en/latest/), which allows user to request an instance of a Jupyter Notebook server dedicated to them.
* One or multiple training controllers. These are component that simplifies and manages the deployment of training jobs. For the purpose of this lab we are only going to deploy a training controller for TensorFlow jobs. However the Kubeflow community has started working on controllers for PyTorch and Caffe2 as well.
* A serving component that will help you serve predictions with your models.
* And many more projects...

For more general info on Kubeflow, head to [kubeflow Docs](https://www.kubeflow.org/docs).

### ksonnet

Kubeflow uses [`ksonnet`](https://ksonnet.io/) templates as a way to package and deploy the different components.  

> ksonnet simplifies defining an application configuration, updating the configuration over time, and specializing it for different clusters and environments. 

We will not focus on that in this workshop. We'll deploy the jobs and other things directly via the `.yaml` files.

### Deployed Kubeflow services

`oc get pods -n kubeflow`

should return something like this, in case you have view permission to the kubeflow namespace:

~~~text
NAME                                READY     STATUS    RESTARTS   AGE
ambassador-7789cddc5d-czf7p         2/2       Running   0          1d
ambassador-7789cddc5d-f79zp         2/2       Running   0          1d
ambassador-7789cddc5d-h57ms         2/2       Running   0          1d
centraldashboard-d5bf74c6b-nn925    1/1       Running   0          1d
tf-hub-0                            1/1       Running   0          1d
tf-job-dashboard-8699ccb5ff-9phmv   1/1       Running   0          1d
tf-job-operator-646bdbcb7-bc479     1/1       Running   0          1d
~~~

The most important components for the purpose of this lab are `tf-hub-0` which is the JupyterHub spawner running on your cluster, and `tf-job-operator-646bdbcb7-bc479` which is a controller that will monitor your cluster for new TensorFlow training jobs (called `TfJobs`) specifications and manages the training, we will look at this two components later.

Click to access the [Central Dashboard](http://centraldashboard-kubeflow.{{OCP_APPS_BASE_URL}}) of Kubeflow

