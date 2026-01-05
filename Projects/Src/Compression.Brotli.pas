unit Compression.Brotli;

{
  Inno Setup - Smart Compression
  Copyright (C) 1997-2026 Jordan Russell
  Portions by Martijn Laan
  For conditions of distribution and use, see LICENSE.TXT.

  Brotli compression interface for text-heavy content
  Uses Google Brotli library (https://github.com/google/brotli)
  Best for: HTML, CSS, JavaScript, JSON, XML, SVG, text files
}

interface

uses
  Windows, SysUtils, Compression.Base;

function BrotliInitCompressFunctions(Module: HMODULE): Boolean;
function BrotliInitDecompressFunctions(Module: HMODULE): Boolean;

const
  { Brotli compression quality levels: 0 (fastest) to 11 (max compression) }
  BROTLI_MIN_QUALITY = 0;
  BROTLI_MAX_QUALITY = 11;
  BROTLI_DEFAULT_QUALITY = 6;  { Sweet spot for most use cases }

  { Recommended quality levels for different scenarios }
  clBrotliFast = 3;      { Fast compression, ~50% smaller than gzip }
  clBrotliNormal = 6;    { Balanced (default), ~70% smaller }
  clBrotliMax = 11;      { Maximum compression, ~75% smaller, slow }

type
  { Brotli stream state }
  TBrotliEncoderState = type Pointer;
  TBrotliDecoderState = type Pointer;

  { Result codes }
  TBrotliResult = (
    brFailure = 0,
    brSuccess = 1,
    brNeedsMoreInput = 2,
    brNeedsMoreOutput = 3
  );

  TBrotliOp = (
    boProcess = 0,
    boFlush = 1,
    boFinish = 2,
    boEmitMetadata = 3
  );

  TBrotliCompressor = class(TCustomCompressor)
  private
    FQuality: Integer;
    FState: TBrotliEncoderState;
    FInitialized: Boolean;
    FBuffer: array[0..65535] of Byte;
    procedure EndCompress;
    procedure FlushBuffer(var AvailOut: Cardinal; var NextOut: PByte);
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

  TBrotliDecompressor = class(TCustomDecompressor)
  private
    FState: TBrotliDecoderState;
    FInitialized: Boolean;
    FReachedEnd: Boolean;
    FBuffer: array[0..65535] of Byte;
    FBufferPos: Cardinal;
    FBufferAvail: Cardinal;
  public
    constructor Create(AReadProc: TDecompressorReadProc); override;
    destructor Destroy; override;
    procedure DecompressInto(var Buffer; Count: Cardinal); override;
    procedure Reset; override;
  end;

implementation

const
  SBrotliDataError = 'Brotli: Compressed data is corrupted';
  SBrotliInternalError = 'Brotli: Internal error. Code %d';
  SBrotliInitError = 'Brotli: Failed to initialize encoder';

var
  { Encoder functions }
  BrotliEncoderCreateInstance: function(
    alloc_func: Pointer;
    free_func: Pointer;
    opaque: Pointer): TBrotliEncoderState; cdecl;
  
  BrotliEncoderSetParameter: function(
    state: TBrotliEncoderState;
    param: Integer;
    value: Cardinal): LongBool; cdecl;
  
  BrotliEncoderCompressStream: function(
    state: TBrotliEncoderState;
    op: TBrotliOp;
    var available_in: Cardinal;
    var next_in: PByte;
    var available_out: Cardinal;
    var next_out: PByte;
    total_out: Pointer): LongBool; cdecl;
  
  BrotliEncoderDestroyInstance: procedure(
    state: TBrotliEncoderState); cdecl;

  BrotliEncoderIsFinished: function(
    state: TBrotliEncoderState): LongBool; cdecl;

  { Decoder functions }
  BrotliDecoderCreateInstance: function(
    alloc_func: Pointer;
    free_func: Pointer;
    opaque: Pointer): TBrotliDecoderState; cdecl;
  
  BrotliDecoderDecompressStream: function(
    state: TBrotliDecoderState;
    var available_in: Cardinal;
    var next_in: PByte;
    var available_out: Cardinal;
    var next_out: PByte;
    total_out: Pointer): TBrotliResult; cdecl;
  
  BrotliDecoderDestroyInstance: procedure(
    state: TBrotliDecoderState); cdecl;

  BrotliDecoderIsFinished: function(
    state: TBrotliDecoderState): LongBool; cdecl;

function BrotliInitCompressFunctions(Module: HMODULE): Boolean;
begin
  BrotliEncoderCreateInstance := GetProcAddress(Module, 'BrotliEncoderCreateInstance');
  BrotliEncoderSetParameter := GetProcAddress(Module, 'BrotliEncoderSetParameter');
  BrotliEncoderCompressStream := GetProcAddress(Module, 'BrotliEncoderCompressStream');
  BrotliEncoderDestroyInstance := GetProcAddress(Module, 'BrotliEncoderDestroyInstance');
  BrotliEncoderIsFinished := GetProcAddress(Module, 'BrotliEncoderIsFinished');
  
  Result := Assigned(BrotliEncoderCreateInstance) and
            Assigned(BrotliEncoderSetParameter) and
            Assigned(BrotliEncoderCompressStream) and
            Assigned(BrotliEncoderDestroyInstance) and
            Assigned(BrotliEncoderIsFinished);
            
  if not Result then begin
    BrotliEncoderCreateInstance := nil;
    BrotliEncoderSetParameter := nil;
    BrotliEncoderCompressStream := nil;
    BrotliEncoderDestroyInstance := nil;
    BrotliEncoderIsFinished := nil;
  end;
end;

function BrotliInitDecompressFunctions(Module: HMODULE): Boolean;
begin
  BrotliDecoderCreateInstance := GetProcAddress(Module, 'BrotliDecoderCreateInstance');
  BrotliDecoderDecompressStream := GetProcAddress(Module, 'BrotliDecoderDecompressStream');
  BrotliDecoderDestroyInstance := GetProcAddress(Module, 'BrotliDecoderDestroyInstance');
  BrotliDecoderIsFinished := GetProcAddress(Module, 'BrotliDecoderIsFinished');
  
  Result := Assigned(BrotliDecoderCreateInstance) and
            Assigned(BrotliDecoderDecompressStream) and
            Assigned(BrotliDecoderDestroyInstance) and
            Assigned(BrotliDecoderIsFinished);
            
  if not Result then begin
    BrotliDecoderCreateInstance := nil;
    BrotliDecoderDecompressStream := nil;
    BrotliDecoderDestroyInstance := nil;
    BrotliDecoderIsFinished := nil;
  end;
end;

{ TBrotliCompressor }

constructor TBrotliCompressor.Create(AWriteProc: TCompressorWriteProc;
  AProgressProc: TCompressorProgressProc; CompressionLevel: Integer;
  ACompressorProps: TCompressorProps);
begin
  inherited;
  
  { Map generic compression level (0-9) to Brotli quality (0-11) }
  if CompressionLevel <= 0 then
    FQuality := BROTLI_MIN_QUALITY
  else if CompressionLevel >= 9 then
    FQuality := BROTLI_MAX_QUALITY
  else
    FQuality := (CompressionLevel * 11) div 9;
    
  InitCompress;
end;

destructor TBrotliCompressor.Destroy;
begin
  EndCompress;
  inherited;
end;

procedure TBrotliCompressor.InitCompress;
const
  BROTLI_PARAM_QUALITY = 0;
begin
  if not FInitialized then begin
    FState := BrotliEncoderCreateInstance(nil, nil, nil);
    if FState = nil then
      raise ECompressInternalError.Create(SBrotliInitError);
      
    { Set compression quality }
    if not BrotliEncoderSetParameter(FState, BROTLI_PARAM_QUALITY, Cardinal(FQuality)) then
      raise ECompressInternalError.Create('Brotli: Failed to set quality parameter');
      
    FInitialized := True;
  end;
end;

procedure TBrotliCompressor.EndCompress;
begin
  if FInitialized then begin
    FInitialized := False;
    if Assigned(FState) then begin
      BrotliEncoderDestroyInstance(FState);
      FState := nil;
    end;
  end;
end;

procedure TBrotliCompressor.FlushBuffer(var AvailOut: Cardinal; var NextOut: PByte);
var
  OutputSize: Cardinal;
begin
  OutputSize := SizeOf(FBuffer) - AvailOut;
  if OutputSize > 0 then begin
    WriteProc(FBuffer, OutputSize);
    NextOut := PByte(@FBuffer);
    AvailOut := SizeOf(FBuffer);
  end;
end;

procedure TBrotliCompressor.DoCompress(const Buffer; Count: Cardinal);
var
  AvailIn: Cardinal;
  NextIn: PByte;
  AvailOut: Cardinal;
  NextOut: PByte;
begin
  InitCompress;
  
  AvailIn := Count;
  NextIn := @Buffer;
  NextOut := PByte(@FBuffer);
  AvailOut := SizeOf(FBuffer);
  
  while AvailIn > 0 do begin
    if not BrotliEncoderCompressStream(FState, boProcess,
                                       AvailIn, NextIn,
                                       AvailOut, NextOut,
                                       nil) then
      raise ECompressInternalError.Create('Brotli: Compression failed');
      
    if AvailOut = 0 then
      FlushBuffer(AvailOut, NextOut);
  end;
  
  if Assigned(ProgressProc) then
    ProgressProc(Count);
end;

procedure TBrotliCompressor.DoFinish;
var
  AvailIn: Cardinal;
  NextIn: PByte;
  AvailOut: Cardinal;
  NextOut: PByte;
begin
  InitCompress;
  
  AvailIn := 0;
  NextIn := nil;
  NextOut := PByte(@FBuffer);
  AvailOut := SizeOf(FBuffer);
  
  { Finish compression stream }
  while not BrotliEncoderIsFinished(FState) do begin
    if not BrotliEncoderCompressStream(FState, boFinish,
                                       AvailIn, NextIn,
                                       AvailOut, NextOut,
                                       nil) then
      raise ECompressInternalError.Create('Brotli: Finish failed');
      
    FlushBuffer(AvailOut, NextOut);
  end;
  
  { Flush any remaining data }
  FlushBuffer(AvailOut, NextOut);
  EndCompress;
end;

{ TBrotliDecompressor }

constructor TBrotliDecompressor.Create(AReadProc: TDecompressorReadProc);
begin
  inherited Create(AReadProc);
  
  FState := BrotliDecoderCreateInstance(nil, nil, nil);
  if FState = nil then
    raise ECompressInternalError.Create('Brotli: Failed to initialize decoder');
    
  FBufferPos := 0;
  FBufferAvail := 0;
  FInitialized := True;
end;

destructor TBrotliDecompressor.Destroy;
begin
  if FInitialized and Assigned(FState) then
    BrotliDecoderDestroyInstance(FState);
  inherited Destroy;
end;

procedure TBrotliDecompressor.DecompressInto(var Buffer; Count: Cardinal);
var
  AvailOut: Cardinal;
  NextOut: PByte;
  AvailIn: Cardinal;
  NextIn: PByte;
  Result: TBrotliResult;
begin
  NextOut := @Buffer;
  AvailOut := Count;
  
  while AvailOut > 0 do begin
    if FReachedEnd then
      raise ECompressDataError.Create(SBrotliDataError);
      
    { Refill input buffer if needed }
    if FBufferAvail = 0 then begin
      FBufferPos := 0;
      FBufferAvail := ReadProc(FBuffer, SizeOf(FBuffer));
    end;
    
    NextIn := @FBuffer[FBufferPos];
    AvailIn := FBufferAvail;
    
    Result := BrotliDecoderDecompressStream(FState,
                                            AvailIn, NextIn,
                                            AvailOut, NextOut,
                                            nil);
    
    { Update buffer position }
    FBufferPos := FBufferPos + (FBufferAvail - AvailIn);
    FBufferAvail := AvailIn;
    
    case Result of
      brSuccess:
        FReachedEnd := True;
      brNeedsMoreInput:
        Continue;  { Refill and try again }
      brNeedsMoreOutput:
        Continue;  { Should not happen, but continue anyway }
      brFailure:
        raise ECompressDataError.Create(SBrotliDataError);
    end;
  end;
end;

procedure TBrotliDecompressor.Reset;
begin
  { Brotli doesn't have a reset function, so recreate the decoder }
  if Assigned(FState) then
    BrotliDecoderDestroyInstance(FState);
    
  FState := BrotliDecoderCreateInstance(nil, nil, nil);
  if FState = nil then
    raise ECompressInternalError.Create('Brotli: Failed to reset decoder');
    
  FBufferPos := 0;
  FBufferAvail := 0;
  FReachedEnd := False;
end;

end.
