#!/bin/bash

# -------------------------------------------------------------
# Installer for KUAS Wi-Fi Auto Login Script
# Created by Shintaro Muraseh (SntMse)
# v1.2
# -------------------------------------------------------------

# 1. Determine terminal language for localization
if [[ "$LANG" == ja* ]]; then
    LANG_JP=true
else
    LANG_JP=false
fi

# 2. Localize output messages
if [ "$LANG_JP" = true ]; then
    MSG_START="KUAS Wi-Fi 自動ログイン (macOS版) のインストールを開始します..."
    MSG_PROMPT_USER="KUASの学籍番号（例: 2021m634）を入力してください: "
    MSG_PROMPT_PASS="パスワードを入力してください: "
    MSG_WIFI="kuas-wlan のWi-Fi接続設定をMacに追加しています... (Macのパスワードを求められる場合があります)"
    MSG_SUCCESS="インストールと設定が正常に完了しました！"
    MSG_UPDATE="※認証情報を変更したい場合は、再度このスクリプト(./install-macOS.sh)を実行してください。"
else
    MSG_START="Starting installation for KUAS Wi-Fi Auto Login (macOS)..."
    MSG_PROMPT_USER="Enter your KUAS Student ID (e.g., 2021m634): "
    MSG_PROMPT_PASS="Enter your password: "
    MSG_WIFI="Adding kuas-wlan Wi-Fi profile to your Mac... (You may be prompted for your Mac's administrator password)"
    MSG_SUCCESS="Installation and setup completed successfully!"
    MSG_UPDATE="* To update your credentials, simply run this script (./install-macOS.sh) again."
fi

echo "$MSG_START"
echo ""

# 3. Add Wi-Fi Profile to macOS Keychain
echo "$MSG_WIFI"
# Find the Wi-Fi interface (usually en0)
WIFI_INT=$(networksetup -listallhardwareports | awk '/Hardware Port: Wi-Fi/{getline; print $2}')
if [ -n "$WIFI_INT" ]; then
    # Add kuas-wlan to preferred networks with the shared password
    networksetup -addpreferredwirelessnetworkatindex "$WIFI_INT" "kuas-wlan" 0 WPA2 "Kyotosentan2019" > /dev/null 2>&1
fi
echo ""

# 4. Prompt user for credentials interactively
read -p "$MSG_PROMPT_USER" KUAS_USER
read -s -p "$MSG_PROMPT_PASS" KUAS_PASS
echo ""
echo ""

# Define paths
USER_HOME=$HOME
SCRIPT_DIR="$USER_HOME/.local/bin"
SCRIPT_PATH="$SCRIPT_DIR/kuas_wifi_macos.sh"
PLIST_PATH="$USER_HOME/Library/LaunchAgents/com.sntmse.kuas.wifi.autologin.plist"
CONF_PATH="$USER_HOME/.kuas_wifi.conf"

# 5. Save credentials securely to a hidden config file
echo "KUAS_USER=\"$KUAS_USER\"" > "$CONF_PATH"
echo "KUAS_PASS=\"$KUAS_PASS\"" >> "$CONF_PATH"
chmod 600 "$CONF_PATH" # Restrict read/write access to the owner only

# 6. Create directory and place the script
mkdir -p "$SCRIPT_DIR"
cp ./kuas_wifi_macos.sh "$SCRIPT_PATH"
chmod +x "$SCRIPT_PATH"

# 7. Generate the launchd plist file dynamically
cat << EOF > "$PLIST_PATH"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.sntmse.kuas.wifi.autologin</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$SCRIPT_PATH</string>
    </array>
    <key>StartInterval</key>
    <integer>300</integer>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF

# 8. Register the job with macOS launchd
# Unload first to prevent errors if it is already registered
launchctl unload "$PLIST_PATH" 2>/dev/null
launchctl load "$PLIST_PATH"

echo "========================================================"
echo "$MSG_SUCCESS"
echo "$MSG_UPDATE"
echo "========================================================"
