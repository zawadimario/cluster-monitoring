#!/bin/bash

cluster="kind"

for container in $(docker ps -a --format '{{.Names}}' | grep "$cluster"); do
    if docker unpause "$container" >/dev/null; then
        echo "Unaused: $container"
    else
        echo "Failed to unpause: $container"
    fi
done

echo "=================================="
echo "Cluster Resumed successfully!"
echo "=================================="