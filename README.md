# Nginx Proxy Configuration with Docker

This guide sets up an Nginx reverse proxy using Docker. The configuration routes requests to `/` to one server and requests to `/api` to another server.

## Prerequisites

- Docker installed on your machine
- Access to the servers you want to proxy to (`server1` and `server2`)

## Configuration

1. **Create a project directory**:

   ```bash
   mkdir nginx-proxy
   cd nginx-proxy
   ```

2. **Create a Dockerfile**:

   In the project directory, create a `Dockerfile`:

   ```dockerfile
   # Use the official Nginx image from the Docker Hub
   FROM nginx:latest

   # Copy the custom Nginx configuration file to the container
   COPY nginx.conf /etc/nginx/nginx.conf
   ```

3. **Create the Nginx configuration file**:

   In the project directory, create an `nginx.conf` file with the following content:

   ```nginx
   events {}

   http {
       server {
           listen 80;

           server_name your_domain_or_ip;

           location / {
               proxy_pass http://server1;
               proxy_set_header Host $host;
               proxy_set_header X-Real-IP $remote_addr;
               proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
               proxy_set_header X-Forwarded-Proto $scheme;
           }

           location /api {
               proxy_pass http://server2;
               proxy_set_header Host $host;
               proxy_set_header X-Real-IP $remote_addr;
               proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
               proxy_set_header X-Forwarded-Proto $scheme;
           }
       }
   }
   ```

   Replace `your_domain_or_ip` with your server's domain name or IP address. Replace `http://server1` and `http://server2` with the appropriate addresses of the servers you are proxying to.

4. **Build the Docker image**:

   In the project directory, build the Docker image:

   ```bash
   docker build -t nginx-proxy .
   ```

5. **Run the Docker container**:

   Run the Docker container, mapping port 80 of the host to port 80 of the container:

   ```bash
   docker run -d -p 80:80 --name nginx-proxy nginx-proxy
   ```

## Verify the Setup

1. Open your web browser and navigate to `http://your_domain_or_ip`. You should be proxied to `server1`.

2. Navigate to `http://your_domain_or_ip/api`. You should be proxied to `server2`.

## Troubleshooting

- **Check Docker container logs**: If you encounter any issues, check the logs of the Docker container.

  ```bash
  docker logs nginx-proxy
  ```

- **Firewall settings**: Ensure that your firewall settings allow traffic on port 80.

## Conclusion

You have successfully set up an Nginx reverse proxy using Docker, routing traffic based on URL paths. Requests to `/` are directed to `server1`, and requests to `/api` are directed to `server2`.

For more detailed information on Nginx and Docker configurations, please refer to the [official Nginx documentation](https://nginx.org/en/docs/) and the [official Docker documentation](https://docs.docker.com/).
