resource "aws_service_discovery_private_dns_namespace" "this" {
  count = var.namespace_name != "" ? 1 : 0

  name = var.namespace_name
  vpc  = var.vpc_id
}

resource "aws_service_discovery_service" "this" {
  for_each = var.service_discovery_configs

  name        = each.key
  description = each.value.description

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this[0].id

    routing_policy = each.value.dns_config["routing_policy"]

    dynamic "dns_records" {
      for_each = each.value.dns_config.dns_records
      content {
        ttl  = dns_records.value.ttl
        type = dns_records.value.type
      }
    }
  }

  dynamic "health_check_custom_config" {
    for_each = each.value.health_check_custom_config
    content {
      failure_threshold = health_check_custom_config.value.failure_threshold
    }
  }
}

// CREATE AN ECS CLUSTER
resource "aws_ecs_cluster" "this" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = var.tags
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

// CREATE ECS TASKS
resource "aws_ecs_task_definition" "task" {
  for_each = var.task_definitions

  family                   = each.value.family
  network_mode             = each.value.network_mode
  requires_compatibilities = each.value.requires_compatibilities
  execution_role_arn       = each.value.execution_role_arn
  task_role_arn            = each.value.task_role_arn
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  container_definitions    = each.value.container_definitions
}


#  CREATE ECS SERVICES
#  TODO: THIS IS NOT WORKING BECAUSE OF THE SERVICE CONNECT CONFIG BLOCK.  CREATING SERVICE-WITH-SERVICE-CONNECT MODULE TO AVOID THE NESTED LOOPS.  WOULD BE NICE TO FIGURE THIS OUT LATER
resource "aws_ecs_service" "service" {
  for_each = var.services

  name            = each.key
  cluster         = aws_ecs_cluster.this.arn
  task_definition = aws_ecs_task_definition.task[each.value.task_definition_family].arn
  desired_count   = each.value.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    assign_public_ip = each.value.assign_public_ip
    security_groups  = each.value.security_group_ids
    subnets          = each.value.subnet_ids
  }

  deployment_controller {
    type = "ECS"
  }

  deployment_circuit_breaker {
    enable   = each.value.deployment_circuit_breaker_enable
    rollback = each.value.deployment_circuit_breaker_rollback
  }

  scheduling_strategy = "REPLICA"

  dynamic "service_registries" {
    for_each = each.value.service_registries
    content {
      registry_arn = service_registries.value.registry_arn
    }
  }

  service_connect_configuration {
    enabled   = each.value.service_connect_enabled
    namespace = each.value.service_connect_namespace

    dynamic "service" {
      for_each = each.value.service_connect_services
      iterator = service
      content {
        port_name      = service.value.port_name
        discovery_name = service.value.discovery_name

        dynamic "client_alias" {
          for_each = service.value.client_alias
          iterator = client_alias
          content {
            port     = client_alias.value.port
            dns_name = client_alias.value.dns_name
          }
        }
      }
    }
  }

  # service_connect_configuration {
  #   enabled   = each.value.service_connect_enabled
  #   namespace = each.value.service_connect_namespace

  #   dynamic "service" {
  #     for_each = each.value.service_connect_services
  #     content {
  #       port_name      = each.value.port_name
  #       discovery_name = each.value.discovery_name
  #       dynamic "client_alias" {
  #         for_each = service.value.client_alias
  #         content {
  #           port     = client_alias.value.port
  #           dns_name = client_alias.value.dns_name
  #         }
  #       }
  #     }
  #   }

  # dynamic "service" {
  #   for_each = each.value.service_connect_services_no_client
  #   content {
  #     port_name      = service.value.port_name
  #     discovery_name = service.value.discovery_name
  #   }
  # }

  # dynamic "service" {
  #   for_each = each.value.service_connect_services
  #   content {
  #     port_name      = service.value.port_name
  #     discovery_name = service.value.discovery_name
  #     dynamic "client_alias" {
  #       for_each = service.value.client_alias
  #       content {
  #         port     = client_alias.value.port
  #         dns_name = client_alias.value.dns_name
  #       }
  #     } 
  #   }
  # }


  propagate_tags = "SERVICE"
}

///////////////////////////////
//////////////////////////////

# # service_connect_configuration {
# #     enabled   = each.value.service_connect_enabled
# #     namespace = each.value.service_connect_namespace

# #     # Iterate over services with alias
# #     dynamic "service" {
# #       for_each = each.value.service_connect_services_with_alias
# #       content {
# #         port_name      = service.value.port_name
# #         discovery_name = service.value.discovery_name

# #         dynamic "client_alias" {
# #           for_each = service.value.client_alias
# #           content {
# #             port     = client_alias.value.port
# #             dns_name = client_alias.value.dns_name
# #           }
# #         }
# #       }
# #     }

# #     # Iterate over services without alias
# #     dynamic "service" {
# #       for_each = each.value.service_connect_services_without_alias
# #       content {
# #         port_name      = service.value.port_name
# #         discovery_name = service.value.discovery_name
# #         # No client_alias block here
# #       }
# #     }
# #   }


# #   propagate_tags = "SERVICE"
# #   tags            = each.value.tags
# # }

# # dynamic "service" {
# #   for_each = each.value.service_connect_services_with_alias
# #   content {
# #     port_name      = service.value.port_name
# #     discovery_name = service.value.discovery_name


# #     dynamic "client_alias" {
# #       // Attempt to access client_alias, defaulting to an empty list if it's not present or empty
# #       for_each = try(length(service.value.client_alias) > 0 ? service.value.client_alias : [], [])
# #       content {
# #         port     = client_alias.value.port
# #         dns_name = client_alias.value.dns_name
# #       }
# #     }
# #   }
# # }