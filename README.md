# Dell EMC Elastic Cloud Storage Helm Charts

This repository provides all Dell EMC Elastic Cloud Storage related packages for [Kubernetes](http://kubernetes.io), formatted as [Helm](https://helm.sh) packages.

To add this repository to your local Helm installation:

> *_NOTE: Currently, this is a private repository, so use the private repo instructions below. Public repo options will be available once we go public._*

## Adding the ECS Repository

```bash
$ helm repo add ecs https://emcecs.github.io/charts
$ helm repo update
```
## Available Charts

* [ECS Flex Operator](ecs-flex-operator)
* [ECS Cluster](ecs-cluster)
* [Zookeeper Operator](zookeeper-operator)
* [Mongoose Load Testing Tool](mongoose)

## Adding the ECS Repository as a private repo (temporary)

1. Create an authentication token in Github with read access to the charts repository.

2. Create the repository using your token:

```bash
$ helm repo add ecs 'https://MY_PRIVATE_TOKEN@raw.githubusercontent.com/EMCECS/charts/master/docs'
$ helm repo update
```
