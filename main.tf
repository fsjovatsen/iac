
resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = join("-", [var.resource_group_name_prefix, var.cluster_name])
}

resource "azurerm_kubernetes_cluster" "k8s" {
  location            = azurerm_resource_group.rg.location
  name                = var.cluster_name
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.cluster_name
  sku_tier = var.cluster_sku_tier
  identity {
    type = "SystemAssigned"
  }


  default_node_pool {
    name       = "userpool1"
    vm_size    = "Standard_D2_v2"
    enable_auto_scaling = true
    node_count = var.user_pool_1_node_count
    max_count = var.user_pool_1_max_node_count
    min_count = var.user_pool_1_min_node_count
    type = "VirtualMachineScaleSets"
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
  mode = "System"
  node_count = var.system_pool_node_count
  enable_auto_scaling = true
  max_count = var.system_pool_max_node_count
  min_count = var.system_pool_min_node_count
}