variable "resource_group_location" {
  type        = string
  default     = "norwayeast"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  type        = string
  default     = "rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "cluster_name" {
  type = string
  default = null
  description = "Name of the cluster. Is used for rg and vnet names also."
}

variable "cluster_sku_tier" {
  type = string
  default = "Free"
  description = ""
}

variable "system_pool_node_count" {
  type        = number
  description = "The initial quantity of nodes for the node pool."
  default     = 1
}


variable "system_pool_min_node_count" {
  type        = number
  description = "The initial quantity of nodes for the node pool."
  default     = 1
}

variable "system_pool_max_node_count" {
  type        = number
  description = "The initial quantity of nodes for the node pool."
  default     = 2
}

variable "user_pool_1_node_count" {
  type        = number
  description = "The initial quantity of nodes for the node pool."
  default     = 1
}


variable "user_pool_1_min_node_count" {
  type        = number
  description = "The initial quantity of nodes for the node pool."
  default     = 1
}

variable "user_pool_1_max_node_count" {
  type        = number
  description = "The initial quantity of nodes for the node pool."
  default     = 2
}

variable "username" {
  type        = string
  description = "The admin username for the new cluster."
  default     = "azureadmin"
}