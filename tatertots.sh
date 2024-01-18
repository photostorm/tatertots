#!/bin/bash

source miner.conf
gen_color() { printf "#%06X\n" $((RANDOM % 0xFFFFFF)); }

gen_hash() {
    local last_hash=$1 miner_id=$2 color=$3
    local string="$last_hash $miner_id $color"
    command -v sha256sum &> /dev/null && local new_hash=$(echo -n "$string" | sha256sum | cut -d ' ' -f 1) || local new_hash=$(echo -n "$string" | shasum -a 256 | cut -d ' ' -f 1)
    hash_result="$new_hash" miner_id_result="$miner_id" color_result="$color"
}

submit() {
    local miner_id=$1 retries=3
    for ((i=0; i<$retries; i++)); do
        local result=$(curl -s "$host/blockchain_config")
        last_hash_result=$(echo "$result" | jq -r '.last_block.hash')
        echo "Last Hash: $last_hash_result"
        local color=$(gen_color)
        gen_hash "$last_hash_result" "$miner_id" "$color"
        local response=$(curl -s -w "%{http_code}" -X POST -H "Content-Type: application/json" -d "{\"hash\": \"$hash_result\", \"miner_id\": \"$miner_id_result\", \"color\": \"$color_result\"}" "$host/submit_block")
        http_status="${response: -3}"
        [ "$http_status" -eq 200 ] && { echo -e "API Response Code: $http_status\nNew Hash: $hash_result"; return; } || { echo "Attempt $((i+1)) failed - API Request failed with HTTP response code: $http_status"; sleep 1; }
    done
}

mine() {
    for miner_id in "${miner_ids[@]}"; do
        submit "$miner_id"
        script_pid=$$
        memory_usage=$(ps -p $script_pid -o rss=)
        echo "Memory usage of the script: ${memory_usage} KB"
        echo -e "$(tput setaf 2)Tatertots: mining for $miner_id_result with $color_result$(tput sgr0)\n"
    done
}

while true; do mine; sleep 49; done
