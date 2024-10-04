resource "aws_s3_bucket_notification" "s3_notification" {
  bucket = module.s3_aws_s3_bucket.s3_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_function.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "gdpf/end_file/"
    filter_suffix       = ".end"
    id                  = "aws-and-infra-${var.env}-s3-notification"
  }
}
