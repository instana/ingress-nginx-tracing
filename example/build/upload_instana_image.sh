#!/usr/bin/env bash

set -e

CWD="$(dirname $0)"
cd "${CWD}"

IMAGE="instana-nginx-hello"
DOCKER_REGISTRY_INTERNAL="containers.instana.io"
TARGET_NAME="${DOCKER_REGISTRY_INTERNAL}/instana/release/agent/instana-nginx-hello"
TAG="latest"

force_success() {
    echo -n ""
}

clean_up() {
    set +e
    docker rmi "${IMAGE}:${TAG}" 2>/dev/null
    docker rmi "${TARGET_NAME}:${TAG}" 2>/dev/null
    set -e
}
trap clean_up EXIT

set -x
    docker tag ${IMAGE}:${TAG} ${TARGET_NAME}:${TAG}
    docker push ${TARGET_NAME}:${TAG}
set +x

# vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab :
