#!/bin/bash

cluster="kind"

for container in $(docker ps --format '{{.Names}}' | grep "$cluster"); do
    if docker pause "$container" >/dev/null; then
        echo "Paused: $container"
    else
        echo "Failed to Unpause: $container"
    fi
done
echo "=================================="
echo "Cluster Paused successfully!"
echo "=================================="