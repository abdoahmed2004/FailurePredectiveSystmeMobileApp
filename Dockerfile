# ================================================
# Dockerfile for Flutter Web Build & Deployment
# ================================================
# This Dockerfile builds the Flutter web version 
# of your app and serves it using Nginx
# ================================================

# Stage 1: Build the Flutter Web app
FROM ubuntu:22.04 AS build

# Avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies with retry logic
RUN apt-get update --fix-missing && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set up Flutter
ENV FLUTTER_HOME=/opt/flutter
ENV PATH=$FLUTTER_HOME/bin:$PATH

# Download and install Flutter (stable channel)
RUN git clone --depth 1 --branch stable https://github.com/flutter/flutter.git $FLUTTER_HOME

# Run flutter doctor
RUN flutter doctor -v

# Enable web support
RUN flutter config --enable-web

# Set working directory
WORKDIR /app

# Copy pubspec files first (for better caching)
COPY pubspec.yaml pubspec.lock* ./

# Get dependencies
RUN flutter pub get

# Copy the rest of the source code
COPY . .

# Build web release
RUN flutter build web --release

# ================================================
# Stage 2: Serve with Nginx
# ================================================
FROM nginx:alpine AS production

# Copy built web files to nginx
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy custom nginx config (optional)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
