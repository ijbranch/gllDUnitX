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

unit DUnitX.TestFixture;

interface

{$I DUnitX.inc}

uses
{$IFDEF USE_NS}
  System.Generics.Collections,
  System.Rtti,
  System.SysUtils,
{$ELSE}
  Generics.Collections,
  Rtti,
  SysUtils,
{$ENDIF}
  DUnitX.Types,
  DUnitX.Attributes,
  DUnitX.TestFramework,
  DUnitX.Extensibility,
  DUnitX.InternalInterfaces,
  DUnitX.WeakReference,
  DUnitX.Generics;

type
  /// <summary>
  ///   A test fixture: one test class (or, with TestClass = TObject, a namespace node) with its instance, tests,
  ///   setup / teardown methods, categories, ignored state and child fixtures.
  /// </summary>
  TDUnitXTestFixture = class(TWeakReferencedObject, ITestFixture, ITestFixtureInfo)
  private
    class var
      /// <summary>Shared RTTI context, kept for the life of the process so RTTI objects stay valid.</summary>
      FRttiContext : TRttiContext;
  private
    /// <summary>RTTI type of the test class.</summary>
    FFixtureType : TRttiType;
    /// <summary>The test class; TObject for a namespace-only fixture.</summary>
    FTestClass : TClass;
    /// <summary>The unit that declares the test class.</summary>
    FUnitName : string;
    /// <summary>The fixture's name: the part of the given name after its last '.'.</summary>
    FName : string;
    /// <summary>The part of the given name before its last '.'; the whole name when it has no '.'.</summary>
    FNameSpace : string;
    /// <summary>The description from the class's [TestFixture] attribute.</summary>
    FDescription : string;
    /// <summary>The fixture's categories, compared case-insensitively.</summary>
    FCategories : TList<string>;
    /// <summary>Whether the fixture is selected to run.</summary>
    FEnabled : boolean;
    /// <summary>The fixture's tests and test cases.</summary>
    FTests : ITestList;
    /// <summary>The tests as ITestInfo, built on first request by ITestFixtureInfo_GetTests and then cached.</summary>
    FTestInfos : IList<ITestInfo>;
    /// <summary>The [Setup] method, run before each test.</summary>
    FSetupMethod : TTestMethod;
    /// <summary>The [SetupFixture] method, run once before the fixture's tests; nil when a constructor took its place.</summary>
    FSetupFixtureMethod : TTestMethod;
    /// <summary>The [TearDown] method, run after each test.</summary>
    FTearDownMethod : TTestMethod;
    /// <summary>The [TearDownFixture] method, or the destructor, run once after the fixture's tests.</summary>
    FTearDownFixtureMethod : TTestMethod;
    /// <summary>The fixture instance the tests run on; owned and freed by the fixture.</summary>
    FFixtureInstance : TObject;
    /// <summary>Whether each test is to run in its own thread.</summary>
    FTestInOwnThread : boolean;
    /// <summary>Name of the [SetupFixture] method; kept even when the method itself is not run.</summary>
    FSetupFixtureMethodName : string;
    /// <summary>Name of the [Setup] method.</summary>
    FSetupMethodName : string;
    /// <summary>Name of the [TearDown] method.</summary>
    FTearDownMethodName : string;
    /// <summary>Name of the [TearDownFixture] method or destructor.</summary>
    FTearDownFixtureMethodName : string;
    /// <summary>Child fixtures; created on demand.</summary>
    FChildren : ITestFixtureList;
    /// <summary>True when the fixture teardown is the class's destructor rather than a [TearDownFixture] method.</summary>
    FTearDownFixtureIsDestructor : boolean;
    /// <summary>The class's [IgnoreMemoryLeaks] setting, the default for its tests.</summary>
    FIgnoreMemoryLeaks : Boolean;

    /// <summary>
    ///   True when the instance was created through a parameterless constructor, which then stands in for the
    ///   [SetupFixture] method so that method is not run as well.
    /// </summary>
    FIgnoreFixtureSetup : boolean;
    /// <summary>Whether the class carries [Ignore].</summary>
    FIgnoredFixture : Boolean;
    /// <summary>The reason given by the class's [Ignore].</summary>
    FIgnoredReason : string;
  protected
    /// <summary>
    ///   Decides whether a test method ignores memory leaks: its own [IgnoreMemoryLeaks] attribute overrides the
    ///   fixture's setting.
    /// </summary>
    /// <param name="AMethod">
    ///   The test method.
    /// </param>
    /// <returns>
    ///   The method's setting when it has the attribute, otherwise the fixture's.
    /// </returns>
    function GetIgnoreMemoryLeaksForMethod(AMethod : TRttiMethod) : Boolean;

    /// <summary>
    ///   Whether the fixture is selected to run.
    /// </summary>
    /// <returns>
    ///   True when enabled.
    /// </returns>
    function GetEnabled : Boolean;
    /// <summary>
    ///   Selects or deselects the fixture.
    /// </summary>
    /// <param name="value">
    ///   True to run the fixture.
    /// </param>
    procedure SetEnabled(const value : Boolean);

    /// <summary>
    ///   The fixture's name, without its namespace.
    /// </summary>
    /// <returns>
    ///   The name.
    /// </returns>
    function GetName : string;
    /// <summary>
    ///   The fixture's namespace.
    /// </summary>
    /// <returns>
    ///   The part of the given name before its last '.'; the whole name when it has none.
    /// </returns>
    function GetNameSpace : string;
    /// <summary>
    ///   The fixture's namespace and name joined with '.'.
    /// </summary>
    /// <returns>
    ///   The full name; just the name when it has no separate namespace.
    /// </returns>
    function GetFullName : string;
    /// <summary>
    ///   The unit that declares the test class.
    /// </summary>
    /// <returns>
    ///   The unit name.
    /// </returns>
    function GetUnitName : string;
    /// <summary>
    ///   The description from the [TestFixture] attribute.
    /// </summary>
    /// <returns>
    ///   The description; empty when none was given.
    /// </returns>
    function GetDescription : string;
    /// <summary>
    ///   The fixture's categories.
    /// </summary>
    /// <returns>
    ///   The live list owned by the fixture; do not free it.
    /// </returns>
    function GetCategories : TList<string>;
    /// <summary>
    ///   The fixture's tests.
    /// </summary>
    /// <returns>
    ///   The test list.
    /// </returns>
    function GetTests : ITestList;
    /// <summary>ITestFixtureInfo.GetTests is implemented by ITestFixtureInfo_GetTests.</summary>
    function ITestFixtureInfo.GetTests = ITestFixtureInfo_GetTests;
    /// <summary>
    ///   The fixture's tests as ITestInfo, built on first call and cached.
    /// </summary>
    /// <returns>
    ///   The cached list; tests added after the first call are not in it.
    /// </returns>
    function ITestFixtureInfo_GetTests : IList<ITestInfo>;
    /// <summary>
    ///   The test class.
    /// </summary>
    /// <returns>
    ///   The class; TObject for a namespace-only fixture.
    /// </returns>
    function GetTestClass : TClass;
    /// <summary>
    ///   The [Setup] method.
    /// </summary>
    /// <returns>
    ///   The method, or nil.
    /// </returns>
    function GetSetupMethod : TTestMethod;
    /// <summary>
    ///   The [SetupFixture] method.
    /// </summary>
    /// <returns>
    ///   The method, or nil (including when a parameterless constructor took its place).
    /// </returns>
    function GetSetupFixtureMethod : TTestMethod;
    /// <summary>
    ///   The [TearDown] method.
    /// </summary>
    /// <returns>
    ///   The method, or nil.
    /// </returns>
    function GetTearDownMethod : TTestMethod;
    /// <summary>
    ///   The [TearDownFixture] method or destructor.
    /// </summary>
    /// <returns>
    ///   The method, or nil.
    /// </returns>
    function GetTearDownFixtureMethod : TTestMethod;
    /// <summary>
    ///   Whether each test is to run in its own thread.
    /// </summary>
    /// <returns>
    ///   The flag set by SetTestInOwnThread.
    /// </returns>
    function GetTestInOwnThread : boolean;
    /// <summary>
    ///   Name of the [SetupFixture] method.
    /// </summary>
    /// <returns>
    ///   The name; set even when a constructor took the method's place, so the runner can report that it is not run.
    /// </returns>
    function GetSetupFixtureMethodName : string;
    /// <summary>
    ///   Name of the [Setup] method.
    /// </summary>
    /// <returns>
    ///   The name, or empty.
    /// </returns>
    function GetSetupMethodName : string;
    /// <summary>
    ///   Name of the [TearDown] method.
    /// </summary>
    /// <returns>
    ///   The name, or empty.
    /// </returns>
    function GetTearDownMethodName : string;
    /// <summary>
    ///   Name of the [TearDownFixture] method or destructor.
    /// </summary>
    /// <returns>
    ///   The name, or empty.
    /// </returns>
    function GetTearDownFixtureMethodName : string;
    /// <summary>
    ///   The fixture instance the tests run on.
    /// </summary>
    /// <returns>
    ///   The instance; nil when its constructor raised or after a destructor teardown.
    /// </returns>
    function GetFixtureInstance : TObject;
    /// <summary>
    ///   The number of tests in the fixture, whatever their state.
    /// </summary>
    /// <returns>
    ///   The test count.
    /// </returns>
    function GetTestCount : cardinal;
    /// <summary>
    ///   The number of tests that will execute: enabled and not ignored.
    /// </summary>
    /// <returns>
    ///   The count; 0 for an ignored fixture.
    /// </returns>
    function GetActiveTestCount : cardinal;
    /// <summary>
    ///   Whether the class carries [Ignore].
    /// </summary>
    /// <returns>
    ///   True when the fixture is ignored.
    /// </returns>
    function GetIgnored : boolean;
    /// <summary>
    ///   Why the fixture is ignored.
    /// </summary>
    /// <returns>
    ///   The reason from [Ignore]; empty otherwise.
    /// </returns>
    function GetIgnoreReason : string;

    /// <summary>
    ///   The child fixtures, creating the list on first use.
    /// </summary>
    /// <returns>
    ///   The child fixture list.
    /// </returns>
    function GetChildren : ITestFixtureList;
    /// <summary>
    ///   Whether the fixture has any child fixtures.
    /// </summary>
    /// <returns>
    ///   True when at least one child exists.
    /// </returns>
    function GetHasChildren : boolean;
    /// <summary>
    ///   Whether the fixture has any enabled test (ignored tests count).
    /// </summary>
    /// <returns>
    ///   True when at least one test is enabled.
    /// </returns>
    function GetHasTests : boolean;
    /// <summary>
    ///   Whether any test will execute (enabled and not ignored), so that [SetupFixture] does not run for a fixture
    ///   whose selected tests are all ignored.
    /// </summary>
    /// <returns>
    ///   True when at least one test will execute; False for an ignored fixture.
    /// </returns>
    function GetHasActiveTests : boolean;
    /// <summary>
    ///   Whether any descendant fixture, at any depth, has an enabled test.
    /// </summary>
    /// <returns>
    ///   True when a child or grandchild has tests.
    /// </returns>
    function GetHasChildTests : Boolean;
    /// <summary>
    ///   Whether this is a namespace node rather than a real test class.
    /// </summary>
    /// <returns>
    ///   True when the test class is TObject.
    /// </returns>
    function IsNameSpaceOnly : boolean;
    /// <summary>
    ///   Notifies the fixture that the runner has called one of its methods; after a destructor teardown the instance
    ///   reference is cleared, since the instance no longer exists.
    /// </summary>
    /// <param name="AMethod">
    ///   The method that was executed.
    /// </param>
    procedure OnMethodExecuted(const AMethod : TTestMethod);

    /// <summary>
    ///   Runs the fixture teardown: frees the instance when the teardown is the destructor, otherwise calls the
    ///   [TearDownFixture] method. Does nothing when there is no teardown.
    /// </summary>
    procedure ExecuteFixtureTearDown;
    /// <summary>
    ///   Creates the fixture instance if it does not exist and rebinds every test, setup and teardown method to it.
    /// </summary>
    /// <remarks>
    ///   An exception from the fixture's constructor propagates, so the runner can report it against the fixture's tests.
    /// </remarks>
    procedure InitFixtureInstance;
    /// <summary>
    ///   Creates the fixture instance when there is none, through a parameterless constructor when the class declares
    ///   one (which then replaces the [SetupFixture] method) or the plain class constructor otherwise.
    /// </summary>
    /// <param name="isConstructing">
    ///   True when called from the fixture's own constructor, where no tests yet exist to rebind; False to rebind every
    ///   test, setup and teardown method to the new instance.
    /// </param>
    procedure InternalInitFixtureInstance(const isConstructing : boolean);

    /// <summary>
    ///   Adds a plain test, or a [WillRaise] exception test when an expected exception is given.
    /// </summary>
    /// <param name="AMethodName">
    ///   The name of the fixture method.
    /// </param>
    /// <param name="AMethod">
    ///   The bound method to run.
    /// </param>
    /// <param name="AName">
    ///   The test's display name.
    /// </param>
    /// <param name="ACategory">
    ///   Comma-separated categories.
    /// </param>
    /// <param name="ARttiMethod">
    ///   The method's RTTI, read for [IgnoreMemoryLeaks].
    /// </param>
    /// <param name="AEnabled">
    ///   True to run the test.
    /// </param>
    /// <param name="AIgnored">
    ///   True to report the test as ignored.
    /// </param>
    /// <param name="AIgnoreReason">
    ///   Why the test is ignored.
    /// </param>
    /// <param name="AMaxTime">
    ///   The [MaxTime] limit in milliseconds; 0 for no limit.
    /// </param>
    /// <param name="AExpectedException">
    ///   The exception class the test must raise; nil for a plain test.
    /// </param>
    /// <param name="AExceptionInheritance">
    ///   exExact to require that class exactly; exDescendant to accept a descendant too.
    /// </param>
    /// <returns>
    ///   The new test, already added to the fixture.
    /// </returns>
    function AddTest(const AMethodName : string; const AMethod : TTestMethod; const AName : string; const ACategory : string; const ARttiMethod : TRttiMethod;
      const AEnabled : boolean = true; const AIgnored : boolean = false; const AIgnoreReason : string = ''; const AMaxTime : cardinal = 0; const
      AExpectedException : ExceptClass = nil; const AExceptionInheritance : TExceptionInheritance = exExact) : ITest;
    /// <summary>
    ///   Adds one case of a parameterised test, invoked on the current fixture instance.
    /// </summary>
    /// <param name="AMethodName">
    ///   The name of the fixture method.
    /// </param>
    /// <param name="ACaseName">
    ///   The case's name.
    /// </param>
    /// <param name="AName">
    ///   The test's display name.
    /// </param>
    /// <param name="ACategory">
    ///   Comma-separated categories.
    /// </param>
    /// <param name="AMethod">
    ///   The RTTI method to invoke; also read for [IgnoreMemoryLeaks].
    /// </param>
    /// <param name="AEnabled">
    ///   True to run the case.
    /// </param>
    /// <param name="AArgs">
    ///   The case's values, converted to the method's parameter types.
    /// </param>
    /// <param name="AMaxTime">
    ///   The [MaxTime] limit in milliseconds; 0 for no limit.
    /// </param>
    /// <param name="AExpectedException">
    ///   The exception class the case must raise; nil when none is expected.
    /// </param>
    /// <param name="AExceptionInheritance">
    ///   exExact to require that class exactly; exDescendant to accept a descendant too.
    /// </param>
    /// <returns>
    ///   The new test case, already added to the fixture.
    /// </returns>
    function AddTestCase(const AMethodName : string; const ACaseName : string; const AName : string; const ACategory : string; const AMethod : TRttiMethod;
      const AEnabled : boolean; const AArgs : TValueArray; const AMaxTime : cardinal = 0; const AExpectedException : ExceptClass = nil;
      const AExceptionInheritance : TExceptionInheritance = exExact) : ITest;

    /// <summary>
    ///   Creates a child fixture for a test class (TObject for a namespace node) and adds it to the children.
    /// </summary>
    /// <param name="ATestClass">
    ///   The child's test class; its unit name becomes the child's unit name.
    /// </param>
    /// <param name="AName">
    ///   The child's full name, namespace included.
    /// </param>
    /// <param name="ACategory">
    ///   Comma-separated categories.
    /// </param>
    /// <returns>
    ///   The new child fixture.
    /// </returns>
    function AddChildFixture(const ATestClass : TClass; const AName : string; const ACategory : string) : ITestFixture; overload;
    /// <summary>
    ///   Creates a child fixture around an existing instance and adds it to the children. The child takes ownership of
    ///   the instance and frees it.
    /// </summary>
    /// <param name="AInstance">
    ///   The fixture instance; its class's unit name becomes the child's unit name.
    /// </param>
    /// <param name="AName">
    ///   The child's full name, namespace included.
    /// </param>
    /// <param name="ACategory">
    ///   Comma-separated categories.
    /// </param>
    /// <returns>
    ///   The new child fixture.
    /// </returns>
    function AddChildFixture(const AInstance : TObject; const AName : string; const ACategory : string) : ITestFixture; overload;

    /// <summary>
    ///   Sets the [Setup] method run before each test.
    /// </summary>
    /// <param name="AMethodName">
    ///   The method's name.
    /// </param>
    /// <param name="AMethod">
    ///   The bound method.
    /// </param>
    procedure SetSetupTestMethod(const AMethodName : string; const AMethod : TTestMethod);
    /// <summary>
    ///   Sets the [SetupFixture] method. The name is always kept, but the method is not stored when a parameterless
    ///   constructor created the instance, as that constructor has already done the fixture setup.
    /// </summary>
    /// <param name="AMethodName">
    ///   The method's name.
    /// </param>
    /// <param name="AMethod">
    ///   The bound method.
    /// </param>
    procedure SetSetupFixtureMethod(const AMethodName : string; const AMethod : TTestMethod);
    /// <summary>
    ///   Sets the [TearDown] method run after each test.
    /// </summary>
    /// <param name="AMethodName">
    ///   The method's name.
    /// </param>
    /// <param name="AMethod">
    ///   The bound method.
    /// </param>
    procedure SetTearDownTestMethod(const AMethodName : string; const AMethod : TTestMethod);
    /// <summary>
    ///   Sets the fixture teardown, run once after the fixture's tests.
    /// </summary>
    /// <param name="AMethodName">
    ///   The method's name.
    /// </param>
    /// <param name="AMethod">
    ///   The bound method.
    /// </param>
    /// <param name="AIsDestructor">
    ///   True when the teardown is the class's destructor, so ExecuteFixtureTearDown frees the instance instead of
    ///   calling the method.
    /// </param>
    procedure SetTearDownFixtureMethod(const AMethodName : string; const AMethod : TTestMethod; const AIsDestructor : boolean);
    /// <summary>
    ///   Sets whether each test is to run in its own thread.
    /// </summary>
    /// <param name="value">
    ///   True to run each test in its own thread.
    /// </param>
    procedure SetTestInOwnThread(const value : Boolean);
    /// <summary>
    ///   Creates the shared RTTI context when the unit initialises.
    /// </summary>
    class constructor Create;
    /// <summary>
    ///   Frees the shared RTTI context when the unit finalises.
    /// </summary>
    class destructor Destroy;
  public
    /// <summary>
    ///   Creates a fixture around an existing instance, which the fixture then owns and frees.
    /// </summary>
    /// <param name="AName">
    ///   The fixture's full name; the part after the last '.' is its name, the part before it its namespace.
    /// </param>
    /// <param name="ACategory">
    ///   Comma-separated categories; each is trimmed.
    /// </param>
    /// <param name="AInstance">
    ///   The fixture instance.
    /// </param>
    /// <param name="AUnitName">
    ///   The unit that declares the test class.
    /// </param>
    constructor Create(const AName : string; const ACategory : string; const AInstance : TObject; const AUnitName : string); overload;
    /// <summary>
    ///   Creates a fixture for a test class, reading its [TestFixture], [Ignore] and [IgnoreMemoryLeaks] attributes and
    ///   creating its instance.
    /// </summary>
    /// <param name="AName">
    ///   The fixture's full name; the part after the last '.' is its name, the part before it its namespace.
    /// </param>
    /// <param name="ACategory">
    ///   Comma-separated categories; each is trimmed.
    /// </param>
    /// <param name="AClass">
    ///   The test class; TObject for a namespace node.
    /// </param>
    /// <param name="AUnitName">
    ///   The unit that declares the test class.
    /// </param>
    /// <remarks>
    ///   A constructor that raises does not abort building every fixture: the instance stays nil, and the runner
    ///   constructs it again (InitFixtureInstance) and reports the failure against this fixture's tests.
    /// </remarks>
    constructor Create(const AName : string; const ACategory : string; const AClass : TClass; const AUnitName : string); overload;
    /// <summary>
    ///   Frees the fixture instance, the categories, the tests and the child fixtures.
    /// </summary>
    destructor Destroy; override;

  end;

