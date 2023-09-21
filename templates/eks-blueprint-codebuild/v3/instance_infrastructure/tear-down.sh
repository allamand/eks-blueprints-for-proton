#!/bin/bash
#set -e
set -x

# Get the directory of the currently executing script (shell1.sh)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

{ "$SCRIPT_DIR/tear-down-applications.sh"; } || {
  echo "Error occurred while deleting application"

  # Ask the user if they want to continue
  read -p "Do you want to continue with cluster deletion (y/n)? " choice
  case "$choice" in
    y|Y ) echo "Continuing with the rest of shell1.sh";;
    * ) echo "Exiting.."; exit;;
  esac
}


#terraform destroy -target="module.eks_cluster.module.gitops_bridge_bootstrap" -auto-approve

# Then Tear down the cluster
terraform destroy -var-file=proton-inputs.json -var="aws_region=${AWS_REGION}" -target="module.eks_cluster.module.kubernetes_addons" -auto-approve || (echo "error deleting module.eks_cluster.module.kubernetes_addons")
terraform destroy -var-file=proton-inputs.json -var="aws_region=${AWS_REGION}" -target="module.eks_cluster.module.eks_blueprints_platform_teams" -auto-approve || (echo "error deleting module.eks_cluster.module.eks_blueprints_platform_teams")
terraform destroy -var-file=proton-inputs.json -var="aws_region=${AWS_REGION}" -target="module.eks_cluster.module.eks_blueprints_dev_teams" -auto-approve || (echo "error deleting module.eks_cluster.module.eks_blueprints_dev_teams")
terraform destroy -var-file=proton-inputs.json -var="aws_region=${AWS_REGION}" -target="module.eks_cluster.module.eks_blueprints_ecsdemo_teams" -auto-approve || (echo "error deleting module.eks_cluster.module.eks_blueprints_ecsdemo_teams")

terraform destroy -var-file=proton-inputs.json -var="aws_region=${AWS_REGION}" -target="module.eks_cluster.module.gitops_bridge_bootstrap" -auto-approve || (echo "error deleting module.eks_cluster.module.gitops_bridge_bootstrap")
terraform destroy -var-file=proton-inputs.json -var="aws_region=${AWS_REGION}" -target="module.eks_cluster.module.gitops_bridge_metadata" -auto-approve || (echo "error deleting module.eks_cluster.module.gitops_bridge_metadata")

terraform destroy -var-file=proton-inputs.json -var="aws_region=${AWS_REGION}" -target="module.eks_cluster.module.eks_blueprints_addons" -auto-approve || (echo "error deleting module.eks_cluster.module.eks")

terraform destroy -var-file=proton-inputs.json -var="aws_region=${AWS_REGION}" -target="module.eks_cluster.module.ebs_csi_driver_irsa" --auto-approve
terraform destroy -var-file=proton-inputs.json -var="aws_region=${AWS_REGION}" -target="module.eks_cluster.module.vpc_cni_irsa" --auto-approve
terraform destroy -var-file=proton-inputs.json -var="aws_region=${AWS_REGION}" -target="module.eks_cluster.module.eks" -auto-approve || (echo "error deleting module.eks_cluster.module.eks")

terraform destroy -var-file=proton-inputs.json -var="aws_region=${AWS_REGION}" -auto-approve || (echo "error deleting terraform" && exit -1)

echo "Tear Down OK"
set +x
