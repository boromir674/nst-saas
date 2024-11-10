# modules/lambda/outputs.tf

output "lambda_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.generate_presigned_url.arn
}

output "lambda_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.generate_presigned_url.function_name
}
