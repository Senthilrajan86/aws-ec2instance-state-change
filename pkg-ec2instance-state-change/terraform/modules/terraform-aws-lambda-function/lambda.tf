data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/lambda/${var.lambda_function_name}"
#  retention_in_days = 7
}

# Create a Lambda Function
resource "aws_lambda_function" "health_event_lambda" {
  function_name    = var.lambda_function_name
  runtime          = "python3.8"
  handler          = "main.handler"
  filename         = "${path.module}/lambda/lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/lambda.zip")

  role = aws_iam_role.lambda_execution_role.arn

  environment {
    variables = {
      SLACK_WEBHOOK_URL = var.slack_webhook_url
    }
  }
}

# Create an IAM Role for Lambda
resource "aws_iam_role" "lambda_execution_role" {
  name = var.lambda_function_name

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

# Attach IAM Policy to Lambda Role (for EventBridge and CloudWatch Logs)
resource "aws_iam_policy" "lambda_policy" {
  name = var.lambda_function_name
  #role = aws_iam_role.lambda_execution_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "logs:CreateLogGroup",
      "Effect": "Allow",
      "Resource": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
    },
    {
      "Action": [
        "events:PutTargets",
        "events:PutRule",
        "events:RemoveTargets",
        "events:TestEventPattern",
        "lambda:InvokeFunction",
        "lambda:InvokeAsync",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "${aws_cloudwatch_log_group.main.arn}:*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "lambda_execution_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  roles       = [aws_iam_role.lambda_execution_role.name]
  name        = "lambda-execution-role-attachment"
}

resource "aws_iam_policy_attachment" "lambda_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_policy.arn
  roles       = [aws_iam_role.lambda_execution_role.name]
  name        = "lambda-policy-attachment"
}
