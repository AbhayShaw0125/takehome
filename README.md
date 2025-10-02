# EWMA Calculator Application
  A web application for calculating Exponentially Weighted Moving Averages (EWMA) and simple averages.
  Built with FastAPI backend and React frontend. The application is containerized with Docker and deployed on a local K8s cluster using Kind.

## Repository layout 

  ```
├── backend/                 # FastAPI backend service
│   ├── app/
│   │   ├── main.py          # Application entry point
│   │   ├── routers/         # API route handlers
│   │   ├── schemas.py       # Pydantic models
│   │   └── services.py      # Business logic
│   ├── tests/               # Backend tests
│   ├── Dockerfile           # Backend container image
│   └── requirements.txt     # Python dependencies
│
├── frontend/                # Frontend application (React + Vite + TS)
│   ├── src/
│   │   ├── assets/          # Static assets (images, fonts, icons, etc.)
│   │   ├── components/      # Reusable UI components
│   │   ├── api/             # API calls 
│   │   ├── types/           # Shared types/interfaces
│   │   ├── App.tsx          # Root component
│   │   └── main.tsx         # Entry point
│   │
│   ├── public/              # Public static files
│   │   └── favicon.ico
│   │
│   ├── Dockerfile           # Frontend Docker image
│   ├── index.html           # Root HTML file
│   ├── package.json
│   ├── tsconfig.json
│   ├── tsconfig.app.json
│   ├── tsconfig.node.json
│   ├── vite.config.ts
│   ├── eslint.config.js
│   ├── .gitignore
│   └── README.md
│
├── k8s/                     # Kubernetes configurations
│   └── ewma-calculator/     # Helm chart
│       ├── templates/       # K8s resource templates
│       ├── values.yaml      # Default values
│       ├── values-staging.yaml
│       └── values-production.yaml
│
├── scripts/                 # Automation scripts
│   ├── build_images.sh      # Build Docker images
│   ├── push_images.sh       # Push images to Docker Hub
│   ├── test_backend.sh      # Run backend tests
│   ├── test_frontend.sh     # Test and build frontend
│   └── deploy.sh            # Deploy to Kubernetes (Kind in this case)
│
└── .github/workflows/       # CI/CD pipeline
    └── main.yml             # GitHub Actions workflow
```

## Prerequisites
- Docker
- kubectl
- Helm 3
- Kind (for local deployment)
- Python 3.12+ (for local development)
- Node.js 18+ (for local development)

## Local Development
### Backend
```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload
```
### Frontend
```bash
cd frontend
npm install
npm run dev
```
## Running Tests
#### Backend Tests
```bash
bash scripts/test_backend.sh
```
#### Frontend Tests
```bash
bash scripts/test_frontend.sh
```
#### Building Docker Images
```bash
bash scripts/build_images.sh
```
#### Pushing to Docker Hub
```
bash scripts/push_images.sh
```
### Deploy locally using Docker Compose
In the root directory of this repo, there is a docker-compose.yaml file.
Run the command below to locally run the application.
```bash
docker compose up
```
Frontend accessible at localhost:5173 and backend at localhost:8000

## CI Pipeline
The GitHub Actions workflow automatically:
1. Runs backend tests
2. Runs frontend tests and builds
3. Builds Docker images with appropriate tags
4. Pushes images to Docker Hub

#### Triggered on:
1. Push to main branch
2. Manual worklow dispatch

## Deployment 
#### One-command Deployment
```bash
bash scripts/deploy.sh
```
This script will:
1. Install Kind and Helm (if not present)
2. Create a Kind cluster
3. Deploy staging environment
4. Deploy production environment
5. Set up port forwarding (for local testing)
### Access the application at :
1. Staging
   - Frontend: http://localhost:4000
   - Backend:  http://localhost:9000
2. Production :
   - Frontend: http://localhost:3000
   - Backend: http://localhost:8000
## Manual Deployment
#### Create Cluster
```bash
kind create cluster --config k8s/ewma-calculator/kind-config.yaml --name ewma-cluster
```
#### Deploying Staging
```bash
cd k8s/ewma-calculator
helm upgrade --install ewma-staging . \
  --values values-staging.yaml \
  --wait
```
To see all running resources inside the staging namespace, run the command below
```bash
kubectl get all -n staging
```
#### Deploy Production
```bash
helm upgrade --install ewma-production . \
  --values values-production.yaml \
  --wait
```
To see all running resources inside the production namespace, run the command below
```bash
kubectl get all -n production
```
#### To test locally
Port forward to access locally
1. Frontend
```bash
kubectl port-forward -n staging svc/frontend-service 5173(any_port):80
```
2. Backend
```bash
kubectl port-forward -n staging svc/backend-service 8000(any_port):80
```
The same can be followed for production, just replace **staging** with **production**

#### For Health check
###### Test health endpoint
```bash
curl http://localhost:8000/health
```
Should return: {"status":"healthy"}

### Clean Up
Remove the Kind cluster
```bash
kind delete cluster --name ewma-cluster
```

### Extras
🔎 Role of Metrics Server in HPA
    - Metrics Server provides live CPU and memory usage data from pods via the metrics.k8s.io API, which the Horizontal Pod Autoscaler (HPA) uses to scale workloads up or down.

> ⚠️ **Important:** Without Metrics Server, HPA cannot fetch CPU/memory usage.

#### Command to Install Metric Server
Will use Helm to install metric server
1. Add Metrics Server repo
   ```bash
   helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
   ```
   This tells Helm where to find the metrics-server chart.
2. Update Helm repos
   ```bash
   helm repo update
   ```
   Ensures you have the latest charts from all configured repositories.
3. Skipping TLS verification
   ```bash
   helm up
   grade --install metrics-server metrics-server/metrics-server \ -n kube-system \ --set args={--kubelet-insecure-tls}
   ```
By default metric server uses TLS to connect to Kubelets.
But since we are using a local environment Kind, kubelets don't have valid certificates, so we need the above command to bypass TLS verification
   
   






