; Simple Test Script for .NET IDE
; Uses files from the portable folder

[Setup]
AppName=Test Application
AppVersion=1.0
DefaultDirName={pf}\TestApp
OutputDir=Output
OutputBaseFilename=TestSetup
Compression=lzma2

[Files]
; Use files that exist in the portable folder
Source: "Default.isl"; DestDir: "{app}"; Flags: ignoreversion
Source: "ScintillaNET.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "ScintillaNET.xml"; DestDir: "{app}"; Flags: ignoreversion
