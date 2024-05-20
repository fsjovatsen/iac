resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = join("-", [var.resource_group_name_prefix, var.cluster_name])
}