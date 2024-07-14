FROM nginx:alpine

# Copy the NGINX configuration template into the container
COPY config/nginx.conf.template /etc/nginx/templates/

# Copy the script to substitute environment variables
COPY nginx/entrypoint.sh /entrypoint.sh

# Make the entrypoint script executable
RUN chmod +x /entrypoint.sh

# Use the custom entrypoint script
ENTRYPOINT ["/entrypoint.sh"]

# Run NGINX in the foreground
CMD ["nginx", "-g", "daemon off;"]
