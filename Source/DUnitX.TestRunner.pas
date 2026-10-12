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

unit DUnitX.TestRunner;

interface

{$I DUnitX.inc}

uses
{$IFDEF USE_NS}
  System.Classes,
  System.SysUtils,
  System.Rtti,
  System.Generics.Collections,
{$ELSE}
  Classes,
  SysUtils,
  Rtti,
  Generics.Collections,
{$ENDIF}
  DUnitX.TestFramework,
  DUnitX.Extensibility,
  DUnitX.InternalInterfaces,
  DUnitX.Generics,
  DUnitX.WeakReference,
  DUnitX.Filters,
  DUnitX.Exceptions;

type
  ///  Note - we rely on the fact that there will only ever be 1 testrunner
  ///  per thread, if this changes then handling of WriteLn will need to change
  TDUnitXTestRunner = class(TWeakReferencedObject, ITestRunner)
  private
    class var
      FRttiContext : TRttiContext;
  public
    class var
      FActiveRunners : TDictionary<TThreadID, IWeakReference<ITestRunner>>;
  private
    FLoggers : TList<ITestLogger>;
    FUseRTTI : boolean;
    FFixtureClasses : TDictionary<TClass, string>;

    FFixtureList : ITestFixtureList;
    FLogMessages : TStringList;
    FLogMessagesEx : TLogMessageArray;

    FFailsOnNoAsserts : boolean;
    FCurrentTestName : string;

    //The active-runner entry this runner registered, and the one it stood in for.
    FThreadId : TThreadID;
    FOwnRunnerRef : IWeakReference<ITestRunner>;
    FPreviousRunnerRef : IWeakReference<ITestRunner>;

    //While a test runs, measures memory the runner itself keeps (log messages, a pass message), which
    //the leak check then discounts. nil when not measuring.
    FRunnerAllocationMonitor : IMemoryLeakMonitor;
    FRunnerAllocated : Int64;
    //Measures the whole span from the start of setup (or the test) to the end of teardown (or the test),
    //so memory freed between the phases is not a leak. nil when the monitor is a singleton; the leak check
    //then sums the phases.
    FLeakSpanMonitor : IMemoryLeakMonitor;
    FLeakSpanStarted : boolean;
    procedure BeginRunnerAllocation;
    procedure EndRunnerAllocation;
    procedure BeginLeakSpan;
    procedure ExtendLeakSpan;
  protected
    procedure CountAndFilterTests(const fixtureList : ITestFixtureList; var count, active : Cardinal);
    //Logger calls - sequence ordered
    procedure Loggers_TestingStarts(const threadId : TThreadID; testCount, testActiveCount : Cardinal);

    procedure Loggers_StartTestFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);

    procedure Loggers_SetupFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
    procedure Loggers_EndSetupFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);

    procedure Loggers_BeginTest(const threadId : TThreadID; const Test : ITestInfo);

    procedure Loggers_SetupTest(const threadId : TThreadID; const Test : ITestInfo);
    procedure Loggers_EndSetupTest(const threadId : TThreadID; const Test : ITestInfo);

    procedure Loggers_ExecuteTest(const threadId : TThreadID; const Test : ITestInfo);

    procedure Loggers_AddSuccess(const threadId : TThreadID; const Test : ITestResult);
    procedure Loggers_AddError(const threadId : TThreadID; const Error : ITestError);
    procedure Loggers_AddFailure(const threadId : TThreadID; const Failure : ITestError);
    procedure Loggers_AddIgnored(const threadId : TThreadID; const AIgnored : ITestResult);
    procedure Loggers_AddMemoryLeak(const threadId : TThreadID; const Test : ITestResult);

    procedure Loggers_EndTest(const threadId : TThreadID; const Test : ITestResult);
    procedure Loggers_TeardownTest(const threadId : TThreadID; const Test : ITestInfo);
    procedure Loggers_EndTeardownTest(const aThreadId : TThreadID; const aTest : ITestInfo);

    procedure Loggers_TeardownFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
    procedure Loggers_EndTearDownFixture(const aThreadId : TThreadID; const aFixture : ITestFixtureInfo);

    procedure Loggers_EndTestFixture(const threadId : TThreadID; const results : IFixtureResult);

    procedure Loggers_TestingEnds(const RunResults : IRunResults);

    //ITestRunner
    procedure AddLogger(const value : ITestLogger);
    function Execute : IRunResults;

    procedure ExecuteFixtures(const parentFixtureResult : IFixtureResult; const context : ITestExecuteContext; const threadId : TThreadID; const fixtures :
      ITestFixtureList);
    function ExecuteSetupFixtureMethod(const context : ITestExecuteContext; const threadId : TThreadID; const fixture : ITestFixture; const fixtureResult :
      IFixtureResult) : boolean;
    function ExecuteTestSetupMethod(const context : ITestExecuteContext; const threadId : TThreadID; const fixture : ITestFixture; const test : ITest; out
      errorResult : ITestResult; const memoryAllocationProvider : IMemoryLeakMonitor) : boolean;

    procedure ExecuteTests(const context : ITestExecuteContext; const threadId : TThreadID; const fixture : ITestFixture; const fixtureResult :
      IFixtureResult);

    function ExecuteTest(const context : ITestExecuteContext; const threadId : TThreadID; const test : ITest; const memoryAllocationProvider :
      IMemoryLeakMonitor) : ITestResult;
    function ExecuteSuccessfulResult(const context : ITestExecuteContext; const threadId : TThreadID; const test : ITest; const aMessage : string; const
      aLogMessages : TLogMessageArray) : ITestResult;
    function ExecuteFailureResult(const context : ITestExecuteContext; const threadId : TThreadID; const test : ITest; const exception : Exception; const
      aLogMessages : TLogMessageArray) : ITestError;
    function ExecuteTimedOutResult(const context : ITestExecuteContext; const threadId : TThreadID; const test : ITest; const exception : Exception; const
      aLogMessages : TLogMessageArray) : ITestError;
    function ExecuteErrorResult(const context : ITestExecuteContext; const threadId : TThreadID; const test : ITest; const exception : Exception; const
      aLogMessages : TLogMessageArray) : ITestError;
    function ExecuteIgnoredResult(const context : ITestExecuteContext; const threadId : TThreadID; const test : ITest; const ignoreReason : string) :
      ITestResult;
    procedure InvalidateTestsInFixture(const aFixture : ITestFixture; const aContext : ITestExecuteContext; const aThreadId : TThreadID; const aException :
      Exception; const aFixtureResult : IFixtureResult);

    function CheckMemoryAllocations(const test : ITest; out errorResult : ITestResult; const memoryAllocationProvider : IMemoryLeakMonitor) : boolean;

    function ExecuteTestTearDown(const context : ITestExecuteContext; const threadId : TThreadID; const fixture : ITestFixture; const test : ITest; out
      errorResult : ITestResult; const memoryAllocationProvider : IMemoryLeakMonitor) : boolean;
    procedure ExecuteTearDownFixtureMethod(const context : ITestExecuteContext; const threadId : TThreadID; const fixture : ITestFixture; const fixtureResult :
      IFixtureResult);

    procedure RecordResult(const context : ITestExecuteContext; const threadId : TThreadID; const fixtureResult : IFixtureResult; const testResult :
      ITestResult);

    function GetUseRTTI : Boolean;
    procedure SetUseRTTI(const value : Boolean);
    function GetFailsOnNoAsserts : boolean;
    procedure SetFailsOnNoAsserts(const value : boolean);

    procedure Log(const logType : TLogLevel; const msg : string); overload;
    procedure Log(const msg : string); overload;

    //for backwards compatibility with DUnit tests.
    procedure Status(const msg : string); overload;

    //redirects WriteLn to our loggers.
    procedure WriteLn(const msg : string); overload;
    procedure WriteLn; overload;
    function CurrentTestName : string;

    //internals
    procedure RTTIDiscoverFixtureClasses;
    function BuildFixtures : IInterface;

    procedure AddStatus(const threadId; const msg : string);

    function ShouldRunThisTest(const test : ITest) : boolean;

    class constructor Create;
    class destructor Destroy;
  public
    constructor Create; overload;
    constructor Create(const AListener : ITestLogger); overload;
    constructor Create(const AListeners : array of ITestLogger); overload;
    destructor Destroy; override;
    class function GetActiveRunner : ITestRunner;
    class function GetCurrentTestName : string;
  end;

implementation

uses
{$IFDEF USE_NS}
  System.TypInfo,
  System.StrUtils,
  System.Types,
{$ELSE}
  TypInfo,
  StrUtils,
  Types,
{$ENDIF}
  DUnitX.Attributes,
  DUnitX.CommandLine.Options,
  DUnitX.TestFixture,
  DUnitX.RunResults,
  DUnitX.TestResult,
  DUnitX.FixtureResult,
  DUnitX.Utils,
  DUnitX.ServiceLocator,
  DUnitX.ResStrs,
  DUnitX.FixtureBuilder,
{$IFDEF USE_NS}
  System.TimeSpan,
{$ELSE}
  TimeSpan,
{$ENDIF}
  DUnitX.ComparableFormat,
  DUnitX.Test;

type
  //A test error with text appended to its message (a TearDown that also failed) and, optionally, a
  //strong reference to its test, for a test that no fixture list holds (results hold tests weakly).
  TDUnitXAmendedTestError = class(TInterfacedObject, IResult, ITestResult, ITestError)
  private
    FInner : ITestError;
    FSuffix : string;
    FTest : ITestInfo;
  protected
    //IResult
    function GetStartTime : TDateTime;
    function GetFinishTime : TDateTime;
    function GetDuration : TTimeSpan;
    //ITestResult
    function GetTest : ITestInfo;
    function GetResult : boolean;
    function GetResultType : TTestResultType;
    function GetMessage : string;
    function GetLogMessages : TLogMessageArray;
    function GetStackTrace : string;
    //ITestError
    function GetExceptionClass : ExceptClass;
    function GetExceptionMessage : string;
    function GetExceptionLocationInfo : string;
    function GetExceptionAddressInfo : string;
    function GetExceptionAddress : Pointer;
    function GetIsComparable : boolean;
    function GetExpected : string;
    function GetActual : string;
    function GetFormat : TDUnitXComparableFormatClass;
  public
    constructor Create(const AInner : ITestError; const ASuffix : string; const ATest : ITestInfo = nil);
  end;

{ TDUnitXAmendedTestError }

constructor TDUnitXAmendedTestError.Create(const AInner : ITestError; const ASuffix : string; const ATest : ITestInfo);
begin
  inherited Create;
  FInner := AInner;
  FSuffix := ASuffix;
  FTest := ATest;
end;

function TDUnitXAmendedTestError.GetStartTime : TDateTime;
begin
  result := FInner.StartTime;
end;

function TDUnitXAmendedTestError.GetFinishTime : TDateTime;
begin
  result := FInner.FinishTime;
end;

function TDUnitXAmendedTestError.GetDuration : TTimeSpan;
begin
  result := FInner.Duration;
end;

function TDUnitXAmendedTestError.GetTest : ITestInfo;
begin
  if FTest <> nil then
    result := FTest
  else
    result := FInner.Test;
end;

function TDUnitXAmendedTestError.GetResult : boolean;
begin
  result := FInner.Result;
end;

function TDUnitXAmendedTestError.GetResultType : TTestResultType;
begin
  result := FInner.ResultType;
end;

function TDUnitXAmendedTestError.GetMessage : string;
begin
  result := FInner.Message + FSuffix;
end;

function TDUnitXAmendedTestError.GetLogMessages : TLogMessageArray;
begin
  result := FInner.LogMessages;
end;

function TDUnitXAmendedTestError.GetStackTrace : string;
begin
  result := FInner.StackTrace;
end;

function TDUnitXAmendedTestError.GetExceptionClass : ExceptClass;
begin
  result := FInner.ExceptionClass;
end;

function TDUnitXAmendedTestError.GetExceptionMessage : string;
begin
  result := FInner.ExceptionMessage + FSuffix;
end;

function TDUnitXAmendedTestError.GetExceptionLocationInfo : string;
begin
  result := FInner.ExceptionLocationInfo;
end;

function TDUnitXAmendedTestError.GetExceptionAddressInfo : string;
begin
  result := FInner.ExceptionAddressInfo;
end;

function TDUnitXAmendedTestError.GetExceptionAddress : Pointer;
begin
  result := FInner.ExceptionAddress;
end;

function TDUnitXAmendedTestError.GetIsComparable : boolean;
begin
  result := FInner.IsComparable;
end;

function TDUnitXAmendedTestError.GetExpected : string;
begin
  result := FInner.Expected;
end;

function TDUnitXAmendedTestError.GetActual : string;
begin
  result := FInner.Actual;
end;

function TDUnitXAmendedTestError.GetFormat : TDUnitXComparableFormatClass;
begin
  result := FInner.Format;
end;

{ TDUnitXTestRunner }

procedure TDUnitXTestRunner.Log(const msg : string);
begin
  Self.Log(TLogLevel.Information, msg);
end;

procedure TDUnitXTestRunner.Loggers_AddError(const threadId : TThreadID; const Error : ITestError);
var
  logger : ITestLogger;
begin
  for logger in FLoggers do
  begin
    logger.OnTestError(threadId, Error);
  end;
end;

procedure TDUnitXTestRunner.Loggers_AddFailure(const threadId : TThreadID; const Failure : ITestError);
var
  logger : ITestLogger;
begin
  for logger in FLoggers do
  begin
    logger.OnTestFailure(threadId, Failure);
  end;
end;

procedure TDUnitXTestRunner.Loggers_AddIgnored(const threadId : TThreadID; const AIgnored : ITestResult);
var
  logger : ITestLogger;
begin
  for logger in FLoggers do
  begin
    logger.OnTestIgnored(threadId, AIgnored);
  end;
end;

procedure TDUnitXTestRunner.Loggers_AddMemoryLeak(const threadId : TThreadID; const Test : ITestResult);
var
  logger : ITestLogger;
begin
  for logger in FLoggers do
  begin
    logger.OnTestMemoryLeak(threadId, Test);
  end;
end;

procedure TDUnitXTestRunner.AddLogger(const value : ITestLogger);
begin
  if not FLoggers.Contains(value) then
    FLoggers.Add(value);
end;

procedure TDUnitXTestRunner.Loggers_AddSuccess(const threadId : TThreadID; const Test : ITestResult);
var
  logger : ITestLogger;
begin
  for logger in FLoggers do
  begin
    logger.OnTestSuccess(threadId, Test);
  end;
end;

procedure TDUnitXTestRunner.AddStatus(const threadId; const msg : string);
begin
  //TODO : What should be here???
end;

function TDUnitXTestRunner.BuildFixtures : IInterface;
var
  fixtureBuilder : IFixtureBuilder;
begin
  fixtureBuilder := TDUnitXFixtureBuilder.Create(FUseRTTI);

  FFixtureList := fixtureBuilder.BuildFixtureList;
  FFixtureList.Sort;

  result := FFixtureList;
end;

class constructor TDUnitXTestRunner.Create;
begin
  FRttiContext := TRttiContext.Create;
  FActiveRunners := TDictionary < TThreadID, IWeakReference<ITestRunner> > .Create;
end;

function TDUnitXTestRunner.CheckMemoryAllocations(const test : ITest; out errorResult : ITestResult; const memoryAllocationProvider : IMemoryLeakMonitor) :
  boolean;
var
  LSetUpMemoryAllocated : Int64;
  LTearDownMemoryAllocated : Int64;
  LTestMemoryAllocated : Int64;
  LLeaked : Int64;
  LMsg : string;
  LMemoryAllocationProvider2 : IMemoryLeakMonitor2;
  testInfo : ITestInfo;
begin
  Result := True;
  errorResult := nil;

  if (test.IgnoreMemoryLeaks) then
    Exit;

  LSetUpMemoryAllocated := memoryAllocationProvider.SetUpMemoryAllocated;
  LTestMemoryAllocated := memoryAllocationProvider.TestMemoryAllocated;
  LTearDownMemoryAllocated := memoryAllocationProvider.TearDownMemoryAllocated;

  //Net growth, less what the runner itself kept meanwhile. Only growth is a leak: a test that frees
  //memory allocated before it started has a negative delta. The whole span is measured where it can be,
  //because memory can be freed between the phases (the runner releasing references, another thread
  //finishing), which the sum of the phases would count as leaked.
  if FLeakSpanStarted then
    LLeaked := FLeakSpanMonitor.TestMemoryAllocated - FRunnerAllocated
  else
    LLeaked := LSetUpMemoryAllocated + LTestMemoryAllocated + LTearDownMemoryAllocated - FRunnerAllocated;
  if (LLeaked <= 0) then
    Exit(True);

  if memoryAllocationProvider.QueryInterface(IMemoryLeakMonitor2, LMemoryAllocationProvider2) = 0 then
    LMsg := LMemoryAllocationProvider2.GetReport;

  testInfo := test as ITestInfo;
  if (LTestMemoryAllocated = 0) then
  begin
    // The leak occurred in the setup/teardown
    Result := False;
    LMsg := Format(SSetupTeardownBytesLeaked, [LLeaked]) + LMsg;

    errorResult := TDUnitXTestResult.Create(testInfo, TTestResultType.MemoryLeak, LMsg);
  end
  else if (LSetUpMemoryAllocated + LTearDownMemoryAllocated = 0) then
  begin
    // The leak occurred in the test only
    Result := False;
    LMsg := Format(STestBytesLeaked, [LLeaked]) + LMsg;
    errorResult := TDUnitXTestResult.Create(testInfo, TTestResultType.MemoryLeak, LMsg);
  end
  else
  begin
    // The leak occurred in the setup/teardown/test
    Result := False;
    LMsg := Format(SSetupTestTeardownBytesLeaked, [LLeaked]) + LMsg;
    errorResult := TDUnitXTestResult.Create(testInfo, TTestResultType.MemoryLeak, LMsg);
  end;
end;

constructor TDUnitXTestRunner.Create;
begin
  inherited;
  FLoggers := TList<ITestLogger>.Create;
  FFixtureClasses := TDictionary<TClass, string>.Create;
  FUseRTTI := False;
  FLogMessages := TStringList.Create;
  FThreadId := TThread.CurrentThread.ThreadID;
  FOwnRunnerRef := TWeakReference<ITestRunner>.Create(Self);
  MonitorEnter(TDUnitXTestRunner.FActiveRunners);
  try
    //A runner created while another is active on this thread (one driven from inside a test) stands in for it
    //until it is destroyed, rather than failing with a duplicate key.
    TDUnitXTestRunner.FActiveRunners.TryGetValue(FThreadId, FPreviousRunnerRef);
    TDUnitXTestRunner.FActiveRunners.AddOrSetValue(FThreadId, FOwnRunnerRef);
  finally
    MonitorExit(TDUnitXTestRunner.FActiveRunners);
  end;
end;

constructor TDUnitXTestRunner.Create(const AListener : ITestLogger);
begin
  Create;

  if AListener <> nil then
    FLoggers.Add(AListener);
end;

constructor TDUnitXTestRunner.Create(const AListeners : array of ITestLogger);
begin
  Create;

  FLoggers.AddRange(AListeners);
end;

function TDUnitXTestRunner.CurrentTestName : string;
begin
  result := FCurrentTestName;
end;

destructor TDUnitXTestRunner.Destroy;
var
  ref : IWeakReference<ITestRunner>;
begin
  MonitorEnter(TDUnitXTestRunner.FActiveRunners);
  try
    //Only this runner's own entry is removed, and the runner it stood in for is restored.
    if (FOwnRunnerRef <> nil) and TDUnitXTestRunner.FActiveRunners.TryGetValue(FThreadId, ref) and (ref = FOwnRunnerRef) then
    begin
      if (FPreviousRunnerRef <> nil) and FPreviousRunnerRef.IsAlive then
        TDUnitXTestRunner.FActiveRunners.AddOrSetValue(FThreadId, FPreviousRunnerRef)
      else
        TDUnitXTestRunner.FActiveRunners.Remove(FThreadId);
    end;
  finally
    MonitorExit(TDUnitXTestRunner.FActiveRunners);
  end;
  FPreviousRunnerRef := nil;
  FOwnRunnerRef := nil;

  FLogMessages.Free;
  FLoggers.Free;
  FFixtureClasses.Free;
  inherited;
end;

class destructor TDUnitXTestRunner.Destroy;
begin
  FActiveRunners.Free;
  FRttiContext.Free;
end;

procedure TDUnitXTestRunner.RecordResult(const context : ITestExecuteContext; const threadId : TThreadID; const fixtureResult : IFixtureResult; const testResult
  : ITestResult);
begin
  case testResult.ResultType of
    TTestResultType.Pass :
      begin
        context.RecordResult(fixtureResult, testResult);
        Self.Loggers_AddSuccess(threadId, testResult);
      end;
    TTestResultType.Failure :
      begin
        Log(TLogLevel.Error, STestFailed + testResult.Test.Name + ' : ' + testResult.Message);
        context.RecordResult(fixtureResult, testResult);
        Self.Loggers_AddFailure(threadId, ITestError(testResult));
      end;
    TTestResultType.Error :
      begin
        Log(TLogLevel.Error, STestError + testResult.Test.Name + ' : ' + testResult.Message);
        context.RecordResult(fixtureResult, testResult);
        Self.Loggers_AddError(threadId, ITestError(testResult));
      end;
    TTestResultType.Ignored :
      begin
        Log(TLogLevel.Information, STestIgnored + testResult.Test.Name + ' : ' + testResult.Message);
        context.RecordResult(fixtureResult, testResult);
        Self.Loggers_AddIgnored(threadId, testResult);
      end;
    TTestResultType.MemoryLeak :
      begin
        Log(TLogLevel.Error, STestLeaked + testResult.Test.Name + ' : ' + testResult.Message);
        context.RecordResult(fixtureResult, testResult);
        Self.Loggers_AddMemoryLeak(threadId, testResult);
      end;

  end;
end;

procedure TDUnitXTestRunner.RTTIDiscoverFixtureClasses;
var
  types : TArray<TRttiType>;
  rType : TRttiType;
  attributes : TArray<TCustomAttribute>;
  attribute : TCustomAttribute;
  sName : string;
begin
  types := FRttiContext.GetTypes;
  for rType in types do
  begin
    //try and keep the iteration down as much as possible
    if (rType.TypeKind = TTypeKind.tkClass) and (not rType.InheritsFrom(TPersistent)) then
    begin
      attributes := rType.GetAttributes;
      if Length(attributes) > 0 then
        for attribute in attributes do
        begin
          if attribute.ClassType = TestFixtureAttribute then
          begin
            sName := TestFixtureAttribute(attribute).Name;
            if sName = '' then
              sName := TRttiInstanceType(rType).MetaclassType.ClassName;
            if not FFixtureClasses.ContainsKey(TRttiInstanceType(rType).MetaclassType) then
              FFixtureClasses.Add(TRttiInstanceType(rType).MetaclassType, sName);
          end;
        end;
    end;
  end;
end;

procedure TDUnitXTestRunner.Loggers_EndSetupFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
var
  logger : ITestLogger;
begin
  for logger in FLoggers do
    logger.OnEndSetupFixture(threadId, fixture);
end;

procedure TDUnitXTestRunner.Loggers_EndSetupTest(const threadId : TThreadID; const Test : ITestInfo);
var
  logger : ITestLogger;
begin
  for logger in FLoggers do
  begin
    try
      logger.OnEndSetupTest(threadid, Test);
    except
      //Hmmmm what to do with errors here. This kinda smells.
      on e : Exception do
      begin
        try
          logger.OnLog(TLogLevel.Error, SOnEndSetupEventError + e.Message);
        except
          on e : Exception do
            System.Write(SOnEndSetupTestLogError + e.Message);
        end;
      end;
    end;
  end;

end;

procedure TDUnitXTestRunner.Loggers_EndTearDownFixture(const aThreadId : TThreadID; const aFixture : ITestFixtureInfo);
var
  lLogger : ITestLogger;
begin
  for lLogger in FLoggers do
    lLogger.OnEndTearDownFixture(aThreadId, aFixture);
end;

procedure TDUnitXTestRunner.Loggers_EndTeardownTest(const aThreadId : TThreadID; const aTest : ITestInfo);
var
  lLogger : ITestLogger;
begin
  for lLogger in FLoggers do
    lLogger.OnEndTeardownTest(aThreadId, aTest);
end;

procedure TDUnitXTestRunner.Loggers_EndTest(const threadId : TThreadID; const Test : ITestResult);
var
  logger : ITestLogger;
begin
  for logger in FLoggers do
    logger.OnEndTest(threadId, Test);

end;

procedure TDUnitXTestRunner.Loggers_EndTestFixture(const threadId : TThreadID; const results : IFixtureResult);
var
  logger : ITestLogger;
begin
  for logger in FLoggers do
  begin
    logger.OnEndTestFixture(threadId, results);
  end;
end;

procedure TDUnitXTestRunner.Loggers_ExecuteTest(const threadId : TThreadID; const Test : ITestInfo);
var
  logger : ITestLogger;
begin
  for logger in FLoggers do
    logger.OnExecuteTest(threadId, Test);
end;

procedure TDUnitXTestRunner.CountAndFilterTests(const fixtureList : ITestFixtureList; var count : Cardinal; var active : Cardinal);
var
  fixture : ITestFixture;
  test : ITest;
begin
  for fixture in fixtureList do
  begin
    for test in fixture.Tests do
    begin
      if TDUnitX.Filter <> nil then
        test.Enabled := TDUnitX.Filter.Match(test);

      if test.Enabled then
      begin
        Inc(count);
        if not test.Ignored then
          Inc(active);
      end;
    end;
    if fixture.HasChildFixtures then
      CountAndFilterTests(fixture.children, count, active);

    //    if not (fixture.HasTests or fixture.HasChildTests) then
    //      fixture.Enabled := false;
  end;
end;

//TODO - this needs to be thread aware so we can run tests in threads.
function TDUnitXTestRunner.Execute : IRunResults;
var
  fixtureList : ITestFixtureList;
  context : ITestExecuteContext;
  threadId : TThreadID;
  testCount : Cardinal;
  testActiveCount : Cardinal;
  fixtures : IInterface;
begin
  result := nil;

  if FFixtureList = nil then
  begin
    fixtures := BuildFixtures;
    fixtureList := fixtures as ITestFixtureList;
  end
  else
    fixtureList := FFixtureList;
  if fixtureList.Count = 0 then
    raise ENoTestsRegistered.Create(SNoFixturesFound);

  testCount := 0;
  //TODO: Count the active tests that we have.
  testActiveCount := 0;

  //TODO : Filter tests here?

  CountAndFilterTests(fixtureList, testCount, testActiveCount);

  //TODO: Move to the fixtures class
  result := TDUnitXRunResults.Create;
  context := result as ITestExecuteContext;

  //TODO: Record Test metrics.. runtime etc.
  threadId := TThread.CurrentThread.ThreadID;
  Self.Loggers_TestingStarts(threadId, testCount, testActiveCount);
  try
    ExecuteFixtures(nil, context, threadId, fixtureList);
    context.RollupResults;              //still need this for overall time.
    //AllPassed is False for such a run; say why.
    if result.TestCount - result.IgnoredCount = 0 then
      Log(TLogLevel.Warning, SNoTestsExecuted);
  finally
    Self.Loggers_TestingEnds(result);
  end;
end;

function TDUnitXTestRunner.ExecuteErrorResult(const context : ITestExecuteContext; const threadId : TThreadID; const test : ITest; const exception : Exception;
  const aLogMessages : TLogMessageArray) : ITestError;
var
  testInfo : ITestInfo;
begin
  testInfo := test as ITestInfo;
  Result := TDUnitXTestError.Create(testInfo, TTestResultType.Error, exception, ExceptAddr, exception.Message, aLogMessages);
end;

class function TDUnitXTestRunner.GetActiveRunner : ITestRunner;
var
  ref : IWeakReference<ITestRunner>;
begin
  result := nil;
  MonitorEnter(FActiveRunners);
  try
    if FActiveRunners.TryGetValue(TThread.CurrentThread.ThreadId, ref) then
      result := ref.Data;
  finally
    MonitorExit(FActiveRunners);
  end;
end;

class function TDUnitXTestRunner.GetCurrentTestName : string;
var
  runner : ITestRunner;
begin
  runner := GetActiveRunner;
  if runner <> nil then
    result := runner.CurrentTestName;
end;

function TDUnitXTestRunner.GetFailsOnNoAsserts : boolean;
begin
  Result := FFailsOnNoAsserts;
end;

function TDUnitXTestRunner.ExecuteFailureResult(const context : ITestExecuteContext; const threadId : TThreadID; const test : ITest; const exception :
  Exception; const aLogMessages : TLogMessageArray) : ITestError;
var
  testInfo : ITestInfo;
begin
  testInfo := test as ITestInfo;
  //TODO: Does test failure require its own results interface and class?
  Result := TDUnitXTestError.Create(testInfo, TTestResultType.Failure, exception, ExceptAddr, exception.Message, aLogMessages);
end;

procedure TDUnitXTestRunner.ExecuteFixtures(const parentFixtureResult : IFixtureResult; const context : ITestExecuteContext; const threadId : TThreadID; const
  fixtures : ITestFixtureList);
var
  fixture : ITestFixture;
  fixtureResult : IFixtureResult;
  setupOk : boolean;
begin
  for fixture in fixtures do
  begin
    if not fixture.Enabled then
      System.continue;

    if (not fixture.HasTests) and (not fixture.HasChildTests) then
      System.Continue;

    setupOk := True;
    fixtureResult := TDUnitXFixtureResult.Create(parentFixtureResult, fixture as ITestFixtureInfo);
    if parentFixtureResult = nil then
      context.RecordFixture(fixtureResult);

    Self.Loggers_StartTestFixture(threadId, fixture as ITestFixtureInfo);
    try
      //Initialize the fixture as it may have been destroyed in a previous run (when using gui runner).
      //A constructor that raises fails this fixture's tests, not the whole run.
      if fixture.HasTests then
      try
        fixture.InitFixtureInstance;
      except
        on e : Exception do
        begin
          setupOk := false;
          InvalidateTestsInFixture(fixture, context, threadId, e, fixtureResult);
          Log(TLogLevel.Error, Format(SFixtureCreateError, [fixture.Name, e.Message]));
          Log(TLogLevel.Error, SSkippingFixture);
        end;
      end;
      //A parameterless constructor takes the place of a [SetupFixture] method; say so rather than drop it silently.
      if fixture.HasActiveTests and (fixture.SetupFixtureMethodName <> '') and (not Assigned(fixture.SetupFixtureMethod)) then
        Log(TLogLevel.Warning, Format(SSetupFixtureNotRun, [fixture.SetupFixtureMethodName, fixture.Name]));
      //only run the setup method if there are actually tests
      if setupOk and fixture.HasActiveTests and Assigned(fixture.SetupFixtureMethod) then
        //returns false if an exception happens in the setup.
        setupOk := ExecuteSetupFixtureMethod(context, threadId, fixture, fixtureResult);

      if setupOk and fixture.HasTests then
        ExecuteTests(context, threadId, fixture, fixtureResult);

      if fixture.HasChildFixtures then
        ExecuteFixtures(fixtureResult, context, threadId, fixture.Children);

      // teardown will not run if the fixture setup errored.
      if setupOk and fixture.HasActiveTests and Assigned(fixture.TearDownFixtureMethod) then
        //TODO: Tricker yet each test above us requires errors that occur here
        ExecuteTearDownFixtureMethod(context, threadId, fixture, fixtureResult);

      //rollup durations - needs to be done here to ensure correct timing.
      (fixtureResult as IFixtureResultBuilder).RollUpResults;
    finally
      Self.Loggers_EndTestFixture(threadId, fixtureResult);
    end;
  end;
end;

function TDUnitXTestRunner.ExecuteIgnoredResult(const context : ITestExecuteContext; const threadId : TThreadID; const test : ITest; const ignoreReason :
  string) : ITestResult;
begin
  result := TDUnitXTestResult.Create(test as ITestInfo, TTestResultType.Ignored, ignoreReason);
end;

function TDUnitXTestRunner.ExecuteSetupFixtureMethod(const context : ITestExecuteContext; const threadId : TThreadID; const fixture : ITestFixture; const
  fixtureResult : IFixtureResult) : boolean;
begin
  try
    Self.Loggers_SetupFixture(threadid, fixture as ITestFixtureInfo);
    fixture.SetupFixtureMethod;
    Self.Loggers_EndSetupFixture(threadid, fixture as ITestFixtureInfo);
    result := true;
  except
    on e : Exception do
    begin
      result := false;
      // Log error into each test
      InvalidateTestsInFixture(fixture, context, threadId, e, fixtureResult);
      Log(TLogLevel.Error, Format(SFixtureSetupError, [fixture.Name, e.Message]));
      Log(TLogLevel.Error, SSkippingFixture);

    end;
  end;
end;

function TDUnitXTestRunner.ExecuteSuccessfulResult(const context : ITestExecuteContext; const threadId : TThreadID; const test : ITest; const aMessage :
  string; const aLogMessages : TLogMessageArray) : ITestResult;
var
  testInfo : ITestInfo;
begin
  testInfo := test as ITestInfo;
  Result := TDUnitXTestResult.Create(testInfo, TTestResultType.Pass, aMessage, aLogMessages);
end;

procedure TDUnitXTestRunner.ExecuteTearDownFixtureMethod(const context : ITestExecuteContext; const threadId : TThreadID; const fixture : ITestFixture; const
  fixtureResult : IFixtureResult);
var
  tearDownTest : ITest;
  tearDownResult : ITestResult;
begin
  try
    Self.Loggers_TeardownFixture(threadId, fixture as ITestFixtureInfo);
    fixture.ExecuteFixtureTearDown;     //deals with destructors in a way that stops memory leak reporting from reporting bogus leaks.
    Self.Loggers_EndTearDownFixture(threadId, fixture as ITestFixtureInfo);
  except
    on e : Exception do
    begin
      //The fixture's tests have already run and been recorded, so they are not reported again.
      //The failure is recorded once, as an error result named after the teardown method.
      tearDownTest := TDUnitXTest.Create(fixture, fixture.TearDownFixtureMethodName, fixture.TearDownFixtureMethodName, '', nil, true);
      Self.Loggers_BeginTest(threadId, tearDownTest as ITestInfo);
      //Results reference their test weakly; this test belongs to no fixture list, so the result keeps it alive.
      tearDownResult := TDUnitXAmendedTestError.Create(ExecuteErrorResult(context, threadId, tearDownTest, e, FLogMessagesEx), '',
        tearDownTest as ITestInfo);
      Log(TLogLevel.Error, Format(SFixtureTeardownError, [fixture.Name, e.Message]));
      RecordResult(context, threadId, fixtureResult, tearDownResult);
      Self.Loggers_EndTest(threadId, tearDownResult);
    end;
  end;
end;

function TDUnitXTestRunner.ExecuteTest(const context : ITestExecuteContext; const threadId : TThreadID; const test : ITest; const memoryAllocationProvider :
  IMemoryLeakMonitor) : ITestResult;
var
  testExecute : ITestExecute;
  assertBeforeCount : Cardinal;
  assertAfterCount : Cardinal;
  passed : boolean;
  passMessage : string;
  logText : string;
begin
  if Supports(test, ITestExecute, testExecute) then
  begin
    BeginLeakSpan;
    BeginRunnerAllocation;
    FLogMessages.Clear;
    SetLength(FLogMessagesEx, 0);
    EndRunnerAllocation;
    FCurrentTestName := test.Name;
    try
      Self.Loggers_ExecuteTest(threadId, test as ITestInfo);
      assertBeforeCount := 0;           //to shut the compiler up;
      if FFailsOnNoAsserts then
        assertBeforeCount := TDUnitX.GetAssertCount(threadId);
      passed := false;
      memoryAllocationProvider.PreTest;
      try
        try
          testExecute.Execute(context);
        except
          //Assert.Pass is handled here so that its exception object has been released by the time
          //PostTest measures. The message is copied, and the copy is discounted as runner memory.
          on e : ETestPass do
          begin
            passed := true;
            BeginRunnerAllocation;
            passMessage := e.Message;
            UniqueString(passMessage);
            EndRunnerAllocation;
          end;
        end;
      finally
        memoryAllocationProvider.PostTest;
        ExtendLeakSpan;
      end;

      if passed then
      begin
        BeginRunnerAllocation;
        Result := ExecuteSuccessfulResult(context, threadId, test, passMessage, FLogMessagesEx);
        EndRunnerAllocation;
        Exit;
      end;

      if FFailsOnNoAsserts then
      begin
        assertAfterCount := TDUnitX.GetAssertCount(threadId);
        if (assertBeforeCount = assertAfterCount) then
          raise ENoAssertionsMade.Create(SNoAssertions);
      end;

      //The result is kept until after teardown, so it is runner memory; the log text is held in a
      //variable that is released here, not at the end of the method, outside the measurement.
      BeginRunnerAllocation;
      logText := FLogMessages.Text;
      Result := ExecuteSuccessfulResult(context, threadId, test, logText, FLogMessagesEx);
      logText := '';
      FLogMessages.Clear;
      SetLength(FLogMessagesEx, 0);
      EndRunnerAllocation;
    finally
      FCurrentTestName := '';
    end;
  end
  else
  begin
    //This will be handled by the caller as a test error.
    raise Exception.CreateFmt(SITestExecuteNotSupported, [test.Name]);
  end;
end;

procedure TDUnitXTestRunner.ExecuteTests(const context : ITestExecuteContext; const threadId : TThreadID; const fixture : ITestFixture; const fixtureResult :
  IFixtureResult);
var
  tests : IEnumerable<ITest>;
  test : ITest;
  testResult : ITestResult;
  setupResult : ITestResult;
  tearDownResult : ITestResult;
  memoryAllocationResult : ITestResult;
  memoryAllocationProvider : IMemoryLeakMonitor;
  testError : ITestError;
begin
  tests := fixture.Tests;
  for test in tests do
  begin

    if not ShouldRunThisTest(test) then
      System.Continue;

    memoryAllocationProvider := TDUnitXServiceLocator.DefaultContainer.Resolve<IMemoryLeakMonitor>();
    //A second monitor measures what the runner keeps while the test runs. A singleton registration
    //returns the same monitor, whose readings that would overwrite, so the runner then measures nothing.
    FRunnerAllocationMonitor := TDUnitXServiceLocator.DefaultContainer.Resolve<IMemoryLeakMonitor>();
    if FRunnerAllocationMonitor = memoryAllocationProvider then
      FRunnerAllocationMonitor := nil;
    FRunnerAllocated := 0;
    FLeakSpanMonitor := TDUnitXServiceLocator.DefaultContainer.Resolve<IMemoryLeakMonitor>();
    if (FLeakSpanMonitor = memoryAllocationProvider) or (FLeakSpanMonitor = FRunnerAllocationMonitor) then
      FLeakSpanMonitor := nil;
    FLeakSpanStarted := False;

    //Start a fresh for this test. If we had an exception last execute of the
    //setup or tear down that may have changed this execution. Therefore we try
    //again to see if things have changed. Remember setup, test, tear down can
    //hold state
    setupResult := nil;
    testResult := nil;
    tearDownResult := nil;
    memoryAllocationResult := nil;

    Self.Loggers_BeginTest(threadId, test as ITestInfo);

    //If the setup fails then we need to show this as the result.
    if Assigned(fixture.SetupMethod) and (not test.Ignored) then
      if not (ExecuteTestSetupMethod(context, threadId, fixture, test, setupResult, memoryAllocationProvider)) then
        testResult := setupResult;

    try
      try
        if test.Ignored then
          testResult := ExecuteIgnoredResult(context, threadId, test, test.IgnoreReason)
            //If we haven't already failed, then run the test.
        else if testResult = nil then
          testResult := ExecuteTest(context, threadId, test, memoryAllocationProvider);

      except
        //Handle the results which are raised in the test.
        on e : ETestIgnored do
          //  A RUNTIME ignore carries its own reason; the attribute's
          //  IgnoreReason is empty for it. Preferring e.Message is what
          //  makes Assert.Ignore('...') report anything at all - without
          //  this the skip is recorded but the reason is silently dropped.
          if e.Message <> '' then
            testResult := ExecuteIgnoredResult(context, threadId, test, e.Message)
          else
            testResult := ExecuteIgnoredResult(context, threadId, test, test.IgnoreReason);
        on e : ETestPass do
          testResult := ExecuteSuccessfulResult(context, threadId, test, e.Message, FLogMessagesEx);
        on e : ETestFailure do
          testResult := ExecuteFailureResult(context, threadId, test, e, FLogMessagesEx);
        on e : ETimedOut do
          testResult := ExecuteTimedOutResult(context, threadId, test, e, FLogMessagesEx);
        on e : Exception do
          testResult := ExecuteErrorResult(context, threadId, test, e, FLogMessagesEx);
      end;

      //TearDown does not run after a failed Setup (as in DUnit and NUnit). If it fails, that is the
      //result of a passing test; after a failure the test's own message stays first and the TearDown
      //error is appended.
      if Assigned(fixture.TearDownMethod) and (not test.Ignored) and (setupResult = nil) then
        if not (ExecuteTestTearDown(context, threadId, fixture, test, tearDownResult, memoryAllocationProvider)) then
        begin
          if Supports(testResult, ITestError, testError) then
            testResult := TDUnitXAmendedTestError.Create(testError, sLineBreak + Format(STearDownAlsoFailed, [tearDownResult.Message]))
          else
            testResult := tearDownResult;
        end;

      FRunnerAllocationMonitor := nil;
      if (testResult.ResultType = TTestResultType.Pass) then
        if (not CheckMemoryAllocations(test, memoryAllocationResult, memoryAllocationProvider)) then
          testResult := memoryAllocationResult;
    finally
      FRunnerAllocationMonitor := nil;
      FLeakSpanMonitor := nil;
      FLeakSpanStarted := False;
      RecordResult(context, threadId, fixtureResult, testResult);
      Self.Loggers_EndTest(threadId, testResult);
    end;
  end;
end;

function TDUnitXTestRunner.ExecuteTestSetupMethod(const context : ITestExecuteContext; const threadId : TThreadID; const fixture : ITestFixture; const test :
  ITest; out errorResult : ITestResult; const memoryAllocationProvider : IMemoryLeakMonitor) : boolean;
begin
  Result := False;
  errorResult := nil;

  //Setup method is called before each test method.
  if Assigned(fixture.SetupMethod) then
  begin
    try
      Self.Loggers_SetupTest(threadId, test as ITestInfo);

      BeginLeakSpan;
      memoryAllocationProvider.PreSetup;

      fixture.SetupMethod;

      memoryAllocationProvider.PostSetUp;

      Self.Loggers_EndSetupTest(threadId, test as ITestInfo);
      Result := True;
    except
      on e : {$IFDEF USE_NS}System.SysUtils.{$ENDIF}Exception do
      begin
        errorResult := ExecuteErrorResult(context, threadId, test, e, FLogMessagesEx);
      end;
    end;
  end;
end;

function TDUnitXTestRunner.ExecuteTestTearDown(const context :
  ITestExecuteContext; const threadId : TThreadID; const fixture : ITestFixture; const test : ITest; out errorResult : ITestResult; const
  memoryAllocationProvider : IMemoryLeakMonitor) : boolean;
begin
  Result := False;
  errorResult := nil;

  try
    Self.Loggers_TeardownTest(threadId, test as ITestInfo);

    memoryAllocationProvider.PreTearDown;

    fixture.TearDownMethod;

    memoryAllocationProvider.PostTearDown;
    ExtendLeakSpan;

    Self.Loggers_EndTeardownTest(threadId, test as ITestInfo);
    result := true;
  except
    on e : {$IFDEF USE_NS}System.SysUtils.{$ENDIF}Exception do
    begin
      errorResult := ExecuteErrorResult(context, threadId, test, e, FLogMessagesEx);
    end;
  end;
end;

function TDUnitXTestRunner.ExecuteTimedOutResult(const context : ITestExecuteContext; const threadId : TThreadID; const test : ITest; const exception :
  Exception; const aLogMessages : TLogMessageArray) : ITestError;
begin
  Result := TDUnitXTestError.Create(test as ITestInfo, TTestResultType.Failure, exception, ExceptAddr, exception.Message, aLogMessages);
end;

function TDUnitXTestRunner.GetUseRTTI : Boolean;
begin
  result := FUseRTTI;
end;

procedure TDUnitXTestRunner.InvalidateTestsInFixture(const aFixture : ITestFixture; const aContext : ITestExecuteContext; const aThreadId : TThreadID; const
  aException : Exception; const aFixtureResult : IFixtureResult);
var
  lTest : ITest;
  lTestResult : ITestResult;
begin
  for lTest in aFixture.Tests do
  begin
    if not ShouldRunThisTest(lTest) then
      Continue;

    Self.Loggers_BeginTest(aThreadId, lTest as ITestInfo);
    //An ignored test would not have run anyway, so it stays ignored rather than becoming an error.
    if lTest.Ignored then
      lTestResult := ExecuteIgnoredResult(aContext, aThreadId, lTest, lTest.IgnoreReason)
    else
      lTestResult := ExecuteErrorResult(aContext, aThreadId, lTest, aException, FLogMessagesEx);
    RecordResult(aContext, aThreadId, aFixtureResult, lTestResult);
    Self.Loggers_EndTest(aThreadId, lTestResult);
  end;
end;

procedure TDUnitXTestRunner.SetFailsOnNoAsserts(const value : boolean);
begin
  FFailsOnNoAsserts := value;
end;

procedure TDUnitXTestRunner.SetUseRTTI(const value : Boolean);
begin
  FUseRTTI := value;
end;

procedure TDUnitXTestRunner.Status(const msg : string);
begin
  Self.Log(TLogLevel.Information, msg);
end;

procedure TDUnitXTestRunner.WriteLn;
begin
  Self.Log(TLogLevel.Information, '');
end;

procedure TDUnitXTestRunner.WriteLn(const msg : string);
begin
  Self.Log(TLogLevel.Information, msg);
end;

procedure TDUnitXTestRunner.Loggers_SetupFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
var
  logger : ITestLogger;
begin
  for logger in FLoggers do
    logger.OnSetupFixture(threadId, fixture);
end;

procedure TDUnitXTestRunner.Loggers_SetupTest(const threadId : TThreadID; const Test : ITestInfo);
var
  logger : ITestLogger;
begin
  for logger in FLoggers do
    logger.OnSetupTest(threadId, Test);
end;

procedure TDUnitXTestRunner.Loggers_BeginTest(const threadId : TThreadID; const Test : ITestInfo);
var
  logger : ITestLogger;
begin
  for logger in FLoggers do
    logger.OnBeginTest(threadId, Test);
end;

procedure TDUnitXTestRunner.Loggers_StartTestFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
var
  logger : ITestLogger;
begin
  for logger in FLoggers do
    logger.OnStartTestFixture(threadId, fixture);
end;

procedure TDUnitXTestRunner.Loggers_TeardownFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
var
  logger : ITestLogger;
begin
  for logger in FLoggers do
    logger.OnTearDownFixture(threadId, fixture);
end;

procedure TDUnitXTestRunner.Loggers_TeardownTest(const threadId : TThreadID; const Test : ITestInfo);
var
  logger : ITestLogger;
begin
  for logger in FLoggers do
    logger.OnTeardownTest(threadId, Test);
end;

procedure TDUnitXTestRunner.Loggers_TestingEnds(const RunResults : IRunResults);
var
  logger : ITestLogger;
begin
  for logger in FLoggers do
    logger.OnTestingEnds(RunResults);
end;

procedure TDUnitXTestRunner.Loggers_TestingStarts(const threadId : TThreadID; testCount, testActiveCount : Cardinal);
var
  logger : ITestLogger;
begin
  for logger in FLoggers do
    logger.OnTestingStarts(threadId, testCount, testActiveCount);
end;

procedure TDUnitXTestRunner.Log(const logType : TLogLevel; const msg : string);
var
  logger : ITestLogger;
  NewIdx : integer;
  logMsg : string;
begin
  if logType >= TDUnitX.Options.LogLevel then
  begin
    //What logging keeps is the runner's memory, not the test's: the leak check discounts it.
    BeginRunnerAllocation;
    try
      //The lists keep a copy made here; sharing the test's string would leave its memory counted
      //against the test.
      logMsg := msg;
      UniqueString(logMsg);
      //TODO : Need to get this to the current test result.
      FLogMessages.Add(logMsg);
      NewIdx := Length(FLogMessagesEx);
      SetLength(FLogMessagesEx, NewIdx + 1);
      FLogMessagesEx[NewIdx].Level := logType;
      FLogMessagesEx[NewIdx].Msg := logMsg;
      for logger in FLoggers do
        logger.OnLog(logType, logMsg);
    finally
      EndRunnerAllocation;
    end;
  end;
end;

procedure TDUnitXTestRunner.BeginRunnerAllocation;
begin
  if FRunnerAllocationMonitor <> nil then
    FRunnerAllocationMonitor.PreTest;
end;

procedure TDUnitXTestRunner.EndRunnerAllocation;
begin
  if FRunnerAllocationMonitor <> nil then
  begin
    FRunnerAllocationMonitor.PostTest;
    Inc(FRunnerAllocated, FRunnerAllocationMonitor.TestMemoryAllocated);
  end;
end;

procedure TDUnitXTestRunner.BeginLeakSpan;
begin
  if (FLeakSpanMonitor <> nil) and (not FLeakSpanStarted) then
  begin
    FLeakSpanStarted := True;
    FLeakSpanMonitor.PreTest;
  end;
end;

procedure TDUnitXTestRunner.ExtendLeakSpan;
begin
  if FLeakSpanStarted then
    FLeakSpanMonitor.PostTest;
end;

function TDUnitXTestRunner.ShouldRunThisTest(const test : ITest) : boolean;
begin
  Result := True;

  if not test.Enabled then
    Result := False;

  if test.Ignored and TDUnitX.Options.DontShowIgnored then
    Result := False;

end;

end.

