#!/bin/bash

# -------------------------------------------------------------
# KUAS Wi-Fi Auto Login Script for macOS
# Created by Shintaro Muraseh (SntMse)
# v1.3
# -------------------------------------------------------------

# 1. Determine system language for localization
if [[ "$LANG" == ja* ]] || [[ "$(defaults read -g AppleLocale 2>/dev/null)" == *"ja"* ]]; then
    LANG_JP=true
else
    LANG_JP=false
fi

# 2. Localize output and notification messages
if [ "$LANG_JP" = true ]; then
    MSG_ALREADY_CONN="すでにインターネットに接続されています。"
    MSG_LOGGING_IN="KUAS Wi-Fiにログインしています..."
    MSG_LOGGING_IN_LIB="図書館本館の認証情報で再試行しています..."
    MSG_NOT_CONN="kuas-wlanに接続されていません。現在のSSID: "
    MSG_NO_WIFI="現在どのWi-Fiネットワークにも接続されていません。"
    NOTIFY_TITLE="SntMse KUAS Wi-Fi自動化ログイン"
    NOTIFY_MSG_SUCCESS="KUAS Wi-Fiに自動ログインしました。"
    NOTIFY_MSG_SUCCESS_LIB="図書館のWi-Fiに自動ログインしました。"
    NOTIFY_MSG_FAIL="認証に失敗しました。パスワードを確認してください。"
else
    MSG_ALREADY_CONN="Already connected to the internet."
    MSG_LOGGING_IN="Logging in to KUAS Wi-Fi..."
    MSG_LOGGING_IN_LIB="Retrying with Main Library credentials..."
    MSG_NOT_CONN="Not connected to kuas-wlan. Current SSID: "
    MSG_NO_WIFI="You are not connected to any Wi-Fi network."
    NOTIFY_TITLE="SntMse KUAS Wi-Fi Auto Login"
    NOTIFY_MSG_SUCCESS="Automatically logged in to KUAS Wi-Fi."
    NOTIFY_MSG_SUCCESS_LIB="Automatically logged in to Library Wi-Fi."
    NOTIFY_MSG_FAIL="Authentication failed. Please check your credentials."
fi

# 3. Load credentials from the secure config file
CONF_PATH="$HOME/.kuas_wifi.conf"
if [ -f "$CONF_PATH" ]; then
    source "$CONF_PATH"
else
    exit 1
fi

# =============================================================
# Function to check internet connectivity (HTTP instead of Ping)
# =============================================================
check_internet() {
    # Send request to Apple's Captive Portal Check URL (Max time: 3 seconds)
    local response=$(curl -s -m 3 http://captive.apple.com/hotspot-detect.html)
    
    # If the response contains the word "Success", we have full internet access.
    # If it returns HTML for the university's login page, it won't contain "Success".
    if [[ "$response" == *"Success"* ]]; then
        return 0 # Connected
    else
        return 1 # Not connected (or intercepted by captive portal)
    fi
}

# 4. Dynamically find the Wi-Fi interface (en0, en1, etc.)
WIFI_INT=$(networksetup -listallhardwareports | awk '/Hardware Port: Wi-Fi/{getline; print $2}')

# 5. Get the current Wi-Fi network name (SSID) securely
# コロンとそれに続くスペースを区切り文字として、確実にSSID名だけを抽出する
SSID=$(networksetup -getairportnetwork "$WIFI_INT" | awk -F": *" '{print $2}')

# 6. Check if connected to KUAS Wi-Fi
if [ "$SSID" = "kuas-wlan" ]; then
    
    # 7. Check initial internet connectivity
    if check_internet; then
        echo "$MSG_ALREADY_CONN"
    else
        # 8. First Attempt: Use Personal Credentials
        echo "$MSG_LOGGING_IN"
        curl -X POST "https://uzwlan03.kuas.ac.jp/auth/index.html/u" \
             -d "user=${KUAS_USER}" \
             -d "password=${KUAS_PASS}" \
             -s -o /dev/null
             
        # Wait for network to stabilize
        sleep 3
        
        # 9. Check if First Attempt was successful
        if check_internet; then
            osascript -e "display notification \"$NOTIFY_MSG_SUCCESS\" with title \"$NOTIFY_TITLE\""
        else
            # 10. Second Attempt: Fallback to Library Credentials
            echo "$MSG_LOGGING_IN_LIB"
            curl -X POST "https://uzwlan03.kuas.ac.jp/auth/index.html/u" \
                 -d "user=libwifi" \
                 -d "password=Kuaslib2023" \
                 -s -o /dev/null
                 
            # Wait again
            sleep 3
            
            # 11. Final Check
            if check_internet; then
                # Success in Library
                osascript -e "display notification \"$NOTIFY_MSG_SUCCESS_LIB\" with title \"$NOTIFY_TITLE\""
            else
                # Completely Failed
                osascript -e "display notification \"$NOTIFY_MSG_FAIL\" with title \"$NOTIFY_TITLE\" sound name \"Basso\""
            fi
        fi
    fi
else
    # 接続されていない場合と、別のWi-Fiにいる場合で出力を分ける
    if [ -z "$SSID" ]; then
        echo "$MSG_NO_WIFI"
    else
        echo "${MSG_NOT_CONN}${SSID}"
    fi
fi
