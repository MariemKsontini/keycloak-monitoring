output "client_certificate" {
  sensitive   = true
  description = "The client certificate used for connecting to the Kubernetes cluster."
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
}

output "kube_config" {
  sensitive   = true
  description = "The kube config content to use with kubectl to manage Kubernetes."
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
}

output "aks_cluster_id" {
  description = "The ID of the Kubernetes cluster."
  value       = azurerm_kubernetes_cluster.aks.id
}
