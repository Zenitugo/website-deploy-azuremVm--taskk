# create the virtual network for the application
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.name}-network"
  location            = var.rg-location
  resource_group_name = var.rg-name
  address_space       = var.cidr_block
}

############################################################################################
###########################################################################################

# Create the subnets
resource "azurerm_subnet" "subnet" {
  count                = 2  
  name                 = "${var.name}-subnet"
  resource_group_name  = var.rg-name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnets[count.index]
  
  
  private_endpoint_network_policies = false
  private_link_service_network_policies_enabled = false

}