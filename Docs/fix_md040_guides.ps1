$files = @(
    "03_Guides_and_Manuals\DELPHI_VERSION_GUIDE.md"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        $content = [System.IO.File]::ReadAllText($file)
        $content = [System.Text.RegularExpressions.Regex]::Replace($content, '(?m)^```\s*$', '```txt')
        [System.IO.File]::WriteAllText($file, $content)
        Write-Host "Fixed: $file"
    }
    else {
        Write-Host "Not found: $file"
    }
}
