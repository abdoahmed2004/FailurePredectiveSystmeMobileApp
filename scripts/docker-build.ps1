# ================================================
# PowerShell Script for Docker Operations
# ================================================
# Usage: .\scripts\docker-build.ps1 [command]
# Commands: build-web, build-android, run-web, stop, clean
# ================================================

param(
    [Parameter(Position=0)]
    [ValidateSet("build-web", "build-android", "run-web", "run-dev", "stop", "clean", "logs", "shell")]
    [string]$Command = "build-web"
)

$ErrorActionPreference = "Stop"

function Write-ColorOutput($ForegroundColor, $Message) {
    Write-Host $Message -ForegroundColor $ForegroundColor
}

switch ($Command) {
    "build-web" {
        Write-ColorOutput "Cyan" "🔨 Building Flutter Web Docker Image..."
        docker build -t fpms-web:latest .
        Write-ColorOutput "Green" "✅ Build complete! Run with: docker run -p 8080:80 fpms-web:latest"
    }
    
    "build-android" {
        Write-ColorOutput "Cyan" "📱 Building Android APK in Docker..."
        docker build -f Dockerfile.android -t fpms-android-builder:latest .
        
        # Extract APK from container
        $containerId = docker create fpms-android-builder:latest
        docker cp "${containerId}:/app/build/app/outputs/flutter-apk/app-release.apk" ./app-release.apk
        docker rm $containerId
        
        Write-ColorOutput "Green" "✅ APK extracted to ./app-release.apk"
    }
    
    "run-web" {
        Write-ColorOutput "Cyan" "🚀 Starting Flutter Web App with Docker Compose..."
        docker-compose up -d fpms-web
        Write-ColorOutput "Green" "✅ App running at http://localhost:8080"
    }
    
    "run-dev" {
        Write-ColorOutput "Cyan" "🔧 Starting Development Environment..."
        docker-compose -f docker-compose.dev.yml up -d
        Write-ColorOutput "Green" "✅ Dev server running at http://localhost:8080"
    }
    
    "stop" {
        Write-ColorOutput "Yellow" "🛑 Stopping all containers..."
        docker-compose down
        docker-compose -f docker-compose.dev.yml down 2>$null
        Write-ColorOutput "Green" "✅ All containers stopped"
    }
    
    "clean" {
        Write-ColorOutput "Red" "🧹 Cleaning up Docker resources..."
        docker-compose down -v --rmi local
        docker image prune -f
        Write-ColorOutput "Green" "✅ Cleanup complete"
    }
    
    "logs" {
        Write-ColorOutput "Cyan" "📋 Showing container logs..."
        docker-compose logs -f
    }
    
    "shell" {
        Write-ColorOutput "Cyan" "💻 Opening shell in Flutter container..."
        docker run -it --rm -v ${PWD}:/app -w /app fpms-web:latest /bin/bash
    }
}