implementation

uses
{$IFDEF USE_NS}
  System.TypInfo,
  System.Generics.Defaults,
{$ELSE}
  TypInfo,
  Generics.Defaults,
{$ENDIF}
  DUnitX.Test,
  DUnitX.Utils;

{ TDUnitXTestFixture }

constructor TDUnitXTestFixture.Create(const AName : string; const ACategory : string; const AClass : TClass; const AUnitName : string);
var
  fixtureAttrib : TestFixtureAttribute;
  IgnoreMemoryLeakAttrib : IgnoreMemoryLeaks;
  IgnoredAttrib : IgnoreAttribute;
  i : integer;
  categories : TArray<string>;
  cat : string;
begin
  inherited Create;
  FTestClass := AClass;
  FUnitName := AUnitName;
  FTests := TTestList.Create;
  FCategories := TList<string>.Create(TComparer<string>.Construct(
      function(const Left, Right : string) : integer
      begin
        result := AnsiCompareText(Left, Right);
      end));

  if ACategory <> '' then
  begin
    categories := TStrUtils.SplitString(ACategory, ',');
    for cat in categories do
    begin
      FCategories.Add(Trim(cat));
    end;
  end;

  i := LastDelimiter('.', AName);
  if i <> 0 then
  begin
    FNameSpace := Copy(AName, 1, i - 1);
    FName := Copy(AName, i + 1, Length(AName));
  end
  else
  begin
    FName := AName;
    FNameSpace := AName;
  end;

  FEnabled := True;

  FIgnoreMemoryLeaks := False;
  FFixtureType := FRttiContext.GetType(FTestClass);
  if FFixtureType.TryGetAttributeOfType<IgnoreMemoryLeaks>(IgnoreMemoryLeakAttrib) then
    FIgnoreMemoryLeaks := IgnoreMemoryLeakAttrib.IgnoreLeaks;

  fixtureAttrib := nil;
  if FFixtureType.TryGetAttributeOfType<TestFixtureAttribute>(fixtureAttrib) then
    FDescription := fixtureAttrib.Description;

  FIgnoredFixture := False;
  if FFixtureType.TryGetAttributeOfType<IgnoreAttribute>(IgnoredAttrib) then
  begin
    FIgnoredFixture := True;
    FIgnoredReason := IgnoredAttrib.Reason;
  end;

  //A constructor that raises must not abort building every fixture. The instance stays nil, and the
  //runner constructs it again (InitFixtureInstance) and reports the failure against this fixture's tests.
  try
    InternalInitFixtureInstance(true);
  except
    on Exception do
      FFixtureInstance := nil;
  end;
