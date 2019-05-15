#!/usr/bin/env bash

# Sendmail configuration
set -euo pipefail
echo "127.0.0.1 $(hostname) localhost localhost.localdomain" >> /etc/hosts
service sendmail restart

# Enable extensions and config for specific server
[ -f /hekto/container ] && chmod +x /hekto/container && sh /hekto/container

# Handle demo site
if [ "$DEMO_SITE" = "1" ] ; then
    a2enmod session
    a2enmod session_cookie
    a2enmod session_crypto
    a2enmod request
    a2enmod auth_form
    htpasswd -b -c /var/www/.standout_wp/passwords $DEMO_SITE_USERNAME $DEMO_SITE_PASSWORD

    # Find container ip
    ip_address_bridge="$(hostname -I)"

    {
        echo 'Alias /401.html /var/www/.standout_wp/index.html'
        echo 'ErrorDocument 401 /401.html'

        echo '<Directory /var/www/html/>'
        echo 'AuthFormProvider file'
        echo 'AuthName "Standout WP - Demo"'
        echo 'AuthType form'
        echo 'AuthUserFile /var/www/.standout_wp/passwords'
        echo 'ErrorDocument 401 /401.html'
        echo 'Session On'
        echo 'SessionCookieName session path=/'
        echo "SessionCryptoPassphrase $DEMO_SITE_PASSPHRASE"
        echo 'Require valid-user'
        echo 'Order allow,deny'
        # Remove last char in ip_address_bridge then allow for intervall .0/8
        # This will allow for processes lite screenshots and other internal Docker
        echo "Allow from ${ip_address_bridge%?}0/8"
        echo 'Satisfy any'
        echo 'Options -Indexes'
        echo '</Directory>'

    } >> /etc/apache2/sites-enabled/000-default.conf
fi

# Entrypoint
exec docker-entrypoint.sh "$@"
