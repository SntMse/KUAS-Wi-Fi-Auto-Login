# KUAS Wi-Fi Auto Login

A set of scripts to automatically log in to the Kyoto University of Advanced Science (KUAS) campus Wi-Fi (such as `kuas-wlan`, `kuas-guest`, `kuas-fclan`, etc.) in the background. Currently supports macOS and Windows.
It monitors the network every 5 minutes and automatically authenticates only when the captive portal is detected.

京都先端科学大学（KUAS）の学内Wi-Fi（`kuas-wlan` や `kuas-guest`、`kuas-fclan` など）に接続した際、ブラウザを開くことなくバックグラウンドで自動ログインを行うスクリプト群です。現在はmacOSとWindowsに対応しています。

## Features / 主な機能
- **Auto Wi-Fi Profile Setup (macOS)**: Automatically registers the KUAS Wi-Fi SSIDs and shared passwords to your Mac. (macOS版: 複数の学内Wi-Fiの接続設定と共通パスワードをMacに自動登録します)
- **SSID-Agnostic & Privacy Bypass**: Bypasses Location Services restrictions by detecting the Captive Portal's HTTP 302 redirect instead of reading the Wi-Fi SSID directly. (プライバシー制限によりSSID名が取得できない問題を回避するため、SSIDに依存せず、認証サーバーの302リダイレクトを検知して動作する設計です)
- **Library Fallback**: KUAS Main Library (Kameoka) uses different credentials. This script automatically retries with the Main Library credentials (`libwifi`) if the standard login fails. (亀岡の図書館本館は接続に別のIDを使用します。通常のログインに失敗した場合、自動的に図書館本館の認証情報で再試行します)
- **Background Authentication**: Bypasses the captive portal by authenticating in the background every 5 minutes if disconnected. (未ログイン状態のときだけ、5分ごとに自動でWeb認証を通します)
- **Native Notifications**: Displays native desktop notifications (macOS Banners / Windows Toasts) upon successful or failed authentication. (認証の成功・失敗時にOS標準の通知を表示します)

---

