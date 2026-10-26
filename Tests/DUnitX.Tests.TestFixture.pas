{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2012 Vincent Parrett                              }
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

unit DUnitX.Tests.TestFixture;

interface

uses
  DUnitX.TestFramework,
  DUnitX.TestFixture;

const
  /// <summary>Repeat count for TestRepeat3Times; TearDownFixture checks the test ran exactly this often.</summary>
  TIMES_RUN         = 3;
  /// <summary>Repeat count for the published TestRepeat5TimesAnyWay; checked in TearDownFixture.</summary>
  TIMES_RUN_ANYWAY  = 5;
  /// <summary>Repeat count for the Sum test case; checked in TearDownFixture.</summary>
  TIMES_RUN_TEST_CASE = 2;

type
{$M+}
  /// <summary>
  ///   Fixture whose [Setup] method is protected rather than public, to prove the runner finds and calls attributed
  ///   methods of any visibility RTTI can see. It has no tests of its own.
  /// </summary>
  [TestFixture]
  TTestClassWithNonPublicSetup = class
  private
    /// <summary>Set when Setup runs.</summary>
    FSetupRun : Boolean;
  protected
    /// <summary>
    ///   Protected per-test setup; records that it ran.
    /// </summary>
    [Setup]
    procedure Setup;
  public
    /// <summary>
    ///   Creates the fixture with SetupRun False.
    /// </summary>
    constructor Create;
    /// <summary>True once Setup has run.</summary>
    property SetupRun : Boolean read FSetupRun;
  end;
{$M-}

  /// <summary>
  ///   Custom test-case source attribute: supplies three cases, 'DataTest0' to 'DataTest2', with values 0 to 2.
  /// </summary>
  MockTestSourceAttribute = class(CustomTestCaseSourceAttribute)
  protected
    /// <summary>
    ///   Builds the three cases.
    /// </summary>
    /// <returns>
    ///   Three case infos, each with one integer value equal to its index.
    /// </returns>
    function GetCaseInfoArray : TestCaseInfoArray; override;
  end;

{$M+}
  /// <summary>
  ///   Proves a CustomTestCaseSourceAttribute descendant generates test cases for the method it decorates.
  /// </summary>
  [TestFixture]
  TTestClassWithTestSource = class
  public
    /// <summary>
    ///   Proves each case from MockTestSource runs with its own value, which must lie in 0..2.
    /// </summary>
    /// <param name="Value">
    ///   The case's value from the source attribute.
    /// </param>
    [Test]
    [MockTestSource]
    procedure DataTest(Value : Integer);
  end;
{$M-}

{$M+}
  /// <summary>
  ///   Proves [RepeatTest]: a test runs the requested number of times (plain, with a [TestCase], and published
  ///   without [Test]), and a count of zero means the test is not run. The counts are checked in TearDownFixture.
  /// </summary>
  [TestFixture]
  TTestRepeatAttribute = class
  public
    /// <summary>
    ///   Fixture setup: zeroes the run counters.
    /// </summary>
    [SetUpFixture]
    procedure SetUpFixture;

    /// <summary>
    ///   Fixture teardown: asserts each repeated test ran exactly its requested number of times.
    /// </summary>
    /// <exception cref="ETestFailure">
    ///   Raised (via Assert) when a repeat count is wrong.
    /// </exception>
    [TearDownFixture]
    procedure TearDownFixture;

    /// <summary>
    ///   Counts its runs; proves [RepeatTest(TIMES_RUN)] runs it TIMES_RUN times.
    /// </summary>
    [Test]
    [RepeatTest(TIMES_RUN)]
    procedure TestRepeat3Times;

    /// <summary>
    ///   Counts its runs; proves [RepeatTest] combined with a [TestCase] repeats the case, and the case's values
    ///   still arrive (A + B = Expected).
    /// </summary>
    /// <param name="A">
    ///   First addend.
    /// </param>
    /// <param name="B">
    ///   Second addend.
    /// </param>
    /// <param name="Expected">
    ///   Expected sum.
    /// </param>
    [RepeatTest(TIMES_RUN_TEST_CASE)]
    [Test]
    [TestCase('Sum Case', '1,2,3')]
    procedure Sum(const A, B, Expected : Integer);

    /// <summary>
    ///   Proves [RepeatTest(0)] means the test is not run; it fails if called.
    /// </summary>
    [Test]
    [RepeatTest(0)]
    procedure IgnoreMeWhenRepeatIsZero;
  published
    /// <summary>
    ///   Counts its runs; proves [RepeatTest] is honoured on a published test without [Test].
    /// </summary>
    [RepeatTest(TIMES_RUN_ANYWAY)]
    procedure TestRepeat5TimesAnyWay;

    /// <summary>
    ///   Proves [RepeatTest(0)] is honoured on a published test too; it fails if called.
    /// </summary>
    [Test]
    [RepeatTest(0)]
    procedure IgnoreMeAnyWayWhenRepeatIsZero;
  end;
{$M-}

{$M+}
  /// <summary>
  ///   Tests for [MaxTime] as seen from inside the suite: zero means no limit, and a fast test passes. Overruns are
  ///   proved through a private runner in TRunnerBehaviourTests.
  /// </summary>
  [TestFixture]
  TTestMaxTimeAttribute = class
  public
    /// <summary>
    ///   Proves [MaxTime(0)] means no limit: a 100 ms test passes.
    /// </summary>
    [Test]
    [MaxTime(0)]
    procedure MaxTimeIsZero;

    /// <summary>
    ///   Ignored: would prove a 150 ms test under [MaxTime(100)] times out. It is ignored because a timeout fails the
    ///   test itself; TRunnerBehaviourTests.MaxTimeOverrunIsCaughtWhateverTheTiming proves this through a private
    ///   runner instead.
    /// </summary>
    [Test, Ignore]
    [MaxTime(100)]
    procedure TestTimeout;

    /// <summary>
    ///   Proves a test that finishes well inside [MaxTime(100)] passes.
    /// </summary>
    [Test]
    [MaxTime(100)]
    procedure TestDoesNotTimeout;
  end;
{$M-}

  /// <summary>
  ///   Not a fixture: a holder of methods with awkward signatures that the fixture tests turn into test cases by
  ///   RTTI.
  /// </summary>
  TTestCaseAttribute = class
  public
    /// <summary>
    ///   Method with an untyped parameter, which RTTI cannot describe.
    /// </summary>
    /// <param name="Param1">
    ///   Untyped; never read.
    /// </param>
    procedure ProcedureWithUntypedParameter(const Param1);
    /// <summary>
    ///   Method with a Byte parameter, to prove an out-of-range case value errors.
    /// </summary>
    /// <param name="Value">
    ///   The case value; never read.
    /// </param>
    procedure ProcedureWithByteParameter(const Value : Byte);
    /// <summary>
    ///   Method with two integer parameters, to prove too few, too many and non-numeric case values error.
    /// </summary>
    /// <param name="First">
    ///   First case value; never read.
    /// </param>
    /// <param name="Second">
    ///   Second case value; never read.
    /// </param>
    procedure ProcedureWithTwoParameters(const First, Second : Integer);
  end;

