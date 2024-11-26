# IAM Variables

variable "bucket_name" {
  description = "Name of the S3 bucket that Lambda will interact"
  type        = string
}

variable "budget_state_bucket_name" {
  description = "Name of the S3 bucket that Lambda will read budget state from"
  type        = string
}

# variable "terraform_execution_role" {
#   description = "Name of the IAM role or user for Terraform"
#   type        = string
# }
