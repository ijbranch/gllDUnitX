{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2016 Vincent Parrett                              }
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

unit DUnitX.Loggers.GUI.VCL.RichEdit;

interface

{$I DUnitX.inc}

uses
{$IFDEF USE_NS}
  Vcl.ComCtrls,
  Vcl.Graphics,
  System.Generics.Collections,
{$ELSE}
  ComCtrls,
  Graphics,
  Generics.Collections,
{$ENDIF}
  DUnitX.ConsoleWriter.Base,
  DUnitX.TestFramework;

type
  /// <summary>
  ///   Maps a test's full name to the rich edit line where its output begins, so the GUI runner can scroll the log to
  ///   the test the user selects.
  /// </summary>
  TTestBookmarkList = TDictionary<string, integer>;

  /// <summary>
  ///   Logger used by the VCL GUI runner: writes the console-style, colour-coded progress log and summary into a
  ///   <c>TRichEdit</c>, recording where each test's output begins. Tests failed only for making no assertions are
  ///   listed as warnings in the summary rather than as failures.
  /// </summary>
  TDUnitXGUIVCLRichEditLogger = class(TInterfacedObject, ITestLogger)
  private
    /// <summary>The rich edit the log is written into; owned by the form, not the logger.</summary>
    FRichEdit : TRichEdit;
    /// <summary>The current indent, in spaces.</summary>
    FIndent : integer;
    /// <summary>The colour applied to the next line written.</summary>
    FCurrColor : TColor;
    /// <summary>The caller's test-to-line map, filled as each test begins; owned by the caller.</summary>
    FTestBookmarkList : TTestBookmarkList;
    /// <summary>The indent at the start of each open fixture, so its end can restore it even after a failed setup.</summary>
    FFixtureIndents : TStack<integer>;
    /// <summary>Appends a line at the end of the rich edit, at the current indent and colour, wherever the caret is.</summary>
    /// <param name="Msg">The text of the line.</param>
    procedure Write(const Msg : string);
    /// <summary>Appends an empty line at the end of the rich edit.</summary>
    procedure WriteBlankLine;
    /// <summary>Sets the colour of the following lines.</summary>
    /// <param name="Color">The text colour.</param>
    procedure SetColor(const Color : TColor);
    /// <summary>Increases the indent.</summary>
    /// <param name="Value">The number of spaces to add.</param>
    procedure Indent(const Value : integer = 1);
    /// <summary>Decreases the indent.</summary>
    /// <param name="Value">The number of spaces to remove.</param>
    procedure Outdent(const Value : integer = 1);
  strict protected
    /// <summary>Sets the default text colour (black).</summary>
    procedure SetConsoleDefaultColor; virtual;
    /// <summary>Sets the colour used for failures and errors (red).</summary>
    procedure SetConsoleErrorColor; virtual;
    /// <summary>Sets the colour used for passing tests (green).</summary>
    procedure SetConsolePassColor; virtual;
    /// <summary>Sets the colour used for the test heading (navy).</summary>
    procedure SetConsoleRunTestColor; virtual;
    /// <summary>Sets the colour used for test setup lines (purple).</summary>
    procedure SetConsoleSetupTestColor; virtual;
    /// <summary>Sets the colour used for the end-of-run summary (black).</summary>
    procedure SetConsoleSummaryColor; virtual;
    /// <summary>Sets the colour used for warnings, fixture headings and leaks (olive).</summary>
    procedure SetConsoleWarningColor; virtual;
  protected
    /// <summary>
    ///   Records the line where the test's output begins (a test that begins twice keeps the later line), then writes
    ///   its full name as a heading and indents.
    /// </summary>
    /// <param name="threadId">The thread running the test.</param>
    /// <param name="Test">The test about to begin.</param>
    procedure OnBeginTest(const threadId : TThreadID; const Test : ITestInfo);
    /// <summary>Outdents after the fixture setup.</summary>
    /// <param name="threadId">The thread running the fixture.</param>
    /// <param name="fixture">The fixture whose setup finished.</param>
    procedure OnEndSetupFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
    /// <summary>Called after a test's setup. Writes nothing.</summary>
    /// <param name="threadId">The thread running the test.</param>
    /// <param name="Test">The test whose setup finished.</param>
    procedure OnEndSetupTest(const threadId : TThreadID; const Test : ITestInfo);
    /// <summary>Called after a fixture's teardown. Writes nothing.</summary>
    /// <param name="threadId">The thread running the fixture.</param>
    /// <param name="fixture">The fixture whose teardown finished.</param>
    procedure OnEndTearDownFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
    /// <summary>Called after a test's teardown. Writes nothing.</summary>
    /// <param name="threadId">The thread running the test.</param>
    /// <param name="Test">The test whose teardown finished.</param>
    procedure OnEndTeardownTest(const threadId : TThreadID; const Test : ITestInfo);
    /// <summary>Outdents after the test.</summary>
    /// <param name="threadId">The thread that ran the test.</param>
    /// <param name="Test">The finished test's result.</param>
    procedure OnEndTest(const threadId : TThreadID; const Test : ITestResult);
    /// <summary>
    ///   Restores the indent the fixture started at (so a failed fixture setup cannot leave it skewed) and writes a
    ///   blank line.
    /// </summary>
    /// <param name="threadId">The thread that ran the fixture.</param>
    /// <param name="results">The fixture's aggregated results.</param>
    procedure OnEndTestFixture(const threadId : TThreadID; const results : IFixtureResult);
    /// <summary>Writes an "executing test" line.</summary>
    /// <param name="threadId">The thread running the test.</param>
    /// <param name="Test">The test about to execute.</param>
    procedure OnExecuteTest(const threadId : TThreadID; const Test : ITestInfo);
    /// <summary>Writes a log message, indented and coloured by its level.</summary>
    /// <param name="logType">The severity, which selects the colour.</param>
    /// <param name="msg">The message text.</param>
    procedure OnLog(const logType : TLogLevel; const msg : string);
    /// <summary>Writes the name of the fixture setup method about to run.</summary>
    /// <param name="threadId">The thread running the fixture.</param>
    /// <param name="fixture">The fixture being set up.</param>
    procedure OnSetupFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
    /// <summary>Writes a "running setup" line for the test.</summary>
    /// <param name="threadId">The thread running the test.</param>
    /// <param name="Test">The test being set up.</param>
    procedure OnSetupTest(const threadId : TThreadID; const Test : ITestInfo);
    /// <summary>Saves the current indent, writes the fixture's full name as a heading and indents.</summary>
    /// <param name="threadId">The thread running the fixture.</param>
    /// <param name="fixture">The fixture starting.</param>
    procedure OnStartTestFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
    /// <summary>Writes the name of the fixture teardown method about to run.</summary>
    /// <param name="threadId">The thread running the fixture.</param>
    /// <param name="fixture">The fixture being torn down.</param>
    procedure OnTearDownFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
    /// <summary>Writes a "running teardown" line for the test.</summary>
    /// <param name="threadId">The thread running the test.</param>
    /// <param name="Test">The test being torn down.</param>
    procedure OnTeardownTest(const threadId : TThreadID; const Test : ITestInfo);
    /// <summary>Called when a test errors. Writes nothing; errors appear in the summary.</summary>
    /// <param name="threadId">The thread that ran the test.</param>
    /// <param name="Error">The error result.</param>
    procedure OnTestError(const threadId : TThreadID; const Error : ITestError);
    /// <summary>Called when a test fails. Writes nothing; failures appear in the summary.</summary>
    /// <param name="threadId">The thread that ran the test.</param>
    /// <param name="Failure">The failure result.</param>
    procedure OnTestFailure(const threadId : TThreadID; const Failure : ITestError);
    /// <summary>Called when a test is ignored. Writes nothing.</summary>
    /// <param name="threadId">The thread that would have run the test.</param>
    /// <param name="AIgnored">The ignored test's result.</param>
    procedure OnTestIgnored(const threadId : TThreadID; const AIgnored : ITestResult);
    /// <summary>
    ///   Writes the end-of-run summary: counts found, ignored, passed, leaked, failed, errored and warned, then the
    ///   failing, erroring, no-assertion (warning) and leaking tests with their messages. A failure whose message is
    ///   the no-assertions message is counted as a warning, not a failure.
    /// </summary>
    /// <param name="RunResults">The results of the whole run.</param>
    procedure OnTestingEnds(const RunResults : IRunResults);
    /// <summary>Clears the rich edit, the bookmarks and the indent, then writes the "starting tests" banner.</summary>
    /// <param name="threadId">The thread starting the run.</param>
    /// <param name="testCount">The total number of tests found.</param>
    /// <param name="testActiveCount">The number of tests that will actually run.</param>
    procedure OnTestingStarts(const threadId : TThreadID; testCount, testActiveCount : Cardinal);
    /// <summary>Called when a test leaks. Writes nothing; leaks appear in the summary.</summary>
    /// <param name="threadId">The thread that ran the test.</param>
    /// <param name="Test">The leaking test's result.</param>
    procedure OnTestMemoryLeak(const threadId : TThreadID; const Test : ITestResult);
    /// <summary>Writes a green "success" line with any result message.</summary>
    /// <param name="threadId">The thread that ran the test.</param>
    /// <param name="Test">The passing test's result.</param>
    procedure OnTestSuccess(const threadId : TThreadID; const Test : ITestResult);
  public
    /// <summary>Creates a logger writing into the given rich edit.</summary>
    /// <param name="RichEdit">The rich edit to write into; not owned by the logger.</param>
    /// <param name="TestBookmarkList">The map to fill with each test's starting line; not owned by the logger.</param>
    constructor Create(const RichEdit : TRichEdit; const TestBookmarkList : TTestBookmarkList);
    /// <summary>Frees the fixture indent stack.</summary>
    destructor Destroy; override;
  end;

implementation

uses
{$IFDEF USE_NS}
  System.SysUtils,
{$ELSE}
  SysUtils,
{$ENDIF}
  DUnitX.ResStrs;

resourcestring
  STestsWithWarnings = 'Tests With Warnings';

constructor TDUnitXGUIVCLRichEditLogger.Create(const RichEdit : TRichEdit; const TestBookmarkList : TTestBookmarkList);
begin
  FRichEdit := RichEdit;
  FTestBookmarkList := TestBookmarkList;
  FFixtureIndents := TStack<integer>.Create;

  FIndent := 0;
end;

destructor TDUnitXGUIVCLRichEditLogger.Destroy;
begin
  FFixtureIndents.Free;
  inherited;
end;

procedure TDUnitXGUIVCLRichEditLogger.Indent(const Value : integer);
begin
  Inc(FIndent, Value);
end;

procedure TDUnitXGUIVCLRichEditLogger.OnBeginTest(const threadId : TThreadID; const Test : ITestInfo);
begin
  //A test can begin twice (a fixture teardown failure, a duplicate name): the latest output wins.
  FTestBookmarkList.AddOrSetValue(Test.FullName, FRichEdit.Lines.Count);

  SetConsoleRunTestColor();
  Indent(1);
  Write(STest + Test.FullName);
  Write('-------------------------------------------------');
  SetConsoleDefaultColor();
end;

procedure TDUnitXGUIVCLRichEditLogger.OnEndSetupFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
begin
  Outdent(1);
end;

procedure TDUnitXGUIVCLRichEditLogger.OnEndSetupTest(const threadId : TThreadID; const Test : ITestInfo);
begin
  //Empty
end;

procedure TDUnitXGUIVCLRichEditLogger.OnEndTearDownFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
begin
  //Empty
end;

procedure TDUnitXGUIVCLRichEditLogger.OnEndTeardownTest(const threadId : TThreadID; const Test : ITestInfo);
begin
  //Empty
end;

procedure TDUnitXGUIVCLRichEditLogger.OnEndTest(const threadId : TThreadID; const Test : ITestResult);
begin
  Outdent(1);
end;

procedure TDUnitXGUIVCLRichEditLogger.OnEndTestFixture(const threadId : TThreadID; const results : IFixtureResult);
begin
  //Restore the indent the fixture started at: a failed fixture setup never reaches OnEndSetupFixture.
  if FFixtureIndents.Count > 0 then
    FIndent := FFixtureIndents.Pop
  else
    Outdent(3);
  WriteBlankLine;
end;

procedure TDUnitXGUIVCLRichEditLogger.OnExecuteTest(const threadId : TThreadID; const Test : ITestInfo);
begin
  Write(SExecutingTest + Test.Name);
  WriteBlankLine;
end;

procedure TDUnitXGUIVCLRichEditLogger.OnLog(const logType : TLogLevel; const msg : string);
begin
  Indent(2);
  try
    case logType of
      TLogLevel.Information : SetConsoleDefaultColor();
      TLogLevel.Warning : SetConsoleWarningColor();
      TLogLevel.Error : SetConsoleErrorColor();
    end;

    Write(msg);
  finally
    Outdent(2);
    SetConsoleDefaultColor();
  end;
end;

procedure TDUnitXGUIVCLRichEditLogger.OnSetupFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
begin
  Indent(1);
  Write(SRunningFixtureSetup + fixture.SetupFixtureMethodName);
end;

procedure TDUnitXGUIVCLRichEditLogger.OnSetupTest(const threadId : TThreadID; const Test : ITestInfo);
begin
  SetConsoleSetupTestColor();
  Write(SRunningSetup + Test.Name);
end;

procedure TDUnitXGUIVCLRichEditLogger.OnStartTestFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
begin
  FFixtureIndents.Push(FIndent);
  SetConsoleWarningColor();
  Indent(2);
  Write(SFixture + fixture.FullName);
  Write('-------------------------------------------------');
  Indent(1);
  SetConsoleDefaultColor();
end;

procedure TDUnitXGUIVCLRichEditLogger.OnTearDownFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
begin
  Write(SRunningFixtureTeardown + fixture.TearDownFixtureMethodName);
  WriteBlankLine;
end;

procedure TDUnitXGUIVCLRichEditLogger.OnTeardownTest(const threadId : TThreadID; const Test : ITestInfo);
begin
  WriteBlankLine;
  Indent(1);
  Write(SRunningTestTeardown + test.Name);
  WriteBlankLine;
  Outdent(1);
end;

procedure TDUnitXGUIVCLRichEditLogger.OnTestError(const threadId : TThreadID; const Error : ITestError);
begin
  //Empty
end;

procedure TDUnitXGUIVCLRichEditLogger.OnTestFailure(const threadId : TThreadID; const Failure : ITestError);
begin
  //Empty
end;

procedure TDUnitXGUIVCLRichEditLogger.OnTestIgnored(const threadId : TThreadID; const AIgnored : ITestResult);
begin
  //Empty
end;

procedure TDUnitXGUIVCLRichEditLogger.OnTestingEnds(const RunResults : IRunResults);

  //The GUI makes the runner fail tests that make no assertions; like the structured summary, this lists
  //them as warnings, not failures.
  function IsNoAssertions(const TestResult : ITestResult) : boolean;
  begin
    Result := (TestResult.ResultType = TTestResultType.Failure) and (TestResult.Message = SNoAssertions);
  end;

var
  TestResult : ITestResult;
  WarningCount : integer;
  FailureCount : integer;
begin
  WarningCount := 0;
  for TestResult in RunResults.GetAllTestResults do
    if IsNoAssertions(TestResult) then
      Inc(WarningCount);
  FailureCount := RunResults.FailureCount - WarningCount;
  if FailureCount < 0 then
    FailureCount := 0;

  OutDent(1);
  Write(SDoneTesting);

  SetConsoleSummaryColor;
  Write(Format(STestsFound, [RunResults.TestCount]));

  if RunResults.IgnoredCount > 0 then
    SetConsoleWarningColor()
  else
    SetConsoleDefaultColor;
  Write(Format(STestsIgnored, [RunResults.IgnoredCount]));

  if RunResults.PassCount > 0 then
    SetConsolePassColor()
  else
    SetConsoleDefaultColor;
  Write(Format(STestsPassed, [RunResults.PassCount]));

  if RunResults.MemoryLeakCount > 0 then
    SetConsoleWarningColor()
  else
    SetConsoleDefaultColor;
  Write(Format(STestsLeaked, [RunResults.MemoryLeakCount]));

  if FailureCount > 0 then
    SetConsoleErrorColor()
  else
    SetConsoleDefaultColor;
  Write(Format(STestsFailed, [FailureCount]));

  if RunResults.ErrorCount > 0 then
    SetConsoleErrorColor()
  else
    SetConsoleDefaultColor;
  Write(Format(STestsErrored, [RunResults.ErrorCount]));

  if WarningCount > 0 then
    SetConsoleWarningColor()
  else
    SetConsoleDefaultColor;
  Write(Format(STestsWarning, [WarningCount]));

  if FailureCount > 0 then
  begin
    SetConsoleErrorColor;
    WriteBlankLine;
    Write(SFailingTests);
    WriteBlankLine;
    SetConsoleDefaultColor;

    for TestResult in RunResults.GetAllTestResults do
    begin
      if (TestResult.ResultType = TTestResultType.Failure) and (not IsNoAssertions(TestResult)) then
      begin
        SetConsoleErrorColor;
        Write('  ' + TestResult.Test.FullName);
        SetConsoleDefaultColor;
        Write(SMessage + TestResult.Message);
        WriteBlankLine;
      end;
    end;
    WriteBlankLine;
  end;

  if RunResults.ErrorCount > 0 then
  begin
    SetConsoleErrorColor;
    WriteBlankLine;
    Write(STestsWithErrors);
    WriteBlankLine;
    SetConsoleDefaultColor;

    for TestResult in RunResults.GetAllTestResults do
    begin
      if TestResult.ResultType = TTestResultType.Error then
      begin
        SetConsoleErrorColor;
        Write('  ' + TestResult.Test.FullName);
        SetConsoleDefaultColor;
        Write(SMessage + TestResult.Message);
        WriteBlankLine;
      end;
    end;
    WriteBlankLine;
  end;

  if WarningCount > 0 then
  begin
    SetConsoleWarningColor;
    WriteBlankLine;
    Write(STestsWithWarnings);
    WriteBlankLine;
    SetConsoleDefaultColor;

    for TestResult in RunResults.GetAllTestResults do
    begin
      if IsNoAssertions(TestResult) then
      begin
        SetConsoleWarningColor;
        Write('  ' + TestResult.Test.FullName);
        SetConsoleDefaultColor;
        Write(SMessage + TestResult.Message);
        WriteBlankLine;
      end;
    end;
    WriteBlankLine;
  end;

  if RunResults.MemoryLeakCount > 0 then
  begin
    SetConsoleWarningColor;
    WriteBlankLine;
    Write(STestsWithLeak);
    WriteBlankLine;
    SetConsoleDefaultColor;

    for TestResult in RunResults.GetAllTestResults do
    begin
      if TestResult.ResultType = TTestResultType.MemoryLeak then
      begin
        SetConsoleWarningColor;
        Write('  ' + TestResult.Test.FullName);
        SetConsoleDefaultColor;
        Write(SMessage + TestResult.Message);
        WriteBlankLine;
      end;
    end;
    WriteBlankLine;
  end;

  SetConsoleDefaultColor;
end;

procedure TDUnitXGUIVCLRichEditLogger.OnTestingStarts(const threadId : TThreadID; testCount, testActiveCount : Cardinal);
begin
  FRichEdit.Clear;
  FTestBookmarkList.Clear;
  FFixtureIndents.Clear;
  FIndent := 0;

  SetConsoleDefaultColor;
  Write(Format(SStartingTests, [ExtractFileName(ParamStr(0))]));
  WriteBlankLine;
end;

procedure TDUnitXGUIVCLRichEditLogger.OnTestMemoryLeak(const threadId : TThreadID; const Test : ITestResult);
begin
  //Empty
end;

procedure TDUnitXGUIVCLRichEditLogger.OnTestSuccess(const threadId : TThreadID; const Test : ITestResult);
var
  sMessage : string;
begin
  Indent(2);
  SetConsolePassColor;
  if Test.Message <> '' then
    sMessage := SSuccess + ' : ' + Test.Message
  else
    sMessage := SSuccess + '.';
  Write(sMessage);
  SetConsoleDefaultColor;
  Outdent(2);
end;

procedure TDUnitXGUIVCLRichEditLogger.Outdent(const Value : integer);
begin
  Dec(FIndent, Value);
end;

procedure TDUnitXGUIVCLRichEditLogger.SetColor(const Color : TColor);
begin
  FCurrColor := Color;
end;

procedure TDUnitXGUIVCLRichEditLogger.SetConsoleDefaultColor;
begin
  SetColor(clBlack);
end;

procedure TDUnitXGUIVCLRichEditLogger.SetConsoleErrorColor;
begin
  SetColor(clRed);
end;

procedure TDUnitXGUIVCLRichEditLogger.SetConsolePassColor;
begin
  SetColor(clGreen);
end;

procedure TDUnitXGUIVCLRichEditLogger.SetConsoleRunTestColor;
begin
  SetColor(clNavy);
end;

procedure TDUnitXGUIVCLRichEditLogger.SetConsoleSetupTestColor;
begin
  SetColor(clPurple);
end;

procedure TDUnitXGUIVCLRichEditLogger.SetConsoleSummaryColor;
begin
  SetColor(clBlack);
end;

procedure TDUnitXGUIVCLRichEditLogger.SetConsoleWarningColor;
begin
  SetColor(clOlive);
end;

procedure TDUnitXGUIVCLRichEditLogger.Write(const Msg : string);
begin
  //Append at the end, wherever the user has put the caret.
  FRichEdit.SelStart := FRichEdit.GetTextLen;
  FRichEdit.SelLength := 0;
  FRichEdit.SelAttributes.Color := FCurrColor;
  FRichEdit.SelText := StringOfChar(' ', FIndent) + Msg + #13#10;
end;

procedure TDUnitXGUIVCLRichEditLogger.WriteBlankLine;
begin
  FRichEdit.SelStart := FRichEdit.GetTextLen;
  FRichEdit.SelLength := 0;
  FRichEdit.SelText := #13#10;
end;

end.

