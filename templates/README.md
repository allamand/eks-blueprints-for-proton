# Execute it locally (simulate proton codebuild)

## For Environment

```
export PROTON_ENV=$(cat proton-inputs.json | jq '.environment.name' -r)
export AWS_REGION=$(cat proton-inputs.json | jq '.environment.inputs.aws_region' -r)
export TF_STATE_BUCKET=$(cat proton-inputs.json | jq '.environment.inputs.tf_state_bucket' -r)
export TF_STATE_BUCKET_REGION=$(cat proton-inputs.json | jq '.environment.inputs.tf_state_bucket_region' -r)
echo PROTON_ENV=$PROTON_ENV AWS_REGION=$AWS_REGION TF_STATE_BUCKET=$TF_STATE_BUCKET TF_STATE_BUCKET_REGION=$TF_STATE_BUCKET_REGION
```




terraform destroy -var-file=proton-inputs.json -var="aws_region=${AWS_REGION}"
```