## Table of Contents / 目次
* [How to Download / ダウンロード方法](#how-to-download--ダウンロード方法)
* [For macOS](#-for-macos)
  * [Requirements / 動作環境](#requirements--動作環境-macos)
  * [Installation / インストール](#installation--インストール-macos)
  * [Important Notes / 注意事項](#important-notes--注意事項-macos)
  * [Troubleshooting / トラブルシューティング](#troubleshooting--トラブルシューティング-macos)
  * [Uninstallation / アンインストール](#uninstallation-macos--アンインストール方法-macos)
* [For Windows](#-for-windows)
  * [Requirements / 動作環境](#requirements--動作環境-windows)
  * [Installation / インストール](#installation--インストール-windows)
  * [Important Notes / 注意事項](#important-notes--注意事項-windows)
  * [Uninstallation / アンインストール](#uninstallation-windows--アンインストール方法-windows)
* [How it works / 仕組み](#how-it-works--仕組み)
  * [Updating Credentials / 認証情報の変更](#updating-credentials--認証情報の変更)
* [Bug Reports & Issues / バグ報告・不具合について](#bug-reports--issues--バグ報告不具合について)

---

## How to Download / ダウンロード方法

Choose one of the following methods to download the scripts to your computer.
以下のいずれかの方法で、スクリプトをパソコンにダウンロードしてください。

#### Option A: Download as a ZIP file (Recommended for Windows) / ZIPでダウンロード（Windowsにおすすめ）
1. Click the green **"<> Code"** button at the top of this GitHub page. (このページの右上にある緑色の「<> Code」ボタンをクリックします)
2. Select **"Download ZIP"**. (「Download ZIP」を選択します)
3. Extract (unzip) the downloaded file to your preferred location, such as your Downloads folder. (ダウンロードしたZIPファイルを解凍・展開してください)

#### Option B: Using Git (Recommended for macOS/Developers) / Gitを使用する（Macや開発者におすすめ）
Open your terminal and run the following commands:
ターミナルを開き、以下のコマンドを実行します。

```bash
git clone [https://github.com/SntMse/KUAS-Wi-Fi-Auto-Login.git](https://github.com/SntMse/KUAS-Wi-Fi-Auto-Login.git)
cd KUAS-Wi-Fi-Auto-Login
```

### Next Steps / 次の手順
Once you have downloaded the files, please proceed to the installation instructions for your specific operating system below.

ダウンロードが完了したら、以下の該当するOSのセクションに進み、インストールを行ってください。
* [For macOS](#-for-macos)
* [For Windows](#-for-windows)


# For macOS

## Requirements / 動作環境 (macOS)
* macOS
* Terminal
* KUAS On Campus ID

## Installation / インストール (macOS)
Open your terminal, navigate to the downloaded folder, and run the following commands.
```
chmod +x install-macOS.sh
./install-macOS.sh
```
The installer will interactively ask for your student ID and password.

インストーラの指示に従い、学籍番号とパスワードを入力してください。

## Important Notes / 注意事項 (macOS)

### 1. Global Disabling of Wi-Fi Login Popups / Mac全体のWi-Fiログインポップアップが無効化されます
This installation script globally disables the macOS Captive Network Assistant (CNA) to prevent the default login screen from interrupting the background authentication. This means that when you connect to other public Wi-Fi networks (e.g., cafes, hotels), the login screen will no longer pop up automatically. You will need to open your browser (Safari, Chrome) and access any HTTP site (like http://neverssl.com) to trigger their login pages manually.

本スクリプトのバックグラウンド処理との干渉を防ぐため、インストール時にmacOS標準の「Wi-Fiログインポップアップ機能（CNA）」をシステム全体で無効化します。
これにより、カフェやホテルなどの他の無料Wi-Fiに接続した際も、ログイン画面が自動で立ち上がらなくなります。 学外で公衆Wi-Fiの認証をしたい場合は、ブラウザを開いて手動で任意のHTTPサイト（http://neverssl.com など）にアクセスしてログイン画面を表示させてください。

### 2. VPN Auto-Connect Interference / VPNの自動接続設定による干渉
If you use a VPN with an "Auto-connect" or "On-Demand" feature, it may block the authentication request. Please add kuas-wlan to your VPN's "Trusted Networks" or exclude it from auto-connection.

VPNの自動接続（オンデマンド接続）が有効になっていると、学内サーバーへの認証通信がVPNに吸い込まれてしまい、ログインに失敗します。お使いのVPNアプリ（NordVPNなど）の設定で、kuas-wlan を「信頼できるネットワーク（自動接続の除外対象）」に登録してください。

### 3. Unverified at Kameoka Campus / 亀岡キャンパスでの動作未確認

Currently, this script has not been tested at the Kyoto Kameoka Campus. It may or may not work depending on the network environment there.

現在、京都亀岡キャンパスでの動作確認は行えていません。現地のネットワーク環境（SSIDや認証サーバーの違いなど）によっては正常に動作しない可能性があります。

## Troubleshooting & Common Issues / トラブルシューティング
### 1. Notifications do not appear / スクリプトは動いているが通知が出ない
macOS treats command-line notifications as coming from "Script Editor". If you don't see success/failure popups in the top right corner, go to System Settings > Notifications, find Script Editor (スクリプトエディタ), and turn on "Allow Notifications".

macOSの仕様上、このスクリプトからの通知は「スクリプトエディタ」からの通知として扱われます。「システム設定」＞「通知」の中に「スクリプトエディタ」がオフになっている場合、裏側でログインに成功していても画面にバナーが表示されません。通知を許可してください。

### 2. Keeps saying "Authentication failed" / 「認証に失敗しました」と出続ける
You might have made a typo during the hidden password input. You can check your saved credentials by running cat ~/.kuas_wifi.conf. If there's a typo, simply run ./install-macOS.sh again to overwrite it.

インストーラでのパスワード入力は画面に文字が表示されないため、入力ミス（タイポ）が起こりやすいです。ターミナルで cat ~/.kuas_wifi.conf を実行して、保存されたパスワードが間違っていないか確認してください。間違っていた場合は再度 ./install-macOS.sh を実行して上書きしてください。

## Uninstallation (macOS) / アンインストール方法 (macOS)
Run the following commands to remove the automation.

自動化を解除したい場合は以下のコマンドを実行してください。

```bash
launchctl unload ~/Library/LaunchAgents/com.sntmse.kuas.wifi.autologin.plist
rm ~/Library/LaunchAgents/com.sntmse.kuas.wifi.autologin.plist
rm ~/.local/bin/SntMse-KUAS-Wi-Fi-Auto-Login
rm ~/.kuas_wifi.conf
sudo defaults delete /Library/Preferences/SystemConfiguration/com.apple.captive.control Active
```


# For Windows

## Requirements / 動作環境 (Windows)
* Windows 10 / Windows 11
* KUAS On Campus ID

## Installation / インストール (Windows)
1. After downloading and extracting the ZIP file, open the folder. (ダウンロードしたZIPファイルを解凍し、フォルダを開きます)
2. Double-click the install-WindowsOS.bat file to start the installer. (フォルダ内にある install-WindowsOS.bat をダブルクリックして実行します)
3. A terminal window will open. Follow the on-screen instructions to enter your student ID and password. (青い画面が立ち上がるので、指示に従い学籍番号とパスワードを入力してください)

Note: The necessary files are securely copied to a hidden folder on your system during installation. You can safely delete the downloaded ZIP file and the extracted folder after the installation is complete.

注意: インストール完了後、動作に必要なファイルはパソコン内の安全な隠しフォルダに自動でコピーされています。ダウンロードしたZIPファイルと解凍したフォルダは、ゴミ箱に入れて削除して構いません。

## Important Notes / 注意事項 (Windows)

### 1. VPN Auto-Connect Interference / VPNの自動接続設定による干渉
If you use a VPN with an "Auto-connect" feature, it may block the authentication request. Please add the KUAS Wi-Fi networks to your VPN's "Trusted Networks".
VPNの自動接続が有効になっているとログインに失敗します。お使いのVPNアプリの設定で、学内Wi-Fiを自動接続の除外対象に登録してください。

### 2. Unverified at Kameoka Campus / 亀岡キャンパスでの動作未確認
Currently, this script has not been tested at the Kyoto Kameoka Campus.
現在、京都亀岡キャンパスでの動作確認は行えていません。

## Uninstallation (Windows) / アンインストール方法 (Windows)

Open PowerShell and run the following commands to remove the scheduled task and the saved configurations.

PowerShellを開き、以下のコマンドを実行してタスクスケジューラの登録と設定ファイルを削除してください。

```
Get-ScheduledTask -TaskName "SntMse KUAS Wi-Fi Auto Login*" | Unregister-ScheduledTask -Confirm:$false
Remove-Item -Path "$env:USERPROFILE\.local\bin\SntMse-KUAS-Wi-Fi-Auto-Login.ps1" -ErrorAction SilentlyContinue
Remove-Item -Path "$env:USERPROFILE\.kuas_wifi.conf" -ErrorAction SilentlyContinue
```
(Alternatively, you can manually delete the task named "SntMse KUAS Wi-Fi Auto Login" from the Windows Task Scheduler app. / または、Windows標準の「タスク スケジューラ」アプリを開き、手動で該当タスクを右クリックして削除することも可能です)


# How it works / 仕組み
Your credentials are saved securely in a hidden config file ~/.kuas_wifi.conf with restricted permissions (chmod 600). The password is never stored in the script itself and is securely sent via standard input (stdin) to prevent process exposure.
The script checks connectivity to Apple's captive portal test server. If blocked, it tests the KUAS authentication server (uzwlan03.kuas.ac.jp). If the server returns an HTTP 302 Redirect, it confirms the Mac is on the unauthenticated KUAS network and securely POSTs your credentials.

パスワードはご自身のMac内の隠しファイルに安全な権限で保存され、スクリプト本体に書き込まれることはありません。送信時もプロセス一覧（psコマンド）にパスワードが露出しないセキュアな設計（標準入力からの読み込み）を採用しています。
動作としては、未認証状態で返される「302リダイレクト」のステータスコードを検知したときのみ、パスワードを裏側で送信（POST）する仕組みになっています。


## Updating Credentials / 認証情報の変更
If you change your KUAS password, simply download the latest release and run the installer script again to update your saved credentials.

パスワードを変更した場合は、再度インストーラ（`.sh` または `.bat`）を実行することで上書き更新できます。


# Bug Reports & Issues / バグ報告・不具合について

If you encounter any bugs, issues, or have feature requests, please report them on the [GitHub Issues page](https://github.com/SntMse/KUAS-Wi-Fi-Auto-Login/issues).

バグや問題を発見した場合、または機能の要望がある場合は、[GitHubのIssueページ](https://github.com/SntMse/KUAS-Wi-Fi-Auto-Login/issues)にて報告をお願いします。
