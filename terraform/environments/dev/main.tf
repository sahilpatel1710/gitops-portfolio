terraform {
  required_version = ">= 1.0.0"
}

module "kind_cluster" {
  source = "../../modules/kind-cluster"

  cluster_name       = "gitops-dev"
  kubernetes_version = "v1.28.0"
  worker_nodes       = 1
  kubeconfig_path    = "~/.kube/config-dev"
  install_argocd     = true
  install_ingress    = true
}

output "cluster_name" {
  value = module.kind_cluster.cluster_name
}

output "kubeconfig_path" {
  value = module.kind_cluster.kubeconfig_path
}
