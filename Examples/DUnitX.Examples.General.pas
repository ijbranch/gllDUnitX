{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2013 Vincent Parrett                              }
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

unit DUnitX.Examples.General;

{$I DUnitX.inc}

//{$STRONGLINKTYPES ON}

interface

uses
  DUnitX.TestFramework;

type
  {$M+}
  /// <summary>
  ///   Tour of the test attributes: NamedTestCase and TestCase parameters, categories, MaxTime, disabled and
  ///   ignored tests, Setup/TearDown, logging, and published methods as implicit tests. Some tests fail on purpose.
  /// </summary>
  [TestFixture('Examples.Fixture1','General Example Tests')]
  TMyExampleTests = class
  public
    /// <summary>
    ///   Runs once per NamedTestCase attribute, showing one test fed several parameter sets; it only reports the values.
    /// </summary>
    /// <param name="param1">
    ///   First value from the test case.
    /// </param>
    /// <param name="param2">
    ///   Second value from the test case.
    /// </param>
    /// <remarks>
    ///   Ideally this would be <c>[NamedTestCase('Case 1',[1,3,4])]</c>, but the Delphi compiler does not accept arrays of
    ///   TValue as attribute parameters, so a string constant is used: the attribute splits it and converts the values
    ///   to the test method's parameter types.
    /// </remarks>
    [Test]
    [NamedTestCase('Case 1','1,2')]
    [NamedTestCase('Case 2','3,4')]
    [NamedTestCase('Case 3','5,6')]
    procedure TestOne(param1 : integer; param2 : integer);


    /// <summary>
    ///   Runs once per TestCase attribute, showing cases named from their values rather than given a name, and
    ///   the Category attribute; it only reports the values.
    /// </summary>
    /// <param name="param1">
    ///   First value from the test case.
    /// </param>
    /// <param name="param2">
    ///   Second value from the test case.
    /// </param>
    [Test]
    [TestCase('1,2')]
    [TestCase('3,4')]
    [TestCase('5,6')]
    [Category('auto')]
    procedure TestAutoName(param1 : integer; param2 : integer);

    /// <summary>
    ///   Shows that a NamedTestCase attribute alone, without [Test], makes a method a test; converts a string and an integer
    ///   and only reports them.
    /// </summary>
    /// <param name="a">
    ///   String value from the test case.
    /// </param>
    /// <param name="b">
    ///   Integer value from the test case.
    /// </param>
    [NamedTestCase('Case 3','Blah,1')]
    procedure AnotherTestMethod(const a : string; const b : integer);

    /// <summary>
    ///   Shows test case values that themselves contain '=' and quotes being split correctly; it only reports them.
    /// </summary>
    /// <param name="AInput">
    ///   First string from the test case.
    /// </param>
    /// <param name="AResult">
    ///   Second string from the test case.
    /// </param>
    [Test]
    [NamedTestCase('Case4','password="",password=""')]
    procedure TestCaseWithStrings(const AInput : string; const AResult : string);

    /// <summary>
    ///   Shows status messages and Assert.InheritsFrom (a TStringList's class inherits from TStrings).
    /// </summary>
    [Test]
    procedure TestTwo;

    /// <summary>
    ///   Fails on purpose by raising a plain Exception, showing how the runner reports an error as opposed to a
    ///   failed assertion.
    /// </summary>
    [Test]
    procedure TestError;

    /// <summary>
    ///   Fails on purpose: sleeps 5 seconds against a MaxTime of 2 seconds, showing the timeout being enforced.
    /// </summary>
    [Test]
    [MaxTime(2000)]
    procedure TooLong;


    /// <summary>
    ///   Disabled with [Test(false)], so it must never run; it raises if it is ever called.
    /// </summary>
    [Test(false)]
    procedure DontCallMe;

    /// <summary>
    ///   Runs before each test of the fixture; reports a status message.
    /// </summary>
    [Setup]
    procedure Setup;

    /// <summary>
    ///   Runs after each test of the fixture; reports a status message.
    /// </summary>
    [TearDown]
    procedure TearDown;

    /// <summary>
    ///   Public method with no test attribute; not being published, it is not treated as a test.
    /// </summary>
    procedure TestMeAnyway;

    /// <summary>
    ///   Shows logging through the current runner at the Information, Warning and Error levels.
    /// </summary>
    [Test]
    procedure LogMessageTypes;

    /// <summary>
    ///   Ignored with [Ignore], so it must be reported as ignored and never run; it raises if it is ever called.
    /// </summary>
    [Test]
    [Ignore('Because I said so!!!')]
    procedure IgnoreMePublic;

  published
    /// <summary>
    ///   Published, so a test without needing [Test]; ignored with [Ignore], and raises if it is ever called.
    /// </summary>
    [Ignore('Because he said so!!!')]
    procedure IgnoreMePublished;
  end;

  /// <summary>
  ///   Shows fixture-level setup and teardown: the teardown asserts that exactly one test ran.
  /// </summary>
  [TestFixture]
  TExampleFixture2 = class
  private
    /// <summary>Number of tests run in this fixture; reset by SetupFixture.</summary>
    FTestsRun : integer;
  public
    /// <summary>
    ///   Runs once before the fixture's tests: resets the test count and logs a message.
    /// </summary>
    [SetupFixture]
    procedure SetupFixture;

    /// <summary>
    ///   Runs once after the fixture's tests: asserts exactly one test ran and logs a message.
    /// </summary>
    /// <exception cref="ETestFailure">
    ///   When the number of tests run is not 1.
    /// </exception>
    [TeardownFixture]
    procedure TearDownFixture;
  published
    /// <summary>
    ///   Published, so a test without [Test]; counts itself so TearDownFixture can check it ran once.
    /// </summary>
    procedure IAmATest;
  end;

  /// <summary>
  ///   Shows a parameterless constructor and the destructor serving as fixture setup and teardown.
  /// </summary>
  [TestFixture]
  TExampleFixture3 = class
  public
    /// <summary>
    ///   Used as the fixture's SetupFixture; empty here.
    /// </summary>
    constructor Create;
    /// <summary>
    ///   Used as the fixture's TeardownFixture; empty here.
    /// </summary>
    destructor Destroy;override;
  published
    /// <summary>
    ///   Trivially passing published test, present so the fixture is created and destroyed.
    /// </summary>
    procedure ATest;
  end;

  {$M+}
  /// <summary>
  ///   Unregistered base class whose SetupFixture/TeardownFixture methods are inherited by
  ///   <see cref="TExampleFixture5" />.
  /// </summary>
  TExampleFixture4 = class
  protected
    /// <summary>Object created by SetupFixture and freed by TearDownFixture.</summary>
    FObject: TObject;
  public
    /// <summary>
    ///   Creates <see cref="FObject" /> once before the fixture's tests.
    /// </summary>
    [SetupFixture]
    procedure SetupFixture;

    /// <summary>
    ///   Frees <see cref="FObject" /> once after the fixture's tests.
    /// </summary>
    [TeardownFixture]
    procedure TearDownFixture;
  end;

  /// <summary>
  ///   Fixture that inherits its fixture setup and teardown from <see cref="TExampleFixture4" />.
  /// </summary>
  [TestFixture]
  TExampleFixture5 = class(TExampleFixture4)
  public
    /// <summary>
    ///   Proves inherited [SetupFixture] methods run: the object the base class creates is assigned.
    /// </summary>
    [Test]
    procedure Testing;
  end;

  /// <summary>
  ///   Unregistered base class whose constructor and destructor serve as fixture setup and teardown for
  ///   <see cref="TExampleFixture7" />.
  /// </summary>
  TExampleFixture6 = class
  protected
    /// <summary>Object created by the constructor and freed by the destructor.</summary>
    FObject: TObject;
  public
    /// <summary>
    ///   Creates <see cref="FObject" />; acts as the descendant fixture's setup.
    /// </summary>
    constructor Create;
    /// <summary>
    ///   Frees <see cref="FObject" />; acts as the descendant fixture's teardown.
    /// </summary>
    destructor Destroy;override;
  end;

  /// <summary>
  ///   Fixture that inherits a constructor/destructor setup from <see cref="TExampleFixture6" />.
  /// </summary>
  TExampleFixture7 = class(TExampleFixture6)
  public
    /// <summary>
    ///   Proves an inherited constructor runs as fixture setup: the object the base class creates is assigned.
    /// </summary>
    [Test]
    procedure Testing;
  end;

  /// <summary>
  ///   A source of test cases declared outside the fixture that uses it.
  /// </summary>
  TExternalTestCaseSource = class
  public
    /// <summary>
    ///   Supplies two cases of three Integers: two operands and their sum.
    /// </summary>
    /// <returns>
    ///   One array of values per case.
    /// </returns>
    class function AddSource : TArray<TArray<integer>>; static;
  end;

  /// <summary>
  ///   Shows [TestCaseSource]: cases supplied by a class function of the fixture, or of another class, each named
  ///   from its values, as Add_Two_Integers(1, 2, 3).
  /// </summary>
  [TestFixture]
  TTestCaseSourceExampleFixture = class
  public
    /// <summary>
    ///   A source of cases: a public class function with no parameters that returns one array of values per case.
    /// </summary>
    /// <returns>
    ///   Two cases of two operands and their sum.
    /// </returns>
    class function AddSource : TArray<TArray<integer>>; static;

    /// <summary>
    ///   Runs once per case of the fixture's own AddSource; proves the sum of each case.
    /// </summary>
    /// <param name="a">
    ///   First operand.
    /// </param>
    /// <param name="b">
    ///   Second operand.
    /// </param>
    /// <param name="expected">
    ///   Their sum.
    /// </param>
    [Test]
    [TestCaseSource('AddSource')]
    procedure Add_Two_Integers(a : integer; b : integer; expected : integer);

    /// <summary>
    ///   Runs once per case of TExternalTestCaseSource.AddSource; proves the sum of each case.
    /// </summary>
    /// <param name="a">
    ///   First operand.
    /// </param>
    /// <param name="b">
    ///   Second operand.
    /// </param>
    /// <param name="expected">
    ///   Their sum.
    /// </param>
    [Test]
    [TestCaseSource(TExternalTestCaseSource, 'AddSource')]
    procedure Add_Two_Integers_externalsource(a : integer; b : integer; expected : integer);
  end;


