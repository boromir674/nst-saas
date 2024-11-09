# modules/s3_bucket/variables.tf

# Name of the S3 bucket
variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

# Enable or disable public read access
variable "enable_public_read" {
  description = "Set to true to enable public read access to the bucket"
  type        = bool
  default     = false  # Default to private access
}

# Enable or disable versioning
variable "enable_versioning" {
  description = "Set to true to enable versioning for the bucket"
  type        = bool
  default     = false
}

# Tags to apply to the bucket
variable "tags" {
  description = "A map of tags to apply to the bucket"
  type        = map(string)
  default     = {}
}
