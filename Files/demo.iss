; Demo script for custom Inno Setup IDE with Zstd support
[Setup]
AppName=Gurupia Zstd Demo
AppVersion=1.0
DefaultDirName={pf}\GurupiaDemo
OutputDir=Output
OutputBaseFilename=gurupia_demo_setup
; Use the custom Zstd compression added to the engine
Compression=zstd

[Files]
; Using notepad.exe as a guaranteed existing file for testing
Source: "C:\Windows\notepad.exe"; DestDir: "{app}"; DestName: "MyProg.exe"

[Icons]
Name: "{group}\Gurupia Demo"; Filename: "{app}\MyProg.exe"
