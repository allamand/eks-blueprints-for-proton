/*
This file is managed by AWS Proton. Any changes made directly to this file will be overwritten the next time AWS Proton performs an update.

To manage this resource, see AWS Proton Resource: arn:aws:proton:eu-west-1:382076407153:environment/eks-proton-1

If the resource is no longer accessible within AWS Proton, it may have been deleted and may require manual cleanup.
*/

locals {
  name            = basename(path.cwd)
  region          = data.aws_region.current.name
  cluster_version = "1.21"
  #terraform_version = "Terraform v1.0.1"

  vpc_cidr      = "10.0.0.0/16"
  azs           = slice(data.aws_availability_zones.available.names, 0, 3)

  node_group_name = "managed-ondemand"

  #---------------------------------------------------------------
  # ARGOCD ADD-ON APPLICATION
  #---------------------------------------------------------------

  addon_application = {
    path               = "chart"
    repo_url           = "https://github.com/seb-demo/eks-blueprints-add-ons.git"
    add_on_application = true
  }

  #---------------------------------------------------------------
  # ARGOCD WORKLOAD APPLICATION
  #---------------------------------------------------------------

  workload_application = {
    path               = "envs/dev"
    repo_url           = "https://github.com/seb-demo/eks-blueprints-workloads.git"
    add_on_application = false
  }

  #---------------------------------------------------------------
  # ARGOCD ECSDEMO APPLICATION
  #---------------------------------------------------------------

   ecsdemo_application = {
    path               = "multi-repo/argo-app-of-apps/dev"
    repo_url           = "https://github.com/seb-demo/eks-blueprints-workloads.git"
    add_on_application = false
  }   


  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}
