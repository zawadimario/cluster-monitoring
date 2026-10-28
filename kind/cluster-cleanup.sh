#!/bin/bash

cluster="kind"

for container in $(docker ps --format '{{.Names}}' | grep "$cluster"); do
    if docker stop "$container" >/dev/null; then
        echo "Stopped: $container";
        docker rm -v -f "$container" >/dev/null;
    else
        echo "Failed to stop: $container"
    fi
done

echo "=================================="
echo "Cluster Cleanup successful!"
echo "=================================="