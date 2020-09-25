#Dell EMC IAM  Helm Chart

This Helm chart deploys a Dell EMC IAM Service and its dependencies.

## Table of Contents

* [Description](#description)

## Description

The Dell EMC IAM Service is 2 k8s pods:
- atlas instance with persistent volume claim (Retain)
- iamservice controller to support accounts,  iam entities and iamclient requests

By default the iam feature is not enabled in objectscale-manager.

To enable iam on the install - include:
```bash
  --set iam.enabled=true
```


The atlas registry port is 8099, the objectscale port is 8200.
In order to find the iam images (including atlas) - include:
```bash
  --set global.iam.registry=asdrepo.isus.emc.com:8099
```



By default the iam number of replicas is set to 1.
To increase the number of replicas use:
```bash
  --set global.iam.atlas.replicaCount=3
```

If installing on single node with replicaCount=3, you will also need to set affinity:
```bash
  --set global.iam.atlas.affinity=true
```


