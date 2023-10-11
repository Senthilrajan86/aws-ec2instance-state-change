variable "aws_profile" {
  type        = string
  description = "AWS credential profile to use"
}

variable "aws_region" {
  type        = string
  description = "AWS Region the instance is launched in"
}

variable "tags" {
  description = "tags"
  type        = map(string)
  default     = {}
}


variable "lambda_function_create" {
  type   		  	  = bool
  description 	  = "Create Lambda function"
  default         = false
}

variable "lambda_function_map" {
  type 		     		  = map(object({
    lambda_function_name   = string,
    event_bus_name         = string,
    slack_webhook_url      = string
  }))
  default = {}
}