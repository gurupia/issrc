[Setup]
AppName=Test Application
AppVersion=1.0
DefaultDirName={pf}\TestApp
OutputDir=Output
OutputBaseFilename=testsetup
Compression=lzma2

[Files]
Source: "C:\Windows\notepad.exe"; DestDir: "{app}"
