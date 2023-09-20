output "eks_cluster_id" {
  description = "The name of the EKS cluster."
  value       = module.eks_cluster.eks_cluster_id
}

output "kubernetes_version" {
  description = "The version of the EKS cluster."
  value       = var.service_instance.inputs.kubernetes_version
}

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_cluster.configure_kubectl
}


output "eks_blueprints_platform_teams_configure_kubectl" {
  description = "Configure kubectl Platform Team: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_cluster.eks_blueprints_platform_teams_configure_kubectl
}

#Proton does not like list of outputs
#Invalid type for parameter outputs[0].valueString, value: ['aws eks --region eu-west-1 update-kubeconfig --name proton-dev-eks-green  --role-arn arn:aws:iam::382076407153:role/team-burnham-20230627141152607800000015', 'aws eks --region eu-west-1 update-kubeconfig --name proton-dev-eks-green  --role-arn arn:aws:iam::382076407153:role/team-riker-20230627141152922700000016'], type: <class 'list'>, valid types: <class 'str'>
#  output "eks_blueprints_dev_teams_configure_kubectl" {
#   description = "Configure kubectl for each Dev Application Teams: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
#   value       = module.eks_cluster.eks_blueprints_dev_teams_configure_kubectl
# }


output "access_argocd" {
  description = "ArgoCD Access"
  value       = module.eks_cluster.access_argocd
}

output "gitops_metadata" {
  description = "export gitops_metadata"
  value       = module.eks_cluster.gitops_metadata
  sensitive   = true
}