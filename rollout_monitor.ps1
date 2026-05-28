# Stop executing if any command fails
$ErrorActionPreference = "Stop"

# Configuration variables
$Namespace = "monitoring"

Write-Host " Starting Deployment Workflow for Alloy" -ForegroundColor Cyan
helm upgrade --install alloy grafana/alloy -f alloy.yaml -n $Namespace

Write-Host " Starting Deployment Workflow for Loki" -ForegroundColor Cyan
helm upgrade --install loki grafana/loki -f lokivalues.yaml -n $Namespace

Write-Host " Starting Deployment Workflow for Grafana" -ForegroundColor Cyan
helm upgrade --install grafana grafana/grafana -n $Namespace

# --- NEW: WAIT MECHANISM ---
Write-Host "Waiting for Grafana pods to be ready..." -ForegroundColor Yellow
# This pauses the script until the pods with the 'app.kubernetes.io/name=grafana' label are Ready
kubectl wait --namespace $Namespace `
    --for=condition=ready pod `
    --selector=app.kubernetes.io/name=grafana `
    --timeout=120s

Write-Host "final pod status:" -ForegroundColor Green
kubectl get pods -n $Namespace

Write-Host "Port forwarding for Grafana (Access at http://localhost:3000)" -ForegroundColor Cyan
kubectl port-forward -n $Namespace svc/grafana 3000:80