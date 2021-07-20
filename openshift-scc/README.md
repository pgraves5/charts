# Modify OpenShift SCC for the namespace

This chart creates clusterrolebinding for all the serviceaccounts in the given namespace to the clusterrole - system:openshift:scc:anyuid. This will allow all the containers and pods in the given namespace to run with  SCC: any-userid. The pods/containers can run as root or UID which is not within the range of the OpenShift namespace.


