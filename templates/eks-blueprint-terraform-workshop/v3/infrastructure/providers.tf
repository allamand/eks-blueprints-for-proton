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
  type    = string
  default = "us-east-1"
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
