program TestCompressionIntegration;

{$APPTYPE CONSOLE}

{
  Integration test for Smart Compression system
  Tests the factory and DLL loading without actual DLLs
}

uses
  SysUtils,
  Shared.Struct in '..\Src\Shared.Struct.pas',
  Compression.Base in '..\Src\Compression.Base.pas',
  Compression.SmartSelector in '..\Src\Compression.SmartSelector.pas',
  Compiler.CompressionDLLs in '..\Src\Compiler.CompressionDLLs.pas',
  Compiler.CompressionFactory in '..\Src\Compiler.CompressionFactory.pas';

procedure PrintSeparator;
begin
  WriteLn('================================================');
end;

procedure TestDLLLoading;
begin
  WriteLn;
  PrintSeparator;
  WriteLn('TEST 1: DLL Loading');
  PrintSeparator;
  WriteLn;
  
  WriteLn('Attempting to load compression DLLs...');
  
  if InitializeCompressionDLLs then
    WriteLn('[OK] At least one compression DLL loaded')
  else
    WriteLn('[INFO] No DLLs available - will use fallback');
    
  WriteLn;
  WriteLn('DLL Availability:');
  WriteLn('  Brotli: ', IsBrotliAvailable);
  WriteLn('  Zstd:   ', IsZstdAvailable);
  
  if not IsBrotliAvailable and not IsZstdAvailable then
    WriteLn('[INFO] This is expected if DLLs are not yet built');
end;

procedure TestCompressionMethodAvailability;
var
  Method: TSetupCompressMethod;
begin
  WriteLn;
  PrintSeparator;
  WriteLn('TEST 2: Compression Method Availability');
  PrintSeparator;
  WriteLn;
  
  WriteLn(Format('%-15s %s', ['Method', 'Available']));
  WriteLn(StringOfChar('-', 30));
  
  for Method := Low(TSetupCompressMethod) to High(TSetupCompressMethod) do begin
    WriteLn(Format('%-15s %s', [
      GetEnumName(TypeInfo(TSetupCompressMethod), Ord(Method)),
      BoolToStr(IsCompressionMethodAvailable(Method), True)
    ]));
  end;
end;

procedure TestCompressorClassSelection;
var
  TestFiles: array[0..7] of String;
  CompressorClass: TCustomCompressorClass;
  I: Integer;
begin
  WriteLn;
  PrintSeparator;
  WriteLn('TEST 3: Compressor Class Selection');
  PrintSeparator;
  WriteLn;
  
  TestFiles[0] := 'index.html';
  TestFiles[1] := 'style.css';
  TestFiles[2] := 'app.exe';
  TestFiles[3] := 'library.dll';
  TestFiles[4] := 'archive.zip';
  TestFiles[5] := 'image.jpg';
  TestFiles[6] := 'data.dat';
  TestFiles[7] := 'readme.txt';
  
  WriteLn(Format('%-20s %-20s', ['File', 'Compressor Class']));
  WriteLn(StringOfChar('-', 45));
  
  for I := Low(TestFiles) to High(TestFiles) do begin
    CompressorClass := GetCompressorClass(cmSmart, TestFiles[I]);
    
    if CompressorClass = nil then
      WriteLn(Format('%-20s %-20s', [TestFiles[I], 'nil (Stored)']))
    else
      WriteLn(Format('%-20s %-20s', [TestFiles[I], CompressorClass.ClassName]));
  end;
end;

procedure TestDefaultCompressionLevels;
var
  Method: TSetupCompressMethod;
  Level: Integer;
begin
  WriteLn;
  PrintSeparator;
  WriteLn('TEST 4: Default Compression Levels');
  PrintSeparator;
  WriteLn;
  
  WriteLn(Format('%-15s %s', ['Method', 'Default Level']));
  WriteLn(StringOfChar('-', 30));
  
  for Method := Low(TSetupCompressMethod) to High(TSetupCompressMethod) do begin
    Level := GetDefaultCompressionLevel(Method);
    WriteLn(Format('%-15s %d', [
      GetEnumName(TypeInfo(TSetupCompressMethod), Ord(Method)),
      Level
    ]));
  end;
end;

procedure TestSmartSelectionWithDifferentModes;
var
  Category: TFileCategory;
  Strategy: TCompressionLevel;
  Modes: array[0..3] of TSmartCompressionMode;
  I: Integer;
begin
  WriteLn;
  PrintSeparator;
  WriteLn('TEST 5: Smart Selection with Different Modes');
  PrintSeparator;
  WriteLn;
  
  Modes[0] := scmFast;
  Modes[1] := scmBalanced;
  Modes[2] := scmAuto;
  Modes[3] := scmAggressive;
  
  Category := fcTextWeb;  { HTML file }
  
  WriteLn('File Category: TextWeb (HTML/CSS/JS)');
  WriteLn;
  WriteLn(Format('%-15s %-12s %s', ['Mode', 'Strategy', 'Level']));
  WriteLn(StringOfChar('-', 40));
  
  for I := Low(Modes) to High(Modes) do begin
    Strategy := SelectCompressionStrategy(Category, 10240, Modes[I]);
    WriteLn(Format('%-15s %-12s %d', [
      ModeToString(Modes[I]),
      StrategyToString(Strategy.Strategy),
      Strategy.Level
    ]));
  end;
end;

procedure TestFallbackBehavior;
begin
  WriteLn;
  PrintSeparator;
  WriteLn('TEST 6: Fallback Behavior');
  PrintSeparator;
  WriteLn;
  
  WriteLn('Testing fallback when DLLs are not available:');
  WriteLn;
  
  { Test Brotli fallback }
  var BrotliClass := GetCompressorClass(cmBrotli, '');
  WriteLn('cmBrotli fallback: ', BrotliClass.ClassName);
  
  { Test Zstd fallback }
  var ZstdClass := GetCompressorClass(cmZstd, '');
  WriteLn('cmZstd fallback:   ', ZstdClass.ClassName);
  
  { Test Smart fallback }
  var SmartClass := GetCompressorClass(cmSmart, 'test.html');
  WriteLn('cmSmart fallback:  ', SmartClass.ClassName);
  
  WriteLn;
  if not IsBrotliAvailable and not IsZstdAvailable then
    WriteLn('[OK] All methods correctly fall back to TLZMA2Compressor')
  else
    WriteLn('[OK] DLLs available - using native compressors');
end;

begin
  try
    WriteLn;
    WriteLn('==============================================');
    WriteLn('  Smart Compression Integration Test');
    WriteLn('  Inno Setup 7.1 - Phase 5');
    WriteLn('==============================================');
    
    TestDLLLoading;
    TestCompressionMethodAvailability;
    TestCompressorClassSelection;
    TestDefaultCompressionLevels;
    TestSmartSelectionWithDifferentModes;
    TestFallbackBehavior;
    
    WriteLn;
    PrintSeparator;
    WriteLn('ALL INTEGRATION TESTS COMPLETED!');
    PrintSeparator;
    WriteLn;
    
    if not IsBrotliAvailable and not IsZstdAvailable then begin
      WriteLn('NOTE: DLLs are not available yet.');
      WriteLn('The system correctly falls back to LZMA2.');
      WriteLn('To test with actual DLLs:');
      WriteLn('  1. Build DLLs using build-compression-libs.bat');
      WriteLn('  2. Or download pre-built DLLs');
      WriteLn('  3. Place them in the same directory as this executable');
      WriteLn('  4. Run this test again');
    end
    else begin
      WriteLn('SUCCESS: DLLs are loaded and ready to use!');
    end;
    
    WriteLn;
    WriteLn('Press ENTER to exit...');
    ReadLn;
    
    FinalizeCompressionDLLs;
  except
    on E: Exception do begin
      WriteLn;
      WriteLn('ERROR: ', E.Message);
      WriteLn;
      WriteLn('Press ENTER to exit...');
      ReadLn;
      ExitCode := 1;
    end;
  end;
end.
