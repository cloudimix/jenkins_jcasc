#!/bin/bash
.ONESHELL:

.PHONY: aws
aws:
	ansible-playbook id_rsa_generating.yaml
	cd aws/
	terraform init
	terraform apply --auto-approve
	cd ..
	ansible-galaxy install -r requirements.yaml
	ansible-playbook dockcomp_gen.yaml
	ansible-playbook -i dynamic_inventory_aws.py main.yaml
	make aws_output

.PHONY: oci
oci:
	ansible-playbook id_rsa_generating.yaml
	cd oci/
	terraform init
	terraform apply --auto-approve
	cd ..
	ansible-galaxy install -r requirements.yaml
	ansible-playbook dockcomp_gen.yaml
	ansible-playbook -i dynamic_inventory_oci.py main.yaml
	make oci_output

.PHONY: aws_output
aws_output:
	cd aws/
	terraform output

.PHONY: oci_output
oci_output:
	cd oci/
	terraform output

.PHONY: aws_plan
aws_plan:
	cd	aws/
	terraform init
	terraform plan

.PHONY: oci_plan
oci_plan:
	cd	oci/
	terraform init
	terraform plan

.PHONY: aws_destroy
aws_destroy:
	cd aws/
	terraform destroy

.PHONY: oci_destroy
oci_destroy:
	cd oci/
	terraform destroy
