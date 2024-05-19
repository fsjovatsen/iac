data "aiven_project" "avn_project" {
  project = "frode-a20f"
}

data "azurerm_subscription" "subscription" {}
data "azurerm_client_config" "tentant" {}


resource "aiven_project_vpc" "avn_vpc" {
  project      = data.aiven_project.avn_project.project
  cloud_name   = "azure-norway-east"
  network_cidr = "192.168.1.0/24"

  timeouts {
    create = "15m"
  }
}

# 1. Log in with an Azure admin account
# Already done.

# 2. Create application object
resource "azuread_application" "app" {
  display_name = "aiven-terraform"
  sign_in_audience = "AzureADandPersonalMicrosoftAccount"

  api {
    requested_access_token_version = 2
  }
}
#
# # 3. Create a service principal for your app object
resource "azuread_service_principal" "app_principal" {
  application_id = azuread_application.app.application_id
#   app_role_assignment_required = false
#   owners = [
#     data.azurerm_client_config.tentant.object_id
#   ]
}
#
# # 4. Set a password for your app object
resource "azuread_application_password" "app_password" {
  application_object_id = azuread_application.app.object_id
}
#
# # 5. Find the id properties of your virtual network
# # Skip, we have values in the state
#
# # 6. Grant your service principal permissions to peer
resource "azurerm_role_assignment" "app_role" {
  role_definition_name = "Network Contributor"
  principal_id         = azuread_service_principal.app_principal.object_id
  scope                = azurerm_virtual_network.k8s.id
}
#
# # 7. Create a service principal for the Aiven application object
# # Yes, application_id is hardcoded.
resource "azuread_service_principal" "aiven_app_principal" {
  application_id = "55f300d4-fc50-4c5e-9222-e90a6e2187fb"
}
#
# # 8. Create a custom role for the Aiven application object
resource "azurerm_role_definition" "role_definition" {
  name        = "my-azure-role-definition"
  description = "Allows creating a peering to vnets in scope (but not from)"
  scope       = "/subscriptions/${data.azurerm_subscription.subscription.subscription_id}"

  permissions {
    actions = ["Microsoft.Network/virtualNetworks/peer/action"]
  }

  assignable_scopes = [
    "/subscriptions/${data.azurerm_subscription.subscription.subscription_id}"
  ]
}
#
# # 9. Assign the custom role to the Aiven service principal
resource "azurerm_role_assignment" "aiven_role_assignment" {
  role_definition_id = azurerm_role_definition.role_definition.role_definition_resource_id
  principal_id       = azuread_service_principal.aiven_app_principal.object_id
  scope              = azurerm_virtual_network.k8s.id

  depends_on = [
    azuread_service_principal.aiven_app_principal,
    azurerm_role_assignment.app_role
  ]
}
#
# # 10. Find your AD tenant id
# # Skip, it's in the env
#
# # 11. Create a peering connection from the Aiven Project VPC
# # 12. Wait for the Aiven platform to set up the connection
resource "aiven_azure_vpc_peering_connection" "peering_connection" {
  vpc_id                = aiven_project_vpc.avn_vpc.id
  peer_resource_group   = azurerm_resource_group.rg.name
  azure_subscription_id = data.azurerm_subscription.subscription.subscription_id
  vnet_name             = azurerm_virtual_network.k8s.name
  peer_azure_app_id     = azuread_application.app.application_id
  peer_azure_tenant_id  = data.azurerm_client_config.tentant.tenant_id

  depends_on = [
    azurerm_role_assignment.aiven_role_assignment
  ]
}

provider "azurerm" {
  features {}
  alias                = "app"
  client_id            = azuread_application.app.application_id
  client_secret        = azuread_application_password.app_password.value
  subscription_id      = data.azurerm_subscription.subscription.subscription_id
  tenant_id            = data.azurerm_client_config.tentant.tenant_id
  auxiliary_tenant_ids = [azuread_service_principal.aiven_app_principal.application_tenant_id]
}


resource "azurerm_virtual_network_peering" "network_peering" {
  provider                     = azurerm.app
  name                         = "my-azure-virtual-network-peering"
  remote_virtual_network_id    = aiven_azure_vpc_peering_connection.peering_connection.state_info["to-network-id"]
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.k8s.name
  allow_virtual_network_access = true
}