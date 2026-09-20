#!/bin/sh

# 1. Start Nginx reverse proxy daemon in the background
nginx

# 2. Start App 1 (Hardened Hack Game) in the background with a 384MB memory limit
java -Dserver.port=8081 -Xmx384m -jar /app/app1.jar &

# 3. Start App 2 (Vanilla Web App) in the foreground with a 512MB memory limit
# This blocks container termination so the deployment stays alive on AWS.
exec java -Dserver.port=8082 -Xmx512m -jar /app/app2.jar
