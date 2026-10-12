{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2017 Vincent Parrett & Contributors               }
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

unit DUnitX.Extensibility;

interface

{$I DUnitX.inc}

uses
{$IFDEF USE_NS}
  System.TimeSpan,
  System.Rtti,
  System.Generics.Collections,
  System.SysUtils,
{$ELSE}
  TimeSpan,
  Rtti,
  Generics.Collections,
  SysUtils,
{$ENDIF}
  DUnitX.Types,
  DUnitX.Generics;

type
  /// <summary>
  ///   A parameterless method of an object: the shape of every test, setup and teardown method the runner calls.
  /// </summary>
  TTestMethod = procedure of object;

  /// <summary>
  ///   Forward declaration of the run-time fixture interface, declared in full below.
  /// </summary>
  /// <remarks>
  ///   These interfaces mirror the Info classes in the framework but expose what the runner needs at run time.
  /// </remarks>
  ITestFixture = interface;

  /// <summary>
  ///   Describes a test at run time: its names, method, fixture, timing, and the settings the runner honours
  ///   (enabled, ignored, memory-leak checking, time limit).
  /// </summary>
  ITest = interface
    ['{0CCCE0C7-9AD1-4C3A-86EF-E882D3A839AB}']
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
    ///   Gives the categories the test belongs to, used by category filters.
    /// </summary>
    /// <returns>
    ///   The category list, owned by the test.
    /// </returns>
    function GetCategories : TList<string>;
    /// <summary>
    ///   Gives the method the runner calls to run the test.
    /// </summary>
    /// <returns>
    ///   The test method, bound to the current fixture instance.
    /// </returns>
    function GetTestMethod : TTestMethod;
    /// <summary>
    ///   Gives the fixture the test belongs to.
    /// </summary>
    /// <returns>
    ///   The owning fixture.
    /// </returns>
    function GetTestFixture : ITestFixture;
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
    ///   Reports whether the test is selected to run; filters clear it for tests they exclude.
    /// </summary>
    /// <returns>
    ///   True when the test is enabled.
    /// </returns>
    function GetEnabled : boolean;
    /// <summary>
    ///   Selects or deselects the test for running.
    /// </summary>
    /// <param name="value">
    ///   True to run the test.
    /// </param>
    procedure SetEnabled(const value : boolean);
    /// <summary>
    ///   Reports whether the test is marked to be skipped and reported as ignored.
    /// </summary>
    /// <returns>
    ///   True when the test is ignored.
    /// </returns>
    function GetIgnored : boolean;
    /// <summary>
    ///   Gives why the test is ignored.
    /// </summary>
    /// <returns>
    ///   The reason, empty when none was given.
    /// </returns>
    function GetIgnoreReason : string;
    /// <summary>
    ///   Reports whether memory leaked by the test is ignored rather than reported.
    /// </summary>
    /// <returns>
    ///   True when leaks are ignored.
    /// </returns>
    function GetIgnoreMemoryLeaks() : Boolean;
    /// <summary>
    ///   Sets whether memory leaked by the test is ignored.
    /// </summary>
    /// <param name="AValue">
    ///   True to ignore leaks.
    /// </param>
    procedure SetIgnoreMemoryLeaks(const AValue : Boolean);
    /// <summary>
    ///   Gives the test's time limit in milliseconds.
    /// </summary>
    /// <returns>
    ///   The limit, 0 for none.
    /// </returns>
    function GetMaxTime : cardinal;
    /// <summary>
    ///   Sets the test's time limit.
    /// </summary>
    /// <param name="AValue">
    ///   The limit in milliseconds, 0 for none.
    /// </param>
    procedure SetMaxTime(const AValue : cardinal);
    /// <summary>
    ///   Reports whether the test's last run exceeded its time limit.
    /// </summary>
    /// <returns>
    ///   True when the test timed out.
    /// </returns>
    function GetTimedOut : Boolean;
    /// <summary>
    ///   Records whether the test's run exceeded its time limit.
    /// </summary>
    /// <param name="AValue">
    ///   True when the test timed out.
    /// </param>
    procedure SetTimedOut(const AValue : Boolean);
    /// <summary>
    ///   Reports whether the test is one case of a parameterised test.
    /// </summary>
    /// <returns>
    ///   True for a test case.
    /// </returns>
    function GetIsTestCase : boolean;

    /// <summary>The test's display name.</summary>
    property Name : string read GetName;
    /// <summary>The test's name qualified by its fixture.</summary>
    property FullName : string read GetFullName;
    /// <summary>Name of the method that implements the test.</summary>
    property MethodName : string read GetMethodName;
    /// <summary>Categories the test belongs to.</summary>
    property Categories : TList<string> read GetCategories;
    /// <summary>Whether the test is selected to run.</summary>
    property Enabled : boolean read GetEnabled write SetEnabled;
    /// <summary>The fixture the test belongs to.</summary>
    property Fixture : ITestFixture read GetTestFixture;
    /// <summary>Whether the test is skipped and reported as ignored.</summary>
    property Ignored : boolean read GetIgnored;
    /// <summary>Why the test is ignored.</summary>
    property IgnoreReason : string read GetIgnoreReason;
    /// <summary>Whether the test is one case of a parameterised test.</summary>
    property IsTestCase : boolean read GetIsTestCase;
    /// <summary>The method the runner calls to run the test.</summary>
    property TestMethod : TTestMethod read GetTestMethod;
    /// <summary>Whether memory leaked by the test is ignored rather than reported.</summary>
    property IgnoreMemoryLeaks : Boolean read GetIgnoreMemoryLeaks write SetIgnoreMemoryLeaks;
    /// <summary>Time limit in milliseconds, 0 for none.</summary>
    property MaxTime : cardinal read GetMaxTime write SetMaxTime;
    /// <summary>Whether the last run exceeded the time limit.</summary>
    property TimedOut : Boolean read GetTimedOut write SetTimedOut;
  end;

  /// <summary>
  ///   A list of run-time tests.
  /// </summary>
  ITestList = interface(IList<ITest>)
    ['{83ABC05F-5762-4FD2-9791-E32F5A9A4D06}']
  end;

  /// <summary>
  ///   Forward declaration of the fixture list interface, declared in full below.
  /// </summary>
  ITestFixtureList = interface;

  /// <summary>
  ///   Describes a test fixture at run time: its names, tests, setup and teardown methods, nested fixtures and the
  ///   fixture object the tests run on. A fixture whose class is <c>TObject</c> is a namespace node with no tests of
  ///   its own.
  /// </summary>
  ITestFixture = interface
    ['{B2F140C3-1D6A-4C09-B4C6-0D6AFC99BC87}']
    /// <summary>
    ///   Gives the fixture's name.
    /// </summary>
    /// <returns>
    ///   The name.
    /// </returns>
    function GetName : string;
    /// <summary>
    ///   Gives the fixture's name qualified by its namespace.
    /// </summary>
    /// <returns>
    ///   Namespace and name joined by a dot, or just the name when the two are equal.
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
    ///   Gives the fixture's description, from its <c>TestFixture</c> attribute.
    /// </summary>
    /// <returns>
    ///   The description, possibly empty.
    /// </returns>
    function GetDescription : string;
    /// <summary>
    ///   Gives the categories the fixture belongs to.
    /// </summary>
    /// <returns>
    ///   The category list, owned by the fixture.
    /// </returns>
    function GetCategories : TList<string>;
    /// <summary>
    ///   Gives the fixture's own tests.
    /// </summary>
    /// <returns>
    ///   The test list.
    /// </returns>
    function GetTests : ITestList;
    /// <summary>
    ///   Gives the class the fixture instance is created from.
    /// </summary>
    /// <returns>
    ///   The fixture class; <c>TObject</c> for a namespace-only fixture.
    /// </returns>
    function GetTestClass : TClass;
    /// <summary>
    ///   Gives the method run before each test.
    /// </summary>
    /// <returns>
    ///   The <c>[Setup]</c> method, nil when there is none.
    /// </returns>
    function GetSetupMethod : TTestMethod;
    /// <summary>
    ///   Gives the name of the method run before each test.
    /// </summary>
    /// <returns>
    ///   The <c>[Setup]</c> method name, empty when there is none.
    /// </returns>
    function GetSetupMethodName : string;
    /// <summary>
    ///   Gives the method run once before the fixture's tests.
    /// </summary>
    /// <returns>
    ///   The <c>[SetupFixture]</c> method; nil when there is none or when the fixture's constructor takes its place.
    /// </returns>
    function GetSetupFixtureMethod : TTestMethod;
    /// <summary>
    ///   Gives the name of the method run once before the fixture's tests.
    /// </summary>
    /// <returns>
    ///   The <c>[SetupFixture]</c> method name; kept even when the constructor takes its place, so the runner can
    ///   report that the method is not run.
    /// </returns>
    function GetSetupFixtureMethodName : string;
    /// <summary>
    ///   Gives the method run after each test.
    /// </summary>
    /// <returns>
    ///   The <c>[TearDown]</c> method, nil when there is none.
    /// </returns>
    function GetTearDownMethod : TTestMethod;
    /// <summary>
    ///   Gives the name of the method run after each test.
    /// </summary>
    /// <returns>
    ///   The <c>[TearDown]</c> method name, empty when there is none.
    /// </returns>
    function GetTearDownMethodName : string;
    /// <summary>
    ///   Gives the method run once after the fixture's tests.
    /// </summary>
    /// <returns>
    ///   The <c>[TearDownFixture]</c> method (or the destructor standing in for it), nil when there is none.
    /// </returns>
    function GetTearDownFixtureMethod : TTestMethod;
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
    ///   Reports whether the fixture is selected to run.
    /// </summary>
    /// <returns>
    ///   True when the fixture is enabled.
    /// </returns>
    function GetEnabled : boolean;
    /// <summary>
    ///   Selects or deselects the fixture for running.
    /// </summary>
    /// <param name="value">
    ///   True to run the fixture.
    /// </param>
    procedure SetEnabled(const value : boolean);
    /// <summary>
    ///   Gives the nested fixtures.
    /// </summary>
    /// <returns>
    ///   The child fixture list.
    /// </returns>
    function GetChildren : ITestFixtureList;
    /// <summary>
    ///   Reports whether the fixture has nested fixtures.
    /// </summary>
    /// <returns>
    ///   True when there is at least one child fixture.
    /// </returns>
    function GetHasChildren : boolean;
    /// <summary>
    ///   Gives the fixture's namespace.
    /// </summary>
    /// <returns>
    ///   The namespace.
    /// </returns>
    function GetNameSpace : string;
    /// <summary>
    ///   Reports whether the fixture has tests of its own that are enabled.
    /// </summary>
    /// <returns>
    ///   True when at least one of its own tests is enabled.
    /// </returns>
    function GetHasTests : boolean;
    /// <summary>
    ///   Reports whether any nested fixture, at any depth, has enabled tests.
    /// </summary>
    /// <returns>
    ///   True when a descendant fixture has enabled tests.
    /// </returns>
    function GetHasChildTests : boolean;
    /// <summary>
    ///   Reports whether the fixture is only a namespace node.
    /// </summary>
    /// <returns>
    ///   True when the fixture class is <c>TObject</c>.
    /// </returns>
    function IsNameSpaceOnly : boolean;
    /// <summary>
    ///   Tells the fixture that the runner has just called one of its methods; when that method is the destructor
    ///   standing in for <c>[TearDownFixture]</c>, the fixture forgets its now-freed instance.
    /// </summary>
    /// <param name="AMethod">
    ///   The method that was executed.
    /// </param>
    procedure OnMethodExecuted(const AMethod : TTestMethod);
    /// <summary>
    ///   Gives the object the fixture's tests run on.
    /// </summary>
    /// <returns>
    ///   The fixture instance, nil before it is created or after teardown frees it.
    /// </returns>
    function GetFixtureInstance : TObject;
    /// <summary>
    ///   Reports whether the whole fixture is marked to be skipped.
    /// </summary>
    /// <returns>
    ///   True when the fixture is ignored.
    /// </returns>
    function GetIgnored : boolean;
    /// <summary>
    ///   Gives why the fixture is ignored.
    /// </summary>
    /// <returns>
    ///   The reason, empty when none was given.
    /// </returns>
    function GetIgnoreReason : string;
    /// <summary>
    ///   Reports whether any of the fixture's own tests will actually execute.
    /// </summary>
    /// <returns>
    ///   True when the fixture is not ignored and at least one test is enabled and not ignored; the runner uses it so
    ///   <c>[SetupFixture]</c> does not run for a fixture whose selected tests are all ignored.
    /// </returns>
    function GetHasActiveTests : boolean;

    /// <summary>
    ///   Adds a test for a fixture method.
    /// </summary>
    /// <param name="AMethodName">
    ///   Name of the test method.
    /// </param>
    /// <param name="AMethod">
    ///   The test method itself.
    /// </param>
    /// <param name="AName">
    ///   Display name of the test.
    /// </param>
    /// <param name="ACategory">
    ///   Comma-separated categories of the test.
    /// </param>
    /// <param name="ARttiMethod">
    ///   RTTI for the method, used to read its attributes.
    /// </param>
    /// <param name="AEnabled">
    ///   Whether the test is enabled.
    /// </param>
    /// <param name="AIgnored">
    ///   Whether the test is ignored.
    /// </param>
    /// <param name="AIgnoreReason">
    ///   Why the test is ignored.
    /// </param>
    /// <param name="AMaxTime">
    ///   Time limit in milliseconds, 0 for none.
    /// </param>
    /// <param name="AExpectedException">
    ///   Exception class the test must raise to pass, nil for none.
    /// </param>
    /// <param name="AExceptionInheritance">
    ///   Whether the raised exception must match <c>AExpectedException</c> exactly or may descend from it.
    /// </param>
    /// <returns>
    ///   The new test.
    /// </returns>
    function AddTest(const AMethodName : string; const AMethod : TTestMethod; const AName : string; const ACategory : string; const ARttiMethod : TRttiMethod;
      const AEnabled : boolean = true; const AIgnored : boolean = false; const AIgnoreReason : string = ''; const AMaxTime : cardinal = 0; const
      AExpectedException : ExceptClass = nil; const AExceptionInheritance : TExceptionInheritance = exExact) : ITest;
    /// <summary>
    ///   Adds one case of a parameterised test, which calls the method through RTTI with fixed arguments.
    /// </summary>
    /// <param name="AMethodName">
    ///   Name of the test method.
    /// </param>
    /// <param name="ACaseName">
    ///   Name of the case.
    /// </param>
    /// <param name="AName">
    ///   Display name of the test.
    /// </param>
    /// <param name="ACategory">
    ///   Comma-separated categories of the test.
    /// </param>
    /// <param name="AMethod">
    ///   RTTI for the method, used to invoke it with the case's arguments.
    /// </param>
    /// <param name="AEnabled">
    ///   Whether the case is enabled.
    /// </param>
    /// <param name="AArgs">
    ///   The arguments the case passes to the method.
    /// </param>
    /// <param name="AMaxTime">
    ///   Time limit in milliseconds, 0 for none.
    /// </param>
    /// <param name="AExpectedException">
    ///   Exception class the case must raise to pass, nil for none.
    /// </param>
    /// <param name="AExceptionInheritance">
    ///   Whether the raised exception must match <c>AExpectedException</c> exactly or may descend from it.
    /// </param>
    /// <returns>
    ///   The new test case.
    /// </returns>
    function AddTestCase(const AMethodName : string; const ACaseName : string; const AName : string; const ACategory : string; const AMethod : TRttiMethod;
      const AEnabled : boolean; const AArgs : TValueArray; const AMaxTime : cardinal = 0; const AExpectedException : ExceptClass = nil;
      const AExceptionInheritance : TExceptionInheritance = exExact) : ITest;

    /// <summary>
    ///   Adds a nested fixture whose instance is created from a class.
    /// </summary>
    /// <param name="ATestClass">
    ///   The fixture class; <c>TObject</c> makes a namespace-only node.
    /// </param>
    /// <param name="AName">
    ///   Name of the child fixture.
    /// </param>
    /// <param name="ACategory">
    ///   Comma-separated categories of the child fixture.
    /// </param>
    /// <returns>
    ///   The new child fixture.
    /// </returns>
    function AddChildFixture(const ATestClass : TClass; const AName : string; const ACategory : string) : ITestFixture; overload;
    /// <summary>
    ///   Adds a nested fixture that runs on an existing object instead of creating one.
    /// </summary>
    /// <param name="AInstance">
    ///   The object the child fixture's tests run on.
    /// </param>
    /// <param name="AName">
    ///   Name of the child fixture.
    /// </param>
    /// <param name="ACategory">
    ///   Comma-separated categories of the child fixture.
    /// </param>
    /// <returns>
    ///   The new child fixture.
    /// </returns>
    function AddChildFixture(const AInstance : TObject; const AName : string; const ACategory : string) : ITestFixture; overload;

    /// <summary>
    ///   Sets the method run before each test.
    /// </summary>
    /// <param name="AMethodName">
    ///   Name of the <c>[Setup]</c> method.
    /// </param>
    /// <param name="AMethod">
    ///   The method itself.
    /// </param>
    procedure SetSetupTestMethod(const AMethodName : string; const AMethod : TTestMethod);
    /// <summary>
    ///   Sets the method run once before the fixture's tests. The name is always kept; the method is not stored when
    ///   a parameterless constructor already serves as the fixture setup.
    /// </summary>
    /// <param name="AMethodName">
    ///   Name of the <c>[SetupFixture]</c> method.
    /// </param>
    /// <param name="AMethod">
    ///   The method itself.
    /// </param>
    procedure SetSetupFixtureMethod(const AMethodName : string; const AMethod : TTestMethod);
    /// <summary>
    ///   Sets the method run after each test.
    /// </summary>
    /// <param name="AMethodName">
    ///   Name of the <c>[TearDown]</c> method.
    /// </param>
    /// <param name="AMethod">
    ///   The method itself.
    /// </param>
    procedure SetTearDownTestMethod(const AMethodName : string; const AMethod : TTestMethod);
    /// <summary>
    ///   Sets the method run once after the fixture's tests.
    /// </summary>
    /// <param name="AMethodName">
    ///   Name of the <c>[TearDownFixture]</c> method.
    /// </param>
    /// <param name="AMethod">
    ///   The method itself.
    /// </param>
    /// <param name="AIsDestructor">
    ///   True when the method is the fixture's destructor, so teardown frees the instance instead of calling it.
    /// </param>
    procedure SetTearDownFixtureMethod(const AMethodName : string; const AMethod : TTestMethod; const AIsDestructor : boolean);
    /// <summary>
    ///   Sets whether each test runs in its own thread.
    /// </summary>
    /// <param name="value">
    ///   True to run tests in their own thread.
    /// </param>
    procedure SetTestInOwnThread(const value : boolean);

    /// <summary>
    ///   Runs the fixture teardown: frees the fixture instance when the destructor is the teardown method, otherwise
    ///   calls the <c>[TearDownFixture]</c> method; does nothing when there is none.
    /// </summary>
    procedure ExecuteFixtureTearDown;
    /// <summary>
    ///   Creates the fixture instance when there is none (through a parameterless constructor when one is declared)
    ///   and rebinds every test, setup and teardown method to the new instance.
    /// </summary>
    procedure InitFixtureInstance;

    /// <summary>The fixture's name.</summary>
    property Name : string read GetName;
    /// <summary>The fixture's namespace.</summary>
    property NameSpace : string read GetNameSpace;
    /// <summary>The fixture's name qualified by its namespace.</summary>
    property FullName : string read GetFullName;
    /// <summary>The unit that declares the fixture class.</summary>
    property UnitName : string read GetUnitName;
    /// <summary>Categories the fixture belongs to.</summary>
    property Categories : TList<string> read GetCategories;
    /// <summary>The nested fixtures.</summary>
    property Children : ITestFixtureList read GetChildren;
    /// <summary>The fixture's description.</summary>
    property Description : string read GetDescription;
    /// <summary>Whether the fixture is selected to run.</summary>
    property Enabled : boolean read GetEnabled write SetEnabled;
    /// <summary>The object the fixture's tests run on.</summary>
    property FixtureInstance : TObject read GetFixtureInstance;
    /// <summary>Whether the fixture has nested fixtures.</summary>
    property HasChildFixtures : boolean read GetHasChildren;
    /// <summary>Whether the fixture has enabled tests of its own.</summary>
    property HasTests : boolean read GetHasTests;
    /// <summary>Whether any nested fixture has enabled tests.</summary>
    property HasChildTests : boolean read GetHasChildTests;
    /// <summary>The class the fixture instance is created from.</summary>
    property TestClass : TClass read GetTestClass;
    /// <summary>The fixture's own tests.</summary>
    property Tests : ITestList read GetTests;
    /// <summary>The method run before each test.</summary>
    property SetupMethod : TTestMethod read GetSetupMethod;
    /// <summary>Name of the method run before each test.</summary>
    property SetupMethodName : string read GetSetupMethodName;
    /// <summary>The method run once before the fixture's tests.</summary>
    property SetupFixtureMethod : TTestMethod read GetSetupFixtureMethod;
    /// <summary>Name of the method run once before the fixture's tests.</summary>
    property SetupFixtureMethodName : string read GetSetupFixtureMethodName;
    /// <summary>The method run after each test.</summary>
    property TearDownMethod : TTestMethod read GetTearDownMethod;
    /// <summary>Name of the method run after each test.</summary>
    property TearDownMethodName : string read GetTearDownMethodName;
    /// <summary>The method run once after the fixture's tests.</summary>
    property TearDownFixtureMethod : TTestMethod read GetTearDownFixtureMethod;
    /// <summary>Name of the method run once after the fixture's tests.</summary>
    property TearDownFixtureMethodName : string read GetTearDownFixtureMethodName;
    /// <summary>Whether each test runs in its own thread.</summary>
    property TestInOwnThread : boolean read GetTestInOwnThread write SetTestInOwnThread;
    /// <summary>Whether the whole fixture is skipped.</summary>
    property Ignored : boolean read GetIgnored;
    /// <summary>Why the fixture is ignored.</summary>
    property IgnoreReason : string read GetIgnoreReason;
    /// <summary>Whether any of the fixture's own tests will actually execute.</summary>
    property HasActiveTests : boolean read GetHasActiveTests;
  end;

  /// <summary>
  ///   A list of run-time fixtures that can sort itself, and its descendants, by name.
  /// </summary>
  ITestFixtureList = interface(IList<ITestFixture>)
    ['{BB78BD03-4818-4CF4-B40C-AD037DF2EFB9}']
    /// <summary>
    ///   Sorts the fixtures by full name (ordinal), and every fixture's children the same way, recursively.
    /// </summary>
    /// <remarks>
    ///   Use this rather than <c>Sort</c>, which orders by the default interface comparer, that is by address.
    /// </remarks>
    procedure SortByName;
  end;

  /// <summary>
  ///   The concrete list of run-time tests.
  /// </summary>
  TTestList = class(TDUnitXList<ITest>, ITestList)
  end;

  /// <summary>
  ///   The concrete list of run-time fixtures.
  /// </summary>
  TTestFixtureList = class(TDUnitXList<ITestFixture>, ITestFixtureList)
  public
    /// <summary>
    ///   Sorts the fixtures by full name (ordinal), and every fixture's children the same way, recursively.
    /// </summary>
    procedure SortByName;
  end;

  /// <summary>
  ///   Used by the runner to call the fixture providers and collect the fixtures they build.
  /// </summary>
  IFixtureBuilder = interface
    ['{71A5DFE1-AE08-46C8-9405-65000A96FAA0}']
    /// <summary>
    ///   Runs the registered fixture providers and returns the fixture tree they produce.
    /// </summary>
    /// <returns>
    ///   The top-level fixtures.
    /// </returns>
    function BuildFixtureList : ITestFixtureList;
  end;

  /// <summary>
  ///   Used by a fixture provider to create fixtures; it abstracts the concrete fixture class away from the provider.
  /// </summary>
  IFixtureProviderContext = interface
    ['{933F8442-77F1-4574-BB5E-2F3D0B8E6E6F}']
    /// <summary>
    ///   Creates a fixture; the provider decides where in the fixture tree it goes.
    /// </summary>
    /// <param name="AFixtureClass">
    ///   The fixture class; <c>TObject</c> makes a namespace-only node.
    /// </param>
    /// <param name="AName">
    ///   Name of the fixture.
    /// </param>
    /// <param name="ACategory">
    ///   Comma-separated categories of the fixture.
    /// </param>
    /// <returns>
    ///   The new fixture.
    /// </returns>
    function CreateFixture(const AFixtureClass : TClass; const AName : string; const ACategory : string) : ITestFixture; overload;
    /// <summary>
    ///   Gives the runner's <c>UseRtti</c> setting.
    /// </summary>
    /// <returns>
    ///   True when the provider should also discover fixture classes through RTTI rather than only from the
    ///   explicitly registered ones.
    /// </returns>
    function GetUseRtti : boolean;
    /// <summary>The runner's <c>UseRtti</c> property, exposed for provider use.</summary>
    property UseRtti : boolean read GetUseRtti;
  end;

  /// <summary>
  ///   Generates test fixtures from registered classes; plugins register one to contribute fixtures to a run.
  /// </summary>
  IFixtureProvider = interface
    ['{48D58C88-1236-4B96-9D5F-5DD81DB71504}']
    /// <summary>
    ///   Builds fixtures through the given context.
    /// </summary>
    /// <param name="context">
    ///   The context used to create the fixtures.
    /// </param>
    procedure Execute(const context : IFixtureProviderContext);
  end;

implementation

uses
{$IFDEF USE_NS}
  System.Generics.Defaults
{$ELSE}
  Generics.Defaults
{$ENDIF}
  ;

{ TTestFixtureList }

procedure TTestFixtureList.SortByName;
var
  AFixture : ITestFixture;

  Comparer : IComparer<ITestFixture>;

begin
  Comparer := TDelegatedComparer<ITestFixture>.Create(
    function(const Left, Right : ITestFixture) : Integer
    begin
      Result := CompareStr(Left.FullName, Right.FullName);
    end);

  Sort(Comparer);

  for AFixture in (Self as ITestFixtureList) do
    if AFixture.HasChildFixtures then
      AFixture.Children.SortByName;
end;

end.

