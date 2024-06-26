data "azurerm_kubernetes_cluster" "k8s" {
  depends_on          = [module.aks_cluster] # refresh cluster state before reading
  name                = var.cluster_name
  resource_group_name = var.cluster_name
}

module "aks_cluster" {
  source          = "./aks"
  cluster_name    = var.cluster_name
  admin_groups    = var.admin_groups
  aiven_api_token = var.aiven_api_token
  client_id       = var.ARM_CLIENT_ID
  client_secret   = var.ARM_CLIENT_SECRET
  subscription_id = var.ARM_SUBSCRIPTION_ID
  tenant_id       = var.ARM_TENANT_ID
}

module "observability" {
  source          = "./observability"
  aiven_api_token = var.aiven_api_token
  cluster_name    = var.cluster_name
}

module "security" {
  source = "./security"

  cluster_name = var.cluster_name
}