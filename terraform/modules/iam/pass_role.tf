# terraform/modules/iam/pass_role.tf

# IAM Policy to Allow Passing the Lambda Execution Role
resource "aws_iam_policy" "allow_pass_role_lambda_execution" {
  name        = "AllowPassRoleLambdaExecution"
  description = "Policy to allow passing the Lambda execution role"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "iam:PassRole",
        Resource = aws_iam_role.lambda_execution_role.arn
      }
    ]
  })
}

# Attach PassRole policy to the role running Terraform
resource "aws_iam_policy_attachment" "attach_pass_role_policy" {
  name       = "AllowPassRoleLambdaExecution"
  policy_arn = aws_iam_policy.allow_pass_role_lambda_execution.arn
  roles      = [var.terraform_execution_role]
}
