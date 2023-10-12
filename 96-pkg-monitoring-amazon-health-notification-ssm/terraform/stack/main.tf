terraform {
  required_version = ">= 1.3.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0, < 6.0.0"
    }
  }  
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region

  default_tags {
    tags = merge({
      "EQBusiness" : "Platform"
      "PowerOSComponent" : "Platform"
      "EQService" : "Monitoring"
      "Runtime" : "AWS"
    }, var.tags)
  }
}

module "lambda_function" {
  for_each     = var.lambda_function_map  
  source       = "../modules/terraform-aws-lambda-function"
  lambda_function_name     = each.value.lambda_function_name
  event_bus_name           = each.value.event_bus_name
  context                  = each.value.context
  slack_token_ssm_path     = each.value.sns_slack_api_token_ssm_key
  environment              = each.value.environment
  # slack_webhook_url        = each.value.slack_webhook_url

}