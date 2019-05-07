# FIO Helm Chart

This Helm chart defines tests to check kubernetes volume status using FIO tools, a tool that would be able to simulate a given I/O workload without resorting to writing a
tailored test case.

## Table of Contents
* [Description](#description)
* [Requirements](#requirements)
* [Quick Start](#quick-start)

## Description

Fio test chart includes a dummy ConfigMap and a Pod for helm test, dummy ConfigMap is to meet the at least one valid resource without hook requirement and deployed during helm installation.Helm test pod is created until helm test command is called.

## Requirements

* A [Helm](https://helm.sh) installation with access to install to one or more namespaces.
* Access to an up-and-running Kubernetes cluster, which could be the ECS cluster here.

## Quick Start

1. First, [install and setup Helm](https://docs.helm.sh/using_helm/#quickstart).  *_Note:_* you'll likely need to setup role-based access controls for Helm to have rights to install packages, so be sure to read that part.

2. Setup the [EMCECS Helm Repository](https://github.com/EMCECS/charts).

```bash
$ helm repo add ecs https://emcecs.github.io/charts
$ helm repo update
```

3. Install the sonobuoy. This allows you to create and manage ECS clusters.

```bash
$ helm install --name fio-test ecs/fio-test
NAME:   fio-test
```

4. Running helm test

```bash
$ helm test fio-test
NAME:   fio-test
```

5. Until helm test compelted, logs can be collected by the command below
```bash
$ kubectl logs fio-test
```

6. If you want to rerun this test, manually delete current test pod and rerun the helm test command
```bash
$ kubectl delete po fio-test

$ helm test fio-test

```