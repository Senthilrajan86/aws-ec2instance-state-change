# Create an EventBridge Rule
resource "aws_cloudwatch_event_rule" "ec2_health_event_rule" {
  name          = "ec2_instance_change_rule"
  description   = "Rule to capture EC2 instance change events"
  event_pattern = <<EOF
{
  "source": ["aws.ec2"],
  "detail-type": ["EC2 Instance State-change Notification"],
  "detail": {
    "state": ["pending", "running", "shutting-down", "terminated", "stopping", "stopped"]
  }
}
EOF
}

# Create a target for the EventBridge Rule
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.health_event_rule.name
  target_id = "send_to_lambda"
  arn = aws_lambda_function.health_event_lambda.arn
}

# Create a Lambda Permission for EventBridge
resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.health_event_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.health_event_rule.arn
}
