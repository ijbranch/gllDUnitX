{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2017 Vincent Parrett                              }
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

unit DUnitX.Tests.Example;

interface

{$I ..\Source\DUnitX.inc}

uses
  DUnitX.TestFramework,
{$IFDEF USE_NS}
  System.SysUtils;
{$ELSE}
  SysUtils;
{$ENDIF}

type
  /// <summary>
  ///   Sample enumeration whose set type is passed as a [TestCase] argument.
  /// </summary>
  TTestEnum = (
    /// <summary>Bit 0 of the set (ordinal value 1 as a set).</summary>
    teOne,
    /// <summary>Bit 1 of the set (ordinal value 2 as a set).</summary>
    teTwo,
    /// <summary>Bit 2 of the set (ordinal value 4 as a set).</summary>
    teThree
  );
  /// <summary>
  ///   Set of TTestEnum, to prove '[a,b]' strings in a [TestCase] are converted to set parameters.
  /// </summary>
  TTestEnums = set of TTestEnum;

{$M+}
  /// <summary>
  ///   Example fixture exercising the attribute surface: [TestCase] parameter conversion (integers, dates, times,
  ///   sets), categories, [MaxTime], disabled and ignored tests, [WillRaise], per-test setup/teardown, and published
  ///   methods picked up as tests.
  /// </summary>
  [TestFixture('ExampleFixture1')]
  [Category('examples')]
  TMyExampleTests = class
  public
    /// <summary>
    ///   Proves one method runs once per [TestCase] attribute with that case's comma-separated values converted to
    ///   its integer parameters.
    /// </summary>
    /// <param name="param1">
    ///   First value from the test case string.
    /// </param>
    /// <param name="param2">
    ///   Second value from the test case string.
    /// </param>
    /// <remarks>
    ///   Ideally this would be [TestCase('Case 1',[1,3,4])], but the Delphi compiler will not accept arrays of TValue
    ///   as attribute parameters, so a string constant is used: the attribute splits it and converts the values to
    ///   the method's parameters. Upstream TODOs: named parameters so some can be defaulted; cases with too many or
    ///   too few values; make sure each case runs only once (it once ran X*X times for X cases).
    /// </remarks>
    [Test]
    [TestCase('Case 1', '1,2')]
    [TestCase('Case 2', '3,4')]
    [TestCase('Case 3', '5,6')]
    procedure TestOne(param1 : integer; param2 : integer);

    /// <summary>
    ///   Proves <c>Assert.AreEqual</c> handles the full UInt64 range: High(UInt64) equals the literal
    ///   18446744073709551615 without sign or truncation errors.
    /// </summary>
    [Test]
    procedure TestUint64Max;

    /// <summary>
    ///   Proves a [TestCase] alone, without [Test], makes a method a test and converts a string and an integer
    ///   argument.
    /// </summary>
    /// <param name="a">
    ///   String value from the test case ('Blah').
    /// </param>
    /// <param name="b">
    ///   Integer value from the test case (1).
    /// </param>
    [TestCase('Case 3', 'Blah,1')]
    procedure AnotherTestMethod(const a : string; const b : integer);

    /// <summary>
    ///   Proves ISO 8601 date-time strings in every common form (space or T separator, Z, and both offset spellings)
    ///   convert to the same TDateTime parameter, to the second.
    /// </summary>
    /// <param name="dateTime">
    ///   The converted test-case value; expected to be 1988-10-21 17:44:23 once milliseconds are dropped.
    /// </param>
    [Test]
    [TestCase('Date, space, time', '1988-10-21 17:44:23.456')]
    [TestCase('Date, T, time', '1988-10-21T17:44:23.456')]
    [TestCase('Date, T, time, Z', '1988-10-21T17:44:23.456Z')]
    [TestCase('Date, T, time, offset (1)', '1988-10-21T17:44:23.456+02:30')]
    [TestCase('Date, T, time, offset (2)', '1988-10-21T17:44:23.456+0230')]
    procedure TestDateTimeArgument(dateTime : TDateTime);

    /// <summary>
    ///   Proves an ISO date-only string converts to a TDate parameter.
    /// </summary>
    /// <param name="date">
    ///   The converted test-case value; expected to be 1988-10-21.
    /// </param>
    [Test]
    [TestCase('Just date', '1988-10-21')]
    procedure TestDateArgument(const date : TDate);

    /// <summary>
    ///   Proves a time string, with or without milliseconds, converts to a TTime parameter.
    /// </summary>
    /// <param name="time">
    ///   The converted test-case value; expected to be 17:44:23 once milliseconds are dropped.
    /// </param>
    [Test]
    [TestCase('time with ms', '17:44:23.456')]
    [TestCase('time without ms', '17:44:23')]
    procedure TestTimeArgument(time : TTime);

    /// <summary>
    ///   Proves set literals (empty, single, several, and out of order) convert to the right set value, using '|' as
    ///   the case's separator so the commas inside the set are not split.
    /// </summary>
    /// <param name="aset">
    ///   The converted set.
    /// </param>
    /// <param name="ExpectedAsInteger">
    ///   The set's expected bit pattern as a byte.
    /// </param>
    [Test]
    [TestCase('Set []', '[]|0', '|')]
    [TestCase('Set [teOne]', '[teOne]|1', '|')]
    [TestCase('Set [teTwo]', '[teTwo]|2', '|')]
    [TestCase('Set [teThree]', '[teThree]|4', '|')]
    [TestCase('Set [teOne,teTwo]', '[teOne,teTwo]|3', '|')]
    [TestCase('Set [teOne,teThree]', '[teOne,teThree]|5', '|')]
    [TestCase('Set [teOne,teTwo,teThree]', '[teOne,teTwo,teThree]|7', '|')]
    [TestCase('Set [teThree,teTwo,teOne]', '[teThree,teTwo,teOne]|7', '|')]
    procedure TestSetArgument(aset : TTestEnums; ExpectedAsInteger : UInt8);

    /// <summary>
    ///   Proves a test carrying a comma-separated [Category] runs (and so can be selected by either category); the
    ///   assertion itself is trivial.
    /// </summary>
    [Test]
    [Category('Bar,foo')]
    procedure TestTwo;

    /// <summary>
    ///   Second test in the 'Bar,foo' categories, so a category filter has more than one test to select.
    /// </summary>
    [Test]
    [Category('Bar,foo')]
    procedure TestTwoOne;

    /// <summary>
    ///   Proves a test that finishes inside its [MaxTime] limit passes; [MaxTime] is checked after the method returns,
    ///   and exceeding it would fail the test with ETimedOut.
    /// </summary>
    [Test]
    [MaxTime(1000)]
    procedure TestMaxTime;

    /// <summary>
    ///   Disabled with [Test(false)]: proves a disabled test is never called (it raises if it is).
    /// </summary>
    /// <exception cref="Exception">
    ///   Raised if the runner calls it, which would show [Test(false)] was not honoured.
    /// </exception>
    [Test(false)]
    procedure DontCallMe;

    /// <summary>
    ///   Proves an [Ignore]d test is reported as ignored and not run; its body fails if called.
    /// </summary>
    [Test]
    [Ignore('I was told to ignore me')]
    procedure IgnoreMe;

    /// <summary>
    ///   Proves [WillRaise(EOutOfMemory)] turns the expected exception into a pass.
    /// </summary>
    [WillRaise(EOutOfMemory)]
    procedure FailMe;

    /// <summary>
    ///   Proves [WillRaise(..., exDescendant)] accepts a descendant: EOutOfMemory satisfies EHeapException.
    /// </summary>
    [WillRaise(EHeapException, exDescendant)]
    procedure FailMeToo;

    /// <summary>
    ///   Proves [WillRaise(Exception, exDescendant)] accepts any exception, here EAbort.
    /// </summary>
    [WillRaise(Exception, exDescendant)]
    procedure FailAny;

    /// <summary>
    ///   Proves [Ignore] wins over [WillRaise]: the method raises EAbort, not EOutOfMemory, and would fail if run.
    /// </summary>
    [WillRaise(EOutOfMemory)]
    [Ignore('I am not behaving as I should')]
    procedure IgnoreMeCauseImWrong;

    /// <summary>
    ///   Per-test setup; reports a status line so the log shows it ran before each test.
    /// </summary>
    [Setup]
    procedure Setup;

    /// <summary>
    ///   Per-test teardown; reports a status line so the log shows it ran after each test.
    /// </summary>
    [TearDown]
    procedure TearDown;

  published
    /// <summary>
    ///   Proves a published method with no [Test] attribute is still run as a test, and takes its [Category].
    /// </summary>
    [Category('blah')]
    procedure TestMeAnyway;

    /// <summary>
    ///   Proves [Ignore] is honoured on a published (attribute-less) test; its body fails if called.
    /// </summary>
    [Ignore('I was told to ignore me anyway')]
    procedure IgnoreMeAnyway;

  end;

  /// <summary>
  ///   Proves published methods are included as tests: the test sets a flag that the per-test teardown asserts.
  /// </summary>
  [TestFixture]
  TExampleFixture2 = class
  private
    /// <summary>Set by the published test; checked by TearDownFixture to prove the test ran.</summary>
    FPublished_Procedures_Are_Included_As_Tests_Called : Boolean;
  public
    /// <summary>
    ///   Per-test setup (despite its name): logs and clears the "test was called" flag.
    /// </summary>
    [Setup]
    procedure SetupFixture;
    /// <summary>
    ///   Per-test teardown (despite its name): asserts the published test set the flag.
    /// </summary>
    /// <exception cref="ETestFailure">
    ///   Raised (via Assert) when the published test did not run.
    /// </exception>
    [Teardown]
    procedure TearDownFixture;
    /// <summary>
    ///   Empty destructor, present so the fixture has a virtual destructor for the runner to call.
    /// </summary>
    destructor Destroy; override;
  published
    /// <summary>
    ///   Proves a published method without [Test] is discovered and run, by recording that it was called.
    /// </summary>
    procedure Published_Procedures_Are_Included_As_Tests;
  end;

  /// <summary>
  ///   Proves the fixture's constructor serves as fixture setup: when a parameterless constructor exists, the
  ///   [SetupFixture] method is not called.
  /// </summary>
  [TestFixture]
  TExampleFixture3 = class
  private
    /// <summary>Set by the constructor; asserted by ATest.</summary>
    FSetupCalled : boolean;
  public
{$IFDEF DELPHI_XE_UP}
    /// <summary>
    ///   Fixture setup by construction: records that it ran. (Delphi 2010 did not call the constructor, hence the
    ///   AfterConstruction alternative.)
    /// </summary>
    constructor Create;
{$ELSE}
    /// <summary>
    ///   Fixture setup on compilers that do not call the constructor: records that it ran.
    /// </summary>
    procedure AfterConstruction; override;
{$ENDIF}
    /// <summary>
    ///   Fixture teardown by destruction; empty.
    /// </summary>
    destructor Destroy; override;

    /// <summary>
    ///   Must not be called when the constructor provides fixture setup; fails if it is.
    /// </summary>
    /// <exception cref="ETestFailure">
    ///   Raised (via Assert) if the runner calls it.
    /// </exception>
    [SetupFixture]
    procedure SetupFixture;
  published
    /// <summary>
    ///   Proves the constructor ran before the fixture's tests.
    /// </summary>
    procedure ATest;
  end;

