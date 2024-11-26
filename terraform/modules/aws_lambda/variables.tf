# modules/lambda/variables.tf

# REQUIRED INPUT VARIABLES
variable "function_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "lambda_package_path" {
  description = "Path to the Lambda deployment package (ZIP file)"
  type        = string
}

variable "role_arn" {
  description = "IAM role ARN that Lambda assumes"
  type        = string
}

# OPTIONAL INPUT VARIABLES
variable "handler" {
  description = "Lambda handler (entry point)"
  type        = string
  default     = "function.handler"  # Function entry point in Python file
}

variable "runtime" {
  description = "Runtime environment for the Lambda function"
  type        = string
  default     = "python3.11"
}

variable "timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 10  # Adjust as needed
}

variable "environment_vars" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags for the Lambda function"
  type        = map(string)
  default     = {}
}
