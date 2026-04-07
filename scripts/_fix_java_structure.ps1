# Fix Java package directory structure for all services and test dirs
$svcRoot = "C:\Users\SOLUTIONS\Downloads\FARMERPRO-APP\services"
$clRoot  = "C:\Users\SOLUTIONS\Downloads\FARMERPRO-APP\farmersmk-common-lib"
$roots   = @($svcRoot, $clRoot)
$moved=0; $skipped=0; $errors=0
foreach ($searchRoot in $roots) {
    if (-not (Test-Path $searchRoot)) { continue }
    foreach ($svcDir in (Get-ChildItem $searchRoot -Directory)) {
        foreach ($jRoot in @("$($svcDir.FullName)\src\main\java","$($svcDir.FullName)\src\test\java")) {
            if (-not (Test-Path $jRoot)) { continue }
            foreach ($f in (Get-ChildItem $jRoot -Recurse -Filter "*.java")) {
                if ($f.Length -eq 0) { continue }
                $c = [System.IO.File]::ReadAllText($f.FullName,[System.Text.Encoding]::UTF8).TrimStart([char]0xFEFF)
                if ($c -match '(?m)^package\s+([\w\.]+)\s*;') {
                    $exp = $jRoot + "\" + $matches[1].Replace(".","\")
                    if ($f.DirectoryName -ne $exp) {
                        New-Item -ItemType Directory -Path $exp -Force 2>$null | Out-Null
                        $dest = "$exp\$($f.Name)"
                        if (Test-Path $dest) { $skipped++ }
                        else { try { Move-Item $f.FullName $dest -Force; Write-Host "MOVED $($f.Name)"; $moved++ } catch { Write-Host "ERR $_"; $errors++ } }
                    }
                }
            }
            # remove empty dirs
            Get-ChildItem $jRoot -Recurse -Directory | Where-Object { (Get-ChildItem $_.FullName -Recurse -File).Count -eq 0 } | Sort-Object { $_.FullName.Length } -Descending | ForEach-Object { Remove-Item $_.FullName -Force -EA SilentlyContinue }
        }
    }
}
Write-Host "Done. Moved=$moved Skipped=$skipped Errors=$errors"
