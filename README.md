# Instana tracing for Ingress NGINX

We build an Instana init container which provides the NGINX tracing binaries, an empty tracer configuration, and a patched NGINX configuration template.

The Instana tracing files are registered in the NGINX configuration template and the environment variables used to configure the Instana tracer are whitelisted.

## Init Container Images

| Release | Sensor Version | Changes |
| ------- | -------------- | ------- |
| latest  | 1.1.0 | initial release  |
| 1.184.0 | 1.1.0 | initial release  |

See [Sensor release history](https://github.com/instana/nginx-tracing#release-history) for details.

Image: `containers.instana.io/instana/release/agent/ingress-nginx-init`

Tag names are composed of `<release>-<ingress-nginx-git-tag>`.

Tags:
* `latest-ingress-nginx-2.11.1`, `latest-nginx-0.30.0`, `latest-nginx-0.25.1-rancher1`
* `1.184.0-ingress-nginx-2.11.1`, `1.184.0-nginx-0.30.0`, `1.184.0-nginx-0.25.1-rancher1`

We build the images automatically from the [init container configuration](build/init-container-config). New ingress-nginx versions can be added there.

## Init Container Pull Secret

The pull secret name `instana-registry-key` is assumed. Please edit the respective yaml files if this does not apply to your setup.

Basics: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/

Using our template [deploy/instana-secret.yaml](deploy/instana-secret.yaml):
```sh
docker login -u _ -p <agent_key> containers.instana.io
sed -i "s@<YOUR_BASE64_ENCODED_FILE_CONTENTS_HERE>@$(cat ~/.docker/config.json | base64 --wrap=0)@g" deploy/instana-secret.yaml
kubectl apply -f deploy/instana-secret.yaml
```

## Deploy Ingress NGINX with Instana settings

Helm charts are provided since ingress-nginx version 0.31. Version `ingress-nginx-2.11.1` is assumed as an example.
We provide a custom values file [helm/ingress-nginx-instana.yaml](helm/ingress-nginx-instana.yaml). Adapt it to your needs.

### Helm 2

```sh
helm init
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install --name=ingress-nginx ingress-nginx/ingress-nginx --values=helm/ingress-nginx-instana.yaml --version=2.11.1
```

### Helm 3

```sh
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx --values=helm/ingress-nginx-instana.yaml --version=2.11.1
```

### Without helm

<TODO>

### Additional settings

Additional settings can be specified via the following environment variables:

* `INSTANA_SERVICE_NAME`
* `INSTANA_AGENT_HOST`
* `INSTANA_AGENT_PORT`
* `INSTANA_MAX_BUFFERED_SPANS`
* `INSTANA_DEV`