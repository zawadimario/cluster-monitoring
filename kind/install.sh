#!/bin/bash

exec > >(tee ~/cluster-monitoring/kind/install.log) 2>&1

kind create cluster --config ~/cluster-monitoring/kind/cluster.yaml

sleep 3

cluster="kind"

for c in $(docker ps --format '{{.Names}}' | grep "$cluster"); do
  echo "=================================="
  echo "Running on container: $c"
  echo "=================================="

  docker exec "$c" /bin/bash -c \
    "sysctl -w net.ipv6.conf.all.forwarding=1 && \
     sysctl -w net.ipv6.conf.default.forwarding=1"

  docker exec "$c" /bin/bash -c \
    "curl -L https://github.com/containernetworking/plugins/releases/download/v1.3.0/cni-plugins-linux-arm64-v1.3.0.tgz -o /tmp/cni.tgz && \
     mkdir -p /opt/cni/bin && \
     tar -C /opt/cni/bin -xzf /tmp/cni.tgz && \
     rm /tmp/cni.tgz"

  docker exec "$c" /bin/bash -c \
    "curl -L https://github.com/projectcalico/calico/releases/download/v3.32.0/calicoctl-linux-arm64 -o /usr/bin/calicoctl && \
     chmod +x /usr/bin/calicoctl"

  docker exec "$c" /bin/bash -c \
    "apt-get update && apt-get install -y net-tools pciutils"

  docker exec "$c" /bin/bash -c "ifconfig"

  docker exec "$c" /bin/bash -c \
    "lspci -nnk | grep -i net -A 2"

  docker exec "$c" /bin/bash -c \
    "lspci -nn | grep -i Ethernet"

  docker exec "$c" /bin/bash -c \
    "ip6tables -t nat -A POSTROUTING -s fc00::/7 -j MASQUERADE"

  echo "Finished: $c"
  echo
done

sleep 20
kubectl apply -f ~/cluster-monitoring/kind/multus-thin.yaml

sleep 20
kubectl apply -f ~/cluster-monitoring/kind/calico-install.yaml

sleep 15
kubectl apply -f  ~/cluster-monitoring/cnis/sriov-device-plugin.yaml

echo "=================================="
echo "Cluster installation completed!"
echo "=================================="