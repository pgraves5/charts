# Dell EMC Elastic Cloud Storage (ECS) Helm Chart

This Helm chart deploys a fully functional Dell EMC Elastic Cloud Storage (ECS) S3-compatible storage system.

## Requirements

* A [Helm](https://helm.sh) installation with access to install to one or more namespaces.
* [ECS Flex Operator](https://github.com/EMCECS/charts/tree/master/ecs-flex-operator). Only a single operator needs to be installed for a monitored namespace or Kubernetes cluster.
* A Kubernetes Storage Class capable of dynamically creating `ReadWriteOnce` (`RWO`) volumes. This is available in many public Kubernetes services, such as AWS EKS and Google GKE. For more information see the [storage class section](#sc-setup) below.

## Configuration



## <a name="sc-setup"></a>Private Kubernetes Storage Class Setup

For private Kubernetes deployments, if a dynamic storage class does not already exist, it must be setup. Both [Minikube](https://kubernetes.io/docs/setup/minikube/) and [Docker for Desktop](https://www.docker.com/products/docker-desktop) Kubernetes distributions include such a storage class by default. For convenience, we've added instructions for VMware vSphere virtualised clusters, and Dell EMC VxFlex OS supported options.

### VMware vSphere Storage Class Setup

VMware vSphere supports a private storage class for dynamic creation and attachment of VMDK volumes. This driver is distributed with Kubernetes, so simply create a storage-class as follows:

```bash
$ kubectl apply -f - <<-EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: vsphere
  annotations:
    storageclass.kubernetes.io/is-default-class: true
provisioner: kubernetes.io/vsphere-volume
parameters:
  diskformat: zeroedthick
  fstype: xfs
EOF
```

### Dell EMC VxFlex OS

When deploying on a [Dell EMC VxFlex-based system](https://www.dellemc.com/en-us/solutions/software-defined/vxflex-ready-nodes.htm), you can install a storage class using the available [VxFlex OS CSI driver Helm chart](https://github.com/VxFlex-OS/charts).