implementation

uses
  DUnitX.DUnitCompatibility,
  DUnitX.Exceptions,
  System.Diagnostics,
{$IFDEF USE_NS}
  System.DateUtils;
{$ELSE}
  Diagnostics,
  DateUtils;
{$ENDIF}

procedure TMyExampleTests.DontCallMe;
begin
  TDUnitX.CurrentRunner.Status('DontCallMe called');
  raise Exception.Create('DontCallMe was called!!!!');
end;

procedure TMyExampleTests.FailAny;
begin
  Abort;
end;

procedure TMyExampleTests.FailMe;
begin
  OutOfMemoryError;
end;

procedure TMyExampleTests.FailMeToo;
begin
  OutOfMemoryError;
end;

procedure TMyExampleTests.IgnoreMe;
begin
  Assert.IsTrue(false, 'I should not have been called!');
end;

procedure TMyExampleTests.IgnoreMeAnyway;
begin
  Assert.IsTrue(false, 'I should not have been called!');
end;

procedure TMyExampleTests.IgnoreMeCauseImWrong;
begin
  Abort;
end;

procedure TMyExampleTests.Setup;
begin
  TDUnitX.CurrentRunner.Status('Setup called');
end;

procedure TMyExampleTests.TearDown;
begin
  TDUnitX.CurrentRunner.Status('TearDown called');
end;

procedure TMyExampleTests.AnotherTestMethod(const a : string; const b : integer);
begin
  TDUnitX.CurrentRunner.Status(Format('TestCaseBlah called with %s %d', [a, b]));
  Assert.Pass;
end;

procedure TMyExampleTests.TestDateArgument(const date : TDate);
var
  expected : TDate;
begin
  expected := EncodeDate(1988, 10, 21);
  Assert.IsSameDate(expected, date, 'SameDate(..)');
end;

procedure TMyExampleTests.TestDateTimeArgument(dateTime : TDateTime);
var
  expected : TDateTime;
begin
  dateTime := RecodeMilliSecond(dateTime, 000);
  expected := EncodeDateTime(1988, 10, 21, 17, 44, 23, 000);
  Assert.IsSameDateTime(expected, dateTime, 'SameDateTime(..)');
end;

procedure TMyExampleTests.TestMaxTime;
var
  elapsedTime : Int64;
  stopwatch : TStopWatch;
begin
  //[MaxTime] is checked once the test method returns, so it can no longer be observed
  //from inside the test the way this example used to do. Exceeding the limit fails the
  //test with ETimedOut; staying inside it, as here, simply passes.
  stopwatch := TStopWatch.Create;
  stopwatch.Reset;
  stopwatch.Start;

  repeat
    //Give some time back to the system to process the test.
    Sleep(20);

    elapsedTime := stopwatch.ElapsedMilliseconds;
  until (elapsedTime >= 100);

  Assert.Pass('completed within the permitted time');
