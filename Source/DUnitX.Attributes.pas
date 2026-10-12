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

unit DUnitX.Attributes;

interface

{$I DUnitX.inc}

uses
{$IFDEF USE_NS}
  System.Rtti,
  System.SysUtils,
{$ELSE}
  Rtti,
  SysUtils,
{$ENDIF}
  DUnitX.Types,
  DUnitX.InternalDataProvider;

type
  /// <summary>
  ///   A class decorated with this attribute will be tested. The parameters
  ///   allow you to control which methods are treated as tests. By default
  ///   only methods decorated with the Test attribute are run as tests.
  /// </summary>
  TestFixtureAttribute = class(TCustomAttribute)
  private
    /// <summary>Display name of the fixture; empty means the class name is used.</summary>
    FName : string;
    /// <summary>Free-text description of the fixture.</summary>
    FDescription : string;
  public
    /// <summary>
    ///   Marks the class as a fixture with no explicit name or description.
    /// </summary>
    constructor Create; overload;
    /// <summary>
    ///   Marks the class as a fixture with an explicit name.
    /// </summary>
    /// <param name="AName">
    ///   Display name of the fixture.
    /// </param>
    constructor Create(const AName : string); overload;
    /// <summary>
    ///   Marks the class as a fixture with an explicit name and description.
    /// </summary>
    /// <param name="AName">
    ///   Display name of the fixture.
    /// </param>
    /// <param name="ADescription">
    ///   Free-text description of the fixture.
    /// </param>
    constructor Create(const AName : string; const ADescription : string); overload;
    /// <summary>Display name of the fixture; empty means the class name is used.</summary>
    property Name : string read FName;
    /// <summary>Free-text description of the fixture.</summary>
    property Description : string read FDescription;
  end;

  /// <summary>
  ///   A TestFixture decorated with this attribute will be tested using it's
  ///   own thread. This can speed up unit testing when fixtures do not
  ///   compete for resources and the test machine has enough cores to service
  ///   the tests.
  /// </summary>
  /// <remarks>
  ///   NOTE - CURRENTLY PLANNED BUT NOT IMPLEMENTED!!!
  /// </remarks>
  TestInOwnThreadAttribute = class(TCustomAttribute)
  end;

  /// <summary>
  ///   A method marked with this attribute will run before any tests in. Note
  ///   that if more than one method is decorated with this attribute the first
  ///   method found will be executed (not recommended!).
  /// </summary>
  SetupFixtureAttribute = class(TCustomAttribute)
  end;

  /// <summary>
  ///   A method on a test fixture decorated with this attribute will run
  ///   before each test method is run. Note that if more than one method is
  ///   decorated with this attribute the first method found will be executed
  ///   (not recommended!).
  /// </summary>
  SetupAttribute = class(TCustomAttribute)
  end;

  /// <summary>
  ///   A method on a test fixture class decorated with this attribute will be
  ///   run after each test method is run. Note that if more than one method is
  ///   decorated with this attribute the first method found will be executed
  ///   (not recommended!).
  /// </summary>
  TearDownAttribute = class(TCustomAttribute)
  end;

  /// <summary>
  ///   A method marked with this attribute can contain a teardown method that
  ///   will be run after each all tests in the fixture have executed. Note
  ///   that if more than one method is decorated with this attribute the first
  ///   method found will be executed (not recommended!).
  /// </summary>
  TearDownFixtureAttribute = class(TCustomAttribute)
  end;

  /// <summary>
  ///   This attribue is applied to test methods. If a test is successful and
  ///   produces a memory leak it will be reported. If you do not want the
  ///   leak reported, then you can add this attribute to the test method.
  /// </summary>
  IgnoreMemoryLeaks = class(TCustomAttribute)
  private
    /// <summary>True when leaks from the decorated test are not reported.</summary>
    FIgnoreMemoryLeaks : Boolean;
  public
    /// <summary>
    ///   Sets whether memory leaks from the decorated test (or fixture) are ignored.
    /// </summary>
    /// <param name="AIgnoreMemoryLeaks">
    ///   True (the default) to ignore leaks; False to report them, e.g. to override a fixture-level setting.
    /// </param>
    constructor Create(const AIgnoreMemoryLeaks : Boolean = True);
    /// <summary>True when leaks from the decorated test are not reported.</summary>
    property IgnoreLeaks : Boolean read FIgnoreMemoryLeaks;
  end;

  ///	<summary>
  ///	  Marks a test method to fail after the time specified.
  ///  Currently only support on Win32 &amp; Win64
  ///	</summary>
  ///	<remarks>
  ///	  If [MaxTime(1000)] used then the test will fail if the
  ///   test takes longer than 1000ms
  ///	</remarks>
  MaxTimeAttribute = class(TCustomAttribute)
  private
    /// <summary>Time limit in milliseconds.</summary>
    FMaxTime : Cardinal;
  public
    /// <summary>
    ///   Sets the time limit for the decorated test.
    /// </summary>
    /// <param name="AMaxTime">
    ///   Time limit in milliseconds.
    /// </param>
    constructor Create(const AMaxTime : Cardinal);
    /// <summary>Time limit in milliseconds.</summary>
    property MaxTime : Cardinal read FMaxTime;
  end;

  /// <summary>
  ///   This attribute marks a method as a test method
  /// </summary>
  TestAttribute = class(TCustomAttribute)
  private
    /// <summary>False when the test is registered but not run.</summary>
    FEnabled : boolean;
  public
    /// <summary>
    ///   Marks the method as an enabled test.
    /// </summary>
    constructor Create; overload;
    /// <summary>
    ///   Marks the method as a test, enabled or not.
    /// </summary>
    /// <param name="AEnabled">
    ///   False to register the test without running it.
    /// </param>
    constructor Create(const AEnabled : boolean); overload;
    /// <summary>False when the test is registered but not run.</summary>
    property Enabled : boolean read FEnabled;
  end;

  /// <summary>
  ///   This attribute allows you to specify a test Category which can be used
  ///   when filtering the tests to run.
  /// </summary>
  CategoryAttribute = class(TCustomAttribute)
  private
    /// <summary>The category text as written on the attribute.</summary>
    FCategory : string;
  public
    /// <summary>
    ///   Assigns the decorated test or fixture to one or more categories.
    /// </summary>
    /// <param name="ACategory">
    ///   Category name(s); the framework splits a comma-separated list into several categories.
    /// </param>
    constructor Create(const ACategory : string);
    /// <summary>The category text as written on the attribute.</summary>
    property Category : string read FCategory;
  end;

  /// <summary>
  ///   This attribute will prevent a test from being run. It will still show
  ///   up in the lists of tests, and reported as an Ignored test
  /// </summary>
  /// <remarks>
  ///   This is useful when you need to temporarily stop a test from running.
  /// </remarks>
  IgnoreAttribute = class(TCustomAttribute)
  private
    /// <summary>Why the test is ignored; reported with the result.</summary>
    FReason : string;
  public
    /// <summary>
    ///   Marks the test (or fixture) as ignored.
    /// </summary>
    /// <param name="AReason">
    ///   Why the test is ignored; reported with the result.
    /// </param>
    constructor Create(const AReason : string = '');
    /// <summary>Why the test is ignored; reported with the result.</summary>
    property Reason : string read FReason;
  end;

  /// <summary>
  ///   Marks a test method to be repeated count times.
  /// </summary>
  /// <remarks>
  ///   If [RepeatTest(0)] used then the test will be skipped and behaves like
  ///   IgnoreAttribute
  /// </remarks>
  RepeatTestAttribute = class(TCustomAttribute)
  private
    /// <summary>Number of times the test runs; 0 ignores it.</summary>
    FCount : Cardinal;
  public
    /// <summary>
    ///   Sets how many times the decorated test runs.
    /// </summary>
    /// <param name="ACount">
    ///   Number of runs; 0 ignores the test.
    /// </param>
    constructor Create(const ACount : Cardinal);
    /// <summary>Number of times the test runs; 0 ignores it.</summary>
    property Count : Cardinal read FCount;
  end;

  /// <summary>
  ///   This attribute marks a method as a test method which will raise an exception.
  /// </summary>
  /// <remarks>
  ///   If [WillRaise(ERangeError)] is used then the test will fail if it
  ///   does not raise an ERangeError.
  /// </remarks>
  WillRaiseAttribute = class(TCustomAttribute)
  private
    /// <summary>The exception class the test must raise.</summary>
    FExpectedException : ExceptClass;
    /// <summary>Whether a descendant of the expected class also satisfies the test.</summary>
    FExceptionInheritance : TExceptionInheritance;
  public
    /// <summary>
    ///   Declares the exception the decorated test must raise to pass.
    /// </summary>
    /// <param name="AExpectedException">
    ///   The exception class the test must raise.
    /// </param>
    /// <param name="AInheritance">
    ///   <c>exExact</c> (default) requires exactly that class; <c>exDescendant</c> also accepts descendants.
    /// </param>
    constructor Create(AExpectedException : ExceptClass; const AInheritance : TExceptionInheritance = exExact);
    /// <summary>The exception class the test must raise.</summary>
    property ExpectedException : ExceptClass read FExpectedException;
    /// <summary>Whether a descendant of the expected class also satisfies the test.</summary>
    property ExceptionInheritance : TExceptionInheritance read FExceptionInheritance;
  end;

  /// <summary>
  ///   Internal Structure used for those implementing CustomTestCase or
  ///   CustomTestCaseSource descendants.
  /// </summary>
  TestCaseInfo = record

    /// <summary>
    ///   Name of the Test Case
    /// </summary>
    Name : string;

    /// <summary>
    ///   Values that will be passed to the method being tested.
    /// </summary>
    Values : TValueArray;
  end;

  /// <summary>
  ///   Dynamic array of test cases, returned by a test case source attribute.
  /// </summary>
  TestCaseInfoArray = TArray<TestCaseInfo>;

  /// <summary>
  ///   Base class for all Test Case Attributes.
  /// </summary>
  /// <remarks>
  ///   Class is abstract and should never be, used to annotate a class as a
  ///   attribute. Instead use a descendant, that implements the GetCaseInfo
  ///   method.
  /// </remarks>
  CustomTestCaseAttribute = class abstract(TCustomAttribute)
  protected
    /// <summary>
    ///   Returns the single test case this attribute supplies.
    /// </summary>
    /// <returns>
    ///   The case's name and argument values.
    /// </returns>
    function GetCaseInfo : TestCaseInfo; virtual; abstract;
  public
    /// <summary>The single test case this attribute supplies.</summary>
    property CaseInfo : TestCaseInfo read GetCaseInfo;
  end;

  /// <summary>
  ///   Base class for all Test Case Source Attributes.
  /// </summary>
  /// <remarks>
  ///   <para>
  ///     Class is abstract and should never be, used to annotate a class as
  ///     a attribute. Instead use a descendant, that implements the
  ///     GetCaseInfoArray method.
  ///   </para>
  ///   <para>
  ///     Note: If a method is annotated with a descendant of
  ///     TestCaseSourceAttribute and returns an empty TestCaseInfoArray,
  ///     then no test will be shown for the method.
  ///   </para>
  /// </remarks>
  CustomTestCaseSourceAttribute = class abstract(TCustomAttribute)
  protected
    /// <summary>
    ///   Returns every test case this attribute supplies.
    /// </summary>
    /// <returns>
    ///   The cases, each with a name and argument values; may be empty.
    /// </returns>
    function GetCaseInfoArray : TestCaseInfoArray; virtual; abstract;
  public
    /// <summary>Every test case this attribute supplies.</summary>
    property CaseInfoArray : TestCaseInfoArray read GetCaseInfoArray;
  end;

  /// <summary>
  ///   The TestCaseAttribute allows you to pass values to a test function.
  ///   Each value is delimited in the string, by default the delimiter is ','
  /// </summary>
  TestCaseAttribute = class(CustomTestCaseAttribute)
  protected
    /// <summary>The case name and its values, split from the attribute text as strings.</summary>
    FCaseInfo : TestCaseInfo;
    /// <summary>The unsplit values text as written on the attribute.</summary>
    FValues : string;
    /// <summary>
    ///   Returns the case built by the constructor.
    /// </summary>
    /// <returns>
    ///   The case name and its string values.
    /// </returns>
    function GetCaseInfo : TestCaseInfo; override;
    /// <summary>
    ///   Returns the case name.
    /// </summary>
    /// <returns>
    ///   The name given to the constructor (empty for an auto-named case).
    /// </returns>
    function GetName : string;
    /// <summary>
    ///   Returns the split values.
    /// </summary>
    /// <returns>
    ///   One string <c>TValue</c> per separated value; the framework converts them to the parameter types later.
    /// </returns>
    function GetValues : TValueArray;
    /// <summary>
    ///   Returns the unsplit values text.
    /// </summary>
    /// <returns>
    ///   The values text exactly as written on the attribute.
    /// </returns>
    function GetValuesText : string;
  public
    /// <summary>
    ///   Defines a named test case whose argument values are given as one delimited string.
    /// </summary>
    /// <param name="ACaseName">
    ///   Name of the case, shown after the method name.
    /// </param>
    /// <param name="AValues">
    ///   The argument values, separated by <paramref name="ASeparator" />.
    /// </param>
    /// <param name="ASeparator">
    ///   Value separator; a comma by default.
    /// </param>
    /// <param name="ATrimValues">
    ///   True to trim surrounding white space from each value.
    /// </param>
    constructor Create(const ACaseName : string; const AValues : string; const ASeparator : string = ','; const ATrimValues : boolean = false);
    /// <summary>Name of the case.</summary>
    property Name : string read GetName;
    /// <summary>The split values, each as a string <c>TValue</c>.</summary>
    property Values : TValueArray read GetValues;
    /// <summary>The unsplit values text as written on the attribute.</summary>
    property ValuesText : string read GetValuesText;
  end;

  /// <summary>
  ///   The AutoTestCaseAttribute allows you to pass values to a test function.
  ///   Each value is delimited in the string, by default the delimiter is ','
  ///   The case name is generated by concatenating the test method name with (values)
  /// </summary>
  AutoNameTestCaseAttribute = class(TestCaseAttribute)
  protected
  public
    /// <summary>
    ///   Defines an unnamed test case whose name is generated from the method name and its values.
    /// </summary>
    /// <param name="AValues">
    ///   The argument values, separated by <paramref name="ASeparator" />.
    /// </param>
    /// <param name="ASeparator">
    ///   Value separator; a comma by default.
    /// </param>
    /// <param name="ATrimValues">
    ///   True to trim surrounding white space from each value.
    /// </param>
    /// <remarks>
    ///   A separate class because a second TestCaseAttribute constructor could not be made to resolve sensibly against
    ///   the existing overload.
    /// </remarks>
    constructor Create(const AValues : string; const ASeparator : string = ','; const ATrimValues : boolean = false);
  end;

  /// <summary>
  /// TestCaseProvider Attribute allows you, to pass a registered
  /// Class to the Test, that provides the test function width the
  /// needed data.
  /// </summary>
  TestCaseProviderAttribute = class(TCustomAttribute)
  protected
    /// <summary>Registered name of the provider, or empty when given by class.</summary>
    FName : string;
    /// <summary>Provider class, or nil when given by name.</summary>
    FClass : TTestDataProviderClass;
  public
    /// <summary>
    ///   Names the registered test-data provider that supplies the decorated method's cases.
    /// </summary>
    /// <param name="providerName">
    ///   Name under which the provider was registered.
    /// </param>
    constructor Create(const providerName : string); overload;
    /// <summary>
    ///   Gives the test-data provider class that supplies the decorated method's cases.
    /// </summary>
    /// <param name="AClass">
    ///   The provider class.
    /// </param>
    constructor Create(const AClass : TTestDataProviderClass); overload;
    /// <summary>Registered name of the provider, or empty when given by class.</summary>
    property ProviderName : string read Fname;
    /// <summary>Provider class, or nil when given by name.</summary>
    property ProviderClass : TTestDataProviderClass read FClass;
  end;

