{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2015 Vincent Parrett & Contributors               }
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

unit DUnitX.Loggers.Console;

interface

{$I DUnitX.inc}

uses
  DUnitX.ConsoleWriter.Base,
  DUnitX.TestFramework;

type
  /// <summary>
  ///   Logger that writes indented, colour-coded progress and a summary to the console. In quiet mode it writes one
  ///   character per test outcome (<c>.</c> pass, <c>F</c> failure, <c>E</c> error, <c>I</c> ignored, <c>M</c> leak)
  ///   followed by the summary.
  /// </summary>
  TDUnitXConsoleLogger = class(TInterfacedObject, ITestLogger)
  private
    /// <summary>The console writer resolved from the service locator; does all indenting, colouring and output.</summary>
    FConsoleWriter : IDUnitXConsoleWriter;
    /// <summary>True for terse one-character-per-test output instead of the full indented log.</summary>
    FQuietMode : boolean;
  strict protected
    /// <summary>Restores the console's default colours.</summary>
    procedure SetConsoleDefaultColor(); virtual;
    /// <summary>Sets the colours used for failures and errors (bright red on black).</summary>
    procedure SetConsoleErrorColor(); virtual;
    /// <summary>Sets the colours used for passing tests (bright green on black).</summary>
    procedure SetConsolePassColor(); virtual;
    /// <summary>Sets the colours used for test setup lines (bright purple on black).</summary>
    procedure SetConsoleSetupTestColor(); virtual;
    /// <summary>Sets the colours used for the test heading (bright aqua on black).</summary>
    procedure SetConsoleRunTestColor(); virtual;
    /// <summary>Sets the colours used for the end-of-run summary (bright white on black).</summary>
    procedure SetConsoleSummaryColor(); virtual;
    /// <summary>Sets the colours used for warnings, fixture headings and leaks (bright yellow on black).</summary>
    procedure SetConsoleWarningColor(); virtual;
  protected
    /// <summary>Called once before the first fixture runs; in quiet mode writes the "starting tests" banner.</summary>
    /// <param name="threadId">The thread starting the run.</param>
    /// <param name="testCount">The total number of tests found.</param>
    /// <param name="testActiveCount">The number of tests that will actually run.</param>
    procedure OnTestingStarts(const threadId : TThreadID; testCount, testActiveCount : Cardinal);

    /// <summary>Writes the fixture's full name as a heading and indents what follows.</summary>
    /// <param name="threadId">The thread running the fixture.</param>
    /// <param name="fixture">The fixture starting.</param>
    procedure OnStartTestFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);

    /// <summary>Writes the name of the fixture setup method about to run.</summary>
    /// <param name="threadId">The thread running the fixture.</param>
    /// <param name="fixture">The fixture being set up.</param>
    procedure OnSetupFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
    /// <summary>Outdents after the fixture setup and writes a blank line.</summary>
    /// <param name="threadId">The thread running the fixture.</param>
    /// <param name="fixture">The fixture whose setup finished.</param>
    procedure OnEndSetupFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);

    /// <summary>Writes the test's full name as a heading and indents what follows.</summary>
    /// <param name="threadId">The thread running the test.</param>
    /// <param name="Test">The test about to begin.</param>
    procedure OnBeginTest(const threadId : TThreadID; const Test : ITestInfo);

    /// <summary>Writes a "running setup" line for the test.</summary>
    /// <param name="threadId">The thread running the test.</param>
    /// <param name="Test">The test being set up.</param>
    procedure OnSetupTest(const threadId : TThreadID; const Test : ITestInfo);
    /// <summary>Writes a blank line after the test setup.</summary>
    /// <param name="threadId">The thread running the test.</param>
    /// <param name="Test">The test whose setup finished.</param>
    procedure OnEndSetupTest(const threadId : TThreadID; const Test : ITestInfo);

    /// <summary>Writes an "executing test" line, or a <c>.</c> progress mark in quiet mode.</summary>
    /// <param name="threadId">The thread running the test.</param>
    /// <param name="Test">The test about to execute.</param>
    procedure OnExecuteTest(const threadId : TThreadID; const Test : ITestInfo);

    /// <summary>In quiet mode writes <c>M</c>; otherwise the leak is reported only in the summary.</summary>
    /// <param name="threadId">The thread that ran the test.</param>
    /// <param name="Test">The leaking test's result.</param>
    procedure OnTestMemoryLeak(const threadId : TThreadID; const Test : ITestResult);
    /// <summary>In quiet mode writes <c>I</c>; otherwise writes nothing.</summary>
    /// <param name="threadId">The thread that would have run the test.</param>
    /// <param name="AIgnored">The ignored test's result.</param>
    procedure OnTestIgnored(const threadId : TThreadID; const AIgnored : ITestResult);
    /// <summary>In quiet mode writes <c>E</c>; otherwise the error is reported only in the summary.</summary>
    /// <param name="threadId">The thread that ran the test.</param>
    /// <param name="Error">The error result.</param>
    procedure OnTestError(const threadId : TThreadID; const Error : ITestError);
    /// <summary>In quiet mode writes <c>F</c>; otherwise the failure is reported only in the summary.</summary>
    /// <param name="threadId">The thread that ran the test.</param>
    /// <param name="Failure">The failure result.</param>
    procedure OnTestFailure(const threadId : TThreadID; const Failure : ITestError);
    /// <summary>Writes a green "success" line with any result message, or a <c>.</c> in quiet mode.</summary>
    /// <param name="threadId">The thread that ran the test.</param>
    /// <param name="Test">The passing test's result.</param>
    procedure OnTestSuccess(const threadId : TThreadID; const Test : ITestResult);
    /// <summary>Writes a log message, coloured by its level; suppressed in quiet mode.</summary>
    /// <param name="logType">The severity, which selects the colour.</param>
    /// <param name="msg">The message text.</param>
    procedure OnLog(const logType : TLogLevel; const msg : string);

    /// <summary>Writes a "running teardown" line for the test.</summary>
    /// <param name="threadId">The thread running the test.</param>
    /// <param name="Test">The test being torn down.</param>
    procedure OnTeardownTest(const threadId : TThreadID; const Test : ITestInfo);
    /// <summary>Called after a test's teardown. Writes nothing.</summary>
    /// <param name="threadId">The thread running the test.</param>
    /// <param name="Test">The test whose teardown finished.</param>
    procedure OnEndTeardownTest(const threadId : TThreadID; const Test : ITestInfo);

    /// <summary>Outdents after the test and writes a blank line.</summary>
    /// <param name="threadId">The thread that ran the test.</param>
    /// <param name="Test">The finished test's result.</param>
    procedure OnEndTest(const threadId : TThreadID; const Test : ITestResult);

    /// <summary>Writes the name of the fixture teardown method about to run.</summary>
    /// <param name="threadId">The thread running the fixture.</param>
    /// <param name="fixture">The fixture being torn down.</param>
    procedure OnTearDownFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
    /// <summary>Called after a fixture's teardown. Writes nothing.</summary>
    /// <param name="threadId">The thread running the fixture.</param>
    /// <param name="fixture">The fixture whose teardown finished.</param>
    procedure OnEndTearDownFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);

    /// <summary>Outdents back out of the fixture and writes a blank line.</summary>
    /// <param name="threadId">The thread that ran the fixture.</param>
    /// <param name="results">The fixture's aggregated results.</param>
    procedure OnEndTestFixture(const threadId : TThreadID; const results : IFixtureResult);

    /// <summary>
    ///   Writes the end-of-run summary: counts of tests found, ignored, passed, leaked, failed and errored, then the
    ///   name and message of every failing, erroring and leaking test.
    /// </summary>
    /// <param name="RunResults">The results of the whole run.</param>
    procedure OnTestingEnds(const RunResults : IRunResults);
  public
    /// <summary>
    ///   Creates the logger and resolves the console writer from the default service locator container.
    /// </summary>
    /// <param name="quietMode">
    ///   True for terse one-character-per-test output; False (the default) for the full indented log.
    /// </param>
    /// <exception cref="Exception">
    ///   No <c>IDUnitXConsoleWriter</c> is registered (add <c>DUnitX.AutoDetect.Console</c> or a console writer unit).
    /// </exception>
    constructor Create(const quietMode : boolean = false);
    /// <summary>Destroys the logger.</summary>
    destructor Destroy; override;
  end;

