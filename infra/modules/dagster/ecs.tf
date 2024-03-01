locals {
  namespace_name = "mynamespace.local"
  vpc_id         = var.vpc_id
  cluster_name   = "dagster-cluster"

  service_discovery_configs = {}

  user_code_env = concat(
    var.user_code_environment_variables,
    [
      { "name" : "DAGSTER_CURRENT_IMAGE", "value" : module.ecr_repos["user_code_repo"].repository_url }
    ]
  )

  daemon_container_definition = templatefile("${path.module}/container_definition.tpl", {
    name                  = "daemon"
    image                 = module.ecr_repos["daemon_repo"].repository_url
    command               = jsonencode(["dagster-daemon", "run"])
    environment           = jsonencode(var.daemon_environment_variables)
    awslogs_group         = module.dagster_log_group.name
    awslogs_region        = var.region
    awslogs_stream_prefix = "dagster_daemon"
    port_mapping_name     = "daemon"
    container_port        = 4000
    host_port             = 4000
  })

  webserver_container_definition = templatefile("${path.module}/container_definition.tpl", {
    name                  = "webserver"
    image                 = module.ecr_repos["webserver_repo"].repository_url
    command               = jsonencode(["dagster-webserver", "-h", "0.0.0.0", "-p", "3000", "-w", "workspace.yaml"])
    environment           = jsonencode(var.webserver_environment_variables)
    awslogs_group         = module.dagster_log_group.name
    awslogs_region        = var.region
    awslogs_stream_prefix = "dagster_webserver"
    port_mapping_name     = "webserver"
    container_port        = 3000
    host_port             = 3000
  })

  user_code_container_definition = templatefile("${path.module}/container_definition.tpl", {
    name                  = "user_code"
    image                 = module.ecr_repos["user_code_repo"].repository_url
    command               = jsonencode(["dagster", "api", "grpc", "-h", "0.0.0.0", "-p", "4000", "-f", "defs.py"])
    environment           = jsonencode(local.user_code_env)
    awslogs_group         = module.dagster_log_group.name
    awslogs_region        = var.region
    awslogs_stream_prefix = "dagster_daemon"
    port_mapping_name     = "user_code"
    container_port        = 4000
    host_port             = 4000
  })

  webserver_task_definition = {
    family                   = "webserver"
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    execution_role_arn       = module.iam_ecs_roles["webserver_task_execution_role"].role_arn
    task_role_arn            = module.iam_ecs_roles["webserver_task_role"].role_arn
    cpu                      = "256"
    memory                   = "512"
    container_definitions    = local.webserver_container_definition
  }

  user_code_task_definition = {
    family                   = "user_code"
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    execution_role_arn       = module.iam_ecs_roles["user_code_task_execution_role"].role_arn
    task_role_arn            = module.iam_ecs_roles["user_code_task_role"].role_arn
    cpu                      = "256"
    memory                   = "512"
    container_definitions    = local.user_code_container_definition
  }

  daemon_task_definition = {
    family                   = "daemon"
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    execution_role_arn       = module.iam_ecs_roles["daemon_task_execution_role"].role_arn
    task_role_arn            = module.iam_ecs_roles["daemon_task_role"].role_arn
    cpu                      = "256"
    memory                   = "512"
    container_definitions    = local.daemon_container_definition
  }

  task_definitions = {
    webserver = local.webserver_task_definition
    user_code = local.user_code_task_definition
    daemon    = local.daemon_task_definition
  }

  webserver_service_config = {
    # service_name           = "webserver"
    task_definition_family = "webserver"
    desired_count          = 1
    assign_public_ip       = true
    security_group_ids = [
    module.dagster_security_group.security_group_id, ]
    subnet_ids                          = var.dagster_subnet_ids
    deployment_circuit_breaker_enable   = true
    deployment_circuit_breaker_rollback = true
    service_registries                  = []
    service_connect_enabled             = true
    service_connect_namespace           = local.namespace_name
    service_connect_services = {
      webserver = {
        port_name      = "webserver"
        discovery_name = "dagster-webserver"
        client_alias = [{
          port     = 3000
          dns_name = "dagster-webserver"
        }]
      }
    }
    tags = {}
  }

  daemon_service_config = {
    # service_name           = "daemon"
    task_definition_family = "daemon"
    desired_count          = 1
    assign_public_ip       = true
    security_group_ids = [
    module.dagster_security_group.security_group_id, ]
    subnet_ids                          = var.dagster_subnet_ids
    deployment_circuit_breaker_enable   = true
    deployment_circuit_breaker_rollback = true
    service_registries                  = []
    service_connect_enabled             = true
    service_connect_namespace           = local.namespace_name
    service_connect_services = {
      daemon = {
        port_name      = "daemon"
        discovery_name = "dagster-daemon"
        client_alias = [{
          port     = 4000
          dns_name = "daemon"
        }]
      }
    }
    tags = {}
  }

  user_code_service_config = {
    # service_name           = "user_code"
    task_definition_family = "user_code"
    desired_count          = 1
    assign_public_ip       = true
    security_group_ids = [
    module.dagster_security_group.security_group_id, ]
    subnet_ids                          = var.dagster_subnet_ids
    deployment_circuit_breaker_enable   = true
    deployment_circuit_breaker_rollback = true
    service_registries                  = []
    service_connect_enabled             = true
    service_connect_namespace           = local.namespace_name
    service_connect_services = {
      user_code = {
        port_name      = "user_code"
        discovery_name = "dagster-user-code-1"
        client_alias = [{
          port     = 4000
          dns_name = "user_code"
        }]
      }
    }
    tags = {}
  }

  services = {
    webserver = local.webserver_service_config
    daemon    = local.daemon_service_config
    user_code = local.user_code_service_config
  }

}