implementation

uses
{$IFDEF USE_NS}
  System.Types,
  System.StrUtils,
{$ELSE}
  Types,
  StrUtils,
{$ENDIF}
  DUnitX.Utils;

{ TestFixture }

constructor TestFixtureAttribute.Create;
begin
  inherited;
end;

constructor TestFixtureAttribute.Create(const AName : string);
begin
  inherited Create;
  FName := AName;
end;

constructor TestFixtureAttribute.Create(const AName : string; const ADescription : string);
begin
  inherited Create;
  FName := AName;
  FDescription := ADescription;
end;

{ IgnoreMemoryLeaks }

constructor IgnoreMemoryLeaks.Create(const AIgnoreMemoryLeaks : Boolean);
begin
  inherited Create;
  FIgnoreMemoryLeaks := AIgnoreMemoryLeaks;
end;

{ TestAttribute }

constructor TestAttribute.Create;
begin
  inherited;
  FEnabled := True;
end;

constructor TestAttribute.Create(const AEnabled : boolean);
begin
  inherited Create;
  FEnabled := AEnabled;
end;

{ CategoryAttribute }

constructor CategoryAttribute.Create(const ACategory : string);
begin
  inherited Create;
  FCategory := ACategory;
end;

{ IgnoreAttribute }

constructor IgnoreAttribute.Create(const AReason : string);
begin
  inherited Create;
  FReason := AReason;
