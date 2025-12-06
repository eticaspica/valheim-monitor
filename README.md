# loginlog

Valheim サーバーのログファイルを監視し、Notion データベースへ新規行を保存するための簡易スクリプト群です。`inotifywait` でログファイルの変更を検知し、`curl` で Notion API に行データを送信します。

## 同梱スクリプト
- **loginlog.sh**: ログに「Got character」を含む行だけを Notion に送信します。
- **alllog.sh**: ログの全ての行を Notion に送信します。
- **reboot.sh**: `valheim.log` をバックアップした後、`loginlog.sh` をバックグラウンドで起動します。

## 必要要件
- Bash
- [inotify-tools](https://github.com/inotify-tools/inotify-tools)（`inotifywait` を利用）
- `curl`
- Notion の内部統合トークンとデータベース ID

## 環境変数
`.env` に以下の変数を設定してからスクリプトを実行してください。

```env
# 監視するログファイルへの絶対パス
log_path=/path/to/valheim.log

# Notion 内部統合トークンとデータベース ID
notion_integration_token=secret_xxx
notion_database_id=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

## 使い方
1. 依存コマンドをインストールします（例: `apt install inotify-tools curl`）。
2. 上記の内容で `.env` を作成します。
3. 監視したいスクリプトを実行します。
   - 特定のログ行のみを送る場合: `./loginlog.sh`
   - すべてのログ行を送る場合: `./alllog.sh`

## `reboot.sh` について
- `valheim.log` を `./log/loginlog.log.<番号>` へバックアップします（`log` ディレクトリが必要です）。
- `loginlog.sh` を `nohup` でバックグラウンド起動し、標準出力を `loginlog.log` に書き出します。
- プロセス ID は `loginlog.pid` に保存されます。

## 注意事項
- Notion へのリクエストはデータベースの「raw」タイトルプロパティへログ行をそのまま保存します。必要に応じて Notion 側でカラムを追加・編集してください。
- ログファイルにアクセスできる権限と、データベースへの書き込み権限を持つトークンを使用してください。
