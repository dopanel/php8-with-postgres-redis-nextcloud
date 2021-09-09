FROM php:8.0-fpm-alpine

ENV PHP_INI_DIR=/usr/local/etc/php

RUN set -ex && \ 
apk update && \ 
apk add  --no-cache zip unzip git libpng-dev libpq libaio libnsl libc6-compat postgresql-dev openssl-dev autoconf musl-dev imagemagick-dev libffi-dev libzip-dev  libxml2-dev libaio-dev imap-dev krb5-dev ${PHPIZE_DEPS}  && \ 
pecl install -o -f redis  && \ 
ln -s /lib64/* /lib && \ 
ln -s libnsl.so.2 /usr/lib/libnsl.so.1 && \ 
ln -s libc.so /usr/lib/libresolv.so.2  && \ 
docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql && \ 
docker-php-ext-configure imap --with-kerberos --with-imap-ssl  && \ 
docker-php-ext-install pdo pdo_pgsql pgsql imap  && \ 
docker-php-ext-install gd zip  && \ 
docker-php-ext-enable redis  && \ 
rm -rf /tmp/*  && \ 
apk del zip ${PHPIZE_DEPS}  && \ 
docker-php-source delete && \
rm -rf /var/cache/apk/* /tmp/pear/ 

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
RUN sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 2G/g' "$PHP_INI_DIR/php.ini"
RUN sed -i 's/post_max_size = 8M/post_max_size = 2G/g' "$PHP_INI_DIR/php.ini"
RUN sed -i 's/memory_limit = 128M/memory_limit = 1G/g' "$PHP_INI_DIR/php.ini"
RUN echo "opcache.enable=1" >> "$PHP_INI_DIR/php.ini"
RUN echo "opcache.enable_cli=1" >> "$PHP_INI_DIR/php.ini"
RUN echo "opcache.jit_buffer_size=500M" >> "$PHP_INI_DIR/php.ini"
RUN echo "opcache.jit=tracing" >> "$PHP_INI_DIR/php.ini"
RUN echo "opcache.jit=1255" >> "$PHP_INI_DIR/php.ini"

WORKDIR /code
EXPOSE 9000
CMD php-fpm
