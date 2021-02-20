#!/usr/bin/bash
echo $1 $2
curl -X PUT \
     --header "Content-Type: application/json" \
     -d @./$1 \
     http://localhost:4000/voice/$2
