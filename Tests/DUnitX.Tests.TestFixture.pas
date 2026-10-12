{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2012 Vincent Parrett                              }
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

unit DUnitX.Tests.TestFixture;

interface

uses
  DUnitX.TestFramework,
  DUnitX.TestFixture;

const
  TIMES_RUN         = 3;
  TIMES_RUN_ANYWAY  = 5;
  TIMES_RUN_TEST_CASE = 2;

type
{$M+}
  [TestFixture]
  TTestClassWithNonPublicSetup = class
  private
    FSetupRun : Boolean;
  protected
    [Setup]
    procedure Setup;
  public
    constructor Create;
    property SetupRun : Boolean read FSetupRun;
  end;
{$M-}

  MockTestSourceAttribute = class(CustomTestCaseSourceAttribute)
  protected
    function GetCaseInfoArray : TestCaseInfoArray; override;
  end;

{$M+}
  [TestFixture]
  TTestClassWithTestSource = class
  public
    [Test]
    [MockTestSource]
    procedure DataTest(Value : Integer);
  end;
{$M-}

{$M+}
  [TestFixture]
  TTestRepeatAttribute = class
  public
    [SetUpFixture]
    procedure SetUpFixture;

    [TearDownFixture]
    procedure TearDownFixture;

    [Test]
    [RepeatTest(TIMES_RUN)]
    procedure TestRepeat3Times;

    [RepeatTest(TIMES_RUN_TEST_CASE)]
    [Test]
    [TestCase('Sum Case', '1,2,3')]
    procedure Sum(const A, B, Expected : Integer);

    [Test]
    [RepeatTest(0)]
    procedure IgnoreMeWhenRepeatIsZero;
  published
    [RepeatTest(TIMES_RUN_ANYWAY)]
    procedure TestRepeat5TimesAnyWay;

    [Test]
    [RepeatTest(0)]
    procedure IgnoreMeAnyWayWhenRepeatIsZero;
  end;
{$M-}

{$M+}
  [TestFixture]
  TTestMaxTimeAttribute = class
  public
    [Test]
    [MaxTime(0)]
    procedure MaxTimeIsZero;

    //We ignore the timeout test for the moment. We require a way to test timeout without calling it to fail the test itself.
    [Test, Ignore]
    [MaxTime(100)]
    procedure TestTimeout;

    [Test]
    [MaxTime(100)]
    procedure TestDoesNotTimeout;
  end;
{$M-}

  TTestCaseAttribute = class
  public
    procedure ProcedureWithUntypedParameter(const Param1);
    procedure ProcedureWithByteParameter(const Value : Byte);
    procedure ProcedureWithTwoParameters(const First, Second : Integer);
  end;

{$M+}
  [TestFixture]
  TDUnitXTestFixtureTests = class
  public
    [Test]
    procedure WhenATestCaseHasAUntypedParameterCantRaiseAnyError;
    // Proves that bad [TestCase] data (a value that does not convert, too few or too many values) makes that case
    // report an error naming the case, parameter and value when it runs, instead of running with 0 / defaults, and
    // that building the case does not raise (which would abort the whole run).
    [Test]
    procedure WhenATestCaseValueIsInvalidTheCaseErrors;
    // Proves that TFullNameFilter (the GUI runner's Run / Run Selected filter) matches a test only by its exact full
    // name: a test of another fixture whose full name merely starts with the checked test's name does not run, as it
    // does through TNameFilter's fixture-prefix match.
    [Test]
    procedure FullNameFilterMatchesOnlyTheExactTest;
  end;
{$M-}

