#!/bin/bash
# ==============================================================================
# Xpredict - Automated Nginx Reverse Proxy & SSL Setup for Subdomain
# Usage: sudo ./setup-nginx-ssl.sh pm.xpredictdigital.com 9000
# ==============================================================================

set -e

DOMAIN=$1
PORT=$2

if [ -z "$DOMAIN" ]; then
    read -p "Enter your subdomain (e.g., pm.xpredictdigital.com): " DOMAIN
fi

if [ -z "$PORT" ]; then
    read -p "Enter internal Docker port (e.g., 9000): " PORT
fi

echo "=================================================================="
echo " Configuring Nginx & SSL for: https://$DOMAIN -> 127.0.0.1:$PORT"
echo "=================================================================="

# 1. Install Nginx and Certbot if missing
echo "[*] Ensuring Nginx and Certbot are installed..."
sudo apt-get update -y
sudo apt-get install -y nginx certbot python3-certbot-nginx

# 2. Create Nginx virtual host configuration with WebSocket & Upload support
CONF_FILE="/etc/nginx/sites-available/$DOMAIN.conf"
echo "[*] Creating Nginx configuration at $CONF_FILE..."

sudo bash -c "cat <<EOF > $CONF_FILE
server {
    listen 80;
    server_name $DOMAIN;

    # Maximum file upload size for attachments and logos
    client_max_body_size 100M;

    location / {
        proxy_pass http://127.0.0.1:$PORT;
        proxy_http_version 1.1;

        # Standard headers
        proxy_set_header Host \\\$host;
        proxy_set_header X-Real-IP \\\$remote_addr;
        proxy_set_header X-Forwarded-For \\\$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \\\$scheme;

        # WebSocket & Long-Polling support for live notifications
        proxy_set_header Upgrade \\\$http_upgrade;
        proxy_set_header Connection \"upgrade\";

        # Timeouts for large uploads and long-running reports
        proxy_connect_timeout 300s;
        proxy_send_timeout 300s;
        proxy_read_timeout 300s;
    }
}
EOF"

# 3. Enable site
sudo ln -sf "$CONF_FILE" "/etc/nginx/sites-enabled/$DOMAIN.conf"

# Remove default site if present
if [ -f /etc/nginx/sites-enabled/default ]; then
    sudo rm -f /etc/nginx/sites-enabled/default
fi

# 4. Test and reload Nginx
echo "[*] Testing Nginx configuration..."
sudo nginx -t
sudo systemctl reload nginx
echo "[+] Nginx configured successfully!"

# 5. Run Certbot for Let's Encrypt SSL
echo ""
echo "=================================================================="
echo " Requesting Free SSL Certificate (HTTPS) via Let's Encrypt..."
echo "=================================================================="
sudo certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos --register-unsafely-without-email --redirect || {
    echo ""
    echo "[!] Certbot automated run paused. Running interactive Certbot:"
    sudo certbot --nginx -d "$DOMAIN"
}

echo ""
echo "=================================================================="
echo " SSL & Reverse Proxy Setup Complete!"
echo " Your platform is now securely accessible at:"
echo " 👉 https://$DOMAIN"
echo "=================================================================="

