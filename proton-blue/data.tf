/*
This file is no longer managed by AWS Proton. The associated resource has been deleted in Proton.
*/

# Partition (commercial, govCloud, etc) in which to deploy the solution
data "aws_partition" "current" {}

# Find the user currently in use by AWS
data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "cluster" {
  name = module.eks_blueprints.eks_cluster_id
}

# Region in which to deploy the solution
data "aws_region" "current" {}

# Availability zones to use in our soultion
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks_blueprints.eks_cluster_id
}

data "aws_acm_certificate" "issued" {
  domain   = var.environment.inputs.acm_certificate_domain
  statuses = ["ISSUED"]
}
