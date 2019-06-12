# Dell EMC SRS Gateway Custom Resource Support

This Helm chart deploys an SRS gateway custom resource for a given Dell EMC
product, along with a credentials secret. The SRS gateway custom resource
allows the Dell EMC Common Kubernetes Support (DECKS) to do the following:
- Set up a remote access pod/service to allow customers/customer support
  to remotely access (via SSH) a Kubernetes cluster for servicing/maintenance.
- Register with the SRS Gateway, based on an IP or FQDN and port
- Perform a "call home" test to verify that DECKS can properly make RESTful
  API calls to send events to the SRS gateway.
- Create an SRS GW config secret that an KAHM SRS notifier will use to
  access credentials for making RESTful API calls to the SRS gateway.
- Create a KAHM SRS notifier custom resource, deployment, and service.

The product name must be an official, "on-boarded" product/model that the
SRS gateway recognizes as an official Dell EMC product (e.g. OBJECTSCALE).

## Table of Contents

* [Description](#description)
* [Requirements](#requirements)
* [Quick Start](#quick-start)
* [Configuration](#configuration)
  * [Namespace Access](#namespace-access)
  * [Private Docker Registry](#private-docker-registry)

## Description

## Requirements

* A [Helm](https://helm.sh) installation with access to install to one or more namespaces.

## Quick Start

1. First, [install and setup Helm](https://docs.helm.sh/using_helm/#quickstart).  *_Note:_* you'll likely need to setup role-based access controls for Helm to have rights to install packages, so be sure to read that part.

2. Setup the [EMCECS Helm Repository](https://github.com/EMCECS/charts).

```bash
$ helm repo add ecs https://emcecs.github.io/charts
$ helm repo update
```

3. Install the SRS gateway custom resource and credentials secret.

```bash
$ helm install --name srs-gateway ecs/srs-gateway
NAME:  decks
...
```

There are [configuration options](#configuration) you can peruse later at your heart's delight.

## Configuration

### Namespace Access

The SRS gateway can be configured to be installed in an explicit namespace. To configure a specific namespace, simply set the `global.watchNamespace` setting:

```bash
$ helm install --name srs-gateway \
    --set namespace=my-namespace \
    ecs/decks
```

### Private Docker Registry

While the ECS Flex container images are hosted publicly, DECKS also supports configuration of a private Docker registry for offline Kubernetes clusters or those that do not have access to public registries. To configure a private registry:

1. Download the DECKS container image from [support.emc.com] and upload the images to your private registry.

_*TODO: Add download link once available*_

2. Add a Kubernetes secret for the [private Docker registry](https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod)

```bash
$ kubectl create secret docker-registry decks-registry \
    --docker-username=<DOCKER_USERNAME> \
    --docker-password=<DOCKER_PASSWORD> \
    --docker-email=<DOCKER_EMAIL>
```

3. Set the registry secret and location in the Helm chart installations  via Helm:

```bash
helm install \
    --set global.registry=<REGISTRY ADDRESS> \
    --set global.registrySecret=<SECRET_NAME> \
    ecs/decks
```
