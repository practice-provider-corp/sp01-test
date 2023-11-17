FROM ubuntu/apache2:2.4-20.04_beta

RUN apt -y update
RUN apt -y upgrade
#RUN apt -y full-upgrade
RUN apt -y autoremove
RUN apt -y install curl unzip wget jq
RUN apt -y install ca-certificates

RUN curl --fail --remote-name https://pkg.switch.ch/switchaai/ubuntu/dists/focal/main/binary-all/misc/switchaai-apt-source_1.0.0~ubuntu20.04.1_all.deb
RUN apt install ./switchaai-apt-source_1.0.0~ubuntu20.04.1_all.deb
RUN apt update
RUN apt install -y --install-recommends shibboleth
#RUN apt full-upgrade
RUN apt autoremove

RUN mkdir /certs
COPY certs/. /certs
RUN chown -R www-data:www-data /certs && chmod -R go-rwx /certs

WORKDIR /var/www/ui/v1

COPY files/gh-dl.sh \
     /usr/local/sbin/

RUN /usr/local/sbin/gh-dl.sh latest production.zip && unzip production.zip && rm production.zip

COPY files/shibd-apache2.sh \
     /usr/local/sbin/

COPY files/001-secure.conf \
    /etc/apache2/sites-available/.

RUN a2enmod ssl && \
    a2enmod proxy_http && \
    a2enmod headers && \
    a2ensite 001-secure

ENTRYPOINT ["shibd-apache2.sh"]
