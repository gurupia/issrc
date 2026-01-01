program SimpleDLLTest;

{$IFDEF FPC}
  {$mode objfpc}{$H+}
{$ENDIF}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  SysUtils, Windows;

var
  ZstdHandle32, ZstdHandle64: THandle;
  FilesDir: String;
  
procedure TestDLL(const DLLName: String);
var
  Handle: THandle;
  FullPath: String;
begin
  FullPath := FilesDir + DLLName;
  
  Write('Testing ', DLLName, '... ');
  
  if not FileExists(FullPath) then
  begin
    WriteLn('[NOT FOUND]');
    WriteLn('  Path: ', FullPath);
    Exit;
  end;
  
  Handle := LoadLibrary(PChar(FullPath));
  
  if Handle <> 0 then
  begin
    WriteLn('[OK]');
    WriteLn('  Handle: $', IntToHex(Handle, 8));
    WriteLn('  Size: ', FileSize(FullPath) div 1024, ' KB');
    FreeLibrary(Handle);
  end
  else
  begin
    WriteLn('[LOAD FAILED]');
    WriteLn('  Error: ', GetLastError);
  end;
  
  WriteLn;
end;

function FileSize(const FileName: String): Int64;
var
  SearchRec: TSearchRec;
begin
  if FindFirst(FileName, faAnyFile, SearchRec) = 0 then
  begin
    Result := SearchRec.Size;
    FindClose(SearchRec);
  end
  else
    Result := 0;
end;

begin
  WriteLn;
  WriteLn('========================================');
  WriteLn('  Smart Compression DLL Test');
  WriteLn('  Free Pascal Compatible');
  WriteLn('========================================');
  WriteLn;
  
  // Get Files directory
  FilesDir := ExtractFilePath(ParamStr(0)) + '..\..\Files\';
  WriteLn('Files directory: ', FilesDir);
  WriteLn;
  
  WriteLn('Testing Zstandard DLLs:');
  WriteLn('----------------------------------------');
  TestDLL('iszstd.dll');
  TestDLL('iszstd-x64.dll');
  
  WriteLn('Testing Brotli DLLs:');
  WriteLn('----------------------------------------');
  TestDLL('isbrotlicommon.dll');
  TestDLL('isbrotlienc.dll');
  TestDLL('isbrotlidec.dll');
  TestDLL('isbrotlicommon-x64.dll');
  TestDLL('isbrotlienc-x64.dll');
  TestDLL('isbrotlidec-x64.dll');
  
  WriteLn('========================================');
  WriteLn('Test Complete!');
  WriteLn('========================================');
  WriteLn;
  WriteLn('Summary:');
  WriteLn('  - If DLLs are [OK], smart compression is ready');
  WriteLn('  - If [NOT FOUND], run: Components\download-dlls.bat');
  WriteLn('  - Brotli DLLs are optional (use vcpkg)');
  WriteLn;
  WriteLn('Press ENTER to exit...');
  ReadLn;
end.
