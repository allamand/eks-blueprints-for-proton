output "eks_cluster_id" {
  description = "The name of the EKS cluster."
  value       = module.eks_cluster.eks_cluster_id
}

output "kubernetes_version" {
  description = "The version of the EKS cluster."
  value       = var.service_instance.inputs.kubernetes_version
}

# output "enable_aws_load_balancer_controller" {
#   description = "The flag for the Load Balancer controller."
#   value       = var.service_instance.inputs.aws_load_balancer_controller
# }

# output "enable_karpenter" {
#   description = "The flag for Karpenter."
#   value       = var.service_instance.inputs.karpenter
# }

# output "enable_metrics_server" {
#   description = "The flag for the Metric Server."
#   value       = var.service_instance.inputs.metrics_server
# }

# output "enable_aws_for_fluentbit" {
#   description = "The flag for the Fluentbit."
#   value       = var.service_instance.inputs.aws_for_fluentbit
# }

# output "enable_cert_manager" {
#   description = "The flag for Certificate Manager."
#   value       = var.service_instance.inputs.cert_manager
# }

# output "enable_vpa" {
#   description = "The flag for Virtual Pod Autoscaler."
#   value       = var.service_instance.inputs.vpa
# }

output "eks_blueprints_platform_teams_configure_kubectl" {
  description = "Configure kubectl Platform Team: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_cluster.eks_blueprints_platform_teams_configure_kubectl
}

#Proton does not like list of outputs
#Invalid type for parameter outputs[0].valueString, value: ['aws eks --region eu-west-1 update-kubeconfig --name proton-dev-eks-green  --role-arn arn:aws:iam::382076407153:role/team-burnham-20230627141152607800000015', 'aws eks --region eu-west-1 update-kubeconfig --name proton-dev-eks-green  --role-arn arn:aws:iam::382076407153:role/team-riker-20230627141152922700000016'], type: <class 'list'>, valid types: <class 'str'>
/* output "eks_blueprints_dev_teams_configure_kubectl" {
  description = "Configure kubectl for each Dev Application Teams: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_cluster.eks_blueprints_dev_teams_configure_kubectl
}

output "eks_blueprints_ecsdemo_teams_configure_kubectl" {
  description = "Configure kubectl for each ECSDEMO Application Teams: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_cluster.eks_blueprints_ecsdemo_teams_configure_kubectl
} */