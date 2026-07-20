# KUAS Wi-Fi Auto Login

A set of scripts to automatically log in to the Kyoto University of Advanced Science (KUAS) campus Wi-Fi (`kuas-wlan`) in the background. Currently supports macOS (Windows support is planned for the future).
It monitors the network every 5 minutes and automatically authenticates only when needed.

京都先端科学大学（KUAS）の学内Wi-Fi（`kuas-wlan`）に接続した際、ブラウザを開くことなくバックグラウンドで自動ログインを行うスクリプト群です。現在はmacOSに対応しています（将来的にWindows版も追加予定です）。5分ごとにネットワークを監視し、未ログイン状態のときだけ自動で認証を通します。

## Requirements / 動作環境
- macOS
- Terminal

## Installation (macOS) / インストール手順 (macOS)

Open your terminal and run the following commands.

ターミナルを開き、以下のコマンドを実行します。

```bash
git clone [https://github.com/SntMse/KUAS-Wi-Fi-Auto-Login.git](https://github.com/SntMse/KUAS-Wi-Fi-Auto-Login.git)
```
```bash
cd KUAS-Wi-Fi-Auto-Login
```
```bash
chmod +x install.sh
```
```bash
./install.sh
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

## Updating Credentials / 認証情報の変更
If you change your KUAS password, simply navigate to the repository folder and run ./install.sh again to update your saved credentials.

パスワードを変更した場合は、再度 ./install.sh を実行することで上書き更新できます。

## How it works / 仕組み
Your credentials are saved securely in a hidden config file (~/.kuas_wifi.conf) with restricted permissions (chmod 600). The password is never stored in the script itself.

パスワードはご自身のMac内の隠しファイルに安全な権限で保存され、スクリプト本体に書き込まれることはありません。

## Uninstallation (macOS) / アンインストール方法 (macOS)
Run the following commands to remove the automation.

自動化を解除したい場合は以下のコマンドを実行してください。

```bash
launchctl unload ~/Library/LaunchAgents/com.kuas.wifi.auto.plist
```
```bash
rm ~/Library/LaunchAgents/com.kuas.wifi.auto.plist
```
```bash
rm ~/Scripts/kuas_wifi_macos.sh
```
```bash
rm ~/.kuas_wifi.conf
```
