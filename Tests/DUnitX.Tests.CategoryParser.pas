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

unit DUnitX.Tests.CategoryParser;

interface

uses
  DUnitX.TestFrameWork,
  DUnitX.Filters,
  DUnitX.CategoryExpression;

type
  /// <summary>
  ///   Tests for <c>TCategoryExpression.CreateFilter</c>, the parser behind the --include/--exclude command-line
  ///   options: each test parses an expression and walks the resulting filter tree (category, not, and, or).
  /// </summary>
  [TestFixture]
  TCategoryParseTests = class
  public
    /// <summary>
    ///   Proves an empty expression yields a non-nil filter that reports IsEmpty, so "no filter given" matches
    ///   everything rather than raising or returning nil.
    /// </summary>
    [Test]
    procedure EmptyStringReturnsEmptyFilter;

    /// <summary>
    ///   Proves a bare word parses to a single category filter holding that word.
    /// </summary>
    [Test]
    procedure CanParseSimpleCategory;

    /// <summary>
    ///   Proves comma- and semicolon-separated names (with surrounding spaces) parse into one category filter whose
    ///   categories are the trimmed names in order.
    /// </summary>
    [Test]
    procedure CanParseCompoundCategory;

    /// <summary>
    ///   Proves a leading minus negates the whole following category list: '-One,Two,Three' is a not-filter wrapping
    ///   a category filter of all three names.
    /// </summary>
    [Test]
    procedure CanParseExcludedCategories;

    /// <summary>
    ///   Proves '+' builds a single and-filter with one category filter per operand, in order, whitespace ignored.
    /// </summary>
    [Test]
    procedure CanParseMultipleCategoriesWithAnd;

    /// <summary>
    ///   Proves '|' builds a single or-filter with one category filter per alternative, in order.
    /// </summary>
    [Test]
    procedure CanParseMultipleAlternatives;

    /// <summary>
    ///   Proves '+' binds tighter than '|' and that a minus applies to the comma list after it:
    ///   'A + B | C + -D,E,F' is (A and B) or (C and not(D,E,F)).
    /// </summary>
    [Test]
    procedure PrecedenceTest;

    /// <summary>
    ///   Proves parentheses override precedence: 'A + (B | C) - D,E,F' is an and-filter of A, (B or C) and
    ///   not(D,E,F).
    /// </summary>
    [Test]
    procedure PrecedenceTestWithParentheses;

    /// <summary>
    ///   Proves a binary minus inside an alternative becomes an and-not: 'A|B-C-D|E' has three alternatives, the
    ///   middle one an and-filter of B, not C and not D.
    /// </summary>
    [Test]
    procedure OrAndMinusCombined;

    /// <summary>
    ///   Proves '+' and '-' chain into one flat and-filter of five operands, the minus operands wrapped in
    ///   not-filters.
    /// </summary>
    [Test]
    procedure PlusAndMinusCombined;

    /// <summary>
    ///   Proves an operator in the final position is tokenised: '(Slow|Integration)' must give the category
    ///   'Integration', not 'Integration)', or --exclude:(Slow|Integration) would not exclude Integration tests.
    /// </summary>
    [Test]
    procedure OperatorInLastPositionIsRecognised;

    /// <summary>
    ///   Proves an opening parenthesis with no closing one raises ECommandLineError: it used to be closed silently
    ///   at the end of the text, so a mistyped --include/--exclude ran with a filter the user did not write.
    /// </summary>
    [Test]
    procedure UnclosedParenthesisRaises;

  end;

implementation

uses
  DUnitX.Exceptions;

{ TCategoryParseTests }

procedure TCategoryParseTests.CanParseCompoundCategory;
var
  filter : ITestFilter;
  catFilter : ICategoryFilter;
begin
  filter := TCategoryExpression.CreateFilter('One , Two; Three,Four');
  catFilter := filter as ICategoryFilter;
  Assert.AreEqual('One', catFilter.Categories[0], False);
  Assert.AreEqual('Two', catFilter.Categories[1], False);
  Assert.AreEqual('Three', catFilter.Categories[2], False);
  Assert.AreEqual('Four', catFilter.Categories[3], False);
end;

procedure TCategoryParseTests.CanParseExcludedCategories;
var
  filter : ITestFilter;
  catFilter : ICategoryFilter;
  notFilter : INotFilter;
begin
  filter := TCategoryExpression.CreateFilter('-One,Two,Three');
  notFilter := filter as INotFilter;
  Assert.IsNotNull(notFilter);
  catFilter := notFilter.BaseFilter as ICategoryFilter;
  Assert.IsNotNull(catFilter);
  Assert.AreEqual('One', catFilter.Categories[0], False);
  Assert.AreEqual('Two', catFilter.Categories[1], False);
  Assert.AreEqual('Three', catFilter.Categories[2], False);
end;

procedure TCategoryParseTests.CanParseMultipleAlternatives;
var
  filter : ITestFilter;
  orFilter : IOrFilter;
  catFilter : ICategoryFilter;
begin
  filter := TCategoryExpression.CreateFilter('One|Two|Three');
  orFilter := filter as IOrFilter;
  Assert.IsNotNull(orFilter);
  Assert.AreEqual<NativeInt>(3, orFilter.Filters.Count);

  catFilter := orFilter.Filters[0] as ICategoryFilter;
  Assert.IsNotNull(catFilter);
  Assert.AreEqual('One', catFilter.Categories[0], False);

  catFilter := orFilter.Filters[1] as ICategoryFilter;
  Assert.IsNotNull(catFilter);
  Assert.AreEqual('Two', catFilter.Categories[0], False);

  catFilter := orFilter.Filters[2] as ICategoryFilter;
  Assert.IsNotNull(catFilter);
  Assert.AreEqual('Three', catFilter.Categories[0], False);
end;

procedure TCategoryParseTests.CanParseMultipleCategoriesWithAnd;
var
  filter : ITestFilter;
  catFilter : ICategoryFilter;
  andFilter : IAndFilter;
begin
  filter := TCategoryExpression.CreateFilter('One + Two+Three');
  andFilter := filter as IAndFilter;
  Assert.IsNotNull(andFilter);
  Assert.AreEqual<NativeInt>(3, andFilter.Filters.Count);
  catFilter := andFilter.Filters[0] as ICategoryFilter;
  Assert.IsNotNull(catFilter);
  Assert.AreEqual('One', catFilter.Categories[0], False);

  catFilter := andFilter.Filters[1] as ICategoryFilter;
  Assert.IsNotNull(catFilter);
  Assert.AreEqual('Two', catFilter.Categories[0], False);

  catFilter := andFilter.Filters[2] as ICategoryFilter;
  Assert.IsNotNull(catFilter);
  Assert.AreEqual('Three', catFilter.Categories[0], False);
end;

procedure TCategoryParseTests.OperatorInLastPositionIsRecognised;
var
  filter : ITestFilter;
  orFilter : IOrFilter;
  catFilter : ICategoryFilter;
begin
  filter := TCategoryExpression.CreateFilter('(Slow|Integration)');
  orFilter := filter as IOrFilter;
  Assert.IsNotNull(orFilter);
  Assert.AreEqual<NativeInt>(2, orFilter.Filters.Count);
  catFilter := orFilter.Filters[1] as ICategoryFilter;
  Assert.IsNotNull(catFilter);
  Assert.AreEqual('Integration', catFilter.Categories[0], False);
end;

procedure TCategoryParseTests.CanParseSimpleCategory;
var
  filter : ITestFilter;
  catFilter : ICategoryFilter;
begin
  filter := TCategoryExpression.CreateFilter('Data');
  catFilter := filter as ICategoryFilter;
  Assert.AreEqual('Data', catFilter.Categories[0], False);
end;

procedure TCategoryParseTests.EmptyStringReturnsEmptyFilter;
var
  filter : ITestFilter;
begin
  filter := TCategoryExpression.CreateFilter('');
  Assert.IsNotNull(filter);
  Assert.IsTrue(filter.IsEmpty);
end;

procedure TCategoryParseTests.OrAndMinusCombined;
var
  filter : ITestFilter;
  orFilter : IOrFilter;
  andFilter : IAndFilter;
begin
  filter := TCategoryExpression.CreateFilter('A|B-C-D|E');
  orFilter := filter as IOrFilter;
  Assert.IsNotNull(orFilter);
  Assert.AreEqual<NativeInt>(3, orFilter.Filters.Count);
  andFilter := orFilter.Filters[1] as IAndFilter;
  Assert.IsNotNull(andFilter);
  Assert.AreEqual<NativeInt>(3, andFilter.Filters.Count);
  Assert.Implements<ICategoryFilter>(andFilter.Filters[0]);
  Assert.Implements<INotFilter>(andFilter.Filters[1]);
  Assert.Implements<INotFilter>(andFilter.Filters[2]);
