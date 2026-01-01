unit Compression.SmartSelector;

{
  Inno Setup - Smart Compression
  Copyright (C) 1997-2026 Jordan Russell
  Portions by Martijn Laan
  For conditions of distribution and use, see LICENSE.TXT.

  Smart compression algorithm selector
  Automatically selects optimal compression based on file type and characteristics
}

interface

uses
  Windows, SysUtils, Classes;

type
  { File categories for compression strategy selection }
  TFileCategory = (
    fcTextWeb,      // HTML, CSS, JS, JSON, XML, SVG → Brotli优先
    fcTextDoc,      // TXT, MD, LOG, CSV, INI, CFG → Brotli优先
    fcBinary,       // EXE, DLL, SYS, OCX → Zstd优先
    fcArchive,      // ZIP, 7Z, RAR, GZ → Stored (already compressed)
    fcImageComp,    // JPG, PNG, GIF, WEBP → Stored (already compressed)
    fcImageRaw,     // BMP, TIFF, ICO → Zstd
    fcAudioVideo,   // MP3, MP4, AVI, MKV → Stored (already compressed)
    fcData,         // DAT, DB, BIN → Zstd
    fcUnknown       // Unknown extension → Zstd (safe default)
  );

  { Compression strategies }
  TCompressionStrategy = (
    csStored,       // No compression
    csBrotli,       // Brotli compression (text优先)
    csZstd,         // Zstandard compression (binary优先)
    csLZMA2         // LZMA2 (legacy/compatibility)
  );

  { Smart compression modes }
  TSmartCompressionMode = (
    scmAuto,        // Automatic selection (recommended)
    scmAggressive,  // Maximum compression, slower
    scmBalanced,    // Balance between speed and size
    scmFast,        // Fastest compression
    scmLegacy       // Use LZMA2 for everything (compatibility)
  );

  { Compression level for selected strategy }
  TCompressionLevel = record
    Strategy: TCompressionStrategy;
    Level: Integer;  // Algorithm-specific level
  end;

{ Main selection functions }
function DetectFileCategory(const FileName: String): TFileCategory;
function SelectCompressionStrategy(
  const Category: TFileCategory;
  const FileSize: Int64;
  const Mode: TSmartCompressionMode
): TCompressionLevel;

{ Helper functions }
function GetFileExtension(const FileName: String): String;
function CategoryToString(const Category: TFileCategory): String;
function StrategyToString(const Strategy: TCompressionStrategy): String;
function ModeToString(const Mode: TSmartCompressionMode): String;

implementation

{ File extension mapping to categories }
const
  { Web content extensions }
  WebExtensions: array[0..11] of String = (
    '.html', '.htm', '.css', '.js', '.json', '.xml',
    '.svg', '.wasm', '.ttf', '.eot', '.woff', '.woff2'
  );

  { Document extensions }
  DocExtensions: array[0..9] of String = (
    '.txt', '.md', '.log', '.csv', '.ini', '.cfg',
    '.conf', '.yaml', '.yml', '.toml'
  );

  { Binary executable extensions }
  BinaryExtensions: array[0..9] of String = (
    '.exe', '.dll', '.sys', '.ocx', '.cpl',
    '.scr', '.drv', '.ax', '.so', '.dylib'
  );

  { Archive extensions (already compressed) }
  ArchiveExtensions: array[0..11] of String = (
    '.zip', '.7z', '.rar', '.gz', '.bz2', '.xz',
    '.tar', '.tgz', '.tbz', '.zst', '.br', '.cab'
  );

  { Compressed image extensions }
  CompImageExtensions: array[0..7] of String = (
    '.jpg', '.jpeg', '.png', '.gif', '.webp',
    '.avif', '.heif', '.jxl'
  );

  { Raw/uncompressed image extensions }
  RawImageExtensions: array[0..4] of String = (
    '.bmp', '.tiff', '.tif', '.ico', '.cur'
  );

  { Audio/video extensions (already compressed) }
  AVExtensions: array[0..15] of String = (
    '.mp3', '.mp4', '.avi', '.mkv', '.flv', '.wmv',
    '.m4a', '.aac', '.ogg', '.opus', '.webm', '.mov',
    '.mpg', '.mpeg', '.3gp', '.flac'
  );

  { Data file extensions }
  DataExtensions: array[0..5] of String = (
    '.dat', '.db', '.sqlite', '.mdb', '.bin', '.pak'
  );

{ Helper: Get lowercase file extension }
function GetFileExtension(const FileName: String): String;
begin
  Result := LowerCase(ExtractFileExt(FileName));
end;

{ Helper: Check if extension is in array }
function IsExtensionIn(const Ext: String; const ExtArray: array of String): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := Low(ExtArray) to High(ExtArray) do begin
    if Ext = ExtArray[I] then begin
      Result := True;
      Exit;
    end;
  end;
end;

{ Detect file category based on extension }
function DetectFileCategory(const FileName: String): TFileCategory;
var
  Ext: String;
