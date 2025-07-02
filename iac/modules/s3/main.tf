resource "aws_s3_bucket" "s3" {
  bucket = local.bucket_name
  force_destroy = true

  tags = merge(var.common_tags, {
    Name = local.bucket_name
  })
}
