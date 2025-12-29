#!/bin/bash

set -a
source .env
set +a

inotifywait -m -e modify "$log_path" | while read _; do
    row=`tail -n 1 "$log_path"`
    if [[ "$row" != *"Got character"* ]]; then
        continue
    fi
    json_payload=$(./notion/make-payload.sh "$notion_database_id" "$row")

    ./notion/post-page.sh "$notion_integration_token" "$json_payload"
done