begin
  Ext := GetFileExtension(FileName);

  { Empty extension - analyze content or use default }
  if Ext = '' then begin
    Result := fcUnknown;
    Exit;
  end;

  { Check each category }
  if IsExtensionIn(Ext, WebExtensions) then
    Result := fcTextWeb
  else if IsExtensionIn(Ext, DocExtensions) then
    Result := fcTextDoc
  else if IsExtensionIn(Ext, BinaryExtensions) then
    Result := fcBinary
  else if IsExtensionIn(Ext, ArchiveExtensions) then
    Result := fcArchive
  else if IsExtensionIn(Ext, CompImageExtensions) then
    Result := fcImageComp
  else if IsExtensionIn(Ext, RawImageExtensions) then
    Result := fcImageRaw
  else if IsExtensionIn(Ext, AVExtensions) then
    Result := fcAudioVideo
  else if IsExtensionIn(Ext, DataExtensions) then
    Result := fcData
  else
    Result := fcUnknown;  { Default to unknown }
end;

{ Select compression strategy and level }
function SelectCompressionStrategy(
  const Category: TFileCategory;
  const FileSize: Int64;
  const Mode: TSmartCompressionMode
): TCompressionLevel;
begin
  { Initialize result }
  Result.Strategy := csZstd;  { Safe default }
  Result.Level := 3;

  { Legacy mode: always use LZMA2 }
  if Mode = scmLegacy then begin
    Result.Strategy := csLZMA2;
    Result.Level := 2;  { Normal }
    Exit;
  end;

  { Very small files (<1KB): don't compress (overhead > benefit) }
  if FileSize < 1024 then begin
    Result.Strategy := csStored;
    Result.Level := 0;
    Exit;
  end;

  { Select based on category and mode }
  case Category of
    { Text/Web content → Brotli }
    fcTextWeb, fcTextDoc:
      begin
        Result.Strategy := csBrotli;
        case Mode of
          scmFast: Result.Level := 3;        { Brotli fast }
          scmAuto, scmBalanced: Result.Level := 6;  { Brotli balanced }
          scmAggressive: Result.Level := 11; { Brotli maximum }
        end;
      end;

    { Binary files → Zstd }
    fcBinary, fcData, fcUnknown:
      begin
        Result.Strategy := csZstd;
        case Mode of
          scmFast: Result.Level := 1;        { Zstd ultra-fast }
          scmBalanced: Result.Level := 3;    { Zstd fast }
          scmAuto: Result.Level := 6;        { Zstd normal }
          scmAggressive: Result.Level := 19; { Zstd maximum }
        end;
      end;

    { Raw images → Zstd (light compression) }
    fcImageRaw:
      begin
        Result.Strategy := csZstd;
        case Mode of
          scmFast: Result.Level := 1;
          scmBalanced, scmAuto: Result.Level := 3;
          scmAggressive: Result.Level := 6;  { Don't go too high for images }
        end;
      end;

    { Already compressed → Don't recompress }
    fcArchive, fcImageComp, fcAudioVideo:
      begin
        Result.Strategy := csStored;
        Result.Level := 0;
      end;
  end;

  { Special case: Very large files (>100MB) - use faster compression }
  if FileSize > 100 * 1024 * 1024 then begin
    if Result.Strategy = csBrotli then begin
      if Result.Level > 6 then
        Result.Level := 6;  { Cap Brotli at 6 for large files }
    end
    else if Result.Strategy = csZstd then begin
      if Result.Level > 6 then
        Result.Level := 6;  { Cap Zstd at 6 for large files }
    end;
  end;
end;

{ Helper: Convert category to string }
function CategoryToString(const Category: TFileCategory): String;
begin
  case Category of
    fcTextWeb: Result := 'TextWeb';
    fcTextDoc: Result := 'TextDoc';
    fcBinary: Result := 'Binary';
    fcArchive: Result := 'Archive';
    fcImageComp: Result := 'ImageComp';
    fcImageRaw: Result := 'ImageRaw';
    fcAudioVideo: Result := 'AudioVideo';
    fcData: Result := 'Data';
    fcUnknown: Result := 'Unknown';
  else
    Result := 'Invalid';
  end;
end;

{ Helper: Convert strategy to string }
function StrategyToString(const Strategy: TCompressionStrategy): String;
begin
  case Strategy of
    csStored: Result := 'Stored';
    csBrotli: Result := 'Brotli';
    csZstd: Result := 'Zstd';
    csLZMA2: Result := 'LZMA2';
  else
    Result := 'Invalid';
  end;
end;

{ Helper: Convert mode to string }
function ModeToString(const Mode: TSmartCompressionMode): String;
begin
  case Mode of
    scmAuto: Result := 'Auto';
    scmAggressive: Result := 'Aggressive';
    scmBalanced: Result := 'Balanced';
    scmFast: Result := 'Fast';
    scmLegacy: Result := 'Legacy';
  else
    Result := 'Invalid';
  end;
end;

end.
