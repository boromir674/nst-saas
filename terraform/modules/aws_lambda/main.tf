# modules/lambda/main.tf

# Calculate the hash of the zip file to trigger updates only when file changes
locals {
  lambda_zip_hash = var.function_name != "" ? filebase64sha256(var.lambda_package_path) : ""
}

# Create a Lambda if Function name is provided
resource "aws_lambda_function" "generic_function" {
  count         = var.function_name != "" ? 1 : 0  # Only create if name is provided

  function_name = var.function_name
  handler       = var.handler
  runtime       = var.runtime
  role          = var.role_arn

  # ZIP Lambda Package file path and hash
  filename      = var.lambda_package_path  # Path to the Lambda code ZIP file
  source_code_hash = local.lambda_zip_hash  # Hash to track changes

  environment {
    variables = var.environment_vars
  }

  # Optional: Increase timeout if necessary
  timeout = var.timeout

  # Tags for organizational metadata
  tags = var.tags
}
