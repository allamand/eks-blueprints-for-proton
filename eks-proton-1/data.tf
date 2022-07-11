/*
This file is managed by AWS Proton. Any changes made directly to this file will be overwritten the next time AWS Proton performs an update.

To manage this resource, see AWS Proton Resource: arn:aws:proton:eu-west-1:382076407153:environment/eks-proton-1

If the resource is no longer accessible within AWS Proton, it may have been deleted and may require manual cleanup.
*/

# Partition (commercial, govCloud, etc) in which to deploy the solution
data "aws_partition" "current" {}

# Find the user currently in use by AWS
data "aws_caller_identity" "current" {}

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