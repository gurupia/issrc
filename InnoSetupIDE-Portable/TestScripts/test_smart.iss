[Setup]
AppName=Smart Compression Test
AppVersion=1.0
DefaultDirName={pf}\Smart Compression Test
DefaultGroupName=Smart Compression Test
OutputDir=Output
OutputBaseFilename=setup_smart
; Enable Smart Compression
Compression=smart
SolidCompression=yes

[Files]
; 1. Binary/Executable (Should use Zstd)
Source: "..\Files\ISCC.exe"; DestDir: "{app}"; Flags: ignoreversion

; 2. Text/Pascal (Should use LZMA2 or Zstd)
Source: "..\Projects\Src\Compiler.SetupCompiler.pas"; DestDir: "{app}\src"; Flags: ignoreversion

; 3. XML/Text (Should use LZMA2)
Source: "..\ishelp\isetup.xml"; DestDir: "{app}\help"; Flags: ignoreversion

; 4. Medium size binary (Should use Zstd)
Source: "..\Files\iszstd.dll"; DestDir: "{app}"; Flags: ignoreversion

; 5. Archived file (Should be Stored or light Zstd)
Source: "..\Files\zstd.zip"; DestDir: "{app}"; Flags: ignoreversion
