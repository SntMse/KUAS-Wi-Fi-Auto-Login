# -------------------------------------------------------------
# KUAS Wi-Fi Auto Login Installer for Windows
# by Shintaro Muraseh (SntMse)
# v0.2 Beta
# -------------------------------------------------------------
$Host.UI.RawUI.WindowTitle = "KUAS Wi-Fi Auto Login - Installer"
Write-Host "KUAS Wi-Fi自動ログイン (Windows版) のインストールを開始します..." -ForegroundColor Cyan
Write-Host ""

# 学籍番号の入力
$user = Read-Host "KUASの学籍番号（例: 2021m634）を入力してください"

# パスワードの安全な入力（画面に表示されない）
$passSecure = Read-Host "パスワードを入力してください" -AsSecureString
$passPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($passSecure))

# 設定ファイルの保存先（~/.kuas_wifi.conf）
$confPath = "$env:USERPROFILE\.kuas_wifi.conf"
"KUAS_USER=$user" | Out-File -FilePath $confPath -Encoding utf8
"KUAS_PASS=$passPlain" | Out-File -FilePath $confPath -Encoding utf8 -Append

# 実行ファイルの配置ディレクトリ作成（~/.local/bin）
$binDir = "$env:USERPROFILE\.local\bin"
if (-Not (Test-Path $binDir)) { New-Item -ItemType Directory -Path $binDir | Out-Null }

# メインスクリプトのコピー
$scriptPath = "$binDir\SntMse-KUAS-Wi-Fi-Auto-Login.ps1"
Copy-Item -Path ".\kuas_wifi_WindowsOS.ps1" -Destination $scriptPath -Force

# Windowsタスクスケジューラへの登録（5分ごとにバックグラウンドで実行）
Write-Host "バックグラウンドタスクを登録しています..."
$taskName = "KUAS_WiFi_AutoLogin"
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptPath`""
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 5)

# 既存のタスクがあれば上書き
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -User $env:USERNAME -Force | Out-Null

Write-Host ""
Write-Host "========================================================" -ForegroundColor Green
Write-Host "インストールと設定が正常に完了しました！" -ForegroundColor Green
Write-Host "※認証情報を変更したい場合は、再度このスクリプトを実行してください。" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green
Start-Sleep -Seconds 5