implementation

uses
  DUnitX.ResStrs,
{$IFDEF USE_NS}
  System.SysUtils,
{$ELSE}
  SysUtils,
{$ENDIF}
  DUnitX.AutoDetect.Console,
  DUnitX.ServiceLocator;

{ TDUnitXConsoleLogger }

constructor TDUnitXConsoleLogger.Create(const quietMode : boolean = false);
begin
  FQuietMode := quietMode;
  FConsoleWriter := TDUnitXServiceLocator.DefaultContainer.Resolve<IDUnitXConsoleWriter>();
  if FConsoleWriter = nil then
    raise Exception.Create(SNoConsoleWriterClassRegistered);
end;

destructor TDUnitXConsoleLogger.Destroy;
begin

  inherited;
end;

procedure TDUnitXConsoleLogger.OnEndSetupFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
begin
  if FQuietMode then
    exit;

  FConsoleWriter.Outdent(1);
  FConsoleWriter.WriteLn;
end;

procedure TDUnitXConsoleLogger.OnEndSetupTest(const threadId : TThreadID; const Test : ITestInfo);
begin
  if FQuietMode then
    exit;

  //  FConsoleWriter.WriteLn;
  //  FConsoleWriter.Outdent(1);
  FConsoleWriter.WriteLn;
end;

procedure TDUnitXConsoleLogger.OnEndTearDownFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
begin

end;

procedure TDUnitXConsoleLogger.OnEndTeardownTest(const threadId : TThreadID; const Test : ITestInfo);
begin

end;

procedure TDUnitXConsoleLogger.OnEndTest(const threadId : TThreadID; const Test : ITestResult);
begin
  if FQuietMode then
    exit;

  FConsoleWriter.Outdent(1);
  FConsoleWriter.WriteLn;
end;

procedure TDUnitXConsoleLogger.OnEndTestFixture(const threadId : TThreadID; const results : IFixtureResult);
begin
  if FQuietMode then
    exit;

  FConsoleWriter.Outdent(3);
  FConsoleWriter.WriteLn;
end;

procedure TDUnitXConsoleLogger.OnExecuteTest(const threadId : TThreadID; const Test : ITestInfo);
begin
  if FQuietMode then
  begin
    FConsoleWriter.Write('.');
    exit;
  end;

  //SetConsoleRunTestColor();
  //FConsoleWriter.Indent(1);
  FConsoleWriter.WriteLn(SExecutingTest + Test.Name);
  FConsoleWriter.WriteLn;
  //SetConsoleDefaultColor();
end;

procedure TDUnitXConsoleLogger.OnTestError(const threadId : TThreadID; const Error : ITestError);
begin
  if FQuietMode then
  begin
    FConsoleWriter.Write('E');
    exit;
  end;
end;

procedure TDUnitXConsoleLogger.OnTestFailure(const threadId : TThreadID; const Failure : ITestError);
begin
  if FQuietMode then
  begin
    FConsoleWriter.Write('F');
    exit;
  end;
end;

procedure TDUnitXConsoleLogger.OnTestIgnored(const threadId : TThreadID; const AIgnored : ITestResult);
begin
  if FQuietMode then
    FConsoleWriter.Write('I');

end;

procedure TDUnitXConsoleLogger.OnLog(const logType : TLogLevel; const msg : string);
begin
  if FQuietMode then
    exit;

  FConsoleWriter.Indent(2);
  try

    case logType of
      TLogLevel.Information : SetConsoleDefaultColor();
      TLogLevel.Warning : SetConsoleWarningColor();
      TLogLevel.Error : SetConsoleErrorColor();
    end;

    FConsoleWriter.WriteLn(msg);
  finally
    FConsoleWriter.Outdent(2);
    SetConsoleDefaultColor();
  end;
end;

procedure TDUnitXConsoleLogger.OnSetupFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
begin
  if FQuietMode then
    exit;

  FConsoleWriter.Indent(1);
  FConsoleWriter.WriteLn(SRunningFixtureSetup + fixture.SetupFixtureMethodName);

