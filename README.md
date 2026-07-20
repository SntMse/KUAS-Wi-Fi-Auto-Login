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
cd KUAS-Wi-Fi-Auto-Login
chmod +x install.sh
./install.sh
