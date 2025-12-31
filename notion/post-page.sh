#!/bin/bash

method=$1
token=$2
payload=$3
page_id=$4

url="https://api.notion.com/v1/pages"
if [ -n "$page_id" ]; then
    echo "Updating page $page_id"
    url="$url/$page_id"
fi

curl "$url" \
    -X "$method" \
    -H "Authorization: Bearer $token" \
    -H "Content-Type: application/json" \
    -H "Notion-Version: 2022-06-28" \
    --data "$payload"