# terraform/modules/iam/main.tf

# IAM Role that can only be assumed by Lambda services
resource "aws_iam_role" "lambda_execution_role" {
  name = "NSTStorageURLProviderLambdaIAMRole"
  # Declare Trust Policy: what services can assume this Role
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    # Allow Role to be assumed by any Lambda
    Statement = [
      {
        Effect = "Allow",
        Principal = { Service = "lambda.amazonaws.com" },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy for S3 Access by Lambda
resource "aws_iam_policy" "lambda_s3_access" {
  name        = "NSTS3StorageAccessPolicy"
  description = "Policy granting Lambda function access to S3"
  # Declare Permissions Policy: what actions are allowed on what resources
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:PutObject",
          "s3:GetObject"
        ],
        Resource = "arn:aws:s3:::${var.bucket_name}/*"
        # Resource = "arn:aws:s3:::YOUR_BUCKET_NAME/*"  # Replace with your S3 bucket name
      }
    ]
  })
}

# Lambda Role with S3 PutObject/GetObject Access Permissions
resource "aws_iam_role_policy_attachment" "lambda_s3_policy_attachment" {
    # Attach the S3 access policy to the Lambda execution role
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_s3_access.arn
}


### Read Budget Lambda - Resources ###
resource "aws_iam_role" "read_budget_lambda_execution_role" {
  name = "NSTBudgetReaderLambdaLambdaIAMRole"
  # Declare Trust Policy: what services can assume this Role
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    # Allow Role to be assumed by any Lambda
    Statement = [
      {
        Effect = "Allow",
        Principal = { Service = "lambda.amazonaws.com" },
        Action = "sts:AssumeRole"
        # Condition = {
        #   "StringEquals": {
        #     "aws:RequestTag/lambda:name": "your-lambda-function-name"
        #   }
        # }
      }
    ]
  })
}

## PERMISSION POLICY: what actions are allowed on what resources
# IAM Policy for Read Access to input S3 Bucket
resource "aws_iam_policy" "lambda_s3_read_access" {
  name        = "NSTBudgetStateAccessPolicy"
  description = "Policy granting Lambda function access to S3"
  # Declare Permissions Policy: what actions are allowed on what resources
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:GetObject"
        ],
        Resource = "arn:aws:s3:::${var.budget_state_bucket_name}/*"
      }
    ]
  })
}

# Lambda Role with S3 GetObject Access Permissions
resource "aws_iam_role_policy_attachment" "lambda_budget_s3_read_policy_attachment" {
  # Attach the DynamoDB access policy to the Lambda execution role
  role       = aws_iam_role.read_budget_lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_s3_read_access.arn
}
