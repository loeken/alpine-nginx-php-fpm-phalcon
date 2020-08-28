FROM php:7.3-fpm AS getsource

FROM loeken/alpine-nginx-php-fpm

ARG PSR_VERSION=1.0.0
ARG PHALCON_VERSION=3.4.4
ARG PHALCON_EXT_PATH=php7/64bits

WORKDIR /etc/php7
RUN apk add --no-cache --update tini
RUN apk add curl

COPY --from=getsource /usr/src/php.tar.xz /usr/src/php.tar.xz

ENV PHPIZE_DEPS autoconf dpkg-dev dpkg file g++ gcc libc-dev make pcre-dev pkgconf re2c php7-pdo

USER root
RUN apk add libldap php7-dev php7-ldap $PHPIZE_DEPS
RUN apk add php7-phalcon php7-yaml composer git
COPY . /var/www/html
COPY nginx_conf.d/* /etc/nginx/conf.d/
WORKDIR /var/www/html
