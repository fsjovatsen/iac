resource "azurerm_public_ip" "pip-sjovatsen-no" {
  name                = "pip-sjovatsen-no"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "pip-sjovatsen-no"
}

data "azurerm_user_assigned_identity" "agw" {
  name                = "ingressapplicationgateway-${var.cluster_name}"
  resource_group_name = azurerm_kubernetes_cluster.k8s.node_resource_group
}

resource "azurerm_role_assignment" "agw-reader-role" {
  principal_id         = data.azurerm_user_assigned_identity.agw.principal_id
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Reader"
}

resource "azurerm_role_assignment" "agw-network-contributor-role" {
  principal_id         = data.azurerm_user_assigned_identity.agw.principal_id
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Network Contributor"
}

locals {
  backend_address_pool_name      = "${azurerm_virtual_network.agw.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.agw.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.agw.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.agw.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.agw.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.agw.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.agw.name}-rdrcfg"
}

resource "azurerm_application_gateway" "agw" {
  name                = "agw-${var.cluster_name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "gateway-ip-configuration"
    subnet_id = azurerm_subnet.agw.id
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.pip-sjovatsen-no.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }


  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    #path                  = "/path1/"
    port            = 80
    protocol        = "Http"
    request_timeout = 30
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 100
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}

