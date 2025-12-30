#!/bin/bash

set -a
source .env
set +a

journalctl -u $valheimd -f --since now --no-pager | 
while read -r line; do

    case "$line" in
        *"Got character ZDOID"*)
            ;;
        *"Destroying abandoned non persistent"*)
            ;;
        *"Game server connected"*)
            ;;
        *"OnApplicationQuit"*)
            ;;
        *"Connections"*)
            ;;
        *)
            continue
            ;;
    esac

    json_payload=$(./notion/make-payload.sh "$notion_database_id" "$line")

    ./notion/post-page.sh "$notion_integration_token" "$json_payload"
    echo
done