

format:
	terraform fmt

check:
	terraform fmt -diff -check


verify:
	cp sample.service_instance.variables.tf.local sample.service_instance.variables.tf
	terraform init -backend=false -upgrade
	terraform validate -no-color