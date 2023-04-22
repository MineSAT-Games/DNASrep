FROM ubuntu:16.04

ARG SERVER_IP

WORKDIR /work
COPY . .

# ======= Installs for DNAS responses
RUN apt-get update && apt-get install -y \
  libssl-dev ssl-cert php7.0 libapache2-mod-php7.0 \
  wget unzip php7.0-mcrypt libmcrypt-dev \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN echo "extension=mcrypt.so" > /etc/php/7.0/mods-available/mcrypt.ini \
  && a2enmod ssl && a2ensite default-ssl && phpenmod mcrypt \
  && a2enmod proxy && a2enmod proxy_http && a2enmod proxy_connect

RUN cp ./etc/apache2/sites-available/dnas.conf /etc/apache2/sites-available/dnas.conf \
  && cp -r ./www/dnas /var/www/dnas \
  && cp -r ./etc/dnas /etc/dnas \
  && ln -s /etc/apache2/sites-available/dnas.conf /etc/apache2/sites-enabled/dnas.conf \
  && unlink /etc/apache2/sites-enabled/000-default.conf \
  && unlink /etc/apache2/sites-enabled/default-ssl.conf \
  && ln -sf /proc/self/fd/1 /var/log/apache2/access.log \
  && ln -sf /proc/self/fd/1 /var/log/apache2/error.log

# ======= Installs for DNS Bind server
RUN apt-get update && apt-get install -y \
  bind9 bind9utils bind9-doc dnsutils

RUN cp ./dns_files/* /etc/bind/

RUN sed -i "s/SERVER_IP/${SERVER_IP}/g" /etc/bind/db.dnas.rpz

# DNAS Port
EXPOSE 443
# DNS Server port
EXPOSE 53/udp 53/tcp

ADD ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