end;

destructor TDUnitXTestFixture.Destroy;
begin
  if FFixtureInstance <> nil then
    FFixtureInstance.Free;
  if FChildren <> nil then
    FChildren.Clear;
  FChildren := nil;

  FCategories.Free;
  FTests.Clear;
  FTests := nil;
  inherited;
end;

procedure TDUnitXTestFixture.ExecuteFixtureTearDown;
begin
  if Assigned(FTearDownFixtureMethod) then
  begin
    if FTearDownFixtureIsDestructor then
      //Nils the field before freeing, so a destructor that raises is not freed again by Destroy.
      FreeAndNil(FFixtureInstance)
    else
      FTearDownFixtureMethod();
  end;
end;

function TDUnitXTestFixture.GetActiveTestCount : cardinal;
var
  lTest : ITest;
begin
  //The tests that will execute: enabled and not ignored.
  Result := 0;
  if FIgnoredFixture or (FTests = nil) then
    exit;
  for lTest in FTests do
    if lTest.Enabled and (not lTest.Ignored) then
      Inc(Result);
end;

function TDUnitXTestFixture.GetCategories : TList<string>;
begin
  result := FCategories;
end;

function TDUnitXTestFixture.GetChildren : ITestFixtureList;
begin
  if FChildren = nil then
    FChildren := TTestFixtureList.Create;
  result := FChildren;
