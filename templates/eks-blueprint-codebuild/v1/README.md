aws proton get-environment-template-version \
 --template-name "core-infra" \
 --major-version "1" \
 --minor-version "0"

SERVICE_NAME=eks-blueprint-seb
aws proton create-service-template   --region ${AWS_REGION}   --name ${SERVICE_NAME}   --display-name "EKS Blueprint cluster"   --description "Create EKS bluepribnt cluster"  --pipeline-provisioning "CUSTOMER_MANAGED"

aws proton delete-service-template   --region ${AWS_REGION}   --name ${SERVICE_NAME}

aws proton list-service-template-versions --template-name eks-blueprint-seb

aws proton get-service-template-version \
 --template-name "eks-blueprint-seb" \
 --major-version "1" \
 --minor-version "2"



act pull_request -v -P ubuntu-latest=ghcr.io/catthehacker/ubuntu:act-22.04 -j test_github_output

act -l
act -n
act pull_request -v -s GITHUB_TOKEN=$GITHUB_TOKEN