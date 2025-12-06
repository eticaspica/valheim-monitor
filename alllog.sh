set -a
source .env
set +a

inotifywait -m -e modify "$log_path" | while read _; do
    row=`tail -n 1 "$log_path"`
    json_payload=$(cat <<EOF
{
  "parent": { "database_id": "$notion_database_id" },
  "properties": {
    "raw": {
      "title": [
        {
          "text": { "content": "$row" }
        }
      ]
    }
  }
}
EOF
)
    curl 'https://api.notion.com/v1/pages' \
        -H 'Authorization: Bearer '"$notion_integration_token"'' \
        -H "Content-Type: application/json" \
        -H "Notion-Version: 2022-06-28" \
        --data "$json_payload"
done