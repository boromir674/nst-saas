# terraform/modules/iam/outputs.tf

## OUTPUT ARN's OF IAM ROLES created for Lambda functions ##

output "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_execution_role.arn
}

# A Role only assumable by Lambda's, only granting Read Permission to Budget
output "budget_check_lambda_role_arn" {
  description = "ARN of the Lambda execution role for budget check Lambda"
  value       = aws_iam_role.read_budget_lambda_execution_role.arn
}
