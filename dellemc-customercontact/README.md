# Helm Chart for Installing Dell EMC product customer contacts
The chart will allow a user to install a Dell EMC product customer contact list in the Kubernetes cluster for a product.

A user has to provide a customer contact yaml file for a product from the command line to generate a Dell EMC k8s customercontact resource. The CR object will be captured by DECKS(Dell EMC Common Kubernetes Services) and send it to support assist.

 
## Table of Contents

* [Description](#description)
* [Requirements](#requirements)
* [Quick Start](#quick-start)
* [Configuration](#configuration)

## Description

This Helm chart deploys:
- A Dell EMC k8s customercontact resource object.

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

3. Install the Dell EMC product CustomerContact by using the followings. 
```bash
$ helm install <custom-release-name> ecs/dellemc-customercontact --set-file customercontactfile=<location of the customercontact yaml file> --set product=<product name>
$ helm install objectscale-customercontact ecs/dellemc-customercontact --set-file customercontactfile=/home/john/objectscale-customercontact.yaml --set product=objectscale
```
```bash
$ helm upgrade objectscale-customercontact  dellemc-license --set-file customercontactfile=/home/john/objectscale-customercontact.yaml --set product=objectscale
```

4. After installing the customercontact, it should generate a Dell EMC k8s customercontact resource:
```bash
$ kubectl get customercontacts
NAME                                   AGE
dellemc-objectscale-customercontacts   1m
```
## Configuration

###  customercontactfile
it is a location of the product customer contact yaml file. The file must be in yaml format and follow the template below.If the file is in your current directory, you can simply provide the name of the yaml file. If the file is in another location, you need to provide the pathname of the file.
Example helm install command line setting:
```yaml
spec:
  productname: objectscale
  producttype: dell.enterprise.storage.objectscale
  productversion: 0.25.0
  contacts:
  - contactorder: 1
    firstname: XXX
    lastname: XXX
    phonenumber: "+1 (555) 555-7746"
    emailaddress: test@dell.com
    timezoneoffset: -06:00
    prefcontact: phone
    prefcontacttime: 11:00AM - 1:00AM
    preflanguage: En
  - contactorder: 2
    firstname: XXX
    lastname: XXX
    phonenumber: "+1 (312) 555-7748"
    emailaddress: test@dell.com
    timezoneoffset: -06:00vim
    prefcontact: email
    prefcontacttime: 1:00PM - 3:00AM
    preflanguage: En
```
Example helm install command line setting:
```
--set-file customercontactfile=objectscale-customercontact.yaml
--set-file customercontactfile=/home/xxx/objectscale-customercontact.yaml
--set-file customercontactfile=../../../xxx/objectscale-customercontact.yaml


```

### product 
it is used to create a unique customercontact resource for each product. 
it should be consistent with the productName in SupportAssist CR
Example helm install command line setting:
```
--set product="objectscale"
```
