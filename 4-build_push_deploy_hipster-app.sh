#!/usr/bin/env bash 

if [ -x "$(type -p skaffold)" ]; then
  skaffold run 
else
  echo " You need to install skaffold app located at:"
  echo " https://skaffold.dev/docs/getting-started/#installing-skaffold "
fi
