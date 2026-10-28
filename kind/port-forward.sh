#!/usr/bin/env bash

# 1. Catch Ctrl+C (SIGINT) and termination (SIGTERM) signals.
# 2. Clear the trap immediately to prevent an infinite crash loop.
# 3. Kill PID 0 to terminate every process in this script's group.
trap 'trap - SIGINT SIGTERM EXIT && kill 0' SIGINT SIGTERM EXIT

# Start your background port-forwards
echo "Starting Kubernetes port-forwards..."
kubectl port-forward -n observability svc/alertmanager 9093:9093 &
kubectl port-forward -n observability svc/grafana 3000:3000 &
kubectl port-forward -n observability svc/prometheus 9090:9090 &
kubectl port-forward -n observability svc/cadvisor 8080:8080 &
kubectl port-forward -n kube-system svc/kubernetesui-headlamp 8000:80 &

echo "Port-forwards are running. Press Ctrl+C to stop all of them."

# Wait indefinitely so the script stays active to catch your Ctrl+C
wait
