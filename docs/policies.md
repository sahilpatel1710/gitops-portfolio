# Policy Reference

This document describes the OPA Gatekeeper policies enforced in the cluster.

## Overview

All policies are implemented using OPA Gatekeeper, which intercepts Kubernetes API requests and validates them against defined policies.

## Policies

### 1. Required Labels (`K8sRequiredLabels`)

**Purpose**: Ensures all workloads have required labels for identification and management.

**Required Labels**:
- `app.kubernetes.io/name`

**Applies To**:
- Deployments
- StatefulSets
- DaemonSets

**Example - Compliant**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  labels:
    app.kubernetes.io/name: my-app  # ✅ Required
```

**Example - Non-Compliant**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  # ❌ Missing app.kubernetes.io/name label
```

---

### 2. Resource Limits (`K8sContainerLimits`)

**Purpose**: Ensures all containers have CPU and memory limits to prevent resource exhaustion.

**Applies To**:
- All Pods
- Deployments, StatefulSets, DaemonSets

**Example - Compliant**:
```yaml
containers:
  - name: api
    resources:
      limits:
        memory: "128Mi"  # ✅ Required
        cpu: "100m"      # ✅ Required
```

**Example - Non-Compliant**:
```yaml
containers:
  - name: api
    # ❌ Missing resource limits
```

---

### 3. Deny Privileged Containers (`K8sDenyPrivileged`)

**Purpose**: Prevents running privileged containers which have full access to the host.

**Applies To**:
- All Pods
- All containers and init containers

**Example - Compliant**:
```yaml
containers:
  - name: api
    securityContext:
      privileged: false  # ✅ OK
```

**Example - Non-Compliant**:
```yaml
containers:
  - name: api
    securityContext:
      privileged: true  # ❌ Blocked
```

---

### 4. Require Health Probes (`K8sRequireProbes`)

**Purpose**: Ensures applications have proper health checks for Kubernetes to manage them correctly.

**Required Probes**:
- `livenessProbe`
- `readinessProbe`

**Applies To**:
- Deployments
- StatefulSets

**Example - Compliant**:
```yaml
containers:
  - name: api
    livenessProbe:       # ✅ Required
      httpGet:
        path: /health
        port: 8080
    readinessProbe:      # ✅ Required
      httpGet:
        path: /ready
        port: 8080
```

---

## Excluded Namespaces

The following namespaces are excluded from policy enforcement:
- `kube-system` - Kubernetes system components
- `argocd` - ArgoCD components
- `gatekeeper-system` - Gatekeeper components
- `ingress-nginx` - Ingress controller (for resource limits)

## Testing Policies Locally

Use [conftest](https://www.conftest.dev/) to test policies before deploying:

```bash
# Install conftest
brew install conftest  # macOS
# or download from https://github.com/open-policy-agent/conftest/releases

# Test a manifest
conftest test kubernetes/base/deployment.yaml --policy policies/rego/
```

## Adding New Policies

1. Create ConstraintTemplate in `policies/templates/`
2. Create Constraint in `policies/constraints/`
3. Add Rego policy in `policies/rego/` for local testing
4. Test using conftest
5. Apply to cluster:
   ```bash
   kubectl apply -f policies/templates/
   kubectl apply -f policies/constraints/
   ```

## Viewing Policy Violations

```bash
# List all constraints
kubectl get constraints

# View violations for a specific constraint
kubectl describe k8srequiredlabels require-app-labels
```
