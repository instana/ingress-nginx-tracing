#!/usr/bin/env bash

set -e

NGINX_FLAVOR="$1"
NGINX_VERSION="$2"

if [[ -z "${NGINX_FLAVOR}" || -z "${NGINX_VERSION}" ]]; then
  exit 0
fi

if [ "${NGINX_FLAVOR}" != "openresty" ]; then
  exit 0
fi

case "${NGINX_VERSION}" in
1.19.*|1.17.*|1.15.8.3)
  echo -n "_compat"
  exit 0
  ;;
esac

# vim: set tabstop=2 softtabstop=2 shiftwidth=2 expandtab :
