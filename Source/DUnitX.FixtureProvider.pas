{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2017 Vincent Parrett & Contributors               }
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

unit DUnitX.FixtureProvider;

interface

{$I DUnitX.inc}

uses
{$IFDEF USE_NS}
  System.Rtti,
  System.Generics.Collections,
{$ELSE}
  Rtti,
  Generics.Collections,
{$ENDIF}
  DUnitX.Extensibility,
  DUnitX.Types,
  DUnitX.TestDataProvider;

type
  /// <summary>
  ///   Default fixture provider: gathers fixture classes (registered ones plus, optionally, every [TestFixture] class
  ///   found through RTTI), arranges them in a namespace hierarchy built from their unit names, and generates their
  ///   tests, test cases and setup / teardown bindings from method attributes.
  /// </summary>
  TDUnitXFixtureProvider = class(TInterfacedObject, IFixtureProvider)
  private class var
      /// <summary>Shared RTTI context, kept for the life of the process so RTTI objects stay valid.</summary>
      FRttiContext : TRttiContext;
  private
    /// <summary>The fixture classes to build, mapped to their fixture names.</summary>
    FFixtureClasses : TDictionary<TClass, string>;

  protected
    /// <summary>
    ///   Builds the display name of one repetition of a [RepeatTest] test.
    /// </summary>
    /// <param name="AName">
    ///   The test method name.
    /// </param>
    /// <param name="ATimes">
    ///   The 1-based repetition number.
    /// </param>
    /// <param name="ACount">
    ///   The total number of repetitions.
    /// </param>
    /// <returns>
    ///   AName unchanged when ACount is 1 or less; otherwise AName suffixed with <c>-ATimes-of-ACount</c>.
    /// </returns>
    function FormatTestName(const AName : string; const ATimes, ACount : Integer) : string;
    /// <summary>
    ///   Builds the name of a test case produced by a test data provider.
    /// </summary>
    /// <param name="AName">
    ///   The case name the provider returned.
    /// </param>
    /// <param name="Nr">
    ///   The 0-based case index.
    /// </param>
    /// <returns>
    ///   <c>AName (NN)</c>, with the index zero-padded to at least two digits.
    /// </returns>
    function FormatCaseName(const AName : string; Nr : integer) : string;
    /// <summary>
    ///   Finds the first attribute in a list that is of, or descends from, class T.
    /// </summary>
    /// <param name="attributes">
    ///   The attributes to search.
    /// </param>
    /// <param name="attribute">
    ///   Receives the attribute found, or nil.
    /// </param>
    /// <returns>
    ///   True when a matching attribute was found.
    /// </returns>
    function TryGetAttributeOfType<T : class>(const attributes : TArray<TCustomAttribute>; var attribute : T) : boolean;
    /// <summary>
    ///   Adds every class carrying a [TestFixture] attribute to the fixture classes, named by the attribute or, when it
    ///   gives no name, by the class name. TPersistent and TComponent descendants are included.
    /// </summary>
    procedure RTTIDiscoverFixtureClasses;
    /// <summary>
    ///   Recursively generates the tests of a fixture and its children from the fixture class's method attributes:
    ///   [SetupFixture], [TearDownFixture] (or the destructor), [Setup], [TearDown], [Test], [TestCase], test case
    ///   sources, [TestCaseProvider], [Ignore], [Category], [RepeatTest], [MaxTime], [WillRaise] and un-attributed
    ///   published methods.
    /// </summary>
    /// <param name="context">
    ///   The provider context the fixtures were created through.
    /// </param>
    /// <param name="fixture">
    ///   The fixture to populate; namespace fixtures (TestClass = TObject) only recurse into their children.
    /// </param>
    /// <remarks>
    ///   An override is bound to the fixture class's own implementation and takes the attributes of the nearest
    ///   declaration that has any, so an overridden test is one test. A [TestCaseProvider] naming an unregistered
    ///   provider produces an error test rather than silently producing none.
    /// </remarks>
    procedure GenerateTests(const context : IFixtureProviderContext; const fixture : ITestFixture);
    /// <summary>
    ///   Collects the fixture classes, builds the namespace fixture hierarchy from their unit names (and any dotted
    ///   prefix in a fixture name) through the context, then generates every fixture's tests.
    /// </summary>
    /// <param name="context">
    ///   The builder context that creates top-level fixtures and says whether RTTI discovery is wanted.
    /// </param>
    procedure Execute(const context : IFixtureProviderContext);
  public
    /// <summary>
    ///   Creates the shared RTTI context when the unit initialises.
    /// </summary>
    class constructor Create;
    /// <summary>
    ///   Frees the shared RTTI context when the unit finalises.
    /// </summary>
    class destructor Destroy;
    /// <summary>
    ///   Creates the provider with an empty fixture class map.
    /// </summary>
    constructor Create;
    /// <summary>
    ///   Frees the fixture class map.
    /// </summary>
    destructor Destroy; override;
  end;

