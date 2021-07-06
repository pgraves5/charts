#!/bin/bash -x

##
## Copyright (c) 2021. Dell Inc. or its subsidiaries. All Rights Reserved.
##
## This software contains the intellectual property of Dell Inc.
## or is licensed to Dell Inc. from third parties. Use of this software
## and the intellectual property contained therein is expressly limited to the
## terms and conditions of the License Agreement under which it is provided by or
## on behalf of Dell Inc. or its subsidiaries.

## iterate thru all the apps to apply

for appfile in ./apps/*
do
    appname=$(grep "  name:" $appfile | cut -d : -f 2)
    if [ ! -z "$appname" ]
    then
        kubectl get app --no-headers $appname 
        if [ $? -ne 0 ]  # its not applied
        then
            ## edit in the registry we've been told to use and remove namespace 
            sed -e "s/REGISTRYTEMPLATE/${GLOBAL_REGISTRY}/g" -e "/namespace:/d" $appfile | kubectl apply -n ${POD_NAMESPACE} -f -
        fi
    fi
done 

./install-controller daemon --accept-eula --repo /docs --max-history 2 


    