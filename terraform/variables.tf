# terraform/variables.tf

### AWS region where resources will be created, by Provider ###
variable "aws_region" {
  description = "The AWS region for resources"
  type        = string
  default     = "eu-central-1"  # Replace with your preferred region, if necessary
}

#### Resource: S3 bucket for storing NST images ####
# This should be unique per environment and specified in `terraform.tfvars`.
variable "bucket_name" {
  description = "The name of the S3 bucket to store NST images"
  type        = string
}

#### Resource: URL Provider Lambda ####
# Lambda function name for the budget check function
variable "lambda_function_name" {
  description = "Name of the Lambda function for budget checking"
  type        = string
}

# Lambda handler for the entry point of the function
variable "lambda_handler" {
  description = "Lambda function handler (entry point)"
  type        = string
  default     = "app.handler"  # Replace with the actual handler if different
}

# Lambda runtime (e.g., Python 3.8, Node.js 14.x)
variable "lambda_runtime" {
  description = "Runtime environment for the Lambda function"
  type        = string
  default     = "python3.11"
}

# Environment variables for Lambda functions
variable "environment_vars" {
  description = "A map of environment variables for the Lambda function"
  type        = map(string)
  default     = {}  # Default to an empty map; define specific values in `terraform.tfvars`
}


#### Resource: URL Provider Lambda ####
variable "presigned_url_lambda_function_name" {
  description = "Name of the Lambda function for generating presigned URLs"
  type        = string
}

variable "presigned_url_lambda_handler" {
  description = "Handler for the presigned URL Lambda function"
  type        = string
}

variable "presigned_url_lambda_runtime" {
  description = "Runtime environment for the presigned URL Lambda function"
  type        = string
}

variable "presigned_url_lambda_role_arn" {
  description = "IAM role ARN that presigned URL Lambda function assumes"
  type        = string
}

variable "presigned_url_url_expiration" {
  description = "Expiration time for the presigned URL in seconds"
  type        = number
}

variable "presigned_url_lambda_package_path" {
  description = "Path to the Lambda deployment package (ZIP file) for presigned URL generator"
  type        = string
}


#### Resource: API Gateway ####
variable "api_name" {
  description = "Name of the API Gateway for exposing endpoints"
  type        = string
}

## Support Variables ##
# Environment tag to apply to resources
variable "environment" {
  description = "The environment tag for resources"
  type        = string
  default     = "dev"  # Default to 'dev' environment
}