end;

procedure TDUnitXConsoleLogger.OnSetupTest(const threadId : TThreadID; const Test : ITestInfo);
begin
  if FQuietMode then
    exit;

  SetConsoleSetupTestColor();
  FConsoleWriter.WriteLn(SRunningSetup + Test.Name);
end;

procedure TDUnitXConsoleLogger.OnBeginTest(const threadId : TThreadID; const Test : ITestInfo);
begin
  if FQuietMode then
    exit;

  SetConsoleRunTestColor();
  FConsoleWriter.Indent(1);
  FConsoleWriter.WriteLn(STest + Test.FullName);
  FConsoleWriter.WriteLn('-------------------------------------------------');
  SetConsoleDefaultColor();
end;

procedure TDUnitXConsoleLogger.OnStartTestFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
begin
  if FQuietMode then
    exit;

  SetConsoleWarningColor();
  FConsoleWriter.Indent(2);
  FConsoleWriter.WriteLn(SFixture + fixture.FullName);
  FConsoleWriter.WriteLn('-------------------------------------------------');
  FConsoleWriter.Indent(1);
  SetConsoleDefaultColor();
end;

procedure TDUnitXConsoleLogger.OnTestSuccess(const threadId : TThreadID; const Test : ITestResult);
var
  sMessage : string;
begin
  if FQuietMode then
  begin
    FConsoleWriter.Write('.');
    exit;
  end;
  FConsoleWriter.Indent(2);
  SetConsolePassColor;
  if Test.Message <> '' then
    sMessage := SSuccess + ' : ' + Test.Message
  else
    sMessage := SSuccess + '.';
  FConsoleWriter.WriteLn(sMessage);
  SetConsoleDefaultColor;
  FConsoleWriter.Outdent(2);
end;

procedure TDUnitXConsoleLogger.OnTearDownFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
begin
  if FQuietMode then
    exit;

  FConsoleWriter.WriteLn(SRunningFixtureTeardown + fixture.TearDownFixtureMethodName);
  FConsoleWriter.WriteLn;
end;

procedure TDUnitXConsoleLogger.OnTeardownTest(const threadId : TThreadID; const Test : ITestInfo);
begin
  if FQuietMode then
    exit;

  FConsoleWriter.WriteLn;
  FConsoleWriter.Indent(1);
  FConsoleWriter.WriteLn(SRunningTestTeardown + test.Name);
  FConsoleWriter.WriteLn;
  FConsoleWriter.Outdent(1);
end;

procedure TDUnitXConsoleLogger.OnTestingEnds(const RunResults : IRunResults);
var
  testResult : ITestResult;
