locals {
  instance_identifier         = "dagster-db-${var.environment}"
  engine                      = "postgres"
  engine_version              = "14"
  family                      = "postgres14"
  major_engine_version        = "14"
  instance_class              = "db.t4g.micro"
  allocated_storage           = 20
  max_allocated_storage       = 100
  db_name                     = "postgres"
  username                    = "developer"
  port                        = 5432
  multi_az                    = false
  create_cloudwatch_log_group = true
  backup_retention_period     = 3
  publicly_accessible         = true
  # vpc_id                     = module.data-platform-vpc.vpc_id
  vpc_cidr_block = module.data-platform-vpc.vpc_cidr_block
  # database_subnet_group_name = module.data-platform-vpc.db_subnet_group_name
  tags = var.tags
}


// CREATE A RANDOM PASSWORD FOR THE DB
resource "random_password" "random_password" {
  length           = 20
  special          = true
  override_special = "_!%^"
}

// ADD THE RANDOM PASSWORD TO SECRETS MANAGER
resource "aws_secretsmanager_secret" "db_password" {
  name = "db-password"
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.random_password.result
}

// CREATE AN RDS INSTANCE
module "data-platform-db" {
  source                      = "./modules/rds"
  instance_identifier         = local.instance_identifier
  engine                      = local.engine
  engine_version              = local.engine_version
  family                      = local.family
  major_engine_version        = local.major_engine_version
  instance_class              = local.instance_class
  allocated_storage           = local.allocated_storage
  max_allocated_storage       = local.max_allocated_storage
  db_name                     = local.db_name
  username                    = local.username
  db_password                 = aws_secretsmanager_secret_version.db_password.secret_string
  port                        = local.port
  multi_az                    = local.multi_az
  create_cloudwatch_log_group = local.create_cloudwatch_log_group
  backup_retention_period     = local.backup_retention_period
  publicly_accessible         = local.publicly_accessible
  vpc_id                      = local.vpc_id
  vpc_cidr_block              = local.vpc_cidr_block
  database_subnet_group_name  = local.database_subnet_group_name
  tags                        = local.tags

  depends_on = [
    module.data-platform-vpc,
    aws_secretsmanager_secret_version.db_password
  ]
}
