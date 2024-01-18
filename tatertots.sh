#!/bin/bash

source miner.conf
gen_color() { printf "#%06X\n" $((RANDOM % 0xFFFFFF)); }
declare -g last_hash_result=""

gen_hash() {
    local last_hash=$1 miner_id=$2 color=$3
    local string="$last_hash $miner_id $color"
    command -v sha256sum &> /dev/null && local new_hash=$(echo -n "$string" | sha256sum | cut -d ' ' -f 1) || local new_hash=$(echo -n "$string" | shasum -a 256 | cut -d ' ' -f 1)
    hash_result="$new_hash" miner_id_result="$miner_id" color_result="$color"
}

submit() {
    local miner_id=$1 retries=3
    local response=$(curl -s -w "%{http_code}" -X POST -H "Content-Type: application/json" -d "{\"hash\": \"$hash_result\", \"miner_id\": \"$miner_id_result\", \"color\": \"$color_result\"}" "$host/submit_block")
    local http_status="${response: -3}"
    if [ "$http_status" -eq 200 ]; then
        echo -e "API Response Code: $http_status\nNew Hash: $hash_result"
    else
        echo "API Request failed with HTTP response code: $http_status"
    fi
}

mine() {
    local result=$(curl -s "$host/blockchain_config")
    local new_last_hash_result=$(echo "$result" | jq -r '.last_block.hash')
    if [ "$new_last_hash_result" != "$last_hash_result" ]; then
        last_hash_result="$new_last_hash_result"
        echo "Last Hash: $last_hash_result"
        for miner_id in "${miner_ids[@]}"; do
            local color=$(gen_color)
            gen_hash "$last_hash_result" "$miner_id" "$color"
            submit "$miner_id"
            script_pid=$$
            memory_usage=$(ps -p $script_pid -o rss=)
            echo "Memory usage of the script: ${memory_usage} KB"
            echo -e "$(tput setaf 2)Tatertots: mining for $miner_id_result with $color_result$(tput sgr0)\n"
        done
    else
        echo "Last Hash has not changed. Skipping submission."
    fi
}

while true; do mine; sleep 20; done
