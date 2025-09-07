# Use the official Flutter image as the base image
FROM cirrusci/flutter:3.10.0

# Set the working directory
WORKDIR /app

# Copy the pubspec files first for better caching
COPY pubspec.* ./

# Get dependencies
RUN flutter pub get

# Copy the rest of the application code
COPY . .

# Build the web application
RUN flutter build web --release

# Use nginx to serve the built application
FROM nginx:alpine

# Copy the built application from the previous stage
COPY --from=0 /app/build/web /usr/share/nginx/html

# Copy custom nginx configuration if needed
# COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
