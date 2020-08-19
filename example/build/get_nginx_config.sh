#!/bin/bash

set -e

# Run from everywhere
CWD=`dirname $0`
cd "$CWD"

if [ -z ${BASE_IMAGE} ]; then
  BASE_IMAGE=`cat Dockerfile | grep -o "base_image=.*" | cut -d '=' -f2`
fi

docker run -t ${BASE_IMAGE} sh -c "cat /etc/nginx/nginx.conf | tr -d '\r'" > nginx.conf
docker run -t ${BASE_IMAGE} sh -c "cat /etc/nginx/conf.d/hello.conf | tr -d '\r'" > hello.conf
