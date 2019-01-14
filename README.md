# Kubeflow on OpenShift Workshop

An introductionary workshop on using Kubeflow on OpenShift


## Credits

Most of the content is based on the work of others. Especially the prose words in the workshop documentation.

* [Kubeflow upstream MNIST example](https://github.com/kubeflow/examples/tree/master/mnist)
* [Kubeflow on AKS](https://github.com/Azure/kubeflow-labs)
* [Kubeflow Codelabs](https://codelabs.developers.google.com/codelabs/kubeflow-introduction/index.html)
* [Kubeflow Introduction](https://github.com/googlecodelabs/kubeflow-introduction)
* [OpenShift Starter Guides](https://github.com/openshift-labs/starter-guides)


## Prepare OpenShift for kubeflow

This workshop is based on OpenShift 3.11 and Kubeflow 0.4.0

Here is what you need to do after installing kubeflow:

* expose minio via route


## Workshop created with Workshopper

This workshop was created using [Workshopper](https://github.com/openshift-evangelists/workshopper) which is an engine for building a web-based workshop 


### Deploy On OpenShift

```
make deploy
```

If you've made changes and pushed them to github, trigger a rollout with

```
make rollout
```


### Test Locally with Docker

You can directly run Workshopper as a docker container which is specially helpful when writing the content.

```
make docker
```

Go to http://localhost:8080 on your browser to see the rendered workshop content. You can modify the lab instructions 
and refresh the page to see the latest changes.