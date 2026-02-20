; GurupiaStudio_Setup.iss
; Gurupia Inno Studio 설치 스크립트
; 포터블 .NET IDE + ISCC.exe (Zstd/Brotli 지원) 패키지

[Setup]
AppName=Gurupia Inno Studio
AppVersion=2.0.0
AppPublisher=Gurupia
AppPublisherURL=https://github.com/gurupia/issrc
AppSupportURL=https://github.com/gurupia/issrc/issues
AppUpdatesURL=https://github.com/gurupia/issrc
DefaultDirName={autopf}\GurupiaInnoStudio
DefaultGroupName=Gurupia Inno Studio
AllowNoIcons=yes
; 고DPI 지원
WizardStyle=modern
; 설치파일 출력 설정
OutputDir=Output
OutputBaseFilename=GurupiaStudio_v2.0_Setup
Compression=lzma2/ultra64
SolidCompression=yes
; 언팩 설정
UninstallDisplayIcon={app}\InnoSetupIDE.exe
UninstallDisplayName=Gurupia Inno Studio
; 최소 OS: Windows 10
MinVersion=10.0.17763
VersionInfoVersion=2.0.0.0
VersionInfoCompany=Gurupia
VersionInfoDescription=Gurupia Inno Studio - Professional Inno Setup IDE with Zstd/Brotli Compression

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "바탕화면 바로가기 생성"; GroupDescription: "추가 아이콘:"; Flags: unchecked
Name: "fileassoc"; Description: ".iss 파일 연결"; GroupDescription: "파일 연결:"

[Files]
; 메인 IDE 실행파일
Source: "InnoSetupIDE-Portable\InnoSetupIDE.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "InnoSetupIDE-Portable\InnoSetupIDE.exe.config"; DestDir: "{app}"; Flags: ignoreversion

; Scintilla 편집기
Source: "InnoSetupIDE-Portable\ScintillaNET.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "InnoSetupIDE-Portable\ScintillaNET.xml"; DestDir: "{app}"; Flags: ignoreversion

; Inno Setup 컴파일러 (Zstd/Brotli 지원 버전)
Source: "InnoSetupIDE-Portable\ISCC.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "InnoSetupIDE-Portable\ISCmplr.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "InnoSetupIDE-Portable\ISPP.dll"; DestDir: "{app}"; Flags: ignoreversion

; 압축 라이브러리
Source: "InnoSetupIDE-Portable\iszstd.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "InnoSetupIDE-Portable\islzma.dll"; DestDir: "{app}"; Flags: ignoreversion

; 언어 파일
Source: "InnoSetupIDE-Portable\Default.isl"; DestDir: "{app}"; Flags: ignoreversion

; 런타임 파일
Source: "InnoSetupIDE-Portable\Setup.e32"; DestDir: "{app}"; Flags: ignoreversion
Source: "InnoSetupIDE-Portable\Setup.e64"; DestDir: "{app}"; Flags: ignoreversion
Source: "InnoSetupIDE-Portable\SetupLdr.e32"; DestDir: "{app}"; Flags: ignoreversion
Source: "InnoSetupIDE-Portable\SetupLdr.e64"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\Gurupia Inno Studio"; Filename: "{app}\InnoSetupIDE.exe"; WorkingDir: "{app}"
Name: "{group}\{cm:UninstallProgram,Gurupia Inno Studio}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\Gurupia Inno Studio"; Filename: "{app}\InnoSetupIDE.exe"; WorkingDir: "{app}"; Tasks: desktopicon

[Run]
Filename: "{app}\InnoSetupIDE.exe"; Description: "Gurupia Inno Studio 실행"; Flags: nowait postinstall skipifsilent

[Registry]
; .iss 파일 연결
Root: HKCR; Subkey: ".iss"; ValueType: string; ValueName: ""; ValueData: "GurupiaInnoScript"; Flags: uninsdeletevalue; Tasks: fileassoc
Root: HKCR; Subkey: "GurupiaInnoScript"; ValueType: string; ValueName: ""; ValueData: "Inno Setup Script"; Flags: uninsdeletekey; Tasks: fileassoc
Root: HKCR; Subkey: "GurupiaInnoScript\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\InnoSetupIDE.exe,0"; Tasks: fileassoc
Root: HKCR; Subkey: "GurupiaInnoScript\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\InnoSetupIDE.exe"" ""%1"""; Tasks: fileassoc
