@echo off
title KUAS Wi-Fi Auto Login Installer
echo Starting KUAS Wi-Fi Auto Login Installer...

powershell -NoProfile -ExecutionPolicy Bypass -Command "& '%~dp0install-WindowsOS-script.ps1'"

pause
