param(
  [Parameter(Mandatory = $false)]
  [string]$WebApiBaseUrl = 'https://api.your-domain.com',

  [Parameter(Mandatory = $false)]
  [string]$WebRealtimeUrl = 'wss://api.your-domain.com/ws',

  [Parameter(Mandatory = $false)]
  [string]$WebServiceHubUrl = 'https://api.your-domain.com/services.html',

  [Parameter(Mandatory = $false)]
  [string]$AndroidApiBaseUrl = 'https://api.your-domain.com',

  [Parameter(Mandatory = $false)]
  [switch]$SkipDocker,

  [Parameter(Mandatory = $false)]
  [switch]$SkipAndroidBuild,

  [Parameter(Mandatory = $false)]
  [switch]$NoVcsForEas
)

$ErrorActionPreference = 'Stop'

function Invoke-Step {
  param(
    [Parameter(Mandatory = $true)]
    [scriptblock]$Command,

    [Parameter(Mandatory = $true)]
    [string]$FailureMessage
  )

  & $Command
  if ($LASTEXITCODE -ne 0) {
    throw $FailureMessage
  }
}

function Install-NpmDependencies {
  param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectName
  )

  Write-Host "Installing dependencies for $ProjectName (npm ci)..." -ForegroundColor DarkCyan
  npm ci
  if ($LASTEXITCODE -eq 0) {
    return
  }

  Write-Host "npm ci failed for $ProjectName. Retrying with --legacy-peer-deps..." -ForegroundColor Yellow
  npm ci --legacy-peer-deps
  if ($LASTEXITCODE -ne 0) {
    throw "$ProjectName dependency installation failed with npm ci and npm ci --legacy-peer-deps."
  }
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$webPath = Join-Path $repoRoot 'FarmersMK-frontend-web'
$androidPath = Join-Path $repoRoot 'FarmersMK-android-app'

Write-Host 'Step 1/3: Building desktop/laptop web app...' -ForegroundColor Cyan
Push-Location $webPath
$env:VITE_API_BASE_URL = $WebApiBaseUrl
$env:VITE_REALTIME_URL = $WebRealtimeUrl
$env:VITE_SERVICE_HUB_URL = $WebServiceHubUrl
Install-NpmDependencies -ProjectName 'web frontend'
Invoke-Step -Command { npm run build } -FailureMessage 'Web production build failed.'

if (-not $SkipDocker) {
  Write-Host 'Building web Docker image FarmersMK-web:latest...' -ForegroundColor Cyan
  Invoke-Step -Command { docker build -t FarmersMK-web:latest . } -FailureMessage 'Web Docker image build failed.'
}
Pop-Location

if (-not $SkipAndroidBuild) {
  Write-Host 'Step 2/3: Triggering Android production build (AAB) via EAS...' -ForegroundColor Cyan
  Push-Location $androidPath
  $env:EXPO_PUBLIC_API_BASE_URL = $AndroidApiBaseUrl
  try {
    if ($NoVcsForEas) {
      $env:EAS_NO_VCS = '1'
      Write-Host 'EAS_NO_VCS=1 enabled for this run.' -ForegroundColor Yellow
    }
    Install-NpmDependencies -ProjectName 'android app'
    Invoke-Step -Command { npx expo config --type public } -FailureMessage 'Android Expo config validation failed.'
    Invoke-Step -Command { npm run build:android:production } -FailureMessage 'Android production build trigger failed.'
  }
  finally {
    if ($NoVcsForEas) {
      Remove-Item Env:EAS_NO_VCS -ErrorAction SilentlyContinue
    }
  }
  Pop-Location
}
else {
  Write-Host 'Step 2/3: Android build skipped by flag.' -ForegroundColor Yellow
}

Write-Host 'Step 3/3: Optional smoke test command:' -ForegroundColor Cyan
Write-Host './scripts/pre-release-smoke.ps1 -ApiBaseUrl https://api.your-domain.com -WebUrl https://app.your-domain.com'
Write-Host 'Release command completed.' -ForegroundColor Green
