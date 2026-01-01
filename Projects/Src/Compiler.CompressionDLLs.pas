unit Compiler.CompressionDLLs;

{
  Inno Setup - Smart Compression
  Copyright (C) 1997-2026 Jordan Russell
  Portions by Martijn Laan
  For conditions of distribution and use, see LICENSE.TXT.

  DLL loading and initialization for compression libraries
}

interface

uses
  Windows, SysUtils;

{ DLL Loading Functions }
function InitializeCompressionDLLs: Boolean;
procedure FinalizeCompressionDLLs;

{ Individual DLL loaders }
function LoadBrotliDLL: Boolean;
function LoadZstdDLL: Boolean;
procedure UnloadBrotliDLL;
procedure UnloadZstdDLL;

{ Status queries }
function IsBrotliAvailable: Boolean;
function IsZstdAvailable: Boolean;

implementation

uses
  Compression.Brotli, Compression.Zstd;

var
  BrotliDLLHandle: HMODULE = 0;
  ZstdDLLHandle: HMODULE = 0;
  BrotliLoaded: Boolean = False;
  ZstdLoaded: Boolean = False;

function GetDLLPath(const DLLName: String): String;
begin
  { DLLs are in the same directory as the compiler executable }
  Result := ExtractFilePath(ParamStr(0)) + DLLName;
end;

function LoadBrotliDLL: Boolean;
const
  {$IFDEF WIN64}
  BrotliCommonDLL = 'isbrotlicommon-x64.dll';
  BrotliEncDLL = 'isbrotlienc-x64.dll';
  BrotliDecDLL = 'isbrotlidec-x64.dll';
  {$ELSE}
  BrotliCommonDLL = 'isbrotlicommon.dll';
  BrotliEncDLL = 'isbrotlienc.dll';
  BrotliDecDLL = 'isbrotlidec.dll';
  {$ENDIF}
var
  CommonHandle, EncHandle, DecHandle: HMODULE;
begin
  Result := False;
  
  if BrotliLoaded then begin
    Result := True;
    Exit;
  end;

  try
    { Load Brotli DLLs (requires 3 DLLs: common, encoder, decoder) }
    CommonHandle := LoadLibrary(PChar(GetDLLPath(BrotliCommonDLL)));
    if CommonHandle = 0 then
      Exit;

    EncHandle := LoadLibrary(PChar(GetDLLPath(BrotliEncDLL)));
    if EncHandle = 0 then begin
      FreeLibrary(CommonHandle);
      Exit;
    end;

    DecHandle := LoadLibrary(PChar(GetDLLPath(BrotliDecDLL)));
    if DecHandle = 0 then begin
      FreeLibrary(EncHandle);
      FreeLibrary(CommonHandle);
      Exit;
    end;

    { Initialize function pointers }
    if not BrotliInitCompressFunctions(EncHandle) then begin
      FreeLibrary(DecHandle);
      FreeLibrary(EncHandle);
      FreeLibrary(CommonHandle);
      Exit;
    end;

    if not BrotliInitDecompressFunctions(DecHandle) then begin
      FreeLibrary(DecHandle);
      FreeLibrary(EncHandle);
      FreeLibrary(CommonHandle);
      Exit;
    end;

    { Store handle (we'll use the encoder handle as the main one) }
    BrotliDLLHandle := EncHandle;
    BrotliLoaded := True;
    Result := True;
  except
    Result := False;
  end;
end;

function LoadZstdDLL: Boolean;
const
  {$IFDEF WIN64}
  ZstdDLLName = 'iszstd-x64.dll';
  {$ELSE}
  ZstdDLLName = 'iszstd.dll';
  {$ENDIF}
begin
  Result := False;
  
  if ZstdLoaded then begin
    Result := True;
    Exit;
  end;

  try
    { Load Zstandard DLL }
    ZstdDLLHandle := LoadLibrary(PChar(GetDLLPath(ZstdDLLName)));
    if ZstdDLLHandle = 0 then
      Exit;

    { Initialize function pointers }
    if not ZstdInitCompressFunctions(ZstdDLLHandle) then begin
      FreeLibrary(ZstdDLLHandle);
      ZstdDLLHandle := 0;
      Exit;
    end;

    if not ZstdInitDecompressFunctions(ZstdDLLHandle) then begin
      FreeLibrary(ZstdDLLHandle);
      ZstdDLLHandle := 0;
      Exit;
    end;

    ZstdLoaded := True;
    Result := True;
  except
    Result := False;
  end;
end;

procedure UnloadBrotliDLL;
begin
  if BrotliDLLHandle <> 0 then begin
    FreeLibrary(BrotliDLLHandle);
    BrotliDLLHandle := 0;
    BrotliLoaded := False;
  end;
end;

procedure UnloadZstdDLL;
begin
  if ZstdDLLHandle <> 0 then begin
    FreeLibrary(ZstdDLLHandle);
    ZstdDLLHandle := 0;
    ZstdLoaded := False;
  end;
end;

function IsBrotliAvailable: Boolean;
begin
  Result := BrotliLoaded;
end;

function IsZstdAvailable: Boolean;
begin
  Result := ZstdLoaded;
end;

function InitializeCompressionDLLs: Boolean;
var
  BrotliOK, ZstdOK: Boolean;
begin
  { Try to load both DLLs, but don't fail if they're not available }
  { This allows compilation to continue with legacy compression methods }
  
  BrotliOK := LoadBrotliDLL;
  ZstdOK := LoadZstdDLL;
  
  { Return true if at least one new compression method is available }
  Result := BrotliOK or ZstdOK;
  
  { Note: If both fail, the compiler can still use LZMA/LZMA2 }
end;

procedure FinalizeCompressionDLLs;
begin
  UnloadBrotliDLL;
  UnloadZstdDLL;
end;

initialization
  { DLLs will be loaded on demand }

finalization
  FinalizeCompressionDLLs;

end.
