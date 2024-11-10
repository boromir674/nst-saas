# terraform/main.tf

# Module for S3 bucket to store NST images
# This module creates an S3 bucket, parameterized with a name specific to the environment.
module "s3_bucket" {
  source      = "./modules/s3_bucket"  # Path to the reusable S3 bucket module
  bucket_name = var.bucket_name        # Bucket name passed in as a variable
  enable_public_read = false           # Set to true to enable public read access
  enable_versioning  = false            # Enable versioning for object backups
  tags = {                             # Tags to apply to the bucket
    Environment = var.environment,
    IaaC        = "Terraform",
    App         = "NST"
  }
}

# Module for the Lambda function responsible for budget checking
# This Lambda checks if the NST budget allows a new processing job.
# module "budget_check_lambda" {
#   source           = "./modules/lambda"               # Path to the reusable Lambda module
#   function_name    = var.lambda_function_name         # Unique Lambda name per environment
#   handler          = var.lambda_handler               # Lambda handler (entry point)
#   runtime          = var.lambda_runtime               # Lambda runtime (e.g., python3.8)
#   environment_vars = var.environment_vars             # Environment-specific variables map
# }


# Module for Lambda function to generate pre-signed URLs for S3 uploads
module "presigned_url_lambda" {
  source           = "./modules/aws_lambda"
  function_name    = var.presigned_url_lambda_function_name
  handler          = var.presigned_url_lambda_handler
  runtime          = var.presigned_url_lambda_runtime
  role_arn         = var.presigned_url_lambda_role_arn
  bucket_name      = var.bucket_name
  url_expiration   = var.presigned_url_url_expiration
  lambda_package_path = var.presigned_url_lambda_package_path
  environment_vars = var.environment_vars
  tags = {
    Environment = var.environment,
    IaaC        = "Terraform",
    App         = "NST"
  }
}


# Module for API Gateway to expose endpoints
# This API Gateway integrates with the Lambda function for budget checking.
# module "api_gateway" {
#   source      = "./modules/api_gateway"                # Path to API Gateway module
#   api_name    = var.api_name                           # API name per environment
#   lambda_arns = [module.budget_check_lambda.lambda_arn]  # Links the budget check Lambda
# }
