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
{ This unit is contains ideas borrowed largely from NUnit                   }
{ Copyright © 2012-2014 Charlie Poole                                       }
{ License  : http://nunit.org/index.php?p=vsTestAdapterLicense&r=2.6.3      }
{                                                                           }
{***************************************************************************}

unit DUnitX.TestFramework;

interface

{$I DUnitX.inc}

uses
{$IFDEF USE_NS}
  System.Classes,
  System.SysUtils,
  System.SyncObjs,
  System.TypInfo,
  System.Rtti,
  System.TimeSpan,
  System.Generics.Collections,
{$ELSE}
  Classes,
  SysUtils,
  SyncObjs,
  TypInfo,
  Rtti,
  TimeSpan,
  Generics.Collections,
{$ENDIF}
  DUnitX.Assert,
  DUnitX.Assert.Ex,
  DUnitX.Attributes,
  DUnitX.Generics,
  DUnitX.Extensibility,
  DUnitX.Filters,
  DUnitX.ComparableFormat,
  DUnitX.Exceptions,
  DUnitX.Types;

{$HPPEMIT '#if defined(USEPACKAGES)'}
{$HPPEMIT '# pragma comment(lib, "DUnitXRuntime.bpi")'}
{$HPPEMIT '#else'}
{$HPPEMIT '# pragma comment(lib, "DUnitXRuntime")'}
{$HPPEMIT '#endif'}

type
  /// <summary>Re-export of <c>DUnitX.Attributes.TestFixtureAttribute</c>: marks a class as a test fixture.</summary>
  TestFixtureAttribute = DUnitX.Attributes.TestFixtureAttribute;
  /// <summary>Re-export of <c>DUnitX.Attributes.TestInOwnThreadAttribute</c>: runs each test of the fixture in its own thread.</summary>
  TestInOwnThreadAttribute = DUnitX.Attributes.TestInOwnThreadAttribute;
  /// <summary>Re-export of <c>DUnitX.Attributes.SetupFixtureAttribute</c>: marks the method run once before the fixture's tests.</summary>
  SetupFixtureAttribute = DUnitX.Attributes.SetupFixtureAttribute;
  /// <summary>Re-export of <c>DUnitX.Attributes.SetupAttribute</c>: marks the method run before each test.</summary>
  SetupAttribute = DUnitX.Attributes.SetupAttribute;
  /// <summary>Re-export of <c>DUnitX.Attributes.TearDownAttribute</c>: marks the method run after each test.</summary>
  TearDownAttribute = DUnitX.Attributes.TearDownAttribute;
  /// <summary>Re-export of <c>DUnitX.Attributes.TearDownFixtureAttribute</c>: marks the method run once after the fixture's tests.</summary>
  TearDownFixtureAttribute = DUnitX.Attributes.TearDownFixtureAttribute;
  /// <summary>Re-export of <c>DUnitX.Attributes.IgnoreMemoryLeaks</c>: stops memory leaks being reported for a test or fixture.</summary>
  IgnoreMemoryLeaks = DUnitX.Attributes.IgnoreMemoryLeaks;
  /// <summary>Re-export of <c>DUnitX.Attributes.TestAttribute</c>: marks a method as a test.</summary>
  TestAttribute = DUnitX.Attributes.TestAttribute;
  /// <summary>Re-export of <c>DUnitX.Attributes.CategoryAttribute</c>: assigns categories used by include/exclude filters.</summary>
  CategoryAttribute = DUnitX.Attributes.CategoryAttribute;
  /// <summary>Re-export of <c>DUnitX.Attributes.IgnoreAttribute</c>: skips a test or fixture and reports it as ignored.</summary>
  IgnoreAttribute = DUnitX.Attributes.IgnoreAttribute;
  /// <summary>Re-export of <c>DUnitX.Attributes.RepeatTestAttribute</c>: runs a test a given number of times.</summary>
  RepeatTestAttribute = DUnitX.Attributes.RepeatTestAttribute;
  /// <summary>Re-export of <c>DUnitX.Attributes.MaxTimeAttribute</c>: fails a test that runs longer than a limit.</summary>
  MaxTimeAttribute = DUnitX.Attributes.MaxTimeAttribute;
  /// <summary>Re-export of <c>DUnitX.Attributes.WillRaiseAttribute</c>: passes a test only when it raises a given exception.</summary>
  WillRaiseAttribute = DUnitX.Attributes.WillRaiseAttribute;
  /// <summary>Re-export of <c>DUnitX.Attributes.TestCaseInfo</c>: the name and arguments of one test case.</summary>
  TestCaseInfo = DUnitX.Attributes.TestCaseInfo;
  /// <summary>Re-export of <c>DUnitX.Attributes.TestCaseInfoArray</c>: the cases a custom test-case source returns.</summary>
  TestCaseInfoArray = DUnitX.Attributes.TestCaseInfoArray;

  /// <summary>Re-export of <c>DUnitX.Attributes.CustomTestCaseAttribute</c>: base for attributes that supply one test case.</summary>
  CustomTestCaseAttribute = DUnitX.Attributes.CustomTestCaseAttribute;
  /// <summary>Re-export of <c>DUnitX.Attributes.CustomTestCaseSourceAttribute</c>: base for attributes that supply many test cases.</summary>
  CustomTestCaseSourceAttribute = DUnitX.Attributes.CustomTestCaseSourceAttribute;
  /// <summary>Re-export of <c>DUnitX.Attributes.TestCaseAttribute</c>: a named test case with its arguments.</summary>
  TestCaseAttribute = DUnitX.Attributes.TestCaseAttribute;
  /// <summary>Re-export of <c>DUnitX.Attributes.AutoNameTestCaseAttribute</c>: a test case named from its arguments.</summary>
  AutoNameTestCaseAttribute = DUnitX.Attributes.AutoNameTestCaseAttribute;
  /// <summary>Re-export of <c>DUnitX.Attributes.TestCaseProviderAttribute</c>: takes a test's cases from a registered provider.</summary>
  TestCaseProviderAttribute = DUnitX.Attributes.TestCaseProviderAttribute;

  /// <summary>Re-export of <c>DUnitX.Types.TExceptionInheritance</c>: whether an expected exception must match exactly or may descend.</summary>
  TExceptionInheritance = DUnitX.Types.TExceptionInheritance;

  /// <summary>Re-export of <c>DUnitX.Extensibility.TTestMethod</c>: a parameterless method of an object.</summary>
  TTestMethod = DUnitX.Extensibility.TTestMethod;

  /// <summary>
  ///   An anonymous parameterless procedure, as passed to the <c>Assert.WillRaise</c> family.
  /// </summary>
  TTestLocalMethod = TProc;

{$SCOPEDENUMS ON}
  /// <summary>
  ///   Severity of a log message; messages below <c>TDUnitX.Options.LogLevel</c> are dropped.
  /// </summary>
  TLogLevel = (
    /// <summary>Informational output, including redirected <c>WriteLn</c> and <c>Status</c>.</summary>
    Information,
    /// <summary>Something worth attention that does not fail a test.</summary>
    Warning,
    /// <summary>A failure, error or leak.</summary>
    Error
  );
{$SCOPEDENUMS OFF}

  /// <summary>
  ///   One message logged while a test, setup or teardown ran.
  /// </summary>
  TLogMessage = record
    /// <summary>Severity of the message.</summary>
    Level : TLogLevel;
    /// <summary>Text of the message.</summary>
    Msg : string;
  end;

  /// <summary>
  ///   The messages logged while a test, setup or teardown ran, in logging order.
  /// </summary>
  TLogMessageArray = array of TLogMessage;

{$IFDEF DELPHI_2010}
  /// <summary>Thread identifier type, missing from Delphi 2010's RTL.</summary>
  TThreadID = Cardinal;
{$ENDIF}

const
  /// <summary>Short display text for each log level.</summary>
  TLogLevelDesc     : array[TLogLevel] of string = ('Info', 'Warn', 'Err');

  /// <summary>Re-export of <c>DUnitX.Types.exExact</c>: the raised exception must be exactly the expected class.</summary>
  exExact           = DUnitX.Types.exExact;
  /// <summary>Re-export of <c>DUnitX.Types.exDescendant</c>: the raised exception may descend from the expected class.</summary>
  exDescendant      = DUnitX.Types.exDescendant;

type
{$IFDEF DELPHI_XE2_UP}
  /// <summary>
  ///   Class helper that redirects <c>Log</c>, <c>Status</c> and <c>WriteLn</c> called inside a test fixture to the
  ///   test runner active on the calling thread, so the output is logged against the running test.
  /// </summary>
  TTestFixtureHelper = class helper for TObject
  public
    /// <summary>
    ///   Logs a message through the thread's active runner, or writes it to standard output when no runner is active.
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
    procedure Status(const msg : string);
    /// <summary>
    ///   Redirects <c>WriteLn</c> to the runner's loggers, at <c>Information</c> level.
    /// </summary>
    /// <param name="msg">
    ///   The line to write.
    /// </param>
    procedure WriteLn(const msg : string); overload;
    /// <summary>
    ///   Redirects an empty <c>WriteLn</c> to the runner's loggers, at <c>Information</c> level.
    /// </summary>
    procedure WriteLn; overload;
  end;
{$ENDIF}

  /// <summary>
  ///   The assertion class tests call (<c>Assert.AreEqual</c>, <c>Assert.IsTrue</c>, <c>Assert.WillRaise</c> and the
  ///   rest). A failed assertion raises <c>ETestFailure</c>, <c>Assert.Pass</c> raises <c>ETestPass</c> and
  ///   <c>Assert.Ignore</c> raises <c>ETestIgnored</c>; the runner turns each into the test's result.
  /// </summary>
  /// <remarks>
  ///   Declared as a descendant of <c>DUnitX.Assert.Ex.Assert</c> rather than an alias because the redeclaration
  ///   raises an internal compiler error.
  /// </remarks>
  Assert = class(DUnitX.Assert.Ex.Assert);

{$M+}
  /// <summary>
  ///   Forward declaration of the read-only fixture description, declared in full below.
  /// </summary>
  ITestFixtureInfo = interface;
{$M-}

{$M+}
  /// <summary>
  ///   Read-only description of a test, as loggers and results see it.
  /// </summary>
  ITestInfo = interface
    ['{FF61A6EB-A76B-4BE7-887A-598EBBAE5611}']
    /// <summary>
    ///   Gives the test's display name.
    /// </summary>
    /// <returns>
    ///   The name.
    /// </returns>
    function GetName : string;
    /// <summary>
    ///   Gives the test's name qualified by its fixture.
    /// </summary>
    /// <returns>
    ///   The full name.
    /// </returns>
    function GetFullName : string;
    /// <summary>
    ///   Gives the name of the method that implements the test.
    /// </summary>
    /// <returns>
    ///   The method name.
    /// </returns>
    function GetMethodName : string;
    /// <summary>
    ///   Gives the categories the test belongs to.
    /// </summary>
    /// <returns>
    ///   The category list, owned by the test.
    /// </returns>
    function GetCategories : TList<string>;
    /// <summary>
    ///   Reports whether the test is active.
    /// </summary>
    /// <returns>
    ///   Always True in the framework's implementation; the active state is not tracked.
    /// </returns>
    function GetActive : boolean;
    /// <summary>
    ///   Gives the fixture the test belongs to.
    /// </summary>
    /// <returns>
    ///   The owning fixture.
    /// </returns>
    function GetTestFixture : ITestFixtureInfo;

    /// <summary>
    ///   Gives the time the test last started.
    /// </summary>
    /// <returns>
    ///   The start time.
    /// </returns>
    function GetTestStartTime : TDateTime;
    /// <summary>
    ///   Gives the time the test last finished.
    /// </summary>
    /// <returns>
    ///   The end time.
    /// </returns>
    function GetTestEndTime : TDateTime;
    /// <summary>
    ///   Gives how long the test last took.
    /// </summary>
    /// <returns>
    ///   The duration.
    /// </returns>
    function GetTestDuration : TTimeSpan;

    /// <summary>
    ///   Reports whether the test is selected to run.
    /// </summary>
    /// <returns>
    ///   True when the test is enabled.
    /// </returns>
    function GetEnabled : boolean;
    /// <summary>
    ///   Selects or deselects the test for running; the GUI runner uses it to pick tests.
    /// </summary>
    /// <param name="value">
    ///   True to run the test.
    /// </param>
    procedure SetEnabled(const value : boolean);

    /// <summary>The test's display name.</summary>
    property Name : string read GetName;
    /// <summary>The test's name qualified by its fixture.</summary>
    property FullName : string read GetFullName;
    /// <summary>Name of the method that implements the test.</summary>
    property MethodName : string read GetMethodName;
    /// <summary>Whether the test is selected to run.</summary>
    property Enabled : boolean read GetEnabled write SetEnabled;
    /// <summary>Categories the test belongs to.</summary>
    property Categories : TList<string> read GetCategories;

    /// <summary>Whether the test is active; always True in the framework's implementation.</summary>
    property Active : boolean read GetActive;
    /// <summary>The fixture the test belongs to.</summary>
    property Fixture : ITestFixtureInfo read GetTestFixture;
  end;

  /// <summary>
  ///   A list of read-only test descriptions.
  /// </summary>
  ITestInfoList = interface(IList<ITestInfo>)
    ['{1C614DC2-537F-4229-863D-669E4211074E}']
  end;

  /// <summary>
  ///   The concrete list of read-only test descriptions.
  /// </summary>
  TTestInfoList = class(TDUnitXList<ITestInfo>, ITestInfoList);
{$M-}

{$M+}
  /// <summary>
  ///   Read-only description of a test fixture, as loggers and results see it.
  /// </summary>
  ITestFixtureInfo = interface
    ['{9E98B1E8-583A-49FC-B409-9B6937E22E81}']
    /// <summary>
    ///   Gives the fixture's name.
    /// </summary>
    /// <returns>
    ///   The name.
    /// </returns>
    function GetName : string;
    /// <summary>
    ///   Gives the fixture's namespace.
    /// </summary>
    /// <returns>
    ///   The namespace.
    /// </returns>
    function GetNameSpace : string;
    /// <summary>
    ///   Gives the fixture's name qualified by its namespace.
    /// </summary>
    /// <returns>
    ///   The full name.
    /// </returns>
    function GetFullName : string;
    /// <summary>
    ///   Gives the unit that declares the fixture class.
    /// </summary>
    /// <returns>
    ///   The unit name.
    /// </returns>
    function GetUnitName : string;
    /// <summary>
    ///   Gives the categories the fixture belongs to.
    /// </summary>
    /// <returns>
    ///   The category list, owned by the fixture.
    /// </returns>
    function GetCategories : TList<string>;
    /// <summary>
    ///   Gives the fixture's description.
    /// </summary>
    /// <returns>
    ///   The description, possibly empty.
    /// </returns>
    function GetDescription : string;
    /// <summary>
    ///   Gives the fixture's own tests.
    /// </summary>
    /// <returns>
    ///   The tests as read-only descriptions.
    /// </returns>
    function GetTests : IList<ITestInfo>;
    /// <summary>
    ///   Gives the class the fixture instance is created from.
    /// </summary>
    /// <returns>
    ///   The fixture class; <c>TObject</c> for a namespace-only fixture.
    /// </returns>
    function GetTestClass : TClass;
    /// <summary>
    ///   Gives the name of the method run before each test.
    /// </summary>
    /// <returns>
    ///   The <c>[Setup]</c> method name, empty when there is none.
    /// </returns>
    function GetSetupMethodName : string;
    /// <summary>
    ///   Gives the name of the method run once before the fixture's tests.
    /// </summary>
    /// <returns>
    ///   The <c>[SetupFixture]</c> method name, empty when there is none.
    /// </returns>
    function GetSetupFixtureMethodName : string;
    /// <summary>
    ///   Gives the name of the method run after each test.
    /// </summary>
    /// <returns>
    ///   The <c>[TearDown]</c> method name, empty when there is none.
    /// </returns>
    function GetTearDownMethodName : string;
    /// <summary>
    ///   Gives the name of the method run once after the fixture's tests.
    /// </summary>
    /// <returns>
    ///   The <c>[TearDownFixture]</c> method name, empty when there is none.
    /// </returns>
    function GetTearDownFixtureMethodName : string;
    /// <summary>
    ///   Reports whether each test runs in its own thread.
    /// </summary>
    /// <returns>
    ///   True when tests run in their own thread.
    /// </returns>
    function GetTestInOwnThread : boolean;
    /// <summary>
    ///   Reports whether the fixture has nested fixtures.
    /// </summary>
    /// <returns>
    ///   True when there is at least one child fixture.
    /// </returns>
    function GetHasChildren : boolean;

    /// <summary>
    ///   Counts the fixture's own tests, whatever their state.
    /// </summary>
    /// <returns>
    ///   The number of tests.
    /// </returns>
    function GetTestCount : cardinal;
    /// <summary>
    ///   Counts the fixture's own tests that will execute.
    /// </summary>
    /// <returns>
    ///   The number of tests that are enabled and not ignored; 0 when the whole fixture is ignored.
    /// </returns>
    function GetActiveTestCount : cardinal;

    /// <summary>The fixture's name.</summary>
    property Name : string read GetName;
    /// <summary>The fixture's namespace.</summary>
    property NameSpace : string read GetNameSpace;
    /// <summary>The fixture's name qualified by its namespace.</summary>
    property FullName : string read GetFullName;
    /// <summary>The unit that declares the fixture class.</summary>
    property UnitName : string read GetUnitName;
    /// <summary>The fixture's description.</summary>
    property Description : string read GetDescription;
    /// <summary>Whether the fixture has nested fixtures.</summary>
    property HasChildFixtures : boolean read GetHasChildren;
    /// <summary>The class the fixture instance is created from.</summary>
    property TestClass : TClass read GetTestClass;
    /// <summary>The fixture's own tests.</summary>
    property Tests : IList<ITestInfo> read GetTests;
    /// <summary>Name of the method run before each test.</summary>
    property SetupMethodName : string read GetSetupMethodName;
    /// <summary>Name of the method run once before the fixture's tests.</summary>
    property SetupFixtureMethodName : string read GetSetupFixtureMethodName;
    /// <summary>Name of the method run after each test.</summary>
    property TearDownMethodName : string read GetTearDownMethodName;
    /// <summary>Name of the method run once after the fixture's tests.</summary>
    property TearDownFixtureMethodName : string read GetTearDownFixtureMethodName;
    /// <summary>Whether each test runs in its own thread.</summary>
    property TestInOwnThread : boolean read GetTestInOwnThread;
    /// <summary>Categories the fixture belongs to.</summary>
    property Categories : TList<string> read GetCategories;

    /// <summary>Number of the fixture's own tests.</summary>
    property TestCount : cardinal read GetTestCount;
    /// <summary>Number of the fixture's own tests that will execute.</summary>
    property ActiveTestCount : cardinal read GetActiveTestCount;
  end;

  /// <summary>
  ///   A list of read-only fixture descriptions.
  /// </summary>
  ITestFixtureInfoList = interface(IList<ITestFixtureInfo>)
    ['{DEE229E7-1450-4DC1-BEEA-562461439084}']
  end;
{$M-}
  /// <summary>
  ///   The concrete list of read-only fixture descriptions.
  /// </summary>
  TTestFixtureInfoList = class(TDUnitXList<ITestFixtureInfo>, ITestFixtureInfoList);

{$M+}
  /// <summary>
  ///   Timing shared by test, fixture and run results.
  /// </summary>
  IResult = interface
    ['{AEA1E458-157B-4B3A-9474-44EDFB3EE7A1}']
    /// <summary>
    ///   Gives the time the item started.
    /// </summary>
    /// <returns>
    ///   The start time.
    /// </returns>
    function GetStartTime : TDateTime;
    /// <summary>
    ///   Gives the time the item finished.
    /// </summary>
    /// <returns>
    ///   The finish time.
    /// </returns>
    function GetFinishTime : TDateTime;
    /// <summary>
    ///   Gives how long the item took.
    /// </summary>
    /// <returns>
    ///   The duration.
    /// </returns>
    function GetDuration : TTimeSpan;

    /// <summary>Time the item started.</summary>
    property StartTime : TDateTime read GetStartTime;
    /// <summary>Time the item finished.</summary>
    property FinishTime : TDateTime read GetFinishTime;
    /// <summary>How long the item took.</summary>
    property Duration : TTimeSpan read GetDuration;
  end;
{$M-}

{$SCOPEDENUMS ON}
  /// <summary>
  ///   The outcome of a test.
  /// </summary>
  TTestResultType = (
    /// <summary>The test completed without a failed assertion or exception.</summary>
    Pass,
    /// <summary>An assertion failed (an <c>ETestFailure</c> was raised), or the test exceeded its time limit.</summary>
    Failure,
    /// <summary>An unexpected exception was raised by the test, its setup or teardown, or the fixture.</summary>
    Error,
    /// <summary>The test was skipped, by attribute or by <c>Assert.Ignore</c>.</summary>
    Ignored,
    /// <summary>The test passed but leaked memory.</summary>
    MemoryLeak,
    /// <summary>
    ///   A warning; never produced by the runner. The VCL GUI runner files a no-assertions failure under it.
    /// </summary>
    Warning
  );
{$M+}
  /// <summary>
  ///   The outcome of one test.
  /// </summary>
  ITestResult = interface(IResult)
    ['{EFD44ABA-4F3E-435C-B8FC-1F8EB4B35A3B}']
    /// <summary>
    ///   Gives the test the result belongs to.
    /// </summary>
    /// <returns>
    ///   The test, or nil when it has already been destroyed (results hold their test weakly).
    /// </returns>
    function GetTest : ITestInfo;
    /// <summary>
    ///   Reports whether the test passed.
    /// </summary>
    /// <returns>
    ///   True only for a <c>Pass</c> result.
    /// </returns>
    function GetResult : boolean;
    /// <summary>
    ///   Gives the outcome.
    /// </summary>
    /// <returns>
    ///   The result type.
    /// </returns>
    function GetResultType : TTestResultType;
    /// <summary>
    ///   Gives the result's message: the assertion or exception message, the ignore reason, or a pass message.
    /// </summary>
    /// <returns>
    ///   The message.
    /// </returns>
    function GetMessage : string;
    /// <summary>
    ///   Gives the messages logged while the test, its setup and teardown ran.
    /// </summary>
    /// <returns>
    ///   The log messages.
    /// </returns>
    function GetLogMessages : TLogMessageArray;
    /// <summary>
    ///   Gives the stack trace captured for the result.
    /// </summary>
    /// <returns>
    ///   The stack trace, empty unless a stack-trace provider is registered and the result came from an exception.
    /// </returns>
    function GetStackTrace : string;

    /// <summary>The test the result belongs to; nil once the test is destroyed.</summary>
    property Test : ITestInfo read GetTest;

    /// <summary>Whether the test passed.</summary>
    property Result : boolean read GetResult;
    /// <summary>The outcome.</summary>
    property ResultType : TTestResultType read GetResultType;
    /// <summary>The result's message.</summary>
    property Message : string read GetMessage;
    /// <summary>Messages logged while the test ran.</summary>
    property LogMessages : TLogMessageArray read GetLogMessages;
    /// <summary>The stack trace captured for the result.</summary>
    property StackTrace : string read GetStackTrace;

  end;
{$M-}

  /// <summary>
  ///   A test result caused by an exception: a failure or an error. Carries the exception details and, for a
  ///   string-comparison failure, the expected and actual values.
  /// </summary>
  ITestError = interface(ITestResult)
    ['{375941C6-CEFD-44E5-9646-30D7915B8A71}']
    /// <summary>
    ///   Gives the class of the exception that ended the test.
    /// </summary>
    /// <returns>
    ///   The exception class.
    /// </returns>
    function GetExceptionClass : ExceptClass;
    /// <summary>
    ///   Gives the exception's message, combined with the user message.
    /// </summary>
    /// <returns>
    ///   The exception message.
    /// </returns>
    function GetExceptionMessage : string;
    /// <summary>
    ///   Gives the source location of the exception, as resolved by the registered stack-trace provider.
    /// </summary>
    /// <returns>
    ///   The location text, empty when no provider is registered.
    /// </returns>
    function GetExceptionLocationInfo : string;
    /// <summary>
    ///   Gives the address of the exception, as formatted by the registered stack-trace provider.
    /// </summary>
    /// <returns>
    ///   The address text, empty when no provider is registered.
    /// </returns>
    function GetExceptionAddressInfo : string;
    /// <summary>
    ///   Gives the raw address the exception was raised at.
    /// </summary>
    /// <returns>
    ///   The exception address.
    /// </returns>
    function GetExceptionAddress : Pointer;
    /// <summary>
    ///   Reports whether the failure carries expected and actual values for comparison.
    /// </summary>
    /// <returns>
    ///   True for a string-comparison failure.
    /// </returns>
    function GetIsComparable : boolean;
    /// <summary>
    ///   Gives the expected value of a comparison failure.
    /// </summary>
    /// <returns>
    ///   The expected text, empty when not comparable.
    /// </returns>
    function GetExpected : string;
    /// <summary>
    ///   Gives the actual value of a comparison failure.
    /// </summary>
    /// <returns>
    ///   The actual text, empty when not comparable.
    /// </returns>
    function GetActual : string;
    /// <summary>
    ///   Gives the format class for displaying a comparison failure.
    /// </summary>
    /// <returns>
    ///   The format class, nil when not comparable.
    /// </returns>
    function GetFormat : TDUnitXComparableFormatClass;

    /// <summary>Class of the exception that ended the test.</summary>
    property ExceptionClass : ExceptClass read GetExceptionClass;
    /// <summary>The exception's message.</summary>
    property ExceptionMessage : string read GetExceptionMessage;
    /// <summary>Source location of the exception.</summary>
    property ExceptionLocationInfo : string read GetExceptionLocationInfo;
    /// <summary>Formatted address of the exception.</summary>
    property ExceptionAddressInfo : string read GetExceptionAddressInfo;
    /// <summary>Raw address the exception was raised at.</summary>
    property ExceptionAddress : Pointer read GetExceptionAddress;
    /// <summary>Whether expected and actual values are available.</summary>
    property IsComparable : boolean read GetIsComparable;
    /// <summary>Expected value of a comparison failure.</summary>
    property Expected : string read GetExpected;
    /// <summary>Actual value of a comparison failure.</summary>
    property Actual : string read GetActual;
    /// <summary>Format class for displaying a comparison failure.</summary>
    property Format : TDUnitXComparableFormatClass read GetFormat;
  end;

  /// <summary>
  ///   The result of one fixture: its own test results, the results of nested fixtures and the outcome counts.
  /// </summary>
  IFixtureResult = interface(IResult)
    ['{7264579D-495E-4E00-A15D-751E6A65BEF6}']
    /// <summary>
    ///   Counts tests that ended in an error.
    /// </summary>
    /// <returns>
    ///   The error count, including nested fixtures once rolled up.
    /// </returns>
    function GetErrorCount : integer;
    /// <summary>
    ///   Counts tests that failed.
    /// </summary>
    /// <returns>
    ///   The failure count, including nested fixtures once rolled up.
    /// </returns>
    function GetFailureCount : integer;
    /// <summary>
    ///   Counts tests that were ignored.
    /// </summary>
    /// <returns>
    ///   The ignored count, including nested fixtures once rolled up.
    /// </returns>
    function GetIgnoredCount : integer;
    /// <summary>
    ///   Counts tests that passed.
    /// </summary>
    /// <returns>
    ///   The pass count, including nested fixtures once rolled up.
    /// </returns>
    function GetPassCount : integer;
    /// <summary>
    ///   Reports whether the fixture did not succeed.
    /// </summary>
    /// <returns>
    ///   True when any test failed, errored or leaked memory.
    /// </returns>
    function GetHasFailures : boolean;
    /// <summary>
    ///   Counts the fixture's own test results.
    /// </summary>
    /// <returns>
    ///   The number of results.
    /// </returns>
    function GetTestResultCount : integer;
    /// <summary>
    ///   Counts the nested fixture results.
    /// </summary>
    /// <returns>
    ///   The number of children.
    /// </returns>
    function GetChildCount : integer;

    /// <summary>
    ///   Gives the fixture the result describes.
    /// </summary>
    /// <returns>
    ///   The fixture.
    /// </returns>
    function GetFixture : ITestFixtureInfo;
    /// <summary>
    ///   Gives the fixture's own test results.
    /// </summary>
    /// <returns>
    ///   The results, never nil.
    /// </returns>
    function GetTestResults : IList<ITestResult>;
    /// <summary>
    ///   Gives the nested fixture results.
    /// </summary>
    /// <returns>
    ///   The children, never nil.
    /// </returns>
    function GetChildren : IList<IFixtureResult>;
    /// <summary>
    ///   Collects the fixture's own failed results.
    /// </summary>
    /// <returns>
    ///   A new list of the failures.
    /// </returns>
    function GetFailures : IList<ITestResult>;
    /// <summary>
    ///   Collects the fixture's own results that carry exception details.
    /// </summary>
    /// <returns>
    ///   A new list of the results supporting <c>ITestError</c>.
    /// </returns>
    function GetErrors : IList<ITestError>;
    /// <summary>
    ///   Collects the fixture's own passed results.
    /// </summary>
    /// <returns>
    ///   A new list of the passes.
    /// </returns>
    function GetPasses : IList<ITestResult>;
    /// <summary>
    ///   Gives the fixture's name.
    /// </summary>
    /// <returns>
    ///   The name.
    /// </returns>
    function GetName : string;
    /// <summary>
    ///   Gives the fixture's namespace.
    /// </summary>
    /// <returns>
    ///   The namespace.
    /// </returns>
    function GetNamespace : string;
    /// <summary>
    ///   Collapses namespace levels that hold no tests and a single child into that child, recursively.
    /// </summary>
    procedure Reduce;

    /// <summary>Whether any test failed, errored or leaked.</summary>
    property HasFailures : Boolean read GetHasFailures;
    /// <summary>Number of failed tests.</summary>
    property FailureCount : integer read GetFailureCount;
    /// <summary>Number of tests that errored.</summary>
    property ErrorCount : integer read GetErrorCount;
    /// <summary>Number of ignored tests.</summary>
    property IgnoredCount : integer read GetIgnoredCount;
    /// <summary>Number of passed tests.</summary>
    property PassCount : integer read GetPassCount;
    /// <summary>Number of the fixture's own test results.</summary>
    property ResultCount : integer read GetTestResultCount;
    /// <summary>Number of nested fixture results.</summary>
    property ChildCount : integer read GetChildCount;

    /// <summary>The fixture's name.</summary>
    property Name : string read GetName;
    /// <summary>The fixture's namespace.</summary>
    property Namespace : string read GetNamespace;
    /// <summary>The fixture the result describes.</summary>
    property Fixture : ITestFixtureInfo read GetFixture;
    /// <summary>The nested fixture results.</summary>
    property Children : IList<IFixtureResult> read GetChildren;
    /// <summary>The fixture's own test results.</summary>
    property TestResults : IList<ITestResult> read GetTestResults;
    /// <summary>The fixture's own failed results.</summary>
    property Failures : IList<ITestResult> read GetFailures;
    /// <summary>The fixture's own results that carry exception details.</summary>
    property Errors : IList<ITestError> read GetErrors;
    /// <summary>The fixture's own passed results.</summary>
    property Passes : IList<ITestResult> read GetPasses;
  end;

{$M+}
  /// <summary>
  ///   The results of a whole run, handed to <c>ITestLogger.OnTestingEnds</c> and returned by
  ///   <c>ITestRunner.Execute</c>.
  /// </summary>
  IRunResults = interface(IResult)
    ['{4A335B76-33E3-48FD-87DF-9462428C60DA}']
    /// <summary>
    ///   Counts the top-level fixture results.
    /// </summary>
    /// <returns>
    ///   The fixture count.
    /// </returns>
    function GetFixtureCount : integer;
    /// <summary>
    ///   Counts every test result of the run.
    /// </summary>
    /// <returns>
    ///   The test count, whatever the outcomes.
    /// </returns>
    function GetTestCount : integer;
    /// <summary>
    ///   Reports whether the run passed.
    /// </summary>
    /// <returns>
    ///   True when no test failed, errored or leaked and at least one test actually ran.
    /// </returns>
    function GetAllPassed : boolean;
    /// <summary>
    ///   Counts failed tests.
    /// </summary>
    /// <returns>
    ///   The failure count.
    /// </returns>
    function GetFailureCount : integer;
    /// <summary>
    ///   Counts tests that errored.
    /// </summary>
    /// <returns>
    ///   The error count.
    /// </returns>
    function GetErrorCount : integer;
    /// <summary>
    ///   Counts tests that leaked memory.
    /// </summary>
    /// <returns>
    ///   The memory-leak count.
    /// </returns>
    function GetMemoryLeakCount : Integer;
    /// <summary>
    ///   Counts passed tests.
    /// </summary>
    /// <returns>
    ///   The pass count.
    /// </returns>
    function GetPassCount : integer;
    /// <summary>
    ///   Counts ignored tests.
    /// </summary>
    /// <returns>
    ///   The ignored count.
    /// </returns>
    function GetIgnoredCount : integer;
    /// <summary>
    ///   Computes the percentage of tests that neither failed nor errored.
    /// </summary>
    /// <returns>
    ///   The truncated percentage, 100 when no test ran.
    /// </returns>
    function GetSuccessRate : integer;

    /// <summary>
    ///   Gives the top-level fixture results.
    /// </summary>
    /// <returns>
    ///   The fixture results.
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
    ///   Summarises the run as text.
    /// </summary>
    /// <returns>
    ///   A short summary.
    /// </returns>
    function ToString : string;

    /// <summary>Number of test results.</summary>
    property TestCount : integer read GetTestCount;
    /// <summary>Number of top-level fixture results.</summary>
    property FixtureCount : integer read GetFixtureCount;

    /// <summary>Number of failed tests.</summary>
    property FailureCount : integer read GetFailureCount;
    /// <summary>Number of tests that errored.</summary>
    property ErrorCount : integer read GetErrorCount;
    /// <summary>Number of ignored tests.</summary>
    property IgnoredCount : integer read GetIgnoredCount;
    /// <summary>Number of passed tests.</summary>
    property PassCount : integer read GetPassCount;
    /// <summary>Number of tests that leaked memory.</summary>
    property MemoryLeakCount : integer read GetMemoryLeakCount;

    /// <summary>Percentage of tests that neither failed nor errored.</summary>
    property SuccessRate : integer read GetSuccessRate;
    /// <summary>
    ///   True when all enabled, not ignored tests passed and at least one ran.
    /// </summary>
    property AllPassed : boolean read GetAllPassed;

    /// <summary>The top-level fixture results.</summary>
    property FixtureResults : IEnumerable<IFixtureResult> read GetFixtureResults;
  end;
{$M-}

  /// <summary>
  ///   Receives notification of every step of a test run. Implement it to report results (console, XML, GUI); attach
  ///   it with <c>ITestRunner.AddLogger</c>. Calls arrive in the order the methods are declared here.
  /// </summary>
  ITestLogger = interface
    ['{AADCA392-421C-4060-8D47-79D7CAAB0EEF}']

    /// <summary>
    ///   Called at the start of testing. The default console logger prints the DUnitX banner.
    /// </summary>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="testCount">
    ///   Number of tests selected by the filter.
    /// </param>
    /// <param name="testActiveCount">
    ///   Number of those tests that are not ignored.
    /// </param>
    procedure OnTestingStarts(const threadId : TThreadID; testCount, testActiveCount : Cardinal);

    /// <summary>
    ///   Called before a fixture is run.
    /// </summary>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="fixture">
    ///   The fixture.
    /// </param>
    procedure OnStartTestFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);

    /// <summary>
    ///   Called before a fixture's <c>[SetupFixture]</c> method is run.
    /// </summary>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="fixture">
    ///   The fixture.
    /// </param>
    procedure OnSetupFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);

    /// <summary>
    ///   Called after a fixture's <c>[SetupFixture]</c> method has run successfully.
    /// </summary>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="fixture">
    ///   The fixture.
    /// </param>
    procedure OnEndSetupFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);

    /// <summary>
    ///   Called when a test begins, before its setup method.
    /// </summary>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="Test">
    ///   The test.
    /// </param>
    procedure OnBeginTest(const threadId : TThreadID; const Test : ITestInfo);

    /// <summary>
    ///   Called before a test's <c>[Setup]</c> method is run.
    /// </summary>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="Test">
    ///   The test.
    /// </param>
    procedure OnSetupTest(const threadId : TThreadID; const Test : ITestInfo);

    /// <summary>
    ///   Called after a test's <c>[Setup]</c> method has run successfully.
    /// </summary>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="Test">
    ///   The test.
    /// </param>
    procedure OnEndSetupTest(const threadId : TThreadID; const Test : ITestInfo);

    /// <summary>
    ///   Called immediately before the test method is run.
    /// </summary>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="Test">
    ///   The test.
    /// </param>
    procedure OnExecuteTest(const threadId : TThreadID; const Test : ITestInfo);

    /// <summary>
    ///   Called when a test succeeds.
    /// </summary>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="Test">
    ///   The passing result.
    /// </param>
    procedure OnTestSuccess(const threadId : TThreadID; const Test : ITestResult);

    /// <summary>
    ///   Called when a test errors.
    /// </summary>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="Error">
    ///   The error result.
    /// </param>
    procedure OnTestError(const threadId : TThreadID; const Error : ITestError);

    /// <summary>
    ///   Called when a test fails.
    /// </summary>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="Failure">
    ///   The failure result.
    /// </param>
    procedure OnTestFailure(const threadId : TThreadID; const Failure : ITestError);

    /// <summary>
    ///   Called when a test is ignored.
    /// </summary>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="AIgnored">
    ///   The ignored result; its message is the ignore reason.
    /// </param>
    procedure OnTestIgnored(const threadId : TThreadID; const AIgnored : ITestResult);

    /// <summary>
    ///   Called when a test leaks memory.
    /// </summary>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="Test">
    ///   The memory-leak result; its message gives the bytes leaked.
    /// </param>
    procedure OnTestMemoryLeak(const threadId : TThreadID; const Test : ITestResult);

    /// <summary>
    ///   Called for every message logged at or above <c>TDUnitX.Options.LogLevel</c>, which lets tests write to the
    ///   log.
    /// </summary>
    /// <param name="logType">
    ///   The log level.
    /// </param>
    /// <param name="msg">
    ///   The message.
    /// </param>
    procedure OnLog(const logType : TLogLevel; const msg : string);

    /// <summary>
    ///   Called before a test's <c>[TearDown]</c> method is run.
    /// </summary>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="Test">
    ///   The test.
    /// </param>
    procedure OnTeardownTest(const threadId : TThreadID; const Test : ITestInfo);

    /// <summary>
    ///   Called after a test's <c>[TearDown]</c> method has run successfully.
    /// </summary>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="Test">
    ///   The test.
    /// </param>
    procedure OnEndTeardownTest(const threadId : TThreadID; const Test : ITestInfo);

    /// <summary>
    ///   Called after a test method and its teardown have run, with the test's final result.
    /// </summary>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="Test">
    ///   The final result.
    /// </param>
    procedure OnEndTest(const threadId : TThreadID; const Test : ITestResult);

    /// <summary>
    ///   Called before a fixture's <c>[TearDownFixture]</c> method is called.
    /// </summary>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="fixture">
    ///   The fixture.
    /// </param>
    procedure OnTearDownFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);

    /// <summary>
    ///   Called after a fixture's <c>[TearDownFixture]</c> method has completed successfully.
    /// </summary>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="fixture">
    ///   The fixture.
    /// </param>
    procedure OnEndTearDownFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);

    /// <summary>
    ///   Called after a fixture, including its nested fixtures, has run.
    /// </summary>
    /// <param name="threadId">
    ///   Thread the run executes on.
    /// </param>
    /// <param name="results">
    ///   The fixture's rolled-up result.
    /// </param>
    procedure OnEndTestFixture(const threadId : TThreadID; const results : IFixtureResult);

    /// <summary>
    ///   Called after all fixtures have run; also called when an exception aborts a run that has started.
    /// </summary>
    /// <param name="RunResults">
    ///   The results of the whole run.
    /// </param>
    procedure OnTestingEnds(const RunResults : IRunResults);
  end;

  /// <summary>
  ///   What a console runner does once it has displayed its results.
  /// </summary>
  TDUnitXExitBehavior = (
    /// <summary>The runner exits normally.</summary>
    Continue,
    /// <summary>The runner pauses after displaying its results.</summary>
    Pause
  );

  /// <summary>
  ///   Whether and how a console logger is created.
  /// </summary>
  TDunitXConsoleMode = (
    /// <summary>Do not create a console logger.</summary>
    Off,
    /// <summary>Create a console logger in quiet mode.</summary>
    Quiet,
    /// <summary>Create a console logger in verbose mode.</summary>
    Verbose
  );

  /// <summary>
  ///   Runs the registered test fixtures and reports to the attached loggers. Create one with
  ///   <c>TDUnitX.CreateRunner</c>.
  /// </summary>
  ITestRunner = interface
    ['{06C0D8D2-B2D7-42F9-8D23-8F2D8A75263F}']
    /// <summary>
    ///   Attaches a logger; one already attached is not added twice.
    /// </summary>
    /// <param name="value">
    ///   The logger to add.
    /// </param>
    procedure AddLogger(const value : ITestLogger);

    /// <summary>
    ///   Reports whether fixtures are discovered through RTTI.
    /// </summary>
    /// <returns>
    ///   The <c>UseRTTI</c> setting.
    /// </returns>
    function GetUseRTTI : boolean;
    /// <summary>
    ///   Sets whether fixtures are discovered through RTTI.
    /// </summary>
    /// <param name="value">
    ///   True to discover fixtures through RTTI.
    /// </param>
    procedure SetUseRTTI(const value : boolean);

    /// <summary>
    ///   Reports whether a test that makes no assertion fails.
    /// </summary>
    /// <returns>
    ///   The <c>FailsOnNoAsserts</c> setting.
    /// </returns>
    function GetFailsOnNoAsserts : boolean;
    /// <summary>
    ///   Sets whether a test that makes no assertion fails.
    /// </summary>
    /// <param name="value">
    ///   True to fail such tests.
    /// </param>
    procedure SetFailsOnNoAsserts(const value : boolean);

    /// <summary>
    ///   Gives the name of the test currently executing.
    /// </summary>
    /// <returns>
    ///   The test name, empty between tests.
    /// </returns>
    function CurrentTestName : string;

    /// <summary>
    ///   Builds the fixture tree without running it. Exposed for the GUI runner, which casts the result to
    ///   <c>ITestFixtureList</c>.
    /// </summary>
    /// <returns>
    ///   The fixture list, as an <c>IInterface</c>.
    /// </returns>
    function BuildFixtures : IInterface;

    /// <summary>
    ///   Runs the tests selected by <c>TDUnitX.Filter</c> and reports to the loggers.
    /// </summary>
    /// <returns>
    ///   The results of the run.
    /// </returns>
    /// <exception cref="ENoTestsRegistered">
    ///   Raised when no fixture was found.
    /// </exception>
    function Execute : IRunResults;

    /// <summary>
    ///   Logs a message at a level to the current result and the loggers.
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
    procedure Status(const msg : string);
    /// <summary>
    ///   Redirects <c>WriteLn</c> to the loggers.
    /// </summary>
    /// <param name="msg">
    ///   The line to write.
    /// </param>
    procedure WriteLn(const msg : string); overload;
    /// <summary>
    ///   Redirects an empty <c>WriteLn</c> to the loggers.
    /// </summary>
    procedure WriteLn; overload;

    /// <summary>
    ///   When True, test fixtures are found by using RTTI to search for classes decorated as TestFixtures. For this
    ///   to work you may need <c>{$STRONGLINKTYPES ON}</c>, otherwise the classes may not be linked because nothing
    ///   references them. When False, register the fixtures with <c>TDUnitX.RegisterTestFixture</c>.
    /// </summary>
    property UseRTTI : boolean read GetUseRTTI write SetUseRTTI;

    /// <summary>Whether a test that makes no assertion fails with <c>ENoAssertionsMade</c>.</summary>
    property FailsOnNoAsserts : boolean read GetFailsOnNoAsserts write SetFailsOnNoAsserts;
  end;

  /// <summary>
  ///   The run options, mostly set from the command line by <c>TDUnitX.CheckCommandLine</c>.
  /// </summary>
  TDUnitXOptions = class
  private
    /// <summary>Backing field for <c>XMLOutputFile</c>.</summary>
    FXMLOutputFile : string;
    /// <summary>Backing field for <c>Run</c>; owned.</summary>
    FRun : TStringList;
    /// <summary>Backing field for <c>RunListFile</c>.</summary>
    FRunListFile : string;
    /// <summary>Backing field for <c>Include</c>.</summary>
    FInclude : string;
    /// <summary>Backing field for <c>Exclude</c>.</summary>
    FExclude : string;
    /// <summary>Backing field for <c>LogLevel</c>.</summary>
    FLogLevel : TLogLevel;
    /// <summary>Backing field for <c>HideBanner</c>.</summary>
    FHideBanner : boolean;
    /// <summary>Backing field for <c>ExitBehavior</c>.</summary>
    FExitBehavior : TDUnitXExitBehavior;
    /// <summary>Backing field for <c>ConsoleMode</c>.</summary>
    FConsoleMode : TDunitXConsoleMode;
    /// <summary>Backing field for <c>ShowUsage</c>.</summary>
    FShowUsage : boolean;
    /// <summary>Backing field for <c>DontShowIgnored</c>.</summary>
    FDontShowIgnored : boolean;
  public
    /// <summary>
    ///   Creates the options with their defaults: log level <c>Information</c>, exit behaviour <c>Continue</c>,
    ///   console mode <c>Verbose</c>.
    /// </summary>
    constructor Create;
    /// <summary>
    ///   Frees the run list.
    /// </summary>
    destructor Destroy; override;
    /// <summary>The XML output file to be generated by XML loggers.</summary>
    property XMLOutputFile : string read FXMLOutputFile write FXMLOutputFile;

    /// <summary>The tests to run, by name.</summary>
    property Run : TStringList read FRun;

    /// <summary>Name of a file which lists the tests to run.</summary>
    property RunListFile : string read FRunListFile write FRunListFile;

    /// <summary>Category include pattern.</summary>
    property Include : string read FInclude write FInclude;

    /// <summary>Category exclude pattern.</summary>
    property Exclude : string read FExclude write FExclude;

    /// <summary>Minimum level a message must have to be logged.</summary>
    property LogLevel : TLogLevel read FLogLevel write FLogLevel;

    /// <summary>If True, do not show the banner.</summary>
    property HideBanner : boolean read FHideBanner write FHideBanner;

    /// <summary>What the runner does after displaying its results; defaults to <c>Continue</c>.</summary>
    property ExitBehavior : TDUnitXExitBehavior read FExitBehavior write FExitBehavior;

    /// <summary>Whether and how a console logger is created; defaults to <c>Verbose</c>.</summary>
    property ConsoleMode : TDunitXConsoleMode read FConsoleMode write FConsoleMode;

    /// <summary>Show command-line usage and exit.</summary>
    property ShowUsage : boolean read FShowUsage write FShowUsage;

    /// <summary>Do not run or show ignored tests at all.</summary>
    property DontShowIgnored : boolean read FDontShowIgnored write FDontShowIgnored;
  end;

  /// <summary>
  ///   Entry point of the framework: creates runners, registers fixtures, parses the command line, and holds the run
  ///   options, the filter and the per-thread assertion counters.
  /// </summary>
  TDUnitX = class
  private
    class var
      /// <summary>The run options; created by the class constructor.</summary>
      FOptions : TDUnitXOptions;
      /// <summary>The test filter built from the command line; nil runs every test.</summary>
      FFilter : ITestFilter;
      /// <summary>Number of assertions made on each thread, counted through <c>Assert.OnAssert</c>.</summary>
      FAssertCounters : TDictionary<TThreadID, Cardinal>;
      /// <summary>Guards <c>FAssertCounters</c>.</summary>
      FLock : TCriticalSection;
  protected
    /// <summary>
    ///   Creates the options, assertion counters and fixture registry, registers a default memory-leak monitor when
    ///   none is registered, and hooks <c>Assert.OnAssert</c> to count assertions per thread.
    /// </summary>
    class constructor Create;
    /// <summary>
    ///   Frees the class-level state.
    /// </summary>
    class destructor Destroy;
  public class var
      /// <summary>Fixture classes registered with <c>RegisterTestFixture</c>, mapped to their fixture names.</summary>
      RegisteredFixtures : TDictionary<TClass, string>;
  public
    /// <summary>
    ///   Creates a test runner with no loggers.
    /// </summary>
    /// <returns>
    ///   The new runner, registered as the calling thread's active runner.
    /// </returns>
    class function CreateRunner : ITestRunner; overload;
    /// <summary>
    ///   Creates a test runner with one logger.
    /// </summary>
    /// <param name="ALogger">
    ///   The logger to attach; nil attaches none.
    /// </param>
    /// <returns>
    ///   The new runner, registered as the calling thread's active runner.
    /// </returns>
    class function CreateRunner(const ALogger : ITestLogger) : ITestRunner; overload;
    /// <summary>
    ///   Creates a test runner with several loggers.
    /// </summary>
    /// <param name="ALoggers">
    ///   The loggers to attach.
    /// </param>
    /// <returns>
    ///   The new runner, registered as the calling thread's active runner.
    /// </returns>
    class function CreateRunner(const ALoggers : array of ITestLogger) : ITestRunner; overload;
    /// <summary>
    ///   Registers a fixture class so the runner finds it without RTTI discovery. A class already registered is left
    ///   unchanged.
    /// </summary>
    /// <param name="AClass">
    ///   The fixture class.
    /// </param>
    /// <param name="AName">
    ///   The fixture name; when empty, the name in the class's <c>TestFixture</c> attribute is used, or failing that
    ///   the class name.
    /// </param>
    class procedure RegisterTestFixture(const AClass : TClass; const AName : string = '');
    /// <summary>
    ///   Gives the test runner registered for the calling thread.
    /// </summary>
    /// <returns>
    ///   The active runner; nil when its registration remains but the runner has been destroyed.
    /// </returns>
    /// <exception cref="Exception">
    ///   Raised when no runner is registered for the calling thread.
    /// </exception>
    class function CurrentRunner : ITestRunner;
    /// <summary>
    ///   Gives the number of assertions made so far on a thread.
    /// </summary>
    /// <param name="AThreadId">
    ///   The thread.
    /// </param>
    /// <returns>
    ///   The assertion count, 0 when the thread has made none.
    /// </returns>
    class function GetAssertCount(const AThreadId : TThreadID) : Cardinal;
    /// <summary>
    ///   Parses the command-line options and applies them to the <c>Options</c> object, then builds the
    ///   <c>Filter</c>. In a console application it shows the banner unless hidden, and for <c>ShowUsage</c> prints
    ///   the usage and halts with <c>EXIT_OK</c>.
    /// </summary>
    /// <exception cref="ECommandLineError">
    ///   Raised when the command line has errors; in a console application the errors and usage are printed first and
    ///   <c>ExitCode</c> is set to <c>EXIT_OPTIONS_ERROR</c>.
    /// </exception>
    class procedure CheckCommandLine;
    /// <summary>Container for all options supported.</summary>
    class property Options : TDUnitXOptions read FOptions;
    /// <summary>
    ///   The test filter used by the runners. It lives here because it is built when the command line is checked.
    /// </summary>
    class property Filter : ITestFilter read FFilter write FFilter;
  end;

  /// <summary>
  ///   Produces stack traces and address descriptions for exceptions raised in tests. Register an implementation via
  ///   <c>TDUnitXServiceLocator.DefaultContainer</c>; without one, results carry no stack trace.
  /// </summary>
  IStacktraceProvider = interface
    ['{382288B7-932C-4B6E-8417-660FFCA849EB}']
    /// <summary>
    ///   Builds the stack trace of an exception.
    /// </summary>
    /// <param name="ex">
    ///   The exception.
    /// </param>
    /// <param name="exAddressAddress">
    ///   The address the exception was raised at.
    /// </param>
    /// <returns>
    ///   The stack trace text.
    /// </returns>
    function GetStackTrace(const ex : Exception; const exAddressAddress : Pointer) : string;
    /// <summary>
    ///   Describes the source location of a code address.
    /// </summary>
    /// <param name="Addrs">
    ///   The code address.
    /// </param>
    /// <returns>
    ///   The location text (unit, routine, line where available).
    /// </returns>
    function PointerToLocationInfo(const Addrs : Pointer) : string;
    /// <summary>
    ///   Describes a code address.
    /// </summary>
    /// <param name="Addrs">
    ///   The code address.
    /// </param>
    /// <returns>
    ///   The address text.
    /// </returns>
    function PointerToAddressInfo(Addrs : Pointer) : string;
  end;

  /// <summary>
  ///   Measures memory allocated during each phase of a test (setup, test, teardown) so the runner can report leaks.
  ///   Resolved from <c>TDUnitXServiceLocator.DefaultContainer</c>; a default that measures nothing is registered
  ///   when no other is.
  /// </summary>
  IMemoryLeakMonitor = interface
    ['{A374A4D0-9BF6-4E01-8A29-647F92CBF41C}']
    /// <summary>Takes the baseline reading before the <c>[Setup]</c> method.</summary>
    procedure PreSetup;
    /// <summary>Takes the reading after the <c>[Setup]</c> method.</summary>
    procedure PostSetUp;
    /// <summary>Takes the baseline reading before the test method.</summary>
    procedure PreTest;
    /// <summary>Takes the reading after the test method.</summary>
    procedure PostTest;
    /// <summary>Takes the baseline reading before the <c>[TearDown]</c> method.</summary>
    procedure PreTearDown;
    /// <summary>Takes the reading after the <c>[TearDown]</c> method.</summary>
    procedure PostTearDown;

    /// <summary>
    ///   Gives the net memory allocated by the setup phase.
    /// </summary>
    /// <returns>
    ///   Bytes allocated between <c>PreSetup</c> and <c>PostSetUp</c>; negative when more was freed.
    /// </returns>
    function SetUpMemoryAllocated : Int64;
    /// <summary>
    ///   Gives the net memory allocated by the teardown phase.
    /// </summary>
    /// <returns>
    ///   Bytes allocated between <c>PreTearDown</c> and <c>PostTearDown</c>; negative when more was freed.
    /// </returns>
    function TearDownMemoryAllocated : Int64;
    /// <summary>
    ///   Gives the net memory allocated by the test phase.
    /// </summary>
    /// <returns>
    ///   Bytes allocated between <c>PreTest</c> and <c>PostTest</c>; negative when more was freed.
    /// </returns>
    function TestMemoryAllocated : Int64;
  end;

  /// <summary>
  ///   A memory-leak monitor that can also describe what leaked.
  /// </summary>
  IMemoryLeakMonitor2 = interface(IMemoryLeakMonitor)
    ['{33559983-D522-4ED5-9B5E-AC9A055FA01A}']
    /// <summary>
    ///   Describes the leaked allocations, appended to the memory-leak result's message.
    /// </summary>
    /// <returns>
    ///   The leak report, possibly empty.
    /// </returns>
    function GetReport : string;
  end;

const
  /// <summary>Process exit code for a run in which every test passed.</summary>
  EXIT_OK           = 0;
  /// <summary>Process exit code for a run that did not pass; set by the generated runner project, not by the framework.</summary>
  EXIT_ERRORS       = 1;
  /// <summary>Process exit code when the command line could not be parsed.</summary>
  EXIT_OPTIONS_ERROR = 100;

implementation

uses
{$IFDEF USE_NS}
  System.Variants,
  System.Math,
  System.StrUtils,
  System.Types,
  System.RegularExpressions,
  System.Generics.Defaults,
{$ELSE}
  Variants,
  Math,
  StrUtils,
  Types,
  Generics.Defaults,
{$ENDIF}
  DUnitX.ResStrs,
  DUnitX.ConsoleWriter.Base,
  DUnitX.Banner,
  DUnitX.OptionsDefinition,
  DUnitX.CommandLine.Options,
  DUnitX.TestRunner,
  DUnitX.Utils,
  DUnitX.ServiceLocator,
  DUnitX.MemoryLeakMonitor.Default,
  DUnitX.FixtureProvider,
  DUnitX.FilterBuilder,
  DUnitX.WeakReference,
  DUnitX.TestDataProvider
  {$IFDEF DELPHI_XE3}
  ,DUnitX.Init
  {$ENDIF}
  ;

{ TDUnitXOptions }

constructor TDUnitXOptions.Create;
begin
  FRun := TStringList.Create;
  FLogLevel := TLogLevel.Information;
  FExitBehavior := TDUnitXExitBehavior.Continue;
  FConsoleMode := TDUnitXConsoleMode.Verbose;
end;

destructor TDUnitXOptions.Destroy;
begin
  FRun.Free;
  inherited;
end;

{ TDUnitX }

class function TDUnitX.CreateRunner : ITestRunner;
begin
  result := CreateRunner(nil);
end;

class function TDUnitX.CreateRunner(const ALogger : ITestLogger) : ITestRunner;
begin
  result := TDUnitXTestRunner.Create(ALogger);
end;

class function TDUnitX.CreateRunner(
  const ALoggers : array of ITestLogger) : ITestRunner;
begin
  Result := TDUnitXTestRunner.Create(ALoggers);
end;

procedure WriteLine(consoleWriter : IDUnitXConsoleWriter; const value : string);
begin
  if consoleWriter <> nil then
    consoleWriter.WriteLn(value)
  else
    System.Writeln(value);
end;

procedure ShowUsage(consoleWriter : IDUnitXConsoleWriter);
begin
  if consoleWriter <> nil then
    consoleWriter.SetColour(ccBrightYellow, ccDefault);
  Writeline(consoleWriter, Format(SUsage, [ExtractFileName(ParamStr(0))]) + #13#10);
  Writeline(consoleWriter, SOptions);
  if consoleWriter <> nil then
    consoleWriter.SetColour(ccBrightWhite, ccDefault);

  TOptionsRegistry.PrintUsage(procedure(value : string)
    begin
      WriteLine(consoleWriter, value);
    end);
  if consoleWriter <> nil then
    consoleWriter.SetColour(ccDefault);
end;

class procedure TDUnitX.CheckCommandLine;
var
  parseResult : ICommandLineParseResult;
  consoleWriter : IDUnitXConsoleWriter;
begin
  parseResult := TOptionsRegistry.Parse;
  if parseResult.HasErrors then
  begin
    //if it's a console tell the user what they did wrong
    if IsConsole then
    begin
      //we may have successfully parsed this option so we should respect it.
      if not FOptions.HideBanner then
        DUnitX.Banner.ShowBanner;

      consoleWriter := TDUnitXServiceLocator.DefaultContainer.Resolve<IDUnitXConsoleWriter>;
      if consoleWriter <> nil then
        consoleWriter.SetColour(ccBrightRed, ccDefault);
      Writeline(consoleWriter, parseResult.ErrorText);
      //if the user said hidebanner then don't print the usage either
      if not FOptions.HideBanner then
        ShowUsage(consoleWriter);
      if consoleWriter <> nil then
        consoleWriter.SetColour(ccDefault, ccDefault);
      System.ExitCode := EXIT_OPTIONS_ERROR;
      raise ECommandLineError.Create(parseResult.ErrorText);
    end
    else
      //Not a console app, raise an exception and let the GUI app deal with it??
      raise ECommandLineError.Create(parseResult.ErrorText);
  end
  else
  begin
    //Command line options parsed ok.
    if IsConsole then
    begin
      if not FOptions.HideBanner then
        DUnitX.Banner.ShowBanner;
      //if /? or -h then just show usage and exit
      if FOptions.ShowUsage then
      begin
        consoleWriter := TDUnitXServiceLocator.DefaultContainer.Resolve<IDUnitXConsoleWriter>;
        ShowUsage(consoleWriter);
        consoleWriter := nil;
        parseResult := nil;
        Halt(EXIT_OK);
      end;
    end;

    //Build the filter only if we're actually going to run tests (not just showing help)
    FFilter := TDUnitXFilterBuilder.BuildFilter(FOptions);
  end;

end;

class constructor TDUnitX.Create;
begin
  FOptions := TDUnitXOptions.Create;
  FAssertCounters := TDictionary<TThreadID, Cardinal>.Create(8);
  FLock := TCriticalSection.Create;
  RegisteredFixtures := TDictionary<TClass, string>.Create;
  //Make sure we have at least a dummy memory leak monitor registered.
  if not TDUnitXServiceLocator.DefaultContainer.HasService<IMemoryLeakMonitor> then
    DUnitX.MemoryLeakMonitor.Default.RegisterDefaultProvider;
  FFilter := nil;
  Assert.OnAssert := procedure
      var
      threadId : TThreadID;
      value : cardinal;
    begin
      threadId := TThread.CurrentThread.ThreadID;
      FLock.Enter;
      try
        if FAssertCounters.TryGetValue(threadId, value) then
        begin
          Inc(value);
          FAssertCounters.AddOrSetValue(threadId, value);
        end
        else
          FAssertCounters.Add(threadId, 1)
      finally
        FLock.Leave;
      end;
    end;
end;

class function TDUnitX.CurrentRunner : ITestRunner;
var
  ref : IWeakReference<ITestRunner>;
begin
  MonitorEnter(TDUnitXTestRunner.FActiveRunners);
  try
    if not TDUnitXTestRunner.FActiveRunners.TryGetValue(TThread.CurrentThread.ThreadId, ref) then
      raise Exception.Create(SNoRunner);
  finally
    MonitorExit(TDUnitXTestRunner.FActiveRunners);
  end;
  result := ref.Data;

end;

class destructor TDUnitX.Destroy;
begin
  RegisteredFixtures.Free;
  FOptions.Free;
  FAssertCounters.Free;
  FLock.Free;
end;

class function TDUnitX.GetAssertCount(const AThreadId : TThreadID) : Cardinal;
begin
  result := 0;
  FLock.Enter;
  try
    FAssertCounters.TryGetValue(AThreadId, result);
  finally
    FLock.Leave;
  end;
end;

class procedure TDUnitX.RegisterTestFixture(const AClass : TClass; const AName : string);
var
  sName : string;
  attrib : TestFixtureAttribute;
  rType : TRttiType;
begin
  // If a name is passed in, then that's what we'll use, otherwise see if there
  // is a TestFixture attribute and if it's name is set then use it. If no
  // attribute then fallback to classname
  if AName <> '' then
    sName := AName
  else
  begin
    rType := DUnitX.Utils.GetRttiType(AClass);
    if rType <> nil then
    begin
      if rType.TryGetAttributeOfType<TestFixtureAttribute>(attrib) then
        sName := attrib.Name;
    end;

    if sName = '' then
      sName := AClass.ClassName;

  end;

  if not RegisteredFixtures.ContainsKey(AClass) then
    RegisteredFixtures.Add(AClass, sName);
end;

{$IFDEF DELPHI_XE2_UP}

{ TTestFixtureHelper }

procedure TTestFixtureHelper.Log(const msg : string);
begin
  Self.Log(TLogLevel.Information, msg);
end;

procedure TTestFixtureHelper.Log(const logType : TLogLevel; const msg : string);
var
  runner : ITestRunner;
begin
  //GetActiveRunner reads the runner registry under its lock; another thread may be adding or removing a runner.
  runner := TDUnitXTestRunner.GetActiveRunner;
  if runner <> nil then
    runner.Log(logType, msg)
  else
    System.Writeln(msg);
end;

procedure TTestFixtureHelper.Status(const msg : string);
begin
  Self.Log(TLogLevel.Information, msg);
end;

procedure TTestFixtureHelper.WriteLn;
begin
  Self.Log(TLogLevel.Information, '');
end;

procedure TTestFixtureHelper.WriteLn(const msg : string);
begin
  Self.Log(TLogLevel.Information, msg);
end;
{$ENDIF}

procedure InitAssert;
begin
  Assert.TestFailure := ETestFailure;
  Assert.TestPass := ETestPass;
  Assert.TestIgnored := ETestIgnored;
end;

{$IFNDEF DELPHI_XE3}

initialization
  InitAssert;
  TDUnitXServiceLocator.DefaultContainer.RegisterType<IFixtureProvider, TDUnitXFixtureProvider>();

finalization

{$ENDIF}

end.

