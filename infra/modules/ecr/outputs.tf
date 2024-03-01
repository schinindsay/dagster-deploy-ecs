output "repository_arn" {
  value = aws_ecr_repository.this.arn
}

output "repository_url" {
  value       = aws_ecr_repository.this.repository_url
  description = "The URL of the repository (in the form aws_account_id.dkr.ecr.region.amazonaws.com/repositoryName)."
}