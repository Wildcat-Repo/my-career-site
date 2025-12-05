#!/bin/bash
set -e

# Deployment script for my-career-site on AWS Lightsail
# This script runs on the Lightsail instance

echo "🚀 Starting deployment for my-career-site..."

# Configuration
APP_DIR="/home/bitnami/apps/my-career-site"
REPO_URL="https://git.gondoberg.com/PaddedWalls/my-career-site.git"
BRANCH="main"

# Create app directory if it doesn't exist
if [ ! -d "$APP_DIR" ]; then
    echo "📁 Creating application directory..."
    mkdir -p "$APP_DIR"
fi

# Navigate to app directory
cd "$APP_DIR"

# Clone or pull latest code
if [ ! -d ".git" ]; then
    echo "📦 Cloning repository..."
    git clone "$REPO_URL" .
    git checkout "$BRANCH"
else
    echo "🔄 Pulling latest changes..."
    git fetch origin
    git checkout "$BRANCH"
    git pull origin "$BRANCH"
fi

# Create logs directory
mkdir -p logs

# Install/update dependencies
echo "📚 Installing dependencies..."
npm ci --production

# Check if PM2 is installed
if ! command -v pm2 &> /dev/null; then
    echo "📦 Installing PM2..."
    npm install -g pm2
fi

# Restart application with PM2
echo "♻️  Restarting application with PM2..."
if pm2 list | grep -q "my-career-site"; then
    pm2 restart ecosystem.config.js
else
    pm2 start ecosystem.config.js
fi

# Save PM2 process list and configure startup
pm2 save
pm2 startup systemd -u bitnami --hp /home/bitnami

echo "✅ Deployment completed successfully!"
echo "📊 Application status:"
pm2 status
