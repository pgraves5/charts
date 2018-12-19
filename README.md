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

  - Navigate to your account settings
  - Select _"Developer settings" on the left-side menu
  - Select "Personal access tokens" on the left-side menu
  - Click "Create new token" at the top right
  - Add a token description
  - Select the "repo" permissions checkbox
  - Copy the token for use in the next step

2. Create the repository using your token:

```bash
$ helm repo add ecs 'https://MY_PRIVATE_TOKEN@raw.githubusercontent.com/EMCECS/charts/master/docs'
$ helm repo update
```

3. Ensure that you can see the ECS charts

```bash
$ helm search ecs
NAME                            	CHART VERSION	APP VERSION	DESCRIPTION
ecs/ecs-cluster                 	0.1.0        	1.0        	Elastic Cloud Storage is a highly scalable, S3 compatible...
ecs/ecs-flex-operator           	0.1.0        	1.0        	Dell EMC Elastic Cloud Storage is highly scalable, and hi...
ecs/mongoose                    	0.1.0        	1.0        	Mongoose is a horizontally scalable and configurable S3 p...
ecs/zookeeper-operator          	0.0.1        	2.6.0      	Zookeeper operator deploys a custom resource for a zookee...
```
