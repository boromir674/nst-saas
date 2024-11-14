# modules/s3_bucket/outputs.tf

# Output the bucket name
output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = length(aws_s3_bucket.bucket) > 0 ? aws_s3_bucket.bucket[0].bucket : ""
}

# Output the bucket ARN
output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = length(aws_s3_bucket.bucket) > 0 ? aws_s3_bucket.bucket[0].arn : ""
}

# Output the bucket URL for accessing objects
output "bucket_url" {
  description = "The URL for accessing the S3 bucket"
  value       = length(aws_s3_bucket.bucket) > 0 ? "https://${aws_s3_bucket.bucket[0].bucket}.s3.amazonaws.com" : ""
}
