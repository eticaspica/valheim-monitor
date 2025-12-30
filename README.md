# valheim-monitor

Valheim サーバーログを監視し、ログイン/ログアウトなどのイベントを Notion データベースへ送るシェルスクリプト集です。`curl` で Notion API にページを追加します。

## 構成
- **post-log.sh**: `journalctl -u $valheimd -f` を監視し、対象ログを Notion へ送信します。
  - ログイン: `"Got character ZDOID"`（ZDOID とプレイヤー名を抽出し `viking/` にキャッシュ）
  - ログアウト: `"Destroying abandoned non persistent"`（保存済み ZDOID からプレイヤー名を取得）
  - サーバー起動/停止: `"Game server connected"` / `"OnApplicationQuit"`
  - 接続数: `"Connections"`
- **notion/inout-payload.sh**: Notion に送る JSON ペイロードを生成します（イベント種別やプレイヤー名を含む）。
- **notion/post-page.sh**: Notion API にページを作成します。

## Notion 側のプロパティ
データベースには以下のプロパティが必要です（名前を合わせてください）。
- `title`（タイトル）: 例 `player is login`
- `type`（セレクト）
- `viking`（リッチテキスト）
- `stdout`（リッチテキスト）

## 必要要件
- Bash
- `curl`
- systemd 環境の `journalctl`
- Notion 内部統合トークンとデータベース ID

## 環境変数（.env）
`.env` をリポジトリ直下に配置します。

```env
# systemd サービス名
valheimd=valheim.service

# Notion 内部統合トークンとデータベース ID
notion_integration_token=secret_xxx
notion_database_id=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

## 使い方
1) `.env` を作成し、`viking/` ディレクトリを作成します（ZDOID とプレイヤー名の対応を一時保存します）。  
2) サービス名が異なる場合は `.env` の `valheimd` を変更します。  
3) `journalctl` を読めるユーザーで `./post-log.sh` を実行します。

## 注意事項
- `post-log.sh` は現在の作業ディレクトリに `viking/` を作り、一時ファイルを置きます。適切なパーミッションで運用してください。
- `.env` には秘密情報が含まれるため権限を制限してください（例: `chmod 600 .env`）。
- ログ読み取り権限と Notion データベースへの書き込み権限を持つトークンを使用してください。
