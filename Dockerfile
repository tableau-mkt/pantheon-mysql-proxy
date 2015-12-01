# Dockerfile for MySQL proxy + Pantheon Terminus

FROM pataquets/mysql-proxy

# Add our runtime script and the mysql-proxy lua script.
ADD run /opt/run
ADD terminus_auth.lua /opt/auth.lua
RUN chmod u+x /opt/run

# Install PHP, drush, terminus, etc.
RUN apt-get -qq update \
  && apt-get -qqy upgrade \
  && apt-get -qqy install --no-install-recommends \
    curl \
    openssh-client \
    php5-cli \
    php5-common \
    php5-curl \
  && apt-get clean
RUN curl https://github.com/drush-ops/drush/archive/6.6.0.tar.gz -L -o /tmp/drush.tar.gz \
  && curl https://github.com/pantheon-systems/terminus/archive/master.tar.gz -L -o /tmp/terminus.tar.gz \
  && curl http://pkgs.fedoraproject.org/repo/pkgs/php-pear-Console-Table/Console_Table-1.1.3.tgz/34b5f34db1ab0c4daedf2862958af257/Console_Table-1.1.3.tgz -L -o /tmp/Console_Table-1.1.3.tgz
RUN mkdir $HOME/.drush \
  && tar -zxvf /tmp/drush.tar.gz -C $HOME \
  && tar -zxvf /tmp/terminus.tar.gz -C $HOME/.drush \
  && tar -zxvf /tmp/Console_Table-1.1.3.tgz -C $HOME/drush-6.6.0/lib \
  && ln -s $HOME/drush-6.6.0/drush /usr/local/bin/drush \
  && mkdir $HOME/.ssh \
  && echo "StrictHostKeyChecking no" > $HOME/.ssh/config

# You should customize these at run-time.
ENV PROXY_DB_UN=pantheon_proxy
ENV PROXY_DB_PW=change-me-pw-for-proxy
ENV PROXY_DB_PORT=3306
ENV PANTHEON_EMAIL=test@example.com
ENV PANTHEON_PASS=batteryhorsestaple
ENV PANTHEON_SITE=example
ENV PANTHEON_ENV=test

# Override command/entrypoint from upstream image
ENTRYPOINT ["/opt/run"]
CMD []
