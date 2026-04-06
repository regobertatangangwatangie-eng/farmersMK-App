param(
  [Parameter(Mandatory = $true)]
  [string]$ApiBaseUrl,

  [Parameter(Mandatory = $false)]
  [string]$WebUrl,

  [Parameter(Mandatory = $false)]
  [int]$TimeoutSec = 15
)

$ErrorActionPreference = 'Stop'

function Test-HttpEndpoint {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Url,

    [Parameter(Mandatory = $true)]
    [string]$Name
  )

  try {
    $response = Invoke-WebRequest -Uri $Url -Method Get -TimeoutSec $TimeoutSec -UseBasicParsing
    if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 400) {
      Write-Host "PASS: $Name ($($response.StatusCode)) -> $Url" -ForegroundColor Green
      return $true
    }

    Write-Host "FAIL: $Name ($($response.StatusCode)) -> $Url" -ForegroundColor Red
    return $false
  }
  catch {
    Write-Host "FAIL: $Name -> $Url :: $($_.Exception.Message)" -ForegroundColor Red
    return $false
  }
}

$apiRoot = $ApiBaseUrl.TrimEnd('/')
$checks = @(
  @{ Name = 'API root'; Url = $apiRoot },
  @{ Name = 'Products endpoint'; Url = "$apiRoot/products" },
  @{ Name = 'Users endpoint'; Url = "$apiRoot/users" }
)

if ($WebUrl) {
  $webRoot = $WebUrl.TrimEnd('/')
  $checks += @{ Name = 'Web landing page'; Url = $webRoot }
}

$failures = 0
foreach ($check in $checks) {
  $ok = Test-HttpEndpoint -Url $check.Url -Name $check.Name
  if (-not $ok) {
    $failures++
  }
}

if ($failures -gt 0) {
  Write-Host "Smoke test completed with $failures failure(s)." -ForegroundColor Red
  exit 1
}

Write-Host 'Smoke test completed successfully.' -ForegroundColor Green
