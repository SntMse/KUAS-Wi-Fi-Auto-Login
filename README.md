# KUAS-Wi-Fi-Auto-Login
Auto Login Scripts for kuas-wlan

京都先端科学大学（KUAS）の学内Wi-Fi（`kuas-wlan`）に接続した際、ブラウザを開くことなくバックグラウンドで自動ログインを行うためのmacOS用スクリプトです。
5分ごとにネットワークを監視し、未ログイン状態のときだけ自動で認証を通します。

## 動作環境
- macOS (対応確認済み)
- ターミナル (zsh 推奨)

## インストール手順

### 1. スクリプトのダウンロードと配置
ターミナルを開き、以下のコマンドを順番に実行してスクリプトを配置します。

```bash
mkdir -p ~/Scripts
curl -o ~/Scripts/kuas_wifi.sh [https://raw.githubusercontent.com/SntMse/KUAS-Wi-Fi-Auto-Login/main/kuas_wifi_macOS.sh](https://raw.githubusercontent.com/SntMse/KUAS-Wi-Fi-Auto-Login/main/kuas_wifi_macOS.sh)
chmod +x ~/Scripts/kuas_wifi_macOS.sh
