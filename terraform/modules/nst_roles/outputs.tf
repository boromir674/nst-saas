
## OUTPUT ARN's OF IAM ROLES created for Lambda functions ##

output "url_provider_execution_role_arn" {
  description = "ARN of the 'URL Provider' IAM Lambda execution role"
  value       = length(module.provide_presigned_url_role) > 0 ? module.provide_presigned_url_role[0].role_arn : ""
}

output "read_budget_execution_role_arn" {
  description = "ARN of the 'Read Budget State' IAM Lambda execution role"
  value       = length(module.read_budget_role) > 0 ? module.read_budget_role[0].role_arn : ""
}


