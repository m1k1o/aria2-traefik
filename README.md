# aria2-traefik

Aria2 with Webui in Docker behind Traefik 2.

* Aria2: https://aria2.github.io/
* Webui: https://github.com/ziahamza/webui-aria2
* Traefik 2: https://docs.traefik.io/v2.2/

At the time of creating this repository, Webui does not seem to be in active development (latest change 2 years ago) so I included build here.

# Usage

```yml
  aria2:
    build: .
    container_name: aria2
    restart: unless-stopped
    environment:
      TZ: Europe/Bratislava
      RPC_SECRET: something_random
    volumes:
      - ./downloads:/downloads
    labels:
      - "traefik.enable=true"
      - "traefik.http.services.aria2-webui-frontend.loadbalancer.server.port=8080"
      - "traefik.http.routers.aria2-webui.entrypoints=web"
      - "traefik.http.routers.aria2-webui.rule=Host(`aria2.example.com`)"
      - "traefik.http.routers.aria2-webui.service=aria2-webui-frontend"
      - "traefik.http.services.aria2-frontend.loadbalancer.server.port=6800"
      - "traefik.http.routers.aria2.entrypoints=web"
      - "traefik.http.routers.aria2.rule=Host(`aria2.example.com`) && Path(`/jsonrpc`)"
      - "traefik.http.routers.aria2.service=aria2-frontend"
```
## User settings

Set user and group, that will own downloaded files.

* PUID: 1000
* PGID: 1000

## rpc settings

Websocket secret can be adjusted. Create something random, using e.g. `openssl rand -base64 32`.

* RPC_SECRET: something_random

Keep in mind, that this **secret** will be shared with client. Additional layer of security would be needed:

```diff
    labels:
      - "traefik.enable=true"
+      # Note: all dollar signs in the hash need to be doubled for escaping.
+      # To create user:password pair, it's possible to use this command:
+      # echo $(htpasswd -nb user password) | sed -e s/\\$/\\$\\$/g
+      - "traefik.http.middlewares.aria2-auth.basicauth.users=test:$$apr1$$H6uskkkW$$IgXLP6ewTrSuBkTrqE8wj/"
      - "traefik.http.services.aria2-webui-frontend.loadbalancer.server.port=8080"
      - "traefik.http.routers.aria2-webui.entrypoints=web"
      - "traefik.http.routers.aria2-webui.rule=Host(`aria2.example.com`)"
      - "traefik.http.routers.aria2-webui.service=aria2-webui-frontend"
+      - "traefik.http.routers.aria2-webui.middlewares=aria2-auth"
      - "traefik.http.services.aria2-frontend.loadbalancer.server.port=6800"
      - "traefik.http.routers.aria2.entrypoints=web"
      - "traefik.http.routers.aria2.rule=Host(`aria2.example.com`) && Path(`/jsonrpc`)"
      - "traefik.http.routers.aria2.service=aria2-frontend"
+      - "traefik.http.routers.aria2.middlewares=aria2-auth"
```

More information [here](https://docs.traefik.io/middlewares/basicauth/).

## aria2 settings

These environment variables, with their default values, are supported:

* MAX_OVERALL_DOWNLOAD_LIMIT: 0
* MAX_OVERALL_UPLOAD_LIMIT: 32K
* MAX_CONCURRENT_DOWNLOADS: 10
* MAX_CONNECTION_PER_SERVER: 16
* SPLIT: 10

More information [here](https://aria2.github.io/manual/en/html/aria2c.html).

## More aria2 settings

If you need to add more settings, you can add custom `aria2.conf` template.

```diff
    volumes:
      - ./downloads:/downloads
+      - ./conf/aria2.conf:/conf/aria2.conf.tmpl
```
