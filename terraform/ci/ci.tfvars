### CI Infrastructure

# PLAN: terraform plan --var-file ci.tfvars -out tfplan-ci
# APPLY: terraform apply tfplan-ci
# DESTROY: terraform destroy --var-file ci.tfvars

# IAM Role required for CI to run Terraform!
github_actions_role_name = "NSTSaaSGithubActionsFederatedRole"
