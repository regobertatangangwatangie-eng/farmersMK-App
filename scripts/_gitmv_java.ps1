$env:PATH += ";C:\Program Files\Git\bin;C:\Program Files\Git\cmd"
Set-Location "C:\Users\SOLUTIONS\Downloads\FARMERPRO-APP"
$root = "C:\Users\SOLUTIONS\Downloads\FARMERPRO-APP"
$moved = 0; $errors = 0

Get-ChildItem "$root\services" -Directory | ForEach-Object {
    $svcDir = $_
    foreach ($srcSub in @("src\main\java","src\test\java")) {
        $jRootAbs = "$($svcDir.FullName)\$srcSub"
        $jRootRel = "services/$($svcDir.Name)/" + $srcSub.Replace("\","/")
        if (-not (Test-Path $jRootAbs)) { continue }
        Get-ChildItem $jRootAbs -Recurse -Filter "*.java" | ForEach-Object {
            $f = $_
            $c = [System.IO.File]::ReadAllText($f.FullName,[System.Text.Encoding]::UTF8).TrimStart([char]0xFEFF)
            if ($c -match "(?m)^package\s+([\w\.]+)\s*;") {
                $relDir = $matches[1].Replace(".","/" )
                $oldRel = $f.FullName.Replace("$root\","").Replace("\","/")
                $newRel = "$jRootRel/$relDir/$($f.Name)"
                if ($oldRel -ne $newRel) {
                    $newDirAbs = "$root\" + $newRel.Replace("/","\") | Split-Path
                    if (-not (Test-Path $newDirAbs)) { New-Item -ItemType Directory -Path $newDirAbs -Force | Out-Null }
                    $result = git mv $oldRel $newRel 2>&1
                    if ($LASTEXITCODE -eq 0) { Write-Host "OK: $($f.Name)"; $moved++ }
                    else { Write-Host "ERR ($($f.Name)): $result"; $errors++ }
                }
            }
        }
    }
}
Write-Host "Done. moved=$moved errors=$errors"