implementation

uses
{$IFDEF USE_NS}
  System.TypInfo,
  System.Classes,
  System.Types,
  System.StrUtils,
  System.SysUtils,
{$ELSE}
  TypInfo,
  Classes,
  Types,
  StrUtils,
  SysUtils,
{$ENDIF}
  DUnitX.Attributes,
  DUnitX.Utils,
  DUnitX.TestFramework,
  DUnitX.ResStrs,
  DUnitX.InternalInterfaces,
  DUnitX.InternalDataProvider,
  DUnitX.ServiceLocator,
  DUnitX.Test;

{ TDUnitXFixtureProvider }

constructor TDUnitXFixtureProvider.Create;
begin
  FFixtureClasses := TDictionary<TClass, string>.Create;
end;

class constructor TDUnitXFixtureProvider.Create;
begin
  FRttiContext := TRttiContext.Create;
end;

destructor TDUnitXFixtureProvider.Destroy;
begin
  FFixtureClasses.Free;
  inherited;
end;

class destructor TDUnitXFixtureProvider.Destroy;
begin
  FRttiContext.Free;
end;

procedure TDUnitXFixtureProvider.Execute(const context : IFixtureProviderContext);
var
  pair : TPair<TClass, string>;
  fixture : ITestFixture;
  parentFixture : ITestFixture;
  uName : string;
  namespaces : TArray<string>;
  fixtureNamespaces : TArray<string>;
  namespace : string;
  parentNamespace : string;
  fixtureNamespace : string;
  fixtureName : string;
  tmpFixtures : TDictionary<string, ITestFixture>;
  fixtureList : ITestFixtureList;
  rType : TRttiType;
  categoryAttrib : CategoryAttribute;
  category : string;