{$M+}
  /// <summary>
  ///   Tests for <c>TDUnitXTestFixture</c> built directly by RTTI: adding test cases with bad or awkward data, and
  ///   the name filters' matching.
  /// </summary>
  [TestFixture]
  TDUnitXTestFixtureTests = class
  public
    /// <summary>
    ///   Proves adding a test case for a method with an untyped parameter does not raise, so one unsupported
    ///   signature cannot abort building the run.
    /// </summary>
    [Test]
    procedure WhenATestCaseHasAUntypedParameterCantRaiseAnyError;
    /// <summary>
    ///   Proves that bad [TestCase] data (a value that does not convert, too few or too many values) makes that case
    ///   report an error naming the case, parameter and value when it runs, instead of running with 0 / defaults,
    ///   and that building the case does not raise (which would abort the whole run).
    /// </summary>
    [Test]
    procedure WhenATestCaseValueIsInvalidTheCaseErrors;
    /// <summary>
    ///   Proves that TFullNameFilter (the GUI runner's Run / Run Selected filter) matches a test only by its exact
    ///   full name, case-sensitively: neither a test of another fixture whose full name merely starts with the
    ///   checked test's name, nor a test whose own name starts with it, runs.
    /// </summary>
    [Test]
    procedure FullNameFilterMatchesOnlyTheExactTest;
  end;
{$M-}

{$M+}
  /// <summary>
  ///   Tests of the runner's behaviour, each driving a private TDUnitXTestRunner over the unregistered fixtures
  ///   declared in this unit's implementation section and asserting on the results it reports.
  /// </summary>
  [TestFixture]
  TRunnerBehaviourTests = class
  public
    /// <summary>
    ///   Proves that a runner created on a thread that already has an active runner (a runner driven from inside a
    ///   test) does not raise EListError, stands in as the current runner, and hands the thread back to the first
    ///   runner when it is destroyed. The old registry raised, and the failing constructor's destructor removed the
    ///   FIRST runner's entry.
    /// </summary>
    [Test]
    procedure SecondRunnerOnAThreadStandsInAndRestoresTheFirst;
    /// <summary>
    ///   Proves that [WillRaise] and [MaxTime] on a method with [TestCase] are enforced for each case: a case that
    ///   does not raise, and a case that overruns, both fail. They were dropped when the case was created.
    /// </summary>
    [Test]
    procedure TestCasesKeepWillRaiseAndMaxTime;
    /// <summary>
    ///   Proves that a [MaxTime(100)] test whose body takes 115 ms fails. The old watchdog polled every 20 ms (in
    ///   practice up to ~31 ms) from its own thread, so an overrun that ended between two polls passed.
    /// </summary>
    [Test]
    procedure MaxTimeOverrunIsCaughtWhateverTheTiming;
    /// <summary>
    ///   Proves that a [WillRaise(Exception, exDescendant)] test whose body fails an assertion is reported as a
    ///   failure, not as "raised as expected".
    /// </summary>
    [Test]
    procedure FailingAssertInWillRaiseTestIsAFailure;
    /// <summary>
    ///   Proves that running a [WillRaise] test does not keep the run results alive once released. The test kept the
    ///   execute context (the run results), which hold the fixture, which holds the test: a cycle that leaked the
    ///   run.
    /// </summary>
    [Test]
    procedure ExceptionTestDoesNotKeepTheRunResultsAlive;
    /// <summary>
    ///   Proves that [RepeatTest] repetitions, plain and with [TestCase], get the [Setup] declared in a base class and
    ///   run it on the same instance as the test. Repetitions used to get a child fixture whose Setup was copied
    ///   before the base class's [Setup] had been seen (so none ran), and test cases ran on the child's own instance.
    /// </summary>
    [Test]
    procedure RepeatedTestsRunWithTheirSetupOnTheirInstance;
    /// <summary>
    ///   Proves that when [SetupFixture] fails no test of the fixture runs, repetitions included, each is reported as
    ///   an error, and an [Ignore]d test is still reported as ignored rather than as an error.
    /// </summary>
    [Test]
    procedure AfterSetupFixtureFailsNothingRunsAndIgnoredStayIgnored;
    /// <summary>
    ///   Proves that a failing [TearDownFixture] is reported once, as its own error, and that the tests that already
    ///   passed are not reported a second time as errors.
    /// </summary>
    [Test]
    procedure TearDownFixtureFailureIsReportedOnce;
    /// <summary>
    ///   Proves that a fixture whose destructor (its implicit TearDownFixture) raises is not freed a second time when
    ///   the fixture is destroyed.
    /// </summary>
    [Test]
    procedure RaisingDestructorIsNotFreedTwice;
    /// <summary>
    ///   Proves that a fixture constructor that raises does not abort building the fixtures, and that the fixture's
    ///   tests are then reported as errors carrying the constructor's message.
    /// </summary>
    [Test]
    procedure RaisingConstructorErrorsOnlyItsFixture;
    /// <summary>
    ///   Proves that when a parameterless constructor takes the place of a [SetupFixture] method (upstream's
    ///   documented behaviour, see TExampleFixture3), the runner logs a warning naming the method instead of dropping
    ///   it silently.
    /// </summary>
    [Test]
    procedure SuppressedSetupFixtureIsReported;
    /// <summary>
    ///   Proves that TearDown does not run after a failed Setup, so the Setup error is the one reported.
    /// </summary>
    [Test]
    procedure TearDownIsSkippedAfterSetupFails;
    /// <summary>
    ///   Proves that when a test fails and its TearDown then fails too, the result stays a failure whose message
    ///   starts with the test's own message and also carries the TearDown error.
    /// </summary>
    [Test]
    procedure TearDownErrorDoesNotHideTestFailure;
    /// <summary>
    ///   Proves that a [TestCaseProvider] naming an unregistered provider produces an error naming it, rather than
    ///   silently producing no tests.
    /// </summary>
    [Test]
    procedure UnregisteredTestCaseProviderIsAnError;
    /// <summary>
    ///   Proves the leak check, with a monitor that counts simulated allocations: memory held by the runner's own log
    ///   lists, and the ETestPass object raised by a pass, are not leaks; a test that frees earlier memory (a
    ///   negative delta) is not a leak; a real allocation still is.
    /// </summary>
    [Test]
    procedure LeakCheckCountsOnlyTheTestsOwnGrowth;
    /// <summary>
    ///   Proves the leak check measures the whole span from setup to teardown: memory that setup or the test
    ///   allocates and that is freed between phases (here by a logger, standing in for the runner releasing
    ///   references or another thread finishing) is not a leak; a real allocation still is, with setup and teardown
    ///   present.
    /// </summary>
    [Test]
    procedure LeakCheckIgnoresMemoryFreedBetweenPhases;
    /// <summary>
    ///   Proves that SuccessRate is a percentage (3 of 4 passing is 75), not 0 or 100.
    /// </summary>
    [Test]
    procedure SuccessRateIsAPercentage;
    /// <summary>
    ///   Proves that a run in which no test executed (none at all, or all ignored) is not reported as all passed.
    /// </summary>
    [Test]
    procedure RunWithNoExecutedTestsIsNotAllPassed;
    /// <summary>
    ///   Proves that when a fixture is run again (as the GUI runner does) after its instance was freed, Setup runs on
    ///   the new instance, not on the freed one.
    /// </summary>
    [Test]
    procedure RerunBindsSetupToTheNewInstance;
    /// <summary>
    ///   Proves that an override of an attributed virtual method runs, not the ancestor's code: an override of
    ///   [Setup] and of [Test] that does not repeat the attribute is what executes, and a test overridden in a
    ///   published section is one test, not two. The provider bound the ancestor's static code address.
    /// </summary>
    [Test]
    procedure OverridesOfAttributedMethodsRunOnce;
    /// <summary>
    ///   Proves that a [MaxTime] test that overruns and then calls Assert.Pass fails. The ETestPass raised by
    ///   Assert.Pass skipped the timeout check.
    /// </summary>
    [Test]
    procedure MaxTimeOverrunEndingInAssertPassFails;
    /// <summary>
    ///   Proves that [SetupFixture] does not run when no test of the fixture will execute: the only selected test is
    ///   ignored and the other is filtered out.
    /// </summary>
    [Test]
    procedure SetupFixtureSkippedWhenNoTestWillExecute;
    /// <summary>
    ///   Proves that each result carries the log of its own test and setup only: a Setup failure does not carry the
    ///   previous failing test's log, and what Setup logged is kept on the result.
    /// </summary>
    [Test]
    procedure ResultsCarryOnlyTheirOwnLog;
    /// <summary>
    ///   Proves that what a logger keeps in its per-test callbacks (end of setup, test start, teardown start) is not
    ///   counted as the test's leak.
    /// </summary>
    [Test]
    procedure LoggerStateIsNotATestLeak;
    /// <summary>
    ///   Proves that TNameFilter (the command line's --run) matches a fixture name only as a whole name segment:
    ///   naming Unit.TCustomer does not select Unit.TCustomerOrder, and naming a test method selects its test cases.
    /// </summary>
    [Test]
    procedure NameFilterMatchesWholeNameSegments;
    /// <summary>
    ///   Proves the fixture list the runner sorts is ordered by full name at every level, children included. Sort
    ///   reached the generic list's default comparer, which orders interface pointers, so the run order followed
    ///   heap addresses.
    /// </summary>
    [Test]
    procedure FixtureListSortsByNameAtEveryLevel;
    /// <summary>
    ///   Proves the run results' fixture list holds the fixture of each recorded fixture result: it returned a field
    ///   that was never assigned, so it was always nil.
    /// </summary>
    [Test]
    procedure RunResultsListTheRunFixtures;
    /// <summary>
    ///   Proves a fixture's ITestInfo list grows when a test is added after the list was first read: it was built once
    ///   and then returned stale, so tests the provider added later (error tests) were missing from it.
    /// </summary>
    [Test]
    procedure FixtureTestInfoListFollowsAddedTests;
    /// <summary>
    ///   Proves TNameFilter built from a list of names ('--run:a,,b') stores only the distinct non-empty names (read
    ///   through RTTI, as nothing publishes them): the list overloads bypassed the single-name Add and stored empty
    ///   and duplicate names, and an empty name matches a fixture with an empty name, which no --run asked for.
    /// </summary>
    [Test]
    procedure NameFilterListDropsEmptyAndDuplicateNames;
    /// <summary>
    ///   Proves a test error whose result message differs from the exception's message keeps the two on separate
    ///   lines (they used to be run together), and that an exception DESCENDED from ETestFailureStrCompare is
    ///   comparable and carries its expected and actual values (only the exact class used to be).
    /// </summary>
    [Test]
    procedure TestErrorSeparatesMessagesAndAcceptsStrCompareDescendants;
  end;
{$M-}

