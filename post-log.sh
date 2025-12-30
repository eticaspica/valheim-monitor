#!/bin/bash

set -a
source .env
set +a

journalctl -u $valheimd -f --since now --no-pager -o cat | 
while read -r line; do

    case "$line" in
        *"Got character ZDOID"*)
            type=login
            ZDOID=$(echo "$line" | sed -E 's/.*: ([0-9]+):[0-9]+/\1/')
            viking=$(echo "$line" | sed -E 's/.*from ([^ ]+).*/\1/')
            echo "$viking" > viking/"$ZDOID"

            json_payload=$(./notion/inout-payload.sh \
                "$notion_database_id" \
                "$line" \
                "$type" \
                "$ZDOID" \
                "$viking")

            ./notion/post-page.sh "$notion_integration_token" "$json_payload"
            ;;
        *"Destroying abandoned non persistent"*)
            type=logout
            ZDOID=$(echo "$line" | sed -E 's/.*owner ([0-9]+)/\1/')
            viking=$(cat viking/"$ZDOID")

            json_payload=$(./notion/inout-payload.sh \
                "$notion_database_id" \
                "$line" \
                "$type" \
                "$ZDOID" \
                "$viking")
            rm viking/"$ZDOID"

            if [ -f viking/"$ZDOID" ]; then
                ./notion/post-page.sh "$notion_integration_token" "$json_payload"
            fi
            ;;
        *"Game server connected"*)
            type=server_up
            ;;
        *"OnApplicationQuit"*)
            type=server_down
            ;;
        *"Connections"*)
            type=active_player
            Connections=$(echo "$line" | sed -E 's/.*Connections ([0-9]+).*/\1/')
            ;;
        *)
            continue
            ;;
    esac

    echo
done