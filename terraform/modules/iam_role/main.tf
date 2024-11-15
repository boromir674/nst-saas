# Thin-wrapper configurable entrypoint to create IAM Role resources on-demand

## Variables
variable "role_name" {
  description = "Resource Name of the IAM Role"
  type        = string
}
variable "description" {
  description = "Resource Description of the IAM Role"
  type        = string
}
variable "trust_policies" {
description = "List of IAM Policy Statements; one or more Trust Policies."
  type        = list(object({
    Effect    = string  # ie "Allow" or "Deny"
    Principal = object({
      Service = string  # ie "lambda.amazonaws.com"
    })
    Action    = string  #  ie "sts:AssumeRole"
    # TODO: support Condition! ie to limit which Lambdas can assume this Role
  }))
}

## Outputs
output role_name {
  description = "Name of the IAM Role, required to create Attachment with IAM (Permission) Policies"
  value       = aws_iam_role.role.name
}
output role_arn {
  description = "ARN of the IAM Role, required to let other resources (ie Lambda) assume this (Trust Policy) Role"
  value       = aws_iam_role.role.arn
}

## Main

# 'Trust Policy' implemented as IAM Role
resource "aws_iam_role" "role" {
  name = var.role_name
  description = var.description
  # Declare Trust Policy: what services/users/identities can assume this Role
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = var.trust_policies
  })
}