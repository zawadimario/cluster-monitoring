# cluster-monitoring
This is a simple deployment for Kubernetes Cluster Monitoring. All configurations contained in this repository are for testing purposes only. We are not liable to any issues encountered apart from the basic idea that these manifests should deploy something that is working. Proceed with utmost caution.

### Components
1. cAdvisor
2. Prometheus
3. Alertmanager
4. Grafana
5. Optional OpenLDAP Server with users (**note that this is purely for testing**).
6. Headlamp comparison

### Installation
To install this minimal solution simply run the following.

Install OpenLDAP (optional) if you are going to use it. Everything is pre-configured.

```
kubectl create ns auth
kustomize build openldap | kubectl apply -f -
```

If you installed OpenLDAP, ensure to modify `kustomization.yaml` file to include `6-grafana-ldap.yaml`. Otherwise skip the previous step and this to the next one.

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