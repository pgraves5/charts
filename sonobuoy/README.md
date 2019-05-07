# Sonobuoy Helm Chart

This Helm chart deploys [sonobuoy](https://github.com/heptio/sonobuoy), a diagnostic tool that can run kubernetes conformance tests.

## Table of Contents
* [Description](#description)
* [Requirements](#requirements)
* [Quick Start](#quick-start)

## Description

Sonobuoy is an open-source diagnostic tool that makes it easier to understand the state of a Kubernetes cluster by running a set of upstream Kubernetes tests in an accessible and non-destructive manner. Current Kubernetes conformance test suite is [here](https://github.com/cncf/k8s-conformance/blob/master/docs/KubeConformance-1.11.md).

## Requirements

* A [Helm](https://helm.sh) installation with access to install to one or more namespaces.
* Access to an up-and-running Kubernetes cluster, which could be your ECS cluster here.

## Quick Start

1. First, [install and setup Helm](https://docs.helm.sh/using_helm/#quickstart).  *_Note:_* you'll likely need to setup role-based access controls for Helm to have rights to install packages, so be sure to read that part.

2. Setup the [EMCECS Helm Repository](https://github.com/EMCECS/charts).

```bash
$ helm repo add ecs https://emcecs.github.io/charts
$ helm repo update
```

3. Install the sonobuoy. This allows you to create sonobuoy to run K8S confoemance tests.

```bash
$ helm install --name sonobuoy-test ecs/sonobuoy
NAME:   sonobuoy-test
```

4. Running helm test

```bash
$ helm test sonobuoy-test --timeout 1800
NAME:   sonobuoy-test
...
```


5. Wait for about 20 min and you can get the test log
```bash
$ kubectl logs sonobuoy -n heptio-sonobuoy > temp.log
...
```

6. If you want to rerun this test, manually delete current test pod and rerun the helm test command
```bash
$ kubectl delete po sonobuoy -n heptio-sonobuoy
...
$ helm test sonobuoy-test
...
```