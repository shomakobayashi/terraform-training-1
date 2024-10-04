resource "aws_cloudwatch_event_rule" "rule_daily" {
  name                = "aws-and-infra-${var.env}-cloudwatch-event-rule-daily"
  description         = "aws-and-infra-${var.env}-cloudwatch-event-rule-daily"
  schedule_expression = "cron(0 1 * * ? *)"
  is_enabled          = false

  lifecycle {
    ignore_changes = [schedule_expression, is_enabled]
  }
}

resource "aws_cloudwatch_event_target" "event_lambda_message" {
  arn = aws_lambda_function.lambda_message.arn
  rule = aws_cloudwatch_event_rule.rule_daily
  target_id = "lambda-mlfw-metric-send-message-daily"
  event_bus_name = "default"
}
