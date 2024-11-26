# modules/s3_bucket/main.tf

# Creates an S3 Bucket with optional Bucket Policy and Versioning


# Create S3 Bucket
# INPUTS:
# - bucket_name: string
# - tags: map(string)
resource "aws_s3_bucket" "bucket" {
  count = var.bucket_name != "" ? 1 : 0  # Only create if Bucket name is provided
  bucket = var.bucket_name           # Bucket name passed from the root module
  # aws_s3_bucket_acl = "private"       # Default ACL; can adjust if needed
  tags = var.tags                    # Tags passed as a variable to allow customization

  # Optional Bucket Policy
  # Optional: Server-side encryption for security
}

# Configure versioning for the S3 bucket
resource "aws_s3_bucket_versioning" "bucket_versioning" {
  count = var.bucket_name != "" ? 1 : 0  # Only create if Bucket name is provided
  # Define the S3 bucket versioning resource
  bucket = aws_s3_bucket.bucket[0].id
  versioning_configuration {
    # dynamic from input
    # status = var.enable_versioning ? "Enabled" : "Suspended"
    status = "Disabled"  # Enabled / Suspended / Disabled
  }
}


# Optional: S3 bucket policy for public read access
# resource "aws_s3_bucket_policy" "public_read_policy" {
#   count = var.bucket_name != "" ? 1 : 0  # Only create if Bucket name is provided
#   bucket = aws_s3_bucket.bucket[0].id
#   count  = var.enable_public_read ? 1 : 0  # Creates policy only if public read is enabled

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Principal = "*",
#         Action = "s3:GetObject",
#         Resource = "${aws_s3_bucket.bucket[0].arn}/*"
#       }
#     ]
#   })
# }



## Example of Bucket Policy and server-side encryption configuration

# resource "aws_s3_bucket" "bucket" {
#   count = var.nst_storage_bucket_name != "" ? 1 : 0  # Only create if Bucket name is provided
#   bucket = var.nst_storage_bucket_name           # Bucket name passed from the root module
  # aws_s3_bucket_acl = "private"       # Default ACL; can adjust if needed
  # tags = var.tags                    # Tags passed as a variable to allow customization

  # Bucket Policy
  # policy = jsonencode({
  #   Version = "2012-10-17",
  #   Statement = [
  #     {
  #       Effect    = "Allow",
  #       Principal = "*",
  #       Action    = "s3:GetObject",
  #       Resource  = "arn:aws:s3:::${var.nst_storage_bucket_name}/*"
  #     }
  #   ]
  # })

  # Optional: Server-side encryption for security
  # aws_s3_bucket_server_side_encryption_configuration {
  #   rule {
  #     apply_server_side_encryption_by_default {
  #       sse_algorithm = "AES256"     # Use AES256 encryption by default
  #     }
  #   }
  # }

# }