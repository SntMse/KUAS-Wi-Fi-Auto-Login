# KUAS Wi-Fi Auto Login

A set of scripts to automatically log in to the Kyoto University of Advanced Science (KUAS) campus Wi-Fi (such as `kuas-wlan`, `kuas-wlan-Wifi6`, etc.) in the background. Currently supports macOS.
It monitors the network every 5 minutes and automatically authenticates only when the captive portal is detected.

京都先端科学大学（KUAS）の学内Wi-Fi（`kuas-wlan` や `kuas-wlan-Wifi6` など）に接続した際、ブラウザを開くことなくバックグラウンドで自動ログインを行うスクリプト群です。現在はmacOSに対応しています。

## Features / 主な機能
- **Auto Wi-Fi Profile Setup**: Automatically registers the KUAS Wi-Fi SSIDs and shared passwords to your Mac. (複数の学内Wi-Fiの接続設定と共通パスワードをMacに自動登録します)
- **SSID-Agnostic & Privacy Bypass**: Bypasses macOS Location Services restrictions by detecting the Captive Portal's HTTP 302 redirect instead of reading the Wi-Fi SSID directly. (macOSのプライバシー制限によりSSID名が取得できない問題を回避するため、SSIDに依存せず、認証サーバーの302リダイレクトを検知して動作する堅牢な設計です)
- **Library Fallback**: KUAS Main Library (Kameoka) uses different credentials. This script automatically retries with the Main Library credentials (`libwifi`) if the standard login fails. (亀岡の図書館本館は接続に別のIDを使用します。通常のログインに失敗した場合、自動的に図書館本館の認証情報で再試行します)
- **Background Authentication**: Bypasses the captive portal by authenticating in the background every 5 minutes if disconnected. (未ログイン状態のときだけ、5分ごとに自動でWeb認証を通します)

## Requirements / 動作環境
- macOS
- Terminal
- KUAS On Campus ID

## How to Download / ダウンロード方法

Choose one of the following methods to download the scripts to your computer.
以下のいずれかの方法で、スクリプトをパソコンにダウンロードしてください。

### Option A: Download as a ZIP file (Recommended for Windows) / ZIPでダウンロード（Windowsにおすすめ）
1. Click the green **"<> Code"** button at the top of this GitHub page. (このページの右上にある緑色の「<> Code」ボタンをクリックします)
2. Select **"Download ZIP"**. (「Download ZIP」を選択します)
3. Extract (unzip) the downloaded file to your preferred location, such as your Downloads folder. (ダウンロードしたZIPファイルを解凍・展開してください)

### Using Git (Recommended for macOS/Developers) / Gitを使用する（Macや開発者におすすめ）

Open your terminal and run the following commands.
ターミナルを開き、以下のコマンドを実行します。

```bash
git clone [https://github.com/SntMse/KUAS-Wi-Fi-Auto-Login.git](https://github.com/SntMse/KUAS-Wi-Fi-Auto-Login.git)
cd KUAS-Wi-Fi-Auto-Login
chmod +x install-macOS.sh
./install-macOS.sh
```

The installer will interactively ask for your student ID and password.

インストーラの指示に従い、学籍番号とパスワードを入力してください。

## Important Notes / 注意事項

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

## How it works / 仕組み
Your credentials are saved securely in a hidden config file ~/.kuas_wifi.conf with restricted permissions (chmod 600). The password is never stored in the script itself and is securely sent via standard input (stdin) to prevent process exposure.
The script checks connectivity to Apple's captive portal test server. If blocked, it tests the KUAS authentication server (uzwlan03.kuas.ac.jp). If the server returns an HTTP 302 Redirect, it confirms the Mac is on the unauthenticated KUAS network and securely POSTs your credentials.

パスワードはご自身のMac内の隠しファイルに安全な権限で保存され、スクリプト本体に書き込まれることはありません。送信時もプロセス一覧（psコマンド）にパスワードが露出しないセキュアな設計（標準入力からの読み込み）を採用しています。
動作としては、未認証状態で返される「302リダイレクト」のステータスコードを検知したときのみ、パスワードを裏側で送信（POST）する仕組みになっています。

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
rm ~/.local/bin/SntMse-KUAS-Wi-Fi-Auto-Login
rm ~/.kuas_wifi.conf
sudo defaults delete /Library/Preferences/SystemConfiguration/com.apple.captive.control Active
```
