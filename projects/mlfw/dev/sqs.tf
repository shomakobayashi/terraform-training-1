resource "aws_sqs_queue" "sqs_queue" {
  name = "aws-and-infra-${var.env}-sqs-queue"
  fifo_queue = true
  deduplication_scope = "messageGroup"
  content_based_deduplication = true
  kms_master_key_id = data.aws_kms_key.common_account.arn
  message_retention_seconds = 604800
  receive_wait_time_seconds = 20
  visibility_timeout_seconds = 43200
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.aqs_dead_letter_queue.arn,
    maxReceiveCount = 1000
  })
}

resource "aws_sqs_queue_policy" "sqs_queue_policy" {
  queue_url = aws_sqs_queue.sqs_queue.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "policy"
  "Statement": [
    {
      "Sid": "__owner_statement",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.self.account_id}:root"
      },
      "Action": "sqs:*",
      "Resource": "arn:aws:sqs:ap-north-east-1:${data.aws_caller_identity.self.account_id}:aws-and-infra-${var.env}-sqs-queue.fifo"
    },
    {
      "Sid": "cloudwatch-event-rule-mlfw-daily",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sqs:SendMessage",
      "Resource": "arn:aws:sqs:ap-north-east-1:${data.aws_caller_identity.self.account_id}:aws-and-infra-${var.env}-sqs-queue.fifo",
      "condition": {
        "ArnEquals": {
          "aws:SourceArn: "arn:aws:events:ap-north-east-1:${data.aws_caller_identity.self.account_id}:rule/aws-and-infra-${var.env}-cloudwatch-rule-daily"
        }
      }
    },
    {
      "Sid": "lambda-mlfw-sendmassage",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sqs:SendMessage",
      "Resource": "arn:aws:sqs:ap-north-east-1:${data.aws_caller_identity.self.account_id}:aws-and-infra-${var.env}-sqs-queue.fifo",
      "condition": {
        "ArnEquals": {
          "aws:SourceArn: "arn:aws:lambda:ap-north-east-1:${data.aws_caller_identity.self.account_id}:function/aws-and-infra-${var.env}-lambda-mlfw-send-message"
        }
      }
    }
  ]
}