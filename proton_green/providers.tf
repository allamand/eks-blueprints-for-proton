/*
This file is managed by AWS Proton. Any changes made directly to this file will be overwritten the next time AWS Proton performs an update.

To manage this resource, see AWS Proton Resource: arn:aws:proton:eu-west-1:382076407153:environment/proton_green

If the resource is no longer accessible within AWS Proton, it may have been deleted and may require manual cleanup.
*/

provider "aws" {
  region = var.aws_region
  alias  = "default"
  default_tags {
    tags = {
      "proton:environment" = var.environment.name
    }
  }
}

variable "aws_region" {
  type = string
}

terraform {
  required_version = ">= 1.0.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.72"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.4.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14"
    }
  }
}
