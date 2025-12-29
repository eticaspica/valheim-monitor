#!/bin/bash

database_id=$1
title=$2

cat << EOF
{
    "parent": {
        "type": "database_id",
        "database_id": "$database_id"
    },
    "properties": {
        "raw": {
            "type": "title",
            "title": [
                {
                    "type": "text",
                    "text": {
                        "content": "$title"
                    }
                }
            ]
        }
    }
}
EOF