end;

function TDUnitXTestFixture.GetDescription : string;
begin
  result := FDescription;
end;

function TDUnitXTestFixture.GetEnabled : Boolean;
begin
  result := FEnabled;
end;

function TDUnitXTestFixture.GetFixtureInstance : TObject;
begin
  result := FFixtureInstance;
end;

function TDUnitXTestFixture.GetFullName : string;
begin
  if FName <> FNameSpace then
    result := FNameSpace + '.' + FName
  else
    Result := FName;
end;

function TDUnitXTestFixture.GetHasActiveTests : boolean;
var
  lTest : ITest;
begin
  Result := False;

  if FIgnoredFixture then
    exit;

  //Only a test that will execute counts: one the filters disabled does not, so [SetupFixture] does not run for a
  //fixture whose selected tests are all ignored.
  for lTest in FTests do
  begin
    if lTest.Enabled and (not lTest.Ignored) then
      exit(true);
  end;
end;

function TDUnitXTestFixture.GetHasChildren : boolean;
begin
  result := (FChildren <> nil) and (FChildren.Count > 0);
end;

function TDUnitXTestFixture.GetHasChildTests : Boolean;
var
  fixture : ITestFixture;
begin
  result := GetHasChildren;
  if result then
  begin
    result := false;
    for fixture in FChildren do
    begin
      result := fixture.HasTests;
      if result then
        exit;
      result := fixture.HasChildTests;
      if result then
        exit;
    end;
  end;
