# FARMERPRO-APP

Normalized monorepo layout for FARMERPRO microservices with CI/CD, infrastructure, and deployment automation.

## Repository Structure

```text
FARMERPRO-APP/
├── services/
├── ci-cd/
│   ├── jenkins/
│   └── github-actions/
├── infrastructure/
│   ├── terraform/
│   └── ansible/
├── kubernetes/
│   ├── deployments/
│   ├── services/
│   └── ingress/
├── docker/
│   └── Dockerfiles/
└── scripts/
```

## What Was Added

- `ci-cd/jenkins/Jenkinsfile`: dynamic service discovery in `services/` + Maven build/test + Docker push.
- `ci-cd/github-actions/pipeline.yml`: matrix CI/CD based on discovered services.
- `infrastructure/terraform/*`: AWS VPC + subnet + routing + security group + EC2 app servers.
- `infrastructure/ansible/*`: server configuration and deployment automation.
- `kubernetes/*`: deployment/service/ingress starter manifests.
- `docker/Dockerfiles/Dockerfile.springboot`: standard Java container image template.
- `scripts/sync-structure.ps1` and `scripts/sync-structure.sh`: automatic structure synchronization.

## Service Catalog Refresh

Use one command to refresh `services/` metadata from the canonical monorepo layout:

```powershell
./scripts/sync-structure.ps1
```

Linux/macOS:

```bash
chmod +x ./scripts/sync-structure.sh
./scripts/sync-structure.sh
```

## Terraform (AWS)

1. Copy variables template:

```bash
cp infrastructure/terraform/terraform.tfvars.example infrastructure/terraform/terraform.tfvars
```

1. Fill in the sanitized placeholders in `infrastructure/terraform/terraform.tfvars`:

```text
ami_id      -> your target AMI for the chosen AWS region
key_name    -> the name of an existing EC2 key pair in your account
ssh_cidrs   -> your trusted admin IP ranges, for example ["203.0.113.10/32"]
```

Do not commit machine-specific values back to Git. Keep real values only in your local `terraform.tfvars`.

1. Deploy:

```bash
cd infrastructure/terraform
terraform init
terraform plan
terraform apply
```

## Ansible (AWS server configuration)

1. Copy inventory template and update hosts:

```bash
cp infrastructure/ansible/inventory.ini.example infrastructure/ansible/inventory.ini
```

1. Replace the sanitized placeholders in `infrastructure/ansible/inventory.ini`:

```text
YOUR_SERVER_IP         -> public IP or DNS name of the target host
YOUR_SECOND_SERVER_IP  -> optional second host
/root/.ssh/ansible_key -> matches the mounted key path used by scripts/run-ansible.ps1
```

1. Run playbook:

```bash
cd infrastructure/ansible
ansible-playbook site.yml
```

## Notes

- `services/` is now the source of truth for backend microservices.
- Service discovery scripts and CI only treat directories with real project files as valid services.
- Legacy root-level service folders should be considered deprecated migration leftovers, not active build inputs.
- `infrastructure/terraform/terraform.tfvars` is intentionally ignored and should stay local; commit only `terraform.tfvars.example`.
