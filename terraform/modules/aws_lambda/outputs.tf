# modules/lambda/outputs.tf

output "lambda_arn" {
  description = "ARN of the Lambda function"
  value       = length(aws_lambda_function.generic_function) > 0 ? aws_lambda_function.generic_function[0].arn : ""

}

output "lambda_name" {
  description = "Name of the Lambda function"
  value       = length(aws_lambda_function.generic_function) > 0 ? aws_lambda_function.generic_function[0].function_name : ""
}

output "lambda_invoke_arn" {
  description = "ARN to invoke the Lambda function"
  value       = length(aws_lambda_function.generic_function) > 0 ? aws_lambda_function.generic_function[0].invoke_arn : ""
}
