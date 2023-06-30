#!/bin/bsh

SCRIPT_DIR=~/environment/proton/eks-blueprints-for-proton/scripts/bash/

setup_aws_credentials() {
  # Find the path to the env_config.json file
  CONFIG_FILE="$SCRIPT_DIR../../env_config.json"

  # Check if the config file exists
  if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: env_config.json file not found. in $CONFIG_FILE"
    return 1
  fi
  # Read role ARN from the file
  PLATFORM_ROLE_ARN=$(jq '.[].role' -r "$CONFIG_FILE")
  echo "PLATFORM_ROLE_ARN is $PLATFORM_ROLE_ARN"

  # Assume the role
  CREDENTIALS=$(aws sts assume-role --duration-seconds 3600 --role-arn "$PLATFORM_ROLE_ARN" --role-session-name eks)
  # Set the AWS credentials as environment variables
  export AWS_ACCESS_KEY_ID=$(echo "$CREDENTIALS" | jq -r '.Credentials.AccessKeyId')
  export AWS_SECRET_ACCESS_KEY=$(echo "$CREDENTIALS" | jq -r '.Credentials.SecretAccessKey')
  export AWS_SESSION_TOKEN=$(echo "$CREDENTIALS" | jq -r '.Credentials.SessionToken')
  export AWS_EXPIRATION=$(echo "$CREDENTIALS" | jq -r '.Credentials.Expiration')

  # Verify the AWS identity after assuming the role
  #aws sts get-caller-identity
}


configure_terraform_init()
{
  export PROTON_ENV=$(cat proton-inputs.json | jq '.environment.name' -r)
  export AWS_REGION=$(cat proton-inputs.json | jq '.environment.outputs.aws_region' -r)
  export TF_STATE_BUCKET=$(cat proton-inputs.json | jq '.environment.outputs.tf_state_bucket' -r)
  export TF_STATE_BUCKET_REGION=$(cat proton-inputs.json | jq '.environment.outputs.tf_state_bucket_region' -r)
  export PROTON_SVC=$(cat proton-inputs.json | jq '.service.name' -r)
  export PROTON_SVC_INSTANCE=$(cat proton-inputs.json | jq '.service_instance.name' -r)
  export KEY=${PROTON_ENV}.${PROTON_SVC}.${PROTON_SVC_INSTANCE}
  [[ -z $PROTON_ENV || -z $PROTON_SVC || -z $PROTON_SVC_INSTANCE ]] && echo "Error: One or more variables are missing or empty" && return 1
  set -x
  terraform init -backend-config="bucket=${TF_STATE_BUCKET}" -backend-config="region=${TF_STATE_BUCKET_REGION}" -backend-config="key=${KEY}.tfstate"
  set +x
}