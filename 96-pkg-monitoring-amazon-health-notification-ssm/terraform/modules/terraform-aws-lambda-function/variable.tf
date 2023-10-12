variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "event_bus_name" {
  description = "Name of the EventBridge event bus"
  type        = string
}

#variable "slack_webhook_url" {
#  description = "Slack Incoming Webhook URL"
#  type        = string
#}

variable "slack_token_ssm_path" {
  type        = string
  description = "Path in SSM used to fetch Slack token"
}

variable "context" {
  type        = string
  description = "Name of the context like eqdev01, eqstage01, etc"
}

variable "environment" {
  type        = string
  description = "Environment name like dev, stage, prod"
}
