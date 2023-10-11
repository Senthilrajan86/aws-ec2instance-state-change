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
      "EQService" : "Serverless"
      "Runtime" : "K8S Compute"
    }, var.tags)
  }
}

module "lambda_function" {
  for_each     = var.lambda_function_map  
  source       = "../modules/terraform-aws-lambda-function"
  lambda_function_name     = each.value.lambda_function_name
  event_bus_name           = each.value.event_bus_name
  slack_webhook_url        = each.value.slack_webhook_url

}