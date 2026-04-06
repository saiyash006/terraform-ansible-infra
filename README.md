# Infrastructure Provisioning & Configuration with Terraform + Ansible

Fully reproducible AWS infrastructure (VPC, subnets, EC2, security groups) is provisioned with Terraform, while Ansible applies server configuration (users, Nginx, static app deploy). End-to-end setup completes in minutes with IaC + automation.

## Repo structure
- `terraform/` – VPC, networking, security group, and EC2 definitions.
- `ansible/` – Playbooks and roles for user management, Nginx, and app deployment.

## Prerequisites
- Terraform v1.6+ and Ansible v2.16+ installed locally.
- AWS credentials exported (e.g., `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`) with permissions for VPC/EC2.
- An SSH key in AWS named the same as `var.key_name` (default `terraform-ansible-demo`) and the corresponding private key available locally.

## Terraform: provision infrastructure
```bash
cd terraform
terraform init
terraform apply -auto-approve
```
Key variables (override via `-var` or `.tfvars`):
- `region` (default `us-east-1`)
- `vpc_cidr` (default `10.0.0.0/16`)
- `public_subnet_cidrs` (defaults to two /24s)
- `instance_type` (default `t3.micro`)
- `key_name` (existing AWS key pair name)
- `ssh_ingress_cidr` (default `0.0.0.0/0`)

Outputs:
- Public IPs of EC2 hosts for Ansible
- VPC, subnet, and security group IDs

## Ansible: configure servers
1) Export the Terraform output host into inventory:
```bash
cd ../ansible
terraform -chdir=../terraform output -json public_ips \
  | jq -r '.[]' \
  | sed 's/^/web ansible_host=/' > inventory.ini
```
2) Run the playbook (uses user `ubuntu` for the Ubuntu AMI):
```bash
ansible-playbook -i inventory.ini site.yml
```

What it does:
- Creates a `deploy` user with passwordless sudo and SSH key (set `deploy_authorized_key`).
- Installs and configures Nginx to serve a static app at `/var/www/app`.
- Deploys a simple app landing page with customizable content (`app_title`, `app_body`).

## Cleanup
```bash
cd terraform
terraform destroy -auto-approve
```

## Notes
- Terraform user data installs Python on first boot so Ansible can run immediately.
- Security group allows SSH (22) and HTTP (80); tighten `ssh_ingress_cidr` as needed.
