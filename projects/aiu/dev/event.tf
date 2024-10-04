resource "aws_cloudwatch_event_rule" "rule_cloudwatch_rule_stop_ec2_2200" {
  name        = "aws-and-infra-${var.env}-rule-cloudwatch-rule-stop-ec2-2200"
  description = "aws-and-infra-${var.env}-rule-cloudwatch-rule-stop-ec2-2200"
  event_bus_name = "default"
  schedule_expression =  "cron(0 22 * * ? *)"
  tags = {}
  tags_all = {}
}

resource "aws_cloudwatch_event_target" "target_cloudwatch_rule_stop_ec2_2200" {
  rule = aws_cloudwatch_event_rule.rule_cloudwatch_rule_stop_ec2_2200.name
  arn = data.aws_lambda_function.lambda_ec2_stop_start.arn
  event_bus_name = "default"

  input = jsoncode({
    "action" = "stop",
    "Instance" = var.ec2_instance_ids
  })

  #手動でターゲットを追加した際のコンフリクト防止用
  lifecycle {
    ignore_changes = [input]
  }
  
  resource "aws_lambda_permission" "allow_cloudwatch_rule_stop_ec2_2200" {
    statement_id  = "AllowExecutionFromCloudWatch"
    action        = "lambda:InvokeFunction"
    function_name = data.aws_lambda_function.lambda_ec2_stop_start.function_name
    principal     = "events.amazonaws.com"
    source_arn    = aws_cloudwatch_event_rule.rule_cloudwatch_rule_stop_ec2_2200.arn
  }
}