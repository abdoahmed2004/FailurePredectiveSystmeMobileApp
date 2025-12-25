# 🐳 Docker Guide for FPMS Mobile App

## Overview

This guide explains how to use Docker with your Flutter mobile application for:
- **Web Deployment** - Deploy the Flutter web version
- **CI/CD Builds** - Build APKs in containerized environments
- **Development Environment** - Consistent development setup

---

## 📋 Prerequisites

1. **Docker Desktop** installed on your machine
   - Windows: [Download Docker Desktop](https://www.docker.com/products/docker-desktop)
   - Make sure WSL 2 is enabled on Windows

2. **Docker Compose** (included with Docker Desktop)

---

## 🚀 Quick Start

### Option 1: Using PowerShell Scripts (Recommended for Windows)

```powershell
# Build web image
.\scripts\docker-build.ps1 build-web

# Run the web app
.\scripts\docker-build.ps1 run-web

# Build Android APK
.\scripts\docker-build.ps1 build-android

# Stop all containers
.\scripts\docker-build.ps1 stop

# Clean up Docker resources
.\scripts\docker-build.ps1 clean
```

### Option 2: Using Docker Commands Directly

```bash
# Build the Flutter web app
docker build -t fpms-web:latest .

# Run the container
docker run -d -p 8080:80 --name fpms-app fpms-web:latest

# Access at http://localhost:8080
```

### Option 3: Using Docker Compose

```bash
# Start all services (web app + backend)
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

---

## 📁 Docker Files Explained

| File | Purpose |
|------|---------|
| `Dockerfile` | Builds Flutter web app and serves with Nginx |
| `Dockerfile.android` | Builds Android APK (for CI/CD) |
| `Dockerfile.dev` | Development environment with hot reload |
| `docker-compose.yml` | Production orchestration |
| `docker-compose.dev.yml` | Development orchestration |
| `.dockerignore` | Files to exclude from Docker context |
| `nginx.conf` | Nginx web server configuration |

---

## 🔧 Common Commands

### Build Commands

```bash
# Build web version
docker build -t fpms-web:latest .

# Build Android APK
docker build -f Dockerfile.android -t fpms-android:latest .

# Extract APK from container
docker create --name temp-apk fpms-android:latest
docker cp temp-apk:/app/build/app/outputs/flutter-apk/app-release.apk ./app-release.apk
docker rm temp-apk
```

### Run Commands

```bash
# Run web app
docker run -d -p 8080:80 fpms-web:latest

# Run with environment variables (custom API URL)
docker run -d -p 8080:80 -e API_BASE_URL=https://api.example.com fpms-web:latest
```

### Debug Commands

```bash
# View running containers
docker ps

# View logs
docker logs fpms-web-app

# Enter container shell
docker exec -it fpms-web-app /bin/sh

# Check container health
docker inspect fpms-web-app
```

---

## 🌐 Deploying to Cloud

### Deploy to AWS (ECS/ECR)

```bash
# Tag image for ECR
docker tag fpms-web:latest <aws_account_id>.dkr.ecr.<region>.amazonaws.com/fpms-web:latest

# Push to ECR
docker push <aws_account_id>.dkr.ecr.<region>.amazonaws.com/fpms-web:latest
```

### Deploy to Google Cloud (GCR)

```bash
# Tag for GCR
docker tag fpms-web:latest gcr.io/<project_id>/fpms-web:latest

# Push to GCR
docker push gcr.io/<project_id>/fpms-web:latest
```

### Deploy to Azure (ACR)

```bash
# Tag for ACR
docker tag fpms-web:latest <registry_name>.azurecr.io/fpms-web:latest

# Push to ACR
docker push <registry_name>.azurecr.io/fpms-web:latest
```

---

## 🔌 Configuring API URL

The app connects to a backend API. Configure the URL:

### Method 1: Build-time (Recommended)

In the Dockerfile, the Flutter build uses `--dart-define`:

```dockerfile
RUN flutter build web --release --dart-define=API_BASE_URL=https://api.yourserver.com/api
```

### Method 2: Runtime Environment Variable

Use environment substitution in nginx (requires setup).

---

## 📱 Building Mobile Apps

### Android APK

```bash
# Build APK using Docker
docker build -f Dockerfile.android -t fpms-android:latest .

# Extract APK
docker create --name apk-extract fpms-android:latest
docker cp apk-extract:/app/build/app/outputs/flutter-apk/app-release.apk ./
docker rm apk-extract
```

### iOS (Note: Requires macOS)

Docker cannot build iOS apps directly. iOS builds require:
- macOS machine
- Xcode installed
- Apple Developer account

Consider using:
- **Codemagic** or **Bitrise** for iOS CI/CD
- macOS runners in GitHub Actions

---

## 🛠️ CI/CD Integration

### GitHub Actions Example

Create `.github/workflows/docker-build.yml`:

```yaml
name: Build and Deploy

on:
  push:
    branches: [main]

jobs:
  build-web:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Build Docker Image
        run: docker build -t fpms-web:${{ github.sha }} .
      
      - name: Push to Registry
        run: |
          echo ${{ secrets.DOCKER_PASSWORD }} | docker login -u ${{ secrets.DOCKER_USERNAME }} --password-stdin
          docker push fpms-web:${{ github.sha }}

  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Build APK
        run: docker build -f Dockerfile.android -t fpms-android .
      
      - name: Extract APK
        run: |
          docker create --name apk fpms-android
          docker cp apk:/app/build/app/outputs/flutter-apk/app-release.apk ./
          docker rm apk
      
      - name: Upload APK
        uses: actions/upload-artifact@v3
        with:
          name: release-apk
          path: app-release.apk
```

---

## ❓ Troubleshooting

### Build Fails with "Out of Memory"

Increase Docker memory in Docker Desktop settings (at least 4GB recommended).

### Flutter SDK Download Slow

The first build downloads Flutter SDK (~1GB). Use a pre-built Flutter Docker image:

```dockerfile
FROM cirrusci/flutter:stable AS build
```

### Web App Shows Blank Page

Check if the API URL is correctly configured. The app needs to connect to a running backend.

### Permission Denied on Windows

Run PowerShell as Administrator, or use:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 📚 Additional Resources

- [Flutter Web Documentation](https://docs.flutter.dev/platform-integration/web)
- [Docker Documentation](https://docs.docker.com/)
- [Nginx Configuration](https://nginx.org/en/docs/)

---

Happy Dockerizing! 🚀
