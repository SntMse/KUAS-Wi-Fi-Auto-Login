#!/bin/bash

# -------------------------------------------------------------
# KUAS Wi-Fi Auto Login Script for macOS
# Created by Shintaro Muraseh (SntMse)
# v1.0
# -------------------------------------------------------------

# 1. Determine system language for localization
# Note: launchd environments might not have $LANG set, so we check AppleLocale as well.
if [[ "$LANG" == ja* ]] || [[ "$(defaults read -g AppleLocale 2>/dev/null)" == *"ja"* ]]; then
    LANG_JP=true
else
    LANG_JP=false
fi

# 2. Localize output and notification messages
if [ "$LANG_JP" = true ]; then
    MSG_ALREADY_CONN="すでにインターネットに接続されています。"
    MSG_LOGGING_IN="KUAS Wi-Fiにログインしています..."
    MSG_NOT_CONN="kuas-wlanに接続されていません。現在のSSID: "
    NOTIFY_TITLE="Wi-Fi 自動化"
    NOTIFY_MSG="KUAS Wi-Fiに自動ログインしました。"
else
    MSG_ALREADY_CONN="Already connected to the internet."
    MSG_LOGGING_IN="Logging in to KUAS Wi-Fi..."
    MSG_NOT_CONN="Not connected to kuas-wlan. Current SSID: "
    NOTIFY_TITLE="Wi-Fi Automation"
    NOTIFY_MSG="Automatically logged in to KUAS Wi-Fi."
fi

# 3. Load credentials from the secure config file
CONF_PATH="$HOME/.kuas_wifi.conf"
if [ -f "$CONF_PATH" ]; then
    source "$CONF_PATH"
else
    # Config missing. Exit silently to avoid background errors.
    exit 1
fi

# 4. Get the current Wi-Fi network name (SSID)
SSID=$(networksetup -getairportnetwork en0 | awk '{print $4}')

# 5. Check if connected to KUAS Wi-Fi
if [ "$SSID" = "kuas-wlan" ]; then
    
    # 6. Check internet connectivity
    if ping -o -c 3 1.1.1.1 > /dev/null 2>&1; then
        echo "$MSG_ALREADY_CONN"
    else
        echo "$MSG_LOGGING_IN"
        
        # 7. Send POST request to the authentication server
        curl -X POST "https://uzwlan03.kuas.ac.jp/auth/index.html/u" \
             -d "user=${KUAS_USER}" \
             -d "password=${KUAS_PASS}" \
             -s -o /dev/null
             
        # 8. Display a localized desktop notification
        osascript -e "display notification \"$NOTIFY_MSG\" with title \"$NOTIFY_TITLE\""
    fi
else
    echo "${MSG_NOT_CONN}${SSID}"
fi
