## Setup Podman Machine
Install podman
```
brew install podman
```
Initialize Podman
```
podman machine init --cpus 8 --memory 15360 --disk-size 60
```
Start Podman
```
podman machine start && podman machine ls
```
Add Podman config
```
podman machine ssh --username root
```
Modify registries file
```
vi /etc/containers/registries.conf
```

Enter the following in the registries.conf file
```
unqualified-search-registries = ["registry.fedoraproject.org", "registry.access.redhat.com", "docker.io", "registry-1.docker.io", "quay.io", "ghcr.io", "gcr.io", "registry.k8s.io", "registry.opensource.zalan.do"]
```

```
[engine]
dns = ['8.8.8.8', '8.8.4.4']
[containers]
dns = ["8.8.8.8", "1.1.1.1"]
[[registry]]
location = "ghcr.io"
insecure = true
[[registry]]
location = "pkg-containers.githubusercontent.com"
insecure = true
```
Save and exit. Restart the Podman machine
```
podman machine stop && podman machine start
```
### Setup Minikube using Podman Driver and CRIO Runtime

Create a file named minikube-init.sh
```
vi minikube-init.sh
```
Copy and paste the setup script below.
```
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
```
Run the script.
```
sh minikube-init.sh
```
Start, or restart minikube if it was already started
```
minikube start --cpus=7 --memory=12g --disk-size=50g --container-runtime=cri-o --driver=podman
```
Or
```
minikube start --driver=podman
```
Use k9s to view the cluster.
```
k9s -c pods --all-namespaces
```