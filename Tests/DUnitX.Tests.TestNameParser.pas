{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Originally part of DUnitX, by Vincent Parrett & Contributors    }
{           Modified (C) 2026 Ian Branch (GITLAK Software) - gllDUnitX fork }
{                                                                           }
{           Licensed under the Apache License, Version 2.0                  }
{           http://www.apache.org/licenses/LICENSE-2.0                      }
{                                                                           }
{***************************************************************************}

unit DUnitX.Tests.TestNameParser;

interface

uses
  DUnitX.TestFrameWork;

type
  /// <summary>
  ///   Tests for <c>TTestNameParser.Parse</c>, which splits the --run list of test names on commas while keeping
  ///   commas inside parentheses, quotes and generic angle brackets.
  /// </summary>
  [TestFixture]
  TTestNameParserTests = class
  public
    /// <summary>
    ///   Proves a single name - plain, padded, with a trailing comma, or carrying arguments or generic parameters that
    ///   contain commas or a quoted ')' - parses to exactly one trimmed name without the trailing separator.
    /// </summary>
    /// <param name="name">
    ///   The text handed to the parser.
    /// </param>
    [NamedTestCase('SingleName1', 'Test.Namespace.Fixture.Method', '|')]
    [NamedTestCase('SingleName2', 'Test.Namespace.Fixture.Method,', '|')]
    [NamedTestCase('SingleName3', '  Test.Namespace.Fixture.Method  ', '|')]
    [NamedTestCase('SingleName4', '  Test.Namespace.Fixture.Method  ,', '|')]
    [NamedTestCase('SingleName5', 'Test.Namespace.Fixture.Method()', '|')]
    [NamedTestCase('SingleName6', 'Test.Namespace.Fixture.Method(''string,argument'')', '|')]
    [NamedTestCase('SingleName7', 'Test.Namespace.Fixture.Method(1,2,3)', '|')]
    [NamedTestCase('SingleName8', 'Test.Namespace.Fixture.Method<int,int>()', '|')]
    [NamedTestCase('SingleName9', 'Test.Namespace.Fixture.Method(")")', '|')]
    [NamedTestCase('SingleName10', 'A', '|')]
    procedure SingleName(const name : string);

    /// <summary>
    ///   Proves two comma-joined names parse to exactly two names, even when their arguments contain commas or an
    ///   unbalanced quoted '(' or '&lt;', and that a one-character last name ('Ab,C') is not dropped.
    /// </summary>
    /// <param name="name1">
    ///   The first name; the test joins it to name2 with a comma.
    /// </param>
    /// <param name="name2">
    ///   The second name, possibly with a trailing comma.
    /// </param>
    [NamedTestCase('TwoNames1', 'Test.Namespace.Fixture.Method1|Test.Namespace.Fixture.Method2', '|')]
    [NamedTestCase('TwoNames2', 'Test.Namespace.Fixture.Method1|Test.Namespace.Fixture.Method2,', '|')]
    [NamedTestCase('TwoNames3', 'Test.Namespace.Fixture.Method1(1,2)|Test.Namespace.Fixture.Method2(3,4)', '|')]
    [NamedTestCase('TwoNames4', 'Test.Namespace.Fixture.Method1("(")|Test.Namespace.Fixture.Method2("<")', '|')]
    [NamedTestCase('TwoNames5', 'Ab|C', '|')]
    procedure TwoNames(const name1 : string; const name2 : string);
  end;

implementation

uses
  System.SysUtils,
  DUnitX.TestNameParser;

// A trailing ',' is a separator, not part of the name.
function WithoutTrailingSeparator(const name : string) : string;
begin
  Result := Trim(name);
  if (Result <> '') and (Result[Length(Result)] = ',') then
    Result := Trim(Copy(Result, 1, Length(Result) - 1));
end;

{ TTestNameParserTests }

procedure TTestNameParserTests.SingleName(const name : string);
var
  names : TArray<string>;
begin
  names := TTestNameParser.Parse(name);
  Assert.AreEqual(1, Integer(Length(names)));
  Assert.AreEqual(WithoutTrailingSeparator(name), names[0]);
end;

procedure TTestNameParserTests.TwoNames(const name1, name2 : string);
var
  names : TArray<string>;
begin
  names := TTestNameParser.Parse(name1 + ',' + name2);
  Assert.AreEqual(2, Integer(Length(names)));
  Assert.AreEqual(Trim(name1), names[0]);
  Assert.AreEqual(WithoutTrailingSeparator(name2), names[1]);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestNameParserTests);

end.

