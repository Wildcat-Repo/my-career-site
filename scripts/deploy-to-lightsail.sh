#!/bin/bash
set -e

# Local deployment script for triggering deployment to AWS Lightsail
# Run this from your local machine to deploy to Lightsail

echo "🚀 Deploying my-career-site to AWS Lightsail..."

# Configuration
LIGHTSAIL_IP="44.235.108.165"
LIGHTSAIL_USER="bitnami"
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
    # Download and execute deployment script
    curl -sSL https://git.gondoberg.com/PaddedWalls/my-career-site/raw/branch/main/scripts/deploy.sh -o /tmp/deploy.sh
    chmod +x /tmp/deploy.sh
    bash /tmp/deploy.sh
ENDSSH

echo ""
echo "✅ Deployment completed!"
echo "🌐 Your site should be accessible at: http://$LIGHTSAIL_IP:3000"
echo ""
echo "📊 To check application status:"
echo "   ssh -i $SSH_KEY $LIGHTSAIL_USER@$LIGHTSAIL_IP 'pm2 status'"
echo ""
echo "📋 To view logs:"
echo "   ssh -i $SSH_KEY $LIGHTSAIL_USER@$LIGHTSAIL_IP 'pm2 logs my-career-site'"