begin
  if context.UseRtti then
    RTTIDiscoverFixtureClasses;

  for pair in TDUnitX.RegisteredFixtures do
  begin
    if not FFixtureClasses.ContainsKey(pair.Key) then
      FFixtureClasses.AddOrSetValue(pair.Key, pair.Value);
  end;

  //Build up a fixture hierarchy based on unit names.
  tmpFixtures := TDictionary<string, ITestFixture>.Create;
  fixtureList := TTestFixtureList.Create;
  try
    for pair in FFixtureClasses do
    begin
      rType := FRttiContext.GetType(pair.Key);
      if rType.TryGetAttributeOfType<CategoryAttribute>(categoryAttrib) then
        category := categoryAttrib.Category
      else
        category := '';

      uName := pair.Key.UnitName;

      namespaces := TStrUtils.SplitString(uName, '.');
      //check if the fixture name has namespaces (possible via testfixtureattribute)
      fixtureNamespaces := TStrUtils.SplitString(pair.Value, '.');
      if length(fixtureNamespaces) > 1 then
      begin
        fixtureName := fixtureNamespaces[Length(fixtureNamespaces) - 1];
        TArrayHelper.Delete<string>(fixtureNamespaces, Length(fixtureNamespaces) - 1, 1);

        namespaces := TArrayHelper.Concat<string>([namespaces, fixtureNamespaces]);
      end
      else
        fixtureName := pair.Value;

      //if the unit name has no namespaces the just add the tests.
      fixtureNamespace := '';
      parentNameSpace := '';

      parentFixture := nil;
      fixture := nil;

      for namespace in namespaces do
      begin
        if fixtureNamespace <> '' then
          fixtureNamespace := fixtureNamespace + '.' + namespace
        else
          fixtureNamespace := namespace;

        //first time through the loop it will be empty.
        if parentNamespace = '' then
        begin
          if not tmpFixtures.TryGetValue(fixtureNamespace, parentFixture) then
          begin
            parentFixture := context.CreateFixture(TObject, fixtureNamespace, ''); //<< Should this not take category??
            tmpFixtures.Add(fixtureNamespace, parentFixture);
            fixtureList.Add(parentFixture);
          end;
          parentNamespace := fixtureNamespace;
          continue;
        end
        else
        begin
          if not tmpFixtures.TryGetValue(parentNamespace, parentFixture) then
          begin
            parentFixture := context.CreateFixture(TObject, parentNamespace, '');
            tmpFixtures.Add(parentNamespace, parentFixture);
            fixtureList.Add(parentFixture);
          end;

          if not tmpFixtures.TryGetValue(fixtureNamespace, fixture) then
          begin
            fixture := parentFixture.AddChildFixture(TObject, fixtureNamespace, '');
            tmpFixtures.Add(fixtureNamespace, fixture);
          end;
          parentFixture := fixture;
          parentNamespace := fixtureNamespace;
        end;
      end;

      fixtureNamespace := fixtureNamespace + '.' + fixtureName;

      //per issue #253 - looking at the code above, parentFixture should always be assigned by the time we get here.
      System.Assert(Assigned(parentFixture));
      parentFixture.AddChildFixture(pair.Key, fixtureNamespace, category);
    end;
    for fixture in fixtureList do
    begin
      GenerateTests(context, fixture);
    end;

  finally
    fixtureList := nil;
    tmpFixtures.Free;
  end;
end;

function TDUnitXFixtureProvider.FormatCaseName(const AName : string;
  Nr : integer) : string;
begin
  result := Format('%s (%.2d)', [AName, nr]);
end;

function TDUnitXFixtureProvider.FormatTestName(const AName : string; const ATimes, ACount : Integer) : string;
begin
  Result := AName;

  if (ACount > 1) then
  begin
    Result := Result + Format('-%d-of-%d', [ATimes, ACount]);
  end;
end;

type
  //A method of a fixture class as the provider takes it: the declaration whose attributes apply, the code to bind, and
  //whether it is published.
  TResolvedMethod = record
    Method : TRttiMethod;
    Code : Pointer;
    IsPublished : boolean;
  end;

//Resolves AMethods (GetMethods order: the class itself first, then up the hierarchy) for a fixture of class ATestClass.
//An override is listed before the ancestor method it overrides and does not inherit its attributes, so each virtual
//method is taken once, at its most derived declaration, with the attributes of the nearest declaration that has any,
//and is bound to ATestClass's own implementation. Binding the ancestor's static code address ran the ancestor's code
//(an overriding [Setup] or [Test] never ran) and made an overridden test two tests.
function ResolveFixtureMethods(const AMethods : TArray<TRttiMethod>; const ATestClass : TClass) : TArray<TResolvedMethod>;
var
  slotAttributes : TDictionary<Integer, TRttiMethod>;
  slotPublished : TDictionary<Integer, Boolean>;
  slotsTaken : TDictionary<Integer, Boolean>;
  declared : TRttiMethod;
  resolved : TResolvedMethod;
  count : Integer;
begin
  SetLength(Result, Length(AMethods));
  count := 0;
  slotAttributes := TDictionary<Integer, TRttiMethod>.Create;
  slotPublished := TDictionary<Integer, Boolean>.Create;
  slotsTaken := TDictionary<Integer, Boolean>.Create;
  try
    for declared in AMethods do
      if declared.DispatchKind = TDispatchKind.dkVtable then
      begin
        if (Length(declared.GetAttributes) > 0) and (not slotAttributes.ContainsKey(declared.VirtualIndex)) then
          slotAttributes.Add(declared.VirtualIndex, declared);
        if declared.Visibility = TMemberVisibility.mvPublished then
          slotPublished.AddOrSetValue(declared.VirtualIndex, True);
      end;

    for declared in AMethods do
    begin
      if declared.DispatchKind = TDispatchKind.dkVtable then
      begin
        if slotsTaken.ContainsKey(declared.VirtualIndex) then
          continue;
        slotsTaken.Add(declared.VirtualIndex, True);
        if not slotAttributes.TryGetValue(declared.VirtualIndex, resolved.Method) then
          resolved.Method := declared;
        resolved.IsPublished := slotPublished.ContainsKey(declared.VirtualIndex);
        resolved.Code := PPointer(PByte(ATestClass) + declared.VirtualIndex * SizeOf(Pointer))^;
      end
      else
      begin
        resolved.Method := declared;
        resolved.IsPublished := declared.Visibility = TMemberVisibility.mvPublished;
        resolved.Code := declared.CodeAddress;
      end;
      Result[count] := resolved;
      Inc(count);
    end;
  finally
    slotsTaken.Free;
    slotPublished.Free;
    slotAttributes.Free;
  end;
  SetLength(Result, count);
end;

procedure TDUnitXFixtureProvider.GenerateTests(const context : IFixtureProviderContext; const fixture : ITestFixture);
var
  childFixture : ITestFixture;

  rType : TRttiType;
  resolved : TResolvedMethod;
  method : TRttiMethod;
  meth : TMethod;

  tearDownFixtureIsDestructor : boolean;
  setupMethod : TTestMethod;
  tearDownMethod : TTestMethod;
  setupFixtureMethod : TTestMethod;
  tearDownFixtureMethod : TTestMethod;

  setupAttrib : SetupAttribute;
  setupFixtureAttrib : SetupFixtureAttribute;
  tearDownAttrib : TearDownAttribute;
  tearDownFixtureAttrib : TearDownFixtureAttribute;
  testAttrib : TestAttribute;
  categoryAttrib : CategoryAttribute;
  ignoredAttrib : IgnoreAttribute;
  willRaiseAttrib : WillRaiseAttribute;
  testCases : TArray<CustomTestCaseAttribute>;
  testCaseAttrib : CustomTestCaseAttribute;
  testCaseSources : TArray<CustomTestCaseSourceAttribute>;
  testCaseSourceAttrb : CustomTestCaseSourceAttribute;
  testCaseData : TestCaseInfo;
  testEnabled : boolean;
  isTestMethod : boolean;
  repeatAttrib : RepeatTestAttribute;
  maxTimeAttrib : MaxTimeAttribute;
  tstProviderAttribs : TArray<TestCaseProviderAttribute>;
  tstProviderAttrib : TestCaseProviderAttribute;
  iProvider : ITestDataProvider;
  count, x : integer;
  Params : TValueArray;
  caseName : string;

  category : string;
  ignoredTest : boolean;
  ignoredReason : string;
  maxTime : cardinal;
  willRaise : ExceptClass;
  willRaiseInherit : TExceptionInheritance;

  repeatCount : Cardinal;
  i : Integer;
  currentFixture : ITestFixture;
