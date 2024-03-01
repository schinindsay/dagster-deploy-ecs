variable "repo_name" {
  type        = string
  description = "The name of the ECR repository."
}

variable "repository_type" {
  type        = string
  description = "The type of repository to create. Either 'public' or 'private'. Defaults to 'private'."
  default     = "private"
}

variable "attach_lifecycle_policy" {
  type        = bool
  description = "Indicates whether to attach a lifecycle policy to the ECR repository. Defaults to false."
  default     = false
}

variable "repository_lifecycle_policy" {
  type        = string
  description = "The JSON content of the lifecycle policy. Defaults to null, indicating no policy."
  default     = null
}

variable "repository_read_write_access_arns" {
  type        = set(string)
  description = "A set of ARNs that should be granted read/write access to the ECR repository."
}

variable "repository_force_delete" {
  type        = bool
  description = "Allows the repository to be force deleted even if it contains images. Defaults to true."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to the ECR repository. Defaults to an empty map."
  default     = {}
}

variable "attach_repository_policy" {
  type        = bool
  description = "Determines whether a repository policy will be attached to the repository. Defaults to false."
  default     = false
}

variable "ecr_repository_policy" {
  type        = string
  description = "The repository policy JSON. If null, no policy will be applied. Defaults to null."
  default     = null
}

variable "repository_image_tag_mutability" {
  type        = string
  description = "Determines the tag mutability settings for the repository. Options are 'MUTABLE' or 'IMMUTABLE'. Defaults to 'MUTABLE'."
  default     = "MUTABLE"
}

variable "repository_image_scan_on_push" {
  type        = bool
  description = "Indicates whether images are scanned after being pushed to the repository. Defaults to true."
  default     = true
}
