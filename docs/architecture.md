# Architecture Documentation

## Overview

This project implements a GitOps-based infrastructure and application management system using industry-standard tools and best practices.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         GitOps Architecture                              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌──────────────┐     ┌──────────────┐     ┌──────────────────────────┐ │
│  │  Developer   │────▶│   GitHub     │────▶│   GitHub Actions          │ │
│  │  Push Code   │     │  Repository  │     │   (CI Pipeline)          │ │
│  └──────────────┘     └──────────────┘     └──────────────────────────┘ │
│                              │                        │                  │
│                              │                        ▼                  │
│                              │              ┌─────────────────┐         │
│                              │              │   Docker Hub    │         │
│                              │              │   (Registry)    │         │
│                              │              └─────────────────┘         │
│                              ▼                        │                  │
│                    ┌───────────────────┐              │                  │
│                    │     ArgoCD        │◀─────────────┘                  │
│                    │  (GitOps Engine)  │   (Updated manifests)          │
│                    └───────────────────┘                                 │
│                              │                                           │
│           ┌──────────────────┼──────────────────┐                        │
│           ▼                  ▼                  ▼                        │
│   ┌───────────────┐  ┌───────────────┐  ┌───────────────┐               │
│   │ Dev Cluster   │  │Staging Cluster│  │ Prod Cluster  │               │
│   │   (kind)      │  │    (kind)     │  │    (kind)     │               │
│   └───────────────┘  └───────────────┘  └───────────────┘               │
│           │                  │                  │                        │
│           └──────────────────┴──────────────────┘                        │
│                              │                                           │
│                    ┌─────────────────┐                                   │
│                    │  OPA Gatekeeper │                                   │
│                    │ (Policy Engine) │                                   │
│                    └─────────────────┘                                   │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

## Component Details

### 1. Source Control (GitHub)

- **Purpose**: Single source of truth for all configurations
- **Contents**:
  - Application source code
  - Kubernetes manifests (Kustomize)
  - Terraform infrastructure code
  - ArgoCD application definitions
  - OPA policies

### 2. CI Pipeline (GitHub Actions)

| Workflow | Trigger | Actions |
|----------|---------|---------|
| `ci.yaml` | Push to app code | Test, Build, Push image, Update manifests |
| `terraform.yaml` | Push to terraform/ | Validate, Plan, (Apply) |
| `policy-check.yaml` | PR to kubernetes/ | Validate manifests, Test policies |

### 3. Container Registry (Docker Hub)

- Stores built container images
- Images tagged with: SHA, version, and `latest`
- Integrated with CI pipeline

### 4. GitOps Engine (ArgoCD)

**Pattern Used**: App of Apps

```
app-of-apps (Root)
    ├── sample-api-dev
    ├── sample-api-staging
    └── sample-api-prod
```

**Sync Policies**:
- Dev: Auto-sync, self-heal
- Staging: Auto-sync, self-heal
- Prod: Manual sync required

### 5. Configuration Management (Kustomize)

```
kubernetes/
├── base/                    # Common configurations
│   ├── deployment.yaml
│   ├── service.yaml
│   └── kustomization.yaml
└── overlays/
    ├── dev/                 # 1 replica, low resources
    ├── staging/             # 2 replicas, medium resources
    └── prod/                # 3 replicas, high resources
```

### 6. Infrastructure as Code (Terraform)

**Module Structure**:
```
terraform/
├── modules/
│   └── kind-cluster/       # Reusable cluster module
└── environments/
    └── dev/                 # Environment-specific config
```

### 7. Policy Engine (OPA Gatekeeper)

**Policies Enforced**:
| Policy | Scope | Action |
|--------|-------|--------|
| Required Labels | Deployments | Deny without labels |
| Resource Limits | All pods | Deny without limits |
| No Privileged | All containers | Deny privileged |
| Health Probes | Deployments | Deny without probes |

## Data Flow

### Application Deployment Flow

1. Developer pushes code to `main` branch
2. GitHub Actions CI triggered
3. Tests run, image built and pushed to Docker Hub
4. Manifest updated with new image tag
5. ArgoCD detects manifest change
6. ArgoCD syncs to cluster
7. OPA Gatekeeper validates against policies
8. If compliant, pods are created

### Infrastructure Change Flow

1. Developer creates PR with Terraform changes
2. GitHub Actions runs `terraform plan`
3. Plan output posted to PR for review
4. After merge, `terraform apply` runs (if configured)
5. Infrastructure updated

## Security Considerations

1. **Non-root containers**: All containers run as non-root user
2. **Resource limits**: Enforced via OPA policies
3. **No privileged containers**: Blocked by Gatekeeper
4. **Image scanning**: Can be added to CI pipeline
5. **Secrets management**: Use Sealed Secrets or external secrets operator

## Scaling Considerations

For production environments:
- Replace kind with managed Kubernetes (EKS/GKE/AKS)
- Add external secrets management
- Implement horizontal pod autoscaling
- Add monitoring (Prometheus/Grafana)
- Implement log aggregation (ELK/Loki)
