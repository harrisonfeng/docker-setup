# Deploy Secure Docker Registry

This is a guide for how to deploy a secure docker registry authenticating proxy with nginx.

## Prerequisites

1. Prepare directories

```bash
mkdir -p $HOME/docker/auth
```

2. Generate your own self-signed certificate

```bash
mkdir -p $HOME/docker/auth && openssl req -newkey rsa:4096 -nodes -sha256 -keyout $HOME/docker/auth/registry.key -x509 -days 1825 -out $HOME/docker/auth/registry.crt
```

2. Be sure to use your real domain name as a CN.
3. Instruct docker daemon to trust that certificate.

    This is done by copying the `registry.crt` file to `/etc/docker/certs.d/registrydomain.com/registry.crt`

4. Restart docker daemon

```bash
systemctl restart docker
```

## Prepare htpasswd file

```bash
htpasswd -b $HOME/docker/auth/htpasswd $USER $PASSWORD
# If you don't have htpasswd in you system, please install use
# yum install -y httpd-tools
```
## Authenticating proxy with nginx

1. Create the main nginx configuration you will use under $HOME/docker/auth

```
events {
    worker_connections  1024;
}

http {

  upstream docker-registry {
    server registrydomain.com:5000;
  }

  ## Set a variable to help us decide if we need to add the
  ## 'Docker-Distribution-Api-Version' header.
  ## The registry always sets this header.
  ## In the case of nginx performing auth, the header will be unset
  ## since nginx is auth-ing before proxying.
  map $upstream_http_docker_distribution_api_version $docker_distribution_api_version {
    'registry/2.0' '';
    default registry/2.0;
  }

  server {
    listen 443 ssl;
    server_name registrydomain.com;

    # SSL
    ssl_certificate /etc/nginx/conf.d/dudocker.crt;
    ssl_certificate_key /etc/nginx/conf.d/dudocker.key;

    # Recommendations from https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html
    ssl_protocols TLSv1.1 TLSv1.2;
    ssl_ciphers 'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH';
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;

    # disable any limits to avoid HTTP 413 for large image uploads
    client_max_body_size 0;

    # required to avoid HTTP 411: see Issue #1486 (https://github.com/docker/docker/issues/1486)
    chunked_transfer_encoding on;

    location /v2/ {
      # Do not allow connections from docker 1.5 and earlier
      # docker pre-1.6.0 did not properly set the user agent on ping, catch "Go *" user agents
      if ($http_user_agent ~ "^(docker\/1\.(3|4|5(?!\.[0-9]-dev))|Go ).*\$" ) {
        return 404;
      }

      # To add basic authentication to v2 use auth_basic setting.
      auth_basic "Registry realm";
      auth_basic_user_file /etc/nginx/conf.d/htpasswd;

      ## If $docker_distribution_api_version is empty, the header will not be added.
      ## See the map directive above where this variable is defined.
      add_header 'Docker-Distribution-Api-Version' $docker_distribution_api_version always;

      proxy_pass                          http://docker-registry;
      proxy_set_header  Host              $http_host;   # required for docker client's sake
      proxy_set_header  X-Real-IP         $remote_addr; # pass on real client's IP
      proxy_set_header  X-Forwarded-For   $proxy_add_x_forwarded_for;
      proxy_set_header  X-Forwarded-Proto $scheme;
      proxy_read_timeout                  900;
    }
  }
}
```

>**NOTE**:  Please use your own domain name to replace registrydomain.com in nginx.conf


## Use docker compose to run your registry

1. Install docker compose 

```bash
 pip install docker-compose
```

2. Create docker compose config file registry.yml under $HOME/docker/

```
nginx:
  image: "nginx:1.9"
  ports:
    - 443:443
  links:
    - registry:registry
  volumes:
    - /home/docker/auth:/etc/nginx/conf.d
    - /home/docker/auth/nginx.conf:/etc/nginx/nginx.conf:ro

registry:
  image: registry:2
  ports:
    - 5000:5000
  volumes:
    - /home/docker/registry/data:/var/lib/registry
```

>**NOTE**:  Please use your own path in registry.yml

3. Run registry with docker compose

```bash 
docker-compose -f $HOME/docker/registry.yml up -d
```
