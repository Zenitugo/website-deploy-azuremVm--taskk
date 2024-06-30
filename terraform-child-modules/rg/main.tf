# Create a resource group for the project
resource "azurerm_resource_group" "rg" {
  name     = "${var.name}-rg"
  location = var.region
}