#vModule of each resource

module "rg"{
    source                           = "../terraform-child-modules/rg"
    region                           = var.region
    name                             = var.name 
}



module "network" {
    source                           = "../terraform-child-modules/network"
    name                             = var.name
    rg-location                      = module.rg.rg-location
    rg-name                          = module.rg.rg-name  
    cidr_block                       = var.cidr_block 
    subnets                          = var.subnets 
}


module "VM" {
    source                           = "../terraform-child-modules/VM"
    name                             = var.name 
    rg-location                      = module.rg.rg-location
    rg-name                          = module.rg.rg-name  
    allocation_method                = var.allocation_method
    source_file_path                 = var.source_file_path
    destination_file_path            = var.destination_file_path   
    subnet_ids                       = module.network.subnet_ids
}