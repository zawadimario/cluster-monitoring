#!/usr/bin/env bash
set -euo pipefail

LOCAL_MINIKUBE_DIR="${LOCAL_MINIKUBE_DIR:-$HOME/.minikube/files/etc}"
CRIO_DIR="$LOCAL_MINIKUBE_DIR/crio/crio.conf.d"
CONTAINERS_DIR="$LOCAL_MINIKUBE_DIR/containers"

mkdir -p "$CRIO_DIR" "$CONTAINERS_DIR"

cat > "$CRIO_DIR/02-insecure-registries.conf" <<EOF
[crio.image]
insecure_registries = [
  "ghcr.io",
  "pkg-containers.githubusercontent.com"
]
EOF

cat > "$CONTAINERS_DIR/registries.conf" <<EOF
unqualified-search-registries = ["registry.fedoraproject.org","registry.access.redhat.com","docker.io","registry-1.docker.io","quay.io","ghcr.io","gcr.io","registry.k8s.io","registry.opensource.zalan.do"]
[engine]
dns = ['8.8.8.8','8.8.4.4']
[containers]
dns = ["8.8.8.8","1.1.1.1"]
[[registry]]
location = "ghcr.io"
insecure = true
[[registry]]
location = "pkg-containers.githubusercontent.com"
insecure = true
EOF

echo "Config files created in $LOCAL_MINIKUBE_DIR. Restart Minikube to apply."

sleep 5

# minikube start --cpus=8 --memory=15.5g --disk-size=56g --driver=podman --container-runtime=cri-o
# minikube start --cpus=8 --memory=11.5g --disk-size=56g --driver=docker --container-runtime=cri-o
minikube start --cpus=8 --memory=11.5g --disk-size=56g --driver=docker --container-runtime=docker

sleep 3
minikube ssh "sudo curl -L https://github.com/projectcalico/calico/releases/download/v3.32.0/calicoctl-linux-arm64 -o /usr/bin/calicoctl && sudo chmod +x /usr/bin/calicoctl"

sleep 30
kubectl apply -f ~/cluster-monitoring/cnis/calico-install.yaml
sleep 60
kubectl apply -f ~/cluster-monitoring/cnis/multus-thin.yaml
# minikube node add --worker=true && minikube node add --worker=true