module "dagster-ecs" {
  source = "../ecs/ecs-cloudmap-cluster-tasks"

  namespace_name            = local.namespace_name
  vpc_id                    = local.vpc_id
  service_discovery_configs = local.service_discovery_configs
  cluster_name              = local.cluster_name
  task_definitions          = local.task_definitions
  services                  = local.services
}

# resource "aws_ecs_service" "webserver-service" {
#   name            = local.webserver_service_config["service_name"]
#   cluster         = module.dagster-ecs.created_ecs_cluster_arn
#   task_definition = module.dagster-ecs.task_definition_arns["webserver"]
#   desired_count   = local.webserver_service_config["desired_count"]
#   # launch_type     = "FARGATE"

#   network_configuration {
#     assign_public_ip = local.webserver_service_config["assign_public_ip"]
#     security_groups  = local.webserver_service_config["security_group_ids"]
#     subnets          = local.webserver_service_config["subnet_ids"]
#   }

#   deployment_controller {
#     type = "ECS"
#   }

#   deployment_circuit_breaker {
#     enable   = local.webserver_service_config["deployment_circuit_breaker_enable"]
#     rollback = local.webserver_service_config["deployment_circuit_breaker_rollback"]
#   }

#   scheduling_strategy = "REPLICA"

#   service_connect_configuration {
#     enabled   = true
#     namespace = local.namespace_name

#     service {
#       port_name      = "webserver"
#       discovery_name = "dagster-webserver"
#       client_alias {
#         port     = 3000
#         dns_name = "dagster-webserver"
#       }
#     }

#   }
#   propagate_tags = "SERVICE"
# }

# resource "aws_ecs_service" "user-code-service" {
#   name            = local.user_code_service_config["service_name"]
#   cluster         = module.dagster-ecs.created_ecs_cluster_arn
#   task_definition = module.dagster-ecs.task_definition_arns["user_code"]
#   desired_count   = local.user_code_service_config["desired_count"]
#   # launch_type     = "FARGATE"

#   network_configuration {
#     assign_public_ip = local.user_code_service_config["assign_public_ip"]
#     security_groups  = local.user_code_service_config["security_group_ids"]
#     subnets          = local.user_code_service_config["subnet_ids"]
#   }

#   deployment_controller {
#     type = "ECS"
#   }

#   deployment_circuit_breaker {
#     enable   = local.user_code_service_config["deployment_circuit_breaker_enable"]
#     rollback = local.user_code_service_config["deployment_circuit_breaker_rollback"]
#   }

#   scheduling_strategy = "REPLICA"

#   service_connect_configuration {
#     enabled   = true
#     namespace = local.namespace_name

#     service {
#       port_name      = "user_code"
#       discovery_name = "dagster-user-code-1"
#       client_alias {
#         port     = 4000
#         dns_name = "user_code"
#       }
#     }

#     # service {
#     #   port_name      = "user_code"
#     #   discovery_name = "dagster-user-code-2"
#     #   client_alias {
#     #     port     = 4000
#     #     dns_name = ""
#     #   }
#     # }
#   }

#   propagate_tags = "SERVICE"
# }

# resource "aws_ecs_service" "daemon-service" {
#   name            = local.daemon_service_config["service_name"]
#   cluster         = module.dagster-ecs.created_ecs_cluster_arn
#   task_definition = module.dagster-ecs.task_definition_arns["daemon"]
#   desired_count   = local.daemon_service_config["desired_count"]
#   # launch_type     = "FARGATE"

#   network_configuration {
#     assign_public_ip = local.daemon_service_config["assign_public_ip"]
#     security_groups  = local.daemon_service_config["security_group_ids"]
#     subnets          = local.daemon_service_config["subnet_ids"]
#   }

#   deployment_controller {
#     type = "ECS"
#   }

#   deployment_circuit_breaker {
#     enable   = local.daemon_service_config["deployment_circuit_breaker_enable"]
#     rollback = local.daemon_service_config["deployment_circuit_breaker_rollback"]
#   }

#   scheduling_strategy = "REPLICA"

#   service_connect_configuration {
#     enabled   = true
#     namespace = local.namespace_name


#     service {
#       port_name      = "daemon"
#       discovery_name = "dagster-daemon"
#       client_alias {
#         port     = 4000
#         dns_name = "daemon"
#       }
#     }
#   }

#   propagate_tags = "SERVICE"
# }

# # /////////////////////////////////////
# # // ECS RESOURCES
# # /////////////////////////////////////

# resource "aws_ecs_cluster" "dagster_cluster" {
#   name = "dagster_deploy_ecs"

#   setting {
#     name  = "containerInsights"
#     value = "enabled"
#   }

#   tags = var.tags
# }

# resource "aws_ecs_service" "daemon_service" {
#   depends_on = [
#     aws_ecs_service.user_code_service,
#     module.iam_ecs_roles
#   ]
#   name            = "DaemonService"
#   cluster         = aws_ecs_cluster.dagster_cluster.arn
#   task_definition = aws_ecs_task_definition.daemon_task_definition.arn
#   desired_count   = 1
#   launch_type     = "FARGATE"

#   network_configuration {
#     assign_public_ip = true
#     security_groups = [
#     module.dagster_security_group.security_group_id, ]
#     subnets = module.data-platform-vpc.private_subnets
#   }

#   deployment_controller {
#     type = "ECS"
#   }

#   deployment_circuit_breaker {
#     enable   = true
#     rollback = true
#   }

#   scheduling_strategy = "REPLICA"

#   # The service_registries block is optional
#   service_registries {
#     registry_arn = aws_service_discovery_service.daemon.arn
#   }

#   service_connect_configuration {
#     enabled   = true
#     namespace = aws_service_discovery_private_dns_namespace.dp_ns.name

#     # The service here is optional but also, there can be more than one service blocks in the service_connect_condfiguration
#     service {
#       port_name      = "daemon"
#       discovery_name = "dagster-daemon"
#     }
#   }

#   propagate_tags = "SERVICE"

#   tags = {
#     "com.docker.compose.project" = "dagster_deploy_ecs"
#     "com.docker.compose.service" = "daemon"
#   }
# }

