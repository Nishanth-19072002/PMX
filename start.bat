@echo off
cd /d "%~dp0"
echo ========================================================
echo Starting Leantime Containers...
echo ========================================================
docker compose -f .docker/docker-compose.yml up -d

echo.
echo ========================================================
echo Starting Cloudflare Tunnel...
echo Look below for your public "https://....trycloudflare.com" link!
echo (Keep this window open while testing; press Ctrl+C to stop)
echo ========================================================
.\cloudflared.exe tunnel --url http://localhost:8080
pause

