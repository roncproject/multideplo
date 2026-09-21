#!/bin/sh

# 1. Start Nginx reverse proxy daemon in the background
nginx

# 2. Start App 1 (Hardened Hack Game) in the foreground with Seed 20
# Moved to 'exec' to keep the container alive and expanded memory allocation to a safe 512MB
exec java -Dserver.port=8081 -Xmx512m -jar /app/app1.jar 
