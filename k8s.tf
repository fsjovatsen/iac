resource "azurerm_kubernetes_cluster" "k8s" {
  location                          = azurerm_resource_group.rg.location
  name                              = var.cluster_name
  resource_group_name               = azurerm_resource_group.rg.name
  dns_prefix                        = var.cluster_name
  sku_tier                          = var.cluster_sku_tier
  local_account_disabled            = true
  http_application_routing_enabled  = false
  workload_identity_enabled         = false
  oidc_issuer_enabled               = false
  role_based_access_control_enabled = true

  ingress_application_gateway {
    gateway_id = azurerm_application_gateway.app_gw.id
  }

  identity {
    type = "SystemAssigned"
  }

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled     = true
    admin_group_object_ids = var.admin_groups
    managed                = true
  }

  default_node_pool {
    name                = "userpool1"
    vm_size             = "Standard_D2_v2"
    enable_auto_scaling = true
    node_count          = var.user_pool_1_node_count
    max_count           = var.user_pool_1_max_node_count
    min_count           = var.user_pool_1_min_node_count
    type                = "VirtualMachineScaleSets"
    vnet_subnet_id      = azurerm_subnet.k8s.id
  }


  linux_profile {
    admin_username = var.username

    ssh_key {
      key_data = azapi_resource_action.ssh_public_key_gen.output.publicKey
    }
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "k8s_system_node_pool" {
  name                  = "systempool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  vm_size               = "Standard_DS2_v2"
  mode                  = "System"
  node_count            = var.system_pool_node_count
  enable_auto_scaling   = true
  max_count             = var.system_pool_max_node_count
  min_count             = var.system_pool_min_node_count
  vnet_subnet_id        = azurerm_subnet.k8s.id
}

# resource "azurerm_user_assigned_identity" "alb" {
#   location            = azurerm_resource_group.rg.location
#   name                = "azure-alb-identity"
#   resource_group_name = azurerm_resource_group.rg.name
# }
#
# resource "azurerm_role_assignment" "alb" {
#   principal_id         = azurerm_user_assigned_identity.alb.principal_id
#   scope                = azurerm_kubernetes_cluster.k8s.node_resource_group_id
#   principal_type       = "ServicePrincipal"
#   role_definition_name = "Reader"
# }
#
# resource "azurerm_role_assignment" "alb-mc" {
#   principal_id         = azurerm_user_assigned_identity.alb.principal_id
#   scope                = azurerm_kubernetes_cluster.k8s.node_resource_group_id
#   principal_type       = "ServicePrincipal"
#   role_definition_name = "AppGw for Containers Configuration Manager"
# }
#
# resource "azurerm_role_assignment" "alb-subnet" {
#   principal_id         = azurerm_user_assigned_identity.alb.principal_id
#   scope                = azurerm_subnet.app_gw.id
#   principal_type       = "ServicePrincipal"
#   role_definition_name = "Network Contributor"
# }
#
# resource "azurerm_federated_identity_credential" "alb" {
#   audience            = ["api://AzureADTokenExchange"]
#   issuer              = azurerm_kubernetes_cluster.k8s.oidc_issuer_url
#   name                = "azure-alb-identity"
#   parent_id           = azurerm_user_assigned_identity.alb.id
#   resource_group_name = azurerm_resource_group.rg.name
#   subject             = "system:serviceaccount:azure-alb-system:alb-controller-sa"
# }