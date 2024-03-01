variable "log_group_name" {
  type        = string
  description = "The name of the cloudwatch log group."
}

variable "retention_in_days" {
  type        = number
  description = "The number of days to keep the logs."
}

variable "tags" {
  description = "Tags for the cloudwatch log group."
  type        = map(string)
  default     = {}
}