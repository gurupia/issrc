$files = @(
    "02_Architecture_and_Strategy\DOTNET_PORTING_ANALYSIS.md",
    "02_Architecture_and_Strategy\HYBRID_DOTNET_IDE_STRATEGY.md",
    "02_Architecture_and_Strategy\IDE_INTEGRATION.md",
    "02_Architecture_and_Strategy\SETUP_STUB_REALITY.md",
    "02_Architecture_and_Strategy\SIMPLE_SOLUTION.md"
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
