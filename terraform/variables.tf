variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
  default = "myResource"
}

variable "resource_group_location" {
  description = "The location of the resource group."
  type        = string
  default     = "West US"
}

variable "aks_cluster_name" {
  description = "The name of the AKS cluster."
  type        = string
  default = "myCluster"
}

variable "node_count" {
  description = "The initial number of nodes for the AKS cluster."
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "The size of the Virtual Machines to use for nodes."
  type        = string
  default     = "Standard_D4_v4"
}
