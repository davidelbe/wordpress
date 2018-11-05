# wordpress
Docker repo for Standout WP

## Demo Sites
Authentication can be activated for demo sites.
By default this is not active.
Setting the ENV variable DEMO_SITE to 1, will activate authentication.
It's also posible to modify username/password and the phrase used for credentials encryption.
By default interal ip addresses for docker are whitelisted, to ensure that the screenshot's container work.
```
DEMO_SITE: 1
DEMO_SITE_USERNAME: 'standout'
DEMO_SITE_PASSWORD: 'standout'
DEMO_SITE_PASSPHRASE: 'xssdsdsdsds33443434'
```