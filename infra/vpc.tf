locals {
  vpc_name                           = "dagster-vpc"
  vpc_cidr                           = "10.0.0.0/16"
  public_subnets                     = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets                    = ["10.0.3.0/24", "10.0.4.0/24"]
  database_subnets                   = ["10.0.5.0/24", "10.0.6.0/24"]
  create_database_subnet_group       = true
  create_database_subnet_route_table = false
  enable_nat_gateway                 = true
  single_nat_gateway                 = true
  vpc_tags                           = {}
  database_subnet_group_name         = "data-platform-db-subnet-group"
}

module "data-platform-vpc" {
  source = "./modules/vpc"
  name   = local.vpc_name
  cidr   = local.vpc_cidr
  azs = [
    data.aws_availability_zones.available.names[0],
    data.aws_availability_zones.available.names[1],
  ]
  public_subnets                     = local.public_subnets
  private_subnets                    = local.private_subnets
  database_subnets                   = local.database_subnets
  create_database_subnet_group       = local.create_database_subnet_group
  create_database_subnet_route_table = local.create_database_subnet_route_table
  enable_nat_gateway                 = local.enable_nat_gateway
  single_nat_gateway                 = local.single_nat_gateway
  tags                               = var.tags
  vpc_tags                           = local.vpc_tags
  database_subnet_group_name         = local.database_subnet_group_name
}
