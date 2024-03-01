locals {
  daemon_user_code_policy_json = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ec2:DescribeNetworkInterfaces",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeTasks",
          "ecs:ListAccountSettings",
          "ecs:RegisterTaskDefinition",
          "ecs:RunTask",
          "ecs:TagResource",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecrets",
          "secretsmanager:GetSecretValue",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action   = "iam:PassRole",
        Effect   = "Allow",
        Resource = "*",
        Condition = {
          StringLike = {
            "iam:PassedToService" = "ecs-tasks.amazonaws.com"
          }
        }
      }
    ]
  })

  webserver_policy_json = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ecs:DescribeTasks",
          "ecs:StopTask",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action   = "iam:PassRole",
        Effect   = "Allow",
        Resource = "*",
        Condition = {
          StringLike = {
            "iam:PassedToService" = "ecs-tasks.amazonaws.com"
          }
        }
      }
    ]
  })

  dagster_ecs_role_confs = {

    daemon_task_execution_role = {
      role_name = "DaemonTaskExecutionRole"
      policy_arns = [
        "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      ]
      attach_custom_role_policy = true
      custom_role_policy = {
        policy_name = "DaemonPolicy"
        policy      = local.daemon_user_code_policy_json
      }
      tags = {}
    },

    daemon_task_role = {
      role_name                 = "DaemonTaskRole"
      attach_custom_role_policy = true
      custom_role_policy = {
        policy_name = "DaemonPolicy"
        policy      = local.daemon_user_code_policy_json
      }
      policy_arns = [
        "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      ]
      tags = {}
    },

    webserver_task_execution_role = {
      role_name = "WebserverTaskExecutionRole"
      policy_arns = [
        "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      ]
      attach_custom_role_policy = true
      custom_role_policy = {
        policy_name = "webserverPolicy"
        policy      = local.webserver_policy_json
      }
      tags = {}
    },

    webserver_task_role = {
      role_name                 = "WebserverTaskRole"
      attach_custom_role_policy = true
      custom_role_policy = {
        policy_name = "webserverPolicy"
        policy      = local.webserver_policy_json
      }
      policy_arns = [
        "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      ]
      tags = {}
    },

    user_code_task_execution_role = {
      role_name = "UserCodeTaskExecutionRole"
      policy_arns = [
        "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      ]
      attach_custom_role_policy = true
      custom_role_policy = {
        policy_name = "webserverPolicy"
        policy      = local.daemon_user_code_policy_json
      }
      tags = {}
    },


    user_code_task_role = {
      role_name = "UserCodeTaskRole"
      policy_arns = [
        "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      ]
      tags                      = {}
      attach_custom_role_policy = true
      custom_role_policy = {
        policy_name = "webserverPolicy"
        policy      = local.daemon_user_code_policy_json
      }
    },
  }
}

module "iam_ecs_roles" {

  for_each = local.dagster_ecs_role_confs
  source   = "../iam/ecs_roles"

  role_name = each.value.role_name
  tags      = each.value.tags


  # TODO: FIX THIS - WE DO NOT WANT TO HAVE TO SPECIFY POLICY ARNS AND AN EMPTY LIST IS THROWING AN ERROR HERE
  policy_arns = each.value.policy_arns
  # policy_arns               = each.value.policy_arns != null ? each.value.policy_arns : [] # Ensure this defaults to an empty list if not specified
  attach_custom_role_policy = each.value.attach_custom_role_policy != null ? each.value.attach_custom_role_policy : false # Default to false if not specified

  custom_role_policy = each.value.custom_role_policy
  # custom_role_policy        = each.value.custom_role_policy != null ? each.value.custom_role_policy : { policy_name = null, policy = null } # Default to null values if not specified
}