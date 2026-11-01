unit DUnitX.Tests.TestDataProvider;

interface

uses
  System.Generics.Collections,
  System.Rtti,
  DUnitX.Types,
  DUnitX.InternalDataProvider,
  DUnitX.TestDataProvider,
  DUnitX.TestFramework;

type
  /// <summary>
  ///   One row of sample data served by TSampleProvider: two operands plus the expected results of adding and of
  ///   comparing them.
  /// </summary>
  TSampleData = record
    /// <summary>The two integer operands (v1 and v2, declared together).</summary>
    v1, v2 : integer;
    /// <summary>Expected value of v1 + v2.</summary>
    AddEx : integer;
    /// <summary>Expected value of v1 = v2.</summary>
    Equal : boolean;
  end;

  /// <summary>
  ///   Test-case data provider registered as 'Sampleprovider': serves five TSampleData rows to any method naming it
  ///   in [TestCaseProvider], choosing the expected value by method name.
  /// </summary>
  TSampleProvider = class(TTestDataProvider)
  private
    /// <summary>The sample rows, owned by the provider.</summary>
    flist : TList<TSampleData>;

    /// <summary>
    ///   Fills flist with the five sample rows.
    /// </summary>
    procedure InitTestData;
  public
    /// <summary>
    ///   Creates the row list and fills it.
    /// </summary>
    constructor Create; override;
    /// <summary>
    ///   Number of cases to generate for a method.
    /// </summary>
    /// <param name="methodName">
    ///   The test method's name (ignored: every method gets every row).
    /// </param>
    /// <returns>
    ///   The number of sample rows.
    /// </returns>
    function GetCaseCount(const methodName : string) : Integer; override;
    /// <summary>
    ///   Display name for one generated case.
    /// </summary>
    /// <param name="methodName">
    ///   The test method's name.
    /// </param>
    /// <param name="caseNumber">
    ///   Zero-based case index (ignored).
    /// </param>
    /// <returns>
    ///   'Addtest' for spTstAdd, otherwise 'Comparetest'.
    /// </returns>
    function GetCaseName(const methodName : string; const caseNumber : integer) : string; override;
    /// <summary>
    ///   Argument values for one generated case.
    /// </summary>
    /// <param name="methodName">
    ///   The test method's name; spTstAdd gets AddEx as the third argument, any other method gets Equal.
    /// </param>
    /// <param name="caseNumber">
    ///   Zero-based case index.
    /// </param>
    /// <returns>
    ///   v1, v2 and the expected value; an empty array when caseNumber is out of range.
    /// </returns>
    function GetCaseParams(const methodName : string; const caseNumber : integer) : TValuearray; override;
    /// <summary>
    ///   Frees the row list.
    /// </summary>
    destructor Destroy; override;
  end;

  /// <summary>
  ///   Proves [TestCaseProvider] generates one test case per provider row, with the provider's values passed as the
  ///   method's arguments.
  /// </summary>
  [TestFixture]
  TestFixtureProviderTest = class(TObject)
  public
    /// <summary>
    ///   Proves each provider row arrives as arguments: value1 + Value2 equals the row's expected sum.
    /// </summary>
    /// <param name="value1">
    ///   First operand from the provider.
    /// </param>
    /// <param name="Value2">
    ///   Second operand from the provider.
    /// </param>
    /// <param name="expected">
    ///   Expected sum from the provider.
    /// </param>
    [Test]
    [TestCaseProvider('Sampleprovider')]
    procedure spTstAdd(const value1, Value2 : integer; expected : integer);
    /// <summary>
    ///   Proves the provider can vary the argument type by method: the third argument is a Boolean here, and
    ///   value1 = Value2 equals it.
    /// </summary>
    /// <param name="value1">
    ///   First operand from the provider.
    /// </param>
    /// <param name="Value2">
    ///   Second operand from the provider.
    /// </param>
    /// <param name="expected">
    ///   Expected equality result from the provider.
    /// </param>
    [Test]
    [TestCaseProvider('Sampleprovider')]
    procedure spTstEqual(const value1, Value2 : integer; expected : boolean);

  end;

  /// <summary>
  ///   Test-case generator that supplies one case, named TwoValues, with the values 1 and 2.
  /// </summary>
  TwoValuesSourceAttribute = class(CustomTestCaseGeneratorAttribute)
  protected
    /// <summary>
    ///   Returns the one case.
    /// </summary>
    /// <returns>
    ///   One case named TwoValues with the Integer values 1 and 2.
    /// </returns>
    function GetCaseInfoArray : TestCaseInfoArray; override;
  end;

  /// <summary>
  ///   Test-case attribute of a kind other than [TestCase] that supplies one case, named Two, with the values 1 and 2.
  /// </summary>
  TwoValuesCaseAttribute = class(CustomTestCaseAttribute)
  protected
    /// <summary>
    ///   Returns the case.
    /// </summary>
    /// <returns>
    ///   The case named Two with the Integer values 1 and 2.
    /// </returns>
    function GetCaseInfo : TestCaseInfo; override;
  end;

  /// <summary>
  ///   Not a fixture: TTestCaseAttributeTests generates its tests and runs them itself.  The first three methods take
  ///   fewer values than they are given, the last two as many.
  /// </summary>
  TMoreValuesThanParametersCases = class
  public
    /// <summary>
    ///   Given three values per case by the sample provider; each case must error.
    /// </summary>
    /// <param name="value1">
    ///   The one parameter.
    /// </param>
    [Test]
    [TestCaseProvider('Sampleprovider')]
    procedure FromProvider(const value1 : integer);
    /// <summary>
    ///   Given two values by TwoValuesSourceAttribute; the case must error.
    /// </summary>
    /// <param name="value1">
    ///   The one parameter.
    /// </param>
    [Test]
    [TwoValuesSource]
    procedure FromSource(const value1 : integer);
    /// <summary>
    ///   Given two values by TwoValuesCaseAttribute; the case must error.
    /// </summary>
    /// <param name="value1">
    ///   The one parameter.
    /// </param>
    [Test]
    [TwoValuesCase]
    procedure FromCustomCase(const value1 : integer);
    /// <summary>
    ///   Given exactly its three values by the sample provider; each case must pass.
    /// </summary>
    /// <param name="value1">
    ///   First operand.
    /// </param>
    /// <param name="value2">
    ///   Second operand.
    /// </param>
    /// <param name="expected">
    ///   Whether the operands are equal.
    /// </param>
    [Test]
    [TestCaseProvider('Sampleprovider')]
    procedure FromProviderMatching(const value1, value2 : integer; expected : boolean);
    /// <summary>
    ///   Given exactly its two values by TwoValuesSourceAttribute; the case must pass.
    /// </summary>
    /// <param name="value1">
    ///   Must be 1.
    /// </param>
    /// <param name="value2">
    ///   Must be 2.
    /// </param>
    [Test]
    [TwoValuesSource]
    procedure FromSourceMatching(const value1, value2 : integer);
  end;

  /// <summary>
  ///   Not a fixture: TTestCaseAttributeTests generates its tests and runs them itself.  Cases of [TestCase], named from
  ///   their values, and of [NamedTestCase].
  /// </summary>
  TAutoNamedCases = class
  public
    /// <summary>
    ///   Two [TestCase]s, each named from its values; both must pass.
    /// </summary>
    /// <param name="a">
    ///   First operand.
    /// </param>
    /// <param name="b">
    ///   Second operand.
    /// </param>
    /// <param name="expected">
    ///   Expected sum.
    /// </param>
    [Test]
    [TestCase('1,2,3')]
    [TestCase('-5,-2,-7')]
    procedure Add(const a, b, expected : integer);
    /// <summary>
    ///   Three [TestCase]s with the same values, which must still give three tests with different names.
    /// </summary>
    /// <param name="a">
    ///   Must be 1.
    /// </param>
    /// <param name="b">
    ///   Must be 2.
    /// </param>
    [Test]
    [TestCase('1,2')]
    [TestCase('1,2')]
    [TestCase('1,2')]
    procedure Repeated(const a, b : integer);
    /// <summary>
    ///   Two [NamedTestCase]s, one with its own separator and trimming; both must keep their names and pass.
    /// </summary>
    /// <param name="a">
    ///   First operand.
    /// </param>
    /// <param name="b">
    ///   Second operand.
    /// </param>
    /// <param name="expected">
    ///   Expected sum.
    /// </param>
    [Test]
    [NamedTestCase('First', '1,2,3')]
    [NamedTestCase('Spaced', ' 4 | 5 | 9 ', '|', true)]
    procedure NamedAdd(const a, b, expected : integer);
    /// <summary>
    ///   A [TestCase] value that is not an Integer; the case must error.
    /// </summary>
    /// <param name="value">
    ///   The one parameter.
    /// </param>
    [Test]
    [TestCase('abc')]
    procedure NotAnInteger(const value : integer);
    /// <summary>
    ///   A [TestCase] with two values for one parameter; the case must error.
    /// </summary>
    /// <param name="value">
    ///   The one parameter.
    /// </param>
    [Test]
    [TestCase('1,2')]
    procedure TooManyValues(const value : integer);
    /// <summary>
    ///   A [TestCase] with one value for two parameters; the case must error.
    /// </summary>
    /// <param name="a">
    ///   First parameter.
    /// </param>
    /// <param name="b">
    ///   Second parameter, given no value.
    /// </param>
    [Test]
    [TestCase('1')]
    procedure TooFewValues(const a, b : integer);
    /// <summary>
    ///   A [NamedTestCase] value that is not an Integer; the case must error.
    /// </summary>
    /// <param name="value">
    ///   The one parameter.
    /// </param>
    [Test]
    [NamedTestCase('Named', 'abc')]
    procedure NamedNotAnInteger(const value : integer);
    /// <summary>
    ///   A [NamedTestCase] with two values for one parameter; the case must error.
    /// </summary>
    /// <param name="value">
    ///   The one parameter.
    /// </param>
    [Test]
    [NamedTestCase('Named', '1,2')]
    procedure NamedTooManyValues(const value : integer);
    /// <summary>
    ///   A [NamedTestCase] with an empty name, as the conversion makes of an old [TestCase('', ...)]; must keep the
    ///   plain method name and pass.
    /// </summary>
    /// <param name="a">
    ///   Must be 1.
    /// </param>
    /// <param name="b">
    ///   Must be 2.
    /// </param>
    [Test]
    [NamedTestCase('', '1,2')]
    procedure EmptyName(const a, b : integer);
    /// <summary>
    ///   A [TestCase] repeated by [RepeatTest]: the repeats must share the case's name, not be numbered as duplicates.
    /// </summary>
    /// <param name="a">
    ///   Must be 1.
    /// </param>
    /// <param name="b">
    ///   Must be 2.
    /// </param>
    [Test]
    [RepeatTest(2)]
    [TestCase('1,2')]
    procedure Repeats(const a, b : integer);
  end;

  /// <summary>
  ///   Not a fixture: TTestCaseAttributeTests generates its tests and runs them itself.  [TestCase]s written for the old
  ///   TestCase, which took a name first, and [TestCase]s with ordinary separators.
  /// </summary>
  TSeparatorCheckCases = class
  public
    /// <summary>
    ///   Written for the old TestCase: now the value 'Name' split at the characters of 'Bob'.  Must error with advice.
    /// </summary>
    /// <param name="value">
    ///   Would receive 'Name'.
    /// </param>
    [Test]
    [TestCase('Name', 'Bob')]
    procedure OldOneValue(const value : string);
    /// <summary>
    ///   Written for the old TestCase: now one value for two parameters.  Must error with the advice, not the count.
    /// </summary>
    /// <param name="a">
    ///   Would receive 'Name'.
    /// </param>
    /// <param name="b">
    ///   Given no value.
    /// </param>
    [Test]
    [TestCase('Name', '1,2')]
    procedure OldTwoValues(const a, b : integer);
    /// <summary>
    ///   Separated by a semicolon; must pass.
    /// </summary>
    /// <param name="a">
    ///   First operand.
    /// </param>
    /// <param name="b">
    ///   Second operand.
    /// </param>
    [Test]
    [TestCase('1;2', ';')]
    procedure Semicolon(const a, b : integer);
    /// <summary>
    ///   Separated by a bar; must pass.
    /// </summary>
    /// <param name="a">
    ///   First operand.
    /// </param>
    /// <param name="b">
    ///   Second operand.
    /// </param>
    [Test]
    [TestCase('1|2', '|')]
    procedure Bar(const a, b : integer);
    /// <summary>
    ///   Separated by a space; must pass.
    /// </summary>
    /// <param name="a">
    ///   First operand.
    /// </param>
    /// <param name="b">
    ///   Second operand.
    /// </param>
    [Test]
    [TestCase('1 2', ' ')]
    procedure Space(const a, b : integer);
    /// <summary>
    ///   Separated by a slash; must pass.
    /// </summary>
    /// <param name="a">
    ///   First operand.
    /// </param>
    /// <param name="b">
    ///   Second operand.
    /// </param>
    [Test]
    [TestCase('1/2', '/')]
    procedure Slash(const a, b : integer);
    /// <summary>
    ///   Separated by a tab; must pass.
    /// </summary>
    /// <param name="a">
    ///   First operand.
    /// </param>
    /// <param name="b">
    ///   Second operand.
    /// </param>
    [Test]
    [TestCase('1'#9'2', #9)]
    procedure Tab(const a, b : integer);
    /// <summary>
    ///   A [NamedTestCase] separated by a letter, which it accepts; must pass.
    /// </summary>
    /// <param name="a">
    ///   First operand.
    /// </param>
    /// <param name="b">
    ///   Second operand.
    /// </param>
    [Test]
    [NamedTestCase('Letter', '1x2', 'x')]
    procedure NamedLetterSeparator(const a, b : integer);
  end;

  /// <summary>
  ///   A source of cases for a fixture other than itself.
  /// </summary>
  TExternalCaseSource = class
  public
    /// <summary>
    ///   Two rows of values of different types.
    /// </summary>
    /// <returns>
    ///   (2, 'two', True) and (3, 'three', False).
    /// </returns>
    class function Rows : TArray<TArray<TValue>>; static;
  end;

  /// <summary>
  ///   Not a fixture: TTestCaseAttributeTests generates its tests and runs them itself.  Methods fed by [TestCaseSource],
  ///   with sources that work and sources that cannot be used.
  /// </summary>
  TCaseSourceCases = class
  public
    /// <summary>
    ///   Two rows of three Integers.
    /// </summary>
    /// <returns>
    ///   (1, 2, 3) and (-5, -2, -7).
    /// </returns>
    class function Sums : TArray<TArray<Integer>>; static;
    /// <summary>
    ///   Two single values.
    /// </summary>
    /// <returns>
    ///   'alpha' and 'beta'.
    /// </returns>
    class function Words : TArray<string>; static;
    /// <summary>
    ///   No rows at all.
    /// </summary>
    /// <returns>
    ///   An empty array.
    /// </returns>
    class function NoRows : TArray<TArray<Integer>>; static;
    /// <summary>
    ///   A source that raises.
    /// </summary>
    /// <returns>
    ///   Never returns.
    /// </returns>
    /// <exception cref="EAbort">
    ///   Always, with 'no rows today'.
    /// </exception>
    class function Raises : TArray<TArray<Integer>>; static;
    /// <summary>
    ///   A source with a parameter, which cannot be used.
    /// </summary>
    /// <param name="value">
    ///   The one value of the one row.
    /// </param>
    /// <returns>
    ///   One row holding <paramref name="value" />.
    /// </returns>
    class function TakesAParameter(const value : integer) : TArray<TArray<Integer>>; static;
    /// <summary>
    ///   A source that does not return an array, which cannot be used.
    /// </summary>
    /// <returns>
    ///   1.
    /// </returns>
    class function NotAnArray : Integer; static;
    /// <summary>
    ///   One row with two values, for a method with three parameters.
    /// </summary>
    /// <returns>
    ///   (1, 2).
    /// </returns>
    class function ShortRow : TArray<TArray<Integer>>; static;
    /// <summary>
    ///   One row with four values, for a method with three parameters.
    /// </summary>
    /// <returns>
    ///   (1, 2, 3, 4).
    /// </returns>
    class function LongRow : TArray<TArray<Integer>>; static;
    /// <summary>
    ///   One row whose middle value is not an Integer.
    /// </summary>
    /// <returns>
    ///   ('1', 'x', '3').
    /// </returns>
    class function BadValue : TArray<TArray<string>>; static;
    /// <summary>
    ///   One empty row.
    /// </summary>
    /// <returns>
    ///   One row with no values.
    /// </returns>
    class function EmptyRow : TArray<TArray<string>>; static;
    /// <summary>
    ///   One row for a method whose one parameter is an array.
    /// </summary>
    /// <returns>
    ///   One row, ('a', 'b', 'c').
    /// </returns>
    class function Lists : TArray<TArray<string>>; static;
    /// <summary>
    ///   The overload with a parameter, which must not be chosen.
    /// </summary>
    /// <param name="value">
    ///   The one value.
    /// </param>
    /// <returns>
    ///   (value).
    /// </returns>
    class function Overloaded(const value : integer) : TArray<Integer>; overload; static;
    /// <summary>
    ///   The overload without parameters, which must be chosen.
    /// </summary>
    /// <returns>
    ///   (7).
    /// </returns>
    class function Overloaded : TArray<Integer>; overload; static;
    /// <summary>
    ///   An instance method, which cannot be used as a source.
    /// </summary>
    /// <returns>
    ///   One row, (1).
    /// </returns>
    function NotAClassMethod : TArray<TArray<Integer>>;
    /// <summary>
    ///   A class function that is not static, the usual form.
    /// </summary>
    /// <returns>
    ///   One row, (5).
    /// </returns>
    class function PlainSource : TArray<Integer>;

    /// <summary>
    ///   Fed by Sums; each case must pass.
    /// </summary>
    /// <param name="a">
    ///   First operand.
    /// </param>
    /// <param name="b">
    ///   Second operand.
    /// </param>
    /// <param name="expected">
    ///   Expected sum.
    /// </param>
    [Test]
    [TestCaseSource('Sums')]
    procedure Add(const a, b, expected : integer);
    /// <summary>
    ///   Fed by Words, one value per case; each case must pass.
    /// </summary>
    /// <param name="value">
    ///   A word longer than three characters.
    /// </param>
    [Test]
    [TestCaseSource('Words')]
    procedure NotEmpty(const value : string);
    /// <summary>
    ///   Fed by TExternalCaseSource.Rows; each case must pass.
    /// </summary>
    /// <param name="number">
    ///   The number.
    /// </param>
    /// <param name="name">
    ///   Its name.
    /// </param>
    /// <param name="even">
    ///   Whether it is even.
    /// </param>
    [Test]
    [TestCaseSource(TExternalCaseSource, 'Rows')]
    procedure Describe(const number : integer; const name : string; const even : boolean);
    /// <summary>
    ///   Names a source the fixture does not have; must error.
    /// </summary>
    /// <param name="value">
    ///   Never given.
    /// </param>
    [Test]
    [TestCaseSource('Missing')]
    procedure MissingSource(const value : integer);
    /// <summary>
    ///   Names a source the other class does not have; must error.
    /// </summary>
    /// <param name="value">
    ///   Never given.
    /// </param>
    [Test]
    [TestCaseSource(TExternalCaseSource, 'Missing')]
    procedure MissingExternalSource(const value : integer);
    /// <summary>
    ///   Names an instance method; must error.
    /// </summary>
    /// <param name="value">
    ///   Never given.
    /// </param>
    [Test]
    [TestCaseSource('NotAClassMethod')]
    procedure InstanceSource(const value : integer);
    /// <summary>
    ///   Names a source with a parameter; must error.
    /// </summary>
    /// <param name="value">
    ///   Never given.
    /// </param>
    [Test]
    [TestCaseSource('TakesAParameter')]
    procedure SourceWithAParameter(const value : integer);
    /// <summary>
    ///   Names a source that does not return an array; must error.
    /// </summary>
    /// <param name="value">
    ///   Never given.
    /// </param>
    [Test]
    [TestCaseSource('NotAnArray')]
    procedure SourceNotAnArray(const value : integer);
    /// <summary>
    ///   Names a source with no rows; must error rather than have no tests.
    /// </summary>
    /// <param name="value">
    ///   Never given.
    /// </param>
    [Test]
    [TestCaseSource('NoRows')]
    procedure EmptySource(const value : integer);
    /// <summary>
    ///   Names a source that raises; must error.
    /// </summary>
    /// <param name="value">
    ///   Never given.
    /// </param>
    [Test]
    [TestCaseSource('Raises')]
    procedure RaisingSource(const value : integer);
    /// <summary>
    ///   Fed a row with too few values; must error.
    /// </summary>
    /// <param name="a">
    ///   First parameter.
    /// </param>
    /// <param name="b">
    ///   Second parameter.
    /// </param>
    /// <param name="expected">
    ///   Given no value.
    /// </param>
    [Test]
    [TestCaseSource('ShortRow')]
    procedure AddShortRow(const a, b, expected : integer);
    /// <summary>
    ///   Fed a row with too many values; must error.
    /// </summary>
    /// <param name="a">
    ///   First parameter.
    /// </param>
    /// <param name="b">
    ///   Second parameter.
    /// </param>
    /// <param name="expected">
    ///   Third parameter.
    /// </param>
    [Test]
    [TestCaseSource('LongRow')]
    procedure AddLongRow(const a, b, expected : integer);
    /// <summary>
    ///   Fed a row with a value that is not an Integer; must error.
    /// </summary>
    /// <param name="a">
    ///   First parameter.
    /// </param>
    /// <param name="b">
    ///   Given 'x'.
    /// </param>
    /// <param name="expected">
    ///   Third parameter.
    /// </param>
    [Test]
    [TestCaseSource('BadValue')]
    procedure AddBadValue(const a, b, expected : integer);
    /// <summary>
    ///   Fed an empty row; must error rather than receive an empty string.
    /// </summary>
    /// <param name="value">
    ///   Never given.
    /// </param>
    [Test]
    [TestCaseSource('EmptyRow')]
    procedure OneString(const value : string);
    /// <summary>
    ///   One array parameter, fed by Lists: each row must arrive as the one array value.
    /// </summary>
    /// <param name="parts">
    ///   The row, ('a', 'b', 'c').
    /// </param>
    [Test]
    [TestCaseSource('Lists')]
    procedure OneList(const parts : TArray<string>);
    /// <summary>
    ///   Fed by the overloaded Overloaded: the overload without parameters must be used.
    /// </summary>
    /// <param name="value">
    ///   Must be 7.
    /// </param>
    [Test]
    [TestCaseSource('Overloaded')]
    procedure FromOverload(const value : integer);
    /// <summary>
    ///   Names two sources that cannot be used: each must give a test of its own.
    /// </summary>
    /// <param name="value">
    ///   Never given.
    /// </param>
    [Test]
    [TestCaseSource('Missing')]
    [TestCaseSource('NoRows')]
    procedure TwoBadSources(const value : integer);
    /// <summary>
    ///   Fed by PlainSource, a class function that is not static; must pass.
    /// </summary>
    /// <param name="value">
    ///   Must be 5.
    /// </param>
    [Test]
    [TestCaseSource('PlainSource')]
    procedure FromPlainSource(const value : integer);
  end;

  /// <summary>
  ///   Proves how upstream #533's test-case attributes generate and check cases: [TestCase] named from its values,
  ///   [NamedTestCase] keeping its name, [TestCaseSource] from a class function, the check that catches a
  ///   [TestCase] written for the old TestCase, and the value-count checks on provider and generator cases.  Each test
  ///   generates the tests of a helper class the way the runner does and runs them itself.
  /// </summary>
  [TestFixture]
  TTestCaseAttributeTests = class
  public
    /// <summary>
    ///   Proves provider, generator and custom test-case data with more values than the method has parameters errors
    ///   each case, naming the counts, instead of dropping the extra values.
    /// </summary>
    [Test]
    procedure Provider_Or_Generator_With_More_Values_Than_Parameters_Errors_The_Case;
    /// <summary>
    ///   Proves the value-count check does not touch provider and generator cases with as many values as parameters:
    ///   they still run and pass.
    /// </summary>
    [Test]
    procedure Provider_Or_Generator_With_Matching_Values_Runs;
    /// <summary>
    ///   Proves [TestCase] names each case Method(values as written) and the cases run with their values.
    /// </summary>
    [Test]
    procedure TestCase_Names_Each_Case_From_Its_Values;
    /// <summary>
    ///   Proves [TestCase]s with the same values get unique names, numbered #2, #3 in declaration order, so no two
    ///   tests share a name.
    /// </summary>
    [Test]
    procedure TestCase_Names_Stay_Unique_When_Values_Repeat;
    /// <summary>
    ///   Proves [NamedTestCase] keeps the name it is given (Method.Name), with its separator and trimming honoured.
    /// </summary>
    [Test]
    procedure NamedTestCase_Keeps_The_Name_It_Is_Given;
    /// <summary>
    ///   Proves [TestCaseSource('Method')] takes the cases from a class function of the fixture, one case per row (or
    ///   per value for a single parameter), named from the values.
    /// </summary>
    [Test]
    procedure TestCaseSource_On_The_Fixture_Supplies_The_Cases;
    /// <summary>
    ///   Proves [TestCaseSource(TClass, 'Method')] takes the cases from a class function of another class, with values
    ///   of different types.
    /// </summary>
    [Test]
    procedure TestCaseSource_On_Another_Class_Supplies_The_Cases;
    /// <summary>
    ///   Proves a source that is missing, is not a parameterless class function returning an array, raises or returns
    ///   no rows errors a test named Method.SourceName, saying why, instead of leaving the method with no tests; and
    ///   that of overloads the parameterless one is used.
    /// </summary>
    [Test]
    procedure TestCaseSource_That_Cannot_Be_Used_Errors_The_Test;
    /// <summary>
    ///   Proves rows from a source are checked as other cases are: too few, too many, an unconvertible value and an
    ///   empty row each error; a row for a single array parameter is that array.
    /// </summary>
    [Test]
    procedure TestCaseSource_Values_Are_Checked;
    /// <summary>
    ///   Proves [TestCase] and [NamedTestCase] values are still checked for conversion and count.
    /// </summary>
    [Test]
    procedure TestCase_And_NamedTestCase_Values_Are_Still_Checked;
    /// <summary>
    ///   Proves a two-argument [TestCase] written for the old TestCase, whose "separator" holds a letter or digit,
    ///   errors with advice to use [NamedTestCase], in place of running with the wrong value or a count error.
    /// </summary>
    [Test]
    procedure Old_Two_Argument_TestCase_Errors_With_Advice;
    /// <summary>
    ///   Proves ordinary separators (semicolon, bar, space, slash, tab) do not trip the old-form check, and a
    ///   [NamedTestCase] may use a letter as its separator.
    /// </summary>
    [Test]
    procedure Ordinary_Separators_Do_Not_Trip_The_Old_Form_Check;
  end;

implementation

uses
  System.SysUtils,
  DUnitX.Extensibility,
  DUnitX.InternalInterfaces,
  DUnitX.TestFixture,
  DUnitX.FixtureProvider;

type
  /// <summary>Exposes the protected GenerateTests of the fixture provider.</summary>
  TFixtureProviderAccess = class(TDUnitXFixtureProvider);

//Generates the tests of a class that is not registered as a fixture, as the runner would
function GenerateCases(const AClass : TClass) : ITestFixture;
var
  provider : TDUnitXFixtureProvider;
  providerIntf : IFixtureProvider;
begin
  Result := TDUnitXTestFixture.Create(AClass.ClassName, '', AClass, 'AUnit') as ITestFixture;
  provider := TDUnitXFixtureProvider.Create;
  providerIntf := provider;
  TFixtureProviderAccess(provider).GenerateTests(nil, Result);
end;

//The names of the tests generated for a method, in the order they were generated, separated by '|'
function TestNames(const AFixture : ITestFixture; const AMethodName : string) : string;
var
  test : ITest;
begin
  Result := '';
  for test in AFixture.Tests do
    if test.MethodName = AMethodName then
    begin
      if Result <> '' then
        Result := Result + '|';
      Result := Result + test.Name;
    end;
end;

function FindTest(const AFixture : ITestFixture; const AName : string) : ITestExecute;
var
  test : ITest;
begin
  for test in AFixture.Tests do
    if test.Name = AName then
      Exit(test as ITestExecute);
  Result := nil;
  Assert.Fail('no test named ' + AName + ' among ' + IntToStr(AFixture.Tests.Count) + ' tests');
end;

//Runs a test and returns the class and message of what it raised, or '' when it passed
function ExecuteMessage(const AFixture : ITestFixture; const AName : string) : string;
var
  testExecute : ITestExecute;
begin
  testExecute := FindTest(AFixture, AName);
  Result := '';
  try
    testExecute.Execute(nil);
  except
    on E : Exception do
      Result := E.ClassName + ': ' + E.Message;
  end;
end;

procedure CheckRuns(const AFixture : ITestFixture; const AName : string);
begin
  Assert.AreEqual('', ExecuteMessage(AFixture, AName), AName + ' runs and passes with its values');
end;

procedure CheckErrors(const AFixture : ITestFixture; const AName, AMessagePart : string);
var
  msg : string;
begin
  msg := ExecuteMessage(AFixture, AName);
  Assert.IsTrue(msg <> '', AName + ' errors');
  Assert.Contains(msg, AMessagePart, False, AName + ' message');
end;

{ TSampleProvider }

constructor TSampleProvider.Create;
begin
  inherited;
  flist := TList<TSampleData>.create;
  InitTestData;
end;

destructor TSampleProvider.Destroy;
begin
  flist.free;
  inherited;
end;

function TSampleProvider.GetCaseCount(const methodName : string) : Integer;
begin
  result := flist.count;
end;

function TSampleProvider.GetCaseName(const methodName : string; const caseNumber : integer) : string;
begin
  result := '';
  if (Methodname = 'spTstAdd') then
    result := 'Addtest'
  else
    result := 'Comparetest';

end;

function TSampleProvider.GetCaseParams(const methodName : string; const caseNumber : integer) : TValuearray;
begin
  SetLength(result, 0);
  if (caseNumber >= 0) and (caseNumber < flist.count) then
  begin
    SetLength(result, 3);
    result[0] := flist[caseNumber].v1;
    result[1] := flist[caseNumber].v2;
    if (Methodname = 'spTstAdd') then
      result[2] := flist[caseNumber].AddEx
    else
      result[2] := flist[caseNumber].Equal;
  end;
end;

procedure TSampleProvider.InitTestData;
var
  item : TSampleData;

begin
  item.v1 := 1;
  item.v2 := 1;
  item.AddEx := 2;
  item.Equal := true;
  flist.add(item);
  item.v1 := 1;
  item.v2 := 2;
  item.AddEx := 3;
  item.Equal := false;
  flist.add(item);
  item.v1 := 2;
  item.v2 := 3;
  item.AddEx := 5;
  item.Equal := false;
  flist.add(item);
  item.v1 := 2;
  item.v2 := 2;
  item.AddEx := 4;
  item.Equal := true;
  flist.add(item);
  item.v1 := 3;
  item.v2 := 3;
  item.AddEx := 6;
  item.Equal := true;
  flist.add(item);
end;

{ TestFixtureProviderTest }

procedure TestFixtureProviderTest.spTstAdd(const value1, Value2 : integer;
  expected : integer);
begin
  Assert.AreEqual(expected, (value1 + value2), 'Ok');
end;

procedure TestFixtureProviderTest.spTstEqual(const value1, Value2 : integer;
  expected : boolean);
begin
  Assert.AreEqual(expected, (value1 = value2), 'Ok');
end;

{ TwoValuesSourceAttribute }

function TwoValuesSourceAttribute.GetCaseInfoArray : TestCaseInfoArray;
begin
  SetLength(Result, 1);
  Result[0].Name := 'TwoValues';
  SetLength(Result[0].Values, 2);
  Result[0].Values[0] := 1;
  Result[0].Values[1] := 2;
end;

{ TwoValuesCaseAttribute }

function TwoValuesCaseAttribute.GetCaseInfo : TestCaseInfo;
begin
  Result.Name := 'Two';
  SetLength(Result.Values, 2);
  Result.Values[0] := 1;
  Result.Values[1] := 2;
end;

{ TMoreValuesThanParametersCases }

procedure TMoreValuesThanParametersCases.FromProvider(const value1 : integer);
begin
  Assert.Pass('must not run: the case has more values than parameters');
end;

procedure TMoreValuesThanParametersCases.FromSource(const value1 : integer);
begin
  Assert.Pass('must not run: the case has more values than parameters');
end;

procedure TMoreValuesThanParametersCases.FromCustomCase(const value1 : integer);
begin
  Assert.Pass('must not run: the case has more values than parameters');
end;

procedure TMoreValuesThanParametersCases.FromProviderMatching(const value1, value2 : integer; expected : boolean);
begin
  Assert.AreEqual(value1 = value2, expected, 'the values of the case');
end;

procedure TMoreValuesThanParametersCases.FromSourceMatching(const value1, value2 : integer);
begin
  Assert.AreEqual(1, value1, 'the first value of the case');
  Assert.AreEqual(2, value2, 'the second value of the case');
end;

{ TAutoNamedCases }

procedure TAutoNamedCases.Add(const a, b, expected : integer);
begin
  Assert.AreEqual(expected, a + b);
end;

procedure TAutoNamedCases.Repeated(const a, b : integer);
begin
  Assert.AreEqual(1, a);
  Assert.AreEqual(2, b);
end;

procedure TAutoNamedCases.NamedAdd(const a, b, expected : integer);
begin
  Assert.AreEqual(expected, a + b);
end;

procedure TAutoNamedCases.NotAnInteger(const value : integer);
begin
end;

procedure TAutoNamedCases.TooManyValues(const value : integer);
begin
end;

procedure TAutoNamedCases.TooFewValues(const a, b : integer);
begin
end;

procedure TAutoNamedCases.NamedNotAnInteger(const value : integer);
begin
end;

procedure TAutoNamedCases.NamedTooManyValues(const value : integer);
begin
end;

procedure TAutoNamedCases.EmptyName(const a, b : integer);
begin
  Assert.AreEqual(1, a);
  Assert.AreEqual(2, b);
end;

procedure TAutoNamedCases.Repeats(const a, b : integer);
begin
  Assert.AreEqual(1, a);
  Assert.AreEqual(2, b);
end;

{ TSeparatorCheckCases }

procedure TSeparatorCheckCases.OldOneValue(const value : string);
begin
end;

procedure TSeparatorCheckCases.OldTwoValues(const a, b : integer);
begin
end;

procedure TSeparatorCheckCases.Semicolon(const a, b : integer);
begin
  Assert.AreEqual(3, a + b);
end;

procedure TSeparatorCheckCases.Bar(const a, b : integer);
begin
  Assert.AreEqual(3, a + b);
end;

procedure TSeparatorCheckCases.Space(const a, b : integer);
begin
  Assert.AreEqual(3, a + b);
end;

procedure TSeparatorCheckCases.Slash(const a, b : integer);
begin
  Assert.AreEqual(3, a + b);
end;

procedure TSeparatorCheckCases.Tab(const a, b : integer);
begin
  Assert.AreEqual(3, a + b);
end;

procedure TSeparatorCheckCases.NamedLetterSeparator(const a, b : integer);
begin
  Assert.AreEqual(3, a + b);
end;

{ TExternalCaseSource }

class function TExternalCaseSource.Rows : TArray<TArray<TValue>>;
begin
  Result := TArray<TArray<TValue>>.Create(
    TArray<TValue>.Create(2, 'two', True),
    TArray<TValue>.Create(3, 'three', False));
end;

{ TCaseSourceCases }

class function TCaseSourceCases.Sums : TArray<TArray<Integer>>;
begin
  Result := TArray<TArray<Integer>>.Create(
    TArray<Integer>.Create(1, 2, 3),
    TArray<Integer>.Create(-5, -2, -7));
end;

class function TCaseSourceCases.Words : TArray<string>;
begin
  Result := TArray<string>.Create('alpha', 'beta');
end;

class function TCaseSourceCases.NoRows : TArray<TArray<Integer>>;
begin
  Result := nil;
end;

class function TCaseSourceCases.Raises : TArray<TArray<Integer>>;
begin
  raise EAbort.Create('no rows today');
end;

class function TCaseSourceCases.TakesAParameter(const value : integer) : TArray<TArray<Integer>>;
begin
  Result := TArray<TArray<Integer>>.Create(TArray<Integer>.Create(value));
end;

class function TCaseSourceCases.NotAnArray : Integer;
begin
  Result := 1;
end;

class function TCaseSourceCases.ShortRow : TArray<TArray<Integer>>;
begin
  Result := TArray<TArray<Integer>>.Create(TArray<Integer>.Create(1, 2));
end;

class function TCaseSourceCases.LongRow : TArray<TArray<Integer>>;
begin
  Result := TArray<TArray<Integer>>.Create(TArray<Integer>.Create(1, 2, 3, 4));
end;

class function TCaseSourceCases.BadValue : TArray<TArray<string>>;
begin
  Result := TArray<TArray<string>>.Create(TArray<string>.Create('1', 'x', '3'));
end;

class function TCaseSourceCases.EmptyRow : TArray<TArray<string>>;
begin
  Result := TArray<TArray<string>>.Create(nil);
end;

class function TCaseSourceCases.Lists : TArray<TArray<string>>;
begin
  Result := TArray<TArray<string>>.Create(TArray<string>.Create('a', 'b', 'c'));
end;

class function TCaseSourceCases.Overloaded(const value : integer) : TArray<Integer>;
begin
  Result := TArray<Integer>.Create(value);
end;

class function TCaseSourceCases.Overloaded : TArray<Integer>;
begin
  Result := TArray<Integer>.Create(7);
end;

function TCaseSourceCases.NotAClassMethod : TArray<TArray<Integer>>;
begin
  Result := TArray<TArray<Integer>>.Create(TArray<Integer>.Create(1));
end;

procedure TCaseSourceCases.Add(const a, b, expected : integer);
begin
  Assert.AreEqual(expected, a + b);
end;

procedure TCaseSourceCases.NotEmpty(const value : string);
begin
  Assert.IsTrue(Length(value) > 3, value);
end;

procedure TCaseSourceCases.Describe(const number : integer; const name : string; const even : boolean);
begin
  Assert.AreEqual(not Odd(number), even, name);
  Assert.IsTrue(name <> '', 'a name');
end;

procedure TCaseSourceCases.MissingSource(const value : integer);
begin
end;

procedure TCaseSourceCases.MissingExternalSource(const value : integer);
begin
end;

procedure TCaseSourceCases.InstanceSource(const value : integer);
begin
end;

procedure TCaseSourceCases.SourceWithAParameter(const value : integer);
begin
end;

procedure TCaseSourceCases.SourceNotAnArray(const value : integer);
begin
end;

procedure TCaseSourceCases.EmptySource(const value : integer);
begin
end;

procedure TCaseSourceCases.RaisingSource(const value : integer);
begin
end;

procedure TCaseSourceCases.AddShortRow(const a, b, expected : integer);
begin
end;

procedure TCaseSourceCases.AddLongRow(const a, b, expected : integer);
begin
end;

procedure TCaseSourceCases.AddBadValue(const a, b, expected : integer);
begin
end;

procedure TCaseSourceCases.OneString(const value : string);
begin
end;

procedure TCaseSourceCases.OneList(const parts : TArray<string>);
begin
  Assert.AreEqual(3, Length(parts), 'the row is the one array value');
end;

procedure TCaseSourceCases.FromOverload(const value : integer);
begin
  Assert.AreEqual(7, value);
end;

procedure TCaseSourceCases.TwoBadSources(const value : integer);
begin
end;

class function TCaseSourceCases.PlainSource : TArray<Integer>;
begin
  Result := TArray<Integer>.Create(5);
end;

procedure TCaseSourceCases.FromPlainSource(const value : integer);
begin
  Assert.AreEqual(5, value);
end;

{ TTestCaseAttributeTests }

procedure TTestCaseAttributeTests.Provider_Or_Generator_With_More_Values_Than_Parameters_Errors_The_Case;
var
  fixture : ITestFixture;
begin
  fixture := GenerateCases(TMoreValuesThanParametersCases);
  Assert.AreEqual(5, Length(TestNames(fixture, 'FromProvider').Split(['|'])), 'one test per provider case');
  CheckErrors(fixture, 'FromProvider.Comparetest (00)', 'supplies 3 value(s) but the method has 1 parameter(s)');
  CheckErrors(fixture, 'FromProvider.Comparetest (04)', 'supplies 3 value(s) but the method has 1 parameter(s)');
  CheckErrors(fixture, 'FromSource.TwoValues', 'supplies 2 value(s) but the method has 1 parameter(s)');
  //A test case attribute of another kind is checked as a generator is
  CheckErrors(fixture, 'FromCustomCase.Two', 'supplies 2 value(s) but the method has 1 parameter(s)');
end;

procedure TTestCaseAttributeTests.Provider_Or_Generator_With_Matching_Values_Runs;
var
  fixture : ITestFixture;
begin
  fixture := GenerateCases(TMoreValuesThanParametersCases);
  CheckRuns(fixture, 'FromProviderMatching.Comparetest (00)');
  CheckRuns(fixture, 'FromProviderMatching.Comparetest (04)');
  CheckRuns(fixture, 'FromSourceMatching.TwoValues');
end;

procedure TTestCaseAttributeTests.TestCase_Names_Each_Case_From_Its_Values;
var
  fixture : ITestFixture;
begin
  fixture := GenerateCases(TAutoNamedCases);
  Assert.AreEqual('Add(1,2,3)|Add(-5,-2,-7)', TestNames(fixture, 'Add'), False);
  CheckRuns(fixture, 'Add(1,2,3)');
  CheckRuns(fixture, 'Add(-5,-2,-7)');
end;

procedure TTestCaseAttributeTests.TestCase_Names_Stay_Unique_When_Values_Repeat;
var
  fixture : ITestFixture;
begin
  fixture := GenerateCases(TAutoNamedCases);
  Assert.AreEqual('Repeated(1,2)|Repeated(1,2) #2|Repeated(1,2) #3', TestNames(fixture, 'Repeated'), False);
  //Repeats of one case are not duplicates
  Assert.AreEqual('Repeats-1-of-2(1,2)|Repeats-2-of-2(1,2)', TestNames(fixture, 'Repeats'), False);
  CheckRuns(fixture, 'Repeated(1,2) #3');
end;

procedure TTestCaseAttributeTests.NamedTestCase_Keeps_The_Name_It_Is_Given;
var
  fixture : ITestFixture;
begin
  fixture := GenerateCases(TAutoNamedCases);
  Assert.AreEqual('NamedAdd.First|NamedAdd.Spaced', TestNames(fixture, 'NamedAdd'), False);
  CheckRuns(fixture, 'NamedAdd.First');
  CheckRuns(fixture, 'NamedAdd.Spaced');
  //An empty name keeps the plain method name, as the old [TestCase('', ...)] did
  Assert.AreEqual('EmptyName', TestNames(fixture, 'EmptyName'), False);
  CheckRuns(fixture, 'EmptyName');
end;

procedure TTestCaseAttributeTests.TestCaseSource_On_The_Fixture_Supplies_The_Cases;
var
  fixture : ITestFixture;
begin
  fixture := GenerateCases(TCaseSourceCases);
  Assert.AreEqual('Add(1, 2, 3)|Add(-5, -2, -7)', TestNames(fixture, 'Add'), False);
  CheckRuns(fixture, 'Add(1, 2, 3)');
  CheckRuns(fixture, 'Add(-5, -2, -7)');
  //A source of single values gives one value to each case
  Assert.AreEqual('NotEmpty(alpha)|NotEmpty(beta)', TestNames(fixture, 'NotEmpty'), False);
  CheckRuns(fixture, 'NotEmpty(alpha)');
  CheckRuns(fixture, 'NotEmpty(beta)');
end;

procedure TTestCaseAttributeTests.TestCaseSource_On_Another_Class_Supplies_The_Cases;
var
  fixture : ITestFixture;
begin
  fixture := GenerateCases(TCaseSourceCases);
  Assert.AreEqual('Describe(2, two, True)|Describe(3, three, False)', TestNames(fixture, 'Describe'), False);
  CheckRuns(fixture, 'Describe(2, two, True)');
  CheckRuns(fixture, 'Describe(3, three, False)');
end;

procedure TTestCaseAttributeTests.TestCaseSource_That_Cannot_Be_Used_Errors_The_Test;
const
  SIGNATURE = ' must be a class function with no parameters that returns an array';
var
  fixture : ITestFixture;
begin
  fixture := GenerateCases(TCaseSourceCases);
  CheckErrors(fixture, 'MissingSource.Missing', 'TestCaseSource method ''Missing'' not found on TCaseSourceCases (it must be public)');
  CheckErrors(fixture, 'MissingExternalSource.Missing', 'TestCaseSource method ''Missing'' not found on TExternalCaseSource (it must be public)');
  CheckErrors(fixture, 'InstanceSource.NotAClassMethod', 'TestCaseSource method TCaseSourceCases.NotAClassMethod' + SIGNATURE);
  CheckErrors(fixture, 'SourceWithAParameter.TakesAParameter', 'TestCaseSource method TCaseSourceCases.TakesAParameter' + SIGNATURE);
  CheckErrors(fixture, 'SourceNotAnArray.NotAnArray', 'TestCaseSource method TCaseSourceCases.NotAnArray' + SIGNATURE);
  CheckErrors(fixture, 'EmptySource.NoRows', 'TestCaseSource method TCaseSourceCases.NoRows returned no cases');
  CheckErrors(fixture, 'RaisingSource.Raises', 'TestCaseSource method TCaseSourceCases.Raises raised EAbort: no rows today');
  //Each source that cannot be used has a test of its own
  Assert.AreEqual('TwoBadSources.Missing|TwoBadSources.NoRows', TestNames(fixture, 'TwoBadSources'), False);
  //Of overloads, the one without parameters is the source
  Assert.AreEqual('FromOverload(7)', TestNames(fixture, 'FromOverload'), False);
  CheckRuns(fixture, 'FromOverload(7)');
  //A class function need not be static
  Assert.AreEqual('FromPlainSource(5)', TestNames(fixture, 'FromPlainSource'), False);
  CheckRuns(fixture, 'FromPlainSource(5)');
end;

procedure TTestCaseAttributeTests.TestCaseSource_Values_Are_Checked;
var
  fixture : ITestFixture;
  oneList : string;
begin
  fixture := GenerateCases(TCaseSourceCases);
  CheckErrors(fixture, 'AddShortRow(1, 2)', 'supplies 2 value(s) but the method has 3 parameter(s)');
  CheckErrors(fixture, 'AddLongRow(1, 2, 3, 4)', 'supplies 4 value(s) but the method has 3 parameter(s)');
  CheckErrors(fixture, 'AddBadValue(1, x, 3)', 'value [x] cannot be converted to parameter [b] of type Integer');
  //An empty row is not one empty string
  CheckErrors(fixture, 'OneString()', 'supplies 0 value(s) but the method has 1 parameter(s)');
  //For a method whose one parameter is an array, each row is that array
  oneList := TestNames(fixture, 'OneList');
  Assert.IsTrue(oneList <> '', 'a case for OneList');
  Assert.AreEqual(0, Pos('|', oneList), 'one case: ' + oneList);
  CheckRuns(fixture, oneList);
end;

procedure TTestCaseAttributeTests.TestCase_And_NamedTestCase_Values_Are_Still_Checked;
var
  fixture : ITestFixture;
begin
  fixture := GenerateCases(TAutoNamedCases);
  CheckErrors(fixture, 'NotAnInteger(abc)', 'value [abc] cannot be converted to parameter [value] of type Integer');
  CheckErrors(fixture, 'TooManyValues(1,2)', 'supplies 2 value(s) but the method has 1 parameter(s)');
  CheckErrors(fixture, 'TooFewValues(1)', 'supplies 1 value(s) but the method has 2 parameter(s)');
  CheckErrors(fixture, 'NamedNotAnInteger.Named', 'value [abc] cannot be converted to parameter [value] of type Integer');
  CheckErrors(fixture, 'NamedTooManyValues.Named', 'supplies 2 value(s) but the method has 1 parameter(s)');
end;

procedure TTestCaseAttributeTests.Old_Two_Argument_TestCase_Errors_With_Advice;
var
  fixture : ITestFixture;
begin
  fixture := GenerateCases(TSeparatorCheckCases);
  //Without the check this case would run, and pass, with the value 'Name' in place of 'Bob'
  CheckErrors(fixture, 'OldOneValue(Name)', 'TestCase separator ''Bob'' contains a letter or digit: this looks like ' +
    '[TestCase(''Name'', ''Bob'')] written for the old TestCase, which is now [NamedTestCase(''Name'', ''Bob'')]');
  //The check is reported in place of the value count
  CheckErrors(fixture, 'OldTwoValues(Name)', 'TestCase separator ''1,2'' contains a letter or digit: this looks like ' +
    '[TestCase(''Name'', ''1,2'')] written for the old TestCase, which is now [NamedTestCase(''Name'', ''1,2'')]');
end;

procedure TTestCaseAttributeTests.Ordinary_Separators_Do_Not_Trip_The_Old_Form_Check;
var
  fixture : ITestFixture;
begin
  fixture := GenerateCases(TSeparatorCheckCases);
  CheckRuns(fixture, 'Semicolon(1;2)');
  CheckRuns(fixture, 'Bar(1|2)');
  CheckRuns(fixture, 'Space(1 2)');
  CheckRuns(fixture, 'Slash(1/2)');
  CheckRuns(fixture, 'Tab(1'#9'2)');
  CheckRuns(fixture, 'NamedLetterSeparator.Letter');
end;

initialization
  TestDataProviderManager.RegisterProvider('Sampleprovider', TSampleProvider);
  TDUnitX.RegisterTestFixture(TestFixtureProviderTest);
  TDUnitX.RegisterTestFixture(TTestCaseAttributeTests);
end.

