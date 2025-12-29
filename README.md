# GitOps Portfolio Project

A comprehensive GitOps-based infrastructure and application management project demonstrating modern DevOps practices.

![GitOps](https://img.shields.io/badge/GitOps-ArgoCD-blue)
![IaC](https://img.shields.io/badge/IaC-Terraform-purple)
![K8s](https://img.shields.io/badge/Orchestration-Kubernetes-blue)
![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-black)
![Policy](https://img.shields.io/badge/Policy-OPA%20Gatekeeper-orange)

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Git Repository (Source of Truth)              │
├─────────────────────────────────────────────────────────────────┤
│  App Code → GitHub Actions → Build Image → Update Manifests     │
│                                                                  │
│  Infrastructure (Terraform) ──→ Kubernetes Cluster              │
│  K8s Manifests ──→ ArgoCD ──→ Deploy to Cluster                │
│  OPA Policies ──→ Gatekeeper ──→ Enforce Compliance            │
└─────────────────────────────────────────────────────────────────┘
```

## 🛠️ Technologies

| Component | Technology | Purpose |
|-----------|------------|---------|
| Infrastructure | Terraform | Provision Kubernetes cluster |
| Orchestration | Kubernetes (kind) | Container orchestration |
| GitOps | ArgoCD | Continuous deployment from Git |
| CI/CD | GitHub Actions | Build and test automation |
| Policy | OPA Gatekeeper | Security policy enforcement |
| Config | Kustomize | Environment-specific configs |

## 📁 Project Structure

```
├── apps/                    # Sample applications
│   └── sample-api/          # Node.js REST API
├── kubernetes/              # K8s manifests
│   ├── base/               # Base configurations
│   └── overlays/           # Environment overrides
├── argocd/                  # ArgoCD configurations
├── terraform/               # Infrastructure as Code
├── policies/                # OPA Gatekeeper policies
└── .github/workflows/       # CI/CD pipelines
```

## 🚀 Quick Start

### Prerequisites

- Docker Desktop
- kubectl
- kind (Kubernetes in Docker)
- Terraform
- ArgoCD CLI (optional)

### 1. Create Local Kubernetes Cluster

```bash
# Create kind cluster
kind create cluster --name gitops-demo --config terraform/kind-config.yaml

# Verify cluster
kubectl cluster-info
kubectl get nodes
```

### 2. Install ArgoCD

```bash
# Create namespace and install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f argocd/install/

# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Port forward to access UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Access ArgoCD UI at: https://localhost:8080

### 3. Deploy Applications

```bash
# Apply the App of Apps
kubectl apply -f argocd/applications/app-of-apps.yaml

# Watch ArgoCD sync the applications
argocd app list
```

### 4. Install OPA Gatekeeper

```bash
# Install Gatekeeper
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml

# Apply policies
kubectl apply -f policies/templates/
kubectl apply -f policies/constraints/
```

## 🔄 GitOps Workflow

1. **Developer** pushes code changes to Git
2. **GitHub Actions** builds and tests the application
3. **Container image** is pushed to Docker Hub
4. **Manifest** is updated with new image tag
5. **ArgoCD** detects the change and syncs to cluster
6. **OPA Gatekeeper** validates against policies
7. **Application** is deployed if compliant

## 🌍 Multi-Environment Strategy

| Environment | Branch | Sync Policy | Purpose |
|-------------|--------|-------------|---------|
| Dev | develop | Auto-sync | Development testing |
| Staging | main | Auto-sync | Pre-production |
| Prod | main + tag | Manual | Production |

## 🔒 Policy Enforcement

OPA Gatekeeper enforces:
- ✅ Required labels on all resources
- ✅ Resource limits (CPU/Memory)
- ✅ No privileged containers
- ✅ Required health probes

## 🔥 Disaster Recovery

With GitOps, recovery is straightforward:

1. Provision new cluster
2. Install ArgoCD
3. Point to Git repository
4. ArgoCD auto-syncs all applications

**Recovery Time: < 30 minutes**

## 📚 Documentation

- [Architecture Details](docs/architecture.md)
- [Disaster Recovery Runbook](docs/disaster-recovery.md)
- [Policy Reference](docs/policies.md)

## 📝 License

MIT License - feel free to use this for your own portfolio!
