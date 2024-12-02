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


### 'BUDGET STATE' S3 Bucket ###
## 2 Resources: S3 Bucket and Versioning
budget_state_bucket_name = "budget-state-bucket-test"

## 'READ BUDGET' Lambda Function: reads 'State' file from 'Budget Storage' S3 Bucket
# read_budget_state_lambda_function_name = "read_budget_state_test"
# read_budget_state_lambda_handler       = "read_budget_state.lambda_handler" # Set to match your Lambda Function entry point

## IAM Role for 'Read Budget State' Lambda
## 3 Resources: IAM Role, IAM Policy and Role Policy Attachment

# if not provided, 'plan' will work, but 'apply' will break, since Lambda requires Role ARN on creation time
read_budget_role_name = "NSTReadBudgetStateLambdaExecutionRole"
