locals {
  ecr_push_all_access_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "EcrAllowPushPull",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : var.dagster_ecr_access_roles
        },
        "Action" : [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
      }
    ]
  })

  dagster_ecr_repo_confs = {
    user_code_repo = {
      repo_name                         = "user_code"
      repository_type                   = "private"
      attach_lifecycle_policy           = false
      repository_lifecycle_policy       = null
      repository_read_write_access_arns = var.dagster_repository_read_write_access_arns
      repository_force_delete           = true
      attach_repository_policy          = true
      ecr_repository_policy             = local.ecr_push_all_access_policy
      repository_image_scan_on_push     = true
      tags                              = {}
    },
    daemon_repo = {
      repo_name                         = "daemon"
      repository_type                   = "private"
      attach_lifecycle_policy           = false
      repository_lifecycle_policy       = null
      repository_read_write_access_arns = var.dagster_repository_read_write_access_arns
      repository_force_delete           = true
      attach_repository_policy          = true
      ecr_repository_policy             = local.ecr_push_all_access_policy
      repository_image_scan_on_push     = true
      tags                              = {}
    },
    webserver_repo = {
      repo_name                         = "webserver"
      repository_type                   = "private"
      attach_lifecycle_policy           = false
      repository_lifecycle_policy       = null
      repository_read_write_access_arns = var.dagster_repository_read_write_access_arns
      repository_force_delete           = true
      attach_repository_policy          = true
      repository_image_scan_on_push     = true
      ecr_repository_policy             = local.ecr_push_all_access_policy
      tags                              = {}
    }
  }
}


module "ecr_repos" {

  for_each = local.dagster_ecr_repo_confs
  source   = "../ecr"

  repo_name                         = each.value.repo_name
  repository_type                   = each.value.repository_type
  attach_lifecycle_policy           = each.value.attach_lifecycle_policy
  repository_read_write_access_arns = each.value.repository_read_write_access_arns
  repository_force_delete           = each.value.repository_force_delete
  attach_repository_policy          = each.value.attach_repository_policy
  ecr_repository_policy             = each.value.ecr_repository_policy
  tags                              = each.value.tags
}
