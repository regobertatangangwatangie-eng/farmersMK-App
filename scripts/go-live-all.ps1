<#
.SYNOPSIS
	Unified FARMERPRO go-live orchestration for phone, laptop, and desktop.

.DESCRIPTION
	1. Optionally deploys backend + web stack to EC2 using Ansible.
	2. Builds/release-preps web (laptop/desktop) and Android (phone).
	3. Runs smoke tests against public endpoints.

.EXAMPLE
	.\scripts\go-live-all.ps1 `
		-Instance1Ip 1.2.3.4 `
		-Instance2Ip 5.6.7.8 `
		-SshKeyPath "$env:USERPROFILE\Downloads\farmerpro-key.pem" `
		-DockerHubToken "dckr_pat_XXXX"
#>
param(
	[Parameter(Mandatory = $false)]
	[string]$Instance1Ip,

	[Parameter(Mandatory = $false)]
	[string]$Instance2Ip,

	[Parameter(Mandatory = $false)]
	[string]$SshKeyPath,

	[Parameter(Mandatory = $false)]
	[string]$DockerHubToken = '',

	[Parameter(Mandatory = $false)]
	[string]$WebApiBaseUrl,

	[Parameter(Mandatory = $false)]
	[string]$WebRealtimeUrl,

	[Parameter(Mandatory = $false)]
	[string]$WebServiceHubUrl,

	[Parameter(Mandatory = $false)]
	[string]$AndroidApiBaseUrl,

	[Parameter(Mandatory = $false)]
	[string]$PublicWebUrl,

	[Parameter(Mandatory = $false)]
	[switch]$SkipEc2Deploy,

	[Parameter(Mandatory = $false)]
	[switch]$SkipReleaseBuild,

	[Parameter(Mandatory = $false)]
	[switch]$SkipSmokeTest,

	[Parameter(Mandatory = $false)]
	[switch]$SkipDocker,

	[Parameter(Mandatory = $false)]
	[switch]$SkipAndroidBuild,

	[Parameter(Mandatory = $false)]
	[switch]$NoVcsForEas,

	[Parameter(Mandatory = $false)]
	[int]$SmokeTimeoutSec = 20
)

$ErrorActionPreference = 'Stop'

function Assert-Required {
	param(
		[Parameter(Mandatory = $true)]
		[bool]$Condition,

		[Parameter(Mandatory = $true)]
		[string]$Message
	)

	if (-not $Condition) {
		throw $Message
	}
}

function Get-DefaultOrProvided {
	param(
		[Parameter(Mandatory = $false)]
		[string]$Provided,

		[Parameter(Mandatory = $true)]
		[string]$DefaultValue
	)

	if ([string]::IsNullOrWhiteSpace($Provided)) {
		return $DefaultValue
	}

	return $Provided
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$deployScript = Join-Path $PSScriptRoot 'deploy-to-ec2.ps1'
$releaseScript = Join-Path $PSScriptRoot 'release-phone-desktop.ps1'
$smokeScript = Join-Path $PSScriptRoot 'pre-release-smoke.ps1'

Assert-Required -Condition (Test-Path $deployScript) -Message "Missing script: $deployScript"
Assert-Required -Condition (Test-Path $releaseScript) -Message "Missing script: $releaseScript"
Assert-Required -Condition (Test-Path $smokeScript) -Message "Missing script: $smokeScript"

if (-not $SkipEc2Deploy) {
	Assert-Required -Condition (-not [string]::IsNullOrWhiteSpace($Instance1Ip)) -Message 'Instance1Ip is required unless -SkipEc2Deploy is used.'
	Assert-Required -Condition (-not [string]::IsNullOrWhiteSpace($Instance2Ip)) -Message 'Instance2Ip is required unless -SkipEc2Deploy is used.'
	Assert-Required -Condition (-not [string]::IsNullOrWhiteSpace($SshKeyPath)) -Message 'SshKeyPath is required unless -SkipEc2Deploy is used.'
}

$primaryApi = if (-not [string]::IsNullOrWhiteSpace($Instance1Ip)) { "http://$Instance1Ip:8080" } else { '' }
$primaryWeb = if (-not [string]::IsNullOrWhiteSpace($Instance1Ip)) { "http://$Instance1Ip" } else { '' }
$secondaryApi = if (-not [string]::IsNullOrWhiteSpace($Instance2Ip)) { "http://$Instance2Ip:8080" } else { '' }
$secondaryWeb = if (-not [string]::IsNullOrWhiteSpace($Instance2Ip)) { "http://$Instance2Ip" } else { '' }

$resolvedWebApiBaseUrl = Get-DefaultOrProvided -Provided $WebApiBaseUrl -DefaultValue $primaryApi
Assert-Required -Condition (-not [string]::IsNullOrWhiteSpace($resolvedWebApiBaseUrl)) -Message 'WebApiBaseUrl is required when EC2 deployment is skipped and no Instance1Ip is provided.'

$defaultRealtimeUrl = ($resolvedWebApiBaseUrl -replace '^http', 'ws') + '/ws'
$defaultServiceHubUrl = if (-not [string]::IsNullOrWhiteSpace($primaryWeb)) { ($primaryWeb.TrimEnd('/')) + '/services.html' } else { 'https://api.your-domain.com/services.html' }

$resolvedAndroidApiBaseUrl = Get-DefaultOrProvided -Provided $AndroidApiBaseUrl -DefaultValue $resolvedWebApiBaseUrl
$resolvedWebRealtimeUrl = Get-DefaultOrProvided -Provided $WebRealtimeUrl -DefaultValue $defaultRealtimeUrl
$resolvedWebServiceHubUrl = Get-DefaultOrProvided -Provided $WebServiceHubUrl -DefaultValue $defaultServiceHubUrl
$resolvedPublicWebUrl = Get-DefaultOrProvided -Provided $PublicWebUrl -DefaultValue $primaryWeb

Write-Host ''
Write-Host '=== FARMERPRO GO-LIVE ORCHESTRATION ===' -ForegroundColor Cyan
Write-Host "Repository: $repoRoot" -ForegroundColor DarkGray

if (-not $SkipEc2Deploy) {
	Write-Host ''
	Write-Host 'Step 1/3: Deploying backend + web stack to EC2 instances...' -ForegroundColor Cyan
	$deployArgs = @{
		Instance1Ip = $Instance1Ip
		Instance2Ip = $Instance2Ip
		SshKeyPath = $SshKeyPath
	}
	if (-not [string]::IsNullOrWhiteSpace($DockerHubToken)) {
		$deployArgs.DockerHubToken = $DockerHubToken
	}
	& $deployScript @deployArgs
}
else {
	Write-Host ''
	Write-Host 'Step 1/3: EC2 deployment skipped by flag.' -ForegroundColor Yellow
}

if (-not $SkipReleaseBuild) {
	Write-Host ''
	Write-Host 'Step 2/3: Building release artifacts for laptop/desktop web and Android phone...' -ForegroundColor Cyan
	$releaseArgs = @{
		WebApiBaseUrl = $resolvedWebApiBaseUrl
		WebRealtimeUrl = $resolvedWebRealtimeUrl
		WebServiceHubUrl = $resolvedWebServiceHubUrl
		AndroidApiBaseUrl = $resolvedAndroidApiBaseUrl
	}
	if ($SkipDocker) {
		$releaseArgs.SkipDocker = $true
	}
	if ($SkipAndroidBuild) {
		$releaseArgs.SkipAndroidBuild = $true
	}
	if ($NoVcsForEas) {
		$releaseArgs.NoVcsForEas = $true
	}
	& $releaseScript @releaseArgs
}
else {
	Write-Host ''
	Write-Host 'Step 2/3: Release build skipped by flag.' -ForegroundColor Yellow
}

if (-not $SkipSmokeTest) {
	Write-Host ''
	Write-Host 'Step 3/3: Running post-release smoke tests...' -ForegroundColor Cyan

	if (-not [string]::IsNullOrWhiteSpace($resolvedPublicWebUrl)) {
		& $smokeScript -ApiBaseUrl $resolvedWebApiBaseUrl -WebUrl $resolvedPublicWebUrl -TimeoutSec $SmokeTimeoutSec
	}
	else {
		& $smokeScript -ApiBaseUrl $resolvedWebApiBaseUrl -TimeoutSec $SmokeTimeoutSec
	}

	if (-not [string]::IsNullOrWhiteSpace($secondaryApi)) {
		Write-Host ''
		Write-Host 'Running smoke test against secondary EC2 instance...' -ForegroundColor DarkCyan
		if (-not [string]::IsNullOrWhiteSpace($secondaryWeb)) {
			& $smokeScript -ApiBaseUrl $secondaryApi -WebUrl $secondaryWeb -TimeoutSec $SmokeTimeoutSec
		}
		else {
			& $smokeScript -ApiBaseUrl $secondaryApi -TimeoutSec $SmokeTimeoutSec
		}
	}
}
else {
	Write-Host ''
	Write-Host 'Step 3/3: Smoke test skipped by flag.' -ForegroundColor Yellow
}

Write-Host ''
Write-Host 'FARMERPRO go-live workflow completed.' -ForegroundColor Green
Write-Host "Primary API : $resolvedWebApiBaseUrl" -ForegroundColor Green
if (-not [string]::IsNullOrWhiteSpace($resolvedPublicWebUrl)) {
	Write-Host "Primary Web : $resolvedPublicWebUrl" -ForegroundColor Green
}
Write-Host "Android API : $resolvedAndroidApiBaseUrl" -ForegroundColor Green
