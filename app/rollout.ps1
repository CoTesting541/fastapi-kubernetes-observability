# Stop executing if any command fails
$ErrorActionPreference = "Stop"

# Configuration variables
$ImageTag = "user-service:v1"
$ClusterName = "platform"
$Deployment = "user-service"
$Namespace = "dev"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "🚀 Starting Deployment Workflow for $Deployment" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 1. Build the Docker image
Write-Host "Building Docker image" -ForegroundColor Yellow
docker build -t $ImageTag .

# 2. Import the image into k3d
Write-Host "Importing k3d cluster '$ClusterName'..." -ForegroundColor Yellow
k3d image import $ImageTag -c $ClusterName

# 3. Trigger the Kubernetes rollout
Write-Host "Restart deployment in ns '$Namespace'..." -ForegroundColor Yellow
kubectl rollout restart deployment/$Deployment -n $Namespace

Write-Host "Complete, Streaming logs and watching pods..." -ForegroundColor Green

# 4. Launch streaming logs in a dedicated new window, then watch pods here
Start-Process powershell -ArgumentList "-NoExit", "-Command", "kubectl logs deployment/$Deployment -n $Namespace -f"

# Watch the pods in your original terminal window
kubectl get pods -n $Namespace -w