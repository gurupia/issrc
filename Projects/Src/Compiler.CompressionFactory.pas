unit Compiler.CompressionFactory;

{
  Inno Setup - Smart Compression
  Copyright (C) 1997-2026 Jordan Russell
  Portions by Martijn Laan
  For conditions of distribution and use, see LICENSE.TXT.

  Compression factory - creates appropriate compressor based on method
}

interface

uses
  SysUtils,
  Shared.Struct, Compression.Base, Compression.Brotli, Compression.Zstd,
  Compression.SmartSelector, Compiler.CompressionDLLs;

{ Factory function to get compressor class from compression method }
function GetCompressorClass(const Method: TSetupCompressMethod;
  const FileName: String = ''): TCustomCompressorClass;

{ Get recommended compression level for method }
function GetDefaultCompressionLevel(const Method: TSetupCompressMethod): Integer;

{ Check if compression method is available }
function IsCompressionMethodAvailable(const Method: TSetupCompressMethod): Boolean;

implementation

uses
  Compression.LZMACompressor, Compression.Zlib;

function GetCompressorClass(const Method: TSetupCompressMethod;
  const FileName: String): TCustomCompressorClass;
var
  Category: TFileCategory;
  Strategy: TCompressionLevel;
begin
  case Method of
    cmStored:
      Result := nil;  { No compression }
      
    cmZip:
      Result := TZCompressor;
      
    cmBzip:
      Result := nil;  { Not implemented in this version }
      
    cmLZMA:
      Result := TLZMACompressor;
      
    cmLZMA2:
      Result := TLZMA2Compressor;
      
    cmBrotli:
      begin
        if IsBrotliAvailable then
          Result := TBrotliCompressor
        else
          Result := TLZMA2Compressor;  { Fallback to LZMA2 }
      end;
      
    cmZstd:
      begin
        if IsZstdAvailable then
          Result := TZstdCompressor
        else
          Result := TLZMA2Compressor;  { Fallback to LZMA2 }
      end;
      
    cmSmart:
      begin
        { Smart selection based on file type }
        if FileName <> '' then begin
          Category := DetectFileCategory(FileName);
          Strategy := SelectCompressionStrategy(Category, 0, scmAuto);
          
          case Strategy.Strategy of
            csStored:
              Result := nil;
              
            csBrotli:
              if IsBrotliAvailable then
                Result := TBrotliCompressor
              else
                Result := TLZMA2Compressor;
                
            csZstd:
              if IsZstdAvailable then
                Result := TZstdCompressor
              else
                Result := TLZMA2Compressor;
                
            csLZMA2:
              Result := TLZMA2Compressor;
          else
            Result := TLZMA2Compressor;  { Default fallback }
          end;
        end
        else
          Result := TLZMA2Compressor;  { No filename - use default }
      end;
  else
    Result := TLZMA2Compressor;  { Unknown method - use default }
  end;
end;

function GetDefaultCompressionLevel(const Method: TSetupCompressMethod): Integer;
begin
  case Method of
    cmStored: Result := 0;
    cmZip: Result := 6;      { Zlib default }
    cmBzip: Result := 9;
    cmLZMA: Result := 2;     { Normal }
    cmLZMA2: Result := 2;    { Normal }
    cmBrotli: Result := 6;   { Brotli balanced }
    cmZstd: Result := 6;     { Zstd normal }
    cmSmart: Result := 6;    { Auto mode default }
  else
    Result := 2;  { Default to LZMA2 normal }
  end;
end;

function IsCompressionMethodAvailable(const Method: TSetupCompressMethod): Boolean;
begin
  case Method of
    cmStored, cmZip, cmLZMA, cmLZMA2:
      Result := True;  { Always available }
      
    cmBzip:
      Result := False;  { Not implemented }
      
    cmBrotli:
      Result := IsBrotliAvailable;
      
    cmZstd:
      Result := IsZstdAvailable;
      
    cmSmart:
      Result := IsBrotliAvailable or IsZstdAvailable;  { At least one must be available }
  else
    Result := False;
  end;
end;

end.
