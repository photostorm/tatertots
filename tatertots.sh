#!/bin/bash

source miner.conf
declare -g last_hash_result=""

echo -e "\nPicture this: Potatoes mining starch in a starch mine. Delightful, isn't it?"

gen_color() {
    echo -n "#"
    for i in {1..6}; do
        rand=$((RANDOM % 16))
        printf "%X" "$rand"
    done
}

hex_to_ansi() {
    hex=$1
    decimal=$(printf "%d" 0x${hex:1:6})
    ansi=$(( (decimal % 6) + 16 ))
    echo "$ansi"
}


gen_hash() {
    local last_hash=$1 miner_id=$2 color=$3
    local string="$last_hash $miner_id $color"
    command -v sha256sum &> /dev/null && new_hash=$(echo -n "$string" | sha256sum | cut -d ' ' -f 1) || new_hash=$(echo -n "$string" | shasum -a 256 | cut -d ' ' -f 1)
}

submit() {
    local miner_id=$1 retries=3
    local submit_hash=$(curl -s -w "%{http_code}" -X POST -H "Content-Type: application/json" -d "{\"hash\": \"$new_hash\", \"miner_id\": \"$miner_id\", \"color\": \"$color\"}" "$host/submit_block")
    local http_status="${submit_hash: -3}"
    if [ "$http_status" -eq 200 ]; then
        echo -e "API Response Code: $http_status\nSubmitted Block Hash: $new_hash"
    else
        echo "API Request failed with HTTP response code: $http_status"
    fi
}

mine() {
    local query_tip=$(curl -s "$host/blockchain_config")
    local current_hash=$(echo "$query_tip" | jq -r '.last_block.hash')
    if [ "$current_hash" != "$last_hash_result" ]; then
        last_hash_result="$current_hash"
        echo -e "\nNew chain hash detected!"
        echo -e "Starch chain hash: $last_hash_result\n"
        for miner_id in "${miner_ids[@]}"; do
            local color=$(gen_color)
            ansi_color=$(hex_to_ansi "$color")
            gen_hash "$last_hash_result" "$miner_id" "$color"
            submit "$miner_id"
            echo -e "\e[38;5;${ansi_color}mTatertot: Mining for $miner_id with $color\e[0m\n"
        done
        echo "Sleeping for 30 seconds."
    else
        echo "Starch chain hash has not changed. Sleeping for 30 seconds."
    fi
}

while true; do mine; sleep 30; done