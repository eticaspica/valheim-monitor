# valheim-monitor

Valheim サーバーログを Notion データベースへ送るためのシェルスクリプト集です。`curl` で Notion API にページを追加し、ログ行をそのままタイトルプロパティ（`raw`）に保存します。

## 構成
- **post-log.sh**: `journalctl -u $valheimd -f` を読み、以下の文字列を含む行だけを送信します。
  - Got character ZDOID / Destroying abandoned non persistent / Game server connected / OnApplicationQuit / Connections
- **notion/make-payload.sh**: Notion API へ送る JSON ペイロードを生成します。
- **notion/post-page.sh**: Notion API にページを作成します。

## 必要要件
- Bash
- `curl`
- Notion 内部統合トークンとデータベース ID（タイトルプロパティ名が `raw` のもの）
- `post-log.sh`: systemd 環境の `journalctl`

## 環境変数
`.env` に以下を設定してからスクリプトを実行してください。

```env
# systemd サービス名
valheimd=valheim.service

# Notion 内部統合トークンとデータベース ID
notion_integration_token=secret_xxx
notion_database_id=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

## 使い方
1) 上記の内容で `.env` を作成します。  
2) 目的に応じて以下を実行します。
   - サーバーの journal から特定の行だけ送りたい: `./post-log.sh`
     - サービス名が異なる場合は `.env` の `valheimd` を合わせてください。

## 注意事項
- 送信されるログ行は Notion のタイトルプロパティ `raw` にそのまま保存されます。必要に応じて Notion 側でカラムを追加・編集してください。
- ログファイルへの読み取り権限と、Notion データベースへの書き込み権限を持つトークンを使用してください。