implementation

uses
{$IFDEF USE_NS}
  System.Math,
  System.SysUtils,
  System.Rtti,
  System.Generics.Collections,
{$ELSE}
  System.Math,
  System.SysUtils,
  System.Rtti,
  System.Generics.Collections,
{$ENDIF}
  DUnitX.Types,
  DUnitX.Extensibility,
  DUnitX.InternalInterfaces,
  DUnitX.TestRunner,
{$IFDEF USE_NS}
  System.Classes,
{$ELSE}
  System.Classes,
{$ENDIF}
  DUnitX.Exceptions,
  DUnitX.FixtureProvider,
  DUnitX.RunResults,
  DUnitX.ServiceLocator,
  DUnitX.Loggers.Null,
  DUnitX.Filters,
  DUnitX.TestResult,
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
  Assert.IsFalse(filter.Match(TestB), 'TNameFilter does not match a fixture whose name merely starts with the name');

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
  /// <summary>Simulated heap size read by TFakeLeakMonitor; fixtures and loggers add to or subtract from it.</summary>
  GFakeAllocated : Int64;
  /// <summary>What setup allocated that TGapFreeingLogger frees before the test starts.</summary>
  GSetupGapFree : Int64;
  /// <summary>What the test allocated that TGapFreeingLogger frees before teardown starts.</summary>
  GTestGapFree : Int64;
  /// <summary>Set if TRunnerConstructorAndSetupFixture's suppressed [SetupFixture] ran.</summary>
  GSetupFixtureRan : boolean;
  /// <summary>Set if TRunnerSetupFails's TearDown ran after its failed Setup.</summary>
  GTearDownRan : boolean;
  /// <summary>Set by any test body that must not run.</summary>
  GBodyRan : boolean;
  /// <summary>The instance TRunnerSetupSeesTestInstance's Setup ran on.</summary>
  GSetupInstance : TObject;
  /// <summary>Warning messages collected by TWarningLogger, one per line.</summary>
  GWarnings : string;
  /// <summary>Number of times TRunnerFixtureSetupCount's [SetupFixture] ran.</summary>
  GSetupFixtureCalls : Integer;
  /// <summary>Number of times TRunnerLogAttribution's Setup ran; the second call raises.</summary>
  GLogSetupCalls : Integer;

