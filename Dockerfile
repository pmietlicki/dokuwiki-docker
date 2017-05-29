#dokuwiki-docker dockerfile
FROM php:7.1-apache

LABEL maintainer pmietlicki@gmail.com

ARG UPDATE=true

# Download dokuwiki source
RUN if $UPDATE -eq "true"; then curl -O https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz else curl -o dokuwiki-stable.tgz https://download.dokuwiki.org/out/dokuwiki-4df974a154ed376b43dafde403576818.tgz; fi 

# pour ext ldap
RUN apt-get update && apt-get install -y libldap2-dev vim zlib1g-dev openssl git libssl-dev
# https://bugs.php.net/bug.php?id=49876
RUN ln -fs /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/
RUN docker-php-ext-install ldap zip
RUN docker-php-ext-enable ldap zip

RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
    && docker-php-ext-install -j$(nproc) iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

# Install unzip and extract the dokuwiki files to the actual webserver folder
RUN apt-get update \
    && tar -xzvf dokuwiki-stable.tgz --strip-components=1 -C /var/www/html \
    && cd /var/www/html \
    && find . -type d -exec chmod 755 {} \; \
    && find . -type f -exec chmod 644 {} \; \
    && chown -R www-data:www-data .



VOLUME /var/www/html/data
VOLUME /var/www/html/lib/plugins
