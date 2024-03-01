variable "role_name" {
  type        = string
  description = "The name of the ECS role."
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to the ECS role."
  default     = {}
}

variable "policy_arns" {
  type        = list(string)
  description = "A list of IAM policy ARNs to attach to the ECS role."
  default     = []
}

variable "attach_custom_role_policy" {
  type        = bool
  description = "Determines whether to attach a custom IAM role policy. Defaults to false."
  default     = false
}

variable "custom_role_policy" {
  type        = map(any)
  description = "Configuration for a custom IAM role policy, including the policy name and policy document."
  default = {
    policy_name = ""
    policy      = ""
  }
}
