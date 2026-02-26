$file = "03_Guides_and_Manuals/DELPHI_VERSION_GUIDE.md"
if (Test-Path $file) {
    $content = Get-Content -Path $file -Encoding UTF8
    
    for ($i = 0; $i -lt $content.Length; $i++) {
        if ($content[$i] -match '^\|\s*\*\*Delphi 7\*\*') {
            $content[$i] = '| **Delphi 7**     | 2002  | ~500MB | 가볍고 빠름 |'
        }
        elseif ($content[$i] -match '^\|\s*\*\*Delphi XE7\*\*') {
            $content[$i] = '| **Delphi XE7**   | 2014  | ~3GB   | 중간        |'
        }
        elseif ($content[$i] -match '^\|\s*\*\*Delphi 10.4\*\*') {
            $content[$i] = '| **Delphi 10.4**  | 2020  | ~6GB   | 무거움      |'
        }
        elseif ($content[$i] -match '^\|\s*\*\*Delphi 12.3\*\*') {
            $content[$i] = '| **Delphi 12.3**  | 2024  | ~8GB   | 매우 무거움 |'
        }
        elseif ($content[$i] -match '^\|------\|-----\|-----\|-----\|') {
            $content[$i] = '| ---------------- | ----- | ------ | ----------- |'
        }
        elseif ($content[$i] -match '^\*\*A:\s*가능하지만\s*권장하지\s*않습니다\*\*') {
            $content[$i] = 'A: **가능하지만 권장하지 않습니다**'
        }
    }
    
    [System.IO.File]::WriteAllLines((Resolve-Path $file).Path, $content, [System.Text.Encoding]::UTF8)
    Write-Host "Success"
}
