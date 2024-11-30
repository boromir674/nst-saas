## Service Account with Federated ID (Provider Github) ##

### ROLE for allowing 'Github Actions' CI access to AWS Resources ###
variable "github_actions_role_name" {  # Trust Policy Role
    description = "IAM Role Resource Name assumable by Github Provider IDs"
    default = ""  # if empty string "" then the Role creation is skipped
}
variable "github_actions_role_description" {  # Trust Policy Role
    description = "Resource Description of the IAM Role assumable by Github Provider IDs"
    default = "Assumable by Github Provider IDs. Allows Github Actions CI to access AWS Resources"
}
variable "allow_github_actions_policy_description" {  # Permission Policy
    description = "Resource Description of the IAM (Permission) Policy that allows Github Actions CI to access AWS Resources"
    default = "Permision Policy that Allows Github Actions CI to access AWS Resources"
}


### ROLE for allowing 'Github Actions' CI access to AWS Resources ###
# This role assumes IAM already trusts Github Actions (a Github ID Provider is already setup in AWS as Web Identity Provider object)
# Creates 3 Resources, if github_actions_role_name is given: 'IAM Role', 'IAM Policy' and 'Role Policy Attachment'
module "github_actions_role" {
  source = "../modules/iam_role"
  count = var.github_actions_role_name != "" ? 1 : 0

  role_name = var.github_actions_role_name
  description = var.github_actions_role_description
  trust_policies = [
    {
      Effect = "Allow"
      Action = "sts:AssumeRoleWithWebIdentity"  # accept ID from web Provider (JWT with claims)
      Principal = {  # Github Actions ID Provider already setup to be trusted
        "Federated": "arn:aws:iam::383351349304:oidc-provider/token.actions.githubusercontent.com"
      },
    }
  ]
}
# 'Permission Policy' as IAM Policy allowing
#   - Creating/Destroying S3 Buckets
#   - Creating/Destroying Lambda Functions
#   - Creating/Destroying IAM Roles
module "allow_github_actions_policy" {
  source = "../modules/iam_policy"
  count = var.github_actions_role_name != "" ? 1 : 0

  policy_name = "GithubActionsNSTSaaSAccessPolicy"
  policy_description = var.allow_github_actions_policy_description
  policy_statements = [
    {
      Effect   = "Allow",
      Action   = [
        "s3:CreateBucket",
        "s3:DeleteBucket",
        "lambda:CreateFunction",
        "lambda:DeleteFunction",
        "iam:CreateRole",
        "iam:DeleteRole",
      ],
      Resource = "*"
    }
  ]
}
resource "aws_iam_role_policy_attachment" "github_actions_policy_attachment" {
  count      = var.github_actions_role_name != "" ? 1 : 0
  role       = module.github_actions_role[0].role_name
  policy_arn = module.allow_github_actions_policy[0].policy_arn
}
