module "dagster_log_group" {
  source            = "../cloudwatch"
  log_group_name    = var.dagster_log_group_name
  retention_in_days = var.cloudwatch_retention_days
  tags              = var.tags
}