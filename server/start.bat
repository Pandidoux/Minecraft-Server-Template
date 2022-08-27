@echo off
chcp 65001 > nul
title Minecraft Server

:loop

echo #########################################
echo #####   CTRL+C to stop the script   #####
echo #########################################
timeout /T 10 /NOBREAK
echo ________________________Server Start__________________________
"C:/Program Files/Java/jre1.8.0_341/bin/java.exe" -Xms256M -Xmx4096M -jar "server.jar" nogui
echo ________________________Server Stop__________________________

goto loop
