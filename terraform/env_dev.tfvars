### Development Infrastructure Deployment on AWS
### Environment: Development

# PLAN: terraform plan --var-file env_dev.tfvars --var-file -out tfplan-dev
# APPLY: terraform plan tfplan-dev
# DESTROY: terraform destroy --var-file env_dev.tfvars


### Shared Variables ###

## AWS region for the entire infrastructure of dev environment
aws_region = "eu-central-1"

# Environment tag to apply to resources
environment_name = "dev"

# Environment variables for all Lambda Functions
environment_vars = {
  ENV = "dev"
}


###### MAIN ######

## 'NST STORAGE' S3 Bucket: cloud storage for 'Content' and 'Style' images
storage_bucket_name = "nst-storage-dev"

## 'BUDGET STATE' S3 Bucket: stores the budget state
# budget_state_bucket_name = "nst-budget-state-bucket-dev"

## 'URL PROVIDER' Lambda Function: requests a Pre-signed URL for uploading to 'NST STORAGE'
presigned_url_lambda_package_path  = "../lambda_url_provider/lambda_url_provider.zip" # Path to the ZIP file
presigned_url_lambda_function_name = "generate_presigned_url_dev"
presigned_url_lambda_handler       = "generate_presigned_url.handler"                     # Set to the new handler entry point
presigned_url_url_expiration       = 3600                                                 # Expiration time for the presigned URL in seconds
presigned_url_lambda_tags = {
  Environment = "dev",
  IaaC        = "Terraform",
  App         = "NST"
}

## 'READ BUDGET' Lambda Function: reads 'State' file from 'Budget Storage' S3 Bucket
# read_budget_state_lambda_function_name = "read_budget_state_dev"
# read_budget_state_lambda_handler       = "budget_check.handler" # Set to match your Lambda entry point



## API Gateway name for the dev environment
api_name = "nst-api-dev"
