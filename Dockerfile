# Use the official Nginx image from Docker Hub
FROM nginx:latest

# Copy custom HTML files to the Nginx web server's default directory
COPY ./html /usr/share/nginx/html

# Copy the start script to inject the environment variable into the HTML file
COPY ./start.sh /start.sh

# Make the script executable
RUN chmod +x /start.sh

# Expose port 80
EXPOSE 80

# Run the start script before starting Nginx
CMD ["/bin/sh", "-c", "/start.sh && nginx -g 'daemon off;'"]
