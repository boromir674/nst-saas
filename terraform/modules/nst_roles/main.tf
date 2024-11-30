# Create NST IAM Roles, Policies and attachments, conditioned on input variables


### ROLE for allowing 'URL Provider' Lambda to request Pre-signed URLs from 'NST Storage' S3 ###
# Creates 3 Resources, if provide_presigned_url_role_name is given: 'IAM Role', 'IAM Policy' and 'Role Policy Attachment'
# 'Trust Policy' as IAM Role assumable by Lambda services
module "provide_presigned_url_role" {
  source = "../../modules/iam_role"
  count = var.provide_presigned_url_role_name != "" ? 1 : 0
  role_name = var.provide_presigned_url_role_name
  description = var.provide_presigned_url_role_description
  trust_policies = [
    {
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
      # TODO: support Condition! ie to limit which Lambdas can assume this Role
    }
  ]
}
# 'Permission Policy' as IAM Policy allowing GET on specified S3
module "allow_get_nst_storage_s3_policy" {
  source = "../../modules/iam_policy"
  count = var.provide_presigned_url_role_name != "" ? 1 : 0
  policy_name = "NSTStorageAccessPolicy"
  policy_description = var.allow_get_nst_storage_s3_policy_description
  policy_statements = [
    {
        Effect   = "Allow",
        Action   = [
            "s3:GetObject"
        ],
        Resource = "arn:aws:s3:::${var.nst_storage_bucket_name}/*"
    }
  ]
}
resource "aws_iam_role_policy_attachment" "lambda_budget_s3_read_policy_attachment" {
  count      = var.provide_presigned_url_role_name != "" ? 1 : 0 
  role       = module.provide_presigned_url_role[0].role_name
  policy_arn = module.allow_get_nst_storage_s3_policy[0].policy_arn
}



### ROLE for allowing 'Read Budget' Lambda to read from 'State' S3 ###
# Creates 3 Resources, if read_budget_role_name is given: 'IAM Role', 'IAM Policy' and 'Role Policy Attachment'
# 'Trust Policy' as IAM Role assumable by Lambda services
module "read_budget_role" {
  source = "../../modules/iam_role"
  count = var.read_budget_role_name != "" ? 1 : 0
  role_name = var.read_budget_role_name
  description = var.read_budget_role_description
  trust_policies = [
    {
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
      # TODO: support Condition! ie to limit which Lambdas can assume this Role
    }
  ]
}
# 'Permission Policy' as IAM Policy allowing GET on specified S3
module "allow_read_budget_s3_policy" {
  source = "../../modules/iam_policy"
  count = var.read_budget_role_name != "" ? 1 : 0
  policy_name = "NSTBudgetStateAccessPolicy"
  policy_description = var.allow_read_budget_s3_policy_description
  policy_statements = [
    {
        Effect   = "Allow",
        Action   = [
            "s3:GetObject"
        ],
        Resource = "arn:aws:s3:::${var.budget_state_bucket_name}/*"
    }
  ]
}
resource "aws_iam_role_policy_attachment" "read_budget_lambda_state_s3_read_policy_attachment" {
  count      = var.read_budget_role_name != "" ? 1 : 0    
  role       = module.read_budget_role[0].role_name
  policy_arn = module.allow_read_budget_s3_policy[0].policy_arn
}


### SNIPPETS
# TODO reduce scope to input Lambda instead of any lambda service
        # Condition = {
        #   "StringEquals": {
        #     "aws:RequestTag/lambda:name": "your-lambda-function-name"
        #   }
        # }
