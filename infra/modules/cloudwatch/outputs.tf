output "log_group" {
  description = "Log group resource output."
  value       = aws_cloudwatch_log_group.this
}

output "name" {
  description = "The name of the cloudwatch log group."
  value       = aws_cloudwatch_log_group.this.name
}

output "arn" {
  description = "The arn of the log group."
  value       = aws_cloudwatch_log_group.this.arn
}