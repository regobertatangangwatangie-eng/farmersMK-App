$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$servicesDir = Join-Path $repoRoot "services"

if (-not (Test-Path $servicesDir)) {
    throw "services directory not found: $servicesDir"
}

$serviceDirs = Get-ChildItem -Path $servicesDir -Directory -ErrorAction SilentlyContinue |
    Where-Object {
        $_.Name -like "FarmersMK-*" -and (
            (Test-Path (Join-Path $_.FullName "pom.xml")) -or
            (Test-Path (Join-Path $_.FullName "Dockerfile")) -or
            (Test-Path (Join-Path $_.FullName "dockerfile")) -or
            (Test-Path (Join-Path $_.FullName "src"))
        )
    } |
    Sort-Object Name

if (-not $serviceDirs) {
    throw "No valid services found under $servicesDir"
}

$catalog = @()
foreach ($svc in $serviceDirs) {
    $sourceFile = Join-Path $svc.FullName "SERVICE_SOURCE.txt"
    $relativeSource = ".\\services\\$($svc.Name)"
    Set-Content -Path $sourceFile -Value $relativeSource -Encoding ASCII

    $catalog += [PSCustomObject]@{
        service = $svc.Name
        source  = $relativeSource
    }
}

$catalogPath = Join-Path $servicesDir "catalog.json"
$catalog | ConvertTo-Json -Depth 4 | Set-Content -Path $catalogPath -Encoding ASCII

Write-Host "Synchronized $($catalog.Count) services into services/ catalog."
