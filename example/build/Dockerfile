ARG base_image=nginxdemos/nginx-hello:plain-text
ARG nginx_version=1.16.1

FROM ubuntu:18.04 AS tracer_downloader

RUN set -x \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y bash lynx curl ca-certificates gnupg2 unzip

ARG download_key
ARG agent_key
ARG nginx_version
# Most images are Alpine Linux (musl libc) based. Use "glibc" otherwise.
ARG libc_flavor=musl

ENV INSTANA_DOWNLOAD_KEY=${download_key}
ENV NGINX_FLAVOR=nginx
ENV NGINX_VERSION=${nginx_version}
ENV LIBC_FLAVOR=${libc_flavor}
ENV SUFFIX=''
ENV ARTI_PATH='https://artifact-public.instana.io/artifactory/shared/com/instana/nginx_tracing/'

# Download extension from Artifactory
RUN echo "Using download key ${INSTANA_DOWNLOAD_KEY}; NGINX version: ${NGINX_FLAVOR}/${NGINX_VERSION}; LIBC flavor: ${LIBC_FLAVOR}; suffix: \"${SUFFIX}\""; \
    NGINX_VERSION=$(echo ${NGINX_VERSION} | egrep -o '^[0-9]+\.[0-9]+\.[0-9]+'); \
    sensor_version=$(lynx -auth _:${INSTANA_DOWNLOAD_KEY} -dump -listonly ${ARTI_PATH} | grep -o 'https:.*/[0-9]\+\.[0-9]\+\.[0-9]\+/' | rev | cut -d '/' -f 2 | rev | sort -V | tail -n1); \
    echo "Using sensor version ${sensor_version} for ${NGINX_FLAVOR}/${NGINX_VERSION}."; \
    tmp_file="tmp.zip"; tmp_dir="/tmp/nginx_tracing"; mkdir -p "${tmp_dir}" && cd "${tmp_dir}" && \
    curl --user _:${INSTANA_DOWNLOAD_KEY} --silent --output ${tmp_file} ${ARTI_PATH}${sensor_version}/linux-amd64-${LIBC_FLAVOR}-${NGINX_FLAVOR}-${NGINX_VERSION}${SUFFIX}.zip --fail && \
    echo "Download completed" && \
    unzip ${tmp_file} && \
    mkdir -p /opt/instana/nginx && \
    mv ${LIBC_FLAVOR}-libinstana_sensor.so /opt/instana/nginx/libinstana_sensor.so && \
    mv ${LIBC_FLAVOR}-${NGINX_FLAVOR}-${NGINX_VERSION}-ngx_http_ot_module${SUFFIX}.so /opt/instana/nginx/ngx_http_instana_module.so;


# Final image
FROM ${base_image} AS base

ARG nginx_version
ARG tracing_dependencies_dir='/instana/nginx'
ARG nginx_config_dir='/etc/nginx/'

ENV NGINX_VERSION=${nginx_version}
ENV TRACING_DEPENDENCIES_DIR=${tracing_dependencies_dir}
ENV NGINX_CONFIG_DIR=${nginx_config_dir}

# Verify that the NGINX version is correct
RUN nginx -v 2>&1 | grep -qF "${NGINX_VERSION}"

ADD instana-nginx.conf ${NGINX_CONFIG_DIR}/nginx.conf
ADD instana-hello.conf ${NGINX_CONFIG_DIR}/conf.d/hello.conf
ADD instana-config.json ${TRACING_DEPENDENCIES_DIR}/instana-config.json
COPY --from=tracer_downloader /opt/instana/nginx/libinstana_sensor.so ${TRACING_DEPENDENCIES_DIR}/libinstana_sensor.so
COPY --from=tracer_downloader /opt/instana/nginx/ngx_http_instana_module.so ${TRACING_DEPENDENCIES_DIR}/ngx_http_instana_module.so
