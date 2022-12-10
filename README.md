# jenkins_jcasc
Deployment of Jenkins (jcasc) server on AWS or Oracle Cloud (Always Free)

## AWS:
### Prereq:
- TLS certificate(aws) + DNS record on route53
### Install
- make aws - (provision infrastructure and jenkins server)
- make aws_plan - (terraform plan for aws infrastructure)
- make aws_destroy - (terraform destroy for aws infrastructure)
## OCI:
- make oci
- make oci_plan
- make oci_destroy
