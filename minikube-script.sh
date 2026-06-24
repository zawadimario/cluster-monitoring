# !/usr/bin/env bash
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
minikube start --cpus=8 --memory=11.5g --disk-size=56g --driver=docker --container-runtime=docker --cni=~/cluster-monitoring/cnis/calico-install.yaml

# minikube start --ha --cpus=8 --memory=11.5g --disk-size=56g --driver=docker --container-runtime=docker --cni=~/cluster-monitoring/cnis/calico-install.yaml
minikube node add --worker=true && minikube node add --worker=true

# 1. Fetch node names, excluding the header
nodes=$(kubectl get nodes -o custom-columns=NAME:.metadata.name --no-headers)

# Define the commands to run
cmd_install_calico="sudo curl -L https://github.com/projectcalico/calico/releases/download/v3.32.0/calicoctl-linux-arm64 -o /usr/bin/calicoctl && sudo chmod +x /usr/bin/calicoctl"
cmd_install_tools="sudo apt-get update && sudo apt-get install -y net-tools pciutils"
cmd_etcd="sudo curl -L https://storage.googleapis.com/etcd/v3.6.0/etcd-v3.6.0-linux-arm64.tar.gz -o /tmp/etcd.tar.gz && \
          sudo tar -xvzf /tmp/etcd.tar.gz -C /tmp/ && \
          sudo mv /tmp/etcd-v3.6.0-linux-arm64/etcd /usr/bin/etcd && \
          sudo mv /tmp/etcd-v3.6.0-linux-arm64/etcdctl /usr/bin/etcdctl && \
          sudo mv /tmp/etcd-v3.6.0-linux-arm64/etcdutl /usr/bin/etcdutl && \
          sudo rm -rf /tmp/etcd* && sudo etcdctl version"
cmd_check_net="sudo ifconfig && lspci -nnk | grep -i net -A 2 && lspci"

for node in $nodes; do
    echo "======================================="
    echo "*** Configuring node: $node "
    echo "======================================="
    
    # Determine the SSH command prefix
    # If the node is just 'minikube', we don't pass the --node flag
    if [ "$node" == "minikube" ]; then
        ssh_cmd="minikube ssh"
    else
        ssh_cmd="minikube ssh --node $node"
    fi

    # Run the commands
    $ssh_cmd "$cmd_install_calico"
    $ssh_cmd "$cmd_install_tools"
    $ssh_cmd "$cmd_etcd"
    $ssh_cmd "$cmd_check_net"
done

echo "========================================"
echo "*** Nodes Configured Successfully ******"
echo "========================================"

sleep 5
kubectl apply -f ~/cluster-monitoring/cnis/installs/multus-thin.yaml
sleep 5
kubectl apply -f ~/cluster-monitoring/cnis/installs/sriov-device-plugin.yaml
