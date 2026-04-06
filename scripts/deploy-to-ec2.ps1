<#
.SYNOPSIS
  Deploy FARMERPRO-APP to your two AWS EC2 instances (FARMERPRO-APP and FARMERPRO-APP1).

.DESCRIPTION
  1. Accepts the public IPs and path to your .pem SSH key.
  2. Updates the Ansible inventory with real server IPs.
  3. Optionally pushes Docker images to Docker Hub (requires write-access token).
  4. Runs the Ansible playbook inside Docker to configure servers + start the stack.

.PARAMETER Instance1Ip
  Public IP of the FARMERPRO-APP EC2 instance.

.PARAMETER Instance2Ip
  Public IP of the FARMERPRO-APP1 EC2 instance.

.PARAMETER SshKeyPath
  Full path to your .pem file (downloaded from AWS when creating the key pair).

.PARAMETER DockerHubToken
  Docker Hub access token with Read+Write+Delete scope.
  If not provided, Docker Hub push is skipped and EC2 will build from GitHub source.

.EXAMPLE
  .\scripts\deploy-to-ec2.ps1 `
    -Instance1Ip 1.2.3.4 `
    -Instance2Ip 5.6.7.8 `
    -SshKeyPath "$env:USERPROFILE\Downloads\farmerpro-key.pem" `
    -DockerHubToken "dckr_pat_XXXX"
#>
param(
  [Parameter(Mandatory = $true)]
  [string]$Instance1Ip,

  [Parameter(Mandatory = $true)]
  [string]$Instance2Ip,

  [Parameter(Mandatory = $true)]
  [string]$SshKeyPath,

  [Parameter(Mandatory = $false)]
  [string]$DockerHubToken = ""
)

$ErrorActionPreference = 'Stop'
$repoRoot  = Split-Path -Parent $PSScriptRoot
$ansibleDir = Join-Path $repoRoot "infrastructure\ansible"
$inventory  = Join-Path $ansibleDir "inventory.ini"
$resolvedKeyPath = (Resolve-Path $SshKeyPath).Path
$dockerKeyPath = $resolvedKeyPath
$temporaryPemPath = $null

if ([System.IO.Path]::GetExtension($resolvedKeyPath).ToLowerInvariant() -eq ".ppk") {
  $ppkDirectory = Split-Path -Parent $resolvedKeyPath
  $ppkFileName = Split-Path -Leaf $resolvedKeyPath
  $pemFileName = "{0}.pem" -f [System.IO.Path]::GetFileNameWithoutExtension($resolvedKeyPath)
  $temporaryPemPath = Join-Path $env:TEMP $pemFileName
  $temporaryPemDirectory = Split-Path -Parent $temporaryPemPath

  Write-Host "Converting PPK key to temporary PEM for OpenSSH/Ansible..." -ForegroundColor Cyan
  Remove-Item $temporaryPemPath -Force -ErrorAction SilentlyContinue

  docker run --rm `
    -v "${ppkDirectory}:/keys/in" `
    -v "${temporaryPemDirectory}:/keys/out" `
    debian:bookworm-slim `
    bash -lc "apt-get update >/dev/null && apt-get install -y --no-install-recommends putty-tools >/dev/null && puttygen /keys/in/$ppkFileName -O private-openssh -o /keys/out/$pemFileName && chmod 600 /keys/out/$pemFileName"

  if ($LASTEXITCODE -ne 0 -or -not (Test-Path $temporaryPemPath)) {
    throw "Failed to convert PPK key at $resolvedKeyPath to PEM format."
  }

  $dockerKeyPath = $temporaryPemPath
  Write-Host "Temporary PEM created at $temporaryPemPath" -ForegroundColor Green
}

# ── Step 1: Write Ansible inventory ──────────────────────────────────────────
Write-Host "Writing Ansible inventory for both EC2 instances..." -ForegroundColor Cyan
@"
[farmpro]
server1 ansible_host=$Instance1Ip ansible_user=ubuntu ansible_ssh_private_key_file=/root/.ssh/ansible_key
server2 ansible_host=$Instance2Ip ansible_user=ubuntu ansible_ssh_private_key_file=/root/.ssh/ansible_key
"@ | Set-Content $inventory
Write-Host "Inventory written to $inventory" -ForegroundColor Green

# ── Step 2: Optionally push Docker images ─────────────────────────────────────
if ($DockerHubToken -ne "") {
  Write-Host "Pushing Docker images to Docker Hub (regobert2004)..." -ForegroundColor Cyan
  Write-Output $DockerHubToken | docker login -u regobert2004 --password-stdin

  $images = @(
    "regobert2004/farmpro-api-gateway:latest",
    "regobert2004/farmpro-admin-service:latest",
    "regobert2004/farmpro-user-service:latest",
    "regobert2004/farmpro-marketplace-service:latest",
    "regobert2004/farmpro-notification-service:latest",
    "regobert2004/farmpro-post-service:latest",
    "regobert2004/farmpro-wallet-service:latest",
    "regobert2004/farmpro-realtime-service:latest",
    "regobert2004/farmpro-mastercard-service:latest",
    "regobert2004/farmpro-visacard-service:latest",
    "regobert2004/farmpro-mtnmobilemoney-service:latest",
    "regobert2004/farmpro-orangemoney-service:latest",
    "regobert2004/farmpro-cryptocurrencywallet-service:latest",
    "regobert2004/farmpro-socialmediafacebook-service:latest",
    "regobert2004/farmpro-socialmediainstagram-service:latest",
    "regobert2004/farmpro-socialmediatwitter-service:latest",
    "regobert2004/farmpro-web:latest"
  )

  foreach ($img in $images) {
    Write-Host "  Pushing $img..." -ForegroundColor DarkCyan
    docker push $img
    if ($LASTEXITCODE -ne 0) { Write-Host "  PUSH FAILED: $img" -ForegroundColor Red }
  }
  Write-Host "Docker push complete." -ForegroundColor Green
} else {
  Write-Host "No DockerHubToken provided – EC2 instances will build from GitHub source via Ansible." -ForegroundColor Yellow
}

# ── Step 3: Run Ansible playbook via Docker ───────────────────────────────────
Write-Host "Building Ansible runner image..." -ForegroundColor Cyan
docker build -t farmpro-ansible:latest $ansibleDir

Write-Host "Running Ansible playbook on both EC2 instances..." -ForegroundColor Cyan
docker run --rm `
  -v "${ansibleDir}:/ansible" `
  -v "${dockerKeyPath}:/root/.ssh/ansible_key:ro" `
  -e "DOCKER_HUB_TOKEN=$DockerHubToken" `
  -e "ANSIBLE_HOST_KEY_CHECKING=False" `
  farmpro-ansible:latest `
  -i inventory.ini site.yml

if ($temporaryPemPath -and (Test-Path $temporaryPemPath)) {
  Remove-Item $temporaryPemPath -Force -ErrorAction SilentlyContinue
}

if ($LASTEXITCODE -ne 0) {
  throw "EC2 deployment failed during Ansible execution. Review the playbook output above for the failing task."
}

Write-Host "EC2 deployment complete." -ForegroundColor Green
Write-Host ""
Write-Host "Your services are now live at:" -ForegroundColor Green
Write-Host "  FARMERPRO-APP  -> http://$Instance1Ip"
Write-Host "  FARMERPRO-APP1 -> http://$Instance2Ip"
Write-Host "  API Gateway    -> http://${Instance1Ip}:8080"