end;

procedure TCategoryParseTests.PlusAndMinusCombined;
var
  filter : ITestFilter;
  andFilter : IAndFilter;
begin
  filter := TCategoryExpression.CreateFilter('A+B-C-D+E');
  andFilter := filter as IAndFilter;
  Assert.IsNotNull(andFilter);
  Assert.AreEqual<NativeInt>(5, andFilter.Filters.Count);
  Assert.Implements<ICategoryFilter>(andFilter.Filters[0]);
  Assert.Implements<ICategoryFilter>(andFilter.Filters[1]);
  Assert.Implements<INotFilter>(andFilter.Filters[2]);
  Assert.Implements<INotFilter>(andFilter.Filters[3]);
  Assert.Implements<ICategoryFilter>(andFilter.Filters[4]);
end;

procedure TCategoryParseTests.PrecedenceTest;
var
  filter : ITestFilter;
  orFilter : IOrFilter;
  andFilter : IAndFilter;
  catFilter : ICategoryFilter;
  notFilter : INotFilter;
begin
  filter := TCategoryExpression.CreateFilter('A + B | C + -D,E,F');
  orFilter := filter as IorFilter;
  Assert.IsNotNull(orFilter);

  andFilter := orFilter.Filters[0] as IAndFilter;
  Assert.IsNotNull(andFilter);
  catFilter := andFilter.Filters[0] as ICategoryFilter;
  Assert.AreEqual('A', catFilter.Categories[0], False);
  catFilter := andFilter.Filters[1] as ICategoryFilter;
  Assert.AreEqual('B', catFilter.Categories[0], False);

  andFilter := orFilter.Filters[1] as IAndFilter;
  Assert.IsNotNull(andFilter);
  catFilter := andFilter.Filters[0] as ICategoryFilter;
  Assert.AreEqual('C', catFilter.Categories[0], False);

  notFilter := andFilter.Filters[1] as INotFilter;
  Assert.IsNotNull(notFilter);
  catFilter := notFilter.BaseFilter as ICategoryFilter;
  Assert.IsNotNull(catFilter);
  Assert.AreEqual('D', catFilter.Categories[0], False);
  Assert.AreEqual('E', catFilter.Categories[1], False);
  Assert.AreEqual('F', catFilter.Categories[2], False);
end;

procedure TCategoryParseTests.PrecedenceTestWithParentheses;
var
  filter : ITestFilter;
  orFilter : IOrFilter;
  andFilter : IAndFilter;
  catFilter : ICategoryFilter;
  notFilter : INotFilter;
begin
  filter := TCategoryExpression.CreateFilter('A + (B | C) - D,E,F');
  andFilter := filter as IAndFilter;
  Assert.IsNotNull(andFilter);
  Assert.AreEqual<NativeInt>(3, andFilter.Filters.Count);

  catFilter := andFilter.Filters[0] as ICategoryFilter;
  Assert.AreEqual('A', catFilter.Categories[0], False);

  orFilter := andFilter.Filters[1] as IOrFilter;
  Assert.IsNotNull(orFilter);
  catFilter := orFilter.Filters[0] as ICategoryFilter;
  Assert.AreEqual('B', catFilter.Categories[0], False);
  catFilter := orFilter.Filters[1] as ICategoryFilter;
  Assert.AreEqual('C', catFilter.Categories[0], False);

  notFilter := andFilter.Filters[2] as INotFilter;
  Assert.IsNotNull(notFilter);
  catFilter := notFilter.BaseFilter as ICategoryFilter;
  Assert.AreEqual('D', catFilter.Categories[0], False);
  Assert.AreEqual('E', catFilter.Categories[1], False);
  Assert.AreEqual('F', catFilter.Categories[2], False);
end;

procedure TCategoryParseTests.UnclosedParenthesisRaises;
begin
  Assert.WillRaise(
    procedure
    begin
      TCategoryExpression.CreateFilter('A + (B | C');
    end, ECommandLineError, 'An unclosed parenthesis was accepted');
end;

initialization
  TDUnitX.RegisterTestFixture(TCategoryParseTests);
end.

