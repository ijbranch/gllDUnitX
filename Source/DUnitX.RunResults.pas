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

unit DUnitX.RunResults;

interface

{$I DUnitX.inc}

uses
{$IFDEF USE_NS}
  System.Classes,
  System.TimeSpan,
  System.Diagnostics,
  System.Generics.Collections,
{$ELSE}
  Classes,
  TimeSpan,
  Diagnostics,
  Generics.Collections,
{$ENDIF}
  DUnitX.TestFramework,
  DUnitX.InternalInterfaces,
  DUnitX.Generics;

type
  /// <summary>
  ///   The results of a whole test run: per-fixture results, every test result, outcome counts and timing. The
  ///   runner fills it through <c>ITestExecuteContext</c> and hands it to loggers as <c>IRunResults</c>.
  /// </summary>
  TDUnitXRunResults = class(TInterfacedObject, IRunResults, ITestExecuteContext)
  private
    /// <summary>False once any test ends in an outcome other than pass or ignored.</summary>
    FAllPassed : boolean;
    /// <summary>Number of tests that ended in an error.</summary>
    FErrorCount : integer;
    /// <summary>Number of tests that failed an assertion.</summary>
    FFailureCount : integer;
    /// <summary>Number of tests that passed.</summary>
    FPassCount : integer;
    /// <summary>Number of tests that were ignored.</summary>
    FIgnoredCount : integer;
    /// <summary>Number of tests that leaked memory.</summary>
    FMemoryLeakCount : Integer;
    /// <summary>Number of test results recorded, whatever their outcome.</summary>
    FTotalCount : integer;

    /// <summary>Times the run from construction to <c>RollupResults</c>.</summary>
    FStopWatch : TStopwatch;
    /// <summary>Wall-clock time the results object was created.</summary>
    FStartTime : TDateTime;
    /// <summary>Wall-clock time <c>RollupResults</c> was called; equals the start time until then.</summary>
    FFinishTime : TDateTime;
    /// <summary>Elapsed run time, set by <c>RollupResults</c>.</summary>
    FDuration : TTimeSpan;
    /// <summary>Top-level fixture results recorded by <c>RecordFixture</c>.</summary>
    FFixtureResults : IList<IFixtureResult>;
    /// <summary>Every test result recorded by <c>RecordResult</c>, in recording order.</summary>
    FAllTestResults : IList<ITestResult>;
  protected
    /// <summary>
    ///   Counts the recorded fixture results.
    /// </summary>
    /// <returns>
    ///   The number of fixtures recorded with <c>RecordFixture</c>.
    /// </returns>
    function GetFixtureCount : Integer;
    /// <summary>
    ///   Reports whether the run passed.
    /// </summary>
    /// <returns>
    ///   True only when no test failed, errored or leaked AND at least one test actually ran (not ignored); a run in
    ///   which nothing executed has not passed.
    /// </returns>
    function GetAllPassed : Boolean;
    /// <summary>
    ///   Counts the test results recorded.
    /// </summary>
    /// <returns>
    ///   The total number of results, whatever their outcome.
    /// </returns>
    function GetTestCount : Integer;
    /// <summary>
    ///   Counts tests that ended in an error.
    /// </summary>
    /// <returns>
    ///   The error count.
    /// </returns>
    function GetErrorCount : Integer;
    /// <summary>
    ///   Counts tests that failed an assertion.
    /// </summary>
    /// <returns>
    ///   The failure count.
    /// </returns>
    function GetFailureCount : Integer;
    /// <summary>
    ///   Counts tests that leaked memory.
    /// </summary>
    /// <returns>
    ///   The memory-leak count.
    /// </returns>
    function GetMemoryLeakCount : Integer;
    /// <summary>
    ///   Gives the fixture information of the run.
    /// </summary>
    /// <returns>
    ///   A new list of the fixture of each top-level fixture result, in the order they were recorded.
    /// </returns>
    function GetFixtures : IEnumerable<ITestFixtureInfo>;
    /// <summary>
    ///   Gives the top-level fixture results.
    /// </summary>
    /// <returns>
    ///   The fixture results in recording order.
    /// </returns>
    function GetFixtureResults : IEnumerable<IFixtureResult>;
    /// <summary>
    ///   Gives every test result of the run.
    /// </summary>
    /// <returns>
    ///   All test results in recording order.
    /// </returns>
    function GetAllTestResults : IEnumerable<ITestResult>;

    /// <summary>
    ///   Counts tests that passed.
    /// </summary>
    /// <returns>
    ///   The pass count.
    /// </returns>
    function GetPassCount : Integer;
    /// <summary>
    ///   Counts tests that were ignored.
    /// </summary>
    /// <returns>
    ///   The ignored count.
    /// </returns>
    function GetIgnoredCount : Integer;

    /// <summary>
    ///   Computes the percentage of tests that neither failed nor errored.
    /// </summary>
    /// <returns>
    ///   The truncated percentage, or 100 when no test was recorded.
    /// </returns>
    function GetSuccessRate : integer;
    /// <summary>
    ///   Gives the time the run started.
    /// </summary>
    /// <returns>
    ///   The wall-clock start time.
    /// </returns>
    function GetStartTime : TDateTime;
    /// <summary>
    ///   Gives the time the run finished.
    /// </summary>
    /// <returns>
    ///   The wall-clock finish time; equal to the start time until <c>RollupResults</c> runs.
    /// </returns>
    function GetFinishTime : TDateTime;
    /// <summary>
    ///   Gives the elapsed time of the run.
    /// </summary>
    /// <returns>
    ///   The stopwatch duration captured by <c>RollupResults</c>; zero before then.
    /// </returns>
    function GetDuration : TTimeSpan;

    /// <summary>
    ///   Implements <c>ITestExecuteContext</c>: adds a fixture result to the run.
    /// </summary>
    /// <param name="fixtureResult">
    ///   The fixture result to record.
    /// </param>
    procedure RecordFixture(const fixtureResult : IFixtureResult);
    /// <summary>
    ///   Implements <c>ITestExecuteContext</c>: counts a test result by outcome, clears the all-passed flag for any
    ///   outcome other than pass or ignored, and adds the result to its fixture and to the run's list.
    /// </summary>
    /// <param name="fixtureResult">
    ///   The result of the fixture the test belongs to; must support <c>IFixtureResultBuilder</c>.
    /// </param>
    /// <param name="testResult">
    ///   The test's result.
    /// </param>
    procedure RecordResult(const fixtureResult : IFixtureResult; const testResult : ITestResult);
    /// <summary>
    ///   Implements <c>ITestExecuteContext</c>; called when the run is done. Stamps the finish time and duration and
    ///   rolls up every recorded fixture result.
    /// </summary>
    procedure RollupResults;
  public
    /// <summary>
    ///   Creates empty results and starts the run's stopwatch and start time.
    /// </summary>
    constructor Create;
    /// <summary>
    ///   Releases the result lists.
    /// </summary>
    destructor Destroy; override;
    /// <summary>
    ///   Summarises the run as text.
    /// </summary>
    /// <returns>
    ///   The pass count formatted with <c>STestsPassed</c>, followed by a line break.
    /// </returns>
    function ToString : string; override;
  end;

implementation

uses
  DUnitX.ResStrs,
{$IFDEF USE_NS}
  System.DateUtils,
  System.SysUtils;
{$ELSE}
  DateUtils,
  SysUtils;
{$ENDIF}

{ TDUnitXTestResults }

constructor TDUnitXRunResults.Create;
begin
  FFixtureResults := TDUnitXList<IFixtureResult>.Create;
  FAllTestResults := TDUnitXList<ITestResult>.Create;
  FAllPassed := True;
  FErrorCount := 0;
  FPassCount := 0;
  FFailureCount := 0;
  FStartTime := Now;
  FFinishTime := FStartTime;
  FDuration := TTimeSpan.Zero;
  FStopWatch := TStopwatch.StartNew;
end;

destructor TDUnitXRunResults.Destroy;
begin
  //not required, but makes debugging easier.
  FAllTestResults := nil;
  inherited;
end;

function TDUnitXRunResults.GetAllPassed : Boolean;
begin
  //A run in which no test executed (none matched, or all were ignored) has not passed.
  result := FAllPassed and (FTotalCount - FIgnoredCount > 0);
end;

function TDUnitXRunResults.GetAllTestResults : IEnumerable<ITestResult>;
begin
  result := FAllTestResults;
end;

function TDUnitXRunResults.GetTestCount : Integer;
begin
  result := FTotalCount;
end;

function TDUnitXRunResults.GetErrorCount : Integer;
begin
  result := FErrorCount;
end;

function TDUnitXRunResults.GetFailureCount : Integer;
begin
  result := FFailureCount;
end;

function TDUnitXRunResults.GetFinishTime : TDateTime;
begin
  result := FFinishTime;
end;

function TDUnitXRunResults.GetFixtures : IEnumerable<ITestFixtureInfo>;
var
  fixtures : IList<ITestFixtureInfo>;
  fixtureResult : IFixtureResult;
begin
  //Built from the recorded fixture results; the field this returned was never assigned, so it was always nil.
  fixtures := TDUnitXList<ITestFixtureInfo>.Create;
  for fixtureResult in FFixtureResults do
    fixtures.Add(fixtureResult.Fixture);
  result := fixtures;
end;

function TDUnitXRunResults.GetIgnoredCount : Integer;
begin
  result := FIgnoredCount;
end;

function TDUnitXRunResults.GetMemoryLeakCount : Integer;
begin
  Result := FMemoryLeakCount;
end;

function TDUnitXRunResults.GetFixtureCount : Integer;
begin
  result := FFixtureResults.Count;
end;

function TDUnitXRunResults.GetFixtureResults : IEnumerable<IFixtureResult>;
begin
  result := FFixtureResults;
end;

function TDUnitXRunResults.GetDuration : TTimeSpan;
begin
  result := FDuration;
end;

function TDUnitXRunResults.GetStartTime : TDateTime;
begin
  result := FStartTime;
end;

function TDUnitXRunResults.GetPassCount : Integer;
begin
  result := FPassCount;
end;

function TDUnitXRunResults.GetSuccessRate : integer;
var
  successRate : integer;
begin
  if FTotalCount <> 0 then
    successRate := Trunc((FTotalCount - FFailureCount - FErrorCount) / FTotalCount * 100)
  else
    successRate := 100;

  Result := successRate;
end;

procedure TDUnitXRunResults.RecordFixture(const fixtureResult : IFixtureResult);
begin
  FFixtureResults.Add(fixtureResult);
end;

procedure TDUnitXRunResults.RecordResult(const fixtureResult : IFixtureResult; const testResult : ITestResult);
begin
  Inc(FTotalCount);
  case testResult.ResultType of
    TTestResultType.Pass : Inc(FPassCount);
    TTestResultType.Failure : Inc(FFailureCount);
    TTestResultType.Error : Inc(FErrorCount);
    TTestResultType.Ignored : Inc(FIgnoredCount);
    TTestResultType.MemoryLeak : Inc(FMemoryLeakCount);
  end;

  //Note, don't treat ignored as errors here!
  if testResult.ResultType not in [TTestResultType.Pass, TTestResultType.Ignored] then
    FAllPassed := False;

  (fixtureResult as IFixtureResultBuilder).AddTestResult(testResult);

  FAllTestResults.Add(testResult);
end;

procedure TDUnitXRunResults.RollupResults;
var
  fixtureResult : IFixtureResult;

begin
  FFinishTime := Now;
  FDuration := FStopWatch.Elapsed;
  for fixtureResult in FFixtureResults do
    (fixtureResult as IFixtureResultBuilder).RollUpResults;

  //TODO: Make sure the fixture results are unique.
end;

function TDUnitXRunResults.ToString : string;
begin
  result := Format(STestsPassed + #13#10, [FPassCount]);
end;

end.

