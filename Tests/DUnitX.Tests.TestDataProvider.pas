unit DUnitX.Tests.TestDataProvider;

interface

uses
  System.Generics.Collections,
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

implementation

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

initialization
  TestDataProviderManager.RegisterProvider('Sampleprovider', TSampleProvider);
  TDUnitX.RegisterTestFixture(TestFixtureProviderTest);
end.

