locals {
  logging_target_bucket_name = "aws-and-infra-${var.env}-s3-aws-logs"
}

module "s2_temp_load_to_snowflake" {
  source = "../../../modulea/s3_v01"

  #バケット名（Nameタグにもこのバケット名が自動で指定される）
  bucket = "aws-and-infra-${var.env}-s3-temp-load-to-snowflake"

  tags = {
    Environment = var.tag-env
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "aws:kms"
        kms_master_key_id = aws_kms_key.s3-temp-load-unload-snowflake.key_id
      }
      bucket_key_enabled = true
    }
  }

  attach_policy = true
  policy        = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Deny",
        "Principal": "*",
        "Action": "s3:PutObject",
        "Resource": "arn:aws:s3:::aws-and-infra-${var.env}-s3-temp-load-to-snowflake/*",
        "condition": {
          "StringNotEquals": {
            "s3:x-amz-server-side-encryption": "aws:kms"
          },
          "null": {
            "s3:x-amz-server-side-encryption": "false"
          }
        }
      },
      {
        "Effect": "Deny",
        "Principal": "*",
        "Action": "s3:PutObject",
        "Resource": "arn:aws:s3:::aws-and-infra-${var.env}-s3-temp-load-to-snowflake/*",
        "condition": {
          "StringNotEquals": {
            "s3:x-amz-server-side-encryption-aws-kms-key-id": "${aws_kms_key.s3-temp-load-unload-snowflake.arn}"
          }
        }
      },
      {
        "Sid": "Load to Snowflake",
        "Effect": "Deny",
        "Principal": {
          "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-and-infra-${var.env}-role-temp-snowflake-load-unload"
        },
        "Action": [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketLocation",
          "s3:GetObhectVersionTagging"
        ],
        "Resource": [
          "arn:aws:s3:::aws-and-infra-${var.env}-s3-temp-load-to-snowflake",
          "arn:aws:s3:::aws-and-infra-${var.env}-s3-temp-load-to-snowflake/*"
        ],
        "conditioin": {
          "StringNotEquals": {
            "aws:sourceVpc": "vpc-0a1b2c3d4e5f6g7h8"
          }
        },
        {
          "Sid": "Internal Access",
          "Efect": "Deny",
          "Principal": "*",
          "Action": "s3:*",
          "Resource": [
            "arn:aws:s3:::aws-and-infra-${var.env}-s3-temp-load-to-snowflake",
            "arn:aws:s3:::aws-and-infra-${var.env}-s3-temp-load-to-snowflake/*"
          ], 
          "Condition": {
            "StringNotLike": {
              "aws:userId": [
              "${data.aws_iam_role.codepipeline.unique_id}:*",
              "${data.aws_iam_role.codebuild.unique_id}:*",
              "${data.aws_iam_role.admin_role.unique_id}:*",
              "${data.aws_iam_role.power_role.unique_id}:*",
              "${data.aws_iam_role.redshift_role.unique_id}:*",
              "${var.rolename_aws-and-infra-prd-role-ec2-bastion}:*",
              "${data.aws_caller_identity.self.account_id}"
            ]
          }
        }
      },
      {
        "Sid": "Allow To gdp-prd Bastion",
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::${var.awsAccount_gdpf-prd}:role/aws-and-infra-${var.env_prd}-role-ec2-bastion"
        },
        "Action": "s3:*",
        "Resource": [
          "arn:aws:s3:::aws-and-infra-${var.env}-s3-temp-load-to-snowflake",
          "arn:aws:s3:::aws-and-infra-${var.env}-s3-temp-load-to-snowflake/*"
        ]
      }
    ]
  }
  EOF
logging = {
    target_bucket = local.logging_target_bucket_name
    target_prefix = "aws/s3/accesslog/aws-and-infra-${var.env}-s3-temp-load-to-snowflake/"
}

#バージョニングを使用しない場合は以下を記載
  # versioning = {
  #   suspended = true
  # }

#ライフサイクルルールの要件はないのでコメントアウトする
  # lifecycle_rule = [
  #   {
  #     id = "aws-and-infra-${var.env}-s3-lcr-rule-temp-load-to-snowflake"
  #     enabled = false
  #     abort_incomplete_multipart_upload_days = 14
  #     expiration = {
  #       days = 14
  #       expired_object_delete_marker = false
  #   }
  #     noncurrent_version_expiration = {
  #       days = 14
  #     }
  #   }
  # ]
}
