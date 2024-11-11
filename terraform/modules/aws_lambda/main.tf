# modules/lambda/main.tf

# Calculate the hash of the zip file to trigger updates only when file changes
locals {
  lambda_zip_hash = filebase64sha256(var.lambda_package_path)
}

resource "aws_lambda_function" "generate_presigned_url" {
  function_name = var.function_name
  handler       = var.handler
  runtime       = var.runtime
  role          = var.role_arn

  # ZIP Lambda Package file path and hash
  filename      = var.lambda_package_path  # Path to the Lambda code ZIP file
  source_code_hash = local.lambda_zip_hash  # Hash to track changes

  # Environment variables for bucket name and URL expiration
  environment {
    variables = merge(
      var.environment_vars,
      {
        BUCKET_NAME    = var.bucket_name
        URL_EXPIRATION = var.url_expiration
      }
    )
  }

  # Optional: Increase timeout if necessary
  timeout = var.timeout

  # Tags for organizational metadata
  tags = var.tags
}
