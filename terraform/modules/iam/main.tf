# terraform/modules/iam/main.tf

# IAM Role for Lambda Execution
resource "aws_iam_role" "lambda_execution_role" {
  name = "LambdaExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
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
  name        = "LambdaS3Access"
  description = "Policy granting Lambda function access to S3"
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

# Attach the S3 access policy to the Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_s3_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_s3_access.arn
}
