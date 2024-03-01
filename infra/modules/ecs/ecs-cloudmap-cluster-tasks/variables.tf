variable "namespace_name" {
  type        = string
  description = "The name of the service discovery namespace"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID for the DNS namespace. Required if creating a namespace."
  default     = ""
}

variable "service_discovery_configs" {
  type = map(object({
    description = string

    dns_config = map(object({

      routing_policy = string

      dns_records = list(object({
        ttl  = number
        type = string
      }))

    }))

    health_check_custom_config = list(object({
      failure_threshold = number
    }))

  }))

  default = {}
}

variable "cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "task_definitions" {
  type = map(object({
    family                   = string
    network_mode             = string
    requires_compatibilities = list(string)
    execution_role_arn       = string
    task_role_arn            = string
    cpu                      = string
    memory                   = string
    container_definitions    = any
  }))
  description = "A list of task definitions."
}

variable "services" {
  description = "A map where each entry represents a service and its configuration"
  type = map(object({
    task_definition_family              = string
    desired_count                       = number
    assign_public_ip                    = bool
    security_group_ids                  = list(string)
    subnet_ids                          = list(string)
    deployment_circuit_breaker_enable   = bool
    deployment_circuit_breaker_rollback = bool
    service_registries = list(object({
      registry_arn = string
    }))
    service_connect_enabled   = bool
    service_connect_namespace = string

    service_connect_services = map(object({
      port_name      = string
      discovery_name = string

      client_alias = list(object({
        port     = number
        dns_name = string
      }))
    }))


    # service_connect_services = list(object({
    #   port_name      = string
    #   discovery_name = string
    #   client_alias   = list(object({
    #     port     = number
    #     dns_name = string
    #   }))
    # }))

    # service_connect_services_no_client = list(object({
    #   port_name      = string
    #   discovery_name = string
    # }))



    # service_connect_services_with_alias = list(object({
    #   port_name      = string
    #   discovery_name = string
    #   client_alias   = list(object({
    #     port     = number
    #     dns_name = string
    #   }))
    # }))

    # service_connect_services_without_alias         = list(object({
    #   port_name      = string
    #   discovery_name = string
    # }))

    tags = map(string)
  }))
}