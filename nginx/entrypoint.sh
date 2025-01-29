#!/bin/sh

# Define the beginning of the Nginx configuration
cat <<EOL >/etc/nginx/conf.d/default.conf
server {
    listen 80;
    
    location / {
        proxy_pass http://$PROXY_HOST:$PROXY_PORT/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 1800;
        proxy_connect_timeout 1800;
        proxy_send_timeout 1800;
        send_timeout 1800;
    }

EOL

# Check initial proxy settings
if [ -z "$PROXY_HOST" ] || [ -z "$PROXY_PORT" ]; then
    echo "PROXY_HOST and PROXY_PORT must be set."
    exit 1
fi

# Loop over environment variables to find PROXY_PATH, PROXY_HOST, and PROXY_PORT
INDEX=1
while true; do
    eval PATH_VAR="\$PROXY_PATH$INDEX"
    eval HOST_VAR="\$PROXY_HOST$INDEX"
    eval PORT_VAR="\$PROXY_PORT$INDEX"

    # If no PROXY_PATH exists, break the loop
    if [ -z "$PATH_VAR" ]; then
        break
    fi

    # Append location block to the Nginx configuration
    cat <<EOL >>/etc/nginx/conf.d/default.conf
    location $PATH_VAR {
        proxy_pass http://$HOST_VAR:$PORT_VAR;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 1800;
        proxy_connect_timeout 1800;
        proxy_send_timeout 1800;
        send_timeout 1800;
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
