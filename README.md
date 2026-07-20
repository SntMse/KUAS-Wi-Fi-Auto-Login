# KUAS Wi-Fi Auto Login

A set of scripts to automatically log in to the Kyoto University of Advanced Science (KUAS) campus Wi-Fi (`kuas-wlan`) in the background. Currently supports macOS.
It monitors the network every 5 minutes and automatically authenticates only when needed.

京都先端科学大学（KUAS）の学内Wi-Fi（`kuas-wlan`）に接続した際、ブラウザを開くことなくバックグラウンドで自動ログインを行うスクリプト群です。現在はmacOSに対応しています。

## Features / 主な機能
- **Auto Wi-Fi Profile Setup**: Automatically registers the `kuas-wlan` SSID and shared password to your Mac. (Wi-Fiの接続設定と共通パスワードをMacに自動登録します)
- **Smart Connectivity Check**: Uses HTTP requests to reliably check internet access, bypassing ICMP (Ping) blocks on the university network. (大学のネットワーク制限(Pingブロック)を回避するため、HTTPリクエストによる確実な接続チェックを行います)
- **Library Fallback**: KUAS Main Library (Kameoka) uses different credentials. This script automatically retries with the Main Library credentials (`libwifi`) if the standard login fails. (亀岡の図書館本館は接続に別のIDを使用します。通常のログインに失敗した場合、自動的に図書館本館の認証情報で再試行します)
- **Background Authentication**: Bypasses the captive portal by authenticating in the background every 5 minutes if disconnected. (未ログイン状態のときだけ、5分ごとに自動でWeb認証を通します)

## Requirements / 動作環境
- macOS
- Terminal
- KUAS On Campus ID

## Installation (macOS) / インストール手順 (macOS)

Open your terminal and run the following commands.
ターミナルを開き、以下のコマンドを実行します。

```bash
git clone https://github.com/SntMse/KUAS-Wi-Fi-Auto-Login.git
cd KUAS-Wi-Fi-Auto-Login
chmod +x install-macOS.sh
./install-macOS.sh
```

The installer will interactively ask for your student ID and password.

インストーラの指示に従い、学籍番号とパスワードを入力してください。

## Important Notes / 注意事項

### 1. Disable Wi-Fi Auto-Login Popup / Wi-Fiの自動ログイン（ポップアップ）をオフにする
To prevent the default macOS captive portal login screen from interrupting the script, please disable the "Auto-Login" feature for kuas-wlan in your Mac's Wi-Fi settings.

macOS標準のログイン画面（ポップアップ）が立ち上がるとバックグラウンド処理と干渉する可能性があります。システム設定のWi-Fi設定から kuas-wlan の詳細を開き、「自動ログイン（Auto-Login）」のスイッチをオフにしておいてください。

### 2. VPN Auto-Connect Interference / VPNの自動接続設定による干渉
If you use a VPN with an "Auto-connect" or "On-Demand" feature, it may block the authentication request. Please add kuas-wlan to your VPN's "Trusted Networks" or exclude it from auto-connection.

VPNの自動接続（オンデマンド接続）が有効になっていると、学内サーバーへの認証通信がVPNに吸い込まれてしまい、ログインに失敗します。お使いのVPNアプリ（NordVPNなど）の設定で、kuas-wlan を「信頼できるネットワーク（自動接続の除外対象）」に登録してください。

### 3. Unverified at Kameoka Campus / 亀岡キャンパスでの動作未確認

Currently, this script has not been tested at the Kyoto Kameoka Campus. It may or may not work depending on the network environment there.

現在、京都亀岡キャンパスでの動作確認は行えていません。現地のネットワーク環境（SSIDや認証サーバーの違いなど）によっては正常に動作しない可能性があります。

## Updating Credentials / 認証情報の変更
If you change your KUAS password, simply navigate to the repository folder and run ./install-macOS.sh again to update your saved credentials.

パスワードを変更した場合は、再度 ./install-macOS.sh を実行することで上書き更新できます。

## Bug Reports & Issues / バグ報告・不具合について

If you encounter any bugs, issues, or have feature requests, please report them on the [GitHub Issues page](https://github.com/SntMse/KUAS-Wi-Fi-Auto-Login/issues).

バグや問題を発見した場合、または機能の要望がある場合は、[GitHubのIssueページ](https://github.com/SntMse/KUAS-Wi-Fi-Auto-Login/issues)にて報告をお願いします。

## How it works / 仕組み
Your credentials are saved securely in a hidden config file `~/.kuas_wifi.conf` with restricted permissions (chmod 600). The password is never stored in the script itself.

パスワードはご自身のMac内の隠しファイルに安全な権限で保存され、スクリプト本体に書き込まれることはありません。

## Uninstallation (macOS) / アンインストール方法 (macOS)
Run the following commands to remove the automation.

自動化を解除したい場合は以下のコマンドを実行してください。

```bash
launchctl unload ~/Library/LaunchAgents/com.sntmse.kuas.wifi.autologin.plist
rm ~/Library/LaunchAgents/com.sntmse.kuas.wifi.autologin.plist
rm ~/.local/bin/kuas_wifi_macos.sh
rm ~/.kuas_wifi.conf
```
