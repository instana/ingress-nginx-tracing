#!/bin/bash

#set -x
set -e

CWD="`dirname $0`"
cd "$CWD"

URL="https://github.com/kubernetes/ingress-nginx"
FILE="nginx.tmpl"
FILE_PATH="rootfs/etc/nginx/template/${FILE}"

PATH_TO_REPO=""
if [ $# -gt 0 ]; then
  PATH_TO_REPO="$1"
else
  echo "Please provide the local path to the cloned repository '${URL}' as an argument." >&2
  exit 1
fi

cp "${PATH_TO_REPO}/${FILE_PATH}" .
chmod -x "${FILE}"