end;

{ RepeatTestAttribute }

constructor RepeatTestAttribute.Create(const ACount : Cardinal);
begin
  inherited Create;
  FCount := ACount;
end;

{ TestCaseAttribute }

constructor TestCaseAttribute.Create(const ACaseName : string; const AValues : string; const ASeparator : string; const ATrimValues : boolean);
var
  i : Integer;
  l : integer;
  lValues : TStringDynArray;
begin
  inherited Create;
  FCaseInfo.Name := ACaseName;
  FValues := AValues;
  lValues := SplitString(AValues, ASeparator);
  l := Length(lValues);
  SetLength(FCaseInfo.Values, l);
  for i := 0 to l - 1 do
  begin
    if ATrimValues then
      FCaseInfo.Values[i] := TValue.From<string>(Trim(lValues[i]))
    else
      FCaseInfo.Values[i] := TValue.From<string>(lValues[i]);
  end;
end;

function TestCaseAttribute.GetCaseInfo : TestCaseInfo;
begin
  Result := FCaseInfo;
end;

function TestCaseAttribute.GetName : string;
begin
  Result := FCaseInfo.Name;
end;

function TestCaseAttribute.GetValues : TValueArray;
begin
  Result := FCaseInfo.Values;
end;

function TestCaseAttribute.GetValuesText : string;
begin
  result := FValues;
end;

{ MaxTimeAttribute }

constructor MaxTimeAttribute.Create(const AMaxTime : Cardinal);
begin
  inherited Create;
  FMaxTime := AMaxTime;
end;

{ WillRaiseAttribute }

constructor WillRaiseAttribute.Create(AExpectedException : ExceptClass; const AInheritance : TExceptionInheritance);
begin
  inherited Create;
  FExpectedException := AExpectedException;
  FExceptionInheritance := AInheritance;
end;

{ TestCaseProviderAttribute }

constructor TestCaseProviderAttribute.Create(const providerName : string);
begin
  inherited Create;
  FName := ProviderName;
  FClass := nil;
end;

constructor TestCaseProviderAttribute.Create(const AClass : TTestDataProviderClass);
begin
  inherited Create;
  FName := '';
  FClass := AClass;
end;

{ AutoTestCaseAttribute }

{ AutoNameTestCaseAttribute }

constructor AutoNameTestCaseAttribute.Create(const AValues, ASeparator : string; const ATrimValues : boolean);
begin
  inherited Create('', AValues, ASeparator, ATrimValues);
end;

end.

