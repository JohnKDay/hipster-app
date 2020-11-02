#!/usr/bin/env bash

set -vx
set -euf -o pipefail

appname=Hipster-app
apppath=${PWD}
#registry_src=${1:-localhost:32000} # used when deploying using microk8s
#registry_dst=${2:-localhost:32000} # used when deploying using microk8s
registry_src=${1:-johnkday} # Set to use docker.io/johnkday regsitry
registry_dst=${2:-johnkday} # Set to use docker.io/johnkday registry

while read name bintype
do
    echo --- $name === $bintype
    btag=nodf-latest
    atag=df-latest

    docker build -t ${registry_dst}/${name}:${atag} \
        -f ${apppath}/Dockerfile.${bintype}.df \
        --build-arg "APP_IMAGE=${registry_src}/${name}:${btag}" \
        --build-arg "DF_APP_NAME=${appname}" --build-arg "DF_COMPONENT=${name}" \
        ${apppath}/src/${name}/

    docker push ${registry_dst}/${name}:${atag}
done < container.type

set +vx

exit