type
{$M+}
  /// <summary>
  ///   Runner fixture for per-case and per-test attribute enforcement: [WillRaise] and [MaxTime] combined with
  ///   [TestCase], a 115 ms overrun of [MaxTime(100)], and an assertion failure inside a [WillRaise] test.
  /// </summary>
  TRunnerCaseAttributes = class
  public
    /// <summary>
    ///   Case that must fail: it expects EArgumentOutOfRangeException but raises nothing.
    /// </summary>
    /// <param name="AValue">
    ///   The case value; unused.
    /// </param>
    [Test]
    [TestCase('DoesNotRaise', '1')]
    [WillRaise(EArgumentOutOfRangeException)]
    procedure CaseExpectedToRaise(const AValue : Integer);
    /// <summary>
    ///   Case that must fail: it sleeps 150 ms under [MaxTime(100)].
    /// </summary>
    /// <param name="ADelay">
    ///   Milliseconds to sleep.
    /// </param>
    [Test]
    [TestCase('Slow', '150')]
    [MaxTime(100)]
    procedure CaseOverItsMaxTime(const ADelay : Integer);
    /// <summary>
    ///   Test that must fail: it sleeps 115 ms under [MaxTime(100)], an overrun the old 20 ms poll could miss.
    /// </summary>
    [Test]
    [MaxTime(100)]
    procedure OverItsMaxTimeBetweenPolls;
    /// <summary>
    ///   Test that must be a failure, not an expected raise: it fails an assertion under
    ///   [WillRaise(Exception, exDescendant)].
    /// </summary>
    [Test]
    [WillRaise(Exception, exDescendant)]
    procedure FailingAssertIsNotTheExpectedRaise;
  end;

  /// <summary>
  ///   Runner fixture with a [WillRaise] test that raises as expected, used to check the run results are not kept
  ///   alive by the exception-test path.
  /// </summary>
  TRunnerRaisesAsExpected = class
  public
    /// <summary>
    ///   Raises the EInvalidOpException it declares, so it passes.
    /// </summary>
    /// <exception cref="EInvalidOpException">
    ///   Always; the expected exception.
    /// </exception>
    [Test]
    [WillRaise(EInvalidOpException)]
    procedure Raises;
  end;

  /// <summary>
  ///   Base class declaring the [Setup] that TRunnerRepeatWithBaseSetup's repeated tests must inherit.
  /// </summary>
  TRunnerSetupBase = class
  protected
    /// <summary>Set by Setup; each test asserts and clears it, so every repetition needs its own Setup.</summary>
    FSetupDone : boolean;
  public
    /// <summary>
    ///   Inherited per-test setup; sets FSetupDone.
    /// </summary>
    [Setup]
    procedure Setup;
  end;

  /// <summary>
  ///   Runner fixture whose repeated tests, plain and with a [TestCase], must each see the base class's Setup run on
  ///   their own instance.
  /// </summary>
  TRunnerRepeatWithBaseSetup = class(TRunnerSetupBase)
  public
    /// <summary>
    ///   Repeated three times; fails on any repetition whose Setup did not run on this instance.
    /// </summary>
    [Test]
    [RepeatTest(3)]
    procedure RepeatedTestSeesItsSetup;
    /// <summary>
    ///   A test case repeated twice; fails on any repetition whose Setup did not run on this instance.
    /// </summary>
    /// <param name="AValue">
    ///   The case value; unused.
    /// </param>
    [Test]
    [RepeatTest(2)]
    [TestCase('One', '1')]
    procedure RepeatedCaseSeesItsSetup(const AValue : Integer);
  end;

  /// <summary>
  ///   Runner fixture whose [SetupFixture] raises: no test may run, repetitions included, and the ignored test must
  ///   still be reported as ignored.
  /// </summary>
  TRunnerSetupFixtureFails = class
  public
    /// <summary>
    ///   Fixture setup that fails.
    /// </summary>
    /// <exception cref="Exception">
    ///   Always ('setup fixture boom').
    /// </exception>
    [SetupFixture]
    procedure SetupFixture;
    /// <summary>
    ///   Must not run; sets GBodyRan if it does.
    /// </summary>
    [Test]
    procedure NotRun;
    /// <summary>
    ///   Repeated test that must not run in any repetition; sets GBodyRan if it does.
    /// </summary>
    [Test]
    [RepeatTest(2)]
    procedure NotRunEither;
    /// <summary>
    ///   Ignored test that must be reported as ignored, not as an error; sets GBodyRan if it runs.
    /// </summary>
    [Test]
    [Ignore('stays ignored')]
    procedure StaysIgnored;
  end;

  /// <summary>
  ///   Runner fixture whose [TearDownFixture] raises after two passing tests: the failure must be reported once and
  ///   the passes must stay passes.
  /// </summary>
  TRunnerTearDownFixtureFails = class
  public
    /// <summary>
    ///   Fixture teardown that fails.
    /// </summary>
    /// <exception cref="Exception">
    ///   Always ('teardown fixture boom').
    /// </exception>
    [TearDownFixture]
    procedure TearDownFixture;
    /// <summary>
    ///   Passes (empty body).
    /// </summary>
    [Test]
    procedure PassesOne;
    /// <summary>
    ///   Passes (empty body).
    /// </summary>
    [Test]
    procedure PassesTwo;
  end;

  /// <summary>
  ///   Runner fixture whose destructor raises, to prove the fixture instance is not freed a second time.
  /// </summary>
  TRunnerDestructorRaises = class
  public
    /// <summary>
    ///   Raises without calling the inherited destructor.
    /// </summary>
    /// <exception cref="Exception">
    ///   Always ('destructor boom').
    /// </exception>
    destructor Destroy; override;
    /// <summary>
    ///   Passes (empty body).
    /// </summary>
    [Test]
    procedure Passes;
  end;

  /// <summary>
  ///   Runner fixture whose constructor raises, so its tests must be reported as errors carrying that message.
  /// </summary>
  TRunnerConstructorRaises = class
  public
    /// <summary>
    ///   Fails construction.
    /// </summary>
    /// <exception cref="Exception">
    ///   Always ('constructor boom').
    /// </exception>
    constructor Create;
    /// <summary>
    ///   Must not run; sets GBodyRan if it does.
    /// </summary>
    [Test]
    procedure NeverRuns;
  end;

  /// <summary>
  ///   Runner fixture with both a parameterless constructor and a [SetupFixture] method, so the runner must warn that
  ///   the method is suppressed.
  /// </summary>
  TRunnerConstructorAndSetupFixture = class
  public
    /// <summary>
    ///   Parameterless constructor that takes the place of fixture setup.
    /// </summary>
    constructor Create;
    /// <summary>
    ///   Suppressed by the constructor; sets GSetupFixtureRan if it runs.
    /// </summary>
    [SetupFixture]
    procedure SetupFixture;
    /// <summary>
    ///   Passes (empty body); gives the fixture a test to run.
    /// </summary>
    [Test]
    procedure ConstructorRan;
  end;

  /// <summary>
  ///   Runner fixture whose [Setup] raises: the test must not run and TearDown must be skipped.
  /// </summary>
  TRunnerSetupFails = class
  public
    /// <summary>
    ///   Per-test setup that fails.
    /// </summary>
    /// <exception cref="Exception">
    ///   Always ('setup boom').
    /// </exception>
    [Setup]
    procedure Setup;
    /// <summary>
    ///   Must not run after the failed Setup; sets GTearDownRan and raises if it does.
    /// </summary>
    /// <exception cref="Exception">
    ///   Always ('teardown boom'), so running it would replace the Setup error.
    /// </exception>
    [TearDown]
    procedure TearDown;
    /// <summary>
    ///   Must not run; sets GBodyRan if it does.
    /// </summary>
    [Test]
    procedure NeverRuns;
  end;

  /// <summary>
  ///   Runner fixture where the test fails and then TearDown raises: the result must remain the test's failure.
  /// </summary>
  TRunnerTestAndTearDownFail = class
  public
    /// <summary>
    ///   Per-test teardown that fails.
    /// </summary>
    /// <exception cref="Exception">
    ///   Always ('teardown boom').
    /// </exception>
    [TearDown]
    procedure TearDown;
    /// <summary>
    ///   Fails with 'test boom'.
    /// </summary>
    /// <exception cref="ETestFailure">
    ///   Always, via Assert.Fail.
    /// </exception>
    [Test]
    procedure Fails;
  end;

  /// <summary>
  ///   Runner fixture naming a test-case provider that was never registered.
  /// </summary>
  TRunnerUnknownProvider = class
  public
    /// <summary>
    ///   Must produce an error naming 'DUnitX.Tests.NoSuchProvider' rather than no tests.
    /// </summary>
    /// <param name="AValue">
    ///   Would come from the provider; unused.
    /// </param>
    [Test]
    [TestCaseProvider('DUnitX.Tests.NoSuchProvider')]
    procedure UsesAnUnregisteredProvider(const AValue : Integer);
  end;

  /// <summary>
  ///   Runner fixture for the leak check's arithmetic, measured by TFakeLeakMonitor over GFakeAllocated.
  /// </summary>
  TRunnerLeakChecks = class
  public
    /// <summary>
    ///   Passes by raising ETestPassCounted, whose own 100 simulated bytes must not count as a leak.
    /// </summary>
    /// <exception cref="ETestPassCounted">
    ///   Always; the simulated Assert.Pass.
    /// </exception>
    [Test]
    procedure PassesWithAssertPass;
    /// <summary>
    ///   Logs a status line, whose storage in the runner's log list must not count as a leak.
    /// </summary>
    [Test]
    procedure LogsWhileRunning;
    /// <summary>
    ///   Frees 64 simulated bytes allocated earlier; a negative delta must not count as a leak.
    /// </summary>
    [Test]
    procedure FreesEarlierMemory;
    /// <summary>
    ///   Allocates 32 simulated bytes and keeps them; must be reported as a leak.
    /// </summary>
    [Test]
    procedure LeaksForReal;
  end;

  /// <summary>
  ///   Runner fixture whose setup and test allocate memory that TGapFreeingLogger frees between phases, to prove the
  ///   leak check spans setup to teardown as a whole.
  /// </summary>
  TRunnerGapLeakChecks = class
  public
    /// <summary>
    ///   Allocates 500 simulated bytes that the logger frees before the test starts.
    /// </summary>
    [Setup]
    procedure Setup;
    /// <summary>
    ///   Empty; present so the teardown phase is measured too.
    /// </summary>
    [TearDown]
    procedure TearDown;
    /// <summary>
    ///   Allocates 1000 simulated bytes that the logger frees before teardown; must not be a leak.
    /// </summary>
    [Test]
    procedure FreedBetweenPhases;
    /// <summary>
    ///   Allocates 32 simulated bytes and keeps them; must be reported as a leak.
    /// </summary>
    [Test]
    procedure LeaksForReal;
  end;

  /// <summary>
  ///   Runner fixture with three passing tests and one failing, for the SuccessRate percentage.
  /// </summary>
  TRunnerThreeOfFourPass = class
  public
    /// <summary>Passes (empty body).</summary>
    [Test]
    procedure PassOne;
    /// <summary>Passes (empty body).</summary>
    [Test]
    procedure PassTwo;
    /// <summary>Passes (empty body).</summary>
    [Test]
    procedure PassThree;
    /// <summary>
    ///   Fails via Assert.Fail.
    /// </summary>
    /// <exception cref="ETestFailure">
    ///   Always.
    /// </exception>
    [Test]
    procedure Fails;
  end;

  /// <summary>
  ///   Runner fixture whose only test is ignored, so the run executes nothing.
  /// </summary>
  TRunnerAllIgnored = class
  public
    /// <summary>Ignored test (empty body).</summary>
    [Test]
    [Ignore('ignored')]
    procedure Ignored;
  end;

  /// <summary>
  ///   Runner fixture that records which instance Setup ran on, so a rerun after the instance is freed can be
  ///   checked to bind Setup to the new instance.
  /// </summary>
  TRunnerSetupSeesTestInstance = class
  public
    /// <summary>
    ///   Records Self in GSetupInstance.
    /// </summary>
    [Setup]
    procedure Setup;
    /// <summary>
    ///   Fails unless Setup ran on this same instance.
    /// </summary>
    [Test]
    procedure SetupRanOnThisInstance;
  end;

  /// <summary>
  ///   Declares the attributed, virtual methods that TRunnerVirtualDerived overrides without repeating the
  ///   attributes; its own test bodies fail if they run.
  /// </summary>
  TRunnerVirtualBase = class
  protected
    /// <summary>Set by the overriding Setup; the overriding tests assert it.</summary>
    FOverridingSetupRan : boolean;
  public
    /// <summary>
    ///   Attributed virtual setup; clears FOverridingSetupRan.
    /// </summary>
    [Setup]
    procedure Setup; virtual;
    /// <summary>
    ///   Attributed virtual test; fails if this ancestor body runs instead of the override.
    /// </summary>
    [Test]
    procedure RunsTheOverride; virtual;
    /// <summary>
    ///   Attributed virtual test overridden in a published section; fails if this ancestor body runs.
    /// </summary>
    [Test]
    procedure OverriddenInPublished; virtual;
  end;

  /// <summary>
  ///   Runner fixture overriding TRunnerVirtualBase's attributed methods without the attributes: the overrides are
  ///   what must run, once each.
  /// </summary>
  TRunnerVirtualDerived = class(TRunnerVirtualBase)
  public
    /// <summary>
    ///   Calls the inherited Setup, then sets FOverridingSetupRan.
    /// </summary>
    procedure Setup; override;
    /// <summary>
    ///   Passes only if the overriding Setup ran.
    /// </summary>
    procedure RunsTheOverride; override;
  published
    /// <summary>
    ///   Passes only if the overriding Setup ran; being published must not make it a second test.
    /// </summary>
    procedure OverriddenInPublished; override;
  end;

  /// <summary>
  ///   Runner fixture whose test overruns [MaxTime(50)] and then calls Assert.Pass; it must still fail.
  /// </summary>
  TRunnerSlowPass = class
  public
    /// <summary>
    ///   Sleeps 120 ms, then calls Assert.Pass.
    /// </summary>
    /// <exception cref="ETestPass">
    ///   Always, via Assert.Pass.
    /// </exception>
    [Test]
    [MaxTime(50)]
    procedure OverItsMaxTimeThenPasses;
  end;

  /// <summary>
  ///   Runner fixture whose [SetupFixture] counts its calls; run with a filter so that no test will execute.
  /// </summary>
  TRunnerFixtureSetupCount = class
  public
    /// <summary>
    ///   Increments GSetupFixtureCalls; must not run when no test will execute.
    /// </summary>
    [SetupFixture]
    procedure SetupFixture;
    /// <summary>Excluded by the run's filter (empty body).</summary>
    [Test]
    procedure FilteredOut;
    /// <summary>Selected by the filter but ignored (empty body).</summary>
    [Test]
    [Ignore('ignored')]
    procedure IgnoredButSelected;
  end;

  /// <summary>
  ///   Setup logs on every call and raises on its second, so one test fails in Setup after the other has logged.
  /// </summary>
  TRunnerLogAttribution = class
  public
    /// <summary>
    ///   Logs 'logged in setup'; raises on its second call.
    /// </summary>
    /// <exception cref="EInvalidOpException">
    ///   On the second call ('second setup fails').
    /// </exception>
    [Setup]
    procedure Setup;
    /// <summary>
    ///   Logs, then fails.
    /// </summary>
    /// <exception cref="ETestFailure">
    ///   Always, via Assert.Fail.
    /// </exception>
    [Test]
    procedure TestOne;
    /// <summary>
    ///   Logs, then fails (if its Setup lets it run).
    /// </summary>
    /// <exception cref="ETestFailure">
    ///   Always, via Assert.Fail.
    /// </exception>
    [Test]
    procedure TestTwo;
  end;

  /// <summary>
  ///   Runner fixture with empty setup and teardown and a passing test, so every per-test logger callback fires.
  /// </summary>
  TRunnerSetupAndTearDown = class
  public
    /// <summary>Empty per-test setup.</summary>
    [Setup]
    procedure Setup;
    /// <summary>Empty per-test teardown.</summary>
    [TearDown]
    procedure TearDown;
    /// <summary>
    ///   Passes via Assert.Pass.
    /// </summary>
    /// <exception cref="ETestPass">
    ///   Always, via Assert.Pass.
    /// </exception>
    [Test]
    procedure Passes;
  end;
{$M-}

  /// <summary>
  ///   Simulates the ETestPass that Assert.Pass raises, counting its own memory (100 simulated bytes) as a real one
  ///   would.
  /// </summary>
  ETestPassCounted = class(ETestPass)
  public
    /// <summary>
    ///   Creates the exception and adds 100 to GFakeAllocated.
    /// </summary>
    /// <param name="AMessage">
    ///   The pass message.
    /// </param>
    constructor Create(const AMessage : string);
    /// <summary>
    ///   Subtracts the 100 bytes again.
    /// </summary>
    destructor Destroy; override;
  end;

  /// <summary>
  ///   Leak monitor that measures GFakeAllocated, so a test can simulate allocations precisely.
  /// </summary>
  TFakeLeakMonitor = class(TInterfacedObject, IMemoryLeakMonitor)
  private
    /// <summary>GFakeAllocated before setup.</summary>
    FPreSetup : Int64;
    /// <summary>GFakeAllocated after setup.</summary>
    FPostSetup : Int64;
    /// <summary>GFakeAllocated before the test.</summary>
    FPreTest : Int64;
    /// <summary>GFakeAllocated after the test.</summary>
    FPostTest : Int64;
    /// <summary>GFakeAllocated before teardown.</summary>
    FPreTearDown : Int64;
    /// <summary>GFakeAllocated after teardown.</summary>
    FPostTearDown : Int64;
  public
    /// <summary>Records GFakeAllocated before setup.</summary>
    procedure PreSetup;
    /// <summary>Records GFakeAllocated after setup.</summary>
    procedure PostSetUp;
    /// <summary>Records GFakeAllocated before the test.</summary>
    procedure PreTest;
    /// <summary>Records GFakeAllocated after the test.</summary>
    procedure PostTest;
    /// <summary>Records GFakeAllocated before teardown.</summary>
    procedure PreTearDown;
    /// <summary>Records GFakeAllocated after teardown.</summary>
    procedure PostTearDown;
    /// <summary>
    ///   Growth across setup.
    /// </summary>
    /// <returns>
    ///   Post-setup minus pre-setup simulated bytes.
    /// </returns>
    function SetUpMemoryAllocated : Int64;
    /// <summary>
    ///   Growth across teardown.
    /// </summary>
    /// <returns>
    ///   Post-teardown minus pre-teardown simulated bytes.
    /// </returns>
    function TearDownMemoryAllocated : Int64;
    /// <summary>
    ///   Growth across the test.
    /// </summary>
    /// <returns>
    ///   Post-test minus pre-test simulated bytes.
    /// </returns>
    function TestMemoryAllocated : Int64;
  end;

  /// <summary>
  ///   Logger that collects warnings into GWarnings.
  /// </summary>
  TWarningLogger = class(TDUnitXNullLogger)
  protected
    /// <summary>
    ///   Appends warning-level messages to GWarnings; ignores the rest.
    /// </summary>
    /// <param name="logType">
    ///   The message's level.
    /// </param>
    /// <param name="msg">
    ///   The message text.
    /// </param>
    procedure OnLog(const logType : TLogLevel; const msg : string); override;
  end;

  /// <summary>
  ///   Simulates a logger whose storage grows with every message (50 simulated bytes each).
  /// </summary>
  TFakeAllocatingLogger = class(TDUnitXNullLogger)
  protected
    /// <summary>
    ///   Adds 50 to GFakeAllocated for every message.
    /// </summary>
    /// <param name="logType">
    ///   The message's level; ignored.
    /// </param>
    /// <param name="msg">
    ///   The message text; ignored.
    /// </param>
    procedure OnLog(const logType : TLogLevel; const msg : string); override;
  end;

  /// <summary>
  ///   Keeps per-test state, as a logger may, in callbacks that the runner makes inside the leak span (40 simulated
  ///   bytes per callback).
  /// </summary>
  TStateKeepingLogger = class(TDUnitXNullLogger)
  protected
    /// <summary>
    ///   Adds 40 to GFakeAllocated at the end of setup.
    /// </summary>
    /// <param name="threadId">
    ///   The running thread.
    /// </param>
    /// <param name="Test">
    ///   The test whose setup ended.
    /// </param>
    procedure OnEndSetupTest(const threadId : TThreadID; const Test : ITestInfo); override;
    /// <summary>
    ///   Adds 40 to GFakeAllocated as the test starts.
    /// </summary>
    /// <param name="threadId">
    ///   The running thread.
    /// </param>
    /// <param name="Test">
    ///   The test starting.
    /// </param>
    procedure OnExecuteTest(const threadId : TThreadID; const Test : ITestInfo); override;
    /// <summary>
    ///   Adds 40 to GFakeAllocated as teardown starts.
    /// </summary>
    /// <param name="threadId">
    ///   The running thread.
    /// </param>
    /// <param name="Test">
    ///   The test being torn down.
    /// </param>
    procedure OnTeardownTest(const threadId : TThreadID; const Test : ITestInfo); override;
  end;

  /// <summary>
  ///   Frees, between the phases, what TRunnerGapLeakChecks allocated: setup's allocation before the test starts,
  ///   the test's after it ends and before teardown starts.
  /// </summary>
  TGapFreeingLogger = class(TDUnitXNullLogger)
  protected
    /// <summary>
    ///   Frees what setup allocated (GSetupGapFree) as the test starts.
    /// </summary>
    /// <param name="threadId">
    ///   The running thread.
    /// </param>
    /// <param name="Test">
    ///   The test starting.
    /// </param>
    procedure OnExecuteTest(const threadId : TThreadID; const Test : ITestInfo); override;
    /// <summary>
    ///   Frees what the test allocated (GTestGapFree) as teardown starts.
    /// </summary>
    /// <param name="threadId">
    ///   The running thread.
    /// </param>
    /// <param name="Test">
    ///   The test being torn down.
    /// </param>
    procedure OnTeardownTest(const threadId : TThreadID; const Test : ITestInfo); override;
  end;

  /// <summary>
  ///   Cracker class exposing TDUnitXTestRunner's protected ExecuteFixtures to RunFixture.
  /// </summary>
  TRunnerAccess = class(TDUnitXTestRunner);
  /// <summary>
  ///   Cracker class exposing TDUnitXFixtureProvider's protected GenerateTests to BuildFixture.
  /// </summary>
  TProviderAccess = class(TDUnitXFixtureProvider);
  /// <summary>
  ///   Cracker class exposing TDUnitXRunResults' protected GetFixtures, which no interface publishes.
  /// </summary>
  TRunResultsAccess = class(TDUnitXRunResults);
  /// <summary>
  ///   A descendant of ETestFailureStrCompare, as a custom comparison assertion might raise.
  /// </summary>
  ETestFailureStrCompareChild = class(ETestFailureStrCompare);

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

procedure TRunnerGapLeakChecks.Setup;
begin
  Inc(GFakeAllocated, 500);
  GSetupGapFree := 500;
end;

procedure TRunnerGapLeakChecks.TearDown;
begin
end;

procedure TRunnerGapLeakChecks.FreedBetweenPhases;
begin
  Inc(GFakeAllocated, 1000);
  GTestGapFree := 1000;
end;

procedure TRunnerGapLeakChecks.LeaksForReal;
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

procedure TRunnerVirtualBase.Setup;
begin
  FOverridingSetupRan := false;
end;

procedure TRunnerVirtualBase.RunsTheOverride;
begin
  Assert.Fail('the overridden base implementation ran');
end;

procedure TRunnerVirtualBase.OverriddenInPublished;
begin
  Assert.Fail('the overridden base implementation ran');
end;

procedure TRunnerVirtualDerived.Setup;
begin
  inherited;
  FOverridingSetupRan := true;
end;

procedure TRunnerVirtualDerived.RunsTheOverride;
begin
  Assert.IsTrue(FOverridingSetupRan, 'the overriding Setup ran');
end;

procedure TRunnerVirtualDerived.OverriddenInPublished;
begin
  Assert.IsTrue(FOverridingSetupRan, 'the overriding Setup ran');
end;

