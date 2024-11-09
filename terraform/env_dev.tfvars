# environments/dev/terraform.tfvars

# AWS region for entire infrastructure of dev environment
aws_region = "eu-central-1"

# S3 bucket name for storing NST images in the dev environment
bucket_name = "nst-bucket-dev"

# Lambda function details for budget check in the dev environment
lambda_function_name = "budget_check_dev"
lambda_handler       = "budget_check.handler"  # Set to match your Lambda entry point
lambda_runtime       = "python3.11"             # Choose the Lambda runtime for your function

# Environment variables for the Lambda function
environment_vars = {
  ENV = "dev"
}

# API Gateway name for the dev environment
api_name = "nst-api-dev"
