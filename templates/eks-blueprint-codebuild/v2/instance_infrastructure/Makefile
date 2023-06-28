SHELL := /bin/bash
.ONESHELL:

.PHONY: format check clean clean-finalizers verify apply destroy plan print setup-credentials

format:
	terraform fmt

check:
	terraform fmt -diff -check

applications != kubectl get applications -n argocd -o json | jq ".items[].metadata.name" -r | grep -v addons

clean:
	kubectl patch -n argocd applications $(applications) -p '{"metadata":{"finalizers":null}}' --type=merge

clean-finalizers:
	echo $(applications)
	#echo "kubectl patch -n argocd applications $(applications) -p '{\"metadata\":{\"finalizers\":null}}' --type=merge"
	res=$$(kubectl patch -n argocd applications $(applications) -p '{"metadata":{"finalizers":null}}' --type=merge)
	echo $$res

verify:
	terraform validate -no-color

## Load Environment ##
PROTON_INPUTS?=proton-inputs.json
PROTON_ENV != cat $(PROTON_INPUTS) | jq '.environment.name' -r
AWS_REGION != cat $(PROTON_INPUTS) | jq '.environment.outputs.aws_region' -r
TF_STATE_BUCKET != cat $(PROTON_INPUTS) | jq '.environment.outputs.tf_state_bucket' -r
TF_STATE_BUCKET_REGION != cat $(PROTON_INPUTS) | jq '.environment.outputs.tf_state_bucket_region' -r
PROTON_SVC != cat $(PROTON_INPUTS) | jq '.service.name' -r
PROTON_SVC_INSTANCE != cat $(PROTON_INPUTS) | jq '.service_instance.name' -r
KEY=$(PROTON_ENV).$(PROTON_SVC).$(PROTON_SVC_INSTANCE)

load-functions:
	@source ../../../../scripts/bash/functions.sh && declare -F && setup_aws_credentials
	@aws sts get-caller-identity

print: load-functions
	@echo PROTON_ENV=$(PROTON_ENV) AWS_REGION=$(AWS_REGION) TF_STATE_BUCKET=$(TF_STATE_BUCKET) TF_STATE_BUCKET_REGION=$(TF_STATE_BUCKET_REGION) PROTON_SVC=$(PROTON_SVC) PROTON_SVC_INSTANCE=$(PROTON_SVC_INSTANCE) KEY=$(KEY)

init: print
	@source ../../../../scripts/bash/functions.sh && declare -F && setup_aws_credentials
	terraform init -backend-config="bucket=$(TF_STATE_BUCKET)" -backend-config="key=$(KEY).tfstate" -backend-config="region=$(TF_STATE_BUCKET_REGION)" -upgrade -reconfigure

apply: load-functions print
	@source ../../../../scripts/bash/functions.sh && declare -F && setup_aws_credentials
	terraform apply -var-file=$(PROTON_INPUTS) -var="aws_region=$(AWS_REGION)"

destroy: load-functions
	@source ../../../../scripts/bash/functions.sh && declare -F && setup_aws_credentials
	terraform destroy -var-file=$(PROTON_INPUTS) -var="aws_region=$(AWS_REGION)"

plan:
	@source ../../../../scripts/bash/functions.sh && declare -F && setup_aws_credentials
	terraform plan -var-file=$(PROTON_INPUTS) -var="aws_region=$(AWS_REGION)"

output:
	@source ../../../../scripts/bash/functions.sh && declare -F && setup_aws_credentials
	terraform output

setup-credentials:
	source ../../../../scripts/bash/functions.sh && setup_aws_credentials
	export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_EXPIRATION


plan2: setup-credentials load-functions
	terraform plan -var-file=$(PROTON_INPUTS) -var="aws_region=$(AWS_REGION)"
