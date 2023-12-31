FROM php:8.1-fpm-alpine AS app_php

# Add php extensions installer: https://github.com/mlocati/docker-php-extension-installer
COPY --from=mlocati/php-extension-installer --link /usr/bin/install-php-extensions /usr/local/bin/

# Add composer
COPY --from=composer/composer:2-bin --link /composer /usr/bin/composer

# Add healthcheck
ADD https://raw.githubusercontent.com/renatomefi/php-fpm-healthcheck/master/php-fpm-healthcheck /usr/local/bin/php-fpm-healthcheck
RUN chmod a+rx /usr/local/bin/php-fpm-healthcheck

# Add entrypoint
ADD .docker/entrypoint.sh /usr/local/bin/pixelfed-entrypoint
RUN chmod +x /usr/local/bin/pixelfed-entrypoint

# Locales
WORKDIR /tmp
ENV MUSL_LOCALE_DEPS cmake make musl-dev gcc gettext-dev libintl
ENV MUSL_LOCPATH /usr/share/i18n/locales/musl
ADD https://gitlab.com/rilian-la-te/musl-locales/-/archive/master/musl-locales-master.zip /tmp/musl-locales-master.zip

RUN set -eux; \
	apk add --no-cache \
    $MUSL_LOCALE_DEPS \
    ; \
    unzip musl-locales-master.zip; \
    cd musl-locales-master; \
    cmake -DLOCALE_PROFILE=OFF -D CMAKE_INSTALL_PREFIX:PATH=/usr .; make; make install; \
    cd ..; \
    rm -r musl-locales-master musl-locales-master.zip

# persistent / runtime deps
RUN set -eux; \
	apk add --no-cache \
		acl \
		fcgi \
		file \
		gettext \
		git \
	;

RUN set -eux; \
    install-php-extensions \
    	apcu \
    	bcmath \
    	curl \
    	exif \
    	gd \
    	imagick \
    	intl \
		igbinary \
		opcache \
    	openssl \
    	pcntl \
    	pdo_mysql \
    	pdo_pgsql \
		redis \
    	zip \
    ; \
    printf '\nsession.serialize_handler=igbinary\napc.serializer=igbinary' >> "$PHP_INI_DIR/conf.d/docker-php-ext-igbinary.ini"

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY --link .docker/php/conf.d/php.ini $PHP_INI_DIR/conf.d/custom.ini

ARG UID=1000
ARG GID=1000

RUN set -eux; \
	addgroup -g $GID pixelfed; \
    adduser -u $UID -D -G pixelfed pixelfed; \
    mkdir -p /home/web; chown $UID:$GID /home/pixelfed; \
    mkdir -p /srv/app; chown $UID:$GID /srv/app; \
    mkdir -p /var/run/php; chown $UID:$GID /var/run/php

USER pixelfed
WORKDIR /srv/app

COPY --chown=$UID:$GID composer.json composer.lock ./
RUN set -eux; \
	composer install --prefer-dist --no-dev --no-autoloader --no-scripts --no-progress --no-interaction; \
	composer clear-cache

COPY --chown=$UID:$GID . .
COPY --chown=$UID:$GID storage storage.skel

RUN set -eux; \
	composer dump-autoload --classmap-authoritative --no-dev; \
    php artisan horizon:publish

VOLUME /srv/app/storage
VOLUME /srv/app/bootstrap

ENTRYPOINT ["pixelfed-entrypoint"]
CMD ["php-fpm"]
