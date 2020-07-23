FROM ubuntu:18.04 AS tracing_dependencies

RUN set -x \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y lynx curl ca-certificates gnupg2 unzip

ARG download_key
ARG agent_key
ARG nginx_version
# For Alpine-based images, change the following to 'musl'
ARG libc_version=glibc
ARG tracing_dependencies_dir='/instana/nginx'

ENV INSTANA_DOWNLOAD_KEY=${download_key}
ENV NGINX_VERSION=${nginx_version}
ENV LIBC_VERSION=${libc_version}
ENV ARTI_PATH='https://artifact-public.instana.io/artifactory/shared/com/instana/nginx_tracing/'
ENV TRACING_DEPENDENCIES_DIR=${tracing_dependencies_dir}

# Download extension from Artifactory
RUN echo "Using download key ${INSTANA_DOWNLOAD_KEY}; NGINX version: ${NGINX_VERSION}; LIBC version: ${LIBC_VERSION}"; \ 
    sensor_version=$(lynx -auth _:${INSTANA_DOWNLOAD_KEY} -dump -listonly ${ARTI_PATH} | grep -o 'https:.*/[0-9]\+\.[0-9]\+\.[0-9]\+/' | rev | cut -d '/' -f 2 | rev | sort -V | tail -n1); \
    echo "Using sensor version ${sensor_version} for NGINX ${NGINX_VERSION}."; \
    tmp_file="tmp.zip"; tmp_dir="/tmp/nginx_tracing"; mkdir -p "${tmp_dir}" && cd "${tmp_dir}" && \
    curl --user _:${INSTANA_DOWNLOAD_KEY} --silent --output ${tmp_file} ${ARTI_PATH}${sensor_version}/linux-amd64-${LIBC_VERSION}-nginx-${NGINX_VERSION}.zip --fail && \
    echo "Download completed" && \
    unzip ${tmp_file} && \
    mkdir -p /opt/instana/nginx && \
    mv ${LIBC_VERSION}-libinstana_sensor.so /opt/instana/nginx/libinstana_sensor.so && \
    mv ${LIBC_VERSION}-nginx-${NGINX_VERSION}-ngx_http_ot_module.so /opt/instana/nginx/ngx_http_instana_module.so;

CMD mv /opt/instana/nginx/libinstana_sensor.so ${TRACING_DEPENDENCIES_DIR}/libinstana_sensor.so && \
    mv /opt/instana/nginx/ngx_http_instana_module.so ${TRACING_DEPENDENCIES_DIR}/ngx_http_instana_module.so