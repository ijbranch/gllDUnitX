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

unit DUnitX.Filters;

interface

{$I DUnitX.inc}

uses
{$IFDEF USE_NS}
  System.Classes,
  System.Generics.Collections,
{$ELSE}
  Classes,
  Generics.Collections,
{$ENDIF}
  DUnitX.Extensibility;

type
  /// <summary>
  ///   Interface implemented by filters applied to tests (modelled on NUnit's test filters). The filter applies when
  ///   running the test, after it has been loaded, since that is the only time an ITest exists.
  /// </summary>
  ITestFilter = interface
    ['{FE8D59F6-E47A-4F05-BA15-0471BFCCA004}']
    /// <summary>
    ///   Indicates whether this is the empty filter, which matches every test.
    /// </summary>
    /// <returns>
    ///   True for a TEmptyFilter.
    /// </returns>
    function IsEmpty : boolean;
    /// <summary>
    ///   Determines whether the test itself matches the filter criteria, without examining either parents or
    ///   descendants.
    /// </summary>
    /// <param name="test">
    ///   The test to which the filter is applied.
    /// </param>
    /// <returns>
    ///   True if the test matches the filter and should run.
    /// </returns>
    function Match(const test : ITest) : boolean;
  end;

  /// <summary>
  ///   Name filter: selects tests by name (namespace, fixture, full test name or test-case method name).
  /// </summary>
  INameFilter = interface(ITestFilter)
    ['{74E76CBC-6CC3-4393-A66C-09A14974B7EB}']
    /// <summary>
    ///   Adds one name to select.
    /// </summary>
    /// <param name="name">
    ///   The name; empty names and duplicates are ignored.
    /// </param>
    procedure Add(const name : string); overload;
    /// <summary>
    ///   Adds several names to select.
    /// </summary>
    /// <param name="names">
    ///   The names, added as given.
    /// </param>
    procedure Add(const names : TArray<string>); overload;
  end;

  /// <summary>
  ///   Combines multiple filters so that a test must pass all of them in order to pass this filter.
  /// </summary>
  IAndFilter = interface(ITestFilter)
    ['{EE95054F-06DC-47F7-BB25-77F5162A26FD}']
    /// <summary>
    ///   Adds one filter the test must also pass.
    /// </summary>
    /// <param name="filter">
    ///   The filter to add.
    /// </param>
    procedure Add(const filter : ITestFilter); overload;
    /// <summary>
    ///   Adds several filters the test must also pass.
    /// </summary>
    /// <param name="filters">
    ///   The filters to add.
    /// </param>
    procedure Add(const filters : TArray<ITestFilter>); overload;
    /// <summary>
    ///   The combined filters.
    /// </summary>
    /// <returns>
    ///   The live list owned by the filter; do not free it.
    /// </returns>
    function Filters : TList<ITestFilter>;
  end;

  /// <summary>
  ///   Combines multiple filters so that a test must pass one of them in order to pass this filter.
  /// </summary>
  IOrFilter = interface(ITestFilter)
    ['{617B3F85-BF00-4F1E-9454-180618E32868}']
    /// <summary>
    ///   Adds one alternative filter.
    /// </summary>
    /// <param name="filter">
    ///   The filter to add.
    /// </param>
    procedure Add(const filter : ITestFilter); overload;
    /// <summary>
    ///   Adds several alternative filters.
    /// </summary>
    /// <param name="filters">
    ///   The filters to add.
    /// </param>
    procedure Add(const filters : TArray<ITestFilter>); overload;
    /// <summary>
    ///   The alternative filters.
    /// </summary>
    /// <returns>
    ///   The live list owned by the filter; do not free it.
    /// </returns>
    function Filters : TList<ITestFilter>;
  end;

  /// <summary>
  ///   Negates the operation of another filter.
  /// </summary>
  INotFilter = interface(ITestFilter)
    ['{4F0C6588-A98A-47C4-8CD6-2AF62BBBB7E5}']
    /// <summary>
    ///   Getter for BaseFilter.
    /// </summary>
    /// <returns>
    ///   The filter being negated.
    /// </returns>
    function GetBaseFilter : ITestFilter;
    /// <summary>
    ///   Getter for TopLevel.
    /// </summary>
    /// <returns>
    ///   True when this is the outermost filter of the run.
    /// </returns>
    function GetTopLevel : boolean;
    /// <summary>
    ///   Setter for TopLevel.
    /// </summary>
    /// <param name="value">
    ///   True to mark this as the outermost filter of the run.
    /// </param>
    procedure SetTopLevel(const value : boolean);

    /// <summary>The filter whose result is negated.</summary>
    property BaseFilter : ITestFilter read GetBaseFilter;
    /// <summary>
    ///   Marks the NOT filter as the outermost filter of the run (set by TDUnitXFilterBuilder for --exclude). Carried
    ///   over from NUnit, where it governs explicit tests; Match does not consult it.
    /// </summary>
    property TopLevel : boolean read GetTopLevel write SetTopLevel;
  end;

  /// <summary>
  ///   Category filter: selects tests that carry at least one of the listed categories.
  /// </summary>
  ICategoryFilter = interface(ITestFilter)
    ['{3D11F89D-9E39-4E03-80AB-F1AC9C6F3065}']
    /// <summary>
    ///   Adds one category.
    /// </summary>
    /// <param name="name">
    ///   The category name; empty names and duplicates are ignored.
    /// </param>
    procedure Add(const name : string); overload;
    /// <summary>
    ///   Adds several categories.
    /// </summary>
    /// <param name="names">
    ///   The category names, added as given.
    /// </param>
    procedure Add(const names : TArray<string>); overload;
    /// <summary>
    ///   The categories the filter matches.
    /// </summary>
    /// <returns>
    ///   The live list owned by the filter; do not free it.
    /// </returns>
    function Categories : TList<string>;
  end;

  /// <summary>
  ///   Abstract base class of the filter implementations.
  /// </summary>
  TTestFilter = class(TInterfacedObject, ITestFilter)
  protected
    /// <summary>
    ///   Indicates whether this is the empty filter.
    /// </summary>
    /// <returns>
    ///   True when the instance is a TEmptyFilter.
    /// </returns>
    function IsEmpty : Boolean;
    /// <summary>
    ///   Determines whether the test matches the filter; implemented by each descendant.
    /// </summary>
    /// <param name="test">
    ///   The test to which the filter is applied.
    /// </param>
    /// <returns>
    ///   True if the test matches.
    /// </returns>
    function Match(const test : ITest) : Boolean; virtual; abstract;
  end;

  /// <summary>
  ///   The filter used when nothing restricts the run: it matches every test.
  /// </summary>
  TEmptyFilter = class(TTestFilter)
  protected
    /// <summary>
    ///   Matches every test.
    /// </summary>
    /// <param name="test">
    ///   The test to which the filter is applied (ignored).
    /// </param>
    /// <returns>
    ///   Always True.
    /// </returns>
    function Match(const test : ITest) : Boolean; override;
  end;

  /// <summary>
  ///   Selects tests by name: a name selects whatever it names whole - a namespace, a fixture, a test, or a method's
  ///   test cases. Names compare case-insensitively.
  /// </summary>
  TNameFilter = class(TTestFilter, ITestFilter, INameFilter)
  private
    /// <summary>The names to select, held in a case-insensitive list.</summary>
    FNames : TList<string>;
  protected
    /// <summary>
    ///   Adds one name to select.
    /// </summary>
    /// <param name="name">
    ///   The name; empty names and duplicates are ignored.
    /// </param>
    procedure Add(const name : string); overload;
    /// <summary>
    ///   Adds several names to select, as given (no empty or duplicate check).
    /// </summary>
    /// <param name="names">
    ///   The names to add.
    /// </param>
    procedure Add(const names : TArray<string>); overload;
    /// <summary>
    ///   Adds every line of a string list as a name to select, as given (no empty or duplicate check).
    /// </summary>
    /// <param name="names">
    ///   The names to add.
    /// </param>
    procedure Add(const names : TStrings); overload;
    /// <summary>
    ///   Matches a test when a name equals its fixture's full name, prefixes its full name at a '.' boundary, equals
    ///   its full name, or (for a test case) equals its method name.
    /// </summary>
    /// <param name="test">
    ///   The test to which the filter is applied.
    /// </param>
    /// <returns>
    ///   True if any name selects the test.
    /// </returns>
    /// <remarks>
    ///   The '.' boundary means Unit.TCustomer does not also select Unit.TCustomerOrder.
    /// </remarks>
    function Match(const test : ITest) : Boolean; override;
  public
    /// <summary>
    ///   Creates a filter with no names (which matches nothing).
    /// </summary>
    constructor Create; overload;
    /// <summary>
    ///   Creates a filter selecting one name.
    /// </summary>
    /// <param name="AName">
    ///   The name to select; empty adds nothing.
    /// </param>
    constructor Create(const AName : string); overload;
    /// <summary>
    ///   Creates a filter selecting several names.
    /// </summary>
    /// <param name="ANames">
    ///   The names to select.
    /// </param>
    constructor Create(const ANames : TArray<string>); overload;
    /// <summary>
    ///   Creates a filter selecting every line of a string list.
    /// </summary>
    /// <param name="ANames">
    ///   The names to select.
    /// </param>
    constructor Create(const ANames : TStrings); overload;
    /// <summary>
    ///   Frees the name list.
    /// </summary>
    destructor Destroy; override;
  end;

  /// <summary>
  ///   Selects tests by their exact full name only. Unlike TNameFilter it does not treat a name as a fixture name
  ///   prefix, so it runs exactly the tests named (the GUI runner's checked tests).
  /// </summary>
  TFullNameFilter = class(TTestFilter, ITestFilter)
  private
    /// <summary>The full test names to run, compared case-sensitively because test case names can differ only in case.</summary>
    FNames : TDictionary<string, Boolean>;
  protected
    /// <summary>
    ///   Matches a test whose full name is one of the names, case-sensitively.
    /// </summary>
    /// <param name="test">
    ///   The test to which the filter is applied.
    /// </param>
    /// <returns>
    ///   True if the test's full name is in the set.
    /// </returns>
    function Match(const test : ITest) : Boolean; override;
  public
    /// <summary>
    ///   Creates a filter for one full test name.
    /// </summary>
    /// <param name="AName">
    ///   The full name; empty creates an empty set (which matches nothing).
    /// </param>
    constructor Create(const AName : string); overload;
    /// <summary>
    ///   Creates a filter for every non-empty line of a string list.
    /// </summary>
    /// <param name="ANames">
    ///   The full test names.
    /// </param>
    constructor Create(const ANames : TStrings); overload;
    /// <summary>
    ///   Frees the name set.
    /// </summary>
    destructor Destroy; override;
  end;

  /// <summary>
  ///   Selects tests that carry at least one of the listed categories; reuses TNameFilter's name list as the category
  ///   list.
  /// </summary>
  TCategoryFilter = class(TNameFilter, ITestFilter, ICategoryFilter)
  protected
    /// <summary>
    ///   Matches a test whose categories contain any of the filter's categories.
    /// </summary>
    /// <param name="test">
    ///   The test to which the filter is applied.
    /// </param>
    /// <returns>
    ///   True if the test has at least one listed category; False for an uncategorised test.
    /// </returns>
    function Match(const test : ITest) : Boolean; override;
    /// <summary>
    ///   The categories the filter matches.
    /// </summary>
    /// <returns>
    ///   The live list owned by the filter; do not free it.
    /// </returns>
    function Categories : TList<string>;
  end;

  /// <summary>
  ///   Matches a test only when every contained filter matches it.
  /// </summary>
  TAndFilter = class(TTestFilter, ITestFilter, IAndFilter)
  private
    /// <summary>The filters that must all match.</summary>
    FFilters : TList<ITestFilter>;
  protected
    /// <summary>
    ///   Adds one filter the test must also pass.
    /// </summary>
    /// <param name="filter">
    ///   The filter to add.
    /// </param>
    procedure Add(const filter : ITestFilter); overload;
    /// <summary>
    ///   Adds several filters the test must also pass.
    /// </summary>
    /// <param name="filters">
    ///   The filters to add.
    /// </param>
    procedure Add(const filters : TArray<ITestFilter>); overload;
    /// <summary>
    ///   Matches when every contained filter matches, stopping at the first that does not.
    /// </summary>
    /// <param name="test">
    ///   The test to which the filter is applied.
    /// </param>
    /// <returns>
    ///   True if all filters match (True when the list is empty).
    /// </returns>
    function Match(const test : ITest) : Boolean; override;
    /// <summary>
    ///   The combined filters.
    /// </summary>
    /// <returns>
    ///   The live list owned by the filter; do not free it.
    /// </returns>
    function Filters : TList<ITestFilter>;
  public
    /// <summary>
    ///   Creates an AND filter starting with one filter.
    /// </summary>
    /// <param name="filter">
    ///   The first filter.
    /// </param>
    constructor Create(const filter : ITestFilter); overload;
    /// <summary>
    ///   Creates an AND filter over several filters.
    /// </summary>
    /// <param name="filters">
    ///   The filters that must all match.
    /// </param>
    constructor Create(const filters : TArray<ITestFilter>); overload;
    /// <summary>
    ///   Frees the filter list (releasing the contained filters).
    /// </summary>
    destructor Destroy; override;
  end;

  /// <summary>
  ///   Matches a test when any contained filter matches it.
  /// </summary>
  TOrFilter = class(TTestFilter, ITestFilter, IOrFilter)
  private
    /// <summary>The alternative filters.</summary>
    FFilters : TList<ITestFilter>;
  protected
    /// <summary>
    ///   Adds one alternative filter.
    /// </summary>
    /// <param name="filter">
    ///   The filter to add.
    /// </param>
    procedure Add(const filter : ITestFilter); overload;
    /// <summary>
    ///   Adds several alternative filters.
    /// </summary>
    /// <param name="filters">
    ///   The filters to add.
    /// </param>
    procedure Add(const filters : TArray<ITestFilter>); overload;
    /// <summary>
    ///   Matches when any contained filter matches, stopping at the first that does.
    /// </summary>
    /// <param name="test">
    ///   The test to which the filter is applied.
    /// </param>
    /// <returns>
    ///   True if at least one filter matches (False when the list is empty).
    /// </returns>
    function Match(const test : ITest) : Boolean; override;
    /// <summary>
    ///   The alternative filters.
    /// </summary>
    /// <returns>
    ///   The live list owned by the filter; do not free it.
    /// </returns>
    function Filters : TList<ITestFilter>;
  public
    /// <summary>
    ///   Creates an OR filter starting with one filter.
    /// </summary>
    /// <param name="filter">
    ///   The first alternative.
    /// </param>
    constructor Create(const filter : ITestFilter); overload;
    /// <summary>
    ///   Creates an OR filter over several filters.
    /// </summary>
    /// <param name="filters">
    ///   The alternatives.
    /// </param>
    constructor Create(const filters : TArray<ITestFilter>); overload;
    /// <summary>
    ///   Frees the filter list (releasing the contained filters).
    /// </summary>
    destructor Destroy; override;
  end;

  /// <summary>
  ///   Matches a test exactly when its base filter does not.
  /// </summary>
  TNotFilter = class(TTestFilter, ITestFilter, INotFilter)
  private
    /// <summary>Backing field for TopLevel.</summary>
    FTopLevel : boolean;
    /// <summary>The filter being negated.</summary>
    FBaseFilter : ITestFilter;
  protected
    /// <summary>
    ///   Getter for BaseFilter.
    /// </summary>
    /// <returns>
    ///   The filter being negated.
    /// </returns>
    function GetBaseFilter : ITestFilter;
    /// <summary>
    ///   Getter for TopLevel.
    /// </summary>
    /// <returns>
    ///   True when this is the outermost filter of the run.
    /// </returns>
    function GetTopLevel : Boolean;
    /// <summary>
    ///   Setter for TopLevel.
    /// </summary>
    /// <param name="value">
    ///   True to mark this as the outermost filter of the run.
    /// </param>
    procedure SetTopLevel(const value : boolean);
    /// <summary>
    ///   Negates the base filter's result.
    /// </summary>
    /// <param name="test">
    ///   The test to which the filter is applied.
    /// </param>
    /// <returns>
    ///   True if the base filter does not match the test.
    /// </returns>
    function Match(const test : ITest) : Boolean; override;

  public
    /// <summary>
    ///   Creates a NOT filter that is not top level.
    /// </summary>
    /// <param name="baseFilter">
    ///   The filter to negate.
    /// </param>
    constructor Create(const baseFilter : ITestFilter); overload;
    /// <summary>
    ///   Creates a NOT filter with an explicit TopLevel value.
    /// </summary>
    /// <param name="baseFilter">
    ///   The filter to negate.
    /// </param>
    /// <param name="topLevel">
    ///   True to mark it as the outermost filter of the run.
    /// </param>
    constructor Create(const baseFilter : ITestFilter; const topLevel : boolean); overload;
  end;

implementation

uses
{$IFDEF USE_NS}
  System.Generics.Defaults,
  System.StrUtils,
  System.SysUtils;
{$ELSE}
  Generics.Defaults,
  StrUtils,
  SysUtils;
{$ENDIF}

{ TTestFilter }

function TTestFilter.IsEmpty : Boolean;
begin
  result := Self is TEmptyFilter;
end;

{ TEmptyFilter }

function TEmptyFilter.Match(const test : ITest) : Boolean;
begin
  result := True;
end;

{ TNameFilter }

procedure TNameFilter.Add(const names : TArray<string>);
var
  name : string;
begin
  //Through the single-name Add, which drops empty and duplicate names ('--run:a,,b').
  for name in names do
    Add(name);
end;

constructor TNameFilter.Create;
begin
  inherited;
  FNames := TList<string>.Create(TComparer<string>.Construct(
      function(const Left, Right : string) : integer
      begin
        result := AnsiCompareText(Left, Right);
      end));
end;

procedure TNameFilter.Add(const name : string);
begin
  if name <> '' then
  begin
    if not FNames.Contains(name) then
      FNames.Add(name);
  end;
end;

procedure TNameFilter.Add(const names : TStrings);
var
  name : string;
begin
  //Through the single-name Add, which drops empty and duplicate names.
  for name in names do
    Add(name);
end;

constructor TNameFilter.Create(const ANames : TStrings);
begin
  Create;
  Add(ANames);
end;

constructor TNameFilter.Create(const ANames : TArray<string>);
begin
  Create;
  Add(ANames);
end;

constructor TNameFilter.Create(const AName : string);
begin
  Create;
  Add(AName);
end;

destructor TNameFilter.Destroy;
begin
  FNames.Free;
  inherited;
end;

function TNameFilter.Match(const test : ITest) : Boolean;
var
  name : string;
begin
  result := false;
  //A name selects whatever it names whole: a namespace, a fixture, a test, or a method's test cases. It matches only
  //at a '.' boundary, so Unit.TCustomer does not also select Unit.TCustomerOrder.
  for name in FNames do
  begin
    result := SameText(name, test.Fixture.FullName) or StartsText(name + '.', test.FullName);
    if result then
      exit;
  end;

  if not result then
    result := FNames.IndexOf(test.FullName) <> -1;
  //hacky way to allow filtering on test cases.
  if (not result) and test.IsTestCase then
    result := FNames.IndexOf(test.MethodName) <> -1;
end;

{ TFullNameFilter }

constructor TFullNameFilter.Create(const AName : string);
begin
  inherited Create;
  //Case-sensitive: test case names can differ only in case.
  FNames := TDictionary<string, Boolean>.Create;
  if AName <> '' then
    FNames.AddOrSetValue(AName, True);
end;

constructor TFullNameFilter.Create(const ANames : TStrings);
var
  name : string;
begin
  Create('');
  for name in ANames do
    if name <> '' then
      FNames.AddOrSetValue(name, True);
end;

destructor TFullNameFilter.Destroy;
begin
  FNames.Free;
  inherited;
end;

function TFullNameFilter.Match(const test : ITest) : Boolean;
begin
  result := FNames.ContainsKey(test.FullName);
end;

{ TAndFilter }

procedure TAndFilter.Add(const filters : TArray<ITestFilter>);
begin
  FFilters.AddRange(filters);
end;

procedure TAndFilter.Add(const filter : ITestFilter);
begin
  FFilters.Add(filter);
end;

constructor TAndFilter.Create(const filters : TArray<ITestFilter>);
begin
  inherited Create;
  FFilters := TList<ITestFilter>.Create;
  Add(filters);
end;

destructor TAndFilter.Destroy;
begin
  FFilters.Free;
  inherited;
end;

function TAndFilter.Filters : TList<ITestFilter>;
begin
  result := FFilters;
end;

constructor TAndFilter.Create(const filter : ITestFilter);
begin
  inherited Create;
  FFilters := TList<ITestFilter>.Create;
  Add(filter);
end;

function TAndFilter.Match(const test : ITest) : Boolean;
var
  filter : ITestFilter;
begin
  for filter in FFilters do
  begin
    if not filter.Match(test) then
      Exit(false);
  end;
  result := true;
end;

{ TOrFilter }

procedure TOrFilter.Add(const filters : TArray<ITestFilter>);
begin
  FFilters.AddRange(filters);
end;

procedure TOrFilter.Add(const filter : ITestFilter);
begin
  FFilters.Add(filter);
end;

constructor TOrFilter.Create(const filters : TArray<ITestFilter>);
begin
  inherited Create;
  FFilters := TList<ITestFilter>.Create;
  Add(filters);
end;

destructor TOrFilter.Destroy;
begin
  FFilters.Free;
  inherited;
end;

function TOrFilter.Filters : TList<ITestFilter>;
begin
  result := FFilters;
end;

constructor TOrFilter.Create(const filter : ITestFilter);
begin
  inherited Create;
  FFilters := TList<ITestFilter>.Create;
  Add(filter);
end;

function TOrFilter.Match(const test : ITest) : Boolean;
var
  filter : ITestFilter;
begin
  result := false;
  for filter in FFilters do
  begin
    if filter.Match(test) then
      Exit(true);
  end;
end;

{ TNotFilter }

constructor TNotFilter.Create(const baseFilter : ITestFilter);
begin
  Create(baseFilter, false);
end;

constructor TNotFilter.Create(const baseFilter : ITestFilter; const topLevel : boolean);
begin
  inherited Create;
  FBaseFilter := baseFilter;
  FTopLevel := topLevel;
end;

function TNotFilter.GetBaseFilter : ITestFilter;
begin
  result := FBaseFilter;
end;

function TNotFilter.GetTopLevel : Boolean;
begin
  result := FTopLevel;
end;

function TNotFilter.Match(const test : ITest) : Boolean;
begin
  Result := not FBaseFilter.Match(test);
end;

procedure TNotFilter.SetTopLevel(const value : boolean);
begin
  FTopLevel := value;
end;

{ TCategoryFilter }

function TCategoryFilter.Categories : TList<string>;
begin
  result := FNames;
end;

function TCategoryFilter.Match(const test : ITest) : Boolean;
var
  i : integer;
begin
  result := False;
  if test.Categories.Count = 0 then
    exit;

  for i := 0 to FNames.Count - 1 do
  begin
    if test.Categories.Contains(FNames[i]) then
      exit(true);
  end;
end;

end.

