#!/bin/bash

source miner.conf
declare -g last_hash_result=""

echo -e "\nPicture this: Potatoes mining starch in a starch mine. Delightful, isn't it?"

gen_color() {
    R=$((RANDOM % 256))
    G=$((RANDOM % 256))
    B=$((RANDOM % 256))
    hex=$(printf "#%02x%02x%02x" $R $G $B)
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
    if [[ "$http_status" =~ ^2 ]]; then
        echo -e "API Response Code: $http_status\nSubmitted Block Hash: $new_hash"
    else
        echo "API Request failed with HTTP response code: $http_status"
    fi
}

mine() {
    local current_hash=$(curl -s "$host/blockchain_config" | jq -r '.last_block.hash')
    if [ "$current_hash" != "$last_hash_result" ]; then
        last_hash_result="$current_hash"
        echo -e "\nNew chain hash detected!"
        echo -e "Starch chain hash: $last_hash_result\n"
        for miner_id in "${miner_ids[@]}"; do
            gen_color
            gen_hash "$last_hash_result" "$miner_id" "$hex"
            submit "$miner_id"
            printf "\e[38;2;${R};${G};${B}mTatertot: Mining for AA45ED46 with ${hex}\e[0m\n"
            printf "\n"
        done
        echo "Sleeping for 30 seconds."
    else
        echo "Starch chain hash has not changed. Sleeping for 30 seconds."
    fi
}

while true; do mine; sleep 30; done
