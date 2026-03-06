#!/bin/bash
set -e

# Local deployment script for triggering deployment to AWS Lightsail
# Run this from your local machine to deploy to Lightsail

echo "🚀 Deploying my-career-site to AWS Lightsail..."

# Configuration - set LIGHTSAIL_IP and LIGHTSAIL_USER as environment variables
LIGHTSAIL_IP="${LIGHTSAIL_IP:?Error: LIGHTSAIL_IP environment variable is not set}"
LIGHTSAIL_USER="${LIGHTSAIL_USER:-bitnami}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SSH_KEY="$PROJECT_DIR/.aws/LightsailDefaultKey-us-west-2.pem"
DEPLOY_SCRIPT_URL="https://git.gondoberg.com/PaddedWalls/my-career-site/raw/branch/main/scripts/deploy.sh"

# Check if SSH key exists
if [ ! -f "$SSH_KEY" ]; then
    echo "❌ Error: SSH key not found at $SSH_KEY"
    exit 1
fi

# Check SSH key permissions
chmod 400 "$SSH_KEY"

echo "📡 Connecting to Lightsail instance at $LIGHTSAIL_IP..."

# Execute deployment on remote server
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$LIGHTSAIL_USER@$LIGHTSAIL_IP" << 'ENDSSH'
    set -e

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
        pm2 save
        pm2 startup systemd -u bitnami --hp /home/bitnami
    fi

    echo "✅ Deployment completed successfully!"
    echo "📊 Application status:"
    pm2 status
ENDSSH

echo ""
echo "✅ Deployment completed!"
echo "🌐 Your site should be accessible at: http://$LIGHTSAIL_IP:8000"
echo ""
echo "📊 To check application status:"
echo "   ssh -i $SSH_KEY $LIGHTSAIL_USER@$LIGHTSAIL_IP 'pm2 status'"
echo ""
echo "📋 To view logs:"
echo "   ssh -i $SSH_KEY $LIGHTSAIL_USER@$LIGHTSAIL_IP 'pm2 logs my-career-site'"
