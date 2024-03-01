resource "aws_ecr_repository" "this" {
  name                 = var.repo_name
  image_tag_mutability = var.repository_image_tag_mutability
  force_delete         = var.repository_force_delete

  image_scanning_configuration {
    scan_on_push = var.repository_image_scan_on_push
  }

  tags = var.tags
}

resource "aws_ecr_repository_policy" "this" {
  count = var.attach_repository_policy ? 1 : 0

  repository = aws_ecr_repository.this.name
  policy     = var.ecr_repository_policy
}