variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "event_bus_name" {
  description = "Name of the EventBridge event bus"
  type        = string
}

variable "slack_webhook_url" {
  description = "Slack Incoming Webhook URL"
  type        = string
}