end;

function TDUnitXTestFixture.GetHasTests : boolean;
var
  test : ITest;
begin
  result := false;
  if FTests <> nil then
    for test in FTests do
    begin
      if test.Enabled then
        exit(true);
    end;
end;

function TDUnitXTestFixture.GetIgnored : boolean;
begin
  Result := FIgnoredFixture;
end;

function TDUnitXTestFixture.GetIgnoreMemoryLeaksForMethod(
  AMethod : TRttiMethod) : Boolean;
var
  IgnoreMemoryLeak : IgnoreMemoryLeaks;
begin
  if AMethod.TryGetAttributeOfType<IgnoreMemoryLeaks>(IgnoreMemoryLeak) then
    result := IgnoreMemoryLeak.IgnoreLeaks
  else
    result := FIgnoreMemoryLeaks;
end;

function TDUnitXTestFixture.GetIgnoreReason : string;
begin
  Result := FIgnoredReason;
end;

function TDUnitXTestFixture.GetName : string;
begin
  result := FName;
end;

function TDUnitXTestFixture.GetNameSpace : string;
begin
  result := FNameSpace;
end;

function TDUnitXTestFixture.GetSetupFixtureMethod : TTestMethod;
begin
  result := FSetupFixtureMethod;
end;

function TDUnitXTestFixture.GetSetupFixtureMethodName : string;
begin
  result := FSetupFixtureMethodName;
