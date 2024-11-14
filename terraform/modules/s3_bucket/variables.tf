# modules/s3_bucket/variables.tf

## 'NST Stoage' S3 Bucket
variable "bucket_name" {
  description = "Name of the 'NST Storage' BucketThe name of the S3 bucket"
  type        = string
}

# Tags to apply to the bucket
variable "tags" {
  description = "A map of tags to apply to the bucket"
  type        = map(string)
  default     = {}
}


## TODO create a factory pattern module that can take care of creating all S3 Buckets (or on-demand subsets) the System requires
# that module will use this one.
