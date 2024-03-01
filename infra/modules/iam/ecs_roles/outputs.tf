output "role_arn" {
  value       = aws_iam_role.ecs_role.arn
  description = "The ARN of the created IAM role."
}