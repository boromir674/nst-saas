# terraform/main.tf


### Create 'NST Storage' the S3 bucket to store NST images ###
# 2 Resources of type 'S3 Bucket' and 'Bucket Versioning'
module "s3_bucket" {
  source             = "./modules/s3_bucket" # Path to the reusable S3 bucket module
  bucket_name        = var.storage_bucket_name       # Bucket name passed in as a variable
  tags = {                                   # Tags to apply to the bucket
    Environment = var.environment_name,
    IaaC        = "Terraform",
    App         = "NST"
  }
}

### Create 'Budget State' S3 bucket to store budget state ###
module "budget_state_bucket" {
  source             = "./modules/s3_bucket"
  bucket_name        = var.budget_state_bucket_name
  tags = {
    Environment = var.environment_name,
    IaaC        = "Terraform",
    App         = "NST"
  }
}
# Does state transition on apply but fails on destroy (bucket not empty to delete !)
# resource "null_resource" "budget_state_init" {
#   provisioner "local-exec" {
#     command = "echo '{\"budget\": 1800}' > /tmp/budget_state.json && aws s3 cp /tmp/budget_state.json s3://${module.budget_state_bucket.bucket_name}/"
#   }

#   depends_on = [module.budget_state_bucket]
# }


### Create 2 Lambda Roles for 'NST Storage' and 'Budget State' access ###
# - x2 'IAM Role', 'IAM Policy' and 'Role Policy Attachment' Resources
module "iam" {
  source = "./modules/iam"
  # Provide Bucket Names for IAM Role Policies
  bucket_name              = module.s3_bucket.bucket_name
  budget_state_bucket_name = module.budget_state_bucket.bucket_name
}

### Create 'URL Provider' Lambda with above Role to generate pre-signed URLs ###
# 1 Resource of type 'Lambda Function'
module "presigned_url_lambda" {
  source           = "./modules/aws_lambda"
  function_name    = var.presigned_url_lambda_function_name
  handler          = var.presigned_url_lambda_handler != "" ? var.presigned_url_lambda_handler : var.default_lambda_handler
  # Specify Role by arn using Output of above 'Role'
  role_arn         = module.iam.lambda_execution_role_arn
  timeout          = 10
  lambda_package_path = var.presigned_url_lambda_package_path

  environment_vars = merge(
    var.environment_vars,
    {
      BUCKET_NAME    = var.storage_bucket_name
      URL_EXPIRATION = var.presigned_url_url_expiration
    }
  )
  tags = {
    Environment = var.environment_name,
    IaaC        = "Terraform",
    App         = "NST"
  }
}

### Create 'Read Budget State' Lambda with new 'iam' Role
module "budget_check_lambda" {
  source        = "./modules/aws_lambda"
  function_name = var.read_budget_state_lambda_function_name
  # if no value provided for handler use default fallback
  handler = var.read_budget_state_lambda_handler != "" ? var.read_budget_state_lambda_handler : var.default_lambda_handler
  role_arn      = module.iam.budget_check_lambda_role_arn
  timeout       = 10
  # automatically hashes the ZIP file to trigger state updates
  lambda_package_path = "../lambda_functions/read_budget_state/read_budget_state.zip"
  environment_vars = merge(
    var.environment_vars,
    {
      STATE_BUCKET_NAME = module.budget_state_bucket.bucket_name
      STATE_OBJECT_KEY  = "budget_state.json"
    }
  )
  tags = {
    Environment = var.environment_name,
    IaaC        = "Terraform",
    App         = "NST"
  }
}


# Create API Gateway by calling a module
# This API Gateway integrates with the Lambda function for budget checking.
# module "api_gateway" {
#   source      = "./modules/api_gateway"                # Path to API Gateway module
#   api_name    = var.api_name                           # API name per environment
#   lambda_arns = [module.budget_check_lambda.lambda_arn]  # Links the budget check Lambda
# }

# ### Create an AWS API Gateway to expose the URL generation Lambda ###
# # Resource: API Gateway to expose the URL generation Lambda
# resource "aws_api_gateway_rest_api" "url_provider_api" {
#   name        = "URLProviderAPI"
#   description = "API to generate pre-signed URLs for S3 uploads"
# }

# # Define an HTTP endpoint (aka resource path, url path) in the API Gateway
# resource "aws_api_gateway_resource" "url_resource" {
#   rest_api_id = aws_api_gateway_rest_api.url_provider_api.id
#   parent_id   = aws_api_gateway_rest_api.url_provider_api.root_resource_id
#   path_part   = "get-presigned-url"
# }

# # Enable the GET method for above Endpoint
# resource "aws_api_gateway_method" "get_presigned_url" {
#   rest_api_id   = aws_api_gateway_rest_api.url_provider_api.id
#   resource_id   = aws_api_gateway_resource.url_resource.id
#   http_method   = "GET"
#   authorization = "NONE"  # No auth for quick testing; replace with proper auth later
# }

# # Integrate API Gateway with the Lambda function
# resource "aws_api_gateway_integration" "lambda_integration" {
#   rest_api_id             = aws_api_gateway_rest_api.url_provider_api.id
#   resource_id             = aws_api_gateway_resource.url_resource.id
#   http_method             = aws_api_gateway_method.get_presigned_url.http_method
#   integration_http_method = "POST"
#   type                    = "AWS_PROXY"
#   uri                     = module.presigned_url_lambda.lambda_invoke_arn
# }

# # Grant API Gateway permission to invoke the URL Provider Lambda
# resource "aws_lambda_permission" "api_gateway_invoke" {
#   statement_id  = "AllowAPIGatewayInvoke"
#   action        = "lambda:InvokeFunction"
#   function_name = module.presigned_url_lambda.lambda_name
#   principal     = "apigateway.amazonaws.com"
#   source_arn    = "${aws_api_gateway_rest_api.url_provider_api.execution_arn}/*/*"
# }

# # Deploy the API
# resource "aws_api_gateway_deployment" "api_deployment" {
#   depends_on   = [aws_api_gateway_integration.lambda_integration]
#   rest_api_id  = aws_api_gateway_rest_api.url_provider_api.id
#   # nest all resources/endpoints under /test path
#   stage_name   = "test"
# }



##### 

# # Define a POST method for API Gateway
# resource "aws_api_gateway_method" "post_presigned_url" {
#   rest_api_id   = aws_api_gateway_rest_api.url_provider_api.id
#   resource_id   = aws_api_gateway_resource.url_resource.id
#   http_method   = "POST"                     # Change to POST
#   authorization = "NONE"                      # No auth for quick testing

#   # Specify that the request will have a JSON payload
#   request_parameters = {
#     "method.request.header.Content-Type" = true
#   }
# }

# # Integrate API Gateway with Lambda function for POST method
# resource "aws_api_gateway_integration" "lambda_integration" {
#   rest_api_id             = aws_api_gateway_rest_api.url_provider_api.id
#   resource_id             = aws_api_gateway_resource.url_resource.id
#   http_method             = aws_api_gateway_method.post_presigned_url.http_method
#   integration_http_method = "POST"             # POST to match Lambda’s POST handler
#   type                    = "AWS_PROXY"        # AWS_PROXY to handle Lambda responses directly
#   uri                     = aws_lambda_function.presigned_url_lambda.invoke_arn

#   request_templates = {
#     "application/json" = <<EOF
#       #if($input.json('$') != '')
#         $input.json('$')
#       #else
#         {}
#       #end
#     EOF
#   }
# }