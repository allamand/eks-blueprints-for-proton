output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "platform_teams_configure_kubectl" {
  description = "The command to use to configure the kubeconfig file to be used with kubectl."
  value = tomap({
    #for k, v in module.eks_blueprints.teams[0].platform_teams_iam_role_arn : 
    #k => "aws eks --region ${data.aws_region.current.id} update-kubeconfig 
    #--name ${data.aws_eks_cluster.cluster.name}  --role-arn ${v}"
    for k, v in module.eks_blueprints.teams[0].platform_teams_iam_role_arn : k => "aws eks --region ${data.aws_region.current.id} update-kubeconfig --name ${module.eks_blueprints.eks_cluster_id}  --role-arn ${v}"
  })["admin"]
}

output "eks_cluster_id" {
  description = "The name of the EKS cluster."
  value       = module.eks_blueprints.eks_cluster_id
}

output "cluster_version" {
  description = "The version of the EKS cluster."
  value       = var.service_instance.inputs.cluster_version
}

output "enable_aws_load_balancer_controller" {
  description = "The flag for the Load Balancer controller."
  value       = var.service_instance.inputs.aws_load_balancer_controller
}

output "enable_karpenter" {
  description = "The flag for Karpenter."
  value       = var.service_instance.inputs.karpenter
}

output "enable_metrics_server" {
  description = "The flag for the Metric Server."
  value       = var.service_instance.inputs.metrics_server
}

output "enable_aws_for_fluentbit" {
  description = "The flag for the Fluentbit."
  value       = var.service_instance.inputs.aws_for_fluentbit
}

output "enable_cert_manager" {
  description = "The flag for Certificate Manager."
  value       = var.service_instance.inputs.cert_manager
}

output "enable_vpa" {
  description = "The flag for Virtual Pod Autoscaler."
  value       = var.service_instance.inputs.vpa
}



output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_blueprints.configure_kubectl
}
