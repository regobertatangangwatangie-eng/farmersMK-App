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

## Go-Live Checklist (Phone + Desktop)

### Desktop/Laptop Web App (`farmpro-frontend-web`)

1. Copy environment template:

```bash
cp farmpro-frontend-web/.env.example farmpro-frontend-web/.env.local
```

1. Set production values:

```text
VITE_API_BASE_URL=https://api.your-domain.com
VITE_REALTIME_URL=wss://api.your-domain.com/ws
VITE_SERVICE_HUB_URL=https://api.your-domain.com/services.html
```

1. Build and verify:

```bash
cd farmpro-frontend-web
npm install
npm run build
```

1. Deploy:

```bash
docker build -t farmpro-web:latest .
docker run -p 80:80 farmpro-web:latest
```

### Android Phone App (`farmpro-android-app`)

1. Copy environment template:

```bash
cp farmpro-android-app/.env.example farmpro-android-app/.env
```

1. Set production API endpoint:

```text
EXPO_PUBLIC_API_BASE_URL=https://api.your-domain.com
```

1. Install dependencies and validate Expo config:

```bash
cd farmpro-android-app
npm install
npx expo config --type public
```

1. Build for store release (AAB):

```bash
npm run build:android:production
```

1. Submit to Google Play:

```bash
npm run submit:android:production
```

## Production Automation

### CI Checks Added

`ci-cd/github-actions/pipeline.yml` now includes:

- `frontend-web-check`: installs dependencies and runs production build for `farmpro-frontend-web`.
- `android-config-check`: installs dependencies and validates Expo public config for `farmpro-android-app`.

### Pre-release Smoke Test

Run this after deploying backend/web endpoints:

```powershell
./scripts/pre-release-smoke.ps1 -ApiBaseUrl https://api.your-domain.com -WebUrl https://app.your-domain.com
```

The script checks API root, products endpoint, users endpoint, and optionally web landing page.

### One-command Full Go-Live (EC2 + Phone + Laptop/Desktop)

Use this to deploy backend/web to EC2, build the web release, trigger Android production build, and run smoke tests:

```powershell
./scripts/go-live-all.ps1 `
	-Instance1Ip 1.2.3.4 `
	-Instance2Ip 5.6.7.8 `
	-SshKeyPath "$env:USERPROFILE\Downloads\farmerpro-key.pem" `
	-DockerHubToken "dckr_pat_XXXX"
```

Optional flags:

- `-SkipEc2Deploy`: run release/smoke only.
- `-SkipReleaseBuild`: run deploy/smoke only.
- `-SkipSmokeTest`: skip endpoint checks.
- `-SkipDocker`: skip web Docker image build.
- `-SkipAndroidBuild`: skip Android EAS build trigger.

### One-command Desktop + Phone Release

Use:

```powershell
./scripts/release-phone-desktop.ps1 -WebApiBaseUrl https://api.your-domain.com -AndroidApiBaseUrl https://api.your-domain.com
```

Optional flags:

- `-SkipDocker`: skip web Docker image build.
- `-SkipAndroidBuild`: skip EAS Android production build.
