#!/bin/sh

# Maximum number of extra paths (PROXY_PATH1 .. PROXY_PATH5)
MAX_PATHS=5

# Check initial proxy settings
if [ -z "$PROXY_HOST" ] || [ -z "$PROXY_PORT" ]; then
    echo "PROXY_HOST and PROXY_PORT must be set."
    exit 1
fi

# Define the beginning of the Nginx configuration
cat <<EOL >/etc/nginx/conf.d/default.conf
server {
    listen 80;

    client_max_body_size 100M;
    proxy_max_temp_file_size 0;
    proxy_buffering off;
    
    location / {
        if (\$request_method = OPTIONS) {
            add_header Access-Control-Allow-Origin \$http_origin always;
            add_header Access-Control-Allow-Methods "GET, POST, OPTIONS, PUT, DELETE" always;
            add_header Access-Control-Allow-Headers "Authorization, Content-Type, X-Requested-With" always;
            add_header Access-Control-Max-Age 86400;
            add_header Content-Length 0;
            return 204;
        }

        proxy_pass http://$PROXY_HOST:$PROXY_PORT/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 1800;
        proxy_connect_timeout 1800;
        proxy_send_timeout 1800;
        send_timeout 1800;

        add_header Access-Control-Allow-Origin \$http_origin always;
        add_header Access-Control-Allow-Methods "GET, POST, OPTIONS, PUT, DELETE" always;
        add_header Access-Control-Allow-Headers "Authorization, Content-Type, X-Requested-With" always;
    }

EOL

# Warn about paths beyond the supported maximum
for N in $(env | sed -n 's/^PROXY_PATH\([0-9][0-9]*\)=.*/\1/p'); do
    if [ "$N" -gt "$MAX_PATHS" ]; then
        echo "Warning: PROXY_PATH$N is ignored, only up to $MAX_PATHS paths are supported."
    fi
done

# Loop over PROXY_PATH1..PROXY_PATH$MAX_PATHS with their PROXY_HOSTx and PROXY_PORTx
INDEX=1
while [ "$INDEX" -le "$MAX_PATHS" ]; do
    eval PATH_VAR="\$PROXY_PATH$INDEX"
    eval HOST_VAR="\$PROXY_HOST$INDEX"
    eval PORT_VAR="\$PROXY_PORT$INDEX"

    # Skip unused slots, so gaps (e.g. PROXY_PATH1 and PROXY_PATH3 only) are allowed
    if [ -z "$PATH_VAR" ]; then
        INDEX=$((INDEX + 1))
        continue
    fi

    if [ -z "$HOST_VAR" ] || [ -z "$PORT_VAR" ]; then
        echo "PROXY_HOST$INDEX and PROXY_PORT$INDEX must be set when PROXY_PATH$INDEX is set."
        exit 1
    fi

    # Append location block to the Nginx configuration
    cat <<EOL >>/etc/nginx/conf.d/default.conf
    location $PATH_VAR {
        if (\$request_method = OPTIONS) {
            add_header Access-Control-Allow-Origin \$http_origin always;
            add_header Access-Control-Allow-Methods "GET, POST, OPTIONS, PUT, DELETE" always;
            add_header Access-Control-Allow-Headers "Authorization, Content-Type, X-Requested-With" always;
            add_header Access-Control-Max-Age 86400;
            add_header Content-Length 0;
            return 204;
        }

        proxy_pass http://$HOST_VAR:$PORT_VAR;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 1800;
        proxy_connect_timeout 1800;
        proxy_send_timeout 1800;
        send_timeout 1800;

        add_header Access-Control-Allow-Origin \$http_origin always;
        add_header Access-Control-Allow-Methods "GET, POST, OPTIONS, PUT, DELETE" always;
        add_header Access-Control-Allow-Headers "Authorization, Content-Type, X-Requested-With" always;
    }
EOL

    # Increment index to check next set of PROXY_PATHx, PROXY_HOSTx, PROXY_PORTx
    INDEX=$((INDEX + 1))
done

# End of Nginx configuration
cat <<EOL >>/etc/nginx/conf.d/default.conf
}
EOL

# Start Nginx
exec "$@"
