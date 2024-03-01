module "dagster_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = var.dagster_sg_name
  description = "Security group to connect to the Dagster instance"
  vpc_id      = var.vpc_id

  egress_with_cidr_blocks = [
    {
      from_port   = 0,
      to_port     = 0,
      protocol    = "-1",
      description = "Allow egress to anywhere.",
      cidr_blocks = "0.0.0.0/0",
    }
  ]

  ingress_with_cidr_blocks = [
    {
      from_port   = var.dagster_webserver_port,
      to_port     = var.dagster_webserver_port,
      protocol    = "tcp",
      description = "Ingress for webserver ui.",
      cidr_blocks = "0.0.0.0/0",
    },
    {
      from_port   = var.dagster_user_code_port,
      to_port     = var.dagster_user_code_port,
      protocol    = "tcp",
      description = "Ingress for user code on port 4000.",
      cidr_blocks = "0.0.0.0/0",
    },
    {
      from_port   = 80,
      to_port     = 80,
      protocol    = "tcp",
      description = "HTTP",
      cidr_blocks = "0.0.0.0/0",
    },
    {
      from_port   = 443,
      to_port     = 443,
      protocol    = "tcp",
      description = "HTTPS",
      cidr_blocks = "0.0.0.0/0",
    }
  ]

  computed_ingress_with_self = [
    {
      protocol    = "-1",
      from_port   = 0,
      to_port     = 0,
      description = "",
      self        = true,
    }
  ]

  # egress_with_cidr_blocks = [for cidr in var.egress_cidr_blocks : {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1"
  #   description = "Allow egress to anywhere."
  #   cidr_blocks = cidr
  # }]

  # ingress_with_cidr_blocks = concat([
  #   {
  #     from_port   = var.dagster_webserver_port
  #     to_port     = var.dagster_webserver_port
  #     protocol    = "tcp"
  #     description = "Ingress for webserver UI."
  #     # cidr_blocks = var.ingress_cidr_blocks
  #     cidr_blocks = "0.0.0.0/0"
  #   },
  #   {
  #     from_port   = var.dagster_user_code_port
  #     to_port     = var.dagster_user_code_port
  #     protocol    = "tcp"
  #     description = "Ingress for user code."
  #     # cidr_blocks = var.ingress_cidr_blocks
  #     cidr_blocks = "0.0.0.0/0"
  #   }
  # ], var.ingress_rules)

  tags = var.tags
}