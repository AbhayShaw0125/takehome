#!/bin/bash
set -e

# ========================================
# Paths
# ========================================
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"   # go one level up from scripts/
KIND_CONFIG="$REPO_ROOT/k8s/ewma-calculator/kind-config.yaml"
CHART_DIR="$REPO_ROOT/k8s/ewma-calculator"

# ========================================
# 0. Install dependencies if missing
# ========================================
install_kind() {
  if ! command -v kind &> /dev/null; then
    echo "📦 Installing Kind..."
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
  else
    echo "✅ Kind already installed"
  fi
}

install_helm() {
  if ! command -v helm &> /dev/null; then
    echo "📦 Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  else
    echo "✅ Helm already installed"
  fi
}

# ========================================
# 1. Setup Cluster
# ========================================
setup_cluster() {
  echo "📦 Creating Kind cluster..."
  kind create cluster --config "$KIND_CONFIG" --name ewma-cluster
}

# ========================================
# 2. Deploy Staging (first)
# ========================================
deploy_staging() {
  echo "🚀 Deploying ewma-staging..."
  cd "$CHART_DIR"
  helm upgrade --install ewma-staging . \
    --values values-staging.yaml \
    --wait 
  cd "$REPO_ROOT"
}

# ========================================
# 3. Deploy Production (second)
# ========================================
deploy_production() {
  echo "🚀 Deploying ewma-production..."
  cd "$CHART_DIR"
  helm upgrade --install ewma-production . \
    --values values-production.yaml \
    --wait 
  cd "$REPO_ROOT"
}

# ========================================
# 4. Port Forward
# ========================================
port_forward() {
  echo "🌐 Setting up port-forwards..."
  # Staging
  kubectl port-forward -n staging svc/frontend-service 4000:80 &
  kubectl port-forward -n staging svc/backend-service 9000:80 &
  # Production
  kubectl port-forward -n production svc/frontend-service 3000:80 &
  kubectl port-forward -n production svc/backend-service 8000:80 &
  
  echo ""
  echo "✅ Deployments complete!"
  echo "   Staging:    http://localhost:4000 (frontend), http://localhost:9000 (backend)"
  echo "   Production: http://localhost:3000 (frontend), http://localhost:8000 (backend)"
  echo ""
  echo "Press Ctrl+C to stop port-forwards."
  wait
}

# ========================================
# MAIN SCRIPT (calls)
# ========================================
install_kind
install_helm
setup_cluster
deploy_staging
deploy_production
port_forward