end;

function TDUnitXTestFixture.GetSetupMethod : TTestMethod;
begin
  result := FSetupMethod;
end;

function TDUnitXTestFixture.GetSetupMethodName : string;
begin
  result := FSetupMethodName;
end;

function TDUnitXTestFixture.GetTearDownFixtureMethod : TTestMethod;
begin
  result := FTearDownFixtureMethod;
end;

function TDUnitXTestFixture.GetTearDownFixtureMethodName : string;
begin
  result := FTearDownFixtureMethodName;
end;

function TDUnitXTestFixture.GetTearDownMethod : TTestMethod;
begin
  result := FTearDownMethod;
end;

function TDUnitXTestFixture.GetTearDownMethodName : string;
begin
  result := FTearDownMethodName;
end;

function TDUnitXTestFixture.GetTestClass : TClass;
begin
  result := FTestClass;
end;

function TDUnitXTestFixture.GetTestCount : cardinal;
begin
  Result := FTests.Count;
end;

function TDUnitXTestFixture.GetTestInOwnThread : boolean;
begin
  result := FTestInOwnThread;
end;

function TDUnitXTestFixture.GetTests : ITestList;
begin
  result := FTests;
end;

function TDUnitXTestFixture.GetUnitName : string;
begin
  result := FUnitName;
