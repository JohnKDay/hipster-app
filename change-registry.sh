#!/bin/sh

NEW_REGISTRY=${1:-REGISTRYSERVER}

sed -i "s/REGISTRYSERVER/${NEW_REGISTRY}/g" *.yaml kubernetes-manifests/*.yaml


