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









