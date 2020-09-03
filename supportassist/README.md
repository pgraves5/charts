# Helm Chart for Deploying Dell EMC SupportAssist Embedded Services Enabler
This chart allows the user to deploy a Dell EMC embedded services enabler pod in the Kubernetes cluster for a product.
 
## Table of Contents

* [Description](#description)
* [Requirements](#requirements)
* [Quick Start](#quick-start)
* [Configuration](#configuration)

## Description

This Helm chart deploys:
1. A k8s statefulset pod for SupportAssist ESE for the product:
   `supportassist-objectscale-0`
2. A persistent volume to store logs and secure keys
3. Future changes will add in the supportassist custom resource, secrets etc...

## Requirements

* A [Helm 3.0](https://helm.sh) installation with access to install to one or more namespaces.
* Access to https://github.com/EMCECS/charts
* Access to docker registries:
    * https://hub.docker.com/objectscale
    * https://asdrepo.isus.emc.com:9042
* Dell EMC Connectivity servers:
    * Direct firewalled access to https://esrs3*.com servers or
    * Local SRS gateways already firewalled to Dell EMC Connectivity servers:
* SupportAssist ESE Release Info:
    * http://10.236.140.82/ese/
    - Username: `cecuser`
    - Password: `Password!`

## Quick Start

1. First, [install and setup Helm](https://docs.helm.sh/using_helm/#quickstart).

2. Using your github token add the helm chart repo

    ```
    $ helm repo add objscharts https://<yourgihubtoken>@raw.githubusercontent.com/emcecs/charts/master/docs
    $ helm repo update
    ```

3. Install the Dell EMC Embedded support enables (ESE) for the product: 
    - for **objectscale** 
    ```
    $ helm install sa-objs objscharts/supportassist --set product=objectscale --set global.registry=asdrepo.isus.emc.com:9042
    ```

4. Verify the pod and service is available:
    ```bash
    $ kubectl get pod,svc -l release=supportassist-objectscale

    NAME                              READY   STATUS    RESTARTS   AGE
    pod/supportassist-objectscale-0   1/1     Running   0          15h

    NAME                                         TYPE           CLUSTER-IP   EXTERNAL-IP    PORT(S)                         AGE
    service/supportassist-objectscale            LoadBalancer   10.96.1.89   10.240.124.9   9447:31526/TCP,8080:32740/TCP   15h
    service/supportassist-objectscale-headless   ClusterIP      None         <none>         9447/TCP,8080/TCP               15h
    ```


## Configuration
- SupportAssist ESE services are now running with an empty configuration.  Use the steps below to configure ESE for the product.

1. Use [postman](https://postman.com) to create a collection of REST API calls
    
2. GET the status of the ESE service:
    ```
    GET http://{{ESEHOSTPORT}}/ese/status
    Returns:
    ```
    ```json
    {
        "communicationEnabled": true,
        "eseVersion": "2.0.3.7",
        "primaryDirectEndpoint": "https://esrs3-corestg.isus.emc.com",
        "primaryGatewayEndpoint": "https://10.249.238.250:9443",
        "connectionPreference": "gateway",
        "lastConnection": "2020-09-03 04:15:45",
        "eseProcessInfo": {
            "timestamp": 1599106924,
            "pid": 14,
            "memory": 50094080,
            "cpu_percent": 0.0
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
            "productType": "dell.enterprise.storage.objectscale",
            "productName": "OBJECTSCALE",
            "productVersion": "0.52.0"
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
    ```

4. Now obtain an access key using the product name, Party (site ID) and a PIN:
    - Go to: https://connectivitykeyprovider.cft.isus.emc.com/accessCodes
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
            "serialNumber": "ELMOBJ09209QZC"
        }
    }
    ```
7. Use the `serialNumber` value returned above for all subsequent ESE API calls for identification (i.e.):
    ```json
    {
        "identifiers": [
			{
				"idType": "serialNumber",
				"value": "ELMOBJ09209QZC"
			}
		],
    }


