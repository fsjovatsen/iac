resource "azurerm_network_security_group" "sg" {
  name                = join("-", ["sg", var.cluster_name])
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_virtual_network" "k8s" {
  name                = join("-", ["vnet", var.cluster_name, "k8s"])
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.100.0.0/16"]
}

resource "azurerm_subnet" "k8s" {
  address_prefixes     = ["10.100.0.0/16"]
  name                 = "service"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.k8s.name
}

resource "azurerm_virtual_network" "app_gw" {
  name                = "vnet-app-gateway"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.254.0.0/16"]


  #   subnet {
  #     name           = "app-gateway"
  #     address_prefix = "10.254.0.0/24"
  #   }
}

resource "azurerm_subnet" "app_gw" {
  address_prefixes     = ["10.254.0.0/24"]
  name                 = "app-gateway"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.app_gw.name
}

resource "azurerm_virtual_network_peering" "app_gw" {
  name                      = "${azurerm_virtual_network.app_gw.name}-${azurerm_virtual_network.k8s.name}"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.app_gw.name
  remote_virtual_network_id = azurerm_virtual_network.k8s.id
}

resource "azurerm_virtual_network_peering" "k8s" {
  name                      = "${azurerm_virtual_network.k8s.name}-${azurerm_virtual_network.app_gw.name}"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.k8s.name
  remote_virtual_network_id = azurerm_virtual_network.app_gw.id
}