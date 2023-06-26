output "tf_state_bucket" {
  description = "Terraform state bucket name"
  value       = var.environment.inputs.tf_state_bucket
}

output "tf_state_bucket_region" {
  description = "AWS Region where state bucket resides"
  value       = var.environment.inputs.tf_state_bucket_region
}

output "aws_region" {
  description = "AWS Region where resources reside"
  value       = var.environment.inputs.aws_region
}

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

output "hosted_zone_name" {
  description = "Hosted Zone Name"
  value       = var.environment.inputs.hosted_zone_name
}

output "argocd_secret_manager_name_suffix" {
  description = "ArgoCD secret manager suffix"
  value       = var.environment.inputs.argocd_secret_manager_name_suffix
}