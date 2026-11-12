#!/bin/bash
# ==============================================================================
# Xpredict - Automated AWS EC2 Deployment Script for Leantime
# Supports: Ubuntu 22.04 / 24.04 LTS, Debian, Amazon Linux 2023
# ==============================================================================

set -e

echo "=================================================================="
echo " Starting Xpredict PM (Leantime) Deployment on AWS EC2"
echo "=================================================================="

# 1. Prompt for Custom Port (defaults to 9000 if empty)
read -p "Enter custom port number to run on [default: 9000]: " CUSTOM_PORT
CUSTOM_PORT=${CUSTOM_PORT:-9000}

# 2. Detect Public IP
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || curl -s ifconfig.me 2>/dev/null || echo "localhost")
read -p "Enter your Domain or Server IP [default: http://$PUBLIC_IP:$CUSTOM_PORT]: " APP_URL
APP_URL=${APP_URL:-http://$PUBLIC_IP:$CUSTOM_PORT}

echo ""
echo "Deploying with configuration:"
echo " - Custom Port : $CUSTOM_PORT"
echo " - App Base URL: $APP_URL"
echo "------------------------------------------------------------------"

# 3. Check and Install Docker if not present
if ! command -v docker &> /dev/null; then
    echo "[*] Installing Docker and Docker Compose plugin..."
    sudo apt-get update -y
    sudo apt-get install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker $USER
    echo "[+] Docker installed successfully!"
fi

# 4. Generate Random Passwords for MySQL & Session
ROOT_PASSWORD=$(openssl rand -hex 16 2>/dev/null || echo "xpredict_root_pwd")
DB_PASSWORD=$(openssl rand -hex 16 2>/dev/null || echo "xpredict_db_secret")
SESSION_PWD=$(openssl rand -hex 24 2>/dev/null || echo "xpredict_session_token")

# 5. Write AWS-ready .docker/.env
mkdir -p .docker
cat <<EOF > .docker/.env
# MySQL database settings
MYSQL_ROOT_PASSWORD=$ROOT_PASSWORD
MYSQL_DATABASE=leantime
MYSQL_USER=leantime
MYSQL_PASSWORD=$DB_PASSWORD

# Leantime connection settings
LEAN_DB_HOST=leantime_db
LEAN_DB_USER=leantime
LEAN_DB_PASSWORD=$DB_PASSWORD
LEAN_DB_DATABASE=leantime
LEAN_DB_PORT=3306

# App settings
LEAN_PORT=$CUSTOM_PORT
LEAN_APP_URL=$APP_URL
LEAN_SITENAME=Xpredict
LEAN_DEBUG=0
LEAN_SESSION_PASSWORD=$SESSION_PWD
EOF

echo "[+] Created production .docker/.env file"

# 6. Launch Docker Containers
echo "[*] Starting containers via Docker Compose..."
docker compose -f .docker/docker-compose.yml up -d --force-recreate

echo ""
echo "=================================================================="
echo " Xpredict PM is successfully deployed and running!"
echo ""
echo " Access URL : $APP_URL"
echo " Custom Port: $CUSTOM_PORT"
echo ""
echo " IMPORTANT AWS NOTE:"
echo " Ensure your AWS EC2 Security Group allows INBOUND traffic on:"
echo "   Type: Custom TCP"
echo "   Port: $CUSTOM_PORT"
echo "   Source: Anywhere (0.0.0.0/0) or your IP"
echo "=================================================================="