{$M+}
  [TestFixture]
  TRunnerBehaviourTests = class
  public
    // Proves that a runner created on a thread that already has an active runner (a runner driven from inside a
    // test) does not raise EListError, stands in as the current runner, and hands the thread back to the first runner
    // when it is destroyed. The old registry raised, and the failing constructor's destructor removed the FIRST
    // runner's entry.
    [Test]
    procedure SecondRunnerOnAThreadStandsInAndRestoresTheFirst;
    // Proves that [WillRaise] and [MaxTime] on a method with [TestCase] are enforced for each case: a case that does
    // not raise, and a case that overruns, both fail. They were dropped when the case was created.
    [Test]
    procedure TestCasesKeepWillRaiseAndMaxTime;
    // Proves that a [MaxTime(100)] test whose body takes 115 ms fails. The old watchdog polled every 20 ms (in
    // practice up to ~31 ms) from its own thread, so an overrun that ended between two polls passed.
    [Test]
    procedure MaxTimeOverrunIsCaughtWhateverTheTiming;
    // Proves that a [WillRaise(Exception, exDescendant)] test whose body fails an assertion is reported as a failure,
    // not as "raised as expected".
    [Test]
    procedure FailingAssertInWillRaiseTestIsAFailure;
    // Proves that running a [WillRaise] test does not keep the run results alive once released. The test kept the
    // execute context (the run results), which hold the fixture, which holds the test: a cycle that leaked the run.
    [Test]
    procedure ExceptionTestDoesNotKeepTheRunResultsAlive;
    // Proves that [RepeatTest] repetitions, plain and with [TestCase], get the [Setup] declared in a base class and
    // run it on the same instance as the test. Repetitions used to get a child fixture whose Setup was copied before
    // the base class's [Setup] had been seen (so none ran), and test cases ran on the child's own instance.
    [Test]
    procedure RepeatedTestsRunWithTheirSetupOnTheirInstance;
    // Proves that when [SetupFixture] fails no test of the fixture runs, repetitions included, each is reported as an
    // error, and an [Ignore]d test is still reported as ignored rather than as an error.
    [Test]
    procedure AfterSetupFixtureFailsNothingRunsAndIgnoredStayIgnored;
    // Proves that a failing [TearDownFixture] is reported once, as its own error, and that the tests that already
    // passed are not reported a second time as errors.
    [Test]
    procedure TearDownFixtureFailureIsReportedOnce;
    // Proves that a fixture whose destructor (its implicit TearDownFixture) raises is not freed a second time when
    // the fixture is destroyed.
    [Test]
    procedure RaisingDestructorIsNotFreedTwice;
    // Proves that a fixture constructor that raises does not abort building the fixtures, and that the fixture's
    // tests are then reported as errors carrying the constructor's message.
    [Test]
    procedure RaisingConstructorErrorsOnlyItsFixture;
    // Proves that when a parameterless constructor takes the place of a [SetupFixture] method (upstream's documented
    // behaviour, see TExampleFixture3), the runner logs a warning naming the method instead of dropping it silently.
    [Test]
    procedure SuppressedSetupFixtureIsReported;
    // Proves that TearDown does not run after a failed Setup, so the Setup error is the one reported.
    [Test]
    procedure TearDownIsSkippedAfterSetupFails;
    // Proves that when a test fails and its TearDown then fails too, the result stays a failure whose message
    // starts with the test's own message and also carries the TearDown error.
    [Test]
    procedure TearDownErrorDoesNotHideTestFailure;
    // Proves that a [TestCaseProvider] naming an unregistered provider produces an error naming it, rather than
    // silently producing no tests.
    [Test]
    procedure UnregisteredTestCaseProviderIsAnError;
    // Proves the leak check, with a monitor that counts simulated allocations: memory held by the runner's own log
    // lists, and the ETestPass object raised by a pass, are not leaks; a test that frees earlier memory (a negative
    // delta) is not a leak; a real allocation still is.
    [Test]
    procedure LeakCheckCountsOnlyTheTestsOwnGrowth;
    // Proves that SuccessRate is a percentage (3 of 4 passing is 75), not 0 or 100.
    [Test]
    procedure SuccessRateIsAPercentage;
    // Proves that a run in which no test executed (none at all, or all ignored) is not reported as all passed.
    [Test]
    procedure RunWithNoExecutedTestsIsNotAllPassed;
    // Proves that when a fixture is run again (as the GUI runner does) after its instance was freed, Setup runs on
    // the new instance, not on the freed one.
    [Test]
    procedure RerunBindsSetupToTheNewInstance;
  end;
{$M-}

implementation

uses
{$IFDEF USE_NS}
  System.Math,
  System.SysUtils,
  System.Rtti,
{$ELSE}
  Math,
  SysUtils,
  Rtti,
{$ENDIF}
  DUnitX.Types,
  DUnitX.Extensibility,
  DUnitX.InternalInterfaces,
  DUnitX.TestRunner,
{$IFDEF USE_NS}
  System.Classes,
{$ELSE}
  Classes,
{$ENDIF}
  DUnitX.Exceptions,
  DUnitX.FixtureProvider,
  DUnitX.RunResults,
  DUnitX.ServiceLocator,
  DUnitX.Loggers.Null,
  DUnitX.Filters,
  DUnitX.MemoryLeakMonitor.Default;

var
  _TimesRun : Integer;
  _TimesRunAnyWay : Integer;
  _TimesRunTestCase : Integer;

  { TDUnitXTestFixtureTests }

  { TTestClassWithNonPublicSetup }

constructor TTestClassWithNonPublicSetup.Create;
begin
  inherited Create;
  FSetupRun := False;
end;

procedure TTestClassWithNonPublicSetup.Setup;
begin
  //Optimised out as the method is not used internally;
  FSetupRun := True;
end;

{ TTestSourceAttribute }

function MockTestSourceAttribute.GetCaseInfoArray : TestCaseInfoArray;
var
  I : Integer;
begin
  SetLength(result, 3);
  for I := 0 to 2 do
  begin
    result[I].Name := 'DataTest' + IntToStr(I);
    SetLength(result[I].Values, 1);
    result[I].Values[0] := I;
  end;
end;

{ TTestClassWithTestSource }

procedure TTestClassWithTestSource.DataTest(Value : Integer);
begin
  TDUnitX.CurrentRunner.Status(Format('DataTest(%d) Called', [Value]));
  Assert.IsTrue(InRange(Value, 0, 2));
end;

{ TTestRepeatAttribute }

procedure TTestRepeatAttribute.TestRepeat3Times;
begin
  Inc(_TimesRun);
  Assert.Pass;
end;

procedure TTestRepeatAttribute.TestRepeat5TimesAnyWay;
begin
  Inc(_TimesRunAnyWay);
  Sleep(5);
  Assert.Pass;
end;

procedure TTestRepeatAttribute.IgnoreMeAnyWayWhenRepeatIsZero;
begin
  Assert.IsTrue(false, 'I should not have been called!');
end;

procedure TTestRepeatAttribute.IgnoreMeWhenRepeatIsZero;
begin
  Assert.IsTrue(false, 'I should not have been called!');
end;

