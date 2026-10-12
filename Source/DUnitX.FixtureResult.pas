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

unit DUnitX.FixtureResult;

interface

{$I DUnitX.inc}

uses
{$IFDEF USE_NS}
  System.Classes,
  System.TimeSpan,
  System.Diagnostics,
{$ELSE}
  Classes,
  TimeSpan,
  Diagnostics,
{$ENDIF}
  DUnitX.Generics,
  DUnitX.TestFramework,
  DUnitX.InternalInterfaces;

type
  /// <summary>
  ///   The result of one test fixture: its own test results, the results of nested fixtures, outcome counts and
  ///   timing. Fixture results form a tree that mirrors the namespace/fixture hierarchy.
  /// </summary>
  TDUnitXFixtureResult = class(TInterfacedObject, IFixtureResult, IFixtureResultBuilder)
  private
    /// <summary>Results of nested fixtures; created lazily, nil until the first child is added.</summary>
    FChildren : IList<IFixtureResult>;
    /// <summary>Results of this fixture's own tests; created lazily, nil until the first result is added.</summary>
    FTestResults : IList<ITestResult>;
    /// <summary>The fixture this result describes; replaced by the child's fixture when <c>Reduce</c> merges a child.</summary>
    FFixture : ITestFixtureInfo;

    /// <summary>Number of tests that ended in an error, including children once rolled up.</summary>
    FErrorCount : integer;
    /// <summary>Number of tests that failed an assertion, including children once rolled up.</summary>
    FFailureCount : integer;
    /// <summary>Number of tests that passed, including children once rolled up.</summary>
    FPassCount : integer;
    /// <summary>Number of tests that were ignored, including children once rolled up.</summary>
    FIgnoredCount : integer;
    /// <summary>Number of tests that leaked memory, including children once rolled up.</summary>
    FMemoryLeakCount : Integer;
    /// <summary>Number of this fixture's own test results recorded; children are not added to it.</summary>
    FTotalCount : integer;

    /// <summary>Times the fixture from construction to <c>RollUpResults</c>.</summary>
    FStopWatch : TStopwatch;
    /// <summary>Wall-clock time the result object was created.</summary>
    FStartTime : TDateTime;
    /// <summary>Wall-clock finish time; zero (undefined) until <c>RollUpResults</c> runs, which also guards re-entry.</summary>
    FFinishTime : TDateTime;
    /// <summary>Elapsed time from the stopwatch, which spans the fixture's own tests and its children's.</summary>
    FDuration : TTimeSpan;

    /// <summary>Fixture name; becomes the child's name when <c>Reduce</c> merges a single child.</summary>
    FName : string;
    /// <summary>Fixture namespace; extended with the old name when <c>Reduce</c> merges a single child.</summary>
    FNameSpace : string;
    /// <summary>True when the result has a parent, so a lone child may be merged into it; the root never reduces.</summary>
    FCanReduce : boolean;

  protected
    /// <summary>
    ///   Simplifies the result tree: reduces every child first, then, when this result has a parent, no test results
    ///   of its own and exactly one child, absorbs that child (name, fixture, tests and grandchildren) so namespace
    ///   levels with nothing in them do not appear as separate nodes.
    /// </summary>
    procedure Reduce;

    /// <summary>
    ///   Counts the nested fixture results.
    /// </summary>
    /// <returns>
    ///   The number of children, 0 when there are none.
    /// </returns>
    function GetChildCount : Integer;
    /// <summary>
    ///   Gives the nested fixture results, creating an empty list on first use so callers never receive nil.
    /// </summary>
    /// <returns>
    ///   The children list itself (not a copy).
    /// </returns>
    function GetChildren : IList<IFixtureResult>;
    /// <summary>
    ///   Counts tests that ended in an error.
    /// </summary>
    /// <returns>
    ///   The error count, including children once rolled up.
    /// </returns>
    function GetErrorCount : Integer;
    /// <summary>
    ///   Collects this fixture's own test results that carry error details.
    /// </summary>
    /// <returns>
    ///   A new list of the results supporting <c>ITestError</c>; children are not searched.
    /// </returns>
    function GetErrors : IList<ITestError>;
    /// <summary>
    ///   Counts tests that failed an assertion.
    /// </summary>
    /// <returns>
    ///   The failure count, including children once rolled up.
    /// </returns>
    function GetFailureCount : Integer;
    /// <summary>
    ///   Collects this fixture's own failed test results.
    /// </summary>
    /// <returns>
    ///   A new list of the results whose type is <c>Failure</c>; children are not searched.
    /// </returns>
    function GetFailures : IList<ITestResult>;
    /// <summary>
    ///   Gives the fixture this result describes.
    /// </summary>
    /// <returns>
    ///   The fixture information.
    /// </returns>
    function GetFixture : ITestFixtureInfo;
    /// <summary>
    ///   Reports whether the fixture did not succeed.
    /// </summary>
    /// <returns>
    ///   True when any test failed, errored or leaked memory; passes and ignores alone return False.
    /// </returns>
    function GetHasFailures : Boolean;
    /// <summary>
    ///   Counts tests that passed.
    /// </summary>
    /// <returns>
    ///   The pass count, including children once rolled up.
    /// </returns>
    function GetPassCount : Integer;
    /// <summary>
    ///   Collects this fixture's own passed test results.
    /// </summary>
    /// <returns>
    ///   A new list of the results whose type is <c>Pass</c>; children are not searched.
    /// </returns>
    function GetPasses : IList<ITestResult>;
    /// <summary>
    ///   Counts this fixture's own test results.
    /// </summary>
    /// <returns>
    ///   The number of results, 0 when there are none.
    /// </returns>
    function GetTestResultCount : Integer;
    /// <summary>
    ///   Gives this fixture's own test results, creating an empty list on first use so callers never receive nil.
    /// </summary>
    /// <returns>
    ///   The result list itself (not a copy).
    /// </returns>
    function GetTestResults : IList<ITestResult>;
    /// <summary>
    ///   Counts tests that were ignored.
    /// </summary>
    /// <returns>
    ///   The ignored count, including children once rolled up.
    /// </returns>
    function GetIgnoredCount : Integer;

    /// <summary>
    ///   Gives the time the fixture result was created.
    /// </summary>
    /// <returns>
    ///   The wall-clock start time.
    /// </returns>
    function GetStartTime : TDateTime;
    /// <summary>
    ///   Gives the time the fixture finished.
    /// </summary>
    /// <returns>
    ///   The finish time (the latest child finish time for a fixture with children); zero before rolling up.
    /// </returns>
    function GetFinishTime : TDateTime;
    /// <summary>
    ///   Gives the elapsed time of the fixture.
    /// </summary>
    /// <returns>
    ///   The duration set by <c>RollUpResults</c>.
    /// </returns>
    function GetDuration : TTimeSpan;
    /// <summary>
    ///   Gives the fixture's name.
    /// </summary>
    /// <returns>
    ///   The name, as changed by <c>Reduce</c> if a child was merged.
    /// </returns>
    function GetName : string;
    /// <summary>
    ///   Gives the fixture's namespace.
    /// </summary>
    /// <returns>
    ///   The namespace, as extended by <c>Reduce</c> if a child was merged.
    /// </returns>
    function GetNamespace : string;

    /// <summary>
    ///   Implements <c>IFixtureResultBuilder</c>: adds a nested fixture result, creating the children list on first
    ///   use.
    /// </summary>
    /// <param name="AFixtureResult">
    ///   The child fixture result.
    /// </param>
    procedure AddChild(const AFixtureResult : IFixtureResult);
    /// <summary>
    ///   Implements <c>IFixtureResultBuilder</c>: adds a test result to this fixture and counts it by outcome.
    /// </summary>
    /// <param name="AResult">
    ///   The test result to add.
    /// </param>
    procedure AddTestResult(const AResult : ITestResult);
    /// <summary>
    ///   Increments the total and the counter that matches the result's outcome.
    /// </summary>
    /// <param name="AResult">
    ///   The test result to count.
    /// </param>
    procedure RecordTestResult(const AResult : ITestResult);
    /// <summary>
    ///   Implements <c>IFixtureResultBuilder</c>: finishes the fixture. A fixture with children rolls each child up,
    ///   adds the children's counts to its own and takes the latest finish time. Every fixture stops its stopwatch,
    ///   which spans its own tests and its children's. Runs only once.
    /// </summary>
    procedure RollUpResults;
  public
    /// <summary>
    ///   Creates the result for a fixture, starts its timing and attaches it to its parent's result.
    /// </summary>
    /// <param name="AParentResult">
    ///   The parent fixture's result, which must support <c>IFixtureResultBuilder</c>; nil for the root, which is
    ///   then never reduced.
    /// </param>
    /// <param name="AFixture">
    ///   The fixture the result describes; its name and namespace are copied.
    /// </param>
    constructor Create(const AParentResult : IFixtureResult; const AFixture : ITestFixtureInfo);
  end;

implementation

uses
{$IFDEF USE_NS}
  System.DateUtils,
  System.SysUtils;
{$ELSE}
  DateUtils,
  SysUtils;
{$ENDIF}

const
  UNDEFINED_DATETIME = 0;

  { TDUnitXFixtureResult }

procedure TDUnitXFixtureResult.AddChild(const AFixtureResult : IFixtureResult);
begin
  if FChildren = nil then
    FChildren := TDUnitXList<IFixtureResult>.Create;
  FChildren.Add(AFixtureResult);
end;

procedure TDUnitXFixtureResult.AddTestResult(const AResult : ITestResult);
begin
  if FTestResults = nil then
    FTestResults := TDUnitXList<ITestResult>.Create;
  FTestResults.Add(AResult);
  RecordTestResult(AResult);
end;

constructor TDUnitXFixtureResult.Create(const AParentResult : IFixtureResult; const AFixture : ITestFixtureInfo);
begin
  FFixture := AFixture;
  FStartTime := Now;
  FFinishTime := UNDEFINED_DATETIME;
  FStopWatch := TStopwatch.StartNew;
  //Don't create collections here.. we'll lazy create;
  FChildren := nil;
  FTestResults := nil;

  FName := AFixture.Name;
  FNameSpace := AFixture.NameSpace;

  if AParentResult <> nil then
  begin
    (AParentResult as IFixtureResultBuilder).AddChild(Self);
    FCanReduce := True;
  end;

end;

function TDUnitXFixtureResult.GetChildCount : Integer;
begin
  if FChildren <> nil then
    result := FChildren.Count
  else
    result := 0;
end;

function TDUnitXFixtureResult.GetChildren : IList<IFixtureResult>;
begin
  //Don't pass nill back???
  if FChildren = nil then
    FChildren := TDUnitXList<IFixtureResult>.Create;
  result := FChildren;
end;

function TDUnitXFixtureResult.GetDuration : TTimeSpan;
begin
  result := FDuration;
end;

function TDUnitXFixtureResult.GetErrorCount : Integer;
begin
  result := FErrorCount;
end;

function TDUnitXFixtureResult.GetErrors : IList<ITestError>;
var
  test : ITestResult;
  error : ITestError;
begin
  result := TDUnitXList<ITestError>.Create;
  if FTestResults = nil then
    exit;

  for test in FTestResults do
  begin
    if Supports(test, ITestError, error) then
      result.Add(error);
  end;
end;

function TDUnitXFixtureResult.GetFailureCount : Integer;
begin
  result := FFailureCount;
end;

function TDUnitXFixtureResult.GetFailures : IList<ITestResult>;
var
  test : ITestResult;
begin
  result := TDUnitXList<ITestResult>.Create;
  if FTestResults = nil then
    exit;

  for test in FTestResults do
  begin
    if test.ResultType = TTestResultType.Failure then
      result.Add(test);
  end;
end;

function TDUnitXFixtureResult.GetFinishTime : TDateTime;
begin
  result := FFinishTime;
end;

function TDUnitXFixtureResult.GetFixture : ITestFixtureInfo;
begin
  result := FFixture;
end;

function TDUnitXFixtureResult.GetHasFailures : Boolean;
begin
  //Anything but a pass or an ignore: a fixture whose tests all errored or leaked has not succeeded.
  result := (FFailureCount > 0) or (FErrorCount > 0) or (FMemoryLeakCount > 0);
end;

function TDUnitXFixtureResult.GetIgnoredCount : Integer;
begin
  result := FIgnoredCount;
end;

function TDUnitXFixtureResult.GetName : string;
begin
  result := FName;
end;

function TDUnitXFixtureResult.GetNamespace : string;
begin
  result := FNameSpace;
end;

function TDUnitXFixtureResult.GetPassCount : Integer;
begin
  result := FPassCount;
end;

function TDUnitXFixtureResult.GetPasses : IList<ITestResult>;
var
  test : ITestResult;
begin
  result := TDUnitXList<ITestResult>.Create;
  if FTestResults = nil then
    exit;

  for test in FTestResults do
  begin
    if test.ResultType = TTestResultType.Pass then
      result.Add(test);
  end;
end;

function TDUnitXFixtureResult.GetStartTime : TDateTime;
begin
  Result := FStartTime;
end;

function TDUnitXFixtureResult.GetTestResultCount : Integer;
begin
  if FTestResults = nil then
    Exit(0);
  result := FTestResults.Count;
end;

function TDUnitXFixtureResult.GetTestResults : IList<DUnitX.TestFramework.ITestResult>;
begin
  if FTestResults = nil then
    FTestResults := TDUnitXList<ITestResult>.Create;
  result := FTestResults;
end;

function Max(const a, b : TDateTime) : TDateTime;
begin
  if a > b then
    result := a
  else
    result := b;
end;

procedure TDUnitXFixtureResult.RecordTestResult(const AResult : ITestResult);
begin
  Inc(FTotalCount);
  case AResult.ResultType of
    TTestResultType.Pass : Inc(FPassCount);
    TTestResultType.Failure : Inc(FFailureCount);
    TTestResultType.Error : Inc(FErrorCount);
    TTestResultType.Ignored : Inc(FIgnoredCount);
    TTestResultType.MemoryLeak : Inc(FMemoryLeakCount);
  end;
end;

procedure TDUnitXFixtureResult.Reduce;
var
  fixtureRes : IFixtureResult;
begin
  if (FChildren <> nil) and (FChildren.Count > 0) then
  begin
    //Reduce the children first.
    for fixtureRes in FChildren do
      fixtureRes.Reduce;

    //if we have no tests and only one child, then we reduce to that child.
    if FCanReduce and (FChildren.Count = 1) and ((FTestResults = nil) or (FTestResults.Count = 0)) then
    begin
      fixtureRes := FChildren[0];

      FNameSpace := FNameSpace + '.' + FName;
      FName := fixtureRes.Name;

      FFixture := fixtureRes.Fixture;
      if FTestResults = nil then
        FTestResults := TDUnitXList<ITestResult>.Create;
      FTestResults.AddRange(fixtureRes.TestResults);
      FChildren.Clear;
      if fixtureRes.ChildCount > 0 then
        FChildren.AddRange(fixtureRes.Children)
      else
        FChildren.Clear;
    end;
  end;
end;

procedure TDUnitXFixtureResult.RollUpResults;
var
  fixture : IFixtureResult;
begin
  //guard against rolling up multiple times.
  if FFinishTime <> UNDEFINED_DATETIME then
    exit;

  if FChildren <> nil then
  begin
    //The stopwatch spans this fixture's own tests and its children's, which run inside it; the sum of the children's
    //durations, used before, left out the fixture's own tests.
    FStopWatch.Stop;
    FDuration := FStopWatch.Elapsed;
    FFinishTime := Now;
    for fixture in FChildren do
    begin
      (fixture as IFixtureResultBuilder).RollUpResults;
      Inc(FErrorCount, fixture.ErrorCount);
      Inc(FFailureCount, fixture.FailureCount);
      Inc(FIgnoredCount, fixture.IgnoredCount);
      Inc(FPassCount, fixture.PassCount);
      //IFixtureResult has no leak count; every fixture result is one of ours.
      if fixture is TDUnitXFixtureResult then
        Inc(FMemoryLeakCount, TDUnitXFixtureResult(fixture).FMemoryLeakCount);
      FFinishTime := Max(FFinishTime, fixture.FinishTime);
    end;
  end
  else if (FFinishTime = UNDEFINED_DATETIME) then
  begin
    FFinishTime := Now;
    FStopWatch.Stop;
    FDuration := FStopWatch.Elapsed;
  end;
end;

end.