begin
  if FQuietMode then
  begin
    FConsoleWriter.WriteLn;
    FConsoleWriter.WriteLn;
  end
  else
  begin
    FConsoleWriter.OutDent(1);
    FConsoleWriter.WriteLn(SDoneTesting);
  end;

  SetConsoleSummaryColor();
  FConsoleWriter.WriteLn(Format(STestsFound, [RunResults.TestCount]));

  if RunResults.IgnoredCount > 0 then
    SetConsoleWarningColor()
  else
    SetConsoleDefaultColor();
  FConsoleWriter.WriteLn(Format(STestsIgnored, [RunResults.IgnoredCount]));

  if RunResults.PassCount > 0 then
    SetConsolePassColor()
  else
    SetConsoleDefaultColor();
  FConsoleWriter.WriteLn(Format(STestsPassed, [RunResults.PassCount]));

  if RunResults.MemoryLeakCount > 0 then
    SetConsoleWarningColor()
  else
    SetConsoleDefaultColor();
  FConsoleWriter.WriteLn(Format(STestsLeaked, [RunResults.MemoryLeakCount]));

  if RunResults.FailureCount > 0 then
    SetConsoleErrorColor()
  else
    SetConsoleDefaultColor();
  FConsoleWriter.WriteLn(Format(STestsFailed, [RunResults.FailureCount]));

  if RunResults.ErrorCount > 0 then
    SetConsoleErrorColor()
  else
    SetConsoleDefaultColor();
  FConsoleWriter.WriteLn(Format(STestsErrored, [RunResults.ErrorCount]));

  if RunResults.FailureCount > 0 then
  begin
    SetConsoleErrorColor();
    FConsoleWriter.WriteLn;
    FConsoleWriter.WriteLn(SFailingTests);
    FConsoleWriter.WriteLn;
    SetConsoleDefaultColor();

    for testResult in RunResults.GetAllTestResults do
    begin
      if testResult.ResultType = TTestResultType.Failure then
      begin
        SetConsoleErrorColor();
        FConsoleWriter.WriteLn('  ' + testResult.Test.FullName);
        SetConsoleDefaultColor();
        FConsoleWriter.WriteLn(SMessage + testResult.Message);
        FConsoleWriter.WriteLn;
      end;
    end;
    FConsoleWriter.WriteLn;
  end;

  if RunResults.ErrorCount > 0 then
  begin
    SetConsoleErrorColor();
    FConsoleWriter.WriteLn;
    FConsoleWriter.WriteLn(STestsWithErrors);
    FConsoleWriter.WriteLn;
    SetConsoleDefaultColor();

    for testResult in RunResults.GetAllTestResults do
    begin
      if testResult.ResultType = TTestResultType.Error then
      begin
        SetConsoleErrorColor();
        FConsoleWriter.WriteLn('  ' + testResult.Test.FullName);
        SetConsoleDefaultColor();
        FConsoleWriter.WriteLn(SMessage + testResult.Message);
        FConsoleWriter.WriteLn;
      end;
    end;
    FConsoleWriter.WriteLn;
  end;

  if RunResults.MemoryLeakCount > 0 then
  begin
    SetConsoleWarningColor();
    FConsoleWriter.WriteLn;
    FConsoleWriter.WriteLn(STestsWithLeak);
    FConsoleWriter.WriteLn;
    SetConsoleDefaultColor();

    for testResult in RunResults.GetAllTestResults do
    begin
      if testResult.ResultType = TTestResultType.MemoryLeak then
      begin
        SetConsoleWarningColor();
        FConsoleWriter.WriteLn('  ' + testResult.Test.FullName);
        SetConsoleDefaultColor();
        FConsoleWriter.WriteLn(SMessage + testResult.Message);
        FConsoleWriter.WriteLn;
      end;
    end;
    FConsoleWriter.WriteLn;
  end;

  SetConsoleDefaultColor();
end;

procedure TDUnitXConsoleLogger.OnTestingStarts(const threadId : TThreadID; testCount, testActiveCount : Cardinal);
begin
  if FQuietMode then
  begin
    FConsoleWriter.WriteLn(Format(SStartingTests, [ExtractFileName(ParamStr(0))]));
    FConsoleWriter.WriteLn;
    exit;
  end;
end;

procedure TDUnitXConsoleLogger.OnTestMemoryLeak(const threadId : TThreadID; const Test : ITestResult);
begin
  if FQuietMode then
    FConsoleWriter.Write('M');
end;

procedure TDUnitXConsoleLogger.SetConsoleDefaultColor();
begin
  FConsoleWriter.SetColour(ccDefault);
end;

procedure TDUnitXConsoleLogger.SetConsoleErrorColor();
begin
  FConsoleWriter.SetColour(ccBrightRed, ccBlack);
end;

procedure TDUnitXConsoleLogger.SetConsolePassColor();
begin
  FConsoleWriter.SetColour(ccBrightGreen, ccBlack);
end;

procedure TDUnitXConsoleLogger.SetConsoleRunTestColor();
begin
  FConsoleWriter.SetColour(ccBrightAqua, ccBlack);
end;

procedure TDUnitXConsoleLogger.SetConsoleSetupTestColor();
begin
  FConsoleWriter.SetColour(ccBrightPurple, ccBlack);
end;

procedure TDUnitXConsoleLogger.SetConsoleSummaryColor();
begin
  FConsoleWriter.SetColour(ccBrightWhite, ccBlack);
end;

procedure TDUnitXConsoleLogger.SetConsoleWarningColor();
begin
  FConsoleWriter.SetColour(ccBrightYellow, ccBlack);
end;

end.

