FROM wordpress:apache

ENV DEMO_SITE 0
ENV DEMO_SITE_USERNAME standoutwp
ENV DEMO_SITE_PASSWORD standoutwp
ENV DEMO_SITE_PASSPHRASE 36303902180949383769

RUN apt-get update
RUN apt-get install -y libxml2 libxml2-dev

# Install PHP Soap Extention
RUN docker-php-ext-install soap

# Sendmail
RUN apt-get install -y --no-install-recommends sendmail
RUN rm -rf /var/lib/apt/lists/*
RUN echo "sendmail_path=sendmail -t -i" >> /usr/local/etc/php/conf.d/sendmail.ini

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
