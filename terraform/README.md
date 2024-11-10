# Neural Style Transfer (NST) Infrastructure as Code

> Infrastructure as Code on AWS

The setup provisions
- `S3 bucket` for image storage
- a `Lambda function` for budget checking
- an API Gateway for exposing endpoints, while handling auth, throttling, etc

## Folder Structure

```plaintext
terraform/
├── main.tf                      # Core Terraform configuration that references modules
├── providers.tf                 # AWS provider configuration
├── variables.tf                 # Common variable definitions for all environments
├── outputs.tf                   # Outputs important resource information after apply
├── environments/                # Environment-specific variable files
│   ├── dev/
│   │   └── terraform.tfvars     # Dev-specific variable values
│   └── prod/
│       └── terraform.tfvars     # Prod-specific variable values
└── modules/                     # Reusable modules for resources
    ├── s3_bucket/               # Module for creating S3 buckets
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── lambda/                  # Module for creating Lambda functions
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── api_gateway/             # Module for creating API Gateway
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Prerequisites

1. **Terraform**: Install from Terraform website
2. **AWS CLI**

    ```
    aws configure
    ```

## Setup Instructions

### Step 1: Initialize Terraform
Navigate to the terraform/ directory and run terraform init to initialize the project.

```bash
cd terraform/
terraform init
```
> Now backend (aka state) should be initialized, along with `modules` and provider plugins

### Step 2: Plan Infrastructure Changes
> To preview the changes Terraform will make to your infrastructure run `terraform plan`.

Specify a preset `environment` by using the corresponding `*.tfvars` file.

For example, to plan changes for the `dev` environment and record plan:

```
terraform plan --var-file env_dev.tfvars -out tfplan-dev
```

### Step 3: Deploy/Apply Configuration
> To deploy the infrastructure run `terraform apply` with the plan compiled previously.

```
terraform apply tfplan-dev
```

Terraform **will prompt** you to confirm before making any changes.  

After **successfully provisioning** the resources **Output Values** from `outputs.tf` will be **displayed**, such as:
- S3 bucket URLs
- API Gateway URLs

#### Verify Resources

- To see all AWS S3 Buckets: `aws s3 ls`
- To see all AWS Lambda Functions: `aws lambda list-functions`

### Step 4: Destroy Infrastructure (Tear Down)
> To remove all resources deployed, run `terraform destroy`.

```sh
terraform destroy
```
