resource "aws_kms_key" "s3-temp-load-unload-snowflake" {
  description = "KMS key for S3 temp load/unload for Snowflake"
  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "Enable IAM User Permissions",
        "Effect": "Allow",
        "Principal": {
          "aws": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action": "kms:*",
        "Resource": "*"
      },
      {
        "Sid": "Allow access for key Administrators",
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AdminRole"
        },
        "Action": [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:TagResource",
          "kms:UntagResource"
        ],
        "Resource": "*"
      },
      {
        "Sid": "Allow use of the key",
        "Effect": "Allow",
        "Principal": {
          "AWS": [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/PowerRole",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-and-infra-${var.env}-role-ec2-bastion",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-and-infra-${var.env}-role-redshift-aiu",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-and-infra-${var.env}-role-temp-snowflake-load-unload",
            "arn:aws:iam::${var.awsAccount_B}:root
          ]
        },
        "Action": [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource": "*"
      },
      {
        "Sid": "Allow attachment of persistent resources",
        "Effect": "Allow",
        "Principal": {
          "AWS": [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/PowerRole",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-and-infra-${var.env}-role-ec2-bastion",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-and-infra-${var.env}-role-redshift-aiu",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-and-infra-${var.env}-role-temp-snowflake-load-unload",
            "arn:aws:iam::${var.awsAccount_B}:root
          ]
        },
        "Action": [
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant"
        ],
        "Resource": "*",
        "Condition": {
          "Bool": {
            "kms:GrantIsForAWSResource": "true"
          }
        }
      }
    ]
  }
  EOF
}

resource "aws_kms_alias" "s3-temp-load-unload-snowflake" {
  name          = "alias/aws-and-infra${var.env}-kms-s3-temp-load-unload-snowflake"
  target_key_id = aws_kms_key.s3-temp-load-unload-snowflake.key_id
}
