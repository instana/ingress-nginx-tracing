# Instana tracing for Ingress NGINX

## Build

Build the Instana init container in [`./instana/init-container`](./instana/init-container):

```sh
docker build -t instana-nginx-init ./init-container \
    --build-arg nginx_version='1.19.0' \
    --build-arg download_key=<DOWNLOAD_KEY>
```

## Deploy Ingress NGINX with Instana settings

### NGINX Configuration

```nginx
load_module /instana/nginx/ngx_http_instana_module.so;

events {}

error_log /dev/stdout info;

http {
  error_log /dev/stdout info;

  # The following line loads the Instana libsinstana_sensor library, that
  # gets the tracing data from ngx_http_opentracing_module.so and converts
  # them to Instana AutoTrace tracing data.
  # The content of instana-config.json is discussed below.
  opentracing_load_tracer /instana/nginx/libinstana_sensor.so /etc/instana-config.json;

  # Propagates the active span context for upstream requests.
  # Without this configuration, the Instana trace will end at
  # NGINX, and the systems downstream (those to which NGINX
  # routes the requests) monitored by Instana will generate
  # new, unrelated traces
  opentracing_propagate_context;

  # If you use upstreams, Instana will automatically use them as endpoints,
  # and it is really cool :-)
  upstream backend {
    server server-app:8080;
  }

  server {
    error_log /dev/stdout info;
    listen 8080;
    server_name localhost;

    location /static {
      root /www/html;
    }

    location ^~ /api {
      proxy_pass http://backend;
    }

    location ^~ /other_api {
      set_proxy_header X-AWESOME-HEADER "truly_is_awesome";

      # Using the `set_proxy_header` directive voids for this
      # location the `opentracing_propagate_context` defined
      # at the `http` level, so here we need to set it again
      opentracing_propagate_context;

      proxy_pass http://backend;
    }
  }
}
```

### Helm chart

```yaml
# ingress-nginx-instana.yaml
controller:

    extraVolumes:
      - name: instana-tracing-dependencies
        emptyDir: {}
      - name: nginx-configuration

    extraVolumeMounts:
      - name: instana-tracing-dependencies
        mountPath: /instana/nginx
    #   - name: nginx-configuration # Be sure to mount your nginx.conf file with the Instana configurations!
    #     mountPath: /etc/nginx/nginx.conf

    extraInitContainers:
      - name: instana-tracing-dependencies
        image: instana-nginx-init
        volumeMounts:
          - name: instana-tracing-dependenciesREADME.md
            mountPath: /instana/nginx
```

Install your chart with helm:

```sh
helm install --name my-release --values ingress-nginx-instana.yaml ingress-nginx/ingress-nginx
```
