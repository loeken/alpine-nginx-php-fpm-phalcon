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
RUN apk add php7-dev $PHPIZE_DEPS
ADD https://raw.githubusercontent.com/docker-library/php/master/docker-php-ext-install /usr/local/bin/
ADD https://raw.githubusercontent.com/docker-library/php/master/docker-php-source /usr/local/bin/
ADD https://raw.githubusercontent.com/docker-library/php/master/docker-php-ext-configure /usr/local/bin/
ADD https://raw.githubusercontent.com/docker-library/php/master/docker-php-ext-enable /usr/local/bin/
RUN chown nobody:nobody /usr/local/bin/docker-*
RUN chmod uga+x /usr/local/bin/docker-php-* && sync

RUN set -xe && \
        # Download PSR, see https://github.com/jbboehr/php-psr
        curl -LO https://github.com/jbboehr/php-psr/archive/v${PSR_VERSION}.tar.gz && \
        tar xzf ${PWD}/v${PSR_VERSION}.tar.gz && \
        # Download Phalcon
        curl -LO https://github.com/phalcon/cphalcon/archive/v${PHALCON_VERSION}.tar.gz && \
        tar xzf ${PWD}/v${PHALCON_VERSION}.tar.gz && \
        docker-php-ext-install -j $(getconf _NPROCESSORS_ONLN) \
            ${PWD}/php-psr-${PSR_VERSION} \
            ${PWD}/cphalcon-${PHALCON_VERSION}/build/${PHALCON_EXT_PATH} \
            --ini /etc/php7/conf.d/50-phalcon.ini \
        && \
        # Remove all temp files
        rm -r \
            ${PWD}/v${PSR_VERSION}.tar.gz \
            ${PWD}/php-psr-${PSR_VERSION} \
            ${PWD}/v${PHALCON_VERSION}.tar.gz \
            ${PWD}/cphalcon-${PHALCON_VERSION} \
        && \
        ls && \
        find / -name phalcon.so && \
        php -m

COPY . /var/www/html
WORKDIR /var/www/html