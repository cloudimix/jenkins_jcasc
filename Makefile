#!/bin/bash

.PHONY: infrastructure
infrastructure:
	ansible-playbook id_rsa_generating.yaml
	terraform init
	terraform apply --auto-approve -lock=false
	terraform apply --auto-approve -lock=false
	if [ ! -f ~/.vault_pass ]; then echo testpass > ~/.vault_pass; fi
	ansible-galaxy install -r requirements.yaml
	ansible-playbook -i dynamic_inventory.py ssh_port_check.yaml
	ansible-playbook -i dynamic_inventory.py volume_mount.yaml

.PHONY: docker
docker:
	ansible-playbook dockcomp_gen.yaml
	ansible-playbook -i dynamic_inventory.py play_docker_install_role.yaml -vv

.PHONY: jcasc
jcasc:
	ansible-playbook -i dynamic_inventory.py jenkins_files_copy.yaml -vv
	ansible-playbook -i dynamic_inventory.py jenkins_DC_up_build.yaml -vv

all: infrastructure docker jcasc