# resource "aws_ecs_task_definition" "daemon_task_definition" {
#   family                   = "dagster_deploy_ecs-daemon"
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#   execution_role_arn       = module.iam_ecs_roles["daemon_task_execution_role"].role_arn
#   task_role_arn            = module.iam_ecs_roles["daemon_task_role"].role_arn
#   cpu                      = "256"
#   memory                   = "512"

#   container_definitions = jsonencode([
#     {
#       "name" : "daemon",
#       "image" : module.ecr_repos["daemon_repo"].repository_url,
#       "essential" : true,
#       "command" : ["dagster-daemon", "run"],
#       "environment" : [
#         { "name" : "DAGSTER_POSTGRES_DB", "value" : module.data-platform-db.db_instance_name },
#         { "name" : "DAGSTER_POSTGRES_HOSTNAME", "value" : module.data-platform-db.db_instance_hostname },
#         { "name" : "DAGSTER_POSTGRES_PASSWORD", "value" : aws_secretsmanager_secret_version.db_password.secret_string },
#         { "name" : "DAGSTER_POSTGRES_USER", "value" : module.data-platform-db.db_instance_username }
#       ],
#       "logConfiguration" : {
#         "logDriver" : "awslogs",
#         "options" : {
#           "awslogs-group" : module.dagster_log_group.name,
#           "awslogs-region" : data.aws_region.current.name,
#           "awslogs-stream-prefix" : "dagster_deploy_ecs"
#         }
#       },
#       "portMappings" : [
#         {
#           "name" : "daemon",
#           "hostport" : 4000,
#           "containerport" : 4000
#         }
#       ],
#     }
#   ])
#   # Enable ECS Exec

# }

# resource "aws_ecs_service" "webserver_service" {
#   depends_on = [
#     aws_ecs_service.user_code_service,
#     module.iam_ecs_roles,
#   ]
#   name            = "WebserverService"
#   cluster         = aws_ecs_cluster.dagster_cluster.arn
#   task_definition = aws_ecs_task_definition.webserver_task_definition.arn
#   desired_count   = 1
#   launch_type     = "FARGATE"

#   network_configuration {
#     assign_public_ip = true
#     security_groups = [
#     module.dagster_security_group.security_group_id, ]
#     subnets = module.data-platform-vpc.private_subnets
#   }

#   deployment_controller {
#     type = "ECS"
#   }

#   deployment_circuit_breaker {
#     enable   = true
#     rollback = true
#   }

#   scheduling_strategy = "REPLICA"

#   service_connect_configuration {
#     enabled   = true
#     namespace = aws_service_discovery_private_dns_namespace.dp_ns.name
#     service {
#       port_name      = "webserver"
#       discovery_name = "dagster-webserver"
#       client_alias {
#         port     = 3000
#         dns_name = "dagster-webserver"
#       }
#     }
#   }

#   propagate_tags = "SERVICE"

#   tags = {
#     "com.docker.compose.project" = "dagster_deploy_ecs"
#     "com.docker.compose.service" = "webserver"
#   }
# }

# resource "aws_ecs_task_definition" "webserver_task_definition" {
#   family                   = "dagster_deploy_ecs-webserver"
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#   cpu                      = "256"
#   memory                   = "512"
#   execution_role_arn       = module.iam_ecs_roles["webserver_task_execution_role"].role_arn
#   task_role_arn            = module.iam_ecs_roles["webserver_task_role"].role_arn
#   container_definitions = jsonencode([
#     {
#       "name" : "webserver",
#       "image" : module.ecr_repos["webserver_repo"].repository_url,
#       "essential" : true,
#       "command" : ["dagster-webserver", "-h", "0.0.0.0", "-p", "3000", "-w", "workspace.yaml"],
#       "environment" : [
#         { "name" : "DAGSTER_POSTGRES_DB", "value" : module.data-platform-db.db_instance_name },
#         { "name" : "DAGSTER_POSTGRES_HOSTNAME", "value" : module.data-platform-db.db_instance_hostname },
#         { "name" : "DAGSTER_POSTGRES_PASSWORD", "value" : aws_secretsmanager_secret_version.db_password.secret_string },
#         { "name" : "DAGSTER_POSTGRES_USER", "value" : module.data-platform-db.db_instance_username }
#       ],
#       "portMappings" : [
#         {
#           "name" : "webserver",
#           "containerPort" : 3000,
#           "hostPort" : 3000,
#         }
#       ],
#       "logConfiguration" : {
#         "logDriver" : "awslogs",
#         "options" : {
#           "awslogs-group" : module.dagster_log_group.name,
#           "awslogs-region" : data.aws_region.current.name,
#           "awslogs-stream-prefix" : "dagster_deploy_ecs"
#         }
#       }
#     }
#   ])
#   # Enable ECS Exec

