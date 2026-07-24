# -------------------------------------------------------------
# KUAS Wi-Fi Auto Login Installer for Windows
# by Shintaro Muraseh (SntMse)
$VERSION = "w1.1" # Updated version organization
# -------------------------------------------------------------

# 1. Determine system language for localization (Default: English, Japanese if system culture is "ja")
$lang = (Get-Culture).TwoLetterISOLanguageName
if ($lang -eq "ja") {
    $MSG_START = "SntMse KUAS Wi-Fi自動ログイン ${VERSION}版のインストールを開始します..."
    $MSG_PROMPT_USER = "KUASの学籍番号（例: 2021m634）を入力してください"
    $MSG_PROMPT_PASS = "パスワードを入力してください"
    $MSG_TASK_REG = "バックグラウンドタスクを登録しています..."
    $MSG_SUCCESS = "インストールと設定が正常に完了しました！"
    $MSG_UPDATE = "※認証情報を変更したい場合は、再度このスクリプトを実行してください。"
} else {
    $MSG_START = "Starting installation for SntMse KUAS Wi-Fi Auto Login v${VERSION}..."
    $MSG_PROMPT_USER = "Enter your KUAS Student ID (e.g., 2021m634)"
    $MSG_PROMPT_PASS = "Enter your password"
    $MSG_TASK_REG = "Registering background task..."
    $MSG_SUCCESS = "Installation and setup completed successfully!"
    $MSG_UPDATE = "* To update your credentials, simply run this script again."
}

$Host.UI.RawUI.WindowTitle = "SntMse KUAS Wi-Fi Auto Login v${VERSION} - Installer"
Write-Host $MSG_START -ForegroundColor Cyan
Write-Host ""

# 2. Prompt for student ID
$user = Read-Host $MSG_PROMPT_USER

# 3. Securely prompt for password (masked input)
$passSecure = Read-Host $MSG_PROMPT_PASS -AsSecureString
$passPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($passSecure))

# 4. Define configuration file path (~/.kuas_wifi.conf) and save credentials
$confPath = "$env:USERPROFILE\.kuas_wifi.conf"
"KUAS_USER=$user" | Out-File -FilePath $confPath -Encoding utf8
"KUAS_PASS=$passPlain" | Out-File -FilePath $confPath -Encoding utf8 -Append

# 5. Create bin directory if it doesn't exist (~/.local/bin)
$binDir = "$env:USERPROFILE\.local\bin"
if (-Not (Test-Path $binDir)) { New-Item -ItemType Directory -Path $binDir | Out-Null }

# 6. Copy the main script to the bin directory
$scriptPath = "$binDir\SntMse-KUAS-Wi-Fi-Auto-Login.ps1"
Copy-Item -Path ".\kuas_wifi_WindowsOS.ps1" -Destination $scriptPath -Force

# 7. Register a Windows Scheduled Task (runs in the background every 5 minutes)
Write-Host $MSG_TASK_REG
$taskName = "SntMse KUAS Wi-Fi Auto Login v${VERSION}"
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptPath`""
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 5)

# 8. Overwrite existing task if present
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -User $env:USERNAME -Force | Out-Null

Write-Host ""
Write-Host "========================================================" -ForegroundColor Green
Write-Host $MSG_SUCCESS -ForegroundColor Green
Write-Host $MSG_UPDATE -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green
Start-Sleep -Seconds 5
