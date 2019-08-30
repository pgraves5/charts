# Helm Chart for Installing Dell EMC License
The chart will allow a user to install DELL EMC License in Kubernetes cluster for a product.

A user has to provide a license xml file for a product from the command line to generate the license secret object for the product. The secret object will be labeled with "com.dellemc.decklicense.subscribed=true" so that DECKS (Dell EMC Common Kubernetes Services) can create a license resource from the secret.

 
## Table of Contents

* [Description](#description)
* [Requirements](#requirements)
* [Quick Start](#quick-start)
* [Configuration](#configuration)

## Description

This Helm chart deploys:
- A Secret object.
  - will have base64 encoded license secret
  - will be labeled with "com.dellemc.decklicense.subscribed=true"
  - If the secret is created successfully and DECKS is running, a license resource will get created for the product.

## Requirements

* A [Helm](https://helm.sh) installation with access to install to one or more namespaces.
* A [DECKS](https://github.com/EMCECS/charts/tree/master/decks) installation.

## Quick Start

1. First, [install and setup Helm](https://docs.helm.sh/using_helm/#quickstart).  *_Note:_* you'll likely need to setup role-based access controls for Helm to have rights to install packages, so be sure to read that part.

2. Setup the [EMCECS Helm Repository](https://github.com/EMCECS/charts).

```bash
$ helm repo add ecs https://emcecs.github.io/charts
$ helm repo update
```

3. Install the License by using the followings. 
```bash
$ helm install --name <custom-release-name> ecs/dellemc-license --set-file licensefile=<location of the license xml file> --set product=<product name>
$ helm install --name streamingdata-license ecs/dellemc-license --set-file licensefile=/home/john/streamingdata-license.xml --set product=streamingdata
```
```bash
$ helm upgrade streamingdata-license  dellemc-license --set-file licensefile=/home/john/streaming-license.xml --set product=streamingdata
```

4. After installing the license secrets, and DECKS is running, it should generate a license resource:
```bash
$ kubectl get licenses
```
## Configuration

###  licensefile
it is a location of the license xml file. If the file is in your current directory, you can simply provide the name of the xml file. If the file is in some other location, you need to provide the relative or absolute path of the file.
Example helm install command line setting:
```
--set-file licensefile=objectscale-license.xml
--set-file licensefile=/home/xxx/objectscale-license.xml
--set-file licensefile=../../../xxx/objectscale-license.xml
```

### product 
it is used to create a unique license secret name for each product so that you can install multiple licenses with the different product names.
Example helm install command line setting:
```
--set product="objectscale"
```
