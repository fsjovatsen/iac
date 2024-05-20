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

resource "azurerm_virtual_network" "agw" {
  name                = "vnet-app-gateway"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.254.0.0/16"]
}

resource "azurerm_subnet" "agw" {
  address_prefixes     = ["10.254.0.0/24"]
  name                 = "app-gateway"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.agw.name
}

resource "azurerm_virtual_network_peering" "agw" {
  name                      = "${azurerm_virtual_network.agw.name}-${azurerm_virtual_network.k8s.name}"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.agw.name
  remote_virtual_network_id = azurerm_virtual_network.k8s.id
}

resource "azurerm_virtual_network_peering" "k8s" {
  name                      = "${azurerm_virtual_network.k8s.name}-${azurerm_virtual_network.agw.name}"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.k8s.name
  remote_virtual_network_id = azurerm_virtual_network.agw.id
}