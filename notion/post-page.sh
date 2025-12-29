#!/bin/bash

token=$1
payload=$2

curl 'https://api.notion.com/v1/pages' \
    -H 'Authorization: Bearer '"$token"'' \
    -H "Content-Type: application/json" \
    -H "Notion-Version: 2022-06-28" \
    --data "$payload"