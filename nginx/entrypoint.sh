#!/bin/sh

# Substitute environment variables in the NGINX template and save to the final config file
envsubst '$FE_HOST $BE_HOST $FE_PORT $BE_PORT $BE_PATH' < /etc/nginx/templates/nginx.conf.template > /etc/nginx/conf.d/default.conf

# Execute the CMD from the Dockerfile
exec "$@"