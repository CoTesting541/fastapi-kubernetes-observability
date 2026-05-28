# Stop executing if any command fails
$ErrorActionPreference = "Stop"

# Configuration variables
$ImageTag = "user-service:v1"
$ClusterName = "platform"
$Deployment = "user-service"
$Namespace = "dev"  

Write-Host " Starting Deployment Workflow for $Deployment" -ForegroundColor Cyan

# 1. Build the Docker image
Write-Host " Building Docker image..." -ForegroundColor Yellow
docker build -t $ImageTag ./app

# 2. Create k3d cluster if it doesn't exist
if (-not (k3d cluster list | Select-String $ClusterName)) {
    Write-Host " Creating k3d cluster '$ClusterName'..." -ForegroundColor Yellow
    k3d cluster create --config k3d-config.yaml
}
else {
    Write-Host " k3d cluster '$ClusterName' already exists. Skipping creation." -ForegroundColor Green
}

Write-Host " Creating namespaces..." -ForegroundColor Green
kubectl apply -f ./namespaces/data.yaml
kubectl apply -f ./namespaces/dev.yaml

# 3. Update kubectl context to the k3d cluster
Write-Host " Setting kubectl context to k3d cluster '$ClusterName'..." -ForegroundColor Yellow
kubectl config use-context k3d-$ClusterName

# 4. Import the image into k3d
Write-Host "Importing image into k3d cluster '$ClusterName'..." -ForegroundColor Yellow
k3d image import $ImageTag -c $ClusterName

# --- NEW: WAIT FOR APPLICATION READY ---
Write-Host " Waiting for $Deployment pods to be fully ready..." -ForegroundColor Yellow
# This targets the deployment and pauses until the underlying pods pass readiness checks
kubectl wait --namespace $Namespace `
    --for=condition=available deployment/$Deployment `
    --timeout=90s

# 5. Deploy the application using kubectl
Write-Host " Deploying all manifests to cluster '$ClusterName'..." -ForegroundColor Yellow
kubectl apply -f ./k8-configs/ 

Write-Host " $Deployment is online! Fetching active status:" -ForegroundColor Green
kubectl get pods -n $Namespace

Write-Host " Complete, Streaming logs in background..." -ForegroundColor Green

# 6. Launch streaming logs in a dedicated new window
Start-Process powershell -ArgumentList "-NoExit", "-Command", "kubectl logs deployment/$Deployment -n $Namespace -f"
