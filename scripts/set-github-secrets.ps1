<#
  set-github-secrets.ps1
  Run with:  .\scripts\set-github-secrets.ps1 -DockerOnly
  to update only Docker Hub secrets quickly.
  ----------------------
  Downloads gh CLI (if needed), then sets the required GitHub Actions secrets
  for farmersMK-App:
    - DOCKERHUB_USERNAME / DOCKERHUB_TOKEN
    - EC2_SSH_KEY  (SSH_PRIVATE_KEY used by webfactory/ssh-agent)
    - EXPO_TOKEN   (optional — leave blank to skip)
    - ANSIBLE_SSH_KEY / ANSIBLE_HOST_1 / ANSIBLE_HOST_2
    - K8S_KUBECONFIG (optional)
  
  Usage: .\scripts\set-github-secrets.ps1
#>

$ErrorActionPreference = 'Stop'
$REPO = "regobertatangangwatangie-eng/farmersMK-App"

# ── Helper: read a secret from the console without echoing ──────────────────
function Read-Secret([string]$Prompt) {
    $ss = Read-Host -Prompt $Prompt -AsSecureString
    [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($ss))
}

# ── Helper: read a multi-line value (e.g. PEM key) from a file path ─────────
function Read-FileOrDirect([string]$Prompt) {
    $val = Read-Host -Prompt "$Prompt  [paste path to file, or press Enter to paste text]"
    if ($val -and (Test-Path $val -PathType Leaf)) {
        return (Get-Content $val -Raw).Trim()
    }
    if ($val) { return $val.Trim() }
    # multi-line paste: read until blank line
    Write-Host "Paste the value below, then enter a blank line:"
    $lines = @()
    while ($true) {
        $line = Read-Host
        if ($line -eq '') { break }
        $lines += $line
    }
    return ($lines -join "`n").Trim()
}

# ── 1. Ensure gh CLI is available ────────────────────────────────────────────
$ghPath = ""
$ghCandidate = Get-Command gh -ErrorAction SilentlyContinue
if ($ghCandidate) {
    $ghPath = $ghCandidate.Source
    Write-Host "gh CLI found: $ghPath"
} else {
    Write-Host "gh CLI not found — downloading portable version..."
    $ghDir  = "$env:TEMP\gh-cli"
    $ghZip  = "$env:TEMP\gh.zip"
    $ghExe  = "$ghDir\gh.exe"

    if (-not (Test-Path $ghExe)) {
        # Latest stable portable zip for Windows
        $release = Invoke-RestMethod "https://api.github.com/repos/cli/cli/releases/latest"
        $asset   = $release.assets | Where-Object { $_.name -like "gh_*_windows_amd64.zip" } | Select-Object -First 1
        if (-not $asset) { throw "Could not find gh Windows release asset." }
        Write-Host "Downloading $($asset.name)..."
        Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $ghZip -UseBasicParsing
        Expand-Archive -Path $ghZip -DestinationPath $ghDir -Force
        # The zip has a sub-folder like gh_2.x.x_windows_amd64\bin\gh.exe
        $extracted = Get-ChildItem -Path $ghDir -Recurse -Filter gh.exe | Select-Object -First 1
        if (-not $extracted) { throw "gh.exe not found after extraction." }
        $ghExe = $extracted.FullName
    }
    $ghPath = $ghExe
    Write-Host "gh CLI ready at: $ghPath"
}

# ── 2. Authenticate ──────────────────────────────────────────────────────────
Write-Host ""
Write-Host "=== GitHub Authentication ===" -ForegroundColor Cyan
Write-Host "You need a GitHub PAT with 'repo' + 'write:secrets' scope."
Write-Host "Generate one at: https://github.com/settings/tokens"
Write-Host ""
$token = Read-Secret "GitHub Personal Access Token"
$env:GH_TOKEN = $token

# Verify auth
$authTest = & $ghPath api "repos/$REPO" --jq '.full_name' 2>&1
if ($LASTEXITCODE -ne 0) {
    throw "Authentication failed. Check your PAT has repo access. Error: $authTest"
}
Write-Host "Authenticated. Repo: $authTest" -ForegroundColor Green

# ── 3. Collect secret values ─────────────────────────────────────────────────
Write-Host ""
Write-Host "=== Collect Secret Values ===" -ForegroundColor Cyan
Write-Host "(Press Enter to skip an optional secret)"
Write-Host ""

$secrets = [ordered]@{}

# Docker Hub
$secrets['DOCKERHUB_USERNAME'] = (Read-Host "Docker Hub username").Trim()
$secrets['DOCKERHUB_TOKEN']    = Read-Secret "Docker Hub Access Token"

# EC2 SSH key (used by webfactory/ssh-agent as SSH_PRIVATE_KEY)
Write-Host ""
$sshKey = Read-FileOrDirect "EC2 SSH private key (.pem file path or paste)"
if ($sshKey) {
    $secrets['EC2_SSH_KEY']     = $sshKey
    $secrets['SSH_PRIVATE_KEY'] = $sshKey   # alias used by webfactory/ssh-agent
    $secrets['ANSIBLE_SSH_KEY'] = $sshKey   # alias used by Ansible deploy jobs
}

# EC2 hosts
Write-Host ""
$host1 = (Read-Host "EC2 Host 1 IP (ANSIBLE_HOST_1) [default: 98.84.28.135]").Trim()
if (-not $host1) { $host1 = "98.84.28.135" }
$secrets['ANSIBLE_HOST_1'] = $host1

$host2 = (Read-Host "EC2 Host 2 IP (ANSIBLE_HOST_2) [leave blank to skip]").Trim()
if ($host2) { $secrets['ANSIBLE_HOST_2'] = $host2 }

# Expo (optional)
Write-Host ""
$expoToken = Read-Secret "Expo Access Token (blank to skip Android builds)"
if ($expoToken) { $secrets['EXPO_TOKEN'] = $expoToken }

# K8S kubeconfig (optional)
Write-Host ""
$k8sCfg = Read-FileOrDirect "K8s kubeconfig file path (blank to skip)"
if ($k8sCfg) {
    # GitHub expects it base64-encoded
    $b64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($k8sCfg))
    $secrets['K8S_KUBECONFIG'] = $b64
}

# ── 4. Set secrets ────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "=== Setting Secrets ===" -ForegroundColor Cyan

foreach ($name in $secrets.Keys) {
    $value = $secrets[$name]
    if (-not $value) { continue }
    Write-Host "  Setting $name ..." -NoNewline
    $value | & $ghPath secret set $name --repo $REPO 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host " OK" -ForegroundColor Green
    } else {
        Write-Host " FAILED" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== Done ===" -ForegroundColor Green
Write-Host "All secrets set. Re-run the GitHub Actions workflow to verify."