implementation

uses
  System.SysUtils,
  System.Classes,
  DUnitX.DUnitCompatibility;

{ TMyExampleTests }

procedure TMyExampleTests.DontCallMe;
begin
  TDUnitX.CurrentRunner.Status('DontCallMe called');
  raise Exception.Create('DontCallMe was called!!!!');
end;

procedure TMyExampleTests.IgnoreMePublic;
begin
  TDUnitX.CurrentRunner.Status('IgnoreMePublic called');
  raise Exception.Create('IgnoreMePublic was called when it has IgnoreAttribute !!!!');
end;

procedure TMyExampleTests.IgnoreMePublished;
begin
  TDUnitX.CurrentRunner.Status('IgnoreMePublished called');
  raise Exception.Create('IgnoreMePublished was called when it has IgnoreAttribute !!!!');
end;

procedure TMyExampleTests.LogMessageTypes;
begin
  TDUnitX.CurrentRunner.Log(TLogLevel.Information, 'Information');
  TDUnitX.CurrentRunner.Log(TLogLevel.Warning, 'Warning');
  TDUnitX.CurrentRunner.Log(TLogLevel.Error, 'Error');
end;

procedure TMyExampleTests.Setup;
begin
  TDUnitX.CurrentRunner.Status('Setup called');
end;

procedure TMyExampleTests.TearDown;
begin
  TDUnitX.CurrentRunner.Status('TearDown called');
end;

procedure TMyExampleTests.AnotherTestMethod(const a: string; const b: integer);
begin
  TDUnitX.CurrentRunner.Status(Format('AnotherTestMethod called with %s %d',[a, b]));
end;

procedure TMyExampleTests.TestAutoName(param1, param2: integer);
begin
  TDUnitX.CurrentRunner.Status(Format('TestAutoName called with %d %d',[param1, param2]));

end;

procedure TMyExampleTests.TestCaseWithStrings(const AInput, AResult: string);
begin
  TDUnitX.CurrentRunner.Status(Format('TestCaseWithStrings called with %s %s',[AInput, AResult]));
end;

procedure TMyExampleTests.TestError;
begin
  raise Exception.Create('Error.');
end;

procedure TMyExampleTests.TestMeAnyway;
begin
  TDUnitX.CurrentRunner.Status('TestMeAnyway called');
end;

procedure TMyExampleTests.TestOne(param1 : integer; param2 : integer);
begin
  TDUnitX.CurrentRunner.Status(Format('TestOne called with %d %d',[param1, param2]));
end;

procedure TMyExampleTests.TestTwo;
var
  x : TStringList;
begin
  TDUnitX.CurrentRunner.Status('TestTwo called');
  TDUnitX.CurrentRunner.Status('hello world');
  x := TStringList.Create;
  try
    Assert.InheritsFrom(x.ClassType, TStrings); /// a bit pointless since it's strongly typed.
  finally
    x.Free;
  end;