end;

procedure TDUnitXTestFixture.InitFixtureInstance;
begin
  InternalInitFixtureInstance(false);
end;

procedure TDUnitXTestFixture.InternalInitFixtureInstance(const isConstructing : boolean);
var
  test : ITest;
{$IFDEF DELPHI_XE_UP}
  method : TRttiMethod;
{$ENDIF}

begin
  if FFixtureInstance = nil then
  begin
    //it's a dummy namespace fixture, don't bother with the rest.
    if FFixtureType.Handle = TypeInfo(TObject) then
    begin
      FFixtureInstance := FTestClass.Create;
      exit;
    end;

    FIgnoreFixtureSetup := false;
{$IFDEF DELPHI_XE_UP}
    //NOTE: Causes Delphi 2010 to be inconsistent with produced exe. Will sometimes crash with AV when generating fixtures.
    //If there is a parameterless constructor declared then we will use that as the
    //fixture Setup method.
    if FFixtureType.TryGetConstructor(method) then
    begin
      FIgnoreFixtureSetup := true;
      FFixtureInstance := method.Invoke(TRttiInstanceType(FFixtureType).MetaclassType, []).AsObject;
    end
    else
{$ENDIF}
      FFixtureInstance := FTestClass.Create;

    //Don't do this if we are called from the constructor as it's not needed.
    if not isConstructing then
    begin
      //The fixture instance has changed, need to update the tests to run on the new instance.
      for test in FTests do
        (test as ITestExecute).UpdateInstance(FFixtureInstance);
      //So do the setup and teardown methods, which were bound to the previous (freed) instance.
      if Assigned(FSetupMethod) then
        TMethod(FSetupMethod).Data := FFixtureInstance;
      if Assigned(FTearDownMethod) then
        TMethod(FTearDownMethod).Data := FFixtureInstance;
      if Assigned(FSetupFixtureMethod) then
        TMethod(FSetupFixtureMethod).Data := FFixtureInstance;
      if Assigned(FTearDownFixtureMethod) then
        TMethod(FTearDownFixtureMethod).Data := FFixtureInstance;
    end;
  end;
end;

function TDUnitXTestFixture.IsNameSpaceOnly : boolean;
begin
  result := FTestClass = TObject;
end;

function TDUnitXTestFixture.ITestFixtureInfo_GetTests : IList<ITestInfo>;
var
  test : ITest;
  testInfo : ITestInfo;
begin
  //Rebuilt when tests have been added since it was built (the provider adds error tests to Tests directly).
  if (FTestInfos = nil) or (FTestInfos.Count <> FTests.Count) then
  begin
    FTestInfos := TDUnitXList<ITestInfo>.Create;
    for test in FTests do
    begin
      testInfo := test as ITestInfo;
      FTestInfos.Add(testInfo);
    end;
  end;
  result := FTestInfos;
end;

