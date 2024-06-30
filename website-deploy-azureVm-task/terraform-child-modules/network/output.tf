# Output the subnet ids
output "subnet_ids" {
    value = azurerm_subnet.subnet.id
}