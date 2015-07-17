# Pantheon Switchboard
![The Pantheon Switchboard](https://www.eric.pe/sites/default/files/field/image/PantheonSwitchboard.png)
This repository contains a Dockerfile of [MySQL proxy][] that will dynamically
proxy MySQL queries made against it to a pre-configured [Pantheon][] site and
environment at runtime.

This allows you to configure and deploy a static endpoint with your choice of
credentials that always points to your Pantheon site's database, despite
[periodic connection detail changes][] that occur as a result of server
upgrades, endpoint migrations, etc.

## Installation
1. Install [Docker][].
2. Download the [automated build][] from the [Docker Hub Registry][]:
   `docker pull tableaumkt/pantheon-mysql-proxy`
3. Alternatively, you can build an image from the Dockerfile:
   `docker build -t="tableaumkt/pantheon-mysql-proxy" github.com/tableau-mkt/pantheon-mysql-proxy`

## Usage
You should be able to deploy this image directly; everything you need to change
is made configurable via environment variables, outlined below.

#### Example run command:
```bash
docker run \
  -e "PROXY_DB_UN=pantheon_proxy" \
  -e "PROXY_DB_PW=batteryhorsestaple" \
  -e "PROXY_DB_PORT=3306" \
  -e "PANTHEON_SITE=www-my-company" \
  -e "PANTHEON_ENV=test" \
  -e "PANTHEON_EMAIL=josh@getpantheon.com" \
  -e "PANTHEON_PASS=actualPantheonPasswordHere" \
  --restart=always tableaumkt/pantheon-mysql-proxy
```

These may also be configured/stored differently depending on your Docker deploy
strategy.

Once deployed, you can connect to your proxy as if it were a MySQL instance
itself: `mysql --host=your.proxy.io --port=3306 --user=pantheon_proxy -p`

#### Configurable variables

- __`PROXY_DB_UN`__
  - The username that you will give to your end-users to authenticate with the
    MySQL proxy.
- __`PROXY_DB_PW`__
  - The password you will give to your end-users to authenticate with the MySQL
    proxy.
- __`PROXY_DB_PORT`__
  - The port you will give to your end-users to connect with the MySQL proxy.
    Available so you can pack multiple instances of this image on a single host.
- __`PANTHEON_SITE`__
  - The slug of the site whose database you wish to proxy.
- __`PANTHEON_ENV`__
  - The Pantheon environment you wish to proxy (e.g. `dev`, `test`, or `live`).
- __`PANTHEON_EMAIL`__
  - A Pantheon account e-mail address with dashboard access to the site
    specified above.
- __`PANTHEON_PASS`__
  - The password associated with the Pantheon account specified above; used to
    pull MySQL connection details via Pantheon's API.

#### Queries no longer forwarding to the right database?
Simply restart or re-deploy the docker image; Pantheon MySQL connection info and
credentials are pulled and cached on start-up.

### Base docker image
- [pataquets/mysql-proxy][]

[MySQL proxy]: https://dev.mysql.com/doc/mysql-proxy/en/
[Pantheon]: https://pantheon.io
[periodic connection detail changes]: https://pantheon.io/docs/articles/local/accessing-mysql-databases/
[Docker]: https://www.docker.com/
[automated build]: https://registry.hub.docker.com/u/tableaumkt/pantheon-mysql-proxy/
[Docker Hub Registry]: https://registry.hub.docker.com/
[pataquets/mysql-proxy]: https://registry.hub.docker.com/u/pataquets/mysql-proxy/
