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
  service_name    = var.service_instance.name
  cluster_version = var.service_instance.inputs.kubernetes_version

  argocd_route53_weight      = var.service_instance.inputs.argocd_route53_weight
  route53_weight             = var.service_instance.inputs.route53_weight
  ecsfrontend_route53_weight = var.service_instance.inputs.ecsfrontend_route53_weight

  environment_name    = var.environment.name
  hosted_zone_name    = var.environment.outputs.hosted_zone_name
  eks_admin_role_name = var.service_instance.inputs.eks_admin_role_name

  aws_secret_manager_git_private_ssh_key_name = var.service_instance.inputs.aws_secret_manager_git_private_ssh_key_name
  argocd_secret_manager_name_suffix           = var.service_instance.inputs.argocd_secret_manager_name_suffix
  #ingress_type                                = "alb" #var.service_instance.inputs.ingress_type

  gitops_addons_org      = var.service_instance.inputs.gitops_addons_org
  gitops_addons_repo     = var.service_instance.inputs.gitops_addons_repo
  gitops_addons_basepath = var.service_instance.inputs.gitops_addons_basepath
  gitops_addons_path     = var.service_instance.inputs.gitops_addons_path
  gitops_addons_revision = var.service_instance.inputs.gitops_addons_revision

  gitops_workloads_org      = var.service_instance.inputs.gitops_workloads_org
  gitops_workloads_repo     = var.service_instance.inputs.gitops_workloads_repo
  gitops_workloads_revision = var.service_instance.inputs.gitops_workloads_revision
  gitops_workloads_path     = var.service_instance.inputs.gitops_workloads_path




}
