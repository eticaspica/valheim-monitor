#!/bin/bash

database_id=$1
line=$2
type=$3
ZDOID=$4
viking=$5

cat << EOF
{
    "parent": {
        "type": "database_id",
        "database_id": "$database_id"
    },
    "icon": {
        "emoji": "👋"
    },
    "properties": {
        "title": {
            "title": [
                {
                    "text": {
                        "content": "$viking is $type"
                    }
                }
            ]
        },
        "type": {
            "select": {
                "name": "$type"
            }
        },
        "viking": {
            "rich_text": [
                {
                    "text": {
                        "content": "$viking"
                    }
                }
            ]
        },
        "stdout": {
            "rich_text": [
                {
                    "text": {
                        "content": "$line"
                    }
                }
            ]
        }
    }
}
EOF