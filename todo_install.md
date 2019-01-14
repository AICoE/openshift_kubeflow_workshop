* add cluster-admin to tf-job-operator

```
oc adm policy add-role-to-user cluster-admin -z tf-job-operator
```

* expose some services

```
oc expose svc/minio-service -n kubeflow
oc expose svc/centraldashboard -n kubeflow
```

* add view perms to kubeflow NS for userN


TODO workshop

* make name in job and serving a param
