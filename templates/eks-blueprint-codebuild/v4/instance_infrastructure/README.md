## Troubleshoot

### Building Infrastructure as code

If you want you can go to the template environment directory and then point to the Terraform S3 bucket state:

> You first need to create the proton-inputs.json file as it will be created by AWS Proton. You can either find the content of the file in the CodeBuild logs as it is printed there, or you can recompute one from the `proton-inputs-example.json` file.

First Source helping script
```bash
source ../../../../scripts/bash/functions.sh
```

Then configure terraform
```bash
configure_terraform_init
```

Then you can work locally if you have enough IAM rights to create associated AWS ressources.
For doing that, you can assume the role you define in the env_config.json


Retrieve Credentials used by the AWS Proton CodeBuild pipeline (GitHubAppRunner-Terraform)

```bash
setup_aws_credentials
```

Deploy

```bash
terraform apply -var-file=proton-inputs.json -var="aws_region=${AWS_REGION}" -auto-approve
```

### Configuring Argo CLI

```bash
export ARGO_SERVER=$(kubectl get svc -n argocd -l app.kubernetes.io/name=argocd-server -o name)
echo $ARGO_SERVER
#export ARGO_PASSWORD=$(kubectl -n argocd get secret argocd-secret -o jsonpath="{.data.admin.password}" | base64 -d)
export ARGO_PASSWORD=$(aws secretsmanager get-secret-value --secret-id argo-admin-secret.proton-green --query SecretString --output text --region eu-west-1)
echo $ARGO_PASSWORD
```

and then login with the cli

```bash
kubectl port-forward $ARGO_SERVER -n argocd 8080:443
export ARGO_URL=argocd.proton-blue.eks.demo3.allamand.com
export ARGO_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo $ARGO_PASSWORD
#export ARGO_URL=localhost:8080
argocd login --grpc-web $ARGO_URL --username admin --password $ARGO_PASSWORD
```

Create a project in Argo

```bash
argocd proj create sample \
    -d https://kubernetes.default.svc,argocd \
    -s https://github.com/aws-samples/eks-blueprints-workloads.git
```

Create the application with Argo bu running

```bash
argocd app create dev-apps \
    --dest-namespace argocd  \
    --dest-server https://kubernetes.default.svc  \
    --repo https://github.com/aws-samples/eks-blueprints-workloads.git \
    --path "envs/dev"
```

Sync the apps

```bash
argocd app list
argocd proj list
argocd app sync dev-apps
```

Before deleting the stack:

- delete your Argocd workloads

```bash
argocd --grpc-web app delete workloads
argocd --grpc-web app delete ecsdemo
```

Wait few minutes for all aWS ressources to be cleaned up by respectives controllers (load balancer, karpenter nodes..)

```bash
#terraform apply -destroy -target="module.argocd_addons" -auto-approve -var="aws_region=$AWS_REGION"
githubRole

terraform apply -destroy -target="module.kubernetes_addons" -auto-approve -var="aws_region=$AWS_REGION"
#terraform apply -destroy -target="module.aws_controllers" -auto-approve -var="aws_region=$AWS_REGION"

terraform apply -destroy -target="module.eks_blueprints" -auto-approve -var="aws_region=$AWS_REGION"

terraform apply -destroy -auto-approve -var="aws_region=$AWS_REGION"
```
