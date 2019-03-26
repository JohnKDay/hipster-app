#!/usr/bin/env bash
#
# Function: Given CCP CP IP:port address (MGMT_HOST), CCP CP password (PASS), SAP Data Hub TC name ($1)
#   Will perform:
#   - Create 'temp' subdirectory
#   - Obtain session cookie from CCP CP and place in temp directory
#   - Extract SAP Data Hub TC information and place in temp directory
#   - Download SAP Data Hub TC KUBECONFIG file and place in temp directory
#   - Test the KUBECONFIG file
#   - Print export value to reference the KUBECONFIG file

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
CLUSTER=${1:-datahub}

# Create 'temp' subdirectory
[ -d temp ] || mkdir temp
[ -w temp/_context-merge.KUBECONFIG ] || touch temp/_context-merge.KUBECONFIG

# Obtain session cookie from CCP CP and place in temp directory
curl -k -c temp/cookie.txt -H "Content-Type:application/x-www-form-urlencoded" -d "username=admin&password=${PASS}" https://$MGMT_HOST/2/system/login/

# Extract SAP Data Hub TC information and place in temp directory
curl -sk -b temp/cookie.txt https://$MGMT_HOST/2/clusters/${CLUSTER}| tee temp/${CLUSTER}.json| jq '.name,.uuid,.state'

# Download SAP Data Hub TC KUBECONFIG file and place in temp directory
TC=$(jq -r '.uuid' temp/${CLUSTER}.json)
echo $TC
if [ -x "$(type -p set_kubeconfig_cluster.rb)" ]; then
  curl -sk -b temp/cookie.txt https://$MGMT_HOST/2/clusters/${TC}/env | set_kubeconfig_cluster.rb ${CLUSTER} >  temp/${CLUSTER}.KUBECONFIG
else
  curl -sk -b temp/cookie.txt https://$MGMT_HOST/2/clusters/${TC}/env >  temp/${CLUSTER}.KUBECONFIG
fi

# Test the KUBECONFIG file
KUBECONFIG=temp/${CLUSTER}.KUBECONFIG kubectl get nodes -o wide

# Print the value to set KUBECONFIG for use in environment
echo "Paste the below line into your shell environment"
echo "export KUBECONFIG=${PWD}/temp/${CLUSTER}.KUBECONFIG"

exit 0 
