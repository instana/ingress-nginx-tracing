#!/usr/bin/env bash

set -e

CWD="$(dirname $0)"
cd "${CWD}"

BUILD_SUCCESS=0
IMAGE="instana-nginx-hello"
TAG="latest"
DOCKERFILE="./Dockerfile"

clean_up() {
    set +e
    if [ ${BUILD_SUCCESS} -ne 1 ]; then
        docker rmi "${IMAGE}:${TAG}" 2>/dev/null
    fi
    set -e
}
trap clean_up EXIT

get_nginx_version() {
    local docker_image=$(grep -o "ARG base_image=.*" "${DOCKERFILE}" | cut -d '=' -f2)
    if [ -z "${nginx_version}" ]; then
        nginx_version=$(docker run -t ${docker_image} \
          nginx -v | cut -d ' ' -f3 | tr -d [:cntrl:])
        echo "nginx_version: ${nginx_version}"; echo
    fi
    nginx_version=$(cut -d '/' -f2 <<< ${nginx_version})
}

build_instana_image() {
    get_nginx_version

    # Build the init container image
    docker build -t ${IMAGE}:${TAG} . \
        --build-arg nginx_version="${nginx_version}" \
        --build-arg download_key="${INSTANA_DOWNLOAD_KEY}"
}

main() {
    build_instana_image
    BUILD_SUCCESS=1
}

main "$@"

# vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab :
