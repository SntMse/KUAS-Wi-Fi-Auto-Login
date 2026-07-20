#!/bin/bash

# -------------------------------------------------------------
# KUAS Wi-Fi Auto Login Script for macOS
# -------------------------------------------------------------

# Check if environment variables are set
if [ -z "$KUAS_USER" ] || [ -z "$KUAS_PASS" ]; then
    echo "Error: KUAS_USER or KUAS_PASS is not set."
    echo "Please set them in your ~/.zshrc or ~/.bash_profile"
    exit 1
fi

# 1. Get the current Wi-Fi network name (SSID)
SSID=$(networksetup -getairportnetwork en0 | awk '{print $4}')

# 2. Check if connected to KUAS Wi-Fi
if [ "$SSID" = "kuas-wlan" ]; then
    
    # 3. Check internet connectivity
    if ping -o -c 3 1.1.1.1 > /dev/null 2>&1; then
        echo "Already connected to the internet."
    else
        echo "Logging in to KUAS Wi-Fi..."
        
        # 4. Send POST request to the authentication server
        curl -X POST "https://uzwlan03.kuas.ac.jp/auth/index.html/u" \
             -d "user=${KUAS_USER}" \
             -d "password=${KUAS_PASS}" \
             -s -o /dev/null
             
        # 5. Display a desktop notification
        osascript -e 'display notification "Automatically logged in to KUAS Wi-Fi." with title "Wi-Fi Automation"'
    fi
else
    echo "Not connected to kuas-wlan. Current SSID: $SSID"
fi
