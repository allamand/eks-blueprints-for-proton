aws proton get-environment-template-version \
 --template-name "core-infra" \
 --major-version "1" \
 --minor-version "0"

SERVICE_NAME=eks-blueprint-codebuild
aws proton create-service-template --region ${AWS_REGION} --name ${SERVICE_NAME} --display-name "EKS Blueprint cluster Deployed with CodeBuild" --description "Create EKS bluepribnt cluster deployed with CodeBuild" --pipeline-provisioning "CUSTOMER_MANAGED"

aws proton delete-service-template --region ${AWS_REGION} --name ${SERVICE_NAME}

aws proton list-service-template-versions --template-name ${SERVICE_NAME}

aws proton get-service-template-version \
 --template-name ${SERVICE_NAME} \
 --major-version "1" \
 --minor-version "2"

act pull_request -v -P ubuntu-latest=ghcr.io/catthehacker/ubuntu:act-22.04 -j test_github_output

act -l
act -n
act pull_request -v -s GITHUB_TOKEN=$GITHUB_TOKEN


File(s): [Pipeline manifest file] is/are missing or not in the correct directory.