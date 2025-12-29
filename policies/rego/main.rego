# Rego policies for local testing with conftest
package main

# Deny deployments without required labels
deny[msg] {
  input.kind == "Deployment"
  not input.metadata.labels["app.kubernetes.io/name"]
  msg := sprintf("Deployment '%s' must have 'app.kubernetes.io/name' label", [input.metadata.name])
}

# Deny containers without resource limits
deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  not container.resources.limits.memory
  msg := sprintf("Container '%s' in Deployment '%s' must have memory limits", [container.name, input.metadata.name])
}

deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  not container.resources.limits.cpu
  msg := sprintf("Container '%s' in Deployment '%s' must have CPU limits", [container.name, input.metadata.name])
}

# Deny privileged containers
deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  container.securityContext.privileged == true
  msg := sprintf("Container '%s' in Deployment '%s' cannot be privileged", [container.name, input.metadata.name])
}

# Warn for missing health probes
warn[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  not container.livenessProbe
  msg := sprintf("Container '%s' in Deployment '%s' should have a liveness probe", [container.name, input.metadata.name])
}

warn[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  not container.readinessProbe
  msg := sprintf("Container '%s' in Deployment '%s' should have a readiness probe", [container.name, input.metadata.name])
}
