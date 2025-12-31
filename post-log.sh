#!/bin/bash

set -a
source .env
set +a

reg_login_ZDOID='s/.*: ([0-9]+):[0-9]+/\1/'
reg_ZDOID_gen='s/.*: [0-9]+:([0-9]+)/\1/'
reg_logout_ZDOID='s/.*zdo ([0-9]+):[0-9]+.*/\1/'
reg_viking='s/.*from ([^ ]+).*/\1/'
reg_conn='s/.*Connections ([0-9]+).*/\1/'

journalctl -f --no-pager \
    -u $valheimd \
    -o cat \
    --since now |
while read -r line; do
    case "$line" in
        *"Got character ZDOID"*)
            method="POST"
            dtz=$(date -Iseconds)
            ZDOID=$(echo "$line" | sed -E "$reg_login_ZDOID")
            gen=$(echo "$line" | sed -E "$reg_ZDOID_gen")
            viking=$(echo "$line" | sed -E "$reg_viking")

            if [ "$ZDOID" == "0" ]; then
                echo "Ignoring ZDOID 0 for viking $viking"
                continue
            fi

            if [ "$gen" != "1" ]; then
                echo "Ignoring non-persistent viking $viking with ZDOID $ZDOID and gen $gen"
                continue
            fi

            json_payload=$(
                database_id="$notion_database_id" \
                dtz="$dtz" \
                viking="$viking" \
                envsubst < notion/login.json
            )

            page_id=$(
                ./notion/post-page.sh \
                    "$method" \
                    "$notion_integration_token" \
                    "$json_payload" |
                jq -r '.id'
            )

            jq  -nc \
                --arg viking "$viking" \
                --arg page_id "$page_id" \
                --arg dtz "$dtz" \
                '{"viking": $viking, "page_id": $page_id, "dtz": $dtz}' > viking/"$ZDOID"
            ;;
        *"Destroying abandoned non persistent"*)
            ZDOID=$(echo "$line" | sed -E "$reg_logout_ZDOID")
            if [ -f viking/"$ZDOID" ]; then
                method="PATCH"
                end_dtz=$(date -Iseconds)
                viking=$(jq -r '.viking' viking/"$ZDOID")
                page_id=$(jq -r '.page_id' viking/"$ZDOID")
                start_dtz=$(jq -r '.dtz' viking/"$ZDOID")

                json_payload=$(
                    database_id="$notion_database_id" \
                    start_dtz="$start_dtz" \
                    end_dtz="$end_dtz" \
                    viking="$viking" \
                    envsubst < notion/logout.json
                )

                ./notion/post-page.sh \
                    "$method" \
                    "$notion_integration_token" \
                    "$json_payload" \
                    "$page_id"
                rm viking/"$ZDOID"
            fi
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

    echo
done
