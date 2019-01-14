# Introduction

This workshop will walk you through using [Kubeflow](http://kubeflow.org) on OpenShift  / Kubernets cluster.

Machine learning model development and operationalization currently has very few industry-wide best practices to help us reduce the time to market and optimize the different steps.

However in traditional application development, DevOps practices are becoming ubiquitous. 
We can benefit from many of these practices by applying them to model development and operationalization.

Here are a subset of pain points that exists in a typical ML workflow.

## A Typical ML Workflow and its Pain Points
![Typical Workflow]({% image_path workflow.png %})

This workshop is going to focus on improving the training and serving process by leveraging containers and OpenShift.

Today many data scientists are training their models either on their physical workstation (be it a laptop or a desktop with multiple GPUs) or using a VM (sometime, but rarely, a couple of them) in the cloud.

This approach is sub-optimal for many reasons, among which:

* Training is slow and sequential
  * Having a single (or few) GPU on hand, means there is only so much trainings you can do at the time. It also means that once your GPU is busy with a training you cannot use it to do something else, just as smaller experiments.
  * Hyper-parameter sweeping is vastly inefficient: The different hypothesis you want to test will run sequentially and not in parallel. In practices this means that very often we don't have time to really explore the hyper-parameter space and we just run a couple of experiments that we think will yield the best result.
  The longer the training time, the fewer experiments we can run.
* Distributed training is hard (or impossible) to setup
  * In practice very few data scientist benefit from distributed training. Either because they simply can't use it (you need multiple machines for that), or because it is too tedious to setup.
* High cost
  * If each member of the team has it's own allocated resources, in practices it means many of them will not be used at any given time, given the price of a single GPU, this is very costly. On the other hand pooling resourcing (such as sharing VM) is also painful since multiple people might want to use them at the same time.

Using OpenShift, we can alleviate many of these pain points:

* Training is massively parallelizable
  * Kubernetes is highly scalable. In practice that means you could run as many experiments as you want at the same time. This makes exploring and comparing different hypothesis much simpler and efficient.
* Distributed training is much simpler
  * As we will see in this workshop, it is very easy to setup a TensorFlow distributed training on kubernetes, and scale it to whatever size you want, making much more usable in practice.

## Kubeflow

This workshop will serve as an introduction to Kubeflow, an open-source project which aims to make running ML workloads on Kubernetes simple, portable and scalable. 
Kubeflow adds some resources to your cluster to assist with a variety of tasks, including training and serving models and running Jupyter Notebooks. 
It also extends the Kubernetes API by adding new Custom Resource Definitions (CRDs) to your cluster, so machine learning workloads can be treated as first-class citizens by Kubernetes.


## What You'll Build

![MNIST UI]({% image_path mnist-ui.png %})

This workshop will describe how to train and serve a TensorFlow model, and then how to deploy a web interface to allow users to interact with the model over the public internet. You will build a classic handwritten digit recognizer using the MNIST dataset.

The purpose of this workshop is to get a brief overview of how to interact with Kubeflow. To keep things simple, use CPU-only training, and only make use of a single node for training. Kubeflow's documentation has more information when you are ready to explore further.







