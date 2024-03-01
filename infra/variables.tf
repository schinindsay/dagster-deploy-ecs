variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region for the backend resources. Will default to the session region."
}

variable "aws_profile" {
  type        = string
  default     = ""
  description = "AWS cli profile."
}

variable "environment" {
  type        = string
  default     = "staging"
  description = "Environment where resources will be created - should be either dev, staging, or prod."
}

variable "tags" {
  type        = map(string)
  default     = { Name = "dagster" }
  description = "Tags to add to the created resources."
}