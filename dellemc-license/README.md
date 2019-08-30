# Dell EMC DKS (KAHM DECKS SRSGateway) Test Application Support
The chart will allow to install DELL EMC License in Kubernetes cluster for a product.

This Helm chart will read the license xml file from the command line option and will generate the license secret for the product. The secret object will be labeled with "com.dellemc.decklicense.subscribed=true" so that DECKS (Dell EMC Common Kubernetes Services) can create a license resource from the secret.

 
## Table of Contents

* [Description](#description)
* [Requirements](#requirements)
* [Quick Start](#quick-start)
* [Configuration](#configuration)

## Description

This Helm chart deploys:
- A Secret object.
  - will have base64 encoded license secret base64
  - will be labeled with "com.dellemc.decklicense.subscribed=true"
  - If the secret is created successfully and DECKS is running, a license resource will get created for the product.

## Requirements

* A [Helm](https://helm.sh) installation with access to install to one or more namespaces.
* A [KAHM](https://github.com/EMCECS/charts/tree/master/kahm) installation.
* A [DECKS](https://github.com/EMCECS/charts/tree/master/decks) installation.
* A [SRS Gateway](https://github.com/EMCECS/charts/tree/master/srs-gateway) installation.

## Quick Start

1. First, [install and setup Helm](https://docs.helm.sh/using_helm/#quickstart).  *_Note:_* you'll likely need to setup role-based access controls for Helm to have rights to install packages, so be sure to read that part.

2. Setup the [EMCECS Helm Repository](https://github.com/EMCECS/charts).

```bash
$ helm repo add ecs https://emcecs.github.io/charts
$ helm repo update
```

3. Install the License by using the followings. 
```bash
$ helm install --name objectscale-license dellemc-license --set-file licensefile=/home/xxx/objectscale-license.xml --set product=streamingdata
```
```bash
$ helm upgrade objectscale-license  dellemc-license --set-file licensefile=objectscale-license.xml --set product=streamingdata
```

4. After installing the license secrets, and DECKS is running, it should generate a license resource:
```bash
$ kubectl get licenses
```
## Configuration

###  licensefile
Can be set to the path of license xml file. If the file is in your current directory, you can simply provide the name of the xml file. If file is in some other location, you need to provide absolute path of the file.
Example helm install command line setting:
```
--set-file licensefile=objectscale-license.xml
--set-file licensefile=/home/xxx/objectscale-license.xml
```

### product 
it is used to create unique license secret name for each product so that you can install multiple licenses with different product names.
Example helm install command line setting:
```
--set product="objectscale"
```
