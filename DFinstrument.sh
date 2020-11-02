#!/usr/bin/env bash

set -vx
set -euf -o pipefail

appname=DFdemo
#apppath=~/git/microservices-demo
apppath=${PWD}
#registry_src=${1:-localhost:32000}
#registry_dst=${2:-localhost:32000}
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
