# cluster-monitoring
This is a simple deployment for Kubernetes Cluster Monitoring

### Components
1. cAdvisor
2. Prometheus
3. Alertmanager
4. Grafana

### Installation
To install this minimal solution simply run the following.
```
kubectl create ns observability
kustomize build | kubectl apply -f -
```
Check if all pods are up and running as expected.
```
kubectl get po -n observability
```
### Endpoints
All components are accessible via the web but you basically need only Grafana, Prometheus and optionally, alert manager.

Obtain the K8s SVCs for the endpoints.
```
kubectl get svc -n observability
```
You should see alertmanager, cadvisor, grafana and prometheus services.

### Access UIs
#### Prometheus
```
kubectl port-forward -n observability svc/prometheus 9090:9090
```
#### Grafana
```
kubectl port-forward -n observability svc/grafana 3000:3000
```
Use admin/admin to login

#### Alertmanager
```
kubectl port-forward -n observability svc/alertmanager 9093:9093
```
#### cAdvisor
```
kubectl port-forward -n observability svc/cadvisor 8000:8080
```