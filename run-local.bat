@echo off
cd /d "%~dp0"
echo ========================================================
echo Starting Leantime Locally (http://localhost:8080)...
echo ========================================================
docker compose -f .docker/docker-compose.yml up -d

echo.
echo Opening browser to http://localhost:8080...
start http://localhost:8080
echo Leantime is running!
pause