# }

# resource "aws_ecs_service" "user_code_service" {
#   depends_on = [
#     module.iam_ecs_roles
#   ]
#   name            = "UserCodeService"
#   cluster         = aws_ecs_cluster.dagster_cluster.arn
#   task_definition = aws_ecs_task_definition.user_code_task_definition.arn
#   desired_count   = 1
#   launch_type     = "FARGATE"

#   network_configuration {
#     assign_public_ip = true
#     security_groups = [
#     module.dagster_security_group.security_group_id, ]
#     subnets = module.data-platform-vpc.private_subnets
#   }

#   deployment_controller {
#     type = "ECS"
#   }

#   deployment_circuit_breaker {
#     enable   = true
#     rollback = true
#   }

#   scheduling_strategy = "REPLICA"

#   service_connect_configuration {
#     enabled   = true
#     namespace = aws_service_discovery_private_dns_namespace.dp_ns.name
#     service {
#       port_name = "user_code"
#       client_alias {
#         port = 4000
#       }
#     }

#     service {
#       port_name      = "user_code"
#       discovery_name = "user_code_2"
#       client_alias {
#         port     = 4000
#         dns_name = "user_code"
#       }
#     }
#   }

#   propagate_tags = "SERVICE"

#   tags = {
#     "com.docker.compose.project" = "dagster_deploy_ecs"
#     "com.docker.compose.service" = "user_code"
#   }
# }

# resource "aws_ecs_task_definition" "user_code_task_definition" {
#   family                   = "dagster_deploy_ecs-user_code"
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#   cpu                      = "256"
#   memory                   = "512"
#   execution_role_arn       = module.iam_ecs_roles["user_code_task_execution_role"].role_arn
#   #   task_role_arn            = module.iam_ecs_roles["daemon_task_role"].role_arn  # task_role_arn            = aws_iam_role.usercode_task_execution_role.arn # Assuming you have a separate task role for user code

#   container_definitions = jsonencode([
#     {
#       "name" : "user_code",
#       "image" : module.ecr_repos["user_code_repo"].repository_url,
#       "essential" : true,
#       "command" : ["dagster", "api", "grpc", "-h", "0.0.0.0", "-p", "4000", "-f", "defs.py"],
#       "environment" : [
#         { "name" : "DAGSTER_CURRENT_IMAGE", "value" : module.ecr_repos["user_code_repo"].repository_url },
#         { "name" : "DAGSTER_POSTGRES_DB", "value" : module.data-platform-db.db_instance_name },
#         { "name" : "DAGSTER_POSTGRES_HOSTNAME", "value" : module.data-platform-db.db_instance_hostname },
#         { "name" : "DAGSTER_POSTGRES_PASSWORD", "value" : aws_secretsmanager_secret_version.db_password.secret_string },
#         { "name" : "DAGSTER_POSTGRES_USER", "value" : module.data-platform-db.db_instance_username }
#       ],
#       "logConfiguration" : {
#         "logDriver" : "awslogs",
#         "options" : {
#           "awslogs-group" : module.dagster_log_group.name,
#           "awslogs-region" : data.aws_region.current.name,
#           "awslogs-stream-prefix" : "dagster_deploy_ecs"
#         }
#       },
#       "portMappings" : [
#         {
#           "name" : "user_code",
#           "containerPort" : 4000,
#           "hostPort" : 4000
#         }
#       ],
#     }
#   ])

# }
