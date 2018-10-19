FROM wordpress:apache

RUN apt-get update
RUN apt-get install -y libxml2 libxml2-dev

# Install PHP Soap Extention
RUN docker-php-ext-install soap

# Sendmail 
RUN apt-get install -y --no-install-recommends sendmail
RUN rm -rf /var/lib/apt/lists/* 
RUN echo "sendmail_path=sendmail -t -i" >> /usr/local/etc/php/conf.d/sendmail.ini
RUN echo '#!/bin/bash' >> /usr/local/bin/docker-entrypoint-wrapper.sh
RUN echo 'set -euo pipefail' >> /usr/local/bin/docker-entrypoint-wrapper.sh
RUN echo 'echo "127.0.0.1 $(hostname) localhost localhost.localdomain" >> /etc/hosts' >> /usr/local/bin/docker-entrypoint-wrapper.sh
RUN echo 'service sendmail restart' >> /usr/local/bin/docker-entrypoint-wrapper.sh
RUN echo 'exec docker-entrypoint.sh "$@"' >> /usr/local/bin/docker-entrypoint-wrapper.sh
RUN chmod +x /usr/local/bin/docker-entrypoint-wrapper.sh

# Pagespeed
RUN cd /tmp \
    && curl -o /tmp/mod-pagespeed.deb https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-beta_current_amd64.deb \
    && dpkg -i /tmp/mod-pagespeed.deb \
    && apt-get -f install
RUN a2enmod pagespeed
RUN a2enmod expires
RUN echo "ModPagespeed On" >> /etc/apache2/apache2.conf
RUN echo "ModPagespeedEnableFilters combine_css,combine_javascript,inline_google_font_css,move_css_to_head,extend_cache,rewrite_images" >> /etc/apache2/apache2.conf

# Make sure we can get the forwarded IP from proxy
RUN a2enmod remoteip
RUN sed -i 's/LogFormat "%h %l %u %t \\"%r\\" %>s %O \\"%{Referer}i\\" \\"%{User-Agent}i\\"" combined/LogFormat "%a %l %u %t \\"%r\\" %>s %O \\"%{Referer}i\\" \\"%{User-Agent}i\\"" combined/g' /etc/apache2/apache2.conf
RUN echo "# Remote IP configuration" >> /etc/apache2/apache2.conf
RUN echo "RemoteIPHeader X-Real-IP" >> /etc/apache2/apache2.conf
RUN echo "RemoteIPTrustedProxy https" >> /etc/apache2/apache2.conf

# Headers module needed by some Wordpress cache plugin's
RUN a2enmod headers

ENTRYPOINT ["docker-entrypoint-wrapper.sh"]
CMD ["apache2-foreground"]
