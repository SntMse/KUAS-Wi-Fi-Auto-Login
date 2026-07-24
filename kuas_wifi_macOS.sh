#!/bin/bash

# -------------------------------------------------------------
# KUAS Wi-Fi Auto Login Script for macOS
# Created by Shintaro Muraseh (SntMse)
# vm1.11 (Fixed login messages & Secure POST)
# -------------------------------------------------------------

# 1. Determine system language
if [[ "$LANG" == ja* ]] || [[ "$(defaults read -g AppleLocale 2>/dev/null)" == *"ja"* ]]; then
    LANG_JP=true
else
    LANG_JP=false
fi

# 2. Localize output messages
if [ "$LANG_JP" = true ]; then
    MSG_ALREADY_CONN="すでにインターネットに接続されています。"
    MSG_LOGGING_IN="KUAS Wi-Fiの認証画面を検出しました。ログインしています..."
    MSG_LOGGING_IN_LIB="図書館本館の認証情報で再試行しています..."
    MSG_OUT_OF_RANGE="KUAS Wi-Fi圏外、または他のネットワークにいます。"
    NOTIFY_TITLE="SntMse KUAS Wi-Fi自動ログイン"
    NOTIFY_MSG_SUCCESS="KUAS Wi-Fiに自動ログインしました。"
    NOTIFY_MSG_SUCCESS_LIB="図書館本館のWi-Fiに自動ログインしました。"
    NOTIFY_MSG_FAIL="認証に失敗しました。パスワードを確認してください。"
else
    MSG_ALREADY_CONN="Already connected to the internet."
    MSG_LOGGING_IN="KUAS Captive Portal detected. Logging in..."
    MSG_LOGGING_IN_LIB="Retrying with Main Library credentials..."
    MSG_OUT_OF_RANGE="Out of KUAS Wi-Fi range or on another network."
    NOTIFY_TITLE="SntMse KUAS Wi-Fi Auto Login"
    NOTIFY_MSG_SUCCESS="Automatically logged in to KUAS Wi-Fi."
    NOTIFY_MSG_SUCCESS_LIB="Automatically logged in to Main Library Wi-Fi."
    NOTIFY_MSG_FAIL="Authentication failed. Please check your credentials."
fi

# 3. Load credentials
CONF_PATH="$HOME/.kuas_wifi.conf"
if [ -f "$CONF_PATH" ]; then
    source "$CONF_PATH"
else
    exit 1
fi

# =============================================================
# 4. Step 1: 完全にインターネットに繋がっているか確認
# =============================================================
if curl -s -m 3 http://captive.apple.com/hotspot-detect.html | grep -q "Success"; then
    echo "$MSG_ALREADY_CONN"
    exit 0
fi

# =============================================================
# 5. Step 2: KUASのログインサーバーが見えるかテスト
# =============================================================
KUAS_STATUS=$(curl -s -m 3 -o /dev/null -w "%{http_code}" https://uzwlan03.kuas.ac.jp/auth/index.html/u)

# ★修正ポイント: 200(OK)だけでなく、302や303(リダイレクト)も許可する
if [[ "$KUAS_STATUS" == "200" || "$KUAS_STATUS" == "302" || "$KUAS_STATUS" == "303" ]]; then
    
    echo "$MSG_LOGGING_IN"
    
    # メインの学籍番号でログイン実行
    # プロセス一覧(ps)へのパスワード露出を防ぐため、標準入力(stdin)から渡す
    curl -X POST "https://uzwlan03.kuas.ac.jp/auth/index.html/u" \
         -d @- \
         -s -o /dev/null <<< "user=${KUAS_USER}&password=${KUAS_PASS}"
         
    sleep 3
    
    # ログイン成功判定
    if curl -s -m 3 http://captive.apple.com/hotspot-detect.html | grep -q "Success"; then
        osascript -e "display notification \"$NOTIFY_MSG_SUCCESS\" with title \"$NOTIFY_TITLE\""
    else
        # 失敗した場合は図書館用でフォールバック
        echo "$MSG_LOGGING_IN_LIB"
        
        # こちらも同様に標準入力(stdin)から渡す
        curl -X POST "https://uzwlan03.kuas.ac.jp/auth/index.html/u" \
             -d @- \
             -s -o /dev/null <<< "user=libwifi&password=Kuaslib2023"
             
        sleep 3
        
        if curl -s -m 3 http://captive.apple.com/hotspot-detect.html | grep -q "Success"; then
            osascript -e "display notification \"$NOTIFY_MSG_SUCCESS_LIB\" with title \"$NOTIFY_TITLE\""
        else
            osascript -e "display notification \"$NOTIFY_MSG_FAIL\" with title \"$NOTIFY_TITLE\" sound name \"Basso\""
        fi
    fi

else
    echo "$MSG_OUT_OF_RANGE"
fi
