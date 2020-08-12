#!/usr/bin/env bash

set -e

CWD="$(dirname $0)"
cd "${CWD}"

force_success() {
    echo -n ""
}

set_target_name() {
    TARGET_NAME="${DOCKER_REGISTRY_INTERNAL}/instana/release/ingress-nginx-init"
}

clean_up() {
    set +e
    for img_tag in ${IMAGE_TAGS}; do
        set_target_name
        docker rmi "${IMAGE}:${img_tag}" 2>/dev/null
        docker rmi "${TARGET_NAME}:${RELEASE}-${img_tag}" 2>/dev/null
        docker rmi "${TARGET_NAME}:latest-${img_tag}" 2>/dev/null
    done
    set -e
}
trap clean_up EXIT

IMAGE="instana-nginx-init"
DOCKER_REGISTRY_INTERNAL="containers.instana.io"

RELEASE="$1"
RELEASE_CHECK="$(grep "[0-9]\+\.[0-9]\+\.[0-9]\+" <<< ${RELEASE} || force_success)"
IMAGE_TAGS=$(docker image ls --format '{{.Tag}}' ${IMAGE})

if [[ -z "${RELEASE}" || -z "${RELEASE_CHECK}" ]]; then
    echo "No valid release number provided." >&2
    exit 1
fi

if [ -z "${IMAGE_TAGS}" ]; then
    echo "No container images found to be uploaded." >&2
    exit 1
fi

set -x
for img_tag in ${IMAGE_TAGS}; do
    set_target_name
    docker tag ${IMAGE}:${img_tag} ${TARGET_NAME}:${RELEASE}-${img_tag}
    docker tag ${IMAGE}:${img_tag} ${TARGET_NAME}:latest-${img_tag}
    docker push ${TARGET_NAME}:${RELEASE}-${img_tag}
    docker push ${TARGET_NAME}:latest-${img_tag}
done
set +x

# vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab :
