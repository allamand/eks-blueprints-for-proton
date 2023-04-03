

format:
	terraform fmt

check:
	terraform fmt -diff -check


verify:
	cp sample.service_instance.variables.tf.local sample.service_instance.variables.tf
	terraform init -backend=false -upgrade
	terraform validate -no-color


set-local-service:
	export PROTON_ENV=$(shell cat proton-inputs.json | jq '.environment.name' -r) \
	&& export AWS_REGION=$(shell cat proton-inputs.json | jq '.environment.outputs.aws_region' -r) \
	&& export TF_STATE_BUCKET=$(shell cat proton-inputs.json | jq '.environment.outputs.tf_state_bucket' -r) \
	&& export TF_STATE_BUCKET_REGION=$(shell cat proton-inputs.json | jq '.environment.outputs.tf_state_bucket_region' -r) \
	&& export PROTON_SVC=$(shell cat proton-inputs.json | jq '.service.name' -r) \
	&& export PROTON_SVC_INSTANCE=$(shell cat proton-inputs.json | jq '.service_instance.name' -r) \
	&& export KEY=$$PROTON_ENV.$$PROTON_SVC.$$PROTON_SVC_INSTANCE \
	&& echo PROTON_ENV=$$PROTON_ENV AWS_REGION=$$AWS_REGION TF_STATE_BUCKET=$$TF_STATE_BUCKET TF_STATE_BUCKET_REGION=$$TF_STATE_BUCKET_REGION PROTON_SVC=$$PROTON_SVC PROTON_SVC_INSTANCE=$$PROTON_SVC_INSTANCE KEY=$$KEY \
	&& terraform init -backend-config="bucket=$$TF_STATE_BUCKET" -backend-config="key=$$KEY.tfstate" -backend-config="region=$$TF_STATE_BUCKET_REGION" -upgrade -reconfigure \
	&& echo PROTON_ENV=$$PROTON_ENV AWS_REGION=$$AWS_REGION TF_STATE_BUCKET=$$TF_STATE_BUCKET TF_STATE_BUCKET_REGION=$$TF_STATE_BUCKET_REGION PROTON_SVC=$$PROTON_SVC PROTON_SVC_INSTANCE=$$PROTON_SVC_INSTANCE KEY=$$KEY

apply: set-local-service
	echo PROTON_ENV=$$PROTON_ENV AWS_REGION=$$AWS_REGION TF_STATE_BUCKET=$$TF_STATE_BUCKET TF_STATE_BUCKET_REGION=$$TF_STATE_BUCKET_REGION PROTON_SVC=$$PROTON_SVC PROTON_SVC_INSTANCE=$$PROTON_SVC_INSTANCE KEY=$$KEY
	terraform apply -var-file=proton-inputs.json -var="aws_region=$$AWS_REGION"

destroy: set-local-service
	echo PROTON_ENV=$$PROTON_ENV AWS_REGION=$$AWS_REGION TF_STATE_BUCKET=$$TF_STATE_BUCKET TF_STATE_BUCKET_REGION=$$TF_STATE_BUCKET_REGION PROTON_SVC=$$PROTON_SVC PROTON_SVC_INSTANCE=$$PROTON_SVC_INSTANCE KEY=$$KEY
	terraform destroy -var-file=proton-inputs.json -var="aws_region=$$AWS_REGION"


plan: #set-local-service
	echo PROTON_ENV=$$PROTON_ENV AWS_REGION=$$AWS_REGION TF_STATE_BUCKET=$$TF_STATE_BUCKET TF_STATE_BUCKET_REGION=$$TF_STATE_BUCKET_REGION PROTON_SVC=$$PROTON_SVC PROTON_SVC_INSTANCE=$$PROTON_SVC_INSTANCE KEY=$$KEY
	terraform plan -var-file=proton-inputs.json -var="aws_region=$$AWS_REGION"


