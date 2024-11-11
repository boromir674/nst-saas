# terraform/providers.tf

# Configure the AWS provider for Terraform
provider "aws" {
  region = var.aws_region # AWS region is set via a variable to keep this flexible
}
