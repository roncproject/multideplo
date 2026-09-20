FROM amazoncorretto:17-alpine

# Install Nginx and process utilities
RUN apk add --no-cache nginx && \
    mkdir -p /run/nginx /var/lib/nginx/tmp && \
    chown -R nginx:nginx /var/lib/nginx /run/nginx

# Forward Nginx access and error logs directly to the Docker collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

WORKDIR /app

# FIXED: Copy the compiled JARs from the flat root directory populated by GitHub Actions
COPY app1.jar /app/app1.jar
COPY app2.jar /app/app2.jar

# Delete default Nginx server configs to prevent route conflicts
RUN rm -f /etc/nginx/http.d/default.conf /etc/nginx/conf.d/default.conf

# Inject the reverse proxy routing layout
COPY nginx.conf /etc/nginx/http.d/default.conf

# Setup the process startup script
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/app/entrypoint.sh"]
