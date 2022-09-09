## Troubleshoot

### Building Infrastructure as code

If you want you can go to the directory created by the Proton PR and then point to the Terraform S3 bucket state:

```bash
export TERRAFORM_BUCKET=$(cat ../env_config.json| jq ".[].state_bucket" -r)
export CLUSTER_NAME=$(cat proton.auto.tfvars.json | jq ".environment.name" -r)
echo "$CLUSTER_NAME for $TERRAFORM_BUCKET"
terraform init -backend-config="bucket=$TERRAFORM_BUCKET" -backend-config="key=$CLUSTER_NAME/terraform.tfstate" -backend-config="region=$AWS_REGION"
```

Then you can work locally if you have enough IAM rights to create associated AWS ressources.
For doing that, you can assume the role you define in the env_config.json

GitHubAppRunner-Terraform

```bash
PLATFORM_ROLE_ARN=$(cat ../env_config.json | jq '.[].role' -r)
echo "PLATFORM_ROLE_ARN is $PLATFORM_ROLE_ARN"
CREDENTIALS=$(aws sts assume-role --duration-seconds 3600 --role-arn $PLATFORM_ROLE_ARN --role-session-name eks)
export AWS_ACCESS_KEY_ID="$(echo ${CREDENTIALS} | jq -r '.Credentials.AccessKeyId')"
export AWS_SECRET_ACCESS_KEY="$(echo ${CREDENTIALS} | jq -r '.Credentials.SecretAccessKey')"
export AWS_SESSION_TOKEN="$(echo ${CREDENTIALS} | jq -r '.Credentials.SessionToken')"
export AWS_EXPIRATION=$(echo ${CREDENTIALS} | jq -r '.Credentials.Expiration')
aws sts get-caller-identity
```

Deploy

```bash
terraform apply -target="module.vpc" -auto-approve -var="aws_region=$AWS_REGION"
terraform apply -target="module.eks_blueprints" -auto-approve -var="aws_region=$AWS_REGION"
terraform apply -target="module.kubernetes_addons" -auto-approve -var="aws_region=$AWS_REGION"
terraform apply -auto-approve -var="aws_region=$AWS_REGION"
```

### Configuring Argo CLI

```bash
export ARGO_SERVER=$(kubectl get svc -n argocd -l app.kubernetes.io/name=argocd-server -o name)
echo $ARGO_SERVER
export ARGO_PASSWORD=$(kubectl -n argocd get secret argocd-secret -o jsonpath="{.data.admin.password}" | base64 -d)
echo $ARGO_PASSWORD
```

and then login with the cli

```bash
kubectl port-forward $ARGO_SERVER -n argocd 8080:443
export ARGO_URL=argocd.proton-blue.eks.demo3.allamand.com
export ARGO_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo $ARGO_PASSWORD
#export ARGO_URL=localhost:8080
argocd login $ARGO_URL --username admin --password $ARGO_PASSWORD
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
