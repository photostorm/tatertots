#!/bin/bash

source miner.conf
declare -A initial_lifetime_blocks

echo -e "\nPicture this: \e[38;2;139;69;19mPotatoes mining starch in a starch mine. Delightful, isn't it?\e[0m\n"

tip_color() {
    local hex=$1
    R=$(printf "%d\n" 0x"${hex:1:2}")
    G=$(printf "%d\n" 0x"${hex:3:2}")
    B=$(printf "%d\n" 0x"${hex:5:2}")
}

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
    local submit_hash=$(curl -s -w "%{http_code}" -X POST -H "Content-Type: application/json" -d "{\"hash\": \"$new_hash\", \"miner_id\": \"$miner_id\", \"color\": \"$hex\"}" "$host/submit_block")
    local http_status="${submit_hash: -3}"
    if [[ "$http_status" =~ ^2 ]]; then
        echo "🥔 Response Code: $http_status 👍"
        printf "Submitted Block Hash: \e[38;2;${R};${G};${B}m$new_hash\e[0m\n"
    else
        echo "API Request failed with HTTP response code: $http_status"
    fi
}

mine() {
    local query_tip=$(curl -s "$host/blockchain_config")
    local current_hash=$(echo "$query_tip" | jq -r '.last_block.hash')
    local current_color=$(echo "$query_tip" | jq -r '.last_block.color')
    local block_id=$(echo "$query_tip" | jq -r '.last_block.id')
    if [ "$current_hash" != "$last_hash_result" ]; then
        last_hash_result="$current_hash"
        tip_color "$current_color"
        printf "Chain extended, new tip: #$block_id \n"; printf "\e[38;2;${R};${G};${B}m$current_hash\e[0m\n"; printf "\n"
        for miner_id in "${miner_ids[@]}"; do
            local query_miner=$(curl -s "$host/miner/$miner_id")
            local balance=$(echo "$query_miner" | jq -r '.balance')
            local blocks=$(echo "$query_miner" | jq -r '.blocks')
            if [ -z "${initial_lifetime_blocks["$miner_id"]}" ]; then
                initial_lifetime_blocks["$miner_id"]=$blocks
            fi
            gen_color
            gen_hash "$last_hash_result" "$miner_id" "$hex"
            submit "$miner_id"
            printf "Tatertot: Mining for $miner_id with color \e[38;2;${R};${G};${B}m$hex\e[0m\n"
            local initial_value="${initial_lifetime_blocks["$miner_id"]}"
            local changes=$((blocks - initial_value))
            printf "Miner balance: \e[38;2;${R};${G};${B}m$balance\e[0m"; printf ", Lifetime blocks: \e[38;2;${R};${G};${B}m$blocks\e[0m";  printf ", Since startup: \e[38;2;${R};${G};${B}m$changes\e[0m\n"
            printf "\n"
        done
        echo "Sleeping for 49 seconds."
    else
        echo -e "Starch chain hash has not changed.\nSleeping for 49 seconds.\n"
    fi
}

while true; do mine; sleep 49; done
