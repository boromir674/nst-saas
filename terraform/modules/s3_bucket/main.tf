# modules/s3_bucket/main.tf

# Create S3 Bucket
# INPUTS:
# - bucket_name: string
# - tags: map(string)
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name           # Bucket name passed from the root module
  # acl is deprecated in favor of aws_s3_bucket_acl
  # acl    = "private"                 # Default ACL; can adjust if needed
  # aws_s3_bucket_acl = "private"       # Default ACL; can adjust if needed

  # Bucket Policy
  # policy = jsonencode({
  #   Version = "2012-10-17",
  #   Statement = [
  #     {
  #       Effect    = "Allow",
  #       Principal = "*",
  #       Action    = "s3:GetObject",
  #       Resource  = "arn:aws:s3:::${var.bucket_name}/*"
  #     }
  #   ]
  # })

  # Optional: Enable versioning for object backups
  # versioning {
  #   enabled = var.enable_versioning
  # }

  # Optional: Server-side encryption for security
  # aws_s3_bucket_server_side_encryption_configuration {
  #   rule {
  #     apply_server_side_encryption_by_default {
  #       sse_algorithm = "AES256"     # Use AES256 encryption by default
  #     }
  #   }
  # }

  tags = var.tags                    # Tags passed as a variable to allow customization
}

# Configure versioning for the S3 bucket
resource "aws_s3_bucket_versioning" "bucket_versioning" {
  # Define the S3 bucket versioning resource
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    # dynamic from input
    # status = var.enable_versioning ? "Enabled" : "Suspended"
    status = "Disabled"  # Enabled / Suspended / Disabled
  }
}


# Optional: S3 bucket policy for public read access
# resource "aws_s3_bucket_policy" "public_read_policy" {
#   bucket = aws_s3_bucket.bucket.id
#   count  = var.enable_public_read ? 1 : 0  # Creates policy only if public read is enabled

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Principal = "*",
#         Action = "s3:GetObject",
#         Resource = "${aws_s3_bucket.bucket.arn}/*"
#       }
#     ]
#   })
# }
