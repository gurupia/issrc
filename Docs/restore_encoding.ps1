$files = @(
    "02_Architecture_and_Strategy\DOTNET_PORTING_ANALYSIS.md",
    "02_Architecture_and_Strategy\HYBRID_DOTNET_IDE_STRATEGY.md",
    "02_Architecture_and_Strategy\IDE_INTEGRATION.md",
    "02_Architecture_and_Strategy\SETUP_STUB_REALITY.md",
    "02_Architecture_and_Strategy\SIMPLE_SOLUTION.md",
    "03_Guides_and_Manuals\QUICK_START.md",
    "03_Guides_and_Manuals\GETTING_STARTED_SMART_COMPRESSION.md",
    "03_Guides_and_Manuals\FREE_PASCAL_GUIDE.md",
    "03_Guides_and_Manuals\DELPHI_VERSION_GUIDE.md"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        $doubleEncodedBytes = [System.IO.File]::ReadAllBytes($file)
        
        # UTF-8 -> String (Mojibake) -> CP949 Bytes -> Pure UTF-8 Bytes
        $mojibakeString = [System.Text.Encoding]::UTF8.GetString($doubleEncodedBytes)
        $originalUtf8Bytes = [System.Text.Encoding]::GetEncoding(949).GetBytes($mojibakeString)
        
        [System.IO.File]::WriteAllBytes($file, $originalUtf8Bytes)
        Write-Host "Restored $file"
    }
}
