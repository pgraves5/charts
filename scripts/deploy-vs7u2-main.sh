
kubectl -n vmware-system-appplatform-operator-system get cm ${service_id} 2>/dev/null
if [ $? -eq 0 ]
then
    echomsg "ObjectScale Plugin \"${service_id}\" has already been deployed"
    echomsg "It must be disabled and removed before a new one can be applied"
    exit 1
fi


echomsg dl 
echomsg "Adding the ObjectScale plugin for vSphere7"

## rest of the code below is built with vmware/vmware_pack.sh
cat <<'EOF' | kubectl apply -f -
