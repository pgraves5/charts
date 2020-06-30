#!/bin/bash 
##
## Copyright (c) 2020. Dell Inc. or its subsidiaries. All Rights Reserved.
##
## This software contains the intellectual property of Dell Inc.
## or is licensed to Dell Inc. from third parties. Use of this software
## and the intellectual property contained therein is expressly limited to the
## terms and conditions of the License Agreement under which it is provided by or
## on behalf of Dell Inc. or its subsidiaries.


echomsg () {

    if [ ! -d ./log ]
    then 
	      mkdir ./log
    fi 

    curdate=$(date +"%y.%m.%d %H:%M:%S")

    case $1 in
	    log)
	        msg=$2
          echo "$curdate : $msg"  >> $logfile
	        return
	        ;;
	    stl|starline)
	        msg="**********************************************"
	        ;;
	    dl|doubleline)
	        msg="=============================================="
	        ;;
      sl|singleline)
	        msg="----------------------------------------------"
	        ;;
      nl|newline)
	        msg=" "
	        ;;
	    *)
	        msg="$1"
	        ;;
    esac

    ## ok now show the message
    echo "$curdate : $msg" | tee -a $logfile

} #end echomsg

## add_vsphere7_clusterole_rules 
## Add rules needed to apply our plugin
add_vsphere7_clusterrole_rules () {
  vsphere7AppRoles="kubectl get -n vmware-system-appplatform-operator-system clusterrole vmware-system-appplatform-operator-manager-role  -o yaml"
  numRoles=$(eval ${vsphere7AppRoles} | egrep -c -e "- batch|- app.k8s.io")

  if [ ${numRoles} -le 1 ] 
  then
      echomsg log "Adding roles to app platform"
      cat <<'EOT' > /tmp/newroles.yaml
- apiGroups:
  - batch
  resources:
  - cronjobs
  verbs:
  - get
  - list
  - create
  - update
  - patch
  - delete
- apiGroups:
  - app.k8s.io
  resources:
  - applications
  verbs:
  - '*'
EOT
      eval ${vsphere7AppRoles} > /tmp/currrules.yaml
      kubectl apply -f <(cat <(cat /tmp/currroles.yaml) /tmp/newrules.yaml)
      if [ $? -ne 0 ] 
      then
          echomsg log "Error: unable to apply the clusterrole rules for clusterrole vmware-system-appplatform-operator-manager-role"
          exit 1
      fi
  fi 
}
## main()
curdate=`date +"%y%m%d"`
logfile="./log/deploy-objectscale-$curdate.log"

echomsg log "Starting deployment of ObjectScale"
echomsg dl

echomsg log "Locating kubectl..."
kubectl version --short=true > /tmp/kubectl_version.txt
if [ $? -ne 0 ]
then
    echomsg log "error unable to located kubectl in the PATH"
    exit 1
fi 

echomsg log "$(cat /tmp/kubectl_version.txt)"

## Now check if the api groups have been added for VMware vSphere7 app platform:
add_vsphere7_clusterrole_rules

echomsg dl 
echomsg log "Adding the ObjectScale plugin for vSphere7"

cat <<'EOF' | kubectl apply -f - 2>/dev/null
