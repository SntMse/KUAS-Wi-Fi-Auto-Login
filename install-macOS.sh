#!/bin/bash

# -------------------------------------------------------------
# Installer for KUAS Wi-Fi Auto Login Script
# Created by Shintaro Muraseh (SntMse)
# v1.6 (Added CNA popup disable & Bilingual support)
# -------------------------------------------------------------

# 1. Determine terminal language for localization (Default: English, Japanese if LANG starts with ja)
if [[ "$LANG" == ja* ]]; then
    LANG_JP=true
else
    LANG_JP=false
fi

# 2. Localize output messages
if [ "$LANG_JP" = true ]; then
    MSG_START="KUAS Wi-Fi自動ログイン (macOS版) のインストールを開始します..."
    MSG_PROMPT_USER="KUASの学籍番号（例: 2021m634）を入力してください: "
    MSG_PROMPT_PASS="パスワードを入力してください: "
    MSG_WIFI="Wi-Fi接続設定をMacに追加しています... (Macのパスワードを求められる場合があります)"
    MSG_CNA="バックグラウンド認証のため、Wi-Fi自動ログインポップアップ（CNA）を無効化しています..."
    MSG_SUCCESS="インストールと設定が正常に完了しました！"
    MSG_UPDATE="※認証情報を変更したい場合は、再度このスクリプト(./install-macOS.sh)を実行してください。"
else
    MSG_START="Starting installation for KUAS Wi-Fi Auto Login (macOS)..."
    MSG_PROMPT_USER="Enter your KUAS Student ID (e.g., 2021m634): "
    MSG_PROMPT_PASS="Enter your password: "
    MSG_WIFI="Adding KUAS Wi-Fi profiles to your Mac... (You may be prompted for your Mac's administrator password)"
    MSG_CNA="Disabling Wi-Fi auto-login popups (CNA) for background authentication..."
    MSG_SUCCESS="Installation and setup completed successfully!"
    MSG_UPDATE="* To update your credentials, simply run this script (./install-macOS.sh) again."
fi

echo "$MSG_START"
echo ""

# 3. Add Wi-Fi Profiles to macOS Keychain
echo "$MSG_WIFI"
# Find the Wi-Fi interface (usually en0)
WIFI_INT=$(networksetup -listallhardwareports | awk '/Hardware Port: Wi-Fi/{getline; print $2}')
if [ -n "$WIFI_INT" ]; then
    # Add kuas-wlan (Index 0: Highest priority)
    networksetup -addpreferredwirelessnetworkatindex "$WIFI_INT" "kuas-wlan" 0 WPA2 "Kyotosentan2019" > /dev/null 2>&1
    
    # Add kuas-fclan (Index 1)
    networksetup -addpreferredwirelessnetworkatindex "$WIFI_INT" "kuas-fclan" 1 WPA2 "kuasfuturecenter2022" > /dev/null 2>&1
    
    # Add kuas-guest (Index 2)
    networksetup -addpreferredwirelessnetworkatindex "$WIFI_INT" "kuas-guest" 2 WPA2 "kuas2022" > /dev/null 2>&1
    
    # Add oick-lan (Index 3)
    networksetup -addpreferredwirelessnetworkatindex "$WIFI_INT" "oick-lan" 3 WPA2 "oick2022" > /dev/null 2>&1
fi
echo ""

# 4. Disable Captive Network Assistant popup globally to prevent background interference
echo "$MSG_CNA"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.captive.control Active -boolean false
echo ""

# 5. Prompt user for credentials interactively
read -p "$MSG_PROMPT_USER" KUAS_USER
read -s -p "$MSG_PROMPT_PASS" KUAS_PASS
echo ""
echo ""

# Define paths
USER_HOME=$HOME
SCRIPT_DIR="$USER_HOME/.local/bin"
SCRIPT_PATH="$SCRIPT_DIR/SntMse-KUAS-Wi-Fi-Auto-Login"
PLIST_PATH="$USER_HOME/Library/LaunchAgents/com.sntmse.kuas.wifi.autologin.plist"
CONF_PATH="$USER_HOME/.kuas_wifi.conf"

# 6. Save credentials securely to a hidden config file
echo "KUAS_USER=\"$KUAS_USER\"" > "$CONF_PATH"
echo "KUAS_PASS=\"$KUAS_PASS\"" >> "$CONF_PATH"
chmod 600 "$CONF_PATH" # Restrict read/write access to the owner only

# 7. Create directory and place the script
mkdir -p "$SCRIPT_DIR"
cp ./kuas_wifi_macos.sh "$SCRIPT_PATH"
chmod +x "$SCRIPT_PATH"

# 8. Generate the launchd plist file dynamically
cat << EOF > "$PLIST_PATH"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.sntmse.kuas.wifi.autologin</string>
    <key>ProgramArguments</key>
    <array>
        <string>$SCRIPT_PATH</string>
    </array>
    <key>StartInterval</key>
    <integer>300</integer>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF

# 9. Register the job with macOS launchd
launchctl unload "$PLIST_PATH" 2>/dev/null
launchctl load "$PLIST_PATH"

echo "========================================================"
echo "$MSG_SUCCESS"
echo "$MSG_UPDATE"
echo "========================================================"
