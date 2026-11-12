@echo off
cd /d "%~dp0"
echo Stopping Leantime Containers...
docker compose -f .docker/docker-compose.yml down
echo Done! Leantime has stopped.
pause

