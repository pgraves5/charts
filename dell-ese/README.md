# Helm Chart for Deploying Dell EMC Enbedded Support Enabler
This chart allows the user to deploy a Dell EMC embedded support enabler service in the Kubernetes cluster for a product.
 
## Table of Contents

* [Description](#description)
* [Requirements](#requirements)
* [Quick Start](#quick-start)
* [Configuration](#configuration)

## Description

This Helm chart deploys:
1. A k8s set of services for REST API access
2. A persistent volume for the ESE Pod
3. A `dell-ese-<productname>` pod 

## Requirements

* A [Helm 3.0](https://helm.sh) installation with access to install to one or more namespaces.
* Access to https://github.com/EMCECS/charts
* Access to docker registries:
    * https://hub.docker.com/emccorp 
    * https://harbor.lss.emc.com/ecs
* Dell EMC Connectivity servers:
    * Direct firewalled access to https://esrs3*.com servers or
    * Local SRS gateways already firewalled to Dell EMC Connectivity servers:
* Dell EMC ESE Release Notes:
    * http://100.90.136.211/builds-ese/ese/latest/release-notes.txt


## Quick Start

1. First, [install and setup Helm](https://docs.helm.sh/using_helm/#quickstart).  *_Note:_* you'll likely need to setup role-based access controls for Helm to have rights to install packages, so be sure to read that part.

2. Use `git clone` or `git pull` to get the latest changes from master:

    ```
    $ cd src/emcecs
    $ git clone https://github.com/emcecs/charts
    $ git checkout -b feature-ese-1.1
    ```

3. Install the Dell EMC Embedded support enables (ESE) for the product: 
    - for **objectscale** 
    ```
    $ helm install de-objs ./dell-ese --set product=objectscale --set global.registry=harbor.lss.emc.com/ecs
    ```
    - for **streamingdata**
    ```
    $ helm install de-objs ./dell-ese --set product=streamingdata --set global.registry=harbor.lss.emc.com/ecs
    ```

4. Verify the pod and service is available:
    ```
    $ kubectl get pod,svc -l release=dell-ese-objectscale
    NAME                         READY   STATUS    RESTARTS   AGE
    pod/dell-ese-objectscale-0   1/1     Running   0          19h

    NAME                                    TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)                         AGE
    service/dell-ese-objectscale            LoadBalancer   10.100.200.231   10.240.125.192   9447:30421/TCP,8080:32312/TCP   19h
    service/dell-ese-objectscale-headless   ClusterIP      None             <none>           9447/TCP,8080/TCP               19h
    ```


## Configuration
- ESE services are now running with an empty configuration.  Use the steps below to configure ESE for the product.

1. Use [postman](https://postman.com) to create a collection of REST API calls
    
2. GET the status of the ESE service:
    ```
    GET http://{{ESEHOSTPORT}}/ese/status
    Returns:
    ```
    ```json
    {
        "communicationEnabled": true,
        "eseVersion": "1.1.1.9",
        "primaryDirectEndpoint": "https://esrs3-corestg.isus.emc.com",
        "primaryGatewayEndpoint": "https://10.249.238.218:9443",
        "connectionPreference": "gateway",
        "lastConnection": "2020-02-24 13:42:53",
        "eseProcessInfo": {
            "timestamp": 1582552016,
            "pid": 6,
            "memory": 49225728,
            "cpu_percent": 10.1
        },
        "initialized": true,
        "proxyMode": "none"
    }
    ```

3. Set the product model, type and version along with a gateway to route data.
    ```
    PUT http://{{ESEHOSTPORT}}/ese/config
    ```
    ```json
    {
        "productIdBlock": {
            "productModel": "OBJECTSCALE",
            "productType": "dell.enterprise.objectscale",
            "productVersion": "0.22.0"
        },
        "useGateways": true,
        "gatewayEndpoints": [
            {
                "url": "https://{{GATEWAY}}:9443",
                "priority": 100,
                "enabled": true,
                "useProxy": false,
                "validateSsl": false
            }
        ]
    }

4. Now obtain an access key using the product name, Party (site ID) and a PIN:
    - Go to: https://ssopcf-connectivityaccesskey-tst.cft.isus.emc.com/
    - Select `SoftwareInstance`
      - Model: `OBJECTSCALE`
      - Party No: (aka site id): `11145366`
    - Click on Submit
    - Now Click on: **Generate New Access Key**
    - Enter Pin: (choose 4 digits, don't forget them as you need them for the next API)')
    - Click **Generate Access Key**

5. Copy this new Access Key into your clipboard (Note: this can only be used one time)

6. Get a new ESE Universal Key, this also returns a new ISWID/SerialNumber for this configuration:
    ```
    POST http://{{ESEHOSTPORT}}/ese/getUniversalKey
    ```
    ```json
    {
        "accesskey": "9E84D0A6",
        "pin": "7777"
    }
    ```
    this returns:
    ```json
    {
        "statusCode": 200,
        "status": "success",
        "message": "getUniversalKey API exercised successfully",
        "backendResponse": {
            "responseCode": 201,
            "message": "Device Key Inserted successfully",
            "serialNumber": "ELMOBJ0220Q3KZ"
        }
    }
    ```
7. Use the `serialNumber` value returned above for all subsequent ESE API calls for identification (i.e.):
    ```json
    {
        "identifiers": [
			{
				"idType": "serialNumber",
				"value": "ELMOBJ0120N59P"
			}
		],
    }


