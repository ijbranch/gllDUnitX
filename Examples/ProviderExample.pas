unit ProviderExample;

interface
uses
  System.Generics.Collections,
  DUnitX.Types,
  DUnitX.InternalDataProvider,
  DUnitX.TestDataProvider,
  DUnitX.TestFramework;

type
  /// <summary>
  ///   One generated test case: two operands with the expected sum and equality.
  /// </summary>
  TTestData = Record
                /// <summary>First and second operands (Val2 shares this declaration).</summary>
                Val1, Val2: integer;
                /// <summary>Expected sum, Val1 + Val2.</summary>
                AddExpect : integer;
                /// <summary>Expected result of Val1 = Val2.</summary>
                isEqual   : boolean;
  End;

  /// <summary>
  ///   Example test-case provider: generates 101 random operand pairs and feeds them to Addtest and Comparetest.
  /// </summary>
  TSampleProvider = Class(TTestDataProvider)
    private
      /// <summary>The generated test cases, indexed by case number.</summary>
      flist : TList<TTestData>;
    public
      /// <summary>
      ///   Creates the provider and generates 101 random cases (operands 0..99).
      /// </summary>
      Constructor Create;override;
      /// <summary>
      ///   Gives the number of cases to run for a test method.
      /// </summary>
      /// <param name="methodName">
      ///   Name of the test method (the same count is given for every method).
      /// </param>
      /// <returns>
      ///   The number of generated cases.
      /// </returns>
      function GetCaseCount(const methodName : string) : Integer; override;
      /// <summary>
      ///   Gives the display name of a case, depending on the test method.
      /// </summary>
      /// <param name="methodName">
      ///   Name of the test method.
      /// </param>
      /// <param name="caseNumber">
      ///   Zero-based case index (unused - every case of a method shares one name).
      /// </param>
      /// <returns>
      ///   'Add integer' for Addtest, 'Compare Integer' for Comparetest, otherwise the method name.
      /// </returns>
      function GetCaseName(const methodName : string; const caseNumber : integer) : string; override;
      /// <summary>
      ///   Gives the arguments for one call of a test method, in the method's parameter order.
      /// </summary>
      /// <param name="methodName">
      ///   Name of the test method; selects the expected value passed as the third argument.
      /// </param>
      /// <param name="caseNumber">
      ///   Zero-based case index.
      /// </param>
      /// <returns>
      ///   Val1, Val2 and the expected sum (Addtest) or equality (Comparetest); an empty array when
      ///   <paramref name="caseNumber" /> is out of range.
      /// </returns>
      function GetCaseParams(const methodName : string ; const caseNumber : integer) : TValuearray; override;
      /// <summary>
      ///   Frees the generated cases.
      /// </summary>
      Destructor Destroy;override;
  End;

  /// <summary>
  ///   Example fixture whose tests take their cases from <see cref="TSampleProvider" /> rather than TestCase attributes.
  /// </summary>
  [TestFixture('ProviderExample1','Example using TestCaseProviders')]
  TProviderExample = class(TObject)
  public
    /// <summary>
    ///   Proves each provider case's expected sum equals v1 + v2, showing a provider feeding integer arguments.
    /// </summary>
    /// <param name="v1">
    ///   First operand.
    /// </param>
    /// <param name="v2">
    ///   Second operand.
    /// </param>
    /// <param name="expected">
    ///   Expected sum.
    /// </param>
    [Test]
    [TestCaseProvider(TSampleProvider)]
    Procedure Addtest(const v1, v2:integer; expected:integer);
    /// <summary>
    ///   Proves each provider case's expected equality matches v1 = v2, showing a provider feeding a Boolean argument.
    /// </summary>
    /// <param name="v1">
    ///   First operand.
    /// </param>
    /// <param name="v2">
    ///   Second operand.
    /// </param>
    /// <param name="expected">
    ///   Expected result of v1 = v2.
    /// </param>
    [Test]
    [TestCaseProvider(TSampleProvider)]
    Procedure Comparetest(const v1, v2:integer; expected:boolean);
  end;

implementation


{ TSampleProvider }

constructor TSampleProvider.Create;
var
  i : integer;
  item : TTestData;

begin
  inherited;
  flist := TList<TTestData>.create;
  //Just generate some Data for the tests
  Randomize();
  for i := 0 to 100 do
  begin
    item.Val1 := Random(100);
    item.Val2 := Random(100);
    item.AddExpect := item.Val1 + Item.Val2;
    item.isEqual := item.Val1 = item.Val2;
    flist.Add(item);
  end;
end;

destructor TSampleProvider.Destroy;
begin
  flist.Free;
  inherited;
end;

function TSampleProvider.GetCaseCount(const methodName : string) : Integer;
begin
  result := flist.Count;
end;

function TSampleProvider.GetCaseName(const methodName : string; const caseNumber : integer) : string;
begin
  result := Methodname;
  if (Methodname = 'Addtest') then
    result := 'Add integer';
  if (Methodname = 'Comparetest') then
    result := 'Compare Integer';
end;

function TSampleProvider.GetCaseParams(const methodName : string ; const caseNumber : integer) : TValuearray;
begin
  SetLength(result, 0);
  if (caseNumber >= 0) and (caseNumber < flist.Count) then
  begin
    SetLength(result, 3);
    result[0] := flist[caseNumber].Val1;
    result[1] := flist[caseNumber].Val2;
    if (Methodname = 'Addtest') then
      result[2] := flist[caseNumber].AddExpect;
    if (Methodname = 'Comparetest') then
      result[2] := flist[caseNumber].isEqual;
  end;
end;

{ TProviderExample }

procedure TProviderExample.Addtest(const v1, v2: integer; expected: integer);
begin
  Assert.AreEqual(expected,(v1 + v2),'Ok');
end;

procedure TProviderExample.Comparetest(const v1, v2: integer;
  expected: boolean);
begin
  Assert.AreEqual(expected,(v1 = v2),'Ok');
end;

initialization
  TestDataProviderManager.RegisterProvider('Demoprovider',TSampleProvider);
  TDUnitX.RegisterTestFixture(TProviderExample);
end.
