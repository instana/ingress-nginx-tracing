#!/usr/bin/env bash

set -e

CWD="$(dirname $0)"
cd "${CWD}"

force_success() {
    echo -n ""
}

IMAGE="instana-nginx-init"
DOCKER_REGISTRY_INTERNAL="containers.instana.io"

RELEASE="$1"
RELEASE_CHECK="$(grep "[0-9]\+\.[0-9]\+\.[0-9]\+" <<< ${RELEASE} || force_success)"

if [[ -z "${RELEASE}" || -z "${RELEASE_CHECK}" ]]; then
    echo "No valid release number provided." >&2
    exit 1
fi

IMAGE_TAGS=$(docker image ls --format '{{.Tag}}' ${IMAGE})

if [ -z "${IMAGE_TAGS}" ]; then
    echo "No container images found to be uploaded." >&2
    exit 1
fi

for img_tag in ${IMAGE_TAGS}; do
    echo "docker tag ${DOCKER_REGISTRY_INTERNAL}/instana/prerelease/ingress-nginx/${img_tag}/instana-init:${RELEASE}"
done

# vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab :
