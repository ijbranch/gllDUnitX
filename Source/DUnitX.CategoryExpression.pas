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
{ This unit is largely a port of the NUnit CategoryExpression class         }
{ Copyright © 2012-2014 Charlie Poole                                       }
{ License  : http://nunit.org/index.php?p=vsTestAdapterLicense&r=2.6.3      }
{                                                                           }
{***************************************************************************}

unit DUnitX.CategoryExpression;

interface

{$I DUnitX.inc}

uses
  DUnitX.Extensibility,
  DUnitX.Filters;

type
  /// <summary>
  ///   Recursive-descent parser that turns a category expression (the --include / --exclude text) into a tree of
  ///   category, AND, OR and NOT test filters.
  /// </summary>
  /// <remarks>
  ///   Grammar as the code implements it (a port of NUnit's CategoryExpression):
  ///   <c>CategoryName ::= text not containing any of , ; - | + ( )</c>;
  ///   <c>CategoryFilter ::= CategoryName | CategoryFilter (',' | ';') CategoryName</c> (any one name matches);
  ///   <c>Primitive ::= CategoryFilter | '-' Primitive | '(' Expression ')'</c>;
  ///   <c>Term ::= Primitive | Term '+' Primitive | Term '-' Primitive</c> (AND, AND NOT);
  ///   <c>Expression ::= Term | Expression '|' Term</c> (OR).
  ///   A '(' without its ')' raises ECommandLineError (since 2026-10-13; it used to be closed silently).
  /// </remarks>
  TCategoryExpression = class
  private
    /// <summary>The expression text being parsed.</summary>
    FText : string;
    /// <summary>String index of the next unread character in FText.</summary>
    FNext : integer;
    /// <summary>The current token: an operator character, a trimmed category name, or empty at end of text.</summary>
    FToken : string;
    /// <summary>The parsed filter, cached by GetFilter so the text is parsed only once.</summary>
    FFilter : ITestFilter;
  protected
    /// <summary>
    ///   Parses a term: primitives joined by '+' (AND) or '-' (AND NOT).
    /// </summary>
    /// <returns>
    ///   The single primitive, or an AND filter over all of them.
    /// </returns>
    function GetTerm : ITestFilter;
    /// <summary>
    ///   Parses an expression: terms joined by '|' (OR).
    /// </summary>
    /// <returns>
    ///   The single term, or an OR filter over all of them.
    /// </returns>
    function GetExpression : ITestFilter;
    /// <summary>
    ///   Parses a category list: the current token plus every name following a ',' or ';'.
    /// </summary>
    /// <returns>
    ///   A category filter that matches a test carrying any of the listed categories.
    /// </returns>
    function GetCategoryFilter : ICategoryFilter;
    /// <summary>
    ///   Parses a primitive: a negated primitive ('-'), a parenthesised expression, or a category list.
    /// </summary>
    /// <returns>
    ///   The filter for the primitive.
    /// </returns>
    function GetPrimitive : ITestFilter;
    /// <summary>
    ///   Skips white space and reads the next token (a single operator character or a right-trimmed category name)
    ///   into FToken.
    /// </summary>
    /// <returns>
    ///   The new token; empty at end of text.
    /// </returns>
    function GetToken : string;
    /// <summary>
    ///   Tests whether the next unread character is one of the operator characters.
    /// </summary>
    /// <returns>
    ///   True when an operator is next; False at end of text or before a category name.
    /// </returns>
    function NextIsOperator : boolean;
    /// <summary>
    ///   Advances FNext past any white space.
    /// </summary>
    procedure SkipWhiteSpace;
    /// <summary>
    ///   Tests whether the whole text has been consumed.
    /// </summary>
    /// <returns>
    ///   True when no characters remain.
    /// </returns>
    function EndOfText : boolean;
    /// <summary>
    ///   Parses the text on first call and caches the result.
    /// </summary>
    /// <returns>
    ///   The parsed filter, or an empty filter when the text holds no tokens.
    /// </returns>
    function GetFilter : ITestFilter;
    /// <summary>
    ///   Creates a parser positioned at the start of the text (or at end of text when it is empty).
    /// </summary>
    /// <param name="text">
    ///   The category expression to parse.
    /// </param>
    constructor Create(const text : string);
  public
    /// <summary>
    ///   Parses a category expression into a test filter.
    /// </summary>
    /// <param name="text">
    ///   The category expression, for example <c>Slow,Database+-Flaky</c>.
    /// </param>
    /// <returns>
    ///   The filter the expression describes; an empty filter (which passes everything) for blank text.
    /// </returns>
    class function CreateFilter(const text : string) : ITestFilter;
  end;

implementation

uses
  DUnitX.Constants,
  DUnitX.Exceptions,
  DUnitX.ResStrs,
{$IFDEF USE_NS}
  System.Character,
  System.SysUtils,
  System.StrUtils;
{$ELSE}
  Character,
  SysUtils,
  StrUtils;
{$ENDIF}

const
  Operators         : array[1..7] of Char = (',', ';', '-', '|', '+', '(', ')');
  { TCategoryExpression }

constructor TCategoryExpression.Create(const text : string);
begin
  FText := text;
  if FText <> '' then
    FNext := MinStringOffset
  else
    FNext := MaxInt - MaxStringOffset;  //force end of text
end;

class function TCategoryExpression.CreateFilter(const text : string) : ITestFilter;
var
  expr : TCategoryExpression;
begin
  expr := TCategoryExpression.Create(text);
  try
    result := expr.GetFilter;
  finally
    expr.Free;
  end;
end;

{$IFNDEF NEXTGEN}
function IndexOfAny(const value : string; const AnyOf : array of Char; StartIndex : Integer) : Integer;
var
  i, j : Integer;
  c : Char;
  Max : Integer;
begin
  Max := Length(value);
  i := StartIndex;
  while i <= Max do
  begin
    for j := 0 to Length(AnyOf) - 1 do
    begin
      c := AnyOf[j];
      if value[i] = c then
        Exit(i);
    end;
    Inc(i);
  end;
  Result := -1;
end;
{$ENDIF}

function TCategoryExpression.GetExpression : ITestFilter;
var
  orFilter : IOrFilter;
begin
  result := GetTerm;
  if FToken <> '|' then
    exit;
  orFilter := TOrFilter.Create(result);
  while FToken = '|' do
  begin
    GetToken();
    orFilter.Add(GetTerm());
  end;
  result := orFilter;
end;

function TCategoryExpression.GetTerm : ITestFilter;
var
  filter : IAndFilter;
  prim : ITestFilter;
  tok : string;
begin
  prim := GetPrimitive;
  if (FToken <> '+') and (FToken <> '-') then
    exit(prim);

  filter := TAndFilter.Create(prim);

  while (FToken = '+') or (FToken = '-') do
  begin
    tok := FToken;
    GetToken();
    prim := GetPrimitive();
    if tok = '-' then
      filter.Add(TNotFilter.Create(prim) as ITestFilter)
    else
      filter.Add(prim);
  end;

  result := filter;
end;

function TCategoryExpression.GetPrimitive : ITestFilter;
begin
  if FToken = '-' then
  begin
    GetToken;
    result := TNotFilter.Create(GetPrimitive);
    exit;
  end
  else if FToken = '(' then
  begin
    GetToken;                           // Skip (
    result := GetExpression;
    //A '(' without its ')' is an error; it used to be closed silently at the end of the text.
    if FToken <> ')' then
      raise ECommandLineError.CreateFmt(SCategoryMissingParenthesis, [FText]);
    GetToken();                         // Skip ')'
    exit;
  end;

  result := GetCategoryFilter;
end;

function TCategoryExpression.GetCategoryFilter : ICategoryFilter;
begin
  result := TCategoryFilter.Create(FToken);
  while ((GetToken = ',') or (FToken = ';')) do
    result.Add(GetToken);
end;

function TCategoryExpression.GetToken : string;
var
  idx : integer;
begin
  SkipWhiteSpace;
{$IFDEF NEXTGEN}
  if EndOfText then
    FToken := string.Empty
  else if NextIsOperator then
  begin
    FToken := FText.Substring(FNext, 1);
    Inc(FNext);
  end
  else
  begin
    idx := FText.IndexOfAny(Operators, FNext);
    if idx < 0 then
      idx := FText.Length;

    FToken := FText.Substring(FNext, idx - FNext).TrimRight;
    FNext := idx;
  end;
{$ELSE}
  if EndOfText then
    FToken := ''
  else if NextIsOperator then
  begin
    FToken := Copy(FText, FNext, 1);
    Inc(FNext);
  end
  else
  begin
    idx := IndexOfAny(FText, Operators, FNext);
    if idx < 0 then
      idx := Length(FText) + 1;

    FToken := TrimRight(Copy(FText, FNext, idx - FNext));
    FNext := idx;
  end;
{$ENDIF}
  result := FToken;
end;

function TCategoryExpression.EndOfText : boolean;
begin
  result := FNext > Length(FText) - MaxStringOffset;
end;

procedure TCategoryExpression.SkipWhiteSpace;
begin
{$IFDEF NEXTGEN}
  while ((FNext < (FText.Length - 1)) and FText.Chars[FNext].IsWhiteSpace) do
    Inc(FNext);
{$ELSE}
  while ((FNext <= Length(Ftext)) and {$IFDEF DELPHI_XE4_UP}FText[FNext].IsWhiteSpace{$ELSE}TCharacter.IsWhiteSpace(FText[FNext]){$ENDIF}) do
    Inc(FNext);
{$ENDIF}
end;

function TCategoryExpression.NextIsOperator : boolean;
var
  op : Char;
begin
  result := false;
  if not EndOfText then
  begin
    for op in Operators do
    begin
{$IFDEF NEXTGEN}
      if FText.Chars[FNext] = op then
{$ELSE}
      if FText[FNext] = op then
{$ENDIF}
        Exit(true);
    end;
  end;
end;

function TCategoryExpression.GetFilter : ITestFilter;
begin
  if FFilter <> nil then
    exit(FFilter);

  if GetToken = '' then
    FFilter := TEmptyFilter.Create
  else
    FFilter := GetExpression;
  Result := FFilter;
end;

end.

