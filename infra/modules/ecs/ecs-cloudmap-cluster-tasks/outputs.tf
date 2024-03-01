output "created_ecs_cluster_arn" {
  value = aws_ecs_cluster.this.arn
}

output "created_ecs_cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "task_definition_arns" {
  value       = { for task in aws_ecs_task_definition.task : task.family => task.arn }
  description = "A map of task definition families to their ARNs."
}