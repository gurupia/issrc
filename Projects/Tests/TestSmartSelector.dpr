program TestSmartSelector;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Compression.SmartSelector in '..\Src\Compression.SmartSelector.pas';

procedure PrintSeparator;
begin
  WriteLn('================================================');
end;

procedure TestFileDetection;
var
  TestFiles: array[0..14] of String;
  Category: TFileCategory;
  I: Integer;
begin
  WriteLn;
  PrintSeparator;
  WriteLn('TEST 1: File Category Detection');
  PrintSeparator;
  WriteLn;

  TestFiles[0] := 'index.html';
  TestFiles[1] := 'style.css';
  TestFiles[2] := 'app.js';
  TestFiles[3] := 'config.json';
  TestFiles[4] := 'readme.txt';
  TestFiles[5] := 'changelog.md';
  TestFiles[6] := 'setup.exe';
  TestFiles[7] := 'library.dll';
  TestFiles[8] := 'archive.zip';
  TestFiles[9] := 'image.jpg';
  TestFiles[10] := 'icon.bmp';
  TestFiles[11] := 'song.mp3';
  TestFiles[12] := 'database.db';
  TestFiles[13] := 'unknown.xyz';
  TestFiles[14] := 'noextension';

  for I := Low(TestFiles) to High(TestFiles) do begin
    Category := DetectFileCategory(TestFiles[I]);
    WriteLn(Format('%-20s → %-12s', [TestFiles[I], CategoryToString(Category)]));
  end;
end;

procedure TestStrategySelection;
var
  Category: TFileCategory;
  Level: TCompressionLevel;
  Mode: TSmartCompressionMode;
  FileSize: Int64;
begin
  WriteLn;
  PrintSeparator;
  WriteLn('TEST 2: Strategy Selection (Auto Mode)');
  PrintSeparator;
  WriteLn;

  Mode := scmAuto;
  FileSize := 10 * 1024;  { 10KB }

  WriteLn(Format('%-15s %-12s %-10s %s', ['Category', 'Strategy', 'Level', 'Description']));
  WriteLn(StringOfChar('-', 60));

  { Test each category }
  Category := fcTextWeb;
  Level := SelectCompressionStrategy(Category, FileSize, Mode);
  WriteLn(Format('%-15s %-12s %-10d %s', [
    CategoryToString(Category),
    StrategyToString(Level.Strategy),
    Level.Level,
    'HTML/CSS/JS'
  ]));

  Category := fcTextDoc;
  Level := SelectCompressionStrategy(Category, FileSize, Mode);
  WriteLn(Format('%-15s %-12s %-10d %s', [
    CategoryToString(Category),
    StrategyToString(Level.Strategy),
    Level.Level,
    'Text documents'
  ]));

  Category := fcBinary;
  Level := SelectCompressionStrategy(Category, FileSize, Mode);
  WriteLn(Format('%-15s %-12s %-10d %s', [
    CategoryToString(Category),
    StrategyToString(Level.Strategy),
    Level.Level,
    'Executables'
  ]));

  Category := fcArchive;
  Level := SelectCompressionStrategy(Category, FileSize, Mode);
  WriteLn(Format('%-15s %-12s %-10d %s', [
    CategoryToString(Category),
    StrategyToString(Level.Strategy),
    Level.Level,
    'Already compressed'
  ]));

  Category := fcImageRaw;
  Level := SelectCompressionStrategy(Category, FileSize, Mode);
  WriteLn(Format('%-15s %-12s %-10d %s', [
    CategoryToString(Category),
    StrategyToString(Level.Strategy),
    Level.Level,
    'Raw images'
  ]));
end;

procedure TestCompressionModes;
var
  Category: TFileCategory;
  Level: TCompressionLevel;
  Modes: array[0..3] of TSmartCompressionMode;
  I: Integer;
begin
  WriteLn;
  PrintSeparator;
  WriteLn('TEST 3: Compression Modes (Text File)');
  PrintSeparator;
  WriteLn;

  Modes[0] := scmFast;
  Modes[1] := scmBalanced;
  Modes[2] := scmAuto;
  Modes[3] := scmAggressive;

  Category := fcTextWeb;

  WriteLn(Format('%-15s %-12s %s', ['Mode', 'Strategy', 'Level']));
  WriteLn(StringOfChar('-', 40));

  for I := Low(Modes) to High(Modes) do begin
    Level := SelectCompressionStrategy(Category, 10240, Modes[I]);
    WriteLn(Format('%-15s %-12s %d', [
      ModeToString(Modes[I]),
      StrategyToString(Level.Strategy),
      Level.Level
    ]));
  end;
end;

procedure TestFileSizeThresholds;
var
  Category: TFileCategory;
  Level: TCompressionLevel;
  Sizes: array[0..4] of Int64;
  I: Integer;
begin
  WriteLn;
  PrintSeparator;
  WriteLn('TEST 4: File Size Thresholds');
  PrintSeparator;
  WriteLn;

  Sizes[0] := 500;                  { 500 bytes }
  Sizes[1] := 10 * 1024;           { 10 KB }
  Sizes[2] := 1024 * 1024;         { 1 MB }
  Sizes[3] := 50 * 1024 * 1024;    { 50 MB }
  Sizes[4] := 150 * 1024 * 1024;   { 150 MB }

  Category := fcBinary;

  WriteLn(Format('%-15s %-12s %s', ['File Size', 'Strategy', 'Level']));
  WriteLn(StringOfChar('-', 40));

  for I := Low(Sizes) to High(Sizes) do begin
    Level := SelectCompressionStrategy(Category, Sizes[I], scmAuto);
    WriteLn(Format('%-15s %-12s %d', [
      FormatFloat('#,##0', Sizes[I] / 1024) + ' KB',
      StrategyToString(Level.Strategy),
      Level.Level
    ]));
  end;
end;

begin
  try
    WriteLn;
    WriteLn('==============================================');
    WriteLn('  Smart Compression Selector Test Suite');
    WriteLn('  Inno Setup v7.1 - Phase 3');
    WriteLn('==============================================');

    TestFileDetection;
    TestStrategySelection;
    TestCompressionModes;
    TestFileSizeThresholds;

    WriteLn;
    PrintSeparator;
    WriteLn('ALL TESTS COMPLETED SUCCESSFULLY!');
    PrintSeparator;
    WriteLn;
    WriteLn('Press ENTER to exit...');
    ReadLn;
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