begin
  //  WriteLn('Generating Tests for : ' + fixture.FullName);

  if fixture.HasChildFixtures then
  begin
    for childFixture in fixture.Children do
      GenerateTests(context, childFixture);
  end;

  rType := FRttiContext.GetType(fixture.TestClass);
  System.Assert(rType <> nil);

  //it's a dummy namespace fixture, don't bother with the rest.
  if rType.Handle = TypeInfo(TObject) then
    exit;

  tearDownFixtureIsDestructor := False;
  setupMethod := nil;
  tearDownMethod := nil;
  setupFixtureMethod := nil;
  tearDownFixtureMethod := nil;

  //Note : Relying on the order of the methods return, ie current type, then up the heirachy
  for resolved in ResolveFixtureMethods(rType.GetMethods, fixture.TestClass) do
  begin
    method := resolved.Method;
    meth.Code := resolved.Code;
    meth.Data := fixture.FixtureInstance;

    ignoredTest := false;
    ignoredReason := '';

    category := TStrUtils.Join(TListStringUtils.ToArray(fixture.Categories), ','); //default to the fixture's category
    categoryAttrib := nil;
    testEnabled := true;
    setupAttrib := nil;
    setupFixtureAttrib := nil;
    tearDownAttrib := nil;
    tearDownFixtureAttrib := nil;
    ignoredAttrib := nil;
    testAttrib := nil;
    categoryAttrib := nil;
    willRaiseAttrib := nil;
    isTestMethod := false;
    repeatCount := 1;
    maxTimeAttrib := nil;
    maxTime := 0;
    willRaise := nil;
    willRaiseInherit := exExact;
    currentFixture := fixture;

    //if the test has a category attribute then we'll use it to override the fixtures's category.
    if method.TryGetAttributeOfType<CategoryAttribute>(categoryAttrib) then
      category := categoryAttrib.Category;

    if method.TryGetAttributeOfType<RepeatTestAttribute>(repeatAttrib) then
    begin
      if (repeatAttrib.Count = 0) then
      begin
        ignoredTest := True;
        ignoredReason := STestIgnoredRepeatSet;
      end
      else if (repeatAttrib.Count > 1) then
        //The repetitions are tests of this fixture (named -n-of-count), so they share its instance, its
        //Setup / TearDown (wherever declared) and its fixture setup. A child fixture used to hold them, with
        //Setup / TearDown copied before a base class's had been seen and test cases on a second instance.
        repeatCount := repeatAttrib.Count;
    end;

    if (not Assigned(setupFixtureMethod)) and method.TryGetAttributeOfType<SetupFixtureAttribute>(setupFixtureAttrib) then
    begin
      //A constructor marked [SetupFixture] already ran when the fixture instance was created; it must not be
      //called again as a method.
      if method.IsConstructor then
        continue;
      setupFixtureMethod := TTestMethod(meth);
      currentFixture.SetSetupFixtureMethod(method.Name, setupFixtureMethod);
      continue;
    end;

