/*
This file is managed by AWS Proton. Any changes made directly to this file will be overwritten the next time AWS Proton performs an update.

To manage this resource, see AWS Proton Resource: arn:aws:proton:eu-west-1:382076407153:environment/proton

If the resource is no longer accessible within AWS Proton, it may have been deleted and may require manual cleanup.
*/

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "aws_route53_zone" {
  description = "The new Route53 Zone"
  value       = aws_route53_zone.sub.name
}

output "aws_acm_certificate_status" {
  description = "Status of Certificate"
  value       = module.acm.acm_certificate_status
}

output "core_stack_name" {
  description = "Core Infra stack name"
  value       = var.environment.inputs.core_stack_name
}

output "hosted_zone_name" {
  description = "Hosted Zone Name"
  value       = var.environment.inputs.hosted_zone_name
}

output "argocd_secret_manager_name_suffix" {
  description = "ArgoCD secret manager suffix"
  value       = var.environment.inputs.argocd_secret_manager_name_suffix
}