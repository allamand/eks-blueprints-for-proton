provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks_blueprints.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

provider "kubectl" {
  apply_retry_count      = 10
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
  load_config_file       = false
  token                  = data.aws_eks_cluster_auth.this.token
}


locals {
  core_stack_name   = var.environment.outputs.core_stack_name
  suffix_stack_name = var.service.name

  env  = var.environment.outputs.core_stack_name
  name = "${local.core_stack_name}-${local.suffix_stack_name}"

  eks_cluster_domain = "${local.core_stack_name}.${var.environment.outputs.hosted_zone_name}" # for external-dns

  cluster_version = var.service_instance.inputs.cluster_version

  # Route 53 Ingress Weights
  argocd_route53_weight      = var.service_instance.inputs.argocd_route53_weight
  route53_weight             = var.service_instance.inputs.route53_weight
  ecsfrontend_route53_weight = var.service_instance.inputs.ecsfrontend_route53_weight

  tag_val_vpc            = var.vpc_tag_value == "" ? var.core_stack_name : var.vpc_tag_value
  tag_val_private_subnet = var.vpc_tag_value == "" ? "${var.core_stack_name}-private-" : var.vpc_tag_value

  node_group_name            = "managed-ondemand"
  argocd_secret_manager_name = var.environment.outputs.argocd_secret_manager_name_suffix

  #---------------------------------------------------------------
  # ARGOCD ADD-ON APPLICATION
  #---------------------------------------------------------------

  addon_application = {
    path                = "chart"
    repo_url            = "${var.service_instance.inputs.addons_repo_url}"
    ssh_key_secret_name = "${var.service_instance.inputs.workload_repo_secret}"
    add_on_application  = true
  }

  #---------------------------------------------------------------
  # ARGOCD WORKLOAD APPLICATION
  #---------------------------------------------------------------

  workload_application = {
    path                = "${var.service_instance.inputs.workload_repo_path}" # <-- we could also to blue/green on the workload repo path like: envs/dev-blue / envs/dev-green
    repo_url            = "${var.service_instance.inputs.workload_repo_url}"
    target_revision     = "${var.service_instance.inputs.workload_repo_revision}"
    ssh_key_secret_name = "${var.service_instance.inputs.workload_repo_secret}"
    add_on_application  = false
    values = {
      labels = {
        env   = local.env
        myapp = "myvalue"
      }
      spec = {
        source = {
          repoURL        = "${var.service_instance.inputs.workload_repo_url}"
          targetRevision = "${var.service_instance.inputs.workload_repo_revision}"
        }
        blueprint                = "terraform"
        clusterName              = local.name
        karpenterInstanceProfile = "${local.name}-${local.node_group_name}"
        env                      = local.env
        ingress = {
          type                  = "alb"
          host                  = local.eks_cluster_domain
          route53_weight        = local.route53_weight # <-- You can control the weight of the route53 weighted records between clusters
          argocd_route53_weight = local.argocd_route53_weight
        }
      }
    }
  }

  #---------------------------------------------------------------
  # ARGOCD ECSDEMO APPLICATION
  #---------------------------------------------------------------

  ecsdemo_application = {
    path                = "multi-repo/argo-app-of-apps/dev"
    repo_url            = "${var.service_instance.inputs.workload_repo_url}"
    target_revision     = "${var.service_instance.inputs.workload_repo_revision}"
    ssh_key_secret_name = "${var.service_instance.inputs.workload_repo_secret}"
    add_on_application  = false
    values = {
      spec = {
        blueprint                = "terraform"
        clusterName              = local.name
        karpenterInstanceProfile = "${local.name}-${local.node_group_name}"

        apps = {
          ecsdemoNodejs = {
            replicaCount = "9"
            nodeSelector = {
              "karpenter.sh/provisioner-name" = "default"
            }
            tolerations = [
              {
                key      = "karpenter"
                operator = "Exists"
                effect   = "NoSchedule"
              }
            ]
            topologySpreadConstraints = [
              {
                maxSkew           = 1
                topologyKey       = "topology.kubernetes.io/zone"
                whenUnsatisfiable = "DoNotSchedule"
                labelSelector = {
                  matchLabels = {
                    "app.kubernetes.io/name" = "ecsdemo-nodejs"
                  }
                }
              }
            ]
          }

          ecsdemoCrystal = {
            replicaCount = "9"
            nodeSelector = {
              "karpenter.sh/provisioner-name" = "default"
            }
            tolerations = [
              {
                key      = "karpenter"
                operator = "Exists"
                effect   = "NoSchedule"
              }
            ]
            topologySpreadConstraints = [
              {
                maxSkew           = 1
                topologyKey       = "topology.kubernetes.io/zone"
                whenUnsatisfiable = "DoNotSchedule"
                labelSelector = {
                  matchLabels = {
                    "app.kubernetes.io/name" = "ecsdemo-crystal"
                  }
                }
              }
            ]
          }

          ecsdemoFrontend = {
            repoURL        = "https://github.com/allamand/ecsdemo-frontend"
            targetRevision = "main"
            #replicaCount   = "9" # see autoscaling configuration
            image = {
              repository = "public.ecr.aws/seb-demo/ecsdemo-frontend"
              tag        = "latest"
            }
            ingress = {
              enabled   = "true"
              className = "alb"
              annotations = {
                "alb.ingress.kubernetes.io/scheme"                = "internet-facing"
                "alb.ingress.kubernetes.io/group.name"            = "ecsdemo"
                "alb.ingress.kubernetes.io/listen-ports"          = "[{\\\"HTTPS\\\": 443}]"
                "alb.ingress.kubernetes.io/ssl-redirect"          = "443"
                "alb.ingress.kubernetes.io/target-type"           = "ip"
                "external-dns.alpha.kubernetes.io/set-identifier" = local.name
                "external-dns.alpha.kubernetes.io/aws-weight"     = local.ecsfrontend_route53_weight
              }
              hosts = [
                {
                  host = "frontend.${local.eks_cluster_domain}"
                  paths = [
                    {
                      path     = "/"
                      pathType = "Prefix"
                    }
                  ]
                }
              ]
            }
            resources = {
              requests = {
                cpu    = "1"
                memory = "256Mi"
              }
              limits = {
                cpu    = "1"
                memory = "512Mi"
              }
            }
            autoscaling = {
              enabled                        = "true"
              minReplicas                    = "9"
              maxReplicas                    = "100"
              targetCPUUtilizationPercentage = "60"
            }
            nodeSelector = {
              "karpenter.sh/provisioner-name" = "default"
            }
            tolerations = [
              {
                key      = "karpenter"
                operator = "Exists"
                effect   = "NoSchedule"
              }
            ]
            topologySpreadConstraints = [
              {
                maxSkew           = 1
                topologyKey       = "topology.kubernetes.io/zone"
                whenUnsatisfiable = "DoNotSchedule"
                labelSelector = {
                  matchLabels = {
                    "app.kubernetes.io/name" = "ecsdemo-frontend"
                  }
                }
              }
            ]
          }
        }
      }
    }
  }

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}


data "aws_partition" "current" {}

# Find the user currently in use by AWS
data "aws_caller_identity" "current" {}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:${var.vpc_tag_key}"
    values = [local.tag_val_vpc]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:${var.vpc_tag_key}"
    values = ["${local.tag_val_private_subnet}*"]
  }
}

# Create Sub HostedZone four our deployment
data "aws_route53_zone" "sub" {
  name = "${var.core_stack_name}.${var.hosted_zone_name}"
}


data "aws_secretsmanager_secret" "argocd" {
  name = "${local.argocd_secret_manager_name}.${local.core_stack_name}"
}

data "aws_secretsmanager_secret_version" "admin_password_version" {
  secret_id = data.aws_secretsmanager_secret.argocd.id
}

module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.25.0"

  cluster_name = local.name

  # EKS Cluster VPC and Subnet mandatory config
  vpc_id             = data.aws_vpc.vpc.id
  private_subnet_ids = data.aws_subnets.private.ids

  # EKS CONTROL PLANE VARIABLES
  cluster_version = local.cluster_version

  # List of map_roles
  map_roles = [
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.service_instance.inputs.eks_admin_role_name}" # The ARN of the IAM role
      username = "ops-role"                                                                                                            # The user name within Kubernetes to map to the IAM role
      groups   = ["system:masters"]                                                                                                    # A list of groups within Kubernetes to which the role is mapped; Checkout K8s Role and Rolebindings
    }
  ]

  # EKS MANAGED NODE GROUPS
  managed_node_groups = {
    mg_5 = {
      node_group_name = local.node_group_name
      instance_types  = ["m5.large"]
      min_size        = 3
      subnet_ids      = data.aws_subnets.private.ids
    }
  }

  platform_teams = {
    admin = {
      users = [
        data.aws_caller_identity.current.arn,
        "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:user/${var.service_instance.inputs.iam_platform_user}",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.service_instance.inputs.eks_admin_role_name}"
      ]
    }
  }

  application_teams = {
    team-platform = {
      "labels" = {
        "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled",
        "appName"                                 = "platform-team-app",
        "projectName"                             = "project-platform",
      }
      "quota" = {
        "requests.cpu"    = "10000m",
        "requests.memory" = "20Gi",
        "limits.cpu"      = "20000m",
        "limits.memory"   = "50Gi",
        "pods"            = "10",
        "secrets"         = "10",
        "services"        = "10"
      }
      ## Manifests Example: we can specify a directory with kubernetes manifests that can be automatically applied in the team-riker namespace.
      manifests_dir = "./kubernetes/team-platform/"
      users         = [data.aws_caller_identity.current.arn]
    }

    team-burnham = {
      "labels" = {
        "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled",
        "appName"                                 = "burnham-team-app",
        "projectName"                             = "project-burnham",
        "environment"                             = "dev",
        "domain"                                  = "example",
        "uuid"                                    = "example",
        "billingCode"                             = "example",
        "branch"                                  = "example"
      }
      "quota" = {
        "requests.cpu"    = "20k",
        "requests.memory" = "20000Gi",
        "limits.cpu"      = "40k",
        "limits.memory"   = "50000Gi",
        "pods"            = "10k",
        "secrets"         = "10k",
        "services"        = "10k"
      }
      ## Manifests Example: we can specify a directory with kubernetes manifests that can be automatically applied in the team-riker namespace.
      manifests_dir = "./kubernetes/team-burnham/"
      users         = [data.aws_caller_identity.current.arn]
    }

    team-riker = {
      "labels" = {
        "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled",
        "appName"                                 = "riker-team-app",
        "projectName"                             = "project-riker",
        "environment"                             = "dev",
        "domain"                                  = "example",
        "uuid"                                    = "example",
        "billingCode"                             = "example",
        "branch"                                  = "example"
      }
      "quota" = {
        "requests.cpu"    = "10000m",
        "requests.memory" = "20Gi",
        "limits.cpu"      = "20000m",
        "limits.memory"   = "50Gi",
        "pods"            = "10",
        "secrets"         = "10",
        "services"        = "10"
      }
      ## Manifests Example: we can specify a directory with kubernetes manifests that can be automatically applied in the team-riker namespace.
      manifests_dir = "./kubernetes/team-riker/"
      users         = [data.aws_caller_identity.current.arn]
    }


    ecsdemo-frontend = {
      "labels" = {
        "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled",
        "appName"                                 = "ecsdemo-frontend-app",
        "projectName"                             = "ecsdemo-frontend",
        "environment"                             = "dev",
      }
      #don't use quotas here cause ecsdemo app does not have request/limits 
      "quota" = {
        "requests.cpu"    = "100",
        "requests.memory" = "20Gi",
        "limits.cpu"      = "200",
        "limits.memory"   = "50Gi",
        "pods"            = "100",
        "secrets"         = "10",
        "services"        = "20"
      }
      ## Manifests Example: we can specify a directory with kubernetes manifests that can be automatically applied in the team-riker namespace.
      manifests_dir = "./kubernetes/ecsdemo-frontend/"
      users         = [data.aws_caller_identity.current.arn]
    }
    ecsdemo-nodejs = {
      "labels" = {
        "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled",
        "appName"                                 = "ecsdemo-nodejs-app",
        "projectName"                             = "ecsdemo-nodejs",
        "environment"                             = "dev",
      }
      #don't use quotas here cause ecsdemo app does not have request/limits 
      "quota" = {
        "requests.cpu"    = "10000m",
        "requests.memory" = "20Gi",
        "limits.cpu"      = "20000m",
        "limits.memory"   = "50Gi",
        "pods"            = "10",
        "secrets"         = "10",
        "services"        = "10"
      }
      ## Manifests Example: we can specify a directory with kubernetes manifests that can be automatically applied in the team-riker namespace.
      manifests_dir = "./kubernetes/ecsdemo-nodejs"
      users         = [data.aws_caller_identity.current.arn]
    }
    ecsdemo-crystal = {
      "labels" = {
        "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled",
        "appName"                                 = "ecsdemo-crystal-app",
        "projectName"                             = "ecsdemo-crystal",
        "environment"                             = "dev",
      }
      #don't use quotas here cause ecsdemo app does not have request/limits 
      "quota" = {
        "requests.cpu"    = "10000m",
        "requests.memory" = "20Gi",
        "limits.cpu"      = "20000m",
        "limits.memory"   = "50Gi",
        "pods"            = "10",
        "secrets"         = "10",
        "services"        = "10"
      }
      ## Manifests Example: we can specify a directory with kubernetes manifests that can be automatically applied in the team-riker namespace.
      manifests_dir = "./kubernetes/ecsdemo-crystal"
      users         = [data.aws_caller_identity.current.arn]
    }
  }


  tags = local.tags
}



#resource "aws_route53_zone" "main" {
data "aws_route53_zone" "main" {
  name = var.service_instance.inputs.eks_cluster_domain
}


#---------------------------------------------------------------
# ArgoCD Admin Password credentials with Secrets Manager
# Login to AWS Secrets manager with the same role as Terraform to extract the ArgoCD admin password with the secret name as "argocd"
#---------------------------------------------------------------
resource "random_password" "argocd" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

#tfsec:ignore:aws-ssm-secret-use-customer-key
resource "aws_secretsmanager_secret" "arogcd" {
  name                    = "${local.argocd_secret_manager_name}.${local.name}"
  recovery_window_in_days = 0 # Set to zero for this example to force delete during Terraform destroy
}

resource "aws_secretsmanager_secret_version" "arogcd" {
  secret_id     = aws_secretsmanager_secret.arogcd.id
  secret_string = random_password.argocd.result
}

data "aws_secretsmanager_secret_version" "admin_password_version" {
  secret_id = aws_secretsmanager_secret.arogcd.id

  depends_on = [aws_secretsmanager_secret_version.arogcd]
}

# Add the following to the bottom of main.tf

module "kubernetes_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.25.0/modules/kubernetes-addons"

  eks_cluster_id     = module.eks_blueprints.eks_cluster_id
  eks_cluster_domain = var.service_instance.inputs.eks_cluster_domain

  #---------------------------------------------------------------
  # ARGO CD ADD-ON
  #---------------------------------------------------------------

  enable_argocd         = true
  argocd_manage_add_ons = true # Indicates that ArgoCD is responsible for managing/deploying Add-ons.

  argocd_applications = {
    addons    = local.addon_application
    workloads = local.workload_application
    ecsdemo   = local.ecsdemo_application
  }

  # This example shows how to set default ArgoCD Admin Password using SecretsManager with Helm Chart set_sensitive values.
  argocd_helm_config = {
    set_sensitive = [
      {
        name  = "configs.secret.argocdServerAdminPassword"
        value = bcrypt(data.aws_secretsmanager_secret_version.admin_password_version.secret_string)
      }
    ]
    # To have additional LB for Argo
    set = [
      {
        name  = "server.service.type"
        value = "LoadBalancer"
      }
    ]
  }

  #---------------------------------------------------------------
  # EKS Managed AddOns
  # https://aws-ia.github.io/terraform-aws-eks-blueprints/add-ons/
  #---------------------------------------------------------------

  enable_amazon_eks_coredns = true
  amazon_eks_coredns_config = {
    most_recent        = true
    kubernetes_version = local.cluster_version
    resolve_conflicts  = "OVERWRITE"
  }

  enable_amazon_eks_aws_ebs_csi_driver = true
  amazon_eks_aws_ebs_csi_driver_config = {
    most_recent        = true
    kubernetes_version = local.cluster_version
    resolve_conflicts  = "OVERWRITE"
  }

  enable_amazon_eks_kube_proxy = true
  amazon_eks_kube_proxy_config = {
    most_recent        = true
    kubernetes_version = local.cluster_version
    resolve_conflicts  = "OVERWRITE"
  }

  enable_amazon_eks_vpc_cni = true
  amazon_eks_vpc_cni_config = {
    most_recent        = true
    kubernetes_version = local.cluster_version
    resolve_conflicts  = "OVERWRITE"
  }

  #---------------------------------------------------------------
  # ADD-ONS - You can add additional addons here
  # https://aws-ia.github.io/terraform-aws-eks-blueprints/add-ons/
  #---------------------------------------------------------------

  enable_metrics_server               = var.service_instance.inputs.metrics_server
  enable_aws_load_balancer_controller = var.service_instance.inputs.aws_load_balancer_controller
  aws_load_balancer_controller_helm_config = {
    service_account = "aws-lb-sa"
  }
  enable_karpenter              = var.service_instance.inputs.karpenter
  enable_aws_for_fluentbit      = var.service_instance.inputs.aws_for_fluentbit
  enable_cert_manager           = var.service_instance.inputs.cert_manager
  enable_aws_cloudwatch_metrics = var.service_instance.inputs.cloudwatch_metrics


  enable_external_dns = var.service_instance.inputs.external_dns
  external_dns_helm_config = {
    txtOwnerId   = local.name
    zoneIdFilter = data.aws_route53_zone.sub.zone_id # Note: this uses GitOpsBridge
    policy       = "sync"
    logLevel     = "debug"
  }



  enable_vpa           = var.service_instance.inputs.vpa
  enable_kubecost      = var.service_instance.inputs.kubecost
  enable_argo_rollouts = var.service_instance.inputs.argo_rollouts


}


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  #version = "v3.2.0"
  version = "~> 3.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  create_igw           = true
  enable_dns_hostnames = true
  single_nat_gateway   = true

  # Manage so we can name
  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${local.name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${local.name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.name}-default" }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/elb"              = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/internal-elb"     = "1"
  }

  tags = local.tags
}