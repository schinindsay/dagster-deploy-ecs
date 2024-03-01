locals {
  vpc_id     = module.data-platform-vpc.vpc_id
  region     = "us-east-1"
  subnet_ids = module.data-platform-vpc.private_subnets

  dagster_sg_name                           = "dagster-ecs-sg"
  dagster_webserver_port                    = 3000
  dagster_user_code_port                    = 4000
  dagster_log_group_name                    = "dagster"
  dagster_repository_read_write_access_arns = [data.aws_caller_identity.current.arn]
  dagster_ecr_access_roles                  = ["*"]

  daemon_environment_variables = [
    { "name" : "DAGSTER_POSTGRES_DB", "value" : module.data-platform-db.db_instance_name },
    { "name" : "DAGSTER_POSTGRES_HOSTNAME", "value" : module.data-platform-db.db_instance_hostname },
    { "name" : "DAGSTER_POSTGRES_PASSWORD", "value" : aws_secretsmanager_secret_version.db_password.secret_string },
    { "name" : "DAGSTER_POSTGRES_USER", "value" : module.data-platform-db.db_instance_username }
  ]

  webserver_environment_variables = [
    { "name" : "DAGSTER_POSTGRES_DB", "value" : module.data-platform-db.db_instance_name },
    { "name" : "DAGSTER_POSTGRES_HOSTNAME", "value" : module.data-platform-db.db_instance_hostname },
    { "name" : "DAGSTER_POSTGRES_PASSWORD", "value" : aws_secretsmanager_secret_version.db_password.secret_string },
    { "name" : "DAGSTER_POSTGRES_USER", "value" : module.data-platform-db.db_instance_username }
  ]

  user_code_environment_variables = [
    { "name" : "DAGSTER_POSTGRES_DB", "value" : module.data-platform-db.db_instance_name },
    { "name" : "DAGSTER_POSTGRES_HOSTNAME", "value" : module.data-platform-db.db_instance_hostname },
    { "name" : "DAGSTER_POSTGRES_PASSWORD", "value" : aws_secretsmanager_secret_version.db_password.secret_string },
    { "name" : "DAGSTER_POSTGRES_USER", "value" : module.data-platform-db.db_instance_username }
  ]
}


module "daster" {
  source = "./modules/dagster"

  dagster_sg_name                           = local.dagster_sg_name
  vpc_id                                    = local.vpc_id
  dagster_webserver_port                    = local.dagster_webserver_port
  dagster_user_code_port                    = local.dagster_user_code_port
  dagster_repository_read_write_access_arns = local.dagster_repository_read_write_access_arns
  dagster_ecr_access_roles                  = local.dagster_ecr_access_roles
  dagster_log_group_name                    = local.dagster_log_group_name
  region                                    = local.region
  user_code_environment_variables           = local.user_code_environment_variables
  webserver_environment_variables           = local.webserver_environment_variables
  daemon_environment_variables              = local.daemon_environment_variables
  dagster_subnet_ids                        = local.subnet_ids
}
