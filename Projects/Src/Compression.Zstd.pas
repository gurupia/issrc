unit Compression.Zstd;

{
  Inno Setup - Smart Compression
  Copyright (C) 1997-2026 Jordan Russell
  Portions by Martijn Laan
  For conditions of distribution and use, see LICENSE.TXT.

  Zstandard compression interface for general-purpose compression
  Uses Facebook Zstandard library (https://github.com/facebook/zstd)
  Best for: Binaries (EXE, DLL), data files, general purpose
}

interface

uses
  Windows, SysUtils, Compression.Base;

function ZstdInitCompressFunctions(Module: HMODULE): Boolean;
function ZstdInitDecompressFunctions(Module: HMODULE): Boolean;

const
  { Zstandard compression levels: 1 (fastest) to 22 (max compression) }
  { Negative levels (-131072 to -1) are for ultra-fast compression }
  ZSTD_MIN_LEVEL = 1;
  ZSTD_MAX_LEVEL = 22;
  ZSTD_DEFAULT_LEVEL = 3;  { Fast and good compression }

  { Recommended levels for different scenarios }
  clZstdUltraFast = 1;   { Fastest compression, ~40% smaller }
  clZstdFast = 3;        { Fast, balanced (default), ~60% smaller }
  clZstdNormal = 6;      { Good compression, ~70% smaller }
  clZstdMax = 19;        { Maximum recommended, ~80% smaller }
  clZstdUltra = 22;      { Ultra compression, very slow }

type
  { Zstandard error codes }
  TZstdErrorCode = type Cardinal;

  { Zstandard context types }
  TZstdCCtx = type Pointer;
  TZstdDCtx = type Pointer;

  TZstdCompressor = class(TCustomCompressor)
  private
    FCompressionLevel: Integer;
    FCCtx: TZstdCCtx;
    FInitialized: Boolean;
    FInBuffer: array[0..65535] of Byte;
    FOutBuffer: array[0..65535] of Byte;
    FInBufferPos: Cardinal;
    procedure EndCompress;
    procedure FlushBuffer;
    procedure InitCompress;
  protected
    procedure DoCompress(const Buffer; Count: Cardinal); override;
    procedure DoFinish; override;
  public
    constructor Create(AWriteProc: TCompressorWriteProc;
      AProgressProc: TCompressorProgressProc; CompressionLevel: Integer;
      ACompressorProps: TCompressorProps); override;
    destructor Destroy; override;
  end;

  TZstdDecompressor = class(TCustomDecompressor)
  private
    FDCtx: TZstdDCtx;
    FInitialized: Boolean;
    FReachedEnd: Boolean;
    FInBuffer: array[0..65535] of Byte;
    FInBufferPos: Cardinal;
    FInBufferAvail: Cardinal;
  public
    constructor Create(AReadProc: TDecompressorReadProc); override;
    destructor Destroy; override;
    procedure DecompressInto(var Buffer; Count: Cardinal); override;
    procedure Reset; override;
  end;

implementation

const
  SZstdDataError = 'Zstandard: Compressed data is corrupted';
  SZstdInternalError = 'Zstandard: Internal error %s';
  SZstdInitError = 'Zstandard: Failed to initialize context';

type
  { Zstandard input/output buffer }
  TZstdInBuffer = record
    src: Pointer;
    size: Cardinal;
    pos: Cardinal;
  end;

  TZstdOutBuffer = record
    dst: Pointer;
    size: Cardinal;
    pos: Cardinal;
  end;

var
  { Compression functions }
  ZSTD_createCCtx: function: TZstdCCtx; cdecl;
  ZSTD_freeCCtx: function(cctx: TZstdCCtx): Cardinal; cdecl;
  ZSTD_compressStream2: function(
    cctx: TZstdCCtx;
    var output: TZstdOutBuffer;
    var input: TZstdInBuffer;
    endOp: Integer): Cardinal; cdecl;
  ZSTD_CCtx_setParameter: function(
    cctx: TZstdCCtx;
    param: Integer;
    value: Integer): Cardinal; cdecl;

  { Decompression functions }
  ZSTD_createDCtx: function: TZstdDCtx; cdecl;
  ZSTD_freeDCtx: function(dctx: TZstdDCtx): Cardinal; cdecl;
  ZSTD_decompressStream: function(
    dctx: TZstdDCtx;
    var output: TZstdOutBuffer;
    var input: TZstdInBuffer): Cardinal; cdecl;
  ZSTD_DCtx_reset: function(
    dctx: TZstdDCtx;
    reset_directive: Integer): Cardinal; cdecl;

  { Error handling }
  ZSTD_isError: function(code: Cardinal): LongBool; cdecl;
  ZSTD_getErrorName: function(code: Cardinal): PAnsiChar; cdecl;

const
  { End operation modes for ZSTD_compressStream2 }
  ZSTD_e_continue = 0;
  ZSTD_e_flush = 1;
  ZSTD_e_end = 2;

  { Compression parameter }
  ZSTD_c_compressionLevel = 100;

  { Reset directive }
  ZSTD_reset_session_only = 1;

function ZstdInitCompressFunctions(Module: HMODULE): Boolean;
begin
  ZSTD_createCCtx := GetProcAddress(Module, 'ZSTD_createCCtx');
  ZSTD_freeCCtx := GetProcAddress(Module, 'ZSTD_freeCCtx');
  ZSTD_compressStream2 := GetProcAddress(Module, 'ZSTD_compressStream2');
  ZSTD_CCtx_setParameter := GetProcAddress(Module, 'ZSTD_CCtx_setParameter');
  ZSTD_isError := GetProcAddress(Module, 'ZSTD_isError');
  ZSTD_getErrorName := GetProcAddress(Module, 'ZSTD_getErrorName');

  Result := Assigned(ZSTD_createCCtx) and
            Assigned(ZSTD_freeCCtx) and
            Assigned(ZSTD_compressStream2) and
            Assigned(ZSTD_CCtx_setParameter) and
            Assigned(ZSTD_isError) and
            Assigned(ZSTD_getErrorName);

  if not Result then begin
    ZSTD_createCCtx := nil;
    ZSTD_freeCCtx := nil;
    ZSTD_compressStream2 := nil;
    ZSTD_CCtx_setParameter := nil;
    ZSTD_isError := nil;
    ZSTD_getErrorName := nil;
  end;
end;

function ZstdInitDecompressFunctions(Module: HMODULE): Boolean;
begin
  ZSTD_createDCtx := GetProcAddress(Module, 'ZSTD_createDCtx');
  ZSTD_freeDCtx := GetProcAddress(Module, 'ZSTD_freeDCtx');
  ZSTD_decompressStream := GetProcAddress(Module, 'ZSTD_decompressStream');
  ZSTD_DCtx_reset := GetProcAddress(Module, 'ZSTD_DCtx_reset');
  ZSTD_isError := GetProcAddress(Module, 'ZSTD_isError');
  ZSTD_getErrorName := GetProcAddress(Module, 'ZSTD_getErrorName');

  Result := Assigned(ZSTD_createDCtx) and
            Assigned(ZSTD_freeDCtx) and
            Assigned(ZSTD_decompressStream) and
            Assigned(ZSTD_DCtx_reset) and
            Assigned(ZSTD_isError) and
            Assigned(ZSTD_getErrorName);

  if not Result then begin
    ZSTD_createDCtx := nil;
    ZSTD_freeDCtx := nil;
    ZSTD_decompressStream := nil;
    ZSTD_DCtx_reset := nil;
    ZSTD_isError := nil;
    ZSTD_getErrorName := nil;
  end;
end;

procedure CheckZstdError(const Code: Cardinal; const Context: String);
begin
  if ZSTD_isError(Code) then begin
    var ErrorMsg := String(ZSTD_getErrorName(Code));
    raise ECompressInternalError.CreateFmt(SZstdInternalError, [Context + ': ' + ErrorMsg]);
  end;
end;

{ TZstdCompressor }

constructor TZstdCompressor.Create(AWriteProc: TCompressorWriteProc;
  AProgressProc: TCompressorProgressProc; CompressionLevel: Integer;
  ACompressorProps: TCompressorProps);
begin
  inherited;

  { Map generic compression level (0-9) to Zstd level (1-22) }
  if CompressionLevel <= 0 then
    FCompressionLevel := ZSTD_MIN_LEVEL
  else if CompressionLevel <= 2 then
    FCompressionLevel := 1    { Ultra-fast }
  else if CompressionLevel <= 4 then
    FCompressionLevel := 3    { Fast }
  else if CompressionLevel <= 6 then
    FCompressionLevel := 6    { Normal }
  else if CompressionLevel <= 8 then
    FCompressionLevel := 15   { High }
  else
    FCompressionLevel := 19;  { Maximum recommended }

  InitCompress;
end;

destructor TZstdCompressor.Destroy;
begin
  EndCompress;
  inherited;
end;

procedure TZstdCompressor.InitCompress;
var
  Res: Cardinal;
begin
  if not FInitialized then begin
    if not Assigned(ZSTD_createCCtx) then
      raise ECompressInternalError.Create('Zstd: Compressor DLL not loaded');
    FCCtx := ZSTD_createCCtx;
    if FCCtx = nil then
      raise ECompressInternalError.Create(SZstdInitError);

    { Set compression level }
    Res := ZSTD_CCtx_setParameter(FCCtx, ZSTD_c_compressionLevel, FCompressionLevel);
    CheckZstdError(Res, 'SetParameter');

    FInBufferPos := 0;
    FInitialized := True;
  end;
end;

procedure TZstdCompressor.EndCompress;
begin
  if FInitialized then begin
    FInitialized := False;
    if Assigned(FCCtx) and Assigned(ZSTD_freeCCtx) then begin
      ZSTD_freeCCtx(FCCtx);
      FCCtx := nil;
    end;
  end;
end;

procedure TZstdCompressor.FlushBuffer;
var
  InBuf: TZstdInBuffer;
  OutBuf: TZstdOutBuffer;
  Res: Cardinal;
begin
  if FInBufferPos = 0 then
    Exit;

  { Prepare input buffer }
  InBuf.src := @FInBuffer;
  InBuf.size := FInBufferPos;
  InBuf.pos := 0;

  { Compress to output buffer and write }
  repeat
    OutBuf.dst := @FOutBuffer;
    OutBuf.size := SizeOf(FOutBuffer);
    OutBuf.pos := 0;

    Res := ZSTD_compressStream2(FCCtx, OutBuf, InBuf, ZSTD_e_continue);
    CheckZstdError(Res, 'CompressStream2');

    if OutBuf.pos > 0 then
      WriteProc(FOutBuffer, OutBuf.pos);
  until InBuf.pos >= InBuf.size;

  FInBufferPos := 0;
end;

procedure TZstdCompressor.DoCompress(const Buffer; Count: Cardinal);
var
  P: PByte;
  Remaining: Cardinal;
  ChunkSize: Cardinal;
begin
  InitCompress;

  P := @Buffer;
  Remaining := Count;

  while Remaining > 0 do begin
    ChunkSize := Remaining;
    if ChunkSize > SizeOf(FInBuffer) - FInBufferPos then
      ChunkSize := SizeOf(FInBuffer) - FInBufferPos;

    Move(P^, FInBuffer[FInBufferPos], ChunkSize);
    Inc(FInBufferPos, ChunkSize);

    { Flush when buffer is full }
    if FInBufferPos >= SizeOf(FInBuffer) then
      FlushBuffer;

    Inc(P, ChunkSize);
    Dec(Remaining, ChunkSize);
  end;

  if Assigned(ProgressProc) then
    ProgressProc(Count);
end;

procedure TZstdCompressor.DoFinish;
var
  InBuf: TZstdInBuffer;
  OutBuf: TZstdOutBuffer;
  Res: Cardinal;
begin
  InitCompress;

  { Flush any remaining data in input buffer }
  FlushBuffer;

  { Finalize compression }
  InBuf.src := nil;
  InBuf.size := 0;
  InBuf.pos := 0;

  repeat
    OutBuf.dst := @FOutBuffer;
    OutBuf.size := SizeOf(FOutBuffer);
    OutBuf.pos := 0;

    Res := ZSTD_compressStream2(FCCtx, OutBuf, InBuf, ZSTD_e_end);
    CheckZstdError(Res, 'CompressStream2(end)');

    if OutBuf.pos > 0 then
      WriteProc(FOutBuffer, OutBuf.pos);
  until Res = 0;  { 0 means frame is complete }

  EndCompress;
end;

{ TZstdDecompressor }

constructor TZstdDecompressor.Create(AReadProc: TDecompressorReadProc);
begin
  inherited Create(AReadProc);

  if not Assigned(ZSTD_createDCtx) then
    raise ECompressInternalError.Create('Zstd: Decompressor DLL not loaded');
  FDCtx := ZSTD_createDCtx;
  if FDCtx = nil then
    raise ECompressInternalError.Create(SZstdInitError);

  FInBufferPos := 0;
  FInBufferAvail := 0;
  FInitialized := True;
end;

destructor TZstdDecompressor.Destroy;
begin
  if FInitialized and Assigned(FDCtx) and Assigned(ZSTD_freeDCtx) then
    ZSTD_freeDCtx(FDCtx);
  inherited Destroy;
end;

procedure TZstdDecompressor.DecompressInto(var Buffer; Count: Cardinal);
var
  OutBuf: TZstdOutBuffer;
  InBuf: TZstdInBuffer;
  Res: Cardinal;
begin
  OutBuf.dst := @Buffer;
  OutBuf.size := Count;
  OutBuf.pos := 0;

  while OutBuf.pos < OutBuf.size do begin
    if FReachedEnd then
      raise ECompressDataError.Create(SZstdDataError);

    { Refill input buffer if needed }
    if FInBufferAvail = 0 then begin
      FInBufferPos := 0;
      FInBufferAvail := ReadProc(FInBuffer, SizeOf(FInBuffer));
      if FInBufferAvail = 0 then
        raise ECompressDataError.Create(SZstdDataError);
    end;

    InBuf.src := @FInBuffer[FInBufferPos];
    InBuf.size := FInBufferAvail;
    InBuf.pos := 0;

    Res := ZSTD_decompressStream(FDCtx, OutBuf, InBuf);
    CheckZstdError(Res, 'DecompressStream');

    { Update input buffer position }
    FInBufferPos := FInBufferPos + InBuf.pos;
    FInBufferAvail := FInBufferAvail - InBuf.pos;

    { Check if frame is complete }
    if Res = 0 then
      FReachedEnd := True;
  end;
end;

procedure TZstdDecompressor.Reset;
var
  Res: Cardinal;
begin
  Res := ZSTD_DCtx_reset(FDCtx, ZSTD_reset_session_only);
  CheckZstdError(Res, 'Reset');

  FInBufferPos := 0;
  FInBufferAvail := 0;
  FReachedEnd := False;
end;

end.
