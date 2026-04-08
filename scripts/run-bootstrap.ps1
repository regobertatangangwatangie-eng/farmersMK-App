#!/usr/bin/env pwsh
# ── farmersMK: Full Pipeline Bootstrap ───────────────────────────────────────
#
# Runs from your Windows machine. SSHes into the Ansible EC2 instance and
# executes the Jenkins bootstrap playbook from there.
#
# Prerequisites:
#   - id_ed25519 key at $HOME\.ssh\id_ed25519
#   - AWS EC2 instances running (terraform apply completed)
#   - A GitHub PAT with:  repo, admin:repo_hook, secrets
#   - A Docker Hub access token (not your password)
#
# Usage:
#   .\scripts\run-bootstrap.ps1 `
#     -GitHubToken  ghp_xxxxxxxxxx `
#     -GitHubOwner  YOUR_GITHUB_USER `
#     -GitHubRepo   farmersMK-App `
#     -DockerUser   YOUR_DOCKERHUB_USER `
#     -DockerToken  dckr_pat_xxxxxxxxxx
# ─────────────────────────────────────────────────────────────────────────────
param(
    [Parameter(Mandatory)][string]$GitHubToken,
    [Parameter(Mandatory)][string]$GitHubOwner,
    [string]$GitHubRepo   = "farmersMK-App",
    [Parameter(Mandatory)][string]$DockerUser,
    [Parameter(Mandatory)][string]$DockerToken,

    # Instance IPs — defaults match terraform output
    [string]$AnsibleIP   = "98.92.240.160",
    [string]$JenkinsIP   = "44.199.227.239",
    [string]$DockerIP    = "3.222.188.212",
    [string]$K8sIP       = "100.48.216.40",
    [string]$TerraformIP = "100.48.90.120",

    [string]$SSHKey = "$HOME\.ssh\id_ed25519",
    [string]$RepoDir = "~/farmersMK-App"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$SSH = "ssh"
$SSHArgs = @("-i", $SSHKey, "-o", "StrictHostKeyChecking=no", "-o", "ConnectTimeout=20")
$AnsibleHost = "ec2-user@$AnsibleIP"

function Invoke-Remote {
    param([string]$Command, [string]$Label = "")
    if ($Label) { Write-Host "" ; Write-Host "── $Label" -ForegroundColor Cyan }
    & $SSH @SSHArgs $AnsibleHost $Command
    if ($LASTEXITCODE -ne 0) { throw "Remote command failed (exit $LASTEXITCODE): $Command" }
}

# ── 0. Wait for Ansible instance ─────────────────────────────────────────────
Write-Host ""
Write-Host "farmersMK Bootstrap" -ForegroundColor Green
Write-Host "Ansible instance : $AnsibleIP"
Write-Host "Jenkins instance : $JenkinsIP"
Write-Host "k3s instance     : $K8sIP"
Write-Host ""

Write-Host "[0/6] Waiting for Ansible EC2 to be reachable..." -ForegroundColor Yellow
$retries = 0
do {
    $result = & $SSH @SSHArgs $AnsibleHost "echo ok" 2>&1
    if ($result -match "ok") { break }
    $retries++
    if ($retries -gt 20) { throw "Ansible EC2 not reachable after 100 seconds." }
    Write-Host "  waiting... ($($retries*5)s)"
    Start-Sleep -Seconds 5
} while ($true)
Write-Host "  Ansible EC2 reachable." -ForegroundColor Green

# ── 1. Clone / update repo on Ansible instance ───────────────────────────────
$GITHUB_HTTPS = "https://${GitHubToken}@github.com/${GitHubOwner}/${GitHubRepo}.git"

Invoke-Remote -Label "[1/6] Clone/update repo on Ansible instance" @"
set -e
if [ -d $RepoDir/.git ]; then
  echo 'Repo exists – pulling latest'
  cd $RepoDir && git fetch --all && git reset --hard origin/master
else
  echo 'Cloning repo...'
  git clone $GITHUB_HTTPS $RepoDir
fi
"@

# ── 2. Install Ansible + dependencies on Ansible instance ────────────────────
Invoke-Remote -Label "[2/6] Ensure Ansible is installed" @"
set -e
if ! command -v ansible-playbook &>/dev/null; then
  sudo dnf install -y ansible-core python3-boto3 2>/dev/null || \
  sudo yum install -y ansible python3-boto3 2>/dev/null || \
  pip3 install --user ansible
fi
ansible --version
"@

# ── 3. Write SSH key to Ansible instance ─────────────────────────────────────
Write-Host ""
Write-Host "── [3/6] Pushing SSH key to Ansible instance" -ForegroundColor Cyan
$localKey = Get-Content $SSHKey -Raw
$escapedKey = $localKey -replace "'", "'\"'\"'"

& $SSH @SSHArgs $AnsibleHost @"
mkdir -p ~/.ssh
chmod 700 ~/.ssh
cat > ~/.ssh/id_ed25519 << 'ENDKEY'
$localKey
ENDKEY
chmod 600 ~/.ssh/id_ed25519
echo 'SSH key written'
"@
if ($LASTEXITCODE -ne 0) { throw "Failed to push SSH key" }

# ── 4. Run Jenkins bootstrap playbook ────────────────────────────────────────
Invoke-Remote -Label "[4/6] Running jenkins-bootstrap.yml" @"
set -e
cd $RepoDir
ansible-playbook \
  -i "infrastructure/ansible/inventory.devops.ini" \
  --extra-vars "
    github_token=$GitHubToken
    github_owner=$GitHubOwner
    github_repo=$GitHubRepo
    dockerhub_username=$DockerUser
    dockerhub_token=$DockerToken
    k8s_server=https://${K8sIP}:6443
  " \
  infrastructure/ansible/jenkins-bootstrap.yml \
  2>&1 | tee /tmp/jenkins-bootstrap.log
echo 'Bootstrap playbook complete'
"@

# ── 5. Register GitHub webhook ───────────────────────────────────────────────
Write-Host ""
Write-Host "── [5/7] Registering GitHub webhook" -ForegroundColor Cyan

$headers = @{
    "Authorization" = "token $GitHubToken"
    "Accept"        = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}

$webhookBody = @{
    name   = "web"
    active = $true
    events = @("push", "pull_request")
    config = @{
        url          = "http://${JenkinsIP}:8080/github-webhook/"
        content_type = "json"
        insecure_ssl = "1"
    }
} | ConvertTo-Json -Depth 4

try {
    $resp = Invoke-RestMethod `
        -Uri "https://api.github.com/repos/$GitHubOwner/$GitHubRepo/hooks" `
        -Method POST `
        -Headers $headers `
        -Body $webhookBody `
        -ContentType "application/json"
    Write-Host "  Webhook created: $($resp.config.url)" -ForegroundColor Green
} catch {
    $code = $_.Exception.Response.StatusCode.value__
    if ($code -eq 422) {
        Write-Host "  Webhook already exists" -ForegroundColor Yellow
    } else {
        Write-Host "  Webhook warning: $_" -ForegroundColor Yellow
    }
}

# ── 6. Set GitHub Actions secrets ─────────────────────────────────────────────
Write-Host ""
Write-Host "── [6/7] Setting GitHub Actions secrets..." -ForegroundColor Cyan

# Helper: set a repo secret via GitHub API (requires gh CLI for encryption)
function Set-GitHubSecret {
    param([string]$Name, [string]$Value)
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        $Value | gh secret set $Name --repo "$GitHubOwner/$GitHubRepo" 2>&1 | Out-Null
        Write-Host "  ✅  $Name" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️   gh CLI not found — set $Name manually in GitHub → Settings → Secrets" -ForegroundColor Yellow
    }
}

# Docker Hub
Set-GitHubSecret "DOCKERHUB_USERNAME" $DockerUser
Set-GitHubSecret "DOCKERHUB_TOKEN"    $DockerToken

# Ansible SSH targets
Set-GitHubSecret "ANSIBLE_SSH_KEY"  (Get-Content $SSHKey -Raw)
Set-GitHubSecret "ANSIBLE_HOST_1"   $AnsibleIP
Set-GitHubSecret "ANSIBLE_HOST_2"   $DockerIP

# k3s kubeconfig (fetch from k3s instance)
Write-Host "      Fetching kubeconfig from k3s @ $K8sIP ..." -ForegroundColor Gray
$kc = & ssh -o StrictHostKeyChecking=no -i $SSHKey "ec2-user@$K8sIP" `
    "sudo cat /etc/rancher/k3s/k3s.yaml 2>/dev/null | sed 's/127.0.0.1/$K8sIP/g'" 2>&1
if ($LASTEXITCODE -eq 0 -and $kc) {
    $kcB64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($kc))
    Set-GitHubSecret "K8S_KUBECONFIG" $kcB64
} else {
    Write-Host "  ⚠️   k3s not ready yet — set K8S_KUBECONFIG manually after k3s finishes booting" -ForegroundColor Yellow
}

# ── 7. Print summary ──────────────────────────────────────────────────────────
Write-Host ""
Write-Host "── [7/7] Done ─────────────────────────────────────────────────────" -ForegroundColor Green
Write-Host ""
Write-Host "  Jenkins    :  http://$JenkinsIP`:8080"
Write-Host "  k3s        :  https://$K8sIP`:6443"
Write-Host "  Docker Reg :  http://$DockerIP`:5000/v2/_catalog"
Write-Host ""
Write-Host "  SSH to Jenkins:   ssh -i $SSHKey ec2-user@$JenkinsIP"
Write-Host "  SSH to k3s:       ssh -i $SSHKey ec2-user@$K8sIP"
Write-Host "  SSH to Ansible:   ssh -i $SSHKey ec2-user@$AnsibleIP"
Write-Host ""
Write-Host "  Next: open Jenkins, get initial password, finish wizard" -ForegroundColor Yellow
Write-Host "        sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
Write-Host ""
Write-Host "  Push to master to trigger the first build pipeline" -ForegroundColor Cyan
Write-Host ""