end;

procedure TMyExampleTests.TooLong;
begin
    TThread.Sleep(5000);
end;

{ TExampleFixture2 }

procedure TExampleFixture2.IAmATest;
begin
  Inc(FTestsRun);
end;

procedure TExampleFixture2.SetupFixture;
begin
  FTestsRun := 0;
  TDUnitX.CurrentRunner.Log('Setting up...');
end;

procedure TExampleFixture2.TearDownFixture;
begin
  Assert.AreEqual(1, FTestsRun);
  TDUnitX.CurrentRunner.Log('Tearing down');
end;

{ TExampleFixture3 }

procedure TExampleFixture3.ATest;
begin
  Assert.IsTrue(true);
end;

constructor TExampleFixture3.Create;
begin
  //Empty
end;

destructor TExampleFixture3.Destroy;
begin
  //Empty
  inherited;
end;

{ TExampleFixture4 }

procedure TExampleFixture4.SetupFixture;
begin
  FObject := TObject.Create;
end;

procedure TExampleFixture4.TearDownFixture;
begin
  FObject.Free;
end;

{ TExampleFixture5 }

procedure TExampleFixture5.Testing;
begin
  Assert.IsNotNull(FObject, 'Problem with inheritance');
end;

{ TExampleFixture6 }

constructor TExampleFixture6.Create;
begin
  FObject := TObject.Create;
end;

destructor TExampleFixture6.Destroy;
begin
  FObject.Free;
  inherited;
end;

{ TExampleFixture7 }

procedure TExampleFixture7.Testing;
begin
  Assert.IsNotNull(FObject, 'Problem with inheritance');
end;

{ TTestCaseSourceExampleFixture }

class function TTestCaseSourceExampleFixture.AddSource : TArray<TArray<integer>>;
begin
  Result := TArray<TArray<Integer>>.Create(
    TArray<Integer>.Create(1, 2, 3),
    TArray<Integer>.Create(-5, -2, -7)
  );
end;

procedure TTestCaseSourceExampleFixture.Add_Two_Integers(a, b, expected : integer);
begin
  Assert.AreEqual(expected, a + b);
end;

procedure TTestCaseSourceExampleFixture.Add_Two_Integers_externalsource(a, b, expected : integer);
begin
  Assert.AreEqual(expected, a + b);
end;

{ TExternalTestCaseSource }

class function TExternalTestCaseSource.AddSource : TArray<TArray<integer>>;
begin
  Result := TArray<TArray<Integer>>.Create(
    TArray<Integer>.Create(4, 5, 9),
    TArray<Integer>.Create(-1, 1, 0)
  );
end;

initialization
//I was hoping to use RTTI to discover the TestFixture classes, however unlike .NET
//if we don't touch the class somehow then the linker will remove
//the class from the resulting exe.
//We could just do this:
//TMyExampleTests.ClassName;
//TExampleFixture2.ClassName;
//which is enough to make the compiler link the classes into the exe, but that seems a
//bit redundant so I guess we'll just use manual registration. If you use the
//{$STRONGLINKTYPES ON} compiler directive then it will link the TestFixtures in and you
//can use RTTI. The downside to that is the resulting exe will potentially much larger.
//Not sure which version {$STRONGLINKTYPES ON} was introduced so we'll allow RTTI and
//manual registration for now.

//Register the test fixtures
  TDUnitX.RegisterTestFixture(TMyExampleTests);
  TDUnitX.RegisterTestFixture(TExampleFixture2);
  TDUnitX.RegisterTestFixture(TExampleFixture3);
  TDUnitX.RegisterTestFixture(TExampleFixture5);
  TDUnitX.RegisterTestFixture(TExampleFixture7);
  TDUnitX.RegisterTestFixture(TTestCaseSourceExampleFixture);
end.
