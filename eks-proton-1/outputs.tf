/*
This file is managed by AWS Proton. Any changes made directly to this file will be overwritten the next time AWS Proton performs an update.

To manage this resource, see AWS Proton Resource: arn:aws:proton:eu-west-1:382076407153:environment/eks-proton-1

If the resource is no longer accessible within AWS Proton, it may have been deleted and may require manual cleanup.
*/

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}
output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_blueprints.configure_kubectl
}

# output "team_riker" {
#   description = "Role Arn of team-riker"
#   value       = module.eks_blueprints.teams[*].application_teams_iam_role_arn["team-riker"]
# }

# output "platform_team" {
#   description = "Role Arn of platform-team"
#   value       = module.eks_blueprints.teams[*].platform_teams_iam_role_arn["admin"]
# }

output "eks_cluster_id" {
  description = "ID of EKs cluster"
  value = module.eks_blueprints.eks_cluster_id
}
