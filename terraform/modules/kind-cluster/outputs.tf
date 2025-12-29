output "cluster_name" {
  description = "Name of the created kind cluster"
  value       = kind_cluster.default.name
}

output "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  value       = kind_cluster.default.kubeconfig_path
}

output "cluster_endpoint" {
  description = "Kubernetes cluster endpoint"
  value       = kind_cluster.default.endpoint
}

output "client_certificate" {
  description = "Client certificate for cluster authentication"
  value       = kind_cluster.default.client_certificate
  sensitive   = true
}

output "client_key" {
  description = "Client key for cluster authentication"
  value       = kind_cluster.default.client_key
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "CA certificate for cluster"
  value       = kind_cluster.default.cluster_ca_certificate
  sensitive   = true
}
