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
    gateway_id = azurerm_application_gateway.agw.id
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