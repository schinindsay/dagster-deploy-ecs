variable "vpc_id" {
  type        = string
  description = "The id of the VPC where dagster resources will be deployed."
}

variable "region" {
  default     = "us-east-1"
  type        = string
  description = "The aws region where the vpc and dagster resources are."
}

variable "dagster_sg_name" {
  type        = string
  description = "The name for the dagster security group"
}

variable "dagster_webserver_port" {
  type        = string
  description = "The port where the dagster webserver or dagit listens."
  default     = 3000
}

variable "dagster_user_code_port" {
  type        = string
  description = "The port where the dagster user_code or server listens."
  default     = 4000
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "dagster_ecr_access_roles" {
  type        = list(string)
  default     = ["*"]
  description = "A list of role ARNs that are allowed to access the code server ecr repository"
}

variable "dagster_repository_read_write_access_arns" {
  type        = list(string)
  description = "A list of ARNs that have read/write access to the ecr repositories."
}

variable "dagster_log_group_name" {
  type        = string
  description = "The name of the cloudwatch group for dagster resources."
  default     = "dagster"
}

variable "cloudwatch_retention_days" {
  type        = number
  default     = 7
  description = "The number of days to keep the cloudwatch logs."
}

variable "daemon_environment_variables" {
  type = list(any)
}

variable "webserver_environment_variables" {
  type = list(any)
}

variable "user_code_environment_variables" {
  type = list(any)
}

variable "dagster_subnet_ids" {
  type = list(string)
}

variable "ingress_rules" {
  description = "Custom ingress rules for the security group."
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      from_port   = 80,
      to_port     = 80,
      protocol    = "tcp",
      description = "HTTP",
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 443,
      to_port     = 443,
      protocol    = "tcp",
      description = "HTTPS",
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "egress_cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks to allow egress traffic to."
  default     = ["0.0.0.0/0"]
}

variable "ingress_cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks to allow ingress traffic from."
  default     = ["0.0.0.0/0"]
}