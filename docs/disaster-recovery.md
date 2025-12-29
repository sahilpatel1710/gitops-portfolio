# Disaster Recovery Procedures

This document outlines the disaster recovery procedures for the GitOps infrastructure.

## 🎯 Recovery Objectives

| Metric | Target |
|--------|--------|
| **RTO** (Recovery Time Objective) | < 30 minutes |
| **RPO** (Recovery Point Objective) | 0 (Git is source of truth) |

## 📋 Pre-requisites for Recovery

Before starting recovery, ensure you have:

- [ ] Access to the Git repository
- [ ] Docker Desktop installed and running
- [ ] kubectl CLI installed
- [ ] kind CLI installed
- [ ] Terraform CLI installed

## 🔥 Scenario 1: Complete Cluster Failure

### Step 1: Create New Cluster

```bash
# Navigate to terraform directory
cd terraform/environments/dev

# Initialize and apply
terraform init
terraform apply -auto-approve
```

Or using kind directly:

```bash
kind create cluster --name gitops-demo --config ../../kind-config.yaml
```

### Step 2: Install ArgoCD

```bash
# Create ArgoCD namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -k ../../argocd/install/

# Wait for ArgoCD to be ready
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s
```

### Step 3: Get ArgoCD Credentials

```bash
# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo

# Port forward to access UI
kubectl port-forward svc/argocd-server -n argocd 8080:443 &
```

### Step 4: Bootstrap Applications

```bash
# Apply the App of Apps (update repo URL first)
kubectl apply -f argocd/applications/app-of-apps.yaml

# ArgoCD will automatically sync all applications
# Monitor progress in UI at https://localhost:8080
```

### Step 5: Verify Recovery

```bash
# Check all ArgoCD applications
argocd app list

# Check all namespaces
kubectl get namespaces

# Check deployments in each environment
kubectl get deployments -n sample-api-dev
kubectl get deployments -n sample-api-staging
kubectl get deployments -n sample-api-prod
```

## 🔧 Scenario 2: Single Application Failure

### Option A: Sync via ArgoCD UI
1. Open ArgoCD UI at https://localhost:8080
2. Find the affected application
3. Click "Sync" and select "Force"

### Option B: Sync via CLI

```bash
# Force sync a specific application
argocd app sync sample-api-dev --force

# Or delete and let ArgoCD recreate
kubectl delete deployment sample-api -n sample-api-dev
# ArgoCD will detect the drift and recreate
```

## 📊 Scenario 3: Manifest Corrupted in Git

### Step 1: Identify the Issue

```bash
# Check ArgoCD app status
argocd app get sample-api-dev

# View sync status
argocd app diff sample-api-dev
```

### Step 2: Revert Git Changes

```bash
# Find the last good commit
git log --oneline kubernetes/

# Revert to that commit
git revert <bad-commit>
git push origin main

# ArgoCD will automatically sync the reverted state
```

## 🛡️ Scenario 4: OPA Policy Blocking Deployments

### Identify Blocked Resources

```bash
# Check Gatekeeper audit logs
kubectl get k8srequiredlabels -o yaml

# Check constraint violations
kubectl get constraints -A
```

### Temporarily Disable a Policy

```bash
# Disable specific constraint (use with caution)
kubectl delete k8srequiredlabels require-app-labels

# Fix the resource, then re-apply policy
kubectl apply -f policies/constraints/require-labels.yaml
```

## 📝 Recovery Checklist

After any recovery, verify:

- [ ] All nodes are Ready: `kubectl get nodes`
- [ ] ArgoCD is running: `kubectl get pods -n argocd`
- [ ] All apps are synced: `argocd app list`
- [ ] OPA Gatekeeper is running: `kubectl get pods -n gatekeeper-system`
- [ ] Sample API is accessible: `kubectl port-forward svc/sample-api 3000:80 -n sample-api-dev`

## 📞 Escalation

If recovery fails:
1. Check ArgoCD logs: `kubectl logs -n argocd deployment/argocd-application-controller`
2. Check events: `kubectl get events --sort-by='.lastTimestamp' -A`
3. Review Git history for recent changes

## 🔄 Regular Testing

Test disaster recovery procedures monthly:

1. Delete the kind cluster
2. Follow Scenario 1 recovery steps
3. Document any issues encountered
4. Update this runbook as needed
