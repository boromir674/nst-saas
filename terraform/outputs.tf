# terraform/outputs.tf
# outputs display essential information after provisioning resources.
# These outputs are useful for verifying deployments and accessing resource details like bucket names or API URLs.


# Output the name of the S3 bucket created for storing NST images.
output "bucket_name" {
  description = "The name of the S3 bucket for storing NST images"
  value       = module.s3_bucket.bucket_name  # Pulls the bucket name from the S3 bucket module
}

# Output the URL of the S3 bucket for quick access (useful for testing or debugging)
output "bucket_url" {
  description = "The URL for accessing the S3 bucket"
  value       = "https://${module.s3_bucket.bucket_name}.s3.amazonaws.com"
}

# Output the ARN (Amazon Resource Name) of the Lambda function for budget checking
# output "budget_check_lambda_arn" {
#   description = "The ARN of the budget check Lambda function"
#   value       = module.budget_check_lambda.lambda_arn  # Gets the ARN from the Lambda module
# }

# Output the URL of the API Gateway for invoking endpoints
# output "api_gateway_url" {
#   description = "The base URL of the API Gateway for budget check"
#   value       = module.api_gateway.api_url  # Assumes api_url is defined as an output in the API Gateway module
# }
