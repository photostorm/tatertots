#!/bin/bash

while true; do
    ./tatertots.sh
    exit_code=$?

    if [ $exit_code -eq 0 ]; then
        echo "Script executed successfully. Restarting in 49 seconds..."
        sleep 49
    else
        echo "Error in script execution. Restarting immediately..."
    fi
done
