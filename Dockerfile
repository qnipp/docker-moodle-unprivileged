# Docker-Moodle
# Dockerfile for moodle instance. more dockerish version of https://github.com/sergiogomez/docker-moodle
# Forked from Jade Auer's docker version. https://github.com/jda/docker-moodle
FROM ubuntu:19.04
LABEL maintainer="Franz Knipp <franz@qnipp.com>"

VOLUME ["/var/moodledata"]
EXPOSE 8080
COPY moodle-config.php /var/www/html/config.php

# Let the container know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

# Configuration using environment variables
ENV MOODLE_URL http://127.0.0.1:8080
ENV DB_TYPE mysqli
ENV DB_HOST 127.0.0.1
ENV DB_PORT 3306
ENV DB_NAME moodle
ENV DB_USER moodle
ENV DB_PASSWORD secret
ENV SSL_PROXY false

COPY ./foreground.sh /etc/apache2/foreground.sh

RUN apt-get update && \
	apt-get -y install mysql-client pwgen python-setuptools curl git unzip apache2 php \
		php-gd libapache2-mod-php postfix wget supervisor php-pgsql curl libcurl4 \
		libcurl3-dev php-curl php-xmlrpc php-intl php-mysql git-core php-xml php-mbstring \
		php-zip php-soap php-ldap ghostscript unoconv && \
	cd /tmp && \
	git clone -b MOODLE_38_STABLE git://git.moodle.org/moodle.git --depth=1 && \
	mv /tmp/moodle/* /var/www/html/ && \
	rm /var/www/html/index.html && \
	chown -R www-data:www-data /var/www && \
	chmod +x /etc/apache2/foreground.sh

# Copy Apache configuration files
COPY etc/apache2/ports.conf /etc/apache2
COPY etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available

# Set file permissions
RUN chown -R www-data: /var/log/apache2
RUN chown -R www-data: /var/run/apache2

# Cleanup, this is ran to reduce the resulting size of the image.
RUN apt-get clean autoclean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/lib/dpkg/* /var/lib/cache/* /var/lib/log/*

# User www-data
USER 33

ENTRYPOINT ["/etc/apache2/foreground.sh"]
