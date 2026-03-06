#!/bin/bash
set -e

# Rsync-based deployment script for AWS Lightsail
# This transfers files directly without requiring git on the server

echo "🚀 Deploying my-career-site to AWS Lightsail (rsync method)..."

# Configuration - set LIGHTSAIL_IP and LIGHTSAIL_USER as environment variables
LIGHTSAIL_IP="${LIGHTSAIL_IP:?Error: LIGHTSAIL_IP environment variable is not set}"
LIGHTSAIL_USER="${LIGHTSAIL_USER:-bitnami}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SSH_KEY="$PROJECT_DIR/.aws/LightsailDefaultKey-us-west-2.pem"
APP_DIR="/home/bitnami/apps/my-career-site"

# Check if SSH key exists
if [ ! -f "$SSH_KEY" ]; then
    echo "❌ Error: SSH key not found at $SSH_KEY"
    exit 1
fi

# Set SSH key permissions
chmod 400 "$SSH_KEY"

echo "📦 Syncing files to Lightsail instance..."

# Create remote directory
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$LIGHTSAIL_USER@$LIGHTSAIL_IP" \
    "mkdir -p $APP_DIR"

# Build SSH command for rsync
SSH_CMD="ssh -i '$SSH_KEY' -o StrictHostKeyChecking=no"

# Rsync files (excluding node_modules, .git, etc.)
rsync -avz --delete \
    -e "$SSH_CMD" \
    --exclude='.git/' \
    --exclude='node_modules/' \
    --exclude='.aws/' \
    --exclude='.history/' \
    --exclude='.claude/' \
    --exclude='.idea/' \
    --exclude='.vscode/' \
    --exclude='cypress/videos/' \
    --exclude='cypress/screenshots/' \
    --exclude='cypress/downloads/' \
    --exclude='logs/' \
    --exclude='tmp/' \
    --exclude='.DS_Store' \
    "$PROJECT_DIR/" \
    "$LIGHTSAIL_USER@$LIGHTSAIL_IP:$APP_DIR/"

echo "✅ Files synced successfully!"
echo "🔧 Setting up application on server..."

# Execute setup and restart on remote server
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$LIGHTSAIL_USER@$LIGHTSAIL_IP" << ENDSSH
    set -e
    cd $APP_DIR

    echo "📁 Creating logs directory..."
    mkdir -p logs

    echo "📚 Installing dependencies..."
    npm ci --production

    echo "📦 Checking PM2..."
    if ! command -v pm2 &> /dev/null; then
        echo "Installing PM2..."
        sudo npm install -g pm2
    fi

    echo "♻️  Restarting application with PM2..."
    if pm2 list | grep -q "my-career-site"; then
        pm2 restart ecosystem.config.js
    else
        pm2 start ecosystem.config.js
        pm2 save

        # Configure PM2 startup
        echo "Configuring PM2 startup..."
        pm2 startup systemd -u bitnami --hp /home/bitnami | tail -n 1 > /tmp/pm2-startup.sh
        if grep -q "sudo" /tmp/pm2-startup.sh; then
            echo "⚠️  PM2 startup requires sudo. Run this on the server:"
            cat /tmp/pm2-startup.sh
        fi
    fi

    echo ""
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