procedure TRunnerSlowPass.OverItsMaxTimeThenPasses;
begin
  Sleep(120);
  Assert.Pass('passed too late');
end;

procedure TRunnerFixtureSetupCount.SetupFixture;
begin
  Inc(GSetupFixtureCalls);
end;

procedure TRunnerFixtureSetupCount.FilteredOut;
begin
end;

procedure TRunnerFixtureSetupCount.IgnoredButSelected;
begin
end;

procedure TRunnerLogAttribution.Setup;
begin
  Inc(GLogSetupCalls);
  Log('logged in setup');
  if GLogSetupCalls = 2 then
    raise EInvalidOpException.Create('second setup fails');
end;

procedure TRunnerLogAttribution.TestOne;
begin
  Log('logged by TestOne');
  Assert.Fail('TestOne fails');
end;

procedure TRunnerLogAttribution.TestTwo;
begin
  Log('logged by TestTwo');
  Assert.Fail('TestTwo fails');
end;

procedure TRunnerSetupAndTearDown.Setup;
begin
end;

procedure TRunnerSetupAndTearDown.TearDown;
begin
end;

procedure TRunnerSetupAndTearDown.Passes;
begin
  Assert.Pass;
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

procedure TStateKeepingLogger.OnEndSetupTest(const threadId : TThreadID; const Test : ITestInfo);
begin
  Inc(GFakeAllocated, 40);
