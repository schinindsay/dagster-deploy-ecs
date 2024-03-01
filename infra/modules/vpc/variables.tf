variable "name" {
  type        = string
  description = "The name of the VPC."
  default     = "vpc"
}

variable "cidr" {
  type        = string
  description = "The CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "azs" {
  type        = list(string)
  description = "A list of availability zones names or IDs in the region."
}

variable "public_subnets" {
  type        = list(string)
  description = "A list of public subnet CIDR blocks inside the VPC."
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "private_subnets" {
  type        = list(string)
  description = "A list of private subnet CIDR blocks inside the VPC."
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "database_subnets" {
  type        = list(string)
  description = "A list of database subnet CIDR blocks inside the VPC."
  default     = ["10.0.151.0/24", "10.0.152.0/24"]
}

variable "create_database_subnet_group" {
  type        = bool
  description = "Controls if a database subnet group should be created within the VPC."
  default     = true
}

variable "create_database_subnet_route_table" {
  type        = bool
  description = "Controls if a separate route table for the database subnets should be created."
  default     = true
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Set to true to provision NAT Gateways for each of your private networks."
  default     = true
}

variable "single_nat_gateway" {
  type        = bool
  description = "Set to true to provision a single shared NAT Gateway across all of your private networks."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all resources."
  default     = {}
}

variable "vpc_tags" {
  type        = map(string)
  description = "A map of tags to apply specifically to the VPC resource."
  default     = {}
}

variable "database_subnet_group_name" {
  type        = string
  description = "The name of the database subnet group within the VPC."
}
