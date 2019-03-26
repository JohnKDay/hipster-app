#!/usr/bin/env bash
#
# Function: Given CCP CP IP:port address (MGMT_HOST), CCP CP password (PASS), Harbor TC name (CLUSTER) and CCP TC Harbor admin password (HARBOR_PASS)
#   Will perform:
#   - Create 'temp' subdirectory
#   - Obtain session cookie from CCP CP and place in temp directory
#   - Extract Harbor TC information and place in temp directory
#   - Download Harbor TC KUBECONFIG file and place in temp directory
#   - Pull Harbor TC ca.crt file and place in temp directory
#   - Obtain Harbor TC Load Balancer IP address
#   - *SUDO* Create /etc/docker/certs.d/<Harbor CP LBIP> directory
#   - *SUDO* Copy Harbor TC ca.crt file to /etc/docker/certs.d/<Harbor CP LBIP>/
#   - Pull busybox container image from docker.io
#   - Login to Harbor registry with admin and password
#   - Tag busybox image to Harbor IP address in 'library' Project
#   - Push tagged busybox image to Harbor IP address

set -v
set -euo pipefail

# Verify minimum variables set 
if [ -z "$MGMT_HOST" ]; then
   printf "Error: need MGMT_HOST env variable set\n"
   exit 1
fi
if [ -z "$PASS" ]; then
   printf "Error: need PASS env veriable set\n"
   exit 2
fi
CLUSTER=${1:-harbor}
HARBOR_PASS=${HARBOR_PASS:-$PASS}

# Create 'temp' subdirectory
[ -d temp ] || mkdir temp
[ -w temp/_context-merge.KUBECONFIG ] || touch temp/_context-merge.KUBECONFIG

# Obtain session cookie from CCP CP and place in temp directory
curl -k -c temp/cookie.txt -H "Content-Type:application/x-www-form-urlencoded" -d "username=admin&password=${PASS}" https://$MGMT_HOST/2/system/login/

# Extract Harbor TC information and place in temp directory
curl -sk -b temp/cookie.txt https://$MGMT_HOST/2/clusters/${CLUSTER}| tee temp/${CLUSTER}.json| jq '.name,.uuid,.state'

# Download Harbor TC KUBECONFIG file and place in temp directory
TC=$(jq -r '.uuid' temp/${CLUSTER}.json)
echo $TC
if [ -x "$(type -p set_kubeconfig_cluster.rb)" ]; then
  curl -sk -b temp/cookie.txt https://$MGMT_HOST/2/clusters/${TC}/env | set_kubeconfig_cluster.rb ${CLUSTER} >  temp/${CLUSTER}.KUBECONFIG
else
  curl -sk -b temp/cookie.txt https://$MGMT_HOST/2/clusters/${TC}/env >  temp/${CLUSTER}.KUBECONFIG
fi

# Pull Harbor TC ca.crt file and place in temp directory
KUBECONFIG=temp/${CLUSTER}.KUBECONFIG kubectl get secret ccp-ingress-tls-ca -n ccp -o jsonpath='{.data.tls\.crt}' |base64 -d | tee  temp/ccp.crt

# Obtain Harbor TC Load Balancer IP address 
LBIP=$(KUBECONFIG=temp/${CLUSTER}.KUBECONFIG kubectl get svc -n ccp -o jsonpath='{.items..status.loadBalancer.ingress[0].ip}') 

# Copy Harbor CA cert into /etc/docker/certs.d for use on install machine
sudo mkdir -p /etc/docker/certs.d/${LBIP}
sudo cp temp/ccp.crt /etc/docker/certs.d/${LBIP}/ca.crt

# Pull busybox container image from docker.io
docker pull busybox

#Login to Harbor registry with admin and password
docker login -u admin -p ${HARBOR_PASS} ${LBIP}

# Tag busybox image to Harbor IP address in 'library' Project
docker tag busybox ${LBIP}/library/busybox

# Push tagged busybox image to Harbor IP address
docker push ${LBIP}/library/busybox

exit 0
