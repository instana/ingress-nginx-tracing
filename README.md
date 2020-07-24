# Instana tracing for Ingress NGINX

We build an Instana init container which provides the NGINX tracing binaries,
an empty tracer configuration, and a patched NGINX configuration template.

The Instana tracing files are registered in the NGINX configuration template
and the environment variables used to configure the Instana tracer are whitelisted.

## Build

Build the Instana init container in [`./instana/init-container`](./instana/init-container):

```sh
INGRESS_NGINX_PATH=/tmp/ingress-nginx
git clone https://github.com/kubernetes/ingress-nginx "${INGRESS_NGINX_PATH}"; \
pushd "${INGRESS_NGINX_PATH}"; \
git checkout ingress-nginx-2.11.1; \
popd; \
./init-container/get_nginx_template.sh "${INGRESS_NGINX_PATH}"; \
./init-container/patch_nginx_template.sh; \
docker build -t instana-nginx-init ./init-container \
    --build-arg nginx_version='1.19.1' \
    --build-arg download_key=<DOWNLOAD_KEY>
```

Tag and upload to your Docker registry accessible by Kubernetes:

```sh
export DOCKER_REGISTRY=<DOCKER_REGISTRY>; \
docker tag instana-nginx-init:latest ${DOCKER_REGISTRY}:5000/instana-nginx-init:latest; \
docker push ${DOCKER_REGISTRY}:5000/instana-nginx-init:latest
```

## Deploy Ingress NGINX with Instana settings

TODO: Set env vars to configure the tracer.

### Helm chart

```yaml
# ingress-nginx-instana.yaml
controller:

    config: {enable-opentracing: "true"}

    extraVolumes:
      - name: instana-tracing-dependencies
        emptyDir: {}
      - name: instana-nginx-template
        emptyDir: {}

    extraVolumeMounts:
      - name: instana-tracing-dependencies
        mountPath: /instana/nginx
      - name: instana-nginx-template
        mountPath: /etc/nginx/template

    extraInitContainers:
      - name: instana-tracing-dependencies
        image: <DOCKER_REGISTRY>:5000/instana-nginx-init:latest
        volumeMounts:
          - name: instana-tracing-dependencies
            mountPath: /instana/nginx
          - name: instana-nginx-template
            mountPath: /etc/nginx/template
```

Patch the helm chart with your Docker registry name/IP:

```sh
sed -i s@'<DOCKER_REGISTRY>'@${DOCKER_REGISTRY}@g helm/ingress-nginx-instana.yaml
```

Install your chart with helm:

```sh
helm install --name my-release --values helm/ingress-nginx-instana.yaml ${INGRESS_NGINX_PATH}/charts/ingress-nginx/
```
