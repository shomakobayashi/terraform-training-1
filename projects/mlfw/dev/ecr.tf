resource "aws_ecr_repository" "mlfw_redhat" {
  name                 = "aws-and-infra-${var.env}-ecr-mlfw-redhat"
  image_tag_mutability = "MUTABLE"
  encryption_configuration {
    encryption_type    = "KMS"
    kms_key           = data.aws_kms_key.common_account.arn
  }
  image_scanning_configuration {
    scan_on_push = false
  }
}
