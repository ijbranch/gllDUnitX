{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2015 Vincent Parrett & Contributors               }
{           Modified (C) 2026 Ian Branch (GITLAK Software) - gllDUnitX fork }
{                                                                           }
{           vincent@finalbuilder.com                                        }
{           http://www.finalbuilder.com                                     }
{                                                                           }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}

unit DUnitX.Loggers.Text;

interface

{$I DUnitX.inc}

uses
{$IFDEF USE_NS}   // since Delphi XE2
  WinAPI.Windows,
  System.SysUtils,
  System.Classes,
  System.TimeSpan,
  System.Generics.Collections,
{$ELSE}
  Windows,
  SysUtils,
  Classes,
  TimeSpan,
  Generics.Collections,
{$ENDIF}
  DUnitX.TestFramework,
  DUnitX.Loggers.Null;

type
  /// <summary>
  ///   Plain-text logger that writes an indented, time-stamped log of fixtures and tests (START/STOP lines, status,
  ///   elapsed time) to a stream, then a list of every test with an issue and the run's counts.
  /// </summary>
  TDunitXTextLogger = class(TDUnitXNullLogger)
  strict private
    const
      /// <summary>Number of spaces added per indent level.</summary>
      fIndentStep = 2;
      /// <summary>Suffix written after a fixture or test name when it starts.</summary>
      fStartSuffix = ' - START';
      /// <summary>Suffix written after a fixture or test name when it stops.</summary>
      fStopSuffix  = ' - STOP';
    var
      /// <summary>The stream the log is written to.</summary>
      fOutput:   TStream;
      /// <summary>True when the logger owns <c>fOutput</c> and frees it on destruction.</summary>
      fOwnOut:   Boolean;
      /// <summary>The current indent, in spaces.</summary>
      fIndent:   Integer;
      /// <summary>Tests with an issue (error, failure, ignored, leak), as pairs of test full name and message.</summary>
      fIssues:   TList<TPair<string, string>>;
      /// <summary>The encoding used to convert each line to bytes (UTF-8 unless the caller chose another).</summary>
      fEncoding: TEncoding;

    /// <summary>Formats a fixture name for the log, appending its unit name unless that is <c>System</c>.</summary>
    /// <param name="Fixture">The fixture to name.</param>
    /// <returns>The fixture's full name, optionally followed by its unit name in brackets.</returns>
    function GetFixtureName(const Fixture : ITestFixtureInfo) : string;
    /// <summary>Formats a test name for the log, adding the display name when it differs from the method name.</summary>
    /// <param name="Test">The test to name.</param>
    /// <returns>The method name, optionally followed by the test's display name in brackets.</returns>
    function GetTestName(const Test : ITestInfo) : string;
    /// <summary>Appends the current local date and time (to the millisecond) to a caption.</summary>
    /// <param name="Caption">The text to suffix, such as <c>fStartSuffix</c>.</param>
    /// <returns>The caption followed by a space and the time stamp.</returns>
    function GetTimeSuffix(const Caption : string) : string;

    /// <summary>Increases the indent.</summary>
    /// <param name="Steps">The number of indent levels to add.</param>
    procedure IncIndent(const Steps : Integer = 1);
    /// <summary>Decreases the indent.</summary>
    /// <param name="Steps">The number of indent levels to remove.</param>
    procedure DecIndent(const Steps : Integer = 1);

    /// <summary>
    ///   Writes one trimmed line at the current indent, encoded with <c>fEncoding</c>; blank text writes an empty line.
    /// </summary>
    /// <param name="text">The line to write.</param>
    procedure WriteLine(const text : string = ''); overload;
    /// <summary>Formats and writes one line at the current indent.</summary>
    /// <param name="textFmt">A <c>Format</c> pattern.</param>
    /// <param name="textArgs">The arguments for the pattern.</param>
    procedure WriteLine(const textFmt : string; textArgs: array of const); overload;
    /// <summary>
    ///   Outdents one level, writes the line, then an "elapsed time" line with the duration's leading zero fields and
    ///   trailing zero digits stripped (omitted when the duration is zero), then an empty line.
    /// </summary>
    /// <param name="text">The line to write.</param>
    /// <param name="duration">The elapsed time to report.</param>
    procedure WriteLine(const text : string; const duration : TTimeSpan); overload;

  protected
    /// <summary>Writes the "starting to perform N tests" banner, underlined, and indents.</summary>
    /// <param name="threadId">The thread starting the run.</param>
    /// <param name="testCount">The total number of tests found.</param>
    /// <param name="testActiveCount">The number of tests that will run; shown only when it differs from the total.</param>
    procedure OnTestingStarts(const threadId : TThreadID; testCount, testActiveCount : Cardinal); override;

    /// <summary>Writes the fixture's START line and indents.</summary>
    /// <param name="threadId">The thread running the fixture.</param>
    /// <param name="fixture">The fixture starting.</param>
    procedure OnStartTestFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo); override;

    /// <summary>Writes the test's START line and indents.</summary>
    /// <param name="threadId">The thread running the test.</param>
    /// <param name="Test">The test about to begin.</param>
    procedure OnBeginTest(const threadId : TThreadID; const Test : ITestInfo); override;

    /// <summary>Writes a SUCCESS status line.</summary>
    /// <param name="threadId">The thread that ran the test.</param>
    /// <param name="TestResult">The passing test's result.</param>
    procedure OnTestSuccess(const threadId : TThreadID; const TestResult : ITestResult); override;
    /// <summary>Writes an ERROR status line and records the test as an issue.</summary>
    /// <param name="threadId">The thread that ran the test.</param>
    /// <param name="Error">The error result.</param>
    procedure OnTestError(const threadId : TThreadID; const Error : ITestError); override;
    /// <summary>Writes a FAILURE status line and records the test as an issue.</summary>
    /// <param name="threadId">The thread that ran the test.</param>
    /// <param name="Failure">The failure result.</param>
    procedure OnTestFailure(const threadId : TThreadID; const Failure : ITestError); override;
    /// <summary>Writes an IGNORED status line and records the test as an issue.</summary>
    /// <param name="threadId">The thread that would have run the test.</param>
    /// <param name="Ignored">The ignored test's result.</param>
    procedure OnTestIgnored(const threadId : TThreadID; const Ignored : ITestResult); override;
    /// <summary>Writes a MEMORY LEAK status line and records the test as an issue.</summary>
    /// <param name="threadId">The thread that ran the test.</param>
    /// <param name="TestResult">The leaking test's result.</param>
    procedure OnTestMemoryLeak(const threadId : TThreadID; const TestResult : ITestResult); override;

    /// <summary>Writes the test's STOP line with its elapsed time.</summary>
    /// <param name="threadId">The thread that ran the test.</param>
    /// <param name="TestResult">The finished test's result.</param>
    procedure OnEndTest(const threadId : TThreadID; const TestResult : ITestResult); override;

    /// <summary>Writes the fixture's STOP line with its elapsed time.</summary>
    /// <param name="threadId">The thread that ran the fixture.</param>
    /// <param name="results">The fixture's aggregated results.</param>
    procedure OnEndTestFixture(const threadId : TThreadID; const results : IFixtureResult); override;

    /// <summary>Writes the numbered list of issues and the fixture, test, pass and non-zero problem counts.</summary>
    /// <param name="RunResults">The results of the whole run.</param>
    procedure OnTestingEnds(const RunResults : IRunResults); override;

  public
    /// <summary>Creates a text logger writing to an existing stream.</summary>
    /// <param name="outputStream">The stream to write to; writing starts at its current position.</param>
    /// <param name="ownsStream">True to free the stream when the logger is destroyed.</param>
    /// <param name="encoding">The text encoding; nil means UTF-8. No preamble is written.</param>
    constructor Create(const outputStream : TStream; const ownsStream : Boolean = False; encoding : TEncoding = nil);
    /// <summary>Frees the issue list and, when owned, the output stream.</summary>
    destructor Destroy(); override;
  end;

  /// <summary>
  ///   Text logger that writes to a file it opens and owns, either replacing it or appending to it.
  /// </summary>
  TDunitXTextFileLogger = class(TDunitXTextLogger)
  public
    /// <summary>
    ///   Opens (or creates) the log file and starts logging to it. A new file gets the encoding's preamble (BOM); when
    ///   appending with no encoding given, the encoding is detected from the existing file's BOM, defaulting to UTF-8.
    /// </summary>
    /// <param name="fileName">The log file; empty means the executable's name with a <c>.log</c> extension.</param>
    /// <param name="overwrite">True to replace an existing file; False to append to it.</param>
    /// <param name="encoding">The text encoding; nil means UTF-8 for a new file, or the detected one when appending.</param>
    /// <exception cref="EFCreateError">The file cannot be created.</exception>
    /// <exception cref="EFOpenError">An existing file cannot be opened for appending.</exception>
    constructor Create(const fileName : string = ''; const overwrite : Boolean = True; const encoding : TEncoding = nil);
  end;

implementation

{$REGION 'TDunitXTextLogger'}

constructor TDunitXTextLogger.Create(const outputStream : TStream; const ownsStream : Boolean; encoding : TEncoding);
begin
  inherited Create();
  fIssues := TList<TPair<string, string>>.Create();

  fOutput := outputStream;
  fOwnOut := ownsStream;

  if encoding <> nil then
    fEncoding := encoding
  else
    fEncoding := TEncoding.UTF8;
end;

procedure TDunitXTextLogger.DecIndent(const Steps : Integer);
begin
  Dec(fIndent, Steps * fIndentStep)
end;

destructor TDunitXTextLogger.Destroy;
begin
  fIssues.Free();
  if fOwnOut then
    fOutput.Free();

  inherited;
end;

function TDunitXTextLogger.GetFixtureName(const Fixture : ITestFixtureInfo) : string;
begin
  if  SameText(Fixture.UnitName, 'System')  then
    Result := Fixture.FullName
  else
    Result := Format('%s (%s)', [Fixture.FullName, Fixture.UnitName])
end;

function TDunitXTextLogger.GetTestName(const Test: ITestInfo): string;
begin
  if Test.Name <> Test.MethodName then
    Result := Format('%s (%s)', [Test.MethodName, Test.Name])
  else
    Result := Test.MethodName
end;

function TDunitXTextLogger.GetTimeSuffix(const Caption : string) : string;
begin
  Result := Caption + ' ' + FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now())
end;

procedure TDunitXTextLogger.IncIndent(const Steps : Integer);
begin
  Inc(fIndent, Steps * fIndentStep)
end;

procedure  TDunitXTextLogger.OnBeginTest(const threadId : TThreadID; const Test : ITestInfo);
begin
  inherited;

  WriteLine(GetTestName(Test) + GetTimeSuffix(fStartSuffix));
  IncIndent()
end;

procedure TDunitXTextLogger.OnEndTest(const threadId : TThreadID; const TestResult : ITestResult);
begin
  inherited;
  WriteLine(GetTestName(TestResult.Test) + GetTimeSuffix(fStopSuffix), TestResult.Duration);
end;

procedure TDunitXTextLogger.OnEndTestFixture(const threadId : TThreadID; const results : IFixtureResult);
begin
  inherited;
  WriteLine(GetFixtureName(results.Fixture) + GetTimeSuffix(fStopSuffix), results.Duration);
end;

procedure TDunitXTextLogger.OnStartTestFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
begin
  inherited;
  WriteLine(GetFixtureName(fixture) + GetTimeSuffix(fStartSuffix));
  WriteLine();
  IncIndent()
end;

procedure TDunitXTextLogger.OnTestError(const threadId : TThreadID; const Error : ITestError);
begin
  inherited;
  WriteLine('- Status: ERROR %s', [Error.Message]);
  fIssues.Add(TPair<string, string>.Create(Error.Test.FullName, Error.Message))
end;

procedure TDunitXTextLogger.OnTestFailure(const threadId : TThreadID; const Failure : ITestError);
begin
  inherited;
  WriteLine('- Status: FAILURE %s', [Failure.Message]);
  fIssues.Add(TPair<string, string>.Create(Failure.Test.FullName, Failure.Message))
end;

procedure TDunitXTextLogger.OnTestIgnored(const threadId : TThreadID; const Ignored : ITestResult);
begin
  inherited;
  WriteLine('- Status: IGNORED %s', [Ignored.Message]);
  fIssues.Add(TPair<string, string>.Create(Ignored.Test.FullName, Ignored.Message))
end;

procedure TDunitXTextLogger.OnTestingEnds(const RunResults : IRunResults);
var
  i: Integer;
begin
  inherited;

  DecIndent();

  WriteLine('Testing finished');

  if fIssues.Count <> 0 then
  begin
    WriteLine('- Issues:');
    IncIndent();
    for i := 0 to fIssues.Count - 1  do
      begin
        WriteLine('%d %s', [i + 1, fIssues[i].Key]);
        IncIndent(2);
        WriteLine(fIssues[i].Value);
        DecIndent(2)
      end;
    DecIndent();
    WriteLine()
  end;

  WriteLine('- Fixture Count: %d', [RunResults.FixtureCount]);
  WriteLine('- Test Count:    %d', [RunResults.TestCount]);
  WriteLine('- Pass Count:    %d', [RunResults.PassCount]);
  if RunResults.FailureCount <> 0 then
    WriteLine('- Failure Count: %d', [RunResults.FailureCount]);
  if RunResults.ErrorCount <> 0 then
    WriteLine('- Error Count:   %d', [RunResults.ErrorCount]);
  if RunResults.IgnoredCount <> 0 then
    WriteLine('- Ignored Count: %d', [RunResults.IgnoredCount]);
  if RunResults.MemoryLeakCount <> 0 then
    WriteLine('- Memory Leaks:  %d', [RunResults.MemoryLeakCount]);
  if RunResults.AllPassed then
    WriteLine('- All PASSED');
  WriteLine()
end;

procedure TDunitXTextLogger.OnTestingStarts(const threadId : TThreadID; testCount, testActiveCount : Cardinal);
var
  buf : string;
begin
  inherited;

  buf := 'Starting to perform %u test';
  if testCount <> 1 then
    buf := buf + 's';
  if testCount <> testActiveCount then
    buf := buf + ', %u active';

  buf := Format(buf, [testCount, testActiveCount]);
  WriteLine(buf);
  WriteLine(StringOfChar('~', Length(buf)));
  WriteLine();

  IncIndent()
end;

procedure TDunitXTextLogger.OnTestMemoryLeak(const threadId : TThreadID; const TestResult : ITestResult);
begin
  inherited;
  WriteLine('- Status: MEMORY LEAK %s', [TestResult.Message]);
  fIssues.Add(TPair<string, string>.Create(TestResult.Test.FullName, TestResult.Message))
end;

procedure TDunitXTextLogger.OnTestSuccess(const threadId : TThreadID; const TestResult : ITestResult);
begin
  inherited;
  WriteLine('- Status: SUCCESS')
end;

function TTimeSpanToString( value : TTimeSpan): string;
var
  Fmt: string;
  Days, SubSecondTicks: Integer;
  LTicks: Int64;
begin
  Fmt := '%1:.2d:%2:.2d:%3:.2d'; // do not localize
  Days :=  value.Ticks div TTimeSpan.TicksPerDay;
  LTicks := value.Ticks mod TTimeSpan.TicksPerDay;
  if value.Ticks < 0 then
    LTicks := -LTicks;
  if value.Days <> 0 then
    Fmt := '%0:d.' + Fmt; // do not localize
  SubSecondTicks := LTicks mod TTimeSpan.TicksPerSecond;
  if SubSecondTicks <> 0 then
    Fmt := Fmt + '.%4:.7d'; // do not localize
  Result := Format(Fmt,
     [Days,
    (LTicks div TTimeSpan.TicksPerHour) mod 24,
    (LTicks div TTimeSpan.TicksPerMinute) mod 60,
    (LTicks div TTimeSpan.TicksPerSecond) mod 60,
    SubSecondTicks]);
end;

procedure TDunitXTextLogger.WriteLine(const text : string; const duration : TTimeSpan);
var
  buf : string;
begin
  DecIndent();

  WriteLine(text);

  if duration.Ticks <> 0 then
    begin
      buf := TTimeSpanToString(duration);

      while Copy(buf, 1, 3) = '00:' do
        Delete(buf, 1, 3);
      if (Length(buf) >= 2) and (buf[1] = '0') and CharInSet(buf[2], ['0'..'9']) then
        Delete(buf, 1, 1);

      while (buf <> '') and (buf[Length(buf)] = '0') do
        SetLength(buf, Length(buf) - 1);
      if (buf <> '') and (buf[Length(buf)] = '.') then
        SetLength(buf, Length(buf) - 1);

      if buf <> '' then
        WriteLine('- elapsed time: ' + buf);
    end;

  WriteLine()
end;

procedure TDunitXTextLogger.WriteLine(const textFmt : string; textArgs : array of const);
begin
  WriteLine(Format(textFmt, textArgs))
end;

procedure TDunitXTextLogger.WriteLine(const text: string);

var
  bufS : string;
  bufB : TBytes;

begin
  if Trim(text) <> '' then
    bufS := StringOfChar(' ', fIndent) + Trim(text) + sLineBreak
  else
    bufS := sLineBreak;
  {-}
  bufB := fEncoding.GetBytes(bufS);
  fOutput.Write(bufB, Length(bufB))
end;

{$ENDREGION 'TDunitXTextLogger'}


{$REGION 'TDunitXTextFileLogger'}

constructor TDunitXTextFileLogger.Create(const fileName : string; const overwrite : Boolean; const encoding : TEncoding);

type
  {$IF Declared(TBufferedFileStream)}
    TOutputStream = TBufferedFileStream;
  {$ELSE}
    TOutputStream = TFileStream;
  {$IFEND}

var
  outName : string;
  outStream : TOutputStream;
  outEncoding : TEncoding;
  bufBOM : TBytes;
  len : Integer;

begin
  outName := FileName;
  if outName = '' then
    outName := ChangeFileExt(ParamStr(0), '.log');

  if overwrite or not FileExists(outName) then
  begin
    outStream := TOutputStream.Create(outName, fmCreate);

    if encoding <> nil then
      outEncoding := encoding
    else
      outEncoding := TEncoding.UTF8;

    bufBOM := outEncoding.GetPreamble();
    if bufBOM <> nil then
      outStream.Write(bufBOM, Length(bufBOM))
  end
  else
  begin
    outStream := TOutputStream.Create(outName, fmOpenReadWrite);

    outEncoding := encoding;
    if outEncoding = nil then
    begin
      // A standard BOM consists of 2 to 4 bytes.
      // In the case of exotic encodings, such as UTF-7, the BOM may consist of 5 bytes.
      SetLength(bufBOM, 5);
      len := outStream.Read(bufBOM, 5);
      SetLength(bufBOM, len);
      TEncoding.GetBufferEncoding(bufBOM, outEncoding, TEncoding.UTF8)
    end;

    outStream.Seek(0, soFromEnd)
  end;

  inherited Create(outStream, True, outEncoding)
end;

{$ENDREGION 'TDunitXTextFileLogger'}


end.