procedure TTestRepeatAttribute.SetUpFixture;
begin
  _TimesRun := 0;
  _TimesRunAnyWay := 0;
  _TimesRunTestCase := 0;
end;

procedure TTestRepeatAttribute.Sum(const A, B, Expected : Integer);
begin
  Assert.AreEqual(Expected, A + B);
  Inc(_TimesRunTestCase);
end;

procedure TTestRepeatAttribute.TearDownFixture;
begin
  Assert.AreEqual(TIMES_RUN, _TimesRun, 'TimesRun');
  Assert.AreEqual(TIMES_RUN_ANYWAY, _TimesRunAnyWay, 'TimesRunAnyway');
  Assert.AreEqual(TIMES_RUN_TEST_CASE, _TimesRunTestCase, 'TimesRunTestCase');
end;

{ TTestMaxTimeAttribute }

procedure TTestMaxTimeAttribute.MaxTimeIsZero;
begin
  Sleep(100);
  Assert.Pass;                          // even after a delay,
  // the test should not timeout, as zero means no timeout
end;

procedure TTestMaxTimeAttribute.TestTimeout;
begin
  Sleep(150);
  Assert.Fail('Timeout should catch this test.'); // the test should time out before this point
end;

procedure TTestMaxTimeAttribute.TestDoesNotTimeout;
begin
  Assert.Pass;                          // the test should NOT time out before this point
end;

{ TDUnitXTestFixtureTests }

procedure TDUnitXTestFixtureTests.WhenATestCaseHasAUntypedParameterCantRaiseAnyError;
var
  Context : TRttiContext;
  MyClass : TRttiType;
  MyMethod : TRttiMethod;
  TestFixture : ITestFixture;
  args : TValueArray;
begin
  Context := TRttiContext.Create;
  MyClass := Context.GetType(TTestCaseAttribute);
  MyMethod := MyClass.GetMethod('ProcedureWithUntypedParameter');
  TestFixture := TDUnitXTestFixture.Create(MyClass.Name, EmptyStr, TTestCaseAttribute, MyClass.UnitName) as ITestFixture;

  Assert.WillNotRaise(
    procedure
    begin
      SetLength(args, 1);
      args[0] := 0;
      TestFixture.AddTestCase(MyMethod.Name, 'My test case', 'My name', 'My category', MyMethod, True, args);
    end);

  TestFixture := nil;

  Context.Free;
end;

procedure TDUnitXTestFixtureTests.FullNameFilterMatchesOnlyTheExactTest;
var
  Context : TRttiContext;
  MyClass : TRttiType;
  MyMethod : TRttiMethod;
  FixtureA : ITestFixture;
  FixtureB : ITestFixture;
  TestA : ITest;
  TestA2 : ITest;
  TestB : ITest;
  filter : ITestFilter;
begin
  Context := TRttiContext.Create;
  MyClass := Context.GetType(TTestCaseAttribute);
  MyMethod := MyClass.GetMethod('ProcedureWithTwoParameters');
  FixtureA := TDUnitXTestFixture.Create('NS.Fix', EmptyStr, TTestCaseAttribute, MyClass.UnitName) as ITestFixture;
  TestA := FixtureA.AddTest(MyMethod.Name, nil, 'Run', '', MyMethod);
  TestA2 := FixtureA.AddTest(MyMethod.Name, nil, 'RunLater', '', MyMethod);
  //A fixture whose full name starts with TestA's full name, as a nested namespace or child fixture can.
  FixtureB := TDUnitXTestFixture.Create(TestA.FullName + 'Load', EmptyStr, TTestCaseAttribute, MyClass.UnitName) as ITestFixture;
  TestB := FixtureB.AddTest(MyMethod.Name, nil, 'Other', '', MyMethod);

  filter := TNameFilter.Create(TestA.FullName);
  Assert.IsTrue(filter.Match(TestB), 'precondition: TNameFilter matches a fixture name prefix');

  filter := TFullNameFilter.Create(TestA.FullName);
  Assert.IsTrue(filter.Match(TestA), 'the named test');
  Assert.IsFalse(filter.Match(TestB), 'a test of a fixture whose full name starts with the named test''s');
  Assert.IsFalse(filter.Match(TestA2), 'a test whose full name starts with the named test''s');

  //Test case names can differ only in case, so the match is case-sensitive.
  filter := TFullNameFilter.Create(UpperCase(TestA.FullName));
  Assert.IsFalse(filter.Match(TestA), 'the named test in another case');

  filter := nil;
  TestA := nil;
  TestA2 := nil;
  TestB := nil;
  FixtureA := nil;
  FixtureB := nil;
  Context.Free;
end;

procedure TDUnitXTestFixtureTests.WhenATestCaseValueIsInvalidTheCaseErrors;
var
  Context : TRttiContext;
  MyClass : TRttiType;
  TestFixture : ITestFixture;

  function ExecuteError(const AMethodName, ACaseName : string; const AArgs : array of string) : string;
  var
    args : TValueArray;
    i : Integer;
    test : ITest;
  begin
    SetLength(args, Length(AArgs));
    for i := 0 to High(AArgs) do
      args[i] := AArgs[i];
    test := TestFixture.AddTestCase(AMethodName, ACaseName, AMethodName, '', MyClass.GetMethod(AMethodName), True, args);
    Result := '';
    try
      (test as ITestExecute).Execute(nil);
    except
      on E : Exception do
        Result := E.Message;
    end;
  end;

var
  msg : string;
begin
  Context := TRttiContext.Create;
  MyClass := Context.GetType(TTestCaseAttribute);
  TestFixture := TDUnitXTestFixture.Create(MyClass.Name, EmptyStr, TTestCaseAttribute, MyClass.UnitName) as ITestFixture;

  msg := ExecuteError('ProcedureWithByteParameter', 'OutOfRange', ['300']);
  Assert.Contains(msg, 'OutOfRange', False, 'case name');
  Assert.Contains(msg, 'Value', False, 'parameter name');
  Assert.Contains(msg, '300', False, 'value');

  msg := ExecuteError('ProcedureWithTwoParameters', 'NotANumber', ['1', 'abc']);
  Assert.Contains(msg, 'NotANumber', False, 'case name');
  Assert.Contains(msg, 'Second', False, 'parameter name');
  Assert.Contains(msg, 'abc', False, 'value');

  msg := ExecuteError('ProcedureWithTwoParameters', 'TooFew', ['1']);
  Assert.Contains(msg, 'TooFew', False, 'too few values');

  msg := ExecuteError('ProcedureWithTwoParameters', 'TooMany', ['1', '2', '3']);
  Assert.Contains(msg, 'TooMany', False, 'too many values');

  Assert.AreEqual('', ExecuteError('ProcedureWithTwoParameters', 'Valid', ['1', '2']), False, 'valid values');

  TestFixture := nil;
  Context.Free;
end;

