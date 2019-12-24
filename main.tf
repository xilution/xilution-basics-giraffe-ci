resource "aws_s3_bucket" "xilution_test_bucket" {
  bucket = "spenserca-code-build-test-bucket"
  force_destroy = true
}
