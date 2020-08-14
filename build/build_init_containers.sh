#!/usr/bin/env bash

set -e

CWD="$(dirname $0)"
cd "${CWD}"

source "scripts/ini-parsing.sh"

TMPL_PATH="rootfs/etc/nginx/template/nginx.tmpl"
BUILD_SUCCESS=0
IMAGE="instana-nginx-init"

clean_up() {
    set +e
    if [ ${BUILD_SUCCESS} -ne 1 ]; then
        for cfg in ${CFG_FUNCTIONS[*]}; do
            ${cfg}
            docker rmi "${IMAGE}:${tag}" 2>/dev/null
        done
    fi
    set -e
}
trap clean_up EXIT

get_and_patch_nginx_template() {
    rm -f init-container/nginx.tmpl
    local tmpl_uri=$(sed 's/github.com/raw.githubusercontent.com/g' <<< ${repo})
    tmpl_uri="${tmpl_uri}/${tag}/${TMPL_PATH}"
    wget -O init-container/nginx.tmpl "${tmpl_uri}"
    init-container/patch_nginx_template.sh
}

get_nginx_flavor_and_version() {
    if [ -z "${nginx_version}" ]; then
        nginx_version=$(docker run -t ${docker_image} \
          nginx -v | cut -d ' ' -f3 | tr -d [:cntrl:])
        echo "new nginx_version: ${nginx_version}"; echo
    fi
    nginx_flavor=$(cut -d '/' -f1 <<< ${nginx_version})
    nginx_version=$(cut -d '/' -f2 <<< ${nginx_version})
}

dump_config() {
    echo "Using config ${tag}:"
    echo "repo: ${repo}"
    echo "tag: ${tag}"
    echo "docker_image: ${docker_image}"
    echo "libc_flavor: ${libc_flavor}"
    echo "nginx_version: ${nginx_version}"
    echo
}

init_and_load_cfg() {
    repo=""
    tag=""
    docker_image=""
    libc_flavor="musl"
    nginx_version=""
    ${cfg}
}

build_init_container_image() {
    nginx_flavor=""
    init_and_load_cfg
    dump_config
    get_nginx_flavor_and_version
    get_and_patch_nginx_template

    # Build the init container image
    docker build -t ${IMAGE}:${tag} ./init-container \
        --build-arg libc_flavor="${libc_flavor}" \
        --build-arg nginx_flavor="${nginx_flavor}" \
        --build-arg nginx_version="${nginx_version}" \
        --build-arg download_key="${INSTANA_DOWNLOAD_KEY}" \
        --build-arg tag="${tag}"
}

main() {
    _parse_cfg init-container-config

    # Only build from specified config entry
    local selected_cfg="$1"
    if [ -n "${selected_cfg}" ]; then
        CFG_FUNCTIONS=("cfg.section.${selected_cfg}")
    fi

    for cfg in ${CFG_FUNCTIONS[*]}; do
        build_init_container_image
    done
    BUILD_SUCCESS=1
}

main "$@"

# vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab :
