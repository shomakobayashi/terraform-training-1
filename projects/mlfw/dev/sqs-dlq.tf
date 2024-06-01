resource "aws_sqs_queue" "aqs_dead_letter_queue" {
  name = "aws-and-infra-${var.env}-aqs-dead-letter-queue"
  fifo_queue = false
  kms_master_key_id = data.aws_kms_key.common_account.arn
  message_retention_seconds = 604800
  receive_wait_time_seconds = 20
}
