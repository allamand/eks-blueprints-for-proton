variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-2"
}
variable "environment_name" {
  description = "The name of Environment Infrastructure stack, feel free to rename it. Used for cluster and VPC names."
  type        = string
  default     = "eks-blueprint"
}

variable "service_name" {
  description = "The name of the Suffix for the stack name"
  type        = string
  default     = "blue"
}

variable "cluster_version" {
  description = "The Version of Kubernetes to deploy"
  type        = string
  default     = "1.25"
}

variable "hosted_zone_name" {
  type        = string
  description = "Route53 domain for the cluster."
  default     = ""
}

variable "eks_admin_role_name" {
  type        = string
  description = "Additional IAM role to be admin in the cluster"
  default     = ""
}

variable "workload_repo_url" {
  type        = string
  description = "Git repo URL for the ArgoCD workload deployment"
  default     = "https://github.com/aws-samples/eks-blueprints-workloads.git"
}

variable "workload_repo_secret" {
  type        = string
  description = "Secret Manager secret name for hosting Github SSH-Key to Access private repository"
  default     = "github-blueprint-ssh-key"
}

variable "workload_repo_revision" {
  type        = string
  description = "Git repo revision in workload_repo_url for the ArgoCD workload deployment"
  default     = "main"
}

variable "workload_repo_path" {
  type        = string
  description = "Git repo path in workload_repo_url for the ArgoCD workload deployment"
  default     = "envs/dev"
}

variable "addons_repo_url" {
  type        = string
  description = "Git repo URL for the ArgoCD addons deployment"
  default     = "https://github.com/aws-samples/eks-blueprints-add-ons.git"
}

variable "iam_platform_user" {
  type        = string
  description = "IAM user used as platform-user"
  default     = ""
}

variable "argocd_secret_manager_name_suffix" {
  type        = string
  description = "Name of secret manager secret for ArgoCD Admin UI Password"
  default     = "argocd-admin-secret"
}

variable "argocd_route53_weight" {
  description = "The Route53 weighted records weight for argocd application"
  type        = string
  default     = "0"
}

variable "ecsfrontend_route53_weight" {
  description = "The Route53 weighted records weight for ecsdeo-frontend application"
  type        = string
  default     = "0"
}

variable "route53_weight" {
  description = "The Route53 weighted records weight for others application"
  type        = string
  default     = "0"
}