end;

procedure TStateKeepingLogger.OnExecuteTest(const threadId : TThreadID; const Test : ITestInfo);
begin
  Inc(GFakeAllocated, 40);
end;

procedure TStateKeepingLogger.OnTeardownTest(const threadId : TThreadID; const Test : ITestInfo);
begin
  Inc(GFakeAllocated, 40);
end;

procedure TGapFreeingLogger.OnExecuteTest(const threadId : TThreadID; const Test : ITestInfo);
begin
  Dec(GFakeAllocated, GSetupGapFree);
  GSetupGapFree := 0;
end;

procedure TGapFreeingLogger.OnTeardownTest(const threadId : TThreadID; const Test : ITestInfo);
begin
  Dec(GFakeAllocated, GTestGapFree);
  GTestGapFree := 0;
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

procedure TRunnerBehaviourTests.LeakCheckIgnoresMemoryFreedBetweenPhases;
var
  results : IRunResults;
begin
  GSetupGapFree := 0;
  GTestGapFree := 0;
  TDUnitXServiceLocator.DefaultContainer.RegisterType<IMemoryLeakMonitor>(
    function : IMemoryLeakMonitor
    begin
      Result := TFakeLeakMonitor.Create;
    end);
  try
    results := RunFixture(BuildFixture(TRunnerGapLeakChecks), TGapFreeingLogger.Create);
  finally
    //The suite runs with the default monitor; put it back.
    DUnitX.MemoryLeakMonitor.Default.RegisterDefaultProvider;
  end;
  CheckResult(results, 'FreedBetweenPhases', TTestResultType.Pass);
  CheckResult(results, 'LeaksForReal', TTestResultType.MemoryLeak);
  //The figure starts the message; setup's 500, freed before the test, is not in it.
  Assert.StartsWith('32 bytes', FindResult(results, 'LeaksForReal').Message, False, 'LeaksForReal message');
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

function CountResults(const AResults : IRunResults; const ATestName : string) : Integer;
var
  testResult : ITestResult;
begin
  Result := 0;
  for testResult in AResults.GetAllTestResults do
    if testResult.Test.Name = ATestName then
      Inc(Result);
end;

function LogText(const AResult : ITestResult) : string;
var
  logMessage : TLogMessage;
begin
  Result := '';
  for logMessage in AResult.LogMessages do
    Result := Result + logMessage.Msg + '|';
end;

procedure TRunnerBehaviourTests.OverridesOfAttributedMethodsRunOnce;
var
  results : IRunResults;
begin
  results := RunFixture(BuildFixture(TRunnerVirtualDerived));
  Assert.AreEqual(1, CountResults(results, 'RunsTheOverride'), 'RunsTheOverride results');
  Assert.AreEqual(1, CountResults(results, 'OverriddenInPublished'), 'OverriddenInPublished results');
  CheckResult(results, 'RunsTheOverride', TTestResultType.Pass);
  CheckResult(results, 'OverriddenInPublished', TTestResultType.Pass);
end;

procedure TRunnerBehaviourTests.MaxTimeOverrunEndingInAssertPassFails;
var
  results : IRunResults;
begin
  results := RunFixture(BuildFixture(TRunnerSlowPass));
  CheckResult(results, 'OverItsMaxTimeThenPasses', TTestResultType.Failure);
end;

procedure TRunnerBehaviourTests.SetupFixtureSkippedWhenNoTestWillExecute;
var
  fixture : ITestFixture;
  test : ITest;
begin
  GSetupFixtureCalls := 0;
  fixture := BuildFixture(TRunnerFixtureSetupCount);
  for test in fixture.Tests do
    if test.Name = 'FilteredOut' then
      test.Enabled := false;
  RunFixture(fixture);
  Assert.AreEqual(0, GSetupFixtureCalls, 'SetupFixture calls');
end;

procedure TRunnerBehaviourTests.ResultsCarryOnlyTheirOwnLog;
var
  results : IRunResults;
  one : string;
  two : string;
begin
  GLogSetupCalls := 0;
  results := RunFixture(BuildFixture(TRunnerLogAttribution));
  one := LogText(FindResult(results, 'TestOne'));
  two := LogText(FindResult(results, 'TestTwo'));
  //Whichever test runs second fails in Setup; neither result may carry the other test's log.
  Assert.DoesNotContain(one, 'logged by TestTwo', False, 'TestOne log: ' + one);
  Assert.DoesNotContain(two, 'logged by TestOne', False, 'TestTwo log: ' + two);
  Assert.Contains(one, 'logged in setup', False, 'TestOne log: ' + one);
  Assert.Contains(two, 'logged in setup', False, 'TestTwo log: ' + two);
end;

procedure TRunnerBehaviourTests.LoggerStateIsNotATestLeak;
var
  results : IRunResults;
begin
  TDUnitXServiceLocator.DefaultContainer.RegisterType<IMemoryLeakMonitor>(
    function : IMemoryLeakMonitor
    begin
      Result := TFakeLeakMonitor.Create;
    end);
  try
    results := RunFixture(BuildFixture(TRunnerSetupAndTearDown), TStateKeepingLogger.Create);
  finally
    //The suite runs with the default monitor; put it back.
    DUnitX.MemoryLeakMonitor.Default.RegisterDefaultProvider;
  end;
  CheckResult(results, 'Passes', TTestResultType.Pass);