{ Fixtures driven by TRunnerBehaviourTests through a private runner. They carry no [TestFixture] and are not
  registered, so the suite's own runner does not run them. }

var
  GFakeAllocated : Int64;
  GSetupFixtureRan : boolean;
  GTearDownRan : boolean;
  GBodyRan : boolean;
  GSetupInstance : TObject;
  GWarnings : string;

type
{$M+}
  TRunnerCaseAttributes = class
  public
    [Test]
    [TestCase('DoesNotRaise', '1')]
    [WillRaise(EArgumentOutOfRangeException)]
    procedure CaseExpectedToRaise(const AValue : Integer);
    [Test]
    [TestCase('Slow', '150')]
    [MaxTime(100)]
    procedure CaseOverItsMaxTime(const ADelay : Integer);
    [Test]
    [MaxTime(100)]
    procedure OverItsMaxTimeBetweenPolls;
    [Test]
    [WillRaise(Exception, exDescendant)]
    procedure FailingAssertIsNotTheExpectedRaise;
  end;

  TRunnerRaisesAsExpected = class
  public
    [Test]
    [WillRaise(EInvalidOpException)]
    procedure Raises;
  end;

  TRunnerSetupBase = class
  protected
    FSetupDone : boolean;
  public
    [Setup]
    procedure Setup;
  end;

  TRunnerRepeatWithBaseSetup = class(TRunnerSetupBase)
  public
    [Test]
    [RepeatTest(3)]
    procedure RepeatedTestSeesItsSetup;
    [Test]
    [RepeatTest(2)]
    [TestCase('One', '1')]
    procedure RepeatedCaseSeesItsSetup(const AValue : Integer);
  end;

  TRunnerSetupFixtureFails = class
  public
    [SetupFixture]
    procedure SetupFixture;
    [Test]
    procedure NotRun;
    [Test]
    [RepeatTest(2)]
    procedure NotRunEither;
    [Test]
    [Ignore('stays ignored')]
    procedure StaysIgnored;
  end;

  TRunnerTearDownFixtureFails = class
  public
    [TearDownFixture]
    procedure TearDownFixture;
    [Test]
    procedure PassesOne;
    [Test]
    procedure PassesTwo;
  end;

  TRunnerDestructorRaises = class
  public
    destructor Destroy; override;
    [Test]
    procedure Passes;
  end;

  TRunnerConstructorRaises = class
  public
    constructor Create;
    [Test]
    procedure NeverRuns;
  end;

  TRunnerConstructorAndSetupFixture = class
  public
    constructor Create;
    [SetupFixture]
    procedure SetupFixture;
    [Test]
    procedure ConstructorRan;
  end;

  TRunnerSetupFails = class
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure NeverRuns;
  end;

  TRunnerTestAndTearDownFail = class
  public
    [TearDown]
    procedure TearDown;
    [Test]
    procedure Fails;
  end;

  TRunnerUnknownProvider = class
  public
    [Test]
    [TestCaseProvider('DUnitX.Tests.NoSuchProvider')]
    procedure UsesAnUnregisteredProvider(const AValue : Integer);
  end;

  TRunnerLeakChecks = class
  public
    [Test]
    procedure PassesWithAssertPass;
    [Test]
    procedure LogsWhileRunning;
    [Test]
    procedure FreesEarlierMemory;
    [Test]
    procedure LeaksForReal;
  end;

  TRunnerThreeOfFourPass = class
  public
    [Test]
    procedure PassOne;
    [Test]
    procedure PassTwo;
    [Test]
    procedure PassThree;
    [Test]
    procedure Fails;
  end;

  TRunnerAllIgnored = class
  public
    [Test]
    [Ignore('ignored')]
    procedure Ignored;
  end;

  TRunnerSetupSeesTestInstance = class
  public
    [Setup]
    procedure Setup;
    [Test]
    procedure SetupRanOnThisInstance;
  end;
{$M-}

  //Simulates the ETestPass that Assert.Pass raises, counting its own memory as a real one would.
  ETestPassCounted = class(ETestPass)
  public
    constructor Create(const AMessage : string);
    destructor Destroy; override;
  end;

  //Measures GFakeAllocated, so a test can simulate allocations precisely.
  TFakeLeakMonitor = class(TInterfacedObject, IMemoryLeakMonitor)
  private
    FPreSetup : Int64;
    FPostSetup : Int64;
    FPreTest : Int64;
    FPostTest : Int64;
    FPreTearDown : Int64;
    FPostTearDown : Int64;
  public
    procedure PreSetup;
    procedure PostSetUp;
    procedure PreTest;
    procedure PostTest;
    procedure PreTearDown;
    procedure PostTearDown;
    function SetUpMemoryAllocated : Int64;
    function TearDownMemoryAllocated : Int64;
    function TestMemoryAllocated : Int64;
  end;

  //Collects warnings into GWarnings.
  TWarningLogger = class(TDUnitXNullLogger)
  protected
    procedure OnLog(const logType : TLogLevel; const msg : string); override;
  end;

  //Simulates a logger whose storage grows with every message.
  TFakeAllocatingLogger = class(TDUnitXNullLogger)
  protected
    procedure OnLog(const logType : TLogLevel; const msg : string); override;
  end;

  TRunnerAccess = class(TDUnitXTestRunner);
  TProviderAccess = class(TDUnitXFixtureProvider);

procedure TRunnerCaseAttributes.CaseExpectedToRaise(const AValue : Integer);
begin
end;

procedure TRunnerCaseAttributes.CaseOverItsMaxTime(const ADelay : Integer);
begin
  Sleep(ADelay);
end;

procedure TRunnerCaseAttributes.OverItsMaxTimeBetweenPolls;
begin
  Sleep(115);
end;

procedure TRunnerCaseAttributes.FailingAssertIsNotTheExpectedRaise;
begin
  Assert.Fail('an assertion failed');
end;

procedure TRunnerRaisesAsExpected.Raises;
begin
  raise EInvalidOpException.Create('expected');
end;

procedure TRunnerSetupBase.Setup;
begin
  FSetupDone := true;
end;

procedure TRunnerRepeatWithBaseSetup.RepeatedTestSeesItsSetup;
begin
  Assert.IsTrue(FSetupDone, 'Setup ran on this instance');
  FSetupDone := false;
end;

procedure TRunnerRepeatWithBaseSetup.RepeatedCaseSeesItsSetup(const AValue : Integer);
begin
  Assert.IsTrue(FSetupDone, 'Setup ran on this instance');
  FSetupDone := false;
end;

procedure TRunnerSetupFixtureFails.SetupFixture;
begin
  raise Exception.Create('setup fixture boom');
end;

procedure TRunnerSetupFixtureFails.NotRun;
begin
  GBodyRan := true;
end;

procedure TRunnerSetupFixtureFails.NotRunEither;
begin
  GBodyRan := true;
end;

procedure TRunnerSetupFixtureFails.StaysIgnored;
begin
  GBodyRan := true;
end;

procedure TRunnerTearDownFixtureFails.TearDownFixture;
begin
  raise Exception.Create('teardown fixture boom');
end;

procedure TRunnerTearDownFixtureFails.PassesOne;
begin
end;

procedure TRunnerTearDownFixtureFails.PassesTwo;
begin
end;

destructor TRunnerDestructorRaises.Destroy;
begin
  raise Exception.Create('destructor boom');
end;

procedure TRunnerDestructorRaises.Passes;
begin
end;

constructor TRunnerConstructorRaises.Create;
begin
  raise Exception.Create('constructor boom');
end;

procedure TRunnerConstructorRaises.NeverRuns;
begin
  GBodyRan := true;
end;

constructor TRunnerConstructorAndSetupFixture.Create;
begin
  inherited Create;
end;

procedure TRunnerConstructorAndSetupFixture.SetupFixture;
begin
  GSetupFixtureRan := true;
end;

procedure TRunnerConstructorAndSetupFixture.ConstructorRan;
begin
end;

procedure TWarningLogger.OnLog(const logType : TLogLevel; const msg : string);
begin
  if logType = TLogLevel.Warning then
    GWarnings := GWarnings + msg + sLineBreak;
end;

procedure TRunnerSetupFails.Setup;
begin
  raise Exception.Create('setup boom');
end;

procedure TRunnerSetupFails.TearDown;
begin
  GTearDownRan := true;
  raise Exception.Create('teardown boom');
end;

procedure TRunnerSetupFails.NeverRuns;
begin
  GBodyRan := true;
end;

procedure TRunnerTestAndTearDownFail.TearDown;
begin
  raise Exception.Create('teardown boom');
end;

procedure TRunnerTestAndTearDownFail.Fails;
begin
  Assert.Fail('test boom');
end;

procedure TRunnerUnknownProvider.UsesAnUnregisteredProvider(const AValue : Integer);
begin
end;

procedure TRunnerLeakChecks.PassesWithAssertPass;
begin
  raise ETestPassCounted.Create('passed with a message');
end;

procedure TRunnerLeakChecks.LogsWhileRunning;
begin
  TDUnitX.CurrentRunner.Status('a status line');
end;

procedure TRunnerLeakChecks.FreesEarlierMemory;
begin
  Dec(GFakeAllocated, 64);
end;

procedure TRunnerLeakChecks.LeaksForReal;
begin
  Inc(GFakeAllocated, 32);
end;

procedure TRunnerThreeOfFourPass.PassOne;
begin
end;

procedure TRunnerThreeOfFourPass.PassTwo;
begin
end;

procedure TRunnerThreeOfFourPass.PassThree;
begin
end;

procedure TRunnerThreeOfFourPass.Fails;
begin
  Assert.Fail('fails');
end;

procedure TRunnerAllIgnored.Ignored;
begin
end;

procedure TRunnerSetupSeesTestInstance.Setup;
begin
  GSetupInstance := Self;
end;

procedure TRunnerSetupSeesTestInstance.SetupRanOnThisInstance;
begin
  Assert.IsTrue(GSetupInstance = Self, 'Setup ran on the instance the test runs on');
end;

constructor ETestPassCounted.Create(const AMessage : string);
begin
  inherited Create(AMessage);
  Inc(GFakeAllocated, 100);
end;

destructor ETestPassCounted.Destroy;
begin
  Dec(GFakeAllocated, 100);
  inherited;
end;

procedure TFakeLeakMonitor.PreSetup;
begin
  FPreSetup := GFakeAllocated;
end;

procedure TFakeLeakMonitor.PostSetUp;
begin
  FPostSetup := GFakeAllocated;
end;

procedure TFakeLeakMonitor.PreTest;
begin
  FPreTest := GFakeAllocated;
end;

procedure TFakeLeakMonitor.PostTest;
begin
  FPostTest := GFakeAllocated;
end;

procedure TFakeLeakMonitor.PreTearDown;
begin
  FPreTearDown := GFakeAllocated;
end;

procedure TFakeLeakMonitor.PostTearDown;
begin
  FPostTearDown := GFakeAllocated;
end;

function TFakeLeakMonitor.SetUpMemoryAllocated : Int64;
begin
  Result := FPostSetup - FPreSetup;
end;

function TFakeLeakMonitor.TearDownMemoryAllocated : Int64;
begin
  Result := FPostTearDown - FPreTearDown;
end;

function TFakeLeakMonitor.TestMemoryAllocated : Int64;
begin
  Result := FPostTest - FPreTest;
end;

procedure TFakeAllocatingLogger.OnLog(const logType : TLogLevel; const msg : string);
begin
  Inc(GFakeAllocated, 50);
end;

//Builds a fixture for AClass the way the fixture provider does.
function BuildFixture(const AClass : TClass) : ITestFixture;
var
  provider : TDUnitXFixtureProvider;
  providerIntf : IFixtureProvider;
begin
  Result := TDUnitXTestFixture.Create(AClass.ClassName, '', AClass, AClass.UnitName);
  provider := TDUnitXFixtureProvider.Create;
  providerIntf := provider;
  TProviderAccess(provider).GenerateTests(nil, Result);
end;

//Runs one fixture through a private runner, which stands in for the suite's runner on this thread meanwhile.
function RunFixture(const AFixture : ITestFixture; const ALogger : ITestLogger = nil) : IRunResults;
var
  runner : TDUnitXTestRunner;
  runnerIntf : ITestRunner;
  fixtures : ITestFixtureList;
  context : ITestExecuteContext;
begin
  runner := TDUnitXTestRunner.Create(ALogger);
  runnerIntf := runner;
  fixtures := TTestFixtureList.Create;
  fixtures.Add(AFixture);
  Result := TDUnitXRunResults.Create;
  context := Result as ITestExecuteContext;
  TRunnerAccess(runner).ExecuteFixtures(nil, context, TThread.CurrentThread.ThreadID, fixtures);
  context.RollupResults;
end;

function FindResult(const AResults : IRunResults; const ATestName : string) : ITestResult;
var
  testResult : ITestResult;
begin
  Result := nil;
  for testResult in AResults.GetAllTestResults do
    if testResult.Test.Name = ATestName then
      Exit(testResult);
end;

procedure CheckResult(const AResults : IRunResults; const ATestName : string; const AExpected : TTestResultType;
  const AMessagePart : string = '');
var
  testResult : ITestResult;
begin
  testResult := FindResult(AResults, ATestName);
  Assert.IsTrue(testResult <> nil, ATestName + ' has a result');
  Assert.AreEqual(Ord(AExpected), Ord(testResult.ResultType), ATestName + ' result type; message: ' + testResult.Message);
  if AMessagePart <> '' then
    Assert.Contains(testResult.Message, AMessagePart, False, ATestName + ' message');
end;

{ TRunnerBehaviourTests }

procedure TRunnerBehaviourTests.TestCasesKeepWillRaiseAndMaxTime;
var
  results : IRunResults;
begin
  results := RunFixture(BuildFixture(TRunnerCaseAttributes));
  CheckResult(results, 'CaseExpectedToRaise.DoesNotRaise', TTestResultType.Failure);
  CheckResult(results, 'CaseOverItsMaxTime.Slow', TTestResultType.Failure);
end;

procedure TRunnerBehaviourTests.MaxTimeOverrunIsCaughtWhateverTheTiming;
var
  results : IRunResults;
begin
  results := RunFixture(BuildFixture(TRunnerCaseAttributes));
  CheckResult(results, 'OverItsMaxTimeBetweenPolls', TTestResultType.Failure);
end;

procedure TRunnerBehaviourTests.FailingAssertInWillRaiseTestIsAFailure;
var
  results : IRunResults;
begin
  results := RunFixture(BuildFixture(TRunnerCaseAttributes));
  CheckResult(results, 'FailingAssertIsNotTheExpectedRaise', TTestResultType.Failure, 'an assertion failed');
end;

procedure TRunnerBehaviourTests.ExceptionTestDoesNotKeepTheRunResultsAlive;
var
  [Weak] observed : IRunResults;

  //A separate procedure, so no hidden temporary of this method holds the fixture or the results.
  procedure RunAndObserve;
  var
    results : IRunResults;
  begin
    results := RunFixture(BuildFixture(TRunnerRaisesAsExpected));
    CheckResult(results, 'Raises', TTestResultType.Pass);
    observed := results;
  end;

begin
  RunAndObserve;
  Assert.IsTrue(observed = nil, 'the run results were freed when released');
end;

procedure TRunnerBehaviourTests.RepeatedTestsRunWithTheirSetupOnTheirInstance;
var
  results : IRunResults;
  i : Integer;
begin
  results := RunFixture(BuildFixture(TRunnerRepeatWithBaseSetup));
  Assert.AreEqual(5, results.TestCount, 'three repetitions and two repeated cases');
  for i := 1 to 3 do
    CheckResult(results, Format('RepeatedTestSeesItsSetup-%d-of-3', [i]), TTestResultType.Pass);
  for i := 1 to 2 do
    CheckResult(results, Format('RepeatedCaseSeesItsSetup-%d-of-2.One', [i]), TTestResultType.Pass);
end;

procedure TRunnerBehaviourTests.AfterSetupFixtureFailsNothingRunsAndIgnoredStayIgnored;
var
  results : IRunResults;
begin
  GBodyRan := false;
  results := RunFixture(BuildFixture(TRunnerSetupFixtureFails));
  Assert.IsFalse(GBodyRan, 'no test body ran');
  Assert.AreEqual(3, results.ErrorCount, 'NotRun and both repetitions of NotRunEither are errors');
  Assert.AreEqual(1, results.IgnoredCount, 'the ignored test is reported as ignored');
  Assert.AreEqual(0, results.PassCount, 'nothing passed');
  CheckResult(results, 'StaysIgnored', TTestResultType.Ignored);
end;

procedure TRunnerBehaviourTests.TearDownFixtureFailureIsReportedOnce;
var
  results : IRunResults;
begin
  results := RunFixture(BuildFixture(TRunnerTearDownFixtureFails));
  Assert.AreEqual(2, results.PassCount, 'both tests passed');
  Assert.AreEqual(1, results.ErrorCount, 'the teardown failure is one error');
  Assert.AreEqual(3, results.TestCount, 'no test is reported twice');
  CheckResult(results, 'PassesOne', TTestResultType.Pass);
  CheckResult(results, 'TearDownFixture', TTestResultType.Error, 'teardown fixture boom');
  Assert.IsFalse(results.AllPassed, 'the run did not pass');
end;

procedure TRunnerBehaviourTests.RaisingDestructorIsNotFreedTwice;
var
  passCount : Integer;
  errorCount : Integer;
begin
  Assert.WillNotRaiseAny(
    procedure
    var
      results : IRunResults;
    begin
      results := RunFixture(BuildFixture(TRunnerDestructorRaises));
      passCount := results.PassCount;
      errorCount := results.ErrorCount;
      //Releasing the results destroys the fixture, which used to free the instance a second time.
      results := nil;
    end, 'destroying the fixture');
  Assert.AreEqual(1, passCount, 'the test passed');
  Assert.AreEqual(1, errorCount, 'the raising destructor is reported once');
end;

procedure TRunnerBehaviourTests.RaisingConstructorErrorsOnlyItsFixture;
var
  fixture : ITestFixture;
  results : IRunResults;
begin
  GBodyRan := false;
  Assert.WillNotRaiseAny(
    procedure
    begin
      fixture := BuildFixture(TRunnerConstructorRaises);
    end, 'building a fixture whose constructor raises');
  results := RunFixture(fixture);
  Assert.IsFalse(GBodyRan, 'the test did not run');
  CheckResult(results, 'NeverRuns', TTestResultType.Error, 'constructor boom');
end;

procedure TRunnerBehaviourTests.SuppressedSetupFixtureIsReported;
var
  results : IRunResults;
begin
  GSetupFixtureRan := false;
  GWarnings := '';
  results := RunFixture(BuildFixture(TRunnerConstructorAndSetupFixture), TWarningLogger.Create);
  CheckResult(results, 'ConstructorRan', TTestResultType.Pass);
  Assert.IsFalse(GSetupFixtureRan, 'the constructor is the fixture setup');
  Assert.Contains(GWarnings, 'SetupFixture', False, 'the [SetupFixture] method that is not run is named');
end;

procedure TRunnerBehaviourTests.TearDownIsSkippedAfterSetupFails;
var
  results : IRunResults;
begin
  GTearDownRan := false;
  GBodyRan := false;
  results := RunFixture(BuildFixture(TRunnerSetupFails));
  Assert.IsFalse(GTearDownRan, 'TearDown did not run');
  Assert.IsFalse(GBodyRan, 'the test did not run');
  CheckResult(results, 'NeverRuns', TTestResultType.Error, 'setup boom');
end;

procedure TRunnerBehaviourTests.TearDownErrorDoesNotHideTestFailure;
var
  results : IRunResults;
begin
  results := RunFixture(BuildFixture(TRunnerTestAndTearDownFail));
  CheckResult(results, 'Fails', TTestResultType.Failure, 'teardown boom');
  Assert.StartsWith('test boom', FindResult(results, 'Fails').Message, False, 'the test''s own failure comes first');
end;

procedure TRunnerBehaviourTests.UnregisteredTestCaseProviderIsAnError;
var
  results : IRunResults;
begin
  results := RunFixture(BuildFixture(TRunnerUnknownProvider));
  Assert.AreEqual(1, results.TestCount, 'one result for the method');
  CheckResult(results, 'UsesAnUnregisteredProvider', TTestResultType.Error, 'DUnitX.Tests.NoSuchProvider');
end;

procedure TRunnerBehaviourTests.LeakCheckCountsOnlyTheTestsOwnGrowth;
var
  results : IRunResults;
  wrong : string;
  name : string;
begin
  TDUnitXServiceLocator.DefaultContainer.RegisterType<IMemoryLeakMonitor>(
    function : IMemoryLeakMonitor
    begin
      Result := TFakeLeakMonitor.Create;
    end);
  try
    results := RunFixture(BuildFixture(TRunnerLeakChecks), TFakeAllocatingLogger.Create);
  finally
    //The suite runs with the default monitor; put it back.
    DUnitX.MemoryLeakMonitor.Default.RegisterDefaultProvider;
  end;
  //Every case is reported, not only the first wrong one.
  wrong := '';
  for name in ['PassesWithAssertPass', 'LogsWhileRunning', 'FreesEarlierMemory'] do
    if FindResult(results, name).ResultType <> TTestResultType.Pass then
      wrong := wrong + name + ': ' + FindResult(results, name).Message + '; ';
  Assert.AreEqual('', wrong, False, 'reported as leaks');
  CheckResult(results, 'PassesWithAssertPass', TTestResultType.Pass, 'passed with a message');
  CheckResult(results, 'LeaksForReal', TTestResultType.MemoryLeak, '32');
end;

procedure TRunnerBehaviourTests.SuccessRateIsAPercentage;
var
  results : IRunResults;
begin
  results := RunFixture(BuildFixture(TRunnerThreeOfFourPass));
  Assert.AreEqual(4, results.TestCount, 'four tests');
  Assert.AreEqual(75, results.SuccessRate, 'three of four passed');
end;

procedure TRunnerBehaviourTests.RunWithNoExecutedTestsIsNotAllPassed;
var
  results : IRunResults;
begin
  results := TDUnitXRunResults.Create;
  (results as ITestExecuteContext).RollupResults;
  Assert.IsFalse(results.AllPassed, 'a run with no tests');

  results := RunFixture(BuildFixture(TRunnerAllIgnored));
  Assert.AreEqual(1, results.IgnoredCount, 'the test was ignored');
  Assert.IsFalse(results.AllPassed, 'a run whose only test was ignored');
end;

procedure TRunnerBehaviourTests.RerunBindsSetupToTheNewInstance;
var
  fixture : ITestFixture;
  results : IRunResults;
  blocker : Pointer;
begin
  fixture := BuildFixture(TRunnerSetupSeesTestInstance);
  results := RunFixture(fixture);
  CheckResult(results, 'SetupRanOnThisInstance', TTestResultType.Pass);
  //The first run freed the instance (its implicit TearDownFixture is the destructor). Occupy the freed block, so the
  //second run's instance cannot be allocated at the same address and hide a stale binding.
  blocker := AllocMem(TRunnerSetupSeesTestInstance.InstanceSize);
  try
    results := RunFixture(fixture);
    CheckResult(results, 'SetupRanOnThisInstance', TTestResultType.Pass);
  finally
    FreeMem(blocker);
  end;
end;

procedure TRunnerBehaviourTests.SecondRunnerOnAThreadStandsInAndRestoresTheFirst;
var
  outer : ITestRunner;
  inner : ITestRunner;

  //A separate function, so the compiler's hidden interface temporaries do not keep the second runner alive.
  function IsCurrent(const ARunner : ITestRunner) : boolean;
  begin
    Result := TDUnitX.CurrentRunner = ARunner;
  end;

begin
  outer := TDUnitX.CurrentRunner;
  Assert.WillNotRaiseAny(
    procedure
    begin
      inner := TDUnitXTestRunner.Create;
    end, 'creating a second runner on this thread');
  Assert.IsTrue(IsCurrent(inner), 'the second runner is current while it lives');
  inner := nil;
  Assert.IsTrue(IsCurrent(outer), 'the first runner is current again');
end;

{ TTestCaseAttribute }

procedure TTestCaseAttribute.ProcedureWithUntypedParameter(const Param1);
begin
  Assert.IsTrue(True);
end;

procedure TTestCaseAttribute.ProcedureWithByteParameter(const Value : Byte);
begin
end;

procedure TTestCaseAttribute.ProcedureWithTwoParameters(const First, Second : Integer);
begin
end;

initialization
  TDUnitX.RegisterTestFixture(TTestClassWithNonPublicSetup);
  TDUnitX.RegisterTestFixture(TTestClassWithTestSource);
  TDUnitX.RegisterTestFixture(TTestRepeatAttribute);
  TDUnitX.RegisterTestFixture(TTestMaxTimeAttribute);
  TDUnitX.RegisterTestFixture(TDUnitXTestFixtureTests);
  TDUnitX.RegisterTestFixture(TRunnerBehaviourTests);

end.

