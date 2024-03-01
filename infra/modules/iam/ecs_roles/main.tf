resource "aws_iam_role" "ecs_role" {
  name = var.role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  for_each   = toset(var.policy_arns)
  role       = aws_iam_role.ecs_role.name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "policy" {
  count  = var.attach_custom_role_policy ? 1 : 0
  name   = var.custom_role_policy["policy_name"]
  role   = aws_iam_role.ecs_role.name
  policy = var.custom_role_policy["policy"]
}
