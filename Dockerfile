# Use the official Nginx image
FROM nginx

# Copy the application files to the Nginx server's root directory
COPY build/ /usr/share/nginx/html

# Expose port 80 to the outside world
EXPOSE 80

# No need to specify daemon off; since Nginx runs in the foreground by default
CMD ["nginx", "-g", "daemon off;"]
