
# ==================== S3-Buckets ====================
# resource "aws_s3_bucket" "build_artifacts_bucket" {
#   bucket = "appexample-dev-build-artifacts-us-east-1"
# }

# resource "aws_s3_bucket_versioning" "build_artifacts_bucket_versioning" {
#   bucket = aws_s3_bucket.build_artifacts_bucket.id
#   versioning_configuration {
#     status = "Disabled"
#   }
# }

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "appexample-dev-codepipeline-bucket-us-east-1"
}

resource "aws_s3_bucket_versioning" "codepipeline_bucket_versioning" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}
