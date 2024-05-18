resource "azurerm_public_ip" "pip" {
  name                = "pip-sjovatsen-no"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

locals {
  backend_address_pool_name      = "${azurerm_virtual_network.app_gw.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.app_gw.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.app_gw.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.app_gw.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.app_gw.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.app_gw.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.app_gw.name}-rdrcfg"
}

resource "azurerm_application_gateway" "app_gw" {
  name                = "example-appgateway"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.app_gw.id
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.pip.id
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

