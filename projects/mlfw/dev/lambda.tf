resource "aws_lambda_function" "lambda_message" {
  function_name    = "aws-and-infra-${var.env}-lambda-mlfw-send-message"
  runtime          = "python3.12"
  role             = "data.aws_iam_role.admin_role.arn"
  package_type     = "Zip"
  handler          = "dummy.lambda_handler"
  filename         = "dummy.zip"
  timeout          = 10
  reserved_concurrent_executions = 1
  layers           = [
    "arn:aws:lambda:ap-north-east-1:580247275435:layer:LambdaInsightsEtension:25"
  ]
  vpc_config {
    subnet_ids = [
      var.private_AZ_A,
      var.pribate_AZ_C
    ]
    security_group_ids = [data.aws_security_group.common.id]  
  }
  dead_letter_config {
    target_arn = aws_sqs_queue.aqs_dead_letter_queue.arn
  }
  lifecycle {
    ignore_changes = [
      handler,
      filename,
      environment,
      runtime
    ]
  }

  resource "aws_lambda_function_event_invoke_config" "lambda_message_event_invoke_config" {
    function_name = aws_lambda_function.lambda_message.function_name
    maximum_event_age_in_seconds = 21600
    maximum_retry_attempts = 2
  }

  resource "aws_lambda_permission" "lambda_message_permission" {
    statement_id  = "AllowExecutionFromSendmMessage"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.lambda_message.function_name
    principal     = "events.amazonaws.com"
    source_arn    = aws_cloudwatch_event_rule.rule_daily.arn
  }
}
