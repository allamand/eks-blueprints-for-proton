provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = module.eks_cluster.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks_cluster.eks_cluster_id]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks_cluster.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks_cluster.eks_cluster_id]
    }
  }
}

provider "kubectl" {
  apply_retry_count      = 10
  host                   = module.eks_cluster.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks_cluster.eks_cluster_id]
  }
}

module "eks_cluster" {
  source = "./modules/eks_cluster"

  aws_region = var.aws_region
  #We uses service_instance name here because in proton we can't have 2 services with same name
  #service_name    = var.service.name
  service_name    = var.service_instance.name
  cluster_version = var.service_instance.inputs.kubernetes_version

  argocd_route53_weight      = var.service_instance.inputs.argocd_route53_weight
  route53_weight             = var.service_instance.inputs.route53_weight
  ecsfrontend_route53_weight = var.service_instance.inputs.ecsfrontend_route53_weight

  environment_name       = var.environment.name
  hosted_zone_name       = var.environment.outputs.hosted_zone_name
  eks_admin_role_name    = var.service_instance.inputs.eks_admin_role_name
  workload_repo_url      = var.service_instance.inputs.workload_repo_url
  workload_repo_secret   = var.service_instance.inputs.workload_repo_secret
  workload_repo_revision = var.service_instance.inputs.workload_repo_revision
  workload_repo_path     = var.service_instance.inputs.workload_repo_path

  addons_repo_url = var.service_instance.inputs.addons_repo_url

  iam_platform_user                 = var.service_instance.inputs.iam_platform_user
  argocd_secret_manager_name_suffix = var.environment.outputs.argocd_secret_manager_name_suffix

  # metrics_server               = var.service_instance.inputs.metrics_server
  # aws_load_balancer_controller = var.service_instance.inputs.aws_load_balancer_controller
  # karpenter                    = var.service_instance.inputs.karpenter
  # aws_for_fluentbit            = var.service_instance.inputs.aws_for_fluentbit
  # cert_manager                 = var.service_instance.inputs.cert_manager
  # cloudwatch_metrics           = var.service_instance.inputs.cloudwatch_metrics
  # external_dns                 = var.service_instance.inputs.external_dns
  # vpa                          = var.service_instance.inputs.vpa
  # kubecost                     = var.service_instance.inputs.kubecost
  # argo_rollouts                = var.service_instance.inputs.argo_rollouts

}
