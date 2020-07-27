# Instana tracing for Ingress NGINX

We build an Instana init container which provides the NGINX tracing binaries, an empty tracer configuration, and a patched NGINX configuration template.

The Instana tracing files are registered in the NGINX configuration template and the environment variables used to configure the Instana tracer are whitelisted.

## Build Init Container

Build the Instana init container in [`./instana/init-container`](./instana/init-container):

```sh
INGRESS_NGINX_PATH=/tmp/ingress-nginx
[ -d "${INGRESS_NGINX_PATH}" ] || git clone https://github.com/kubernetes/ingress-nginx "${INGRESS_NGINX_PATH}"; \
(cd "${INGRESS_NGINX_PATH}"; git checkout ingress-nginx-2.11.1); \
./init-container/get_nginx_template.sh "${INGRESS_NGINX_PATH}"; \
./init-container/patch_nginx_template.sh;
docker build -t instana-nginx-init ./init-container \
    --build-arg nginx_version='1.19.1' \
    --build-arg download_key=<DOWNLOAD_KEY>
```

Tag and upload to your Docker registry accessible by Kubernetes:

```sh
export DOCKER_REGISTRY=<DOCKER_REGISTRY>; \
docker tag instana-nginx-init:latest ${DOCKER_REGISTRY}:5000/instana-nginx-init:2.11.1; \
docker push ${DOCKER_REGISTRY}:5000/instana-nginx-init:2.11.1
```

## Deploy Ingress NGINX with Instana settings

### Helm 2

<TODO>

### Helm 3

```sh
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx --values=helm/ingress-nginx-instana.yaml
```

### Additional settings

Additional settings can be specified via the following environment variables:

<TODO>