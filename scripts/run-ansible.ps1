param(
    [string]$SshKeyPath = "$env:USERPROFILE\.ssh\id_ed25519",
    [string]$Playbook   = "site.yml",
    [string]$Inventory  = "inventory.ini"
)

$ErrorActionPreference = "Stop"
$ansibleDir = Join-Path $PSScriptRoot "..\infrastructure\ansible"
$ansibleDir = (Resolve-Path $ansibleDir).Path

if (-not (Test-Path $SshKeyPath)) {
    throw "SSH key not found: $SshKeyPath"
}

if (-not (Test-Path (Join-Path $ansibleDir $Inventory))) {
    throw "Inventory file not found: $(Join-Path $ansibleDir $Inventory)"
}

Write-Host "Building Ansible runner image..."
docker build -t FarmersMK-ansible:latest $ansibleDir

Write-Host "Running playbook $Playbook against inventory $Inventory ..."
docker run --rm `
    -v "${ansibleDir}:/ansible" `
    -v "${SshKeyPath}:/root/.ssh/ansible_key:ro" `
    FarmersMK-ansible:latest `
    -i $Inventory $Playbook

Write-Host "Playbook run complete."
