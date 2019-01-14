# tensorflow-model

This folder contains files necessary to build a container for a tf-job

- model.py
  - contains TensorFlow code to train a model and upload the results to kubeflow provided minio
- Dockerfile
  - describes how to build a container to run the job

---
This is based on the work from https://github.com/googlecodelabs/kubeflow-introduction
