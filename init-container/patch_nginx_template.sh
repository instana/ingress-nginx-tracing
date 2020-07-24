#!/bin/bash

#set -x

CWD="`dirname $0`"
cd "$CWD"

INPUT="./nginx.tmpl"
OUTPUT="./instana-nginx.tmpl"

OLD_MODLINE='load_module /etc/nginx/modules/ngx_http_opentracing_module.so;'
NEW_MODLINE='load_module /instana/nginx/ngx_http_instana_module.so;'

TRACER_LOAD='    {{ if (shouldLoadOpentracingModule $cfg $servers) }}\n    opentracing_load_tracer /instana/nginx/libinstana_sensor.so /instana/nginx/instana-config.json;\n    {{ end }}'

CFG="env INSTANA_AGENT_HOST;\n"
CFG="${CFG}env INSTANA_AGENT_PORT;\n"
CFG="${CFG}env INSTANA_MAX_BUFFERED_SPANS;\n"
CFG="${CFG}env INSTANA_DEV;\n"
CFG="${CFG}env INSTANA_SERVICE_NAME;"

sed -e "s@daemon off;@daemon off;\n${CFG}@g" \
  -e "s@${OLD_MODLINE}@${NEW_MODLINE}@g" \
  -e "s@http {@http {\n${TRACER_LOAD}@g" \
  ${INPUT} > ${OUTPUT}

grep -q INSTANA ${OUTPUT}
RC1=$?
grep -q instana_module ${OUTPUT}
RC2=$?
grep -q instana_sensor ${OUTPUT}
RC3=$?

if [[ $RC1 -eq 1 || $RC2 -eq 1 || $RC3 -eq 1 ]]; then
  echo "ERROR: Adding Instana config to ${INPUT} as ${OUTPUT} failed." >&2
  exit 1
fi
