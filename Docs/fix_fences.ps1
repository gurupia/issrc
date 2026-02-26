$files = Get-ChildItem -Path "02_Architecture_and_Strategy", "03_Guides_and_Manuals" -Filter "*.md" | Select-Object -ExpandProperty FullName
foreach ($file in $files) {
    if (Test-Path $file) {
        $lines = Get-Content $file
        $inBlock = $false
        for ($i = 0; $i -lt $lines.Count; $i++) {
            $stripped = $lines[$i].Trim()
            if ($stripped.StartsWith('```')) {
                if (-not $inBlock) {
                    $inBlock = $true
                    if ($stripped -eq '```') {
                        $lines[$i] = $lines[$i].Replace('```', '```txt')
                    }
                }
                else {
                    $inBlock = $false
                    $lines[$i] = $lines[$i].Replace($stripped, '```')
                }
            }
        }
        [System.IO.File]::WriteAllLines($file, $lines, [System.Text.Encoding]::UTF8)
        Write-Host "Fixed: $file"
    }
}
