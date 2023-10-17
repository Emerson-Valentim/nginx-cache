#!/bin/bash
content=$(cat ../docker/cache.conf)

encoded_content=$(echo -n "$content" | base64)

cat <<EOL
{
  "base64_encoded_content": "$encoded_content"
}
EOL