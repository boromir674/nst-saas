### Test Infrastructure Deployment on AWS
### Environment: Test 'Budget Lambda Integration'


# PLAN: terraform plan --var-file env_test_budget_lambda.tfvars -out tfplan-test
# APPLY: terraform plan tfplan-test
# DESTROY: terraform destroy --var-file env_test_budget_lambda.tfvars


### Shared Variables ###

## AWS region for the entire infrastructure of dev environment
aws_region = "eu-central-1"

# Environment tag to apply to resources
environment_name = "test"

# Environment variables for all Lambda Functions
environment_vars = {
  ENV = "test"
}

###### MAIN ######


## 'BUDGET STATE' S3 Bucket
budget_state_bucket_name = "budget-state-bucket-test"

## 'READ BUDGET' Lambda Function: reads 'State' file from 'Budget Storage' S3 Bucket
read_budget_state_lambda_function_name = "read_budget_state_test"
read_budget_state_lambda_handler       = "budget_check.handler" # Set to match your Lambda Function entry point