{$IFDEF DELPHI_XE_UP}
    //if there is a Destructor then we will use it as the fixture
    //Teardown method.
    if (not Assigned(tearDownFixtureMethod)) and method.IsDestructor and (Length(method.GetParameters) = 0) then
    begin
      tearDownFixtureMethod := TTestMethod(meth);
      currentFixture.SetTearDownFixtureMethod(method.Name, TTestMethod(meth), true);
      tearDownFixtureIsDestructor := true;
      continue;
    end;
{$ENDIF}

    //if we had previously assigned a destructor as the teardownfixturemethod, then we can still override that with an attributed one.
    if ((not Assigned(tearDownFixtureMethod)) or tearDownFixtureIsDestructor) and method.TryGetAttributeOfType<TearDownFixtureAttribute>(tearDownFixtureAttrib)
      then
    begin
      tearDownFixtureMethod := TTestMethod(meth);
      currentFixture.SetTearDownFixtureMethod(method.Name, tearDownFixtureMethod, false);
      tearDownFixtureIsDestructor := false;
      continue;
    end;

    if (not Assigned(setupMethod)) and method.TryGetAttributeOfType<SetupAttribute>(setupAttrib) then
    begin
      setupMethod := TTestMethod(meth);
      currentFixture.SetSetupTestMethod(method.Name, setupMethod);
      continue;
    end;

    if (not Assigned(tearDownMethod)) and method.TryGetAttributeOfType<TearDownAttribute>(tearDownAttrib) then
    begin
      tearDownMethod := TTestMethod(meth);
      currentFixture.SetTearDownTestMethod(method.Name, tearDownMethod);
      continue;
    end;

    if fixture.Ignored then
    begin
      ignoredTest := true;
      ignoredReason := fixture.IgnoreReason;
    end
    else if method.TryGetAttributeOfType<IgnoreAttribute>(ignoredAttrib) then
    begin
      ignoredTest := true;
      ignoredReason := ignoredAttrib.Reason;
    end;

    if method.TryGetAttributeOfType<WillRaiseAttribute>(willRaiseAttrib) then
    begin
      willRaise := willRaiseAttrib.ExpectedException;
      willRaiseInherit := willRaiseAttrib.ExceptionInheritance;
    end;

    if method.TryGetAttributeOfType<TestAttribute>(testAttrib) then
    begin
      testEnabled := testAttrib.Enabled;
      isTestMethod := true;
    end;

    if method.TryGetAttributeOfType<MaxTimeAttribute>(maxTimeAttrib) then
      maxTime := maxTimeAttrib.MaxTime;
    if method.IsDestructor or method.IsConstructor then
      continue;

    //if a test case is disabled then just ignore it.
    if testEnabled then
    begin
      //find out if the test fixture has test cases.
      testCases := method.GetAttributesOfType<CustomTestCaseAttribute>;
      //find out if the test has test sources
      testCaseSources := method.GetAttributesOfType<CustomTestCaseSourceAttribute>;
      //Find out if we got a TestProviderAttribute
      tstProviderAttribs := Method.GetAttributesOfType<TestCaseProviderAttribute>;

      if (Length(testCases) > 0) or (Length(testCaseSources) > 0) or (Length(tstProviderAttribs) > 0) then
      begin
        if not ignoredTest then
        begin
          //Add the Providertests first
          for tstProviderAttrib in tstProviderAttribs do
          begin
            if (tstProviderAttrib.ProviderClass <> nil) then
              iProvider := TestDataProviderManager.GetProvider(tstProviderAttrib.ProviderClass)
            else
              iProvider := TestDataProviderManager.GetProvider(tstProviderAttrib.ProviderName);
            if (iProvider <> nil) then
            begin
              count := iProvider.GetCaseCount(method.name);
              for x := 0 to count - 1 do
              begin
                caseName := iProvider.GetCaseName(method.name, x);
                params := iProvider.GetCaseParams(method.name, x);
                for i := 1 to repeatCount do
                begin
                  currentFixture.AddTestCase(method.Name, FormatCaseName(caseName, x), FormatTestName(method.Name, i, repeatCount), category, method,
                    testEnabled, params, maxTime, willRaise, willRaiseInherit);
                end;
              end;
              iProvider := nil;
            end
            else
            begin
              //An unregistered provider would otherwise produce no tests at all, silently.
              if tstProviderAttrib.ProviderClass <> nil then
                caseName := tstProviderAttrib.ProviderClass.ClassName
              else
                caseName := tstProviderAttrib.ProviderName;
              currentFixture.Tests.Add(TDUnitXErrorTest.Create(currentFixture, method.Name, method.Name, category,
                Format(SUnknownTestCaseProvider, [caseName, method.Name])));
            end;
          end;
          // Add individual test cases
          for testCaseAttrib in testCases do
          begin
            for i := 1 to repeatCount do
            begin
              if testCaseAttrib is AutoNameTestCaseAttribute then
                caseName := '(' + AutoNameTestCaseAttribute(testCaseAttrib).ValuesText + ')'
              else
                caseName := testCaseAttrib.CaseInfo.Name;
              currentFixture.AddTestCase(method.Name, caseName, FormatTestName(method.Name, i, repeatCount), category, method, testEnabled,
                testCaseAttrib.CaseInfo.Values, maxTime, willRaise, willRaiseInherit);
            end;
          end;
          // Add test case from test \case sources
          if Length(testCaseSources) > 0 then
          begin
            for testCaseSourceAttrb in testCaseSources do
            begin
              if Length(testCaseSourceAttrb.CaseInfoArray) > 0 then
              begin
                for testCaseData in testCaseSourceAttrb.CaseInfoArray do
                begin
                  for i := 1 to repeatCount do
                  begin
                    currentFixture.AddTestCase(method.Name, TestCaseData.Name, FormatTestName(method.Name, i, repeatCount), category, method, testEnabled,
                      TestCaseData.Values, maxTime, willRaise, willRaiseInherit);
                  end;
                end;
              end;
            end;
          end;
        end
        else
        begin
          //if a testcase is ignored, just add it as a regular test.
          currentFixture.AddTest(method.Name, TTestMethod(meth), method.Name, category, method, true, true, ignoredReason, maxTime);
        end;
        continue;
      end;
    end;

    if isTestMethod and testEnabled then
    begin
      for i := 1 to repeatCount do
      begin
        currentFixture.AddTest(method.Name, TTestMethod(meth), FormatTestName(method.Name, i, repeatCount), category, method, true, ignoredTest, ignoredReason,
          maxTime, willRaise, willRaiseInherit);
      end;
      continue;
    end;

    //finally.. if it's a pulished method
    if resolved.IsPublished and (testEnabled) then
    begin
      // Add Published Method that has no Attributes
      for i := 1 to repeatCount do
      begin
        currentFixture.AddTest(method.Name, TTestMethod(meth), FormatTestName(method.Name, i, repeatCount), category, method, true, ignoredTest, ignoredReason,
          maxTime, willRaise, willRaiseInherit);
      end;
    end;
  end;
