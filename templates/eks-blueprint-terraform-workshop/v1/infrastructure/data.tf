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


# The TeamRole IAM role used when at AWS event
#data "aws_iam_role" "team_event" {
#  name = "TeamRole"
#}