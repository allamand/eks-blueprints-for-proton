/*
This file is no longer managed by AWS Proton. The associated resource has been deleted in Proton.
*/

locals {
  name            = basename(path.cwd)
  region          = data.aws_region.current.name
  cluster_version = "1.21"
  #terraform_version = "Terraform v1.0.1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  node_group_name = "managed-ondemand"

  #---------------------------------------------------------------
  # ARGOCD ADD-ON APPLICATION
  #---------------------------------------------------------------

  addon_application = {
    path               = "chart"
    repo_url           = "${var.environment.inputs.addon_repo_url}"
    add_on_application = true
  }

  #---------------------------------------------------------------
  # ARGOCD WORKLOAD APPLICATION
  #---------------------------------------------------------------

  workload_application = {
    path               = "${var.environment.inputs.workload_repo_path}"
    repo_url           = "${var.environment.inputs.workload_repo_url}"
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