end;

function TDUnitXFixtureProvider.TryGetAttributeOfType<T>(const attributes : TArray<TCustomAttribute>; var attribute : T) : boolean;
var
  LAttribute : TCustomAttribute;
begin
  attribute := Default(T);
  Result := false;
  for LAttribute in attributes do
  begin
    if LAttribute.InheritsFrom(T) then
    begin
      attribute := T(LAttribute);
      result := true;
      Break;
    end;
  end;
end;

procedure TDUnitXFixtureProvider.RTTIDiscoverFixtureClasses;
var
  types : TArray<TRttiType>;
  rType : TRttiType;
  attributes : TArray<TCustomAttribute>;
  sName : string;
  fixtureAttribute : TestFixtureAttribute;
begin
  types := FRttiContext.GetTypes;
  for rType in types do
  begin
    fixtureAttribute := nil;
    //Every class is examined, TPersistent descendants included: a [TestFixture] may descend from TComponent. (A
    //TPersistent filter here never took effect, as it asked about the TRttiType object rather than the class.)
    if rType.TypeKind = TTypeKind.tkClass then
    begin
      attributes := rType.GetAttributes;
      if Length(attributes) > 0 then
      begin
        if TryGetAttributeOfType<TestFixtureAttribute>(attributes, fixtureAttribute) then
        begin
          sName := fixtureattribute.Name;
          if sName = '' then
            sName := TRttiInstanceType(rType).MetaclassType.ClassName;
          if not FFixtureClasses.ContainsKey(TRttiInstanceType(rType).MetaclassType) then
            FFixtureClasses.Add(TRttiInstanceType(rType).MetaclassType, sName);
        end;
      end;
    end;
  end;
end;

end.

