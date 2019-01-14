# Kubernetes

### Prerequisites  
You should have a basic understanding of containers.

### Summary

In this module you will learn the basic concepts of Kubernetes. OpenShift uses at it's core Kubernetes for orchestrating contrainers, but adds more enterprise features such as user management and external routing.

> *Important* : Kubernetes is very often abbreviated to **K8s**. This is the name we are going to use in this workshop.

## The basic concepts of Kubernetes

[Kubernetes](https://kubernetes.io/) is an open-source technology that makes it easier to automate deployment, scale, and manage containerized applications in a clustered environment. The ability to use GPUs with Kubernetes allows the clusters to facilitate running frequent experimentations, using it for high-performing serving, and auto-scaling of deep learning models, and much more. 

### Overview

Kubernetes is a system for managing containerized applications across a cluster of nodes. To work with Kubernetes, you use Kubernetes API objects to describe your cluster’s desired state: what applications or other workloads you want to run, what container images they use, the number of replicas, what network and disk resources you want to make available, and more. You set your desired state by creating objects using the Kubernetes API. Once you’ve set your desired state, the Kubernetes Control Plane works to make the cluster’s current state match the desired state. To do so, Kubernetes performs a variety of tasks automatically, such as starting or restarting containers, scaling the number of replicas of a given application, and more.

### Kubernetes Master

The Kubernetes master is responsible for maintaining the desired state for your cluster. When you interact with Kubernetes, such as by using the `oc` command-line interface, you’re communicating with your cluster’s Kubernetes master. The worker nodes communicate with the master components, configure the networking for containers, and run the actual workloads assigned to them. 


> This workshop uses `oc` as the cli which is a superset of the k8s cli `kuebctl`. Sometimes you'll find `kubectl` commands and they should work the same with `oc`, but not necessarily the other way round.

### Kubernetes Objects

Kubernetes contains a number of abstractions that represent the state of your system: deployed containerized applications and workloads, their associated network and disk resources, and other information about what your cluster is doing. A Kubernetes object is a "record of intent" – once you create the object, the Kubernetes system will constantly work to ensure that object exists. By creating an object, you’re telling the Kubernetes system your cluster’s desired state.

The basic Kubernetes objects include:

* Pod - the smallest and simplest unit in the Kubernetes object model that you create or deploy. A Pod encapsulates an application container (or multiple containers), storage resources, a unique network IP, and options that govern how the container(s) should run.
* Service - an abstraction which defines a logical set of Pods and a policy by which to access them.
* Volume - an abstraction which allows data to be preserved across container restarts and allows data to be shared between different containers.
* Namespace - a way to divide a physical cluster resources into multiple virtual clusters between multiple users.
* Deployment - Manages pods and ensures a certain number of them are running. This is typically used to deploy pods that should always be up, such as a web server.
* Job - A job creates one or more pods and ensures that a specified number of them successfully terminate. In other words, we use Job to run a task that finishes at some point, such as training a model.

### Creating a Kubernetes Object

When you create an object in Kubernetes, you must provide the object specifications that describes its desired state, as well as some basic information about the object (such as a name) to the Kubernetes API either directly or via the `oc` command-line interface. Usually, you will provide the information to `oc` in a .yaml file. `oc` then converts the information to JSON when making the API request. In the next few sections, we will be using various yaml files to describe the Kubernetes objects we want to deploy to our Kubernetes cluster.

For example, the `.yaml` file shown below includes the required fields and object spec for a Kubernetes Deployment. A Kubernetes Deployment is an object that can represent an application running on your cluster. In the example below, the Deployment spec describes the desired state of three replicas of the nginx application to be running. When you create the Deployment, the Kubernetes system reads the Deployment spec and starts three instances of your desired application, updating the status to match your spec.

```yaml
apiVersion: apps/v1beta2 # Kubernetes API version for the object
kind: Deployment # The type of object described by this YAML, here a Deployment
metadata:
  name: nginx-deployment # Name of the deployment
spec: # Actual specifications of this deployment
  replicas: 3 # Number of replicas (instances) for this deployment. 1 replica = 1 pod
  template: 
    metadata:
      labels:
        app: nginx
    spec: # Specification for the Pod 
      containers: # These are the containers running inside our Pod, in our case a single one
      - name: nginx # Name of this container
        image: nginx:1.7.9 # Image to run
        ports: # Ports to expose
        - containerPort: 80
```

To create all the objects described in a Deployment using a `.yaml` file like the one above in your own Kubernetes cluster you can use Kubernetes' CLI (`oc`). 

