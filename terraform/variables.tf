# terraform/variables.tf

### If missing it is Required to be added to local user/role/dev to pass the Lambda execution role ###
# variable "terraform_execution_role" {
#   # Define a variable to pass the IAM user or role name
#   description = "IAM role or user running Terraform with permissions to manage resources"
#   type        = string
# }


### AWS region where resources will be created, by Provider ###
variable "aws_region" {
  description = "The AWS region for resources"
  type        = string
  default     = "eu-central-1" # Replace with your preferred region, if necessary
}

#### Resource: S3 bucket for storing NST images ####
# This should be unique per environment and specified in `terraform.tfvars`.
# Also the URL Provider lambda interacts with this S3 bucket.
variable "storage_bucket_name" {
  description = "The name of the S3 bucket to store NST images"
  type        = string
  default     = "" # Explicit value passed required to create this Resourcce
}

variable "budget_state_bucket_name" {
  description = "The name of the S3 bucket to store the Budget State"
  type        = string
  default     = "" # Explicit value passed required to create this Resourcce
}

#### Resource: URL Provider Lambda ####

# Common Environment variables for Lambda functions
variable "environment_vars" {
  description = "A map of common environment variables shared by all/any Lambda Functions"
  type        = map(string)
  default     = {} # Default to an empty map; define specific values in `terraform.tfvars`
}

#### Resource: URL Provider Lambda ####
variable "presigned_url_lambda_function_name" {
  description = "Name of the Lambda function for generating presigned URLs"
  type        = string
  default     = "" # Leave empty default to prevent resource creation
}

variable "presigned_url_lambda_handler" {
  description = "Handler for the presigned URL Lambda function"
  type        = string
  default     = "" # Leave empty to use the default handler or pass value to override
}

variable "presigned_url_url_expiration" {
  description = "Expiration time for the presigned URL in seconds"
  type        = number
  default     = 3600 # Default to 1 hour (3600 seconds)
}

variable "presigned_url_lambda_package_path" {
  description = "Path to the Lambda deployment package (ZIP file) for presigned URL generator"
  type        = string
  default     = ""
}

variable "presigned_url_lambda_tags" {
  description = "Tags to apply to the presigned URL Lambda function"
  type        = map(string)
  default     = {} # Default to an empty map; define specific values in `terraform.tfvars`
}

#### Resource: API Gateway ####
variable "api_name" {
  description = "Name of the API Gateway for exposing endpoints"
  type        = string
  default     = "" # Explicit value passed required to create this Resourcce
}

## Support Variables ##
# Environment tag to apply to resources: one of test, dev, prod
variable "environment_name" {
  description = "The environment name/tag for resources"
  type        = string
  default     = "dev" # Default to 'dev' environment
}

# Common fallback Lambda Handler, to use for all Lambda Resource creation declarations
variable "default_lambda_handler" {
  description = "Fallback Lambda function handler (entry point), when not explicitly supplied when creating a Lambda Resource. Default is 'lambda.handler'"
  type        = string
  default     = "lambda.handler"
}

## 'READ BUDGET' Lambda Function: reads 'State' file from 'Budget Storage' S3 Bucket
variable "read_budget_state_lambda_function_name" {
  description = "Name of the Lambda function for reading budget state. If not supplied, then the resource is not created."
  type        = string
  default     = "" # Explicit value passed required to create this Resourcce
}

variable "read_budget_state_lambda_handler" {
  description = "Lambda Handler (ie lambda.function) for the read budget state Lambda function to override default 'lambda.handler'"
  type        = string
  default     = "" # Leave empty to use the default handler or pass value to override
}
