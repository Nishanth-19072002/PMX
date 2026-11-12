@echo off
cd /d "%~dp0"
echo ========================================================
echo Rebuilding and Restarting Leantime Locally...
echo ========================================================
docker compose -f .docker/docker-compose.yml up -d --force-recreate leantime
echo.
echo Leantime rebuilt and restarted!
echo Opening http://localhost:8080...
start http://localhost:8080
pause

