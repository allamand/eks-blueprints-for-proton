
#First Assume role for Proton Role
#export $(printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s" \
$(aws sts assume-role \
--role-arn arn:aws:iam::${ACCOUNT_ID}:role/AWSProtonCodeBuildProvisioning \
--role-session-name MySessionName \
--query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" \
--output text))

#export $(printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s" \
$(aws sts assume-role \
--role-arn arn:aws:iam::382076407153:role/GitHubAppRunner-Terraform \
--role-session-name MySessionName \
--query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" \
--output text))


format:
	terraform fmt

check:
	terraform fmt -diff -check

applications != kubectl get applications -n argocd -o json  | jq ".items[].metadata.name" -r | grep -v addons

clean:
	kubectl patch -n argocd applications $(applications) -p '{"metadata":{"finalizers":null}}' --type=merge

clean-finalizers:
	echo $(applications)
  #echo "kubectl patch -n argocd applications $(applications) -p '{\"metadata\":{\"finalizers\":null}}' --type=merge"
	res=$(shell kubectl patch -n argocd applications $(applications) -p '{"metadata":{"finalizers":null}}' --type=merge) ; \
	echo $$res

verify:
	cp sample.service_instance.variables.tf.local sample.service_instance.variables.tf
	terraform init -backend=false -upgrade
	terraform validate -no-color

PROTON_INPUTS?=proton-inputs-purple.json

PROTON_ENV != cat $(PROTON_INPUTS) | jq '.environment.name' -r
AWS_REGION != cat $(PROTON_INPUTS) | jq '.environment.outputs.aws_region' -r
TF_STATE_BUCKET != cat $(PROTON_INPUTS) | jq '.environment.outputs.tf_state_bucket' -r
TF_STATE_BUCKET_REGION != cat $(PROTON_INPUTS) | jq '.environment.outputs.tf_state_bucket_region' -r
PROTON_SVC != cat $(PROTON_INPUTS) | jq '.service.name' -r
PROTON_SVC_INSTANCE != cat $(PROTON_INPUTS) | jq '.service_instance.name' -r
KEY=$(PROTON_ENV).$(PROTON_SVC).$(PROTON_SVC_INSTANCE)

print:
	@echo PROTON_ENV=$(PROTON_ENV) AWS_REGION=$(AWS_REGION) TF_STATE_BUCKET=$(TF_STATE_BUCKET) TF_STATE_BUCKET_REGION=$(TF_STATE_BUCKET_REGION) PROTON_SVC=$(PROTON_SVC) PROTON_SVC_INSTANCE=$(PROTON_SVC_INSTANCE) KEY=$(KEY)

init: print
	terraform init -backend-config="bucket=$(TF_STATE_BUCKET)" -backend-config="key=$(KEY).tfstate" -backend-config="region=$(TF_STATE_BUCKET_REGION)" -upgrade -reconfigure

apply: print
	terraform apply -var-file=$(PROTON_INPUTS) -var="aws_region=$(AWS_REGION)"

destroy: print
	terraform destroy -var-file=$(PROTON_INPUTS) -var="aws_region=$(AWS_REGION)"


plan: #set-local-service
	terraform plan -var-file=$(PROTON_INPUTS) -var="aws_region=$(AWS_REGION)"


