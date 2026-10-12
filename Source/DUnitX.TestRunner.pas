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
  /// <summary>
  ///   The DUnitX test runner: builds the fixture tree, applies the filter, runs every fixture's setup, tests and
  ///   teardown, checks each test for memory leaks, and reports progress and results to the attached loggers.
  /// </summary>
  /// <remarks>
  ///   Relies on there being only one active test runner per thread; if that changes, the handling of
  ///   <c>WriteLn</c> will need to change. A runner created while another is active on the same thread stands in for
  ///   it until destroyed.
  /// </remarks>
  TDUnitXTestRunner = class(TWeakReferencedObject, ITestRunner)
  public
    class var
      /// <summary>
      ///   The active runner of each thread, held weakly; guarded by <c>MonitorEnter</c> on the dictionary itself.
      /// </summary>
      FActiveRunners : TDictionary<TThreadID, IWeakReference<ITestRunner>>;
  private
    /// <summary>Loggers notified of every step of the run, in the order they were added.</summary>
    FLoggers : TList<ITestLogger>;
    /// <summary>Whether fixture classes are also discovered through RTTI; passed to the fixture builder.</summary>
    FUseRTTI : boolean;

    /// <summary>The fixture tree, built and sorted on first <c>Execute</c> unless already built.</summary>
    FFixtureList : ITestFixtureList;
    /// <summary>Text of the messages logged for the current setup, test or teardown.</summary>
    FLogMessages : TStringList;
    /// <summary>The same messages with their log levels, attached to the current result.</summary>
    FLogMessagesEx : TLogMessageArray;

    /// <summary>Whether a test that makes no assertion fails with <c>ENoAssertionsMade</c>.</summary>
    FFailsOnNoAsserts : boolean;
    /// <summary>Name of the test currently executing, empty between tests.</summary>
    FCurrentTestName : string;

    /// <summary>Thread whose active-runner entry this runner registered.</summary>
    FThreadId : TThreadID;
    /// <summary>The active-runner entry this runner registered for itself.</summary>
    FOwnRunnerRef : IWeakReference<ITestRunner>;
    /// <summary>The active-runner entry this runner stood in for, restored when it is destroyed.</summary>
    FPreviousRunnerRef : IWeakReference<ITestRunner>;

    /// <summary>
    ///   While a test runs, measures memory the runner itself keeps (log messages, a pass message), which the leak
    ///   check then discounts; nil when not measuring.
    /// </summary>
    FRunnerAllocationMonitor : IMemoryLeakMonitor;
    /// <summary>Bytes the runner itself kept during the current test, subtracted from the leak total.</summary>
    FRunnerAllocated : Int64;
    /// <summary>
    ///   Measures the whole span from the start of setup (or the test) to the end of teardown (or the test), so
    ///   memory freed between the phases is not a leak. nil when the monitor is a singleton; the leak check then
    ///   sums the phases.
    /// </summary>
    FLeakSpanMonitor : IMemoryLeakMonitor;
    /// <summary>Whether the leak span measurement has started for the current test.</summary>
    FLeakSpanStarted : boolean;
    /// <summary>Nesting depth of runner-allocation brackets; only the outermost pair measures.</summary>
    FRunnerAllocationDepth : Integer;
    /// <summary>
    ///   Opens a bracket whose allocations are credited to the runner rather than the test; nested brackets are
    ///   measured once, by the outermost pair.
    /// </summary>
    procedure BeginRunnerAllocation;
    /// <summary>
    ///   Closes a runner-allocation bracket and, at the outermost level, adds what it allocated to the runner's total.
    /// </summary>
    /// <param name="onlyGrowth">
    ///   When True, memory freed inside the bracket is not credited to the runner. Used around logger callbacks,
    ///   which may release what the test or Setup allocated (the test's own memory going, not the runner's).
    /// </param>
    procedure EndRunnerAllocation(const onlyGrowth : boolean = False);
    /// <summary>
    ///   Starts the whole-span leak measurement for the current test, once, when a separate span monitor exists.
    /// </summary>
    procedure BeginLeakSpan;
    /// <summary>
    ///   Moves the end of the leak span to now, so it covers everything up to the latest phase.
    /// </summary>
    procedure ExtendLeakSpan;
    /// <summary>
    ///   Empties both log message lists, so the next result carries only what is logged from here on.
    /// </summary>
    procedure ClearLogMessages;
  protected
    /// <summary>
    ///   Applies the run filter to every test, recursively, and counts the tests that will be reported.
    /// </summary>
    /// <param name="fixtureList">
    ///   The fixtures to walk.
    /// </param>
    /// <param name="count">
    ///   Incremented for every enabled test.
    /// </param>
    /// <param name="active">
    ///   Incremented for every enabled test that is not ignored.
    /// </param>
    procedure CountAndFilterTests(const fixtureList : ITestFixtureList; var count, active : Cardinal);
    /// <summary>
    ///   Tells every logger the run is starting. The <c>Loggers_*</c> methods below are listed in the order the run
    ///   calls them.
    /// </summary>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="testCount">
    ///   Number of enabled tests.
    /// </param>
    /// <param name="testActiveCount">
    ///   Number of enabled tests that are not ignored.
    /// </param>
    procedure Loggers_TestingStarts(const threadId : TThreadID; testCount, testActiveCount : Cardinal);

    /// <summary>
    ///   Tells every logger a fixture is starting.
    /// </summary>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="fixture">
    ///   The fixture.
    /// </param>
    procedure Loggers_StartTestFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);

    /// <summary>
    ///   Tells every logger a fixture's <c>[SetupFixture]</c> method is about to run.
    /// </summary>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="fixture">
    ///   The fixture.
    /// </param>
    procedure Loggers_SetupFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
    /// <summary>
    ///   Tells every logger a fixture's <c>[SetupFixture]</c> method completed.
    /// </summary>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="fixture">
    ///   The fixture.
    /// </param>
    procedure Loggers_EndSetupFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);

    /// <summary>
    ///   Tells every logger a test is beginning, before its setup.
    /// </summary>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="Test">
    ///   The test.
    /// </param>
    procedure Loggers_BeginTest(const threadId : TThreadID; const Test : ITestInfo);

    /// <summary>
    ///   Tells every logger a test's <c>[Setup]</c> method is about to run.
    /// </summary>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="Test">
    ///   The test.
    /// </param>
    procedure Loggers_SetupTest(const threadId : TThreadID; const Test : ITestInfo);
    /// <summary>
    ///   Tells every logger a test's <c>[Setup]</c> method completed. An exception from a logger is reported through
    ///   that logger's <c>OnLog</c> (or written to the console) rather than failing the test.
    /// </summary>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="Test">
    ///   The test.
    /// </param>
    procedure Loggers_EndSetupTest(const threadId : TThreadID; const Test : ITestInfo);

    /// <summary>
    ///   Tells every logger the test method is about to execute.
    /// </summary>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="Test">
    ///   The test.
    /// </param>
    procedure Loggers_ExecuteTest(const threadId : TThreadID; const Test : ITestInfo);

    /// <summary>
    ///   Tells every logger a test passed.
    /// </summary>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="Test">
    ///   The passing result.
    /// </param>
    procedure Loggers_AddSuccess(const threadId : TThreadID; const Test : ITestResult);
    /// <summary>
    ///   Tells every logger a test ended in an error.
    /// </summary>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="Error">
    ///   The error result.
    /// </param>
    procedure Loggers_AddError(const threadId : TThreadID; const Error : ITestError);
    /// <summary>
    ///   Tells every logger a test failed.
    /// </summary>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="Failure">
    ///   The failure result.
    /// </param>
    procedure Loggers_AddFailure(const threadId : TThreadID; const Failure : ITestError);
    /// <summary>
    ///   Tells every logger a test was ignored.
    /// </summary>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="AIgnored">
    ///   The ignored result.
    /// </param>
    procedure Loggers_AddIgnored(const threadId : TThreadID; const AIgnored : ITestResult);
    /// <summary>
    ///   Tells every logger a test leaked memory.
    /// </summary>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="Test">
    ///   The memory-leak result.
    /// </param>
    procedure Loggers_AddMemoryLeak(const threadId : TThreadID; const Test : ITestResult);

    /// <summary>
    ///   Tells every logger a test has finished, with its final result.
    /// </summary>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="Test">
    ///   The test's final result.
    /// </param>
    procedure Loggers_EndTest(const threadId : TThreadID; const Test : ITestResult);
    /// <summary>
    ///   Tells every logger a test's <c>[TearDown]</c> method is about to run.
    /// </summary>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="Test">
    ///   The test.
    /// </param>
    procedure Loggers_TeardownTest(const threadId : TThreadID; const Test : ITestInfo);
    /// <summary>
    ///   Tells every logger a test's <c>[TearDown]</c> method completed.
    /// </summary>
    /// <param name="aThreadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="aTest">
    ///   The test.
    /// </param>
    procedure Loggers_EndTeardownTest(const aThreadId : TThreadID; const aTest : ITestInfo);

    /// <summary>
    ///   Tells every logger a fixture's <c>[TearDownFixture]</c> method is about to run.
    /// </summary>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="fixture">
    ///   The fixture.
    /// </param>
    procedure Loggers_TeardownFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
    /// <summary>
    ///   Tells every logger a fixture's <c>[TearDownFixture]</c> method completed.
    /// </summary>
    /// <param name="aThreadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="aFixture">
    ///   The fixture.
    /// </param>
    procedure Loggers_EndTearDownFixture(const aThreadId : TThreadID; const aFixture : ITestFixtureInfo);

    /// <summary>
    ///   Tells every logger a fixture has finished, with its rolled-up result.
    /// </summary>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="results">
    ///   The fixture's result.
    /// </param>
    procedure Loggers_EndTestFixture(const threadId : TThreadID; const results : IFixtureResult);

    /// <summary>
    ///   Tells every logger the run has ended.
    /// </summary>
    /// <param name="RunResults">
    ///   The results of the whole run.
    /// </param>
    procedure Loggers_TestingEnds(const RunResults : IRunResults);

    /// <summary>
    ///   Implements <c>ITestRunner</c>: attaches a logger, ignoring one already attached.
    /// </summary>
    /// <param name="value">
    ///   The logger to add.
    /// </param>
    procedure AddLogger(const value : ITestLogger);
    /// <summary>
    ///   Implements <c>ITestRunner</c>: builds the fixtures if needed, applies the filter, runs every fixture and
    ///   returns the results. Logs a warning when no test executed, because such a run does not count as passed.
    /// </summary>
    /// <returns>
    ///   The results of the run.
    /// </returns>
    /// <exception cref="ENoTestsRegistered">
    ///   Raised when no fixture was found.
    /// </exception>
    function Execute : IRunResults;

    /// <summary>
    ///   Runs a list of fixtures and, recursively, their children: creates each fixture instance, runs
    ///   <c>[SetupFixture]</c> (only when a test will actually execute), the tests, the child fixtures and
    ///   <c>[TearDownFixture]</c>, then rolls up the fixture result. A failing constructor or fixture setup turns the
    ///   fixture's tests into errors instead of stopping the run.
    /// </summary>
    /// <param name="parentFixtureResult">
    ///   Result of the parent fixture; nil at the top level, where each fixture result is recorded on the context.
    /// </param>
    /// <param name="context">
    ///   The run's result-collection context.
    /// </param>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="fixtures">
    ///   The fixtures to run; disabled ones and those with no enabled tests at any depth are skipped.
    /// </param>
    procedure ExecuteFixtures(const parentFixtureResult : IFixtureResult; const context : ITestExecuteContext; const threadId : TThreadID; const fixtures :
      ITestFixtureList);
    /// <summary>
    ///   Runs a fixture's <c>[SetupFixture]</c> method between the logger notifications. If it raises, every runnable
    ///   test of the fixture is recorded as an error carrying that exception and the fixture is skipped.
    /// </summary>
    /// <param name="context">
    ///   The run's result-collection context.
    /// </param>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="fixture">
    ///   The fixture whose setup runs.
    /// </param>
    /// <param name="fixtureResult">
    ///   The fixture's result, which receives the error results on failure.
    /// </param>
    /// <returns>
    ///   True when the setup completed; False when it raised.
    /// </returns>
    function ExecuteSetupFixtureMethod(const context : ITestExecuteContext; const threadId : TThreadID; const fixture : ITestFixture; const fixtureResult :
      IFixtureResult) : boolean;
    /// <summary>
    ///   Runs the fixture's <c>[Setup]</c> method for one test, measuring its memory for the leak check.
    /// </summary>
    /// <param name="context">
    ///   The run's result-collection context.
    /// </param>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="fixture">
    ///   The fixture whose setup runs.
    /// </param>
    /// <param name="test">
    ///   The test the setup is for.
    /// </param>
    /// <param name="errorResult">
    ///   An error result built from the exception when the setup raises; nil otherwise.
    /// </param>
    /// <param name="memoryAllocationProvider">
    ///   The leak monitor measuring the test's phases.
    /// </param>
    /// <returns>
    ///   True when the setup completed; False when it raised or there is no setup method.
    /// </returns>
    function ExecuteTestSetupMethod(const context : ITestExecuteContext; const threadId : TThreadID; const fixture : ITestFixture; const test : ITest; out
      errorResult : ITestResult; const memoryAllocationProvider : IMemoryLeakMonitor) : boolean;

    /// <summary>
    ///   Runs every runnable test of a fixture: <c>[Setup]</c>, the test, <c>[TearDown]</c> and the leak check, then
    ///   records the result and notifies the loggers. A failed setup becomes the test's result and its teardown is
    ///   skipped; a teardown that fails after a test failure is appended to the test's message.
    /// </summary>
    /// <param name="context">
    ///   The run's result-collection context.
    /// </param>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="fixture">
    ///   The fixture whose tests run.
    /// </param>
    /// <param name="fixtureResult">
    ///   The fixture's result, which receives each test result.
    /// </param>
    procedure ExecuteTests(const context : ITestExecuteContext; const threadId : TThreadID; const fixture : ITestFixture; const fixtureResult :
      IFixtureResult);

    /// <summary>
    ///   Executes one test method under the leak monitor. <c>Assert.Pass</c> is handled here so its exception object is
    ///   released before the memory is measured; other exceptions propagate to the caller, which classifies them.
    /// </summary>
    /// <param name="context">
    ///   The run's result-collection context.
    /// </param>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="test">
    ///   The test to execute.
    /// </param>
    /// <param name="memoryAllocationProvider">
    ///   The leak monitor measuring the test's phases.
    /// </param>
    /// <returns>
    ///   A passing result carrying the pass message or the logged text.
    /// </returns>
    /// <exception cref="ENoAssertionsMade">
    ///   Raised when <c>FailsOnNoAsserts</c> is set and the test made no assertion.
    /// </exception>
    /// <exception cref="Exception">
    ///   Raised when the test does not support <c>ITestExecute</c>; the caller records it as a test error.
    /// </exception>
    function ExecuteTest(const context : ITestExecuteContext; const threadId : TThreadID; const test : ITest; const memoryAllocationProvider :
      IMemoryLeakMonitor) : ITestResult;
    /// <summary>
    ///   Builds a passing result.
    /// </summary>
    /// <param name="context">
    ///   The run's result-collection context (unused).
    /// </param>
    /// <param name="threadId">
    ///   Thread the run executes on (unused).
    /// </param>
    /// <param name="test">
    ///   The test that passed.
    /// </param>
    /// <param name="aMessage">
    ///   The result message.
    /// </param>
    /// <param name="aLogMessages">
    ///   Messages logged during the test.
    /// </param>
    /// <returns>
    ///   A result of type <c>Pass</c>.
    /// </returns>
    function ExecuteSuccessfulResult(const context : ITestExecuteContext; const threadId : TThreadID; const test : ITest; const aMessage : string; const
      aLogMessages : TLogMessageArray) : ITestResult;
    /// <summary>
    ///   Builds a failure result from an assertion exception.
    /// </summary>
    /// <param name="context">
    ///   The run's result-collection context (unused).
    /// </param>
    /// <param name="threadId">
    ///   Thread the run executes on (unused).
    /// </param>
    /// <param name="test">
    ///   The test that failed.
    /// </param>
    /// <param name="exception">
    ///   The exception that failed the test.
    /// </param>
    /// <param name="aLogMessages">
    ///   Messages logged during the test.
    /// </param>
    /// <returns>
    ///   A result of type <c>Failure</c>.
    /// </returns>
    function ExecuteFailureResult(const context : ITestExecuteContext; const threadId : TThreadID; const test : ITest; const exception : Exception; const
      aLogMessages : TLogMessageArray) : ITestError;
    /// <summary>
    ///   Builds the result for a test that exceeded its time limit; it is reported as a failure.
    /// </summary>
    /// <param name="context">
    ///   The run's result-collection context (unused).
    /// </param>
    /// <param name="threadId">
    ///   Thread the run executes on (unused).
    /// </param>
    /// <param name="test">
    ///   The test that timed out.
    /// </param>
    /// <param name="exception">
    ///   The time-out exception.
    /// </param>
    /// <param name="aLogMessages">
    ///   Messages logged during the test.
    /// </param>
    /// <returns>
    ///   A result of type <c>Failure</c>.
    /// </returns>
    function ExecuteTimedOutResult(const context : ITestExecuteContext; const threadId : TThreadID; const test : ITest; const exception : Exception; const
      aLogMessages : TLogMessageArray) : ITestError;
    /// <summary>
    ///   Builds an error result from an unexpected exception.
    /// </summary>
    /// <param name="context">
    ///   The run's result-collection context (unused).
    /// </param>
    /// <param name="threadId">
    ///   Thread the run executes on (unused).
    /// </param>
    /// <param name="test">
    ///   The test the error belongs to.
    /// </param>
    /// <param name="exception">
    ///   The exception raised.
    /// </param>
    /// <param name="aLogMessages">
    ///   Messages logged during the test.
    /// </param>
    /// <returns>
    ///   A result of type <c>Error</c>.
    /// </returns>
    function ExecuteErrorResult(const context : ITestExecuteContext; const threadId : TThreadID; const test : ITest; const exception : Exception; const
      aLogMessages : TLogMessageArray) : ITestError;
    /// <summary>
    ///   Builds an ignored result.
    /// </summary>
    /// <param name="context">
    ///   The run's result-collection context (unused).
    /// </param>
    /// <param name="threadId">
    ///   Thread the run executes on (unused).
    /// </param>
    /// <param name="test">
    ///   The test that was ignored.
    /// </param>
    /// <param name="ignoreReason">
    ///   Why it was ignored; becomes the result message.
    /// </param>
    /// <returns>
    ///   A result of type <c>Ignored</c>.
    /// </returns>
    function ExecuteIgnoredResult(const context : ITestExecuteContext; const threadId : TThreadID; const test : ITest; const ignoreReason : string) :
      ITestResult;
    /// <summary>
    ///   Records every runnable test of a fixture as an error carrying the given exception, used when the fixture
    ///   cannot be created or set up. Ignored tests stay ignored, since they would not have run anyway.
    /// </summary>
    /// <param name="aFixture">
    ///   The fixture whose tests are invalidated.
    /// </param>
    /// <param name="aContext">
    ///   The run's result-collection context.
    /// </param>
    /// <param name="aThreadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="aException">
    ///   The exception that prevented the tests from running.
    /// </param>
    /// <param name="aFixtureResult">
    ///   The fixture's result, which receives the error results.
    /// </param>
    procedure InvalidateTestsInFixture(const aFixture : ITestFixture; const aContext : ITestExecuteContext; const aThreadId : TThreadID; const aException :
      Exception; const aFixtureResult : IFixtureResult);

    /// <summary>
    ///   Checks a passing test for leaked memory: net growth across setup, test and teardown (the whole span where it
    ///   can be measured), less what the runner itself kept. Only growth is a leak.
    /// </summary>
    /// <param name="test">
    ///   The test to check; one with <c>IgnoreMemoryLeaks</c> set always passes.
    /// </param>
    /// <param name="errorResult">
    ///   A <c>MemoryLeak</c> result whose message says whether setup/teardown, the test, or both leaked; nil when
    ///   nothing leaked.
    /// </param>
    /// <param name="memoryAllocationProvider">
    ///   The leak monitor that measured the test's phases.
    /// </param>
    /// <returns>
    ///   True when nothing leaked; False when a leak was found.
    /// </returns>
    function CheckMemoryAllocations(const test : ITest; out errorResult : ITestResult; const memoryAllocationProvider : IMemoryLeakMonitor) : boolean;

    /// <summary>
    ///   Runs the fixture's <c>[TearDown]</c> method for one test, measuring its memory for the leak check.
    /// </summary>
    /// <param name="context">
    ///   The run's result-collection context.
    /// </param>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="fixture">
    ///   The fixture whose teardown runs.
    /// </param>
    /// <param name="test">
    ///   The test the teardown is for.
    /// </param>
    /// <param name="errorResult">
    ///   An error result built from the exception when the teardown raises; nil otherwise.
    /// </param>
    /// <param name="memoryAllocationProvider">
    ///   The leak monitor measuring the test's phases.
    /// </param>
    /// <returns>
    ///   True when the teardown completed; False when it raised.
    /// </returns>
    function ExecuteTestTearDown(const context : ITestExecuteContext; const threadId : TThreadID; const fixture : ITestFixture; const test : ITest; out
      errorResult : ITestResult; const memoryAllocationProvider : IMemoryLeakMonitor) : boolean;
    /// <summary>
    ///   Runs a fixture's <c>[TearDownFixture]</c> method (or frees the instance when the destructor stands in for it).
    ///   If it raises, the failure is recorded once, as an error result named after the teardown method; the
    ///   fixture's tests, already recorded, are not reported again.
    /// </summary>
    /// <param name="context">
    ///   The run's result-collection context.
    /// </param>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="fixture">
    ///   The fixture whose teardown runs.
    /// </param>
    /// <param name="fixtureResult">
    ///   The fixture's result, which receives the error result on failure.
    /// </param>
    procedure ExecuteTearDownFixtureMethod(const context : ITestExecuteContext; const threadId : TThreadID; const fixture : ITestFixture; const fixtureResult :
      IFixtureResult);

    /// <summary>
    ///   Records a result on the context, logs it when it did not pass, and passes it to the matching
    ///   <c>Loggers_Add*</c> notification.
    /// </summary>
    /// <param name="context">
    ///   The run's result-collection context.
    /// </param>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="fixtureResult">
    ///   The fixture's result, which receives the test result.
    /// </param>
    /// <param name="testResult">
    ///   The result to record; its test must still be alive, because its name is logged.
    /// </param>
    procedure RecordResult(const context : ITestExecuteContext; const threadId : TThreadID; const fixtureResult : IFixtureResult; const testResult :
      ITestResult);

    /// <summary>
    ///   Implements <c>ITestRunner</c>: reports whether fixture classes are also discovered through RTTI.
    /// </summary>
    /// <returns>
    ///   The <c>UseRTTI</c> setting; False by default.
    /// </returns>
    function GetUseRTTI : Boolean;
    /// <summary>
    ///   Implements <c>ITestRunner</c>: sets whether fixture classes are also discovered through RTTI; takes effect
    ///   when the fixtures are built.
    /// </summary>
    /// <param name="value">
    ///   True to discover fixtures through RTTI.
    /// </param>
    procedure SetUseRTTI(const value : Boolean);
    /// <summary>
    ///   Implements <c>ITestRunner</c>: reports whether a test that makes no assertion fails.
    /// </summary>
    /// <returns>
    ///   The <c>FailsOnNoAsserts</c> setting.
    /// </returns>
    function GetFailsOnNoAsserts : boolean;
    /// <summary>
    ///   Implements <c>ITestRunner</c>: sets whether a test that makes no assertion fails.
    /// </summary>
    /// <param name="value">
    ///   True to fail such tests with <c>ENoAssertionsMade</c>.
    /// </param>
    procedure SetFailsOnNoAsserts(const value : boolean);

    /// <summary>
    ///   Logs a message at a level: when the level meets <c>TDUnitX.Options.LogLevel</c>, a copy is added to the
    ///   current result's log and passed to every logger. The memory it keeps is discounted from the leak check.
    /// </summary>
    /// <param name="logType">
    ///   The log level.
    /// </param>
    /// <param name="msg">
    ///   The message.
    /// </param>
    procedure Log(const logType : TLogLevel; const msg : string); overload;
    /// <summary>
    ///   Logs a message at <c>Information</c> level.
    /// </summary>
    /// <param name="msg">
    ///   The message.
    /// </param>
    procedure Log(const msg : string); overload;

    /// <summary>
    ///   Logs a message at <c>Information</c> level; kept for backwards compatibility with DUnit tests.
    /// </summary>
    /// <param name="msg">
    ///   The message.
    /// </param>
    procedure Status(const msg : string); overload;

    /// <summary>
    ///   Redirects <c>WriteLn</c> to the loggers, at <c>Information</c> level.
    /// </summary>
    /// <param name="msg">
    ///   The line to write.
    /// </param>
    procedure WriteLn(const msg : string); overload;
    /// <summary>
    ///   Redirects an empty <c>WriteLn</c> to the loggers, at <c>Information</c> level.
    /// </summary>
    procedure WriteLn; overload;
    /// <summary>
    ///   Gives the name of the test currently executing.
    /// </summary>
    /// <returns>
    ///   The test name, empty between tests.
    /// </returns>
    function CurrentTestName : string;

    /// <summary>
    ///   Runs the fixture builder (honouring <c>UseRTTI</c>), keeps the fixture tree and sorts it by name.
    /// </summary>
    /// <returns>
    ///   The fixture list, as an <c>ITestFixtureList</c>.
    /// </returns>
    function BuildFixtures : IInterface;

    /// <summary>
    ///   Decides whether a test is run and reported.
    /// </summary>
    /// <param name="test">
    ///   The test to check.
    /// </param>
    /// <returns>
    ///   False when the test is disabled, or ignored while <c>TDUnitX.Options.DontShowIgnored</c> is set; True
    ///   otherwise.
    /// </returns>
    function ShouldRunThisTest(const test : ITest) : boolean;

    /// <summary>
    ///   Creates the per-thread active-runner dictionary.
    /// </summary>
    class constructor Create;
    /// <summary>
    ///   Frees the per-thread active-runner dictionary.
    /// </summary>
    class destructor Destroy;
  public
    /// <summary>
    ///   Creates a runner with no loggers and registers it as the active runner of the calling thread, standing in
    ///   for any runner already active there.
    /// </summary>
    constructor Create; overload;
    /// <summary>
    ///   Creates a runner with one logger.
    /// </summary>
    /// <param name="AListener">
    ///   The logger to attach; nil attaches none.
    /// </param>
    constructor Create(const AListener : ITestLogger); overload;
    /// <summary>
    ///   Creates a runner with several loggers.
    /// </summary>
    /// <param name="AListeners">
    ///   The loggers to attach.
    /// </param>
    constructor Create(const AListeners : array of ITestLogger); overload;
    /// <summary>
    ///   Removes this runner's active-runner entry, restoring the runner it stood in for if that one is still alive,
    ///   and frees the loggers list and log messages.
    /// </summary>
    destructor Destroy; override;
    /// <summary>
    ///   Gives the runner active on the calling thread.
    /// </summary>
    /// <returns>
    ///   The active runner, or nil when none is registered for the thread.
    /// </returns>
    class function GetActiveRunner : ITestRunner;
    /// <summary>
    ///   Gives the name of the test executing on the calling thread.
    /// </summary>
    /// <returns>
    ///   The test name, or an empty string when no runner is active.
    /// </returns>
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

function TDUnitXTestRunner.BuildFixtures : IInterface;
var
  fixtureBuilder : IFixtureBuilder;
begin
  fixtureBuilder := TDUnitXFixtureBuilder.Create(FUseRTTI);

  FFixtureList := fixtureBuilder.BuildFixtureList;
  FFixtureList.SortByName;

  result := FFixtureList;
end;

class constructor TDUnitXTestRunner.Create;
begin
  FActiveRunners :=TDictionary < TThreadID, IWeakReference<ITestRunner> > .Create;
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
  inherited;
end;

class destructor TDUnitXTestRunner.Destroy;
begin
  FActiveRunners.Free;
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
  hasActiveTests : boolean;
begin
  for fixture in fixtures do
  begin
    if not fixture.Enabled then
      System.continue;

    if (not fixture.HasTests) and (not fixture.HasChildTests) then
      System.Continue;

    setupOk := True;
    //Read once: stopping a run (the GUI runner disables the remaining tests) must not skip the [TearDownFixture]
    //that pairs with a [SetupFixture] that ran.
    hasActiveTests := fixture.HasActiveTests;
    //The fixture's errors carry what its own setup logs, not what the previous fixture's last test logged.
    ClearLogMessages;
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
      if hasActiveTests and (fixture.SetupFixtureMethodName <> '') and (not Assigned(fixture.SetupFixtureMethod)) then
        Log(TLogLevel.Warning, Format(SSetupFixtureNotRun, [fixture.SetupFixtureMethodName, fixture.Name]));
      //only run the setup method if there are actually tests
      if setupOk and hasActiveTests and Assigned(fixture.SetupFixtureMethod) then
        //returns false if an exception happens in the setup.
        setupOk := ExecuteSetupFixtureMethod(context, threadId, fixture, fixtureResult);

      if setupOk and fixture.HasTests then
        ExecuteTests(context, threadId, fixture, fixtureResult);

      if fixture.HasChildFixtures then
        ExecuteFixtures(fixtureResult, context, threadId, fixture.Children);

      // teardown will not run if the fixture setup errored.
      if setupOk and hasActiveTests and Assigned(fixture.TearDownFixtureMethod) then
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
  //A failure here carries what the teardown logged, not the fixture's last test's log.
  ClearLogMessages;
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
    FCurrentTestName := test.Name;
    try
      //Loggers run inside the leak span; what they keep is the runner's memory, not the test's, and what they free
      //(test memory they released) is not credited to the runner.
      BeginRunnerAllocation;
      try
        Self.Loggers_ExecuteTest(threadId, test as ITestInfo);
      finally
        EndRunnerAllocation(True);
      end;
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
      ClearLogMessages;
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

    //Each result carries what its own Setup, test and TearDown logged. Cleared here, before any measurement starts,
    //rather than once the test starts, which lost what Setup logged and left a failed test's log for the next
    //test's Setup error.
    ClearLogMessages;
    memoryAllocationProvider := TDUnitXServiceLocator.DefaultContainer.Resolve<IMemoryLeakMonitor>();
    //A second monitor measures what the runner keeps while the test runs. A singleton registration
    //returns the same monitor, whose readings that would overwrite, so the runner then measures nothing.
    FRunnerAllocationMonitor := TDUnitXServiceLocator.DefaultContainer.Resolve<IMemoryLeakMonitor>();
    if FRunnerAllocationMonitor = memoryAllocationProvider then
      FRunnerAllocationMonitor := nil;
    FRunnerAllocated := 0;
    FRunnerAllocationDepth := 0;
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

      BeginRunnerAllocation;
      try
        Self.Loggers_EndSetupTest(threadId, test as ITestInfo);
      finally
        EndRunnerAllocation(True);
      end;
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
    BeginRunnerAllocation;
    try
      Self.Loggers_TeardownTest(threadId, test as ITestInfo);
    finally
      EndRunnerAllocation(True);
    end;

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
  //Nested calls (a logger that logs) are measured once, by the outermost pair.
  Inc(FRunnerAllocationDepth);
  if (FRunnerAllocationDepth = 1) and (FRunnerAllocationMonitor <> nil) then
    FRunnerAllocationMonitor.PreTest;
end;

procedure TDUnitXTestRunner.EndRunnerAllocation(const onlyGrowth : boolean);
var
  allocated : Int64;
begin
  Dec(FRunnerAllocationDepth);
  if (FRunnerAllocationDepth = 0) and (FRunnerAllocationMonitor <> nil) then
  begin
    FRunnerAllocationMonitor.PostTest;
    allocated := FRunnerAllocationMonitor.TestMemoryAllocated;
    if (allocated > 0) or (not onlyGrowth) then
      Inc(FRunnerAllocated, allocated);
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

procedure TDUnitXTestRunner.ClearLogMessages;
begin
  FLogMessages.Clear;
  SetLength(FLogMessagesEx, 0);
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

