variable "aiven_api_token" {
  type = string
}

variable "cluster_name" {
  type        = string
  default     = null
  description = "Name of the cluster. Is used for rg and vnet names also."
}