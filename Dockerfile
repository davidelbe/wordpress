FROM wordpress:apache

ENV DEMO_SITE 0
ENV DEMO_SITE_USERNAME standoutwp
ENV DEMO_SITE_PASSWORD standoutwp
ENV DEMO_SITE_PASSPHRASE 36303902180949383769

RUN apt-get update
RUN apt-get install -y libxml2 libxml2-dev wget gnupg

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -

# Install PHP Soap Extention
RUN docker-php-ext-install soap

# Sendmail
RUN apt-get install -y --no-install-recommends sendmail
RUN rm -rf /var/lib/apt/lists/*
RUN echo "sendmail_path=sendmail -t -i" >> /usr/local/etc/php/conf.d/sendmail.ini

# Pagespeed
RUN cd /tmp \
    && curl -o /tmp/mod-pagespeed.deb https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-stable_current_amd64.deb  \
    && dpkg -i /tmp/mod-pagespeed.deb \
    && apt-get -f install --allow-unauthenticated
RUN a2enmod pagespeed
RUN a2enmod expires
RUN echo "ModPagespeed On" >> /etc/apache2/apache2.conf
RUN echo "ModPagespeedRewriteLevel CoreFilters" >> /etc/apache2/apache2.conf
RUN echo "ModPagespeedRespectXForwardedProto on" >> /etc/apache2/apache2.conf
RUN echo "ModPagespeedMaxCombinedJsBytes 250000" >> /etc/apache2/apache2.conf
RUN echo "ModPagespeedMaxSegmentLength 1024" >> /etc/apache2/apache2.conf
RUN echo "ModPagespeedDomain *" >> /etc/apache2/apache2.conf
RUN echo "ModPagespeedEnableFilters extend_cache,prioritize_critical_css,defer_javascript" >> /etc/apache2/apache2.conf


# Make sure we can get the forwarded IP from proxy
RUN a2enmod remoteip
RUN sed -i 's/LogFormat "%h %l %u %t \\"%r\\" %>s %O \\"%{Referer}i\\" \\"%{User-Agent}i\\"" combined/LogFormat "%a %l %u %t \\"%r\\" %>s %O \\"%{Referer}i\\" \\"%{User-Agent}i\\"" combined/g' /etc/apache2/apache2.conf
RUN echo "# Remote IP configuration" >> /etc/apache2/apache2.conf
RUN echo "RemoteIPHeader X-Real-IP" >> /etc/apache2/apache2.conf
RUN echo "RemoteIPTrustedProxy https" >> /etc/apache2/apache2.conf

# Headers module needed by some Wordpress cache plugin's
RUN a2enmod headers

# File uploads
RUN echo 'upload_max_filesize = 50M' > /usr/local/etc/php/conf.d/hekto.ini
RUN echo 'post_max_size = 50M' > /usr/local/etc/php/conf.d/hekto.ini

# Assets for demo auth protection
COPY .standout_wp/ /var/www/.standout_wp/

# Entrypoint
COPY docker-entrypoint-wrapper.sh /usr/local/bin/docker-entrypoint-wrapper.sh
RUN chmod +x /usr/local/bin/docker-entrypoint-wrapper.sh

ENTRYPOINT ["docker-entrypoint-wrapper.sh"]
CMD ["apache2-foreground"]
