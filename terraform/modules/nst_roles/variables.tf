#### 'URL Provider' Roles INPUTs ####
# - provide_presigned_url_role_name
#   if 'provide_presigned_url_role_name' is left empty then the Role creation is skipped
# - nst_storage_bucket_name
#   if 'provide_presigned_url_role_name' is provided then nst_storage_bucket_name MUST be provided too

variable "provide_presigned_url_role_name" {
    description = "IAM Role Resource Name assumable by the 'URL Provider' Lambda function"
    default = ""  # if empty string "" then the Role creation is skipped
}
variable "nst_storage_bucket_name" {
    # if 'provide_presigned_url_role_name' is NOT empty then this default "" will cause an error, so it MUST be provided
    description = "Name of the 'NST Storage' S3 Bucket, which stores Content and Style images"
    default = ""  # if empty string then provide_presigned_url_role_name MUST be empty too
}

# Inputs with sensible Defaults
variable "provide_presigned_url_role_description" {
    description = "Resource Description of the IAM Role assumable by the 'URL Provider' Lambda function"
    default = "Assumable by the 'URL Provider' Lambda function. Can Provide Presigned URLs for the 'NST Storage' S3 Bucket"
}

variable "allow_get_nst_storage_s3_policy_description" {
    description = "Resource Description of the IAM (Permission) Policy that allows Get access to the 'NST Storage' S3 Bucket"
    default = "Permision Policy that Allows Get access to the 'NST Storage' S3 Bucket"
}

#### 'Read Budget' Roles INPUTs ####
# - read_budget_role_name
#   if 'read_budget_role_name' is left empty then the Role creation is skipped
# - budget_state_bucket_name
#   if 'read_budget_role_name' is provided then budget_state_bucket_name MUST be provided too


variable "read_budget_role_name" {
    description = "IAM Role Resource Name assumable by the 'Read Budget' Lambda function"
    default = ""  # if empty string "" then the Role creation is skipped
}
variable "budget_state_bucket_name" {
    # if 'read_budget_role_name' is NOT empty then this default "" will cause an error, so it MUST be provided
    description = "Name of the S3 Bucket that stores the 'Budget' State"
    default = ""  # if empty string then read_budget_role_name MUST be empty too
}

# Inputs with sensible Defaults
variable "read_budget_role_description" {
    description = "Resource Description of the IAM Role assumable by the 'Read Budget' Lambda function"
    default = "Assumable by the 'Read Budget' Lambda function. Can Read the 'Budget' State S3 Bucket"
}

variable "allow_read_budget_s3_policy_description" {
    description = "Resource Description of the IAM (Permission) Policy that allows Read access to the 'Budget' State S3 Bucket"
    default = "Permision Policy that Allows Read access to the 'Budget State' S3 Bucket"
}
