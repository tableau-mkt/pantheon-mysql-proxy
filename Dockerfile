# Dockerfile for MySQL proxy + Pantheon Terminus

FROM pataquets/mysql-proxy

# Add our runtime script and the mysql-proxy lua script.
ADD run /opt/run
ADD terminus_auth.lua /opt/auth.lua
RUN chmod u+x /opt/run

# Install PHP, terminus, etc.
RUN apt-get -qq update \
  && apt-get -qqy upgrade \
  && apt-get -qqy install --no-install-recommends \
    curl \
    openssh-client \
    php5-cli \
    php5-common \
    php5-curl \
  && apt-get clean
RUN curl https://github.com/pantheon-systems/terminus/releases/download/0.13.4/terminus.phar -L -o /usr/local/bin/terminus \
  && chmod +x /usr/local/bin/terminus \
  && mkdir $HOME/terminus && mkdir $HOME/terminus/plugins \
  && curl https://github.com/tableau-mkt/terminus-replica/archive/0.1.0.tar.gz -L -o $HOME/terminus/plugins/replica.tar.gz \
  && cd $HOME/terminus/plugins && tar -zxvf replica.tar.gz

# You should customize these at run-time.
ENV PROXY_DB_UN=pantheon_proxy
ENV PROXY_DB_PW=change-me-pw-for-proxy
ENV PROXY_DB_PORT=3306
ENV PANTHEON_EMAIL=test@example.com
ENV PANTHEON_TOKEN=
ENV PANTHEON_PASS=batteryhorsestaple
ENV PANTHEON_SITE=example
ENV PANTHEON_ENV=test

# Override command/entrypoint from upstream image
ENTRYPOINT ["/opt/run"]
CMD []
