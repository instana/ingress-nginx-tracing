# Instana Tracing for Kubernetes NGINX Ingress

Instana provides YAML files to easily deploy [Kubernetes NGINX Ingress](https://github.com/kubernetes/ingress-nginx) with Instana tracing and metrics collection.

## Implementation Details

An Instana init container is built which provides the NGINX tracing binaries, an empty tracer configuration, and a patched NGINX configuration template.
The Instana tracing files are registered in the NGINX configuration template and the environment variables used to configure the Instana tracer are whitelisted.
This differs a bit from the [official Kubernetes NGINX Ingress OpenTracing documentation](https://kubernetes.github.io/ingress-nginx/user-guide/third-party-addons/opentracing/).

## Disclaimer

*Instana tracing for Kubernetes NGINX Ingress is currently a technology preview.*

We reserve ourselves the right to make it better and easier before releasing the functionality for General Availability.

## Init Container Images

| Release | Sensor Version | Changes |
| ------- | -------------- | ------- |
| latest  | 1.1.0 | initial release  |
| 1.184.0 | 1.1.0 | initial release  |

See [Sensor release history](https://github.com/instana/nginx-tracing#release-history) for details.

Image: `containers.instana.io/instana/release/agent/ingress-nginx-init`

Tag names are composed of `<release>-<ingress_nginx_git_tag>`.

Tags:
* `latest-ingress-nginx-2.11.1`, `latest-nginx-0.30.0`, `latest-nginx-0.25.1-rancher1`
* `1.184.0-ingress-nginx-2.11.1`, `1.184.0-nginx-0.30.0`, `1.184.0-nginx-0.25.1-rancher1`

We build the images automatically from the [init container configuration](build/init-container-config). New ingress-nginx versions can be added there.

## Init Container Pull Secret

The pull secret name `instana-registry-key` is assumed in namespace `ingress-nginx`. Please edit the respective yaml files if this does not apply to your setup.

Basics: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/

Using our template [deploy/instana-secret.yaml](deploy/instana-secret.yaml):
```sh
docker login -u _ -p <agent_key> containers.instana.io
sed -i "s@<YOUR_BASE64_ENCODED_FILE_CONTENTS_HERE>@$(cat ~/.docker/config.json | base64 --wrap=0)@g" deploy/instana-secret.yaml
kubectl apply -f deploy/instana-secret.yaml
```

## Deploy Kubernetes NGINX Ingress with Instana Settings

Helm charts are provided since Kubernetes NGINX Ingress version 0.31. Version `ingress-nginx-2.11.1` is assumed as an example.
We provide a custom values file [helm/ingress-nginx-instana.yaml](helm/ingress-nginx-instana.yaml). Adapt it to your needs.

### Helm 3

```sh
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx --values=helm/ingress-nginx-instana.yaml --namespace=ingress-nginx --version=2.11.1
```

### Helm 2

```sh
helm init
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install --name=ingress-nginx ingress-nginx/ingress-nginx --values=helm/ingress-nginx-instana.yaml --namespace=ingress-nginx --version=2.11.1
```

### Without helm

We provide patched versions of the deployment YAML files which provide the same modifications like for the helm chart.

#### Before 0.31

```sh
kubectl apply -f deploy/${ingress_nginx_git_tag}/static/mandatory.yaml
```

Then select one of these depending on your cloud/loadbalancer setup:
```sh
kubectl apply -f deploy/${ingress_nginx_git_tag}/static/provider/cloud-generic.yaml
```
```sh
kubectl apply -f deploy/${ingress_nginx_git_tag}/static/provider/aws/service-nlb.yaml
```
```sh
kubectl apply -f deploy/${ingress_nginx_git_tag}/static/provider/aws/service-l4.yaml
kubectl apply -f deploy/${ingress_nginx_git_tag}/static/provider/aws/patch-configmap-l4.yaml
```
```sh
kubectl apply -f deploy/${ingress_nginx_git_tag}/static/provider/aws/service-l7.yaml
kubectl apply -f deploy/${ingress_nginx_git_tag}/static/provider/aws/patch-configmap-l7.yaml
```
```sh
kubectl apply -f deploy/${ingress_nginx_git_tag}/static/provider/baremetal/service-nodeport.yaml
```

#### 0.31 and later

Select one of these depending on your cloud/loadbalancer setup:
```sh
kubectl apply -f deploy/${ingress_nginx_git_tag}/static/provider/cloud/deploy.yaml
```
```sh
kubectl apply -f deploy/${ingress_nginx_git_tag}/static/provider/aws/deploy.yaml
```
```sh
kubectl apply -f deploy/${ingress_nginx_git_tag}/static/provider/aws/deploy-tls-termination.yaml
```
```sh
kubectl apply -f deploy/${ingress_nginx_git_tag}/static/provider/do/deploy.yaml
```
```sh
kubectl apply -f deploy/${ingress_nginx_git_tag}/static/provider/kind/deploy.yaml
```
```sh
kubectl apply -f deploy/${ingress_nginx_git_tag}/static/provider/baremetal/deploy.yaml
```

### Additional settings

Additional settings can be specified via the following environment variables:

* `INSTANA_SERVICE_NAME`
* `INSTANA_AGENT_HOST`
* `INSTANA_AGENT_PORT`
* `INSTANA_MAX_BUFFERED_SPANS`
* `INSTANA_DEV`