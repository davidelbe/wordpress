FROM wordpress:apache

RUN apt-get update
RUN apt-get install -y libxml2 libxml2-dev

# Install PHP Soap Extention
RUN docker-php-ext-install soap

# Sendmail 
RUN sudo apt-get install -y --no-install-recommends sendmail
RUN rm -rf /var/lib/apt/lists/* 
RUN echo "sendmail_path=sendmail -t -i" >> /usr/local/etc/php/conf.d/sendmail.ini
RUN echo '#!/bin/bash' >> /usr/local/bin/docker-entrypoint-wrapper.sh
RUN echo 'set -euo pipefail' >> /usr/local/bin/docker-entrypoint-wrapper.sh
RUN echo 'echo "127.0.0.1 $(hostname) localhost localhost.localdomain" >> /etc/hosts' >> /usr/local/bin/docker-entrypoint-wrapper.sh
RUN echo 'service sendmail restart' >> /usr/local/bin/docker-entrypoint-wrapper.sh
RUN echo 'exec docker-entrypoint.sh "$@"' >> /usr/local/bin/docker-entrypoint-wrapper.sh
RUN chmod +x /usr/local/bin/docker-entrypoint-wrapper.sh

ENTRYPOINT ["docker-entrypoint-wrapper.sh"]
CMD ["apache2-foreground"]
