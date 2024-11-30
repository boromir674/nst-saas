# Thin-wrapper arround aws_iam_policy to create IAM Policy resources

## Variables
variable "policy_name" {
  description = "Resource Name of the IAM Policy"
  type        = string
}
variable "policy_description" {
  description = "Resource Description of the IAM Policy"
  type        = string
}
variable "policy_statements" {
  description = "List of IAM Policy Statements; one or more Permission Policies."
  type        = list(object({
    Effect    = string        # ie "Allow" or "Deny"
    Action    = list(string)  # ie ["s3:GetObject", "s3:PutObject"]
    Resource  = string        # ie arn:aws:s3:::my_bucket_name/*
  }))
}

## Outputs
output "policy_arn" {
  description = "ARN of the IAM Policy, required to attach to IAM Roles (Trust Policies)"
  value       = aws_iam_policy.permission_policy.arn
}

## Main

# 'Permission Policy' implemented as IAM Policy
resource "aws_iam_policy" "permission_policy" {
  name        = var.policy_name
  description = var.policy_description
  # Declare Permissions Policy: what actions are allowed on what resources
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = var.policy_statements
  })
}
