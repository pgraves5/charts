# Dell EMC SRS Gateway Custom Resource Support

This Helm chart deploys an SRS Gateway Custom Resource (CR) for a given
Dell EMC product and an associated credentials secret. These resources will
be used the the Dell EMC Common Kubernetes Support (DECKS) to create all
of the necessary resources for registering with and communicating with an
SRS gateway. See "Description" section for more details.

## Table of Contents

* [Description](#description)
* [Requirements](#requirements)
* [Quick Start](#quick-start)
* [Configuration](#configuration)

## Description

This Helm chart deploys:
- An SRS Gateway Custom Resource (CR) for a given Dell EMC product.
  The SRS Gateway CR:
  - Allows the Dell EMC Common Kubernetes Support (DECKS) to register a
    Dell EMC product with a given SRS gateway
  - Triggers creation of a "remote access" pod/service that allows customers
    and customer support a mechanism (via SRS) to SSH into the Kubernetes
    cluster for performing service and maintenance.
  - Provides notifier resources that allow the Kubernetes Application Health
    Monitor (KAHM) to send select Kubernetes events as SRS events/alerts to
    the SRS gateway.
- A credentials secret that contains:
  - A login username/password for DECKS to use in registering a product
    with the SRS gateway.
  - User/group/password credentials to configure in the remote access pod.

The product name used for this helm chart must be an official, "on-boarded"
product/model that the SRS gateway recognizes as an official Dell EMC product
(e.g. OBJECTSCALE).

DECKS implements a Kubernetes controller that watches for creation, update,
and deletion of SRS gateway CRs. When an SRS gateway custom resource and an
associated credentials secret are created via this helm chart, DECKS will
do the following:
- Set up a remote access pod/service to allow customers/customer support
  to remotely access (via SSH) a Kubernetes cluster for servicing/maintenance.
- Register with the SRS Gateway, based on an IP or FQDN and port
- Perform a "call home" test to verify that DECKS can properly make RESTful
  API calls to send events to the SRS gateway.
- Create an SRS GW config secret that an KAHM SRS notifier will use to
  access credentials for making RESTful API calls to the SRS gateway.
- Create a KAHM SRS notifier custom resource, deployment, and service.

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

3. Install the SRS gateway custom resource and credentials secret.

NOTE: The following options are mandatory:
* product:
Must be an official, "on-boarded" EMC product/model that is recognized by the SRS gateway that you're using.
* gateway.hostname:
Can be either the IP address or an FQDN for accessing the SRS gateway.
* gateway.login:
This should be set to the user:password that was supplied by Dell/EMC for registering a product with an SRS gateway. It is typically of the form `john.doe@example.com:MyPassword`.

```bash
$ helm install --name srs-gateway ecs/srs-gateway --set product=OBJECTSCALE --set gateway.hostname=10.249.253.18 --set gateway.login=john.doe@example.com:MyPassword
...
```

There are [configuration options](#configuration) you can peruse later at your heart's delight.

## Configuration

### product - MANDATORY
Must be an official, "on-boarded" EMC product/model that is recognized by the SRS gateway that you're using.

Example helm install command line setting:
```
--set product=OBJECTSCALE
```

### gateway.hostname - MANDATORY
Can be either the IP address or an FQDN for accessing the SRS gateway.

Example helm install command line setting:
```
--set gateway.hostname=10.249.253.18
```

### gateway.login - MANDATORY
The gateway.login configures the login username/password for DECKS to use for registering with the SRS gateway.

Example helm install command line setting:
```
--set gateway.login=john.doe@example.com:MyPassword
```

### customResourceName
The name to use for the SRS GW custom resource Kubernetes object. If set, this name will be used as a prefix for all secondary resources generated for the SRS GW custom resource. This allows for multiple SRS GW custom resources to use the same product name, while providing distinct names for the SRS GW CRs and their corresponding secondary resources.

This explicit setting for resource name is provided primarily for testing. Production setups should leave this unset.

If "customResourceName" is not set, the lowercase version of the "product" setting will be used for the name of the SRS GW CR as well as a name prefix for all secondary resources.

For example, if customResourceName is set, then the SRS credentials secret will be created with the name:
```
    <customResourceName>-srs-creds-secret
```
Otherwise, the SRS credential secret will be created with the name:
```
    <product>-srs-creds-secret
```

Example helm install command line setting:
```
--set customResourceName=objectscale
```

### namespace
The SRS gateway custom resource and its secondary resources can be configured to be installed in an explicit namespace using the "namespace" setting.

Default:
* namespace: default

Example helm install command line setting:
```
--set namespace=objectscale
```

### Global Docker Registry Settings (registry, tag, pullPolicy)
These global settings can be used to configure the Docker registry, tag, and/or
pullPolicy to use for both the remote access and the notifier pods.

Defaults:
* registry: emccorp
* tag: stable
* pullPolicy: Always

Example helm install command line setting:
```
--set registry=harbor.lss.emc.com/ecs
--set tag=latest
--set pullPolicy=IfNotPresent
```

### gateway.port
The gateway.port setting configures the port on which the SRS Gateway is listening on.

Defaults:
* gateway.port: 9443

Example helm install command line setting:
```
--set gateway.port=4567
```

### remoteAccess Docker Registry Settings
These settings can be used to customize the Docker registry, repository, tag, and pull policy to use for the remoteAccess pod image.

Defaults:
* remoteAccess.registry=emccorp
* remoteAccess.repository=srs-notifier
* remoteAccess.tag=stable
* remoteAccess.pullPolicy=Always

Example helm install command line setting:
```
--set remoteAccess.registry=harbor.lss.emc.com/ecs
--set remoteAccess.repository=my-special-remote-access
--set remoteAccess.tag=latest
--set remoteAccess.pullPolicy=IfNotPresent
```

### notifier Docker Registry Settings
These settings can be used to customize the Docker registry, repository, tag, and pull policy to use for the notifier pod image.

Defaults:
* notifier.registry=emccorp
* notifier.repository=srs-notifier
* notifier.tag=stable
* notifier.pullPolicy=Always

Example helm install command line setting:
```
--set notifier.registry=harbor.lss.emc.com/ecs
--set notifier.repository=my-special-remote-access
--set notifier.tag=latest
--set notifier.pullPolicy=IfNotPresent
```

### remoteAccess User Login Credentials (user, group, password)
These settings can be used to customize the login access to the remote access pod, including user, group, and password to configure.

Defaults:
* remoteAccess.user: root
* remoteAccess.group: adm
* remoteAccess.password: ChangeMe

Example helm install command line setting:
```
--set remoteAccess.user=admin
--set remoteAccess.group=adm
--set remoteAccess.password=P@ssw0rd
```

### grpcConnTimeout, grpcRetries
These settings can be used to configure the timeout interval and the number of retries for the SRS notifier pod when it tries to send events to the SRS gateway.

Defaults:
* notifier.grpcConnTimeout: 5
* notifier.grpcRetries: 5

Example helm install command line setting:
```
--set notifier.grpcConnTimeout=10
--set notifier.grpcRetries=6
```