end;

procedure TMyExampleTests.TestMeAnyway;
begin
  TDUnitX.CurrentRunner.Status('TestMeAnyway called');
  Assert.Pass;
end;

procedure TMyExampleTests.TestOne(param1 : integer; param2 : integer);
begin
  TDUnitX.CurrentRunner.Status(Format('TestOnce called with %d %d', [param1, param2]));
  Assert.Pass;
end;

procedure TMyExampleTests.TestSetArgument(aset : TTestEnums;
  ExpectedAsInteger : UInt8);
begin
  Assert.AreEqual(ExpectedAsInteger, UInt8(aset));
end;

procedure TMyExampleTests.TestTimeArgument(time : TTime);
var
  expected : TTime;
begin
  time := RecodeMilliSecond(time, 0);
  expected := EncodeTime(17, 44, 23, 000);
  Assert.IsSameTime(expected, time, 'SameTime(..)');
end;

procedure TMyExampleTests.TestTwo;
var
  x : TMyExampleTests;
begin
  TDUnitX.CurrentRunner.Status('TestTwo called');
  x := TMyExampleTests.Create;
  //CheckIs(x,TObject); //DUnit compatibility.
  TDUnitX.CurrentRunner.Status('hello world');
  Assert.IsTrue(x is TObject);          /// a bit pointless since it's strongly typed.
  x.Free;
end;

procedure TMyExampleTests.TestTwoOne;
var
  x : TMyExampleTests;
begin
  TDUnitX.CurrentRunner.Status('TestTwo called');
  x := TMyExampleTests.Create;
  //CheckIs(x,TObject); //DUnit compatibility.
  TDUnitX.CurrentRunner.Status('hello world');
  Assert.IsTrue(x is TObject);          /// a bit pointless since it's strongly typed.
  x.Free;
end;

procedure TMyExampleTests.TestUint64Max;
const
  UInt64MaxValue    : UInt64 = 18446744073709551615;
var
  LUInt64Value : UInt64;
begin
  LUInt64Value := High(UInt64);
  Assert.AreEqual(UInt64MaxValue, LUInt64Value);
end;

destructor TExampleFixture2.Destroy;
begin
  //Empty
  inherited;
end;

procedure TExampleFixture2.Published_Procedures_Are_Included_As_Tests;
begin
  FPublished_Procedures_Are_Included_As_Tests_Called := True;
  Assert.Pass;
end;

procedure TExampleFixture2.SetupFixture;
begin
  TDUnitX.CurrentRunner.Log('Setting up...');
  FPublished_Procedures_Are_Included_As_Tests_Called := False;
end;

procedure TExampleFixture2.TearDownFixture;
begin
  TDUnitX.CurrentRunner.Log('Tearing down');
  Assert.IsTrue(FPublished_Procedures_Are_Included_As_Tests_Called);
end;

procedure TExampleFixture3.ATest;
begin
  Assert.IsTrue(FSetupCalled);
end;

{$IFDEF DELPHI_XE_UP}
constructor TExampleFixture3.Create;

{$ELSE}
procedure TExampleFixture3.AfterConstruction;
{$ENDIF}
begin
  FSetupCalled := True;
end;

destructor TExampleFixture3.Destroy;
begin
  //Empty
  inherited;
end;

procedure TExampleFixture3.SetupFixture;
begin
  Assert.IsTrue(False, 'I should not be called!');
end;

initialization

  //I was hoping to use RTTI to discover the TestFixture classes, however unlike .NET
  //if we don't touch the class somehow then the linker will remove
  //the class from the resulting exe.
  //We could just do this:
  //TMyExampleTests.ClassName;
  //TExampleFixture2.ClassName;
  //which is enough to make the compiler link the classes into the exe, but that seems a
  //bit redundent so I guess we'll just use manual registration. If you use the
  //{$STRONGLINKTYPES ON} compiler directive then it will link the TestFixtures in and you
  //can use RTTI. The downside to that is the resulting exe will potentially much larger.
  //Not sure which version {$STRONGLINKTYPES ON} was introduced so we'll allow RTTI and
  //manual registration for now.

  //Register the test fixtures
  TDUnitX.RegisterTestFixture(TMyExampleTests);
  TDUnitX.RegisterTestFixture(TExampleFixture2);
  TDUnitX.RegisterTestFixture(TExampleFixture3);

end.

