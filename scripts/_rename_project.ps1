
$root = "C:\Users\SOLUTIONS\Downloads\FARMERPRO-APP"
$excludePatterns = 'node_modules|\\\.git\\|\\target\\|\.class$|\.jar$|\.png$|\.jpg$|\.jpeg$|\.gif$|\.ico$|\.svg$|\.ttf$|\.woff|\.eot$|\.apk$|\.zip$|\.tar$|\.gz$|\.ppk$|\.pem$|\.p12$|package-lock\.json$|_rename_project\.ps1$'
# UTF-8 WITHOUT BOM — Java/Linux tools reject UTF-8 BOM (\ufeff)
$utf8NoBOM = New-Object System.Text.UTF8Encoding($false)

$files = Get-ChildItem -Path $root -Recurse -File | Where-Object { $_.FullName -notmatch $excludePatterns }
Write-Host "Files to process: $($files.Count)"

$changedFiles = 0
foreach ($file in $files) {
    try {
        $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
        # Skip binary files (contain null bytes)
        if ($bytes -contains 0) { continue }

        $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
        $original = $content

        # Most-specific first
        $content = $content -replace 'FARMERPRO-APP', 'farmersmk.com'
        $content = $content -replace 'FARMERPRO_APP', 'FARMERSMK_COM'
        $content = $content -replace 'FARMERPRO', 'farmersmk'
        $content = $content -replace 'FarmerPro', 'FarmersMK'
        $content = $content -replace 'FarmPro', 'FarmersMK'
        $content = $content -replace 'com\.farmpro', 'com.farmersmk'
        $content = $content -replace '/opt/farmerpro', '/opt/farmersmk'
        $content = $content -replace 'farmpro_secret', 'farmersmk_secret'
        $content = $content -replace 'farmprodb', 'farmersmkdb'
        $content = $content -replace 'farmpro\.local', 'farmersmk.local'
        $content = $content -replace 'farmpro-', 'farmersmk-'
        $content = $content -replace "farmpro'", "farmersmk'"
        $content = $content -replace 'farmpro_', 'farmersmk_'
        $content = $content -replace '"farmpro"', '"farmersmk"'
        $content = $content -replace ': farmpro', ': farmersmk'
        $content = $content -replace '-U farmpro', '-U farmersmk'
        $content = $content -replace '(?<![a-zA-Z0-9])farmpro(?![a-zA-Z0-9])', 'farmersmk'

        if ($content -ne $original) {
            [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBOM)
            $changedFiles++
            Write-Host "  Updated: $($file.FullName.Replace($root, ''))"
        }
    }
    catch {
        Write-Host "  SKIP: $($file.Name)"
    }
}

Write-Host "`nContent replacement complete. $changedFiles files updated."

# ── Rename directories (deepest paths first to avoid breaking parent references)
Write-Host "`nRenaming directories..."
$renamedDirs = 0

# Helper: rename all dirs matching a pattern under a given path, deepest first
function Rename-FarmpoDirs($searchRoot, $pattern, $replacement) {
    if (-not (Test-Path $searchRoot)) { return }
    $dirs = Get-ChildItem -Path $searchRoot -Directory -Recurse |
        Where-Object { $_.Name -match $pattern } |
        Sort-Object FullName -Descending
    foreach ($dir in $dirs) {
        $newName = $dir.Name -replace $pattern, $replacement
        Rename-Item -Path $dir.FullName -NewName $newName -ErrorAction SilentlyContinue
        Write-Host "  Renamed dir: $($dir.Name) -> $newName"
        $script:renamedDirs++
    }
}

# Top-level farmerpro-* folders (e.g. farmerpro-terraform)
$topDirs = Get-ChildItem -Path $root -Directory |
    Where-Object { $_.Name -imatch '^farmerpro-' }
foreach ($dir in $topDirs) {
    $newName = $dir.Name -replace '(?i)^farmerpro-', 'farmersmk-'
    Move-Item -Path $dir.FullName -Destination (Join-Path $root $newName) -Force -ErrorAction SilentlyContinue
    Write-Host "  Renamed dir: $($dir.Name) -> $newName"
    $renamedDirs++
}

# Top-level farmpro-* project folders
$topDirs2 = Get-ChildItem -Path $root -Directory |
    Where-Object { $_.Name -imatch '^farmpro-' }
foreach ($dir in $topDirs2) {
    $newName = $dir.Name -replace '(?i)^farmpro-', 'farmersmk-'
    Move-Item -Path $dir.FullName -Destination (Join-Path $root $newName) -Force -ErrorAction SilentlyContinue
    Write-Host "  Renamed dir: $($dir.Name) -> $newName"
    $renamedDirs++
}

# services\ farmpro-* dirs
Rename-FarmpoDirs "$root\services"  '^farmpro-'    'farmersmk-'

# docs\ farmpro-* dirs
Rename-FarmpoDirs "$root\docs"      '^farmpro-'    'farmersmk-'

# DevOps sub-folders farmpro-*
Rename-FarmpoDirs "$root\DevOps"    '^farmpro-'    'farmersmk-'

# Java package dirs: com\farmpro -> com\farmersmk (all src/test/target trees)
$javaDirs = Get-ChildItem $root -Recurse -Directory |
    Where-Object { $_.Name -eq 'farmpro' -and $_.Parent.Name -eq 'com' } |
    Sort-Object FullName -Descending
foreach ($dir in $javaDirs) {
    Rename-Item -Path $dir.FullName -NewName 'farmersmk' -ErrorAction SilentlyContinue
    Write-Host "  Renamed Java pkg dir: $($dir.FullName.Replace($root,''))"
    $renamedDirs++
}

# ── Rename files with farmpro/farmerpro in their name ───────────────────────
Write-Host "`nRenaming files..."
$renamedFiles = 0
$allFiles = Get-ChildItem $root -Recurse -File |
    Where-Object { $_.Name -imatch 'farmpro' -and $_.FullName -notmatch '\\target\\|\\node_modules\\' }
foreach ($f in ($allFiles | Sort-Object FullName -Descending)) {
    $newName = $f.Name `
        -replace '(?i)^farmerpro-', 'farmersmk-' `
        -replace '(?i)^farmpro-',   'farmersmk-' `
        -replace '(?i)farmproApi',  'farmersmkApi'
    if ($newName -ne $f.Name) {
        Rename-Item -Path $f.FullName -NewName $newName -ErrorAction SilentlyContinue
        Write-Host "  Renamed file: $($f.Name) -> $newName"
        $renamedFiles++
    }
}

# ── Fix kustomization.yaml resource paths after file renames ─────────────────
$kustomFile = "$root\kubernetes\kustomization.yaml"
if (Test-Path $kustomFile) {
    $k = Get-Content $kustomFile -Raw
    $k2 = $k -replace '(?i)(deployments|services|ingress)/farmpro-', '$1/farmersmk-'
    if ($k2 -ne $k) {
        [System.IO.File]::WriteAllText($kustomFile, $k2, $utf8NoBOM)
        Write-Host "  Updated: \kubernetes\kustomization.yaml"
    }
}

Write-Host "`nDirectory renames: $renamedDirs  |  File renames: $renamedFiles"
Write-Host "`n=== RENAME COMPLETE ==="
