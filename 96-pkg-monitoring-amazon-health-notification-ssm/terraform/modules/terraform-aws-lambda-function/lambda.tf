data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 7
}

# Create a Lambda Function
resource "aws_lambda_function" "health_event_lambda" {
  function_name    = var.lambda_function_name
  runtime          = "python3.11"
  handler          = "main.lambda_handler"
  filename         = "${path.module}/lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda.zip")

  role = aws_iam_role.lambda_execution_role.arn

  environment {
    variables = {
      SLACK_API_TOKEN_SECRET_PATH = var.slack_token_ssm_path
      ENVIRONMENT                 = var.environment
      #SLACK_WEBHOOK_URL = var.slack_webhook_url
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
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "${aws_cloudwatch_log_group.main.arn}:*"
    },
    {
      "Action": [
        "ssm:GetParametersByPath",
        "ssm:GetParameters",
        "ssm:GetParameter"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${var.slack_token_ssm_path}"
    }    
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "lambda_execution_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  roles       = [aws_iam_role.lambda_execution_role.name]
  name        = "${var.context}-lambda-execution-role-attachment"
}

resource "aws_iam_policy_attachment" "lambda_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_policy.arn
  roles       = [aws_iam_role.lambda_execution_role.name]
  name        = "${var.context}-lambda-policy-attachment"
}
