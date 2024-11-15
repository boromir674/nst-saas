# terraform/outputs.tf
# outputs display essential information after provisioning resources.
# These outputs are useful for verifying deployments and accessing resource details like bucket names or API URLs.

## 'NST Storage' S3 Bucket
output "storage_bucket_name" {
  description = "The name of the 'NST Storage' S3 bucket for storing Content and Style images"
  value       = module.s3_bucket.bucket_name # Pulls the bucket name from the S3 bucket module
}
output "storage_bucket_url" {
  description = "The URL for accessing the 'NST Storage' S3 bucket"
  value       = module.s3_bucket.bucket_name != "" ? "https://${module.s3_bucket.bucket_name}.s3.amazonaws.com" : ""
}

## 'Budget State' S3 Bucket
output "budget_state_bucket_name" {
  description = "The name of the 'Budget State' S3 bucket for storing budget state"
  value       = module.budget_state_bucket.bucket_name # Pulls the bucket name from the S3 bucket module
}
output "budget_state_bucket_url" {
  description = "The URL for accessing the 'Budget State' S3 bucket"
  value       = module.budget_state_bucket.bucket_name != "" ? "https://${module.budget_state_bucket.bucket_name}.s3.amazonaws.com" : ""
}


# Output the ARN (Amazon Resource Name) of the Lambda function for budget checking
# output "budget_check_lambda_arn" {
#   description = "The ARN of the budget check Lambda function"
#   value       = module.budget_check_lambda.lambda_arn  # Gets the ARN from the Lambda module
# }


## 'URL Provider' Lambda Outputs
output "presigned_url_lambda_name" {
  description = "Name of the presigned URL Lambda function"
  value       = length(module.presigned_url_lambda) > 0 ? module.presigned_url_lambda.lambda_name : ""
}
output "presigned_url_lambda_arn" {
  description = "ARN of the presigned URL Lambda function"
  value       = length(module.presigned_url_lambda) > 0 ? module.presigned_url_lambda.lambda_arn : ""
}
output "presigned_url_lambda_invoke_arn" {
  description = "ARN to invoke the presigned URL Lambda function"
  value       = length(module.presigned_url_lambda) > 0 ? module.presigned_url_lambda.lambda_invoke_arn : ""
}

## 'Read Budget State' Lambda Outputs
output "budget_check_lambda_name" {
  description = "Name of the budget check Lambda function"
  value       = length(module.budget_check_lambda) > 0 ? module.budget_check_lambda.lambda_name : ""
}

# output "presigned_url_lambda_arn" {
#   description = "ARN of the presigned URL Lambda function"
#   value       = module.presigned_url_lambda.lambda_arn
# }



# Output the URL of the API Gateway for invoking endpoints
# output "api_gateway_url" {
#   description = "The base URL of the API Gateway for budget check"
#   value       = module.api_gateway.api_url  # Assumes api_url is defined as an output in the API Gateway module
# }


### Output of API Gateway related resources

# output "api_invoke_url" {
#   description = "Base URL for API Gateway"
#   value       = aws_api_gateway_deployment.api_deployment.invoke_url
# }


## DEBUG Outputs

# Output the 'URL Provider' Role arn
output "url_provider_execution_role_arn" {
  description = "ARN of the 'URL Provider' Lambda execution role"
  value       = module.iam.url_provider_execution_role_arn
}

# Output the 'Read Budget State' Role arn
output "read_budget_execution_role_arn" {
  description = "ARN of the 'Read Budget State' Lambda execution role"
  value       = module.iam.read_budget_execution_role_arn
}