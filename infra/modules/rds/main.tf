module "db" {
  source                = "terraform-aws-modules/rds/aws"
  identifier            = var.instance_identifier
  engine                = var.engine
  engine_version        = var.engine_version
  family                = var.family
  major_engine_version  = var.major_engine_version
  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage

  db_name                     = var.db_name
  username                    = var.username
  port                        = var.port
  multi_az                    = var.multi_az
  db_subnet_group_name        = var.database_subnet_group_name
  vpc_security_group_ids      = [module.security_group.security_group_id]
  create_cloudwatch_log_group = var.create_cloudwatch_log_group
  backup_retention_period     = var.backup_retention_period
  publicly_accessible         = var.publicly_accessible
  password                    = var.db_password
  manage_master_user_password = false
  tags                        = var.tags
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = var.database_security_group_name
  description = var.database_security_group_description
  vpc_id      = var.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = var.port
      to_port     = var.port
      protocol    = "tcp"
      description = "Database access from within VPC"
      cidr_blocks = var.vpc_cidr_block
    },
  ]

  tags = var.tags
}