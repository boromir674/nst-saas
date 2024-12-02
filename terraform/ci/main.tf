## Service Account with Federated ID (Provider Github) ##

# PLAN: terraform plan --var-file ci.tfvars -out tfplan-ci
# APPLY: terraform apply tfplan-ci
# DESTROY: terraform destroy --var-file ci.tfvars

# TODO: Debug using step in https://chatgpt.com/g/g-2DQzU5UZl-code-copilot/c/672dee51-932c-8009-8de9-65f7f6a9f557

### ROLE for allowing 'Github Actions' CI access to AWS Resources ###
variable "github_actions_role_name" { # Trust Policy Role
  description = "IAM Role Resource Name assumable by Github Provider IDs"
  default     = "" # if empty string "" then the Role creation is skipped
}
variable "github_actions_role_description" { # Trust Policy Role
  description = "Resource Description of the IAM Role assumable by Github Provider IDs"
  default     = "Assumable by Github Provider IDs. Allows Github Actions CI to access AWS Resources"
}
variable "allow_github_actions_policy_description" { # Permission Policy
  description = "Resource Description of the IAM (Permission) Policy that allows Github Actions CI to access AWS Resources"
  default     = "Permision Policy that Allows Github Actions CI to access AWS Resources"
}


# 'Permission Policy' as IAM Policy allowing
#   - Creating/Destroying S3 Buckets
#   - Creating/Destroying Lambda Functions
#   - Creating/Destroying IAM Roles
module "allow_github_actions_policy" {
  source = "../modules/iam_policy"
  count  = var.github_actions_role_name != "" ? 1 : 0

  policy_name        = "GithubActionsNSTSaaSAccessPolicy"
  policy_description = var.allow_github_actions_policy_description
  policy_statements = [
    {
      Effect = "Allow",
      Action = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:PutBucketAcl",       # Required to set ACLs
      "s3:PutBucketPolicy",    # Required for bucket policies
      "s3:HeadBucket",         # Required to check bucket existence
      "s3:GetBucketLocation"   # Required to verify bucket location
      ],
      Resource = "arn:aws:s3:::*"  # Allows actions on all buckets
    },
    {
      Effect = "Allow",
      Action = [
        "lambda:CreateFunction",
        "lambda:DeleteFunction",
        # Required Permissions: tf resource 'aws_iam_role'
        "iam:GetRole",
        "iam:ListRolePolicies",
        "iam:ListAttachedRolePolicies",
        "iam:CreateRole",
        "iam:DeleteRole",
      ],
      Resource = "*"
    },
  {
    Effect = "Allow",
    Action = [
      "s3:ListAllMyBuckets"    # Lists all buckets for Terraform validation
    ],
    Resource = "*"
  }
  ]
}


### ROLE for allowing 'Github Actions' CI access to AWS Resources ###

# This role assumes IAM already trusts Github Actions (a Github ID Provider is already setup in AWS as Web Identity Provider object)
# Creates 2 Resources, if github_actions_role_name is given: 'IAM Role', and 'Role Policy Attachment'
module "iam_github_oidc_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-role"
  create = var.github_actions_role_name != "" ? true : false

  name        = var.github_actions_role_name
  description = var.github_actions_role_description

  # Participates in 'Trust Policy' Condition: "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
  audience = "sts.amazonaws.com"

  # Creates Federated Principal for Github Actions 'Trust Policy'
  # Principal = {                            # Github Actions ID Provider already setup to be trusted
  #   Federated = "arn:aws:iam::383351349304:oidc-provider/token.actions.githubusercontent.com"
  # },
  provider_url = "token.actions.githubusercontent.com"

  # subject_condition = 'StringLike'

  # Governs which git events we trust: branch pushes, pr branches, tags, repo's, etc
  # StringLike = {
  #   "token.actions.githubusercontent.com:sub" = [
  #     "repo:boromir674/nst-saas:ref:refs/heads/*",  # All branches
  #     "repo:boromir674/nst-saas:ref:refs/heads/*",  # Specific repository and branches
  #     # "repo:boromir674/*:ref:refs/heads/*"          # Optional: All repositories in the org
  #   ]
  # }
  subjects = [  # repo: is automatically prepended
    "boromir674/nst-saas:ref:refs/heads/*",  # All branches
    # "terraform-aws-modules/terraform-aws-iam:*"
  ]

  # Automatically create attavhments per IAM Policy, aka 'Permission Policy'
  policies = {
    AuthorizeGithubActions = module.allow_github_actions_policy[0].policy_arn
    # S3ReadOnly = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  }

  tags = {
    Environment = "ci"
  }
}

# module "github_actions_role" {
#   source = "../modules/iam_role"
#   count  = var.github_actions_role_name != "" ? 1 : 0

#   role_name   = var.github_actions_role_name
#   description = var.github_actions_role_description
#   trust_policies = [
#     {
#       Effect = "Allow"
#       Action = "sts:AssumeRoleWithWebIdentity" # accept ID from web Provider (JWT with claims)
#       Principal = {                            # Github Actions ID Provider already setup to be trusted
#         Federated = "arn:aws:iam::383351349304:oidc-provider/token.actions.githubusercontent.com"
#       },
#       Condition = {
#         StringEquals = {
#           "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
#         },
#         # ACCEPT ANY BRANCH PUSH (no PR branch)
#         StringLike = {
#           "token.actions.githubusercontent.com:sub" = [
#             "repo:boromir674/nst-saas:ref:refs/heads/*",  # All branches
#             "repo:boromir674/nst-saas:ref:refs/heads/*",  # Specific repository and branches
#             # "repo:boromir674/*:ref:refs/heads/*"          # Optional: All repositories in the org
#           ]
#         }
#       }
#     }
#   ]
# }

# resource "aws_iam_role_policy_attachment" "github_actions_policy_attachment" {
#   count      = var.github_actions_role_name != "" ? 1 : 0
#   role       = module.github_actions_role[0].role_name
#   policy_arn = module.allow_github_actions_policy[0].policy_arn
# }


### OUTPUTS ###
output "github_actions_role_arn" {
  description = "ARN of the IAM Role, required to let other resources (ie Lambda) assume this (Trust Policy) Role"
  # value       = length(module.github_actions_role) > 0 ? module.github_actions_role[0].role_arn : ""
  value       =  module.iam_github_oidc_role.arn
}