procedure TDUnitXTestFixture.OnMethodExecuted(const AMethod : TTestMethod);
begin
  if FTearDownFixtureIsDestructor and (TMethod(AMethod).Code = TMethod(FTearDownFixtureMethod).Code) then
    FFixtureInstance := nil;
end;

procedure TDUnitXTestFixture.SetEnabled(const value : Boolean);
begin
  FEnabled := value;
end;

procedure TDUnitXTestFixture.SetSetupFixtureMethod(const AMethodName : string; const AMethod : TTestMethod);
begin
  //The name is kept even when the constructor takes the place of the method, so the runner can say
  //that the [SetupFixture] method is not run (SetupFixtureMethodName set, SetupFixtureMethod nil).
  FSetupFixtureMethodName := AMethodName;
  if not FIgnoreFixtureSetup then
    FSetupFixtureMethod := AMethod;
end;

procedure TDUnitXTestFixture.SetSetupTestMethod(const AMethodName : string; const AMethod : TTestMethod);
begin
  FSetupMethodName := AMethodName;
  FSetupMethod := AMethod;
end;

procedure TDUnitXTestFixture.SetTearDownFixtureMethod(const AMethodName : string; const AMethod : TTestMethod; const AIsDestructor : boolean);
begin
  FTearDownFixtureMethodName := AMethodName;
  FTearDownFixtureMethod := AMethod;
  FTearDownFixtureIsDestructor := AIsDestructor;
end;

procedure TDUnitXTestFixture.SetTearDownTestMethod(const AMethodName : string; const AMethod : TTestMethod);
begin
  FTearDownMethodName := AMethodName;
  FTearDownMethod := AMethod;
end;

procedure TDUnitXTestFixture.SetTestInOwnThread(const value : Boolean);
begin
  FTestInOwnThread := value;
end;

function TDUnitXTestFixture.AddChildFixture(const ATestClass : TClass; const AName : string; const ACategory : string) : ITestFixture;
begin
  result := TDUnitXTestFixture.Create(AName, ACategory, ATestClass, ATestClass.UnitName);
  if FChildren = nil then
    FChildren := TTestFixtureList.Create;
  FChildren.Add(result);
end;

function TDUnitXTestFixture.AddChildFixture(const AInstance : TObject; const AName : string; const ACategory : string) : ITestFixture;
begin
  result := TDUnitXTestFixture.Create(AName, ACategory, AInstance, AInstance.ClassType.UnitName);
  if FChildren = nil then
    FChildren := TTestFixtureList.Create;
  FChildren.Add(result);
end;

function TDUnitXTestFixture.AddTest(const AMethodName : string; const AMethod : TTestMethod; const AName : string; const ACategory : string; const ARttiMethod
  : TRttiMethod; const AEnabled : boolean; const AIgnored : boolean; const AIgnoreReason : string; const AMaxTime : cardinal; const AExpectedException :
  ExceptClass; const AExceptionInheritance : TExceptionInheritance) : ITest;
begin
  if AExpectedException = nil then
    result := TDUnitXTest.Create(Self, AMethodName, AName, ACategory, AMethod, AEnabled, AIgnored, AIgnoreReason, AMaxTime)
  else
    result := TDUnitXExceptionTest.Create(Self, AMethodName, AName, ACategory, AMethod, AEnabled, AIgnored, AIgnoreReason, AMaxTime, AExpectedException,
      AExceptionInheritance);
  result.IgnoreMemoryLeaks := GetIgnoreMemoryLeaksForMethod(ARttiMethod);
  FTests.Add(Result);
end;

function TDUnitXTestFixture.AddTestCase(const AMethodName : string; const ACaseName, AName : string; const ACategory : string; const AMethod : TRttiMethod;
  const AEnabled : boolean; const AArgs : TValueArray; const AMaxTime : cardinal; const AExpectedException : ExceptClass;
  const AExceptionInheritance : TExceptionInheritance) : ITest;
begin
  result := TDUnitXTestCase.Create(FFixtureInstance, Self, AMethodName, ACaseName, AName, ACategory, AMethod, AEnabled, AArgs, AMaxTime,
    AExpectedException, AExceptionInheritance);
  result.IgnoreMemoryLeaks := GetIgnoreMemoryLeaksForMethod(AMethod);
  FTests.Add(result);
end;

class constructor TDUnitXTestFixture.Create;
begin
  FRttiContext := TRttiContext.Create;
end;

class destructor TDUnitXTestFixture.Destroy;
begin
  FRttiContext.Free;
end;

constructor TDUnitXTestFixture.Create(const AName : string; const ACategory : string; const AInstance : TObject; const AUnitName : string);
begin
  FFixtureInstance := AInstance;
  Create(AName, ACategory, AInstance.ClassType, AUnitName);
end;

end.

