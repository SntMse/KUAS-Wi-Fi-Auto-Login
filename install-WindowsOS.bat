@echo off
chcp 65001 >nul
title KUAS Wi-Fi Auto Login Installer
echo KUAS Wi-Fi自動ログイン (Windows版) のインストーラーを起動しています...

:: PowerShellをセキュリティ制限を無視して起動し、インストーラーを呼び出す
powershell -NoProfile -ExecutionPolicy Bypass -Command "& '%~dp0install-WindowsOS.ps1'"

pause
