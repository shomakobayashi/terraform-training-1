data "aws_caller_identity" "self" {} 

data "aws_kms_key" "common_account" {
  key_id = "alias/aws-and-infra-${var.env}-common"
}

data "aws_iam_role" "admin_role" {
  name = "AdminRole"
}
