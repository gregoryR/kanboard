FROM alpine:3.20

LABEL org.opencontainers.image.source https://github.com/kanboard/kanboard
LABEL org.opencontainers.image.title=Kanboard
LABEL org.opencontainers.image.description="Kanboard is project management software that focuses on the Kanban methodology"
LABEL org.opencontainers.image.vendor=Kanboard
LABEL org.opencontainers.image.licenses=MIT
LABEL org.opencontainers.image.url=https://kanboard.org
LABEL org.opencontainers.image.documentation=https://docs.kanboard.org

VOLUME /var/www/app/data
VOLUME /var/www/app/plugins
VOLUME /etc/nginx/ssl

EXPOSE 80 443

ARG VERSION

RUN apk --no-cache --update add \
    tzdata openssl unzip xz nginx bash ca-certificates curl ssmtp mailx php83 php83-phar php83-curl \
    php83-fpm php83-json php83-zlib php83-xml php83-dom php83-ctype php83-opcache php83-zip php83-iconv \
    php83-pdo php83-pdo_mysql php83-pdo_sqlite php83-pdo_pgsql php83-mbstring php83-session php83-bcmath \
    php83-gd php83-openssl php83-sockets php83-posix php83-ldap php83-simplexml php83-xmlwriter && \
    rm -rf /var/www/localhost && \
    rm -f /etc/php83/php-fpm.d/www.conf && \
    ln -sf /usr/bin/php83 /usr/bin/php

ARG S6_OVERLAY_VERSION=3.2.0.2

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz

ADD . /var/www/app
ADD docker/ /

RUN rm -rf /var/www/app/docker && echo $VERSION > /var/www/app/app/version.txt

ENTRYPOINT ["/init"]
CMD []
