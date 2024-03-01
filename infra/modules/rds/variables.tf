variable "instance_identifier" {
  type        = string
  description = "The identifier for the RDS instance."
}

variable "engine" {
  type        = string
  description = "The database engine to use (e.g., 'postgres', 'mysql')."
}

variable "engine_version" {
  type        = string
  description = "The engine version to use."
  default     = "14"
}

variable "family" {
  type        = string
  description = "The family of the DB parameter group (e.g., 'postgres14')."
  default     = "postgres14"
}

variable "major_engine_version" {
  type        = string
  description = "The major engine version."
  default     = "14"
}

variable "instance_class" {
  type        = string
  description = "The compute and memory capacity of the DB instance (e.g., 'db.t4g.micro')."
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  type        = number
  description = "The allocated storage in gigabytes."
  default     = 20
}

variable "max_allocated_storage" {
  type        = number
  description = "The maximum allocated storage in gigabytes."
  default     = 100
}

variable "db_name" {
  type        = string
  description = "The name of the database to create when the DB instance is created."
  default     = "node_app"
}

variable "username" {
  type        = string
  description = "Username for the master DB user."
  default     = "developer"
}

variable "port" {
  type        = number
  description = "The port on which the DB accepts connections."
  default     = 5432
}

variable "multi_az" {
  type        = bool
  description = "Specifies if the RDS instance is multi-AZ."
  default     = false
}

variable "create_cloudwatch_log_group" {
  type        = bool
  description = "Specifies whether to create a CloudWatch log group for RDS."
  default     = true
}

variable "backup_retention_period" {
  type        = number
  description = "The number of days to retain backups for."
  default     = 3
}

variable "publicly_accessible" {
  type        = bool
  description = "Specifies if the instance is publicly accessible."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources."
  default     = {}
}

variable "database_security_group_name" {
  type        = string
  description = "The name for the database security group."
  default     = "db-security-group"
}

variable "database_security_group_description" {
  type        = string
  description = "Description for the database security group."
  default     = "The security group for the database."
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID where the database security group will be created."
}

variable "vpc_cidr_block" {
  type        = string
  description = "The CIDR block for the VPC."
}

variable "db_password" {
  type        = string
  description = "The password for the RDS database."
}

variable "database_subnet_group_name" {
  type        = string
  description = "The name of the database subnet group."
  default     = "database-subnet-group"
}