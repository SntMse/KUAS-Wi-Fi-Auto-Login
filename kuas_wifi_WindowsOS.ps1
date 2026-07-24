﻿# -------------------------------------------------------------
# KUAS Wi-Fi Auto Login Script for Windows
# Created by Shintaro Muraseh (SntMse)
# vw1.0 (Windows Native Toast & Secure POST Edition)
# -------------------------------------------------------------

$ErrorActionPreference = "SilentlyContinue"

# 1. Prevent garbled terminal output (UTF-8 encoding)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 2. Localize output messages
$lang = (Get-Culture).TwoLetterISOLanguageName
if ($lang -eq "ja") {
    $MSG_ALREADY_CONN = "すでにインターネットに接続されています。"
    $MSG_LOGGING_IN = "KUAS Wi-Fiの認証画面を検出しました。ログインしています..."
    $MSG_LOGGING_IN_LIB = "図書館本館の認証情報で再試行しています..."
    $MSG_OUT_OF_RANGE = "KUAS Wi-Fi圏外、または他のネットワークにいます。"
    $NOTIFY_TITLE = "SntMse KUAS Wi-Fi自動ログイン"
    $NOTIFY_MSG_SUCCESS = "KUAS Wi-Fiに自動ログインしました。"
    $NOTIFY_MSG_SUCCESS_LIB = "図書館本館のWi-Fiに自動ログインしました。"
    $NOTIFY_MSG_FAIL = "認証に失敗しました。パスワードを確認してください。"
} else {
    $MSG_ALREADY_CONN = "Already connected to the internet."
    $MSG_LOGGING_IN = "KUAS Captive Portal detected. Logging in..."
    $MSG_LOGGING_IN_LIB = "Retrying with Main Library credentials..."
    $MSG_OUT_OF_RANGE = "Out of KUAS Wi-Fi range or on another network."
    $NOTIFY_TITLE = "SntMse KUAS Wi-Fi Auto Login"
    $NOTIFY_MSG_SUCCESS = "Automatically logged in to KUAS Wi-Fi."
    $NOTIFY_MSG_SUCCESS_LIB = "Automatically logged in to Main Library Wi-Fi."
    $NOTIFY_MSG_FAIL = "Authentication failed. Please check your credentials."
}

# --- Windows Native Toast Notification Function ---
function Show-Notification {
    param([string]$Title, [string]$Message)
    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
    $template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)
    $textNodes = $template.GetElementsByTagName("text")
    $textNodes.Item(0).AppendChild($template.CreateTextNode($Title)) | Out-Null
    $textNodes.Item(1).AppendChild($template.CreateTextNode($Message)) | Out-Null
    $toast = [Windows.UI.Notifications.ToastNotification]::new($template)
    $notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("SntMse KUAS Wi-Fi")
    $notifier.Show($toast)
}

# 3. Load credentials
$confPath = "$env:USERPROFILE\.kuas_wifi.conf"
if (-Not (Test-Path $confPath)) { exit 1 }

# Read configuration file
Get-Content $confPath | ForEach-Object {
    if ($_ -match "^KUAS_USER=(.*)$") { $KUAS_USER = $matches[1] }
    if ($_ -match "^KUAS_PASS=(.*)$") { $KUAS_PASS = $matches[1] }
}

# =============================================================
# 4. Step 1: Check if already connected to the internet
# =============================================================
$appleCheck = curl.exe -s -m 3 http://captive.apple.com/hotspot-detect.html
if ($appleCheck -match "Success") {
    Write-Output $MSG_ALREADY_CONN
    exit 0
}

# =============================================================
# 5. Step 2: Test if the KUAS captive portal server is reachable
# =============================================================
$KUAS_STATUS = curl.exe -s -m 3 -o NUL -w "%{http_code}" https://uzwlan03.kuas.ac.jp/auth/index.html/u

# Allow 302/303 (Redirect) along with 200 (OK), similar to macOS
if ($KUAS_STATUS -eq "200" -or $KUAS_STATUS -eq "302" -or $KUAS_STATUS -eq "303") {
    
    Write-Output $MSG_LOGGING_IN
    
    # Execute login with primary student ID (Secure POST via stdin)
    $postData = "user=$KUAS_USER&password=$KUAS_PASS"
    $postData | curl.exe -X POST "https://uzwlan03.kuas.ac.jp/auth/index.html/u" -d @- -s -o NUL
         
    Start-Sleep -Seconds 3
    
    # Check if login was successful
    $appleCheck2 = curl.exe -s -m 3 http://captive.apple.com/hotspot-detect.html
    if ($appleCheck2 -match "Success") {
        Show-Notification -Title $NOTIFY_TITLE -Message $NOTIFY_MSG_SUCCESS
    } else {
        # Fallback to Main Library credentials if it fails
        Write-Output $MSG_LOGGING_IN_LIB
        
        $libData = "user=libwifi&password=Kuaslib2023"
        $libData | curl.exe -X POST "https://uzwlan03.kuas.ac.jp/auth/index.html/u" -d @- -s -o NUL
             
        Start-Sleep -Seconds 3
        
        $appleCheck3 = curl.exe -s -m 3 http://captive.apple.com/hotspot-detect.html
        if ($appleCheck3 -match "Success") {
            Show-Notification -Title $NOTIFY_TITLE -Message $NOTIFY_MSG_SUCCESS_LIB
        } else {
            Show-Notification -Title $NOTIFY_TITLE -Message $NOTIFY_MSG_FAIL
        }
    }

} else {
    Write-Output $MSG_OUT_OF_RANGE
}