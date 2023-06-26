provider "aws" {
  region = var.aws_region
  alias  = "default"
  default_tags {
    tags = {
      "proton:environment" = var.environment.name
    }
  }
}

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.72.0"
    }
    random = {
      version = ">= 3"
    }
  }
}
