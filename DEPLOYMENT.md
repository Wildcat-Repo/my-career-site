# Deployment Guide - AWS Lightsail

This document describes how to deploy the My Career Site to AWS Lightsail.

## Table of Contents

- [Server Information](#server-information)
- [Prerequisites](#prerequisites)
- [Initial Setup](#initial-setup)
- [Deployment Methods](#deployment-methods)
- [Nginx Configuration](#nginx-configuration)
- [Monitoring and Maintenance](#monitoring-and-maintenance)
- [Troubleshooting](#troubleshooting)

---

## Server Information

**Instance Details:**
- **Platform:** AWS Lightsail
- **OS:** Debian 6.1.0 (Bitnami Nginx Stack)
- **Static IP:** 44.235.108.165
- **IPv6:** 2600:1f13:63d:7500:c175:6f68:999c:40b3
- **SSH User:** bitnami
- **SSH Key:** ~/.aws/LightsailDefaultKey-us-west-2.pem

**Application:**
- **Port:** 3000
- **Directory:** /home/bitnami/apps/my-career-site
- **Process Manager:** PM2
- **Web Server:** Nginx (reverse proxy)

---

## Prerequisites

### On Your Local Machine

1. **SSH Key Access**
   ```bash
   # Ensure your SSH key has correct permissions
   chmod 400 ~/.aws/LightsailDefaultKey-us-west-2.pem
   ```

2. **Git Access**
   - Ensure you can push to the repository
   - Repository: https://github.com/PaddedWalls/my-career-site.git

### On the Lightsail Instance

SSH into the instance:
```bash
ssh -i ~/.aws/LightsailDefaultKey-us-west-2.pem bitnami@44.235.108.165
```

1. **Install Node.js (if not already installed)**
   ```bash
   # Install Node.js v20 (LTS)
   curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
   sudo apt-get install -y nodejs

   # Verify installation
   node --version
   npm --version
   ```

2. **Install PM2 Globally**
   ```bash
   sudo npm install -g pm2
   ```

3. **Configure Git (if not already done)**
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

4. **Create Application Directory**
   ```bash
   mkdir -p /home/bitnami/apps
   ```

---

## Initial Setup

### 1. First-Time Deployment

Run the local deployment script:
```bash
./scripts/deploy-to-lightsail.sh
```

Or manually SSH and deploy:
```bash
ssh -i ~/.aws/LightsailDefaultKey-us-west-2.pem bitnami@44.235.108.165

# On the server:
cd /home/bitnami/apps
git clone https://git.gondoberg.com/PaddedWalls/my-career-site.git
cd my-career-site
npm ci --production
pm2 start ecosystem.config.js
pm2 save
pm2 startup systemd -u bitnami --hp /home/bitnami
```

### 2. Configure Nginx

Copy the Nginx configuration:
```bash
# On the Lightsail instance:
sudo cp /home/bitnami/apps/my-career-site/nginx/my-career-site.conf \
        /opt/bitnami/nginx/conf/server_blocks/

# Test Nginx configuration
sudo /opt/bitnami/nginx/sbin/nginx -t

# Restart Nginx
sudo /opt/bitnami/ctlscript.sh restart nginx
```

### 3. Configure Firewall

Ensure port 3000 is accessible (if accessing directly):
```bash
# Check current rules
sudo iptables -L

# Open port 3000 (if needed for direct access)
sudo iptables -A INPUT -p tcp --dport 3000 -j ACCEPT
```

Note: If using Nginx as reverse proxy, you only need port 80 (and 443 for HTTPS) open.

---

## Deployment Methods

### Method 1: Automated Deployment (Recommended)

**Via Gitea Actions (Automatic on Push to Main):**

1. Push your code to the `main` branch
2. Gitea Actions automatically triggers deployment
3. Monitor deployment in Gitea Actions dashboard

**Manual Trigger:**
- Go to Actions tab in Gitea
- Click "Run workflow" on the Deploy workflow

**Setup Required:**
Configure these secrets in Gitea repository settings:
- `LIGHTSAIL_SSH_KEY`: Contents of ~/.aws/LightsailDefaultKey-us-west-2.pem
- `LIGHTSAIL_IP`: 44.235.108.165
- `LIGHTSAIL_USER`: bitnami

### Method 2: Manual Deployment Script

From your local machine:
```bash
./scripts/deploy-to-lightsail.sh
```

This script will:
1. SSH into the Lightsail instance
2. Pull the latest code from Git
3. Install dependencies
4. Restart the application with PM2

### Method 3: Manual Deployment

SSH to the server and deploy manually:
```bash
ssh -i ~/.aws/LightsailDefaultKey-us-west-2.pem bitnami@44.235.108.165

cd /home/bitnami/apps/my-career-site
git pull origin main
npm ci --production
pm2 restart ecosystem.config.js
```

---

## Nginx Configuration

### Current Setup

The application runs on port 3000 and Nginx proxies requests to it.

**Access URLs:**
- Direct: http://44.235.108.165:3000
- Via Nginx: http://44.235.108.165 (after Nginx config is applied)

### Update Nginx Configuration

If you modify `nginx/my-career-site.conf`:

```bash
# On Lightsail instance:
sudo cp /home/bitnami/apps/my-career-site/nginx/my-career-site.conf \
        /opt/bitnami/nginx/conf/server_blocks/

# Test configuration
sudo /opt/bitnami/nginx/sbin/nginx -t

# Apply changes
sudo /opt/bitnami/ctlscript.sh restart nginx
```

### Add SSL/HTTPS (Future)

1. Obtain SSL certificate (Let's Encrypt recommended)
2. Update Nginx configuration to enable HTTPS section
3. Configure automatic renewal

---

## Monitoring and Maintenance

### Check Application Status

```bash
# PM2 status
pm2 status

# View logs
pm2 logs my-career-site

# View last 100 lines
pm2 logs my-career-site --lines 100

# Monitor in real-time
pm2 monit
```

### Log Files

- **PM2 Logs:** /home/bitnami/apps/my-career-site/logs/
  - `out.log` - Standard output
  - `err.log` - Error output
  - `combined.log` - Combined logs

- **Nginx Logs:** /opt/bitnami/nginx/logs/
  - `my-career-site-access.log`
  - `my-career-site-error.log`

### Common PM2 Commands

```bash
# Restart application
pm2 restart my-career-site

# Stop application
pm2 stop my-career-site

# Start application
pm2 start ecosystem.config.js

# Delete from PM2
pm2 delete my-career-site

# View detailed info
pm2 info my-career-site

# Clear logs
pm2 flush

# Save PM2 process list
pm2 save
```

### System Resources

```bash
# Check memory usage
free -h

# Check disk space
df -h

# Check running processes
ps aux | grep node

# Check port usage
sudo lsof -i :3000
```

---

## Troubleshooting

### Application Won't Start

**Check PM2 logs:**
```bash
pm2 logs my-career-site --err
```

**Common issues:**
- Port 3000 already in use
- Missing dependencies
- Incorrect file permissions

**Solutions:**
```bash
# Kill process on port 3000
sudo lsof -ti:3000 | xargs kill -9

# Reinstall dependencies
cd /home/bitnami/apps/my-career-site
rm -rf node_modules
npm ci --production

# Check permissions
ls -la /home/bitnami/apps/my-career-site
```

### Nginx Issues

**Test configuration:**
```bash
sudo /opt/bitnami/nginx/sbin/nginx -t
```

**View error logs:**
```bash
sudo tail -f /opt/bitnami/nginx/logs/error.log
```

**Restart Nginx:**
```bash
sudo /opt/bitnami/ctlscript.sh restart nginx
```

### Deployment Fails

**Check Git access:**
```bash
cd /home/bitnami/apps/my-career-site
git fetch origin
```

**Check Node.js version:**
```bash
node --version  # Should be v18+ or v20+
```

**Check npm permissions:**
```bash
npm config get prefix
# Should be /usr or /usr/local
```

### Can't SSH to Server

**Verify SSH key:**
```bash
ls -la ~/.aws/LightsailDefaultKey-us-west-2.pem
chmod 400 ~/.aws/LightsailDefaultKey-us-west-2.pem
```

**Test connection:**
```bash
ssh -v -i ~/.aws/LightsailDefaultKey-us-west-2.pem bitnami@44.235.108.165
```

**Check Lightsail firewall:**
- Log into AWS Lightsail Console
- Check instance firewall rules
- Ensure SSH (port 22) is allowed

### Application Crashes

**Check PM2 for restart count:**
```bash
pm2 status
```

**View error logs:**
```bash
pm2 logs my-career-site --err --lines 50
```

**Increase memory limit (if needed):**
Edit `ecosystem.config.js`:
```javascript
max_memory_restart: '500M'  // Increase from 200M
```

Then restart:
```bash
pm2 restart ecosystem.config.js
```

---

## Performance Optimization

### Enable Nginx Caching

Already configured in `nginx/my-career-site.conf`:
- Static assets cached for 1 day
- Gzip compression enabled

### PM2 Cluster Mode (Future)

For high traffic, enable cluster mode:

Edit `ecosystem.config.js`:
```javascript
instances: 'max',  // Use all CPU cores
exec_mode: 'cluster'
```

---

## Security Best Practices

1. **Keep system updated:**
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

2. **Restrict SSH access** (configure in Lightsail console)

3. **Use HTTPS** when possible

4. **Regular backups** of application and data

5. **Monitor logs** for suspicious activity

---

## Quick Reference

**Common Tasks:**

| Task | Command |
|------|---------|
| Deploy latest code | `./scripts/deploy-to-lightsail.sh` |
| Check app status | `ssh -i ~/.aws/LightsailDefaultKey-us-west-2.pem bitnami@44.235.108.165 'pm2 status'` |
| View logs | `ssh -i ~/.aws/LightsailDefaultKey-us-west-2.pem bitnami@44.235.108.165 'pm2 logs my-career-site'` |
| Restart app | `ssh -i ~/.aws/LightsailDefaultKey-us-west-2.pem bitnami@44.235.108.165 'pm2 restart my-career-site'` |
| Restart Nginx | `ssh -i ~/.aws/LightsailDefaultKey-us-west-2.pem bitnami@44.235.108.165 'sudo /opt/bitnami/ctlscript.sh restart nginx'` |

**Access Points:**
- Direct (Node.js): http://44.235.108.165:3000
- Via Nginx: http://44.235.108.165
- SSH: `ssh -i ~/.aws/LightsailDefaultKey-us-west-2.pem bitnami@44.235.108.165`

---

## Support

For issues or questions:
1. Check this documentation
2. Review application logs
3. Check Gitea Actions logs (for automated deployments)
4. Consult [PM2 Documentation](https://pm2.keymetrics.io/docs/usage/quick-start/)
5. Consult [Bitnami Nginx Documentation](https://docs.bitnami.com/aws/infrastructure/nginx/)
