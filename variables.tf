# GENERAL VARIABLES
variable "aws_account_id" {
  description = "The AWS account ID"
  type        = string
}

variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources to"
}

variable "namespace" {
  description = "Namespace (e.g. `yourcompany` or `yourorg`)"
  type        = string
}

variable "stage" {
  type        = string
  description = "Stage/environment (e.g. `dev`, `staging`, `prod`)"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags for all AWS resources"
  default     = {}
}

variable "default_tags" {
  type        = map(string)
  description = "Default tags to apply to all resources"
  default     = {}
}

# MODULE VARIABLES
variable "buckets" {
  description = "Map of S3 bucket configurations"
  type        = any
  default     = {}
}
