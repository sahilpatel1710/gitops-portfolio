variable "cluster_name" {
  description = "Name of the kind cluster"
  type        = string
  default     = "gitops-demo"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the kind cluster"
  type        = string
  default     = "v1.28.0"
}

variable "worker_nodes" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}

variable "kubeconfig_path" {
  description = "Path to store the kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "install_argocd" {
  description = "Whether to install ArgoCD"
  type        = bool
  default     = true
}

variable "install_ingress" {
  description = "Whether to install NGINX ingress controller"
  type        = bool
  default     = true
}