end;

procedure TRunnerBehaviourTests.NameFilterMatchesWholeNameSegments;
var
  Context : TRttiContext;
  MyClass : TRttiType;
  MyMethod : TRttiMethod;
  customer : ITestFixture;
  customerOrder : ITestFixture;
  customerTest : ITest;
  orderTest : ITest;
  caseTest : ITest;
  filter : ITestFilter;
begin
  Context := TRttiContext.Create;
  try
    MyClass := Context.GetType(TTestCaseAttribute);
    MyMethod := MyClass.GetMethod('ProcedureWithTwoParameters');
    customer := TDUnitXTestFixture.Create('Unit.TCustomer', EmptyStr, TTestCaseAttribute, MyClass.UnitName) as ITestFixture;
    customerTest := customer.AddTest(MyMethod.Name, nil, 'Run', '', MyMethod);
    caseTest := customer.AddTestCase(MyMethod.Name, 'One', MyMethod.Name, '', MyMethod, true, []);
    customerOrder := TDUnitXTestFixture.Create('Unit.TCustomerOrder', EmptyStr, TTestCaseAttribute, MyClass.UnitName) as ITestFixture;
    orderTest := customerOrder.AddTest(MyMethod.Name, nil, 'Run', '', MyMethod);

    filter := TNameFilter.Create(customer.FullName);
    Assert.IsTrue(filter.Match(customerTest), 'a test of the named fixture');
    Assert.IsFalse(filter.Match(orderTest), 'a test of a fixture whose name only starts with the named one');

    filter := TNameFilter.Create('Unit');
    Assert.IsTrue(filter.Match(orderTest), 'a test under the named namespace');
    filter := TNameFilter.Create('Uni');
    Assert.IsFalse(filter.Match(orderTest), 'a partial namespace segment');

    filter := TNameFilter.Create(customer.FullName + '.' + MyMethod.Name);
    Assert.IsTrue(filter.Match(caseTest), 'a test case of the named method');
    Assert.IsFalse(filter.Match(customerTest), 'another test of the fixture');
  finally
    filter := nil;
    customerTest := nil;
    caseTest := nil;
    orderTest := nil;
    customer := nil;
    customerOrder := nil;
    Context.Free;
  end;
end;

procedure TRunnerBehaviourTests.FixtureListSortsByNameAtEveryLevel;
var
  list : ITestFixtureList;
  parent : ITestFixture;
  name : string;

  function Names(const AList : ITestFixtureList) : string;
  var
    fixture : ITestFixture;
  begin
    Result := '';
    for fixture in AList do
      Result := Result + fixture.Name + ' ';
  end;

begin
  list := TTestFixtureList.Create;
  //Created in reverse order, so heap addresses ascend against the names.
  for name in ['C', 'B', 'A'] do
  begin
    parent := TDUnitXTestFixture.Create(name, EmptyStr, TObject, EmptyStr) as ITestFixture;
    parent.AddChildFixture(TObject, name + 'z', EmptyStr);
    parent.AddChildFixture(TObject, name + 'y', EmptyStr);
    list.Add(parent);
  end;
  list.SortByName;
  Assert.AreEqual('A B C ', Names(list), False, 'top level');
  for parent in list do
    Assert.AreEqual(parent.Name + 'y ' + parent.Name + 'z ', Names(parent.Children), False, 'children of ' + parent.Name);
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

procedure TRunnerBehaviourTests.RunResultsListTheRunFixtures;
var
  fixture : ITestFixture;
  results : IRunResults;
  fixtures : IEnumerable<ITestFixtureInfo>;
  info : ITestFixtureInfo;
  count : Integer;
begin
  fixture := BuildFixture(TRunnerThreeOfFourPass);
  results := RunFixture(fixture);
  Assert.AreEqual(1, results.FixtureCount, 'precondition: one fixture result recorded');
  fixtures := TRunResultsAccess(results as TObject).GetFixtures;
  Assert.IsNotNull(fixtures, 'GetFixtures returned nil');
  count := 0;
  for info in fixtures do
  begin
    Inc(count);
    Assert.AreEqual(fixture.FullName, info.FullName, False, 'the listed fixture is not the one run');
  end;
  Assert.AreEqual(1, count, 'one fixture listed');
end;

procedure TRunnerBehaviourTests.FixtureTestInfoListFollowsAddedTests;
var
  context : TRttiContext;
  fixture : ITestFixture;
  before : Integer;
begin
  fixture := BuildFixture(TRunnerThreeOfFourPass);
  //Reading the list first is what built (and used to freeze) it.
  before := (fixture as ITestFixtureInfo).Tests.Count;
  Assert.AreEqual(4, before, 'precondition: the four declared tests');
  context := TRttiContext.Create;
  try
    fixture.AddTest('PassOne', nil, 'AddedLater', '', context.GetType(TRunnerThreeOfFourPass).GetMethod('PassOne'));
  finally
    context.Free;
  end;
  Assert.AreEqual(before + 1, (fixture as ITestFixtureInfo).Tests.Count, 'the ITestInfo list is stale');
end;

procedure TRunnerBehaviourTests.NameFilterListDropsEmptyAndDuplicateNames;
var
  context : TRttiContext;
  filter : TNameFilter;
  filterIntf : ITestFilter;
  names : TList<string>;
begin
  filter := TNameFilter.Create(TArray<string>.Create('', 'X.Y', 'X.Y', ''));
  filterIntf := filter;
  //No accessor publishes the stored names, so they are read through RTTI.
  context := TRttiContext.Create;
  try
    names := context.GetType(TNameFilter).GetField('FNames').GetValue(filter).AsObject as TList<string>;
    Assert.AreEqual(1, names.Count, 'empty or duplicate names were stored');
    Assert.AreEqual('X.Y', names[0], False);
  finally
    context.Free;
  end;
end;

procedure TRunnerBehaviourTests.TestErrorSeparatesMessagesAndAcceptsStrCompareDescendants;
var
  fixture : ITestFixture;
  testInfo : ITestInfo;
  error : ITestError;
  thrown : Exception;
begin
  fixture := BuildFixture(TRunnerThreeOfFourPass);
  testInfo := (fixture as ITestFixtureInfo).Tests[0];

  thrown := Exception.Create('exception message');
  try
    error := TDUnitXTestError.Create(testInfo, TTestResultType.Error, thrown, nil, 'result message', nil);
  finally
    thrown.Free;
  end;
  Assert.AreEqual('result message' + sLineBreak + 'exception message', error.ExceptionMessage, False,
    'the two messages were not separated by a line break');
  Assert.IsFalse(error.IsComparable, 'a plain exception is not comparable');

  thrown := ETestFailureStrCompareChild.Create('expected text', 'actual text', 'compare message', nil);
  try
    //The result message is the exception's own, as the runner records it, so it must appear once.
    error := TDUnitXTestError.Create(testInfo, TTestResultType.Failure, thrown, nil, thrown.Message, nil);
    Assert.AreEqual(thrown.Message, error.ExceptionMessage, False, 'equal messages must not be repeated');
  finally
    thrown.Free;
  end;
  Assert.IsTrue(error.IsComparable, 'a descendant of ETestFailureStrCompare is not comparable');
  Assert.AreEqual('expected text', error.Expected, False, 'expected value not carried');
  Assert.AreEqual('actual text', error.Actual, False, 'actual value not carried');
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

