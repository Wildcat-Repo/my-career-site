#!/bin/bash
set -e

# Script to configure Nginx for blountforceautomation.com
# Run this after updating DNS to point to Lightsail

echo "🌐 Setting up Nginx for blountforceautomation.com..."

# Configuration
LIGHTSAIL_IP="44.235.108.165"
LIGHTSAIL_USER="bitnami"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SSH_KEY="$PROJECT_DIR/.aws/LightsailDefaultKey-us-west-2.pem"
NGINX_CONF="$PROJECT_DIR/nginx/blountforceautomation.com.conf"

# Check if SSH key exists
if [ ! -f "$SSH_KEY" ]; then
    echo "❌ Error: SSH key not found at $SSH_KEY"
    exit 1
fi

# Check if Nginx config exists
if [ ! -f "$NGINX_CONF" ]; then
    echo "❌ Error: Nginx config not found at $NGINX_CONF"
    exit 1
fi

chmod 400 "$SSH_KEY"

echo "📋 Copying Nginx configuration to server..."
scp -i "$SSH_KEY" -o StrictHostKeyChecking=no \
    "$NGINX_CONF" \
    "$LIGHTSAIL_USER@$LIGHTSAIL_IP:/tmp/blountforceautomation.com.conf"

echo "🔧 Installing configuration and restarting Nginx..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$LIGHTSAIL_USER@$LIGHTSAIL_IP" << 'ENDSSH'
    # Move config to server_blocks
    sudo mv /tmp/blountforceautomation.com.conf \
           /opt/bitnami/nginx/conf/server_blocks/blountforceautomation.com.conf

    # Set correct permissions
    sudo chown root:root /opt/bitnami/nginx/conf/server_blocks/blountforceautomation.com.conf
    sudo chmod 644 /opt/bitnami/nginx/conf/server_blocks/blountforceautomation.com.conf

    # Test Nginx configuration
    echo "🧪 Testing Nginx configuration..."
    sudo /opt/bitnami/nginx/sbin/nginx -t

    # Restart Nginx
    echo "♻️  Restarting Nginx..."
    sudo /opt/bitnami/ctlscript.sh restart nginx

    echo "✅ Nginx configuration applied successfully!"
ENDSSH

echo ""
echo "✅ Nginx setup completed!"
echo ""
echo "🌐 Your site should be accessible at:"
echo "   http://blountforceautomation.com"
echo "   http://www.blountforceautomation.com"
echo ""
echo "⏰ Note: DNS changes may take 5-60 minutes to propagate"
echo ""
echo "🔒 To add SSL/HTTPS, follow the instructions in DEPLOYMENT.md"
