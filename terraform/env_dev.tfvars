# environments/dev/terraform.tfvars

# AWS region for entire infrastructure of dev environment
aws_region = "eu-central-1"

# S3 bucket name for storing NST images in the dev environment
bucket_name = "nst-bucket-dev"

# Lambda function details for budget check in the dev environment
lambda_function_name = "budget_check_dev"
lambda_handler       = "budget_check.handler" # Set to match your Lambda entry point
lambda_runtime       = "python3.11"           # Choose the Lambda runtime for your function

# Environment variables for the Lambda functions
environment_vars = {
  ENV = "dev"
}


# URL Provider: Lambda function details for presigned URL generator in dev environment
presigned_url_lambda_package_path  = "../lambda_url_provider/lambda_url_provider.zip" # Path to the ZIP file
presigned_url_lambda_function_name = "generate_presigned_url_dev"
presigned_url_lambda_handler       = "generate_presigned_url.handler"                     # Set to the new handler entry point
presigned_url_lambda_runtime       = "python3.11"                                         # Runtime for the presigned URL Lambda function
presigned_url_lambda_role_arn      = "arn:aws:iam::123456789012:role/LambdaExecutionRole" # IAM role ARN
presigned_url_url_expiration       = 3600                                                 # Expiration time for the presigned URL in seconds
presigned_url_lambda_tags = {
  Environment = "dev",
  IaaC        = "Terraform",
  App         = "NST"
}


# API Gateway name for the dev environment
api_name = "nst-api-dev"


# Environment tag to apply to resources
environment_name = "dev"
