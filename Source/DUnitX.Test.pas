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

unit DUnitX.Test;

interface

{$I DUnitX.inc}

uses
{$IFDEF USE_NS}
  System.Generics.Collections,
  System.TimeSpan,
  System.Rtti,
  System.SysUtils,
  System.TypInfo,
{$ELSE}
  Generics.Collections,
  TimeSpan,
  Rtti,
  SysUtils,
{$ENDIF}
  DUnitX.Types,
  DUnitX.Extensibility,
  DUnitX.InternalInterfaces,
  DUnitX.WeakReference,
  DUnitX.TestFramework;

type
  /// <summary>
  ///   A single runnable test: a parameterless method of a fixture instance, with its name, categories, enabled /
  ///   ignored state, [MaxTime] limit and timing of its last run.
  /// </summary>
  TDUnitXTest = class(TWeakReferencedObject, ITest, ITestInfo, ISetTestResult, ITestExecute)
  private
    /// <summary>The test's display name (for a repeated test, suffixed -n-of-count).</summary>
    FName : string;
    /// <summary>The name of the fixture method the test runs.</summary>
    FMethodName : string;
    /// <summary>The test's categories, compared case-insensitively.</summary>
    FCategories : TList<string>;
    /// <summary>The bound test method; its Data is the fixture instance.</summary>
    FMethod : TTestMethod;
    /// <summary>Weak reference to the owning fixture, so the test does not keep it alive.</summary>
    FFixture : IWeakReference<ITestFixture>;
    /// <summary>When the last run started.</summary>
    FStartTime : TDateTime;
    /// <summary>When the last run ended.</summary>
    FEndTime : TDateTime;
    /// <summary>How long the last run took.</summary>
    FDuration : TTimeSpan;
    /// <summary>Whether the test is selected to run.</summary>
    FEnabled : boolean;
    /// <summary>Whether the test is ignored ([Ignore], or an ignored fixture).</summary>
    FIgnored : boolean;
    /// <summary>Why the test is ignored.</summary>
    FIgnoreReason : string;
    /// <summary>Whether memory leaks found while the test runs are to be ignored.</summary>
    FIgnoreMemoryLeaks : Boolean;
    /// <summary>The [MaxTime] limit in milliseconds; 0 for no limit.</summary>
    FMaxTime : cardinal;
    /// <summary>Whether the last run exceeded FMaxTime.</summary>
    FTimedOut : Boolean;
  protected
    /// <summary>
    ///   ITest: the test's display name.
    /// </summary>
    /// <returns>
    ///   The name given at creation.
    /// </returns>
    function GetName : string; virtual;
    /// <summary>
    ///   ITest: the name of the fixture method the test runs.
    /// </summary>
    /// <returns>
    ///   The method name.
    /// </returns>
    function GetMethodName : string;
    /// <summary>
    ///   ITest: the test's categories.
    /// </summary>
    /// <returns>
    ///   The live list owned by the test; do not free it.
    /// </returns>
    function GetCategories : TList<string>;
    /// <summary>
    ///   ITest: the fixture's full name, a '.', and the test's name.
    /// </summary>
    /// <returns>
    ///   The fully qualified test name.
    /// </returns>
    function GetFullName : string; virtual;
    /// <summary>
    ///   ITest: the owning fixture.
    /// </summary>
    /// <returns>
    ///   The fixture, or nil when it has already been freed.
    /// </returns>
    function GetTestFixture : ITestFixture;
    /// <summary>
    ///   ITest: the bound test method.
    /// </summary>
    /// <returns>
    ///   The method; nil for a test case or an error test.
    /// </returns>
    function GetTestMethod : TTestMethod;
    /// <summary>
    ///   ITest: when the last run started.
    /// </summary>
    /// <returns>
    ///   The start time; 0 before the first run.
    /// </returns>
    function GetTestStartTime : TDateTime;
    /// <summary>
    ///   ITest: when the last run ended.
    /// </summary>
    /// <returns>
    ///   The end time; 0 before the first run.
    /// </returns>
    function GetTestEndTime : TDateTime;
    /// <summary>
    ///   ITest: how long the last run took.
    /// </summary>
    /// <returns>
    ///   The duration.
    /// </returns>
    function GetTestDuration : TTimeSpan;
    /// <summary>
    ///   ITest: whether memory leaks found while the test runs are ignored.
    /// </summary>
    /// <returns>
    ///   True when leaks are ignored.
    /// </returns>
    function GetIgnoreMemoryLeaks() : Boolean;
    /// <summary>
    ///   ITest: sets whether memory leaks found while the test runs are ignored.
    /// </summary>
    /// <param name="AValue">
    ///   True to ignore leaks.
    /// </param>
    procedure SetIgnoreMemoryLeaks(const AValue : Boolean);
    /// <summary>
    ///   ITest: the [MaxTime] limit.
    /// </summary>
    /// <returns>
    ///   The limit in milliseconds; 0 for no limit.
    /// </returns>
    function GetMaxTime : cardinal;
    /// <summary>
    ///   ITest: sets the [MaxTime] limit.
    /// </summary>
    /// <param name="AValue">
    ///   The limit in milliseconds; 0 for no limit.
    /// </param>
    procedure SetMaxTime(const AValue : cardinal);
    /// <summary>
    ///   ITest: whether the last run exceeded its [MaxTime] limit.
    /// </summary>
    /// <returns>
    ///   True when it timed out.
    /// </returns>
    function GetTimedOut : Boolean;
    /// <summary>
    ///   ITest: sets the timed-out flag.
    /// </summary>
    /// <param name="AValue">
    ///   True to mark the test as timed out.
    /// </param>
    procedure SetTimedOut(const AValue : Boolean);
    /// <summary>
    ///   ITest: whether this is one case of a parameterised test.
    /// </summary>
    /// <returns>
    ///   False; TDUnitXTestCase overrides it to return True.
    /// </returns>
    function GetIsTestCase : boolean; virtual;

    /// <summary>
    ///   ITestInfo: whether the test is active.
    /// </summary>
    /// <returns>
    ///   Always True; the active state is not yet tracked.
    /// </returns>
    function GetActive : boolean;
    /// <summary>ITestInfo.GetTestFixture is implemented by ITestInfo_GetTestFixture.</summary>
    function ITestInfo.GetTestFixture = ITestInfo_GetTestFixture;
    /// <summary>
    ///   ITestInfo: the owning fixture's information.
    /// </summary>
    /// <returns>
    ///   The fixture as ITestFixtureInfo, or nil when it has already been freed.
    /// </returns>
    function ITestInfo_GetTestFixture : ITestFixtureInfo;
    /// <summary>
    ///   ITestInfo: whether the test is selected to run.
    /// </summary>
    /// <returns>
    ///   True when enabled.
    /// </returns>
    function GetEnabled : Boolean;
    /// <summary>
    ///   ITestInfo: selects or deselects the test.
    /// </summary>
    /// <param name="value">
    ///   True to run the test.
    /// </param>
    procedure SetEnabled(const value : Boolean);
    /// <summary>
    ///   ITestInfo: whether the test is ignored.
    /// </summary>
    /// <returns>
    ///   True when ignored.
    /// </returns>
    function GetIgnored : boolean;
    /// <summary>
    ///   ITestInfo: why the test is ignored.
    /// </summary>
    /// <returns>
    ///   The reason; empty when none was given.
    /// </returns>
    function GetIgnoreReason : string;

    /// <summary>
    ///   ISetTestResult: receives the test's result. Currently does nothing.
    /// </summary>
    /// <param name="value">
    ///   The result (discarded).
    /// </param>
    procedure SetResult(const value : ITestResult);

    /// <summary>
    ///   ITestExecute: runs the test body, records its start, end and duration, and enforces [MaxTime].
    /// </summary>
    /// <param name="context">
    ///   The execution context (not used by the base implementation).
    /// </param>
    /// <exception cref="ETimedOut">
    ///   Raised when the body overran its [MaxTime] limit, including when it ended early with Assert.Pass.
    /// </exception>
    /// <remarks>
    ///   Any exception from the test body (ETestFailure, ETestPass, ETestIgnored and so on) propagates to the runner.
    /// </remarks>
    procedure Execute(const context : ITestExecuteContext); virtual;
    /// <summary>
    ///   ITestExecute: rebinds the test to a new fixture instance.
    /// </summary>
    /// <param name="fixtureInstance">
    ///   The fixture instance the method is now to run on.
    /// </param>
    procedure UpdateInstance(const fixtureInstance : TObject); virtual;
    /// <summary>
    ///   Runs the test body; Execute times it against [MaxTime]. The base implementation calls the bound method.
    /// </summary>
    procedure ExecuteMethod; virtual;
  public
    /// <summary>
    ///   Creates a test bound to a fixture method.
    /// </summary>
    /// <param name="AFixture">
    ///   The owning fixture, held weakly.
    /// </param>
    /// <param name="AMethodName">
    ///   The name of the fixture method.
    /// </param>
    /// <param name="AName">
    ///   The test's display name.
    /// </param>
    /// <param name="ACategory">
    ///   Comma-separated categories; each is trimmed.
    /// </param>
    /// <param name="AMethod">
    ///   The bound method to run.
    /// </param>
    /// <param name="AEnabled">
    ///   True to run the test.
    /// </param>
    /// <param name="AIgnored">
    ///   True to report the test as ignored.
    /// </param>
    /// <param name="AIgnoreReason">
    ///   Why the test is ignored.
    /// </param>
    /// <param name="AMaxTime">
    ///   The [MaxTime] limit in milliseconds; 0 for no limit.
    /// </param>
    constructor Create(const AFixture : ITestFixture; const AMethodName : string; const AName : string; const ACategory : string; const AMethod : TTestMethod;
      const AEnabled : boolean; const AIgnored : boolean = false; const AIgnoreReason : string = ''; const AMaxTime : Cardinal = 0);
    /// <summary>
    ///   Frees the category list.
    /// </summary>
    destructor Destroy; override;
  end;

  /// <summary>
  ///   A [WillRaise] test: passes only when the body raises the expected exception class (exactly, or a descendant).
  /// </summary>
  TDUnitXExceptionTest = class(TDUnitXTest, ITestExecute)
  private
    /// <summary>The exception class the body must raise.</summary>
    FExpectedException : ExceptClass;
    /// <summary>Whether the raised class must match exactly or may descend from FExpectedException.</summary>
    FExceptionInheritance : TExceptionInheritance;
  protected
    /// <summary>
    ///   Runs the body inside Assert.WillRaise (or Assert.WillRaiseDescendant), within the timed region so that
    ///   [MaxTime] still applies.
    /// </summary>
    /// <exception cref="ETestFailure">
    ///   Raised when the body raises nothing or a different exception class.
    /// </exception>
    /// <remarks>
    ///   Nothing is kept from the execute context: holding it (the run results, which hold the fixture, which holds
    ///   this test) made a reference cycle that leaked the whole run.
    /// </remarks>
    procedure ExecuteMethod; override;
  public
    /// <summary>
    ///   Creates a test that expects its body to raise.
    /// </summary>
    /// <param name="AFixture">
    ///   The owning fixture, held weakly.
    /// </param>
    /// <param name="AMethodName">
    ///   The name of the fixture method.
    /// </param>
    /// <param name="AName">
    ///   The test's display name.
    /// </param>
    /// <param name="ACategory">
    ///   Comma-separated categories.
    /// </param>
    /// <param name="AMethod">
    ///   The bound method to run.
    /// </param>
    /// <param name="AEnabled">
    ///   True to run the test.
    /// </param>
    /// <param name="AIgnored">
    ///   True to report the test as ignored.
    /// </param>
    /// <param name="AIgnoreReason">
    ///   Why the test is ignored.
    /// </param>
    /// <param name="AMaxTime">
    ///   The [MaxTime] limit in milliseconds; 0 for no limit.
    /// </param>
    /// <param name="AExpectedException">
    ///   The exception class the body must raise.
    /// </param>
    /// <param name="AExceptionInheritance">
    ///   exExact to require that class exactly; exDescendant to accept a descendant too.
    /// </param>
    constructor Create(const AFixture : ITestFixture; const AMethodName : string; const AName : string; const ACategory : string;
      const AMethod : TTestMethod; const AEnabled : boolean; const AIgnored : boolean = false;
      const AIgnoreReason : string = ''; const AMaxTime : Cardinal = 0;
      const AExpectedException : ExceptClass = nil; const AExceptionInheritance : TExceptionInheritance = exExact);
  end;

  /// <summary>
  ///   One case of a parameterised test ([TestCase], a test case source or a [TestCaseProvider]): invokes the method
  ///   through RTTI with arguments converted to the parameter types when the test is created.
  /// </summary>
  TDUnitXTestCase = class(TDUnitXTest, ITestExecute)
  private
    /// <summary>The case's name, appended to the test name by GetName.</summary>
    FCaseName : string;
    /// <summary>The arguments, already converted to the method's parameter types.</summary>
    FArgs : TValueArray;
    /// <summary>The RTTI method invoked for the case.</summary>
    FRttiMethod : TRttiMethod;
    /// <summary>The fixture instance the method is invoked on.</summary>
    FInstance : TObject;
    /// <summary>
    ///   A wrong argument count or failed conversion found at creation; when set, running the case raises it instead
    ///   of invoking the method, so bad data does not silently become defaults and does not abort the whole run.
    /// </summary>
    FArgError : string;
    /// <summary>The [WillRaise] exception class each case must raise; nil when none is expected.</summary>
    FExpectedException : ExceptClass;
    /// <summary>Whether the raised class must match exactly or may descend from FExpectedException.</summary>
    FExceptionInheritance : TExceptionInheritance;
    /// <summary>
    ///   Invokes the RTTI method on the fixture instance with the converted arguments.
    /// </summary>
    procedure InvokeMethod;
  protected
    /// <summary>
    ///   Identifies the test as a test case.
    /// </summary>
    /// <returns>
    ///   Always True.
    /// </returns>
    function GetIsTestCase : boolean; override;
    /// <summary>
    ///   The test name joined to the case name: directly when the case name starts with '(' (an auto-named case),
    ///   otherwise with a '.'.
    /// </summary>
    /// <returns>
    ///   The case's display name; the plain test name when the case has no name.
    /// </returns>
    function GetName : string; override;
    /// <summary>
    ///   Invokes the method with the case's arguments, applying [WillRaise] to each case as to a plain test.
    /// </summary>
    /// <exception cref="EArgumentException">
    ///   Raised when the case's values did not match the method's parameters (count or conversion).
    /// </exception>
    /// <exception cref="ETestFailure">
    ///   Raised when [WillRaise] is set and the method raises nothing or a different exception class.
    /// </exception>
    procedure ExecuteMethod; override;
    /// <summary>
    ///   Rebinds the case to a new fixture instance.
    /// </summary>
    /// <param name="fixtureInstance">
    ///   The fixture instance the method is now to be invoked on.
    /// </param>
    procedure UpdateInstance(const fixtureInstance : TObject); override;
  public
    /// <summary>
    ///   Creates a test case and converts its values to the method's parameter types. A count mismatch or failed
    ///   conversion is stored and reported when the case runs, not raised here.
    /// </summary>
    /// <param name="AInstance">
    ///   The fixture instance to invoke the method on.
    /// </param>
    /// <param name="AFixture">
    ///   The owning fixture, held weakly.
    /// </param>
    /// <param name="AMethodName">
    ///   The name of the fixture method.
    /// </param>
    /// <param name="ACaseName">
    ///   The case's name.
    /// </param>
    /// <param name="AName">
    ///   The test's display name.
    /// </param>
    /// <param name="ACategory">
    ///   Comma-separated categories.
    /// </param>
    /// <param name="AMethod">
    ///   The RTTI method to invoke.
    /// </param>
    /// <param name="AEnabled">
    ///   True to run the case.
    /// </param>
    /// <param name="AArgs">
    ///   The case's values. For a single-parameter method, no values means one empty string.
    /// </param>
    /// <param name="AMaxTime">
    ///   The [MaxTime] limit in milliseconds; 0 for no limit.
    /// </param>
    /// <param name="AExpectedException">
    ///   The exception class each case must raise; nil when none is expected.
    /// </param>
    /// <param name="AExceptionInheritance">
    ///   exExact to require that class exactly; exDescendant to accept a descendant too.
    /// </param>
    constructor Create(const AInstance : TObject; const AFixture : ITestFixture; const AMethodName : string; const ACaseName : string; const AName : string;
      const ACategory : string; const AMethod : TRttiMethod;
      const AEnabled : boolean; const AArgs : TValueArray; const AMaxTime : Cardinal = 0;
      const AExpectedException : ExceptClass = nil; const AExceptionInheritance : TExceptionInheritance = exExact); reintroduce;
    /// <summary>
    ///   Destroys the test case.
    /// </summary>
    destructor Destroy; override;
  end;

  /// <summary>
  ///   A test that reports, when it runs, a problem found while the tests were generated (such as a [TestCaseProvider]
  ///   that is not registered), so the problem is not silently a missing test.
  /// </summary>
  TDUnitXErrorTest = class(TDUnitXTest, ITestExecute)
  private
    /// <summary>The problem to report.</summary>
    FError : string;
  protected
    /// <summary>
    ///   Reports the stored problem as an error.
    /// </summary>
    /// <exception cref="EArgumentException">
    ///   Always raised, with the stored message.
    /// </exception>
    procedure ExecuteMethod; override;
  public
    /// <summary>
    ///   Creates an enabled error test.
    /// </summary>
    /// <param name="AFixture">
    ///   The owning fixture, held weakly.
    /// </param>
    /// <param name="AMethodName">
    ///   The name of the fixture method the problem concerns.
    /// </param>
    /// <param name="AName">
    ///   The test's display name.
    /// </param>
    /// <param name="ACategory">
    ///   Comma-separated categories.
    /// </param>
    /// <param name="AError">
    ///   The message reported when the test runs.
    /// </param>
    constructor Create(const AFixture : ITestFixture; const AMethodName : string; const AName : string; const ACategory : string;
      const AError : string); reintroduce;
  end;

implementation

uses
{$IFDEF USE_NS}
  System.Generics.Defaults,
  System.StrUtils,
{$ELSE}
  Generics.Defaults,
  StrUtils,
{$ENDIF}
  DUnitX.Timeout,
  DUnitX.ResStrs,
  DUnitX.Exceptions,
  DUnitX.Utils;

{ TDUnitXTest }

constructor TDUnitXTest.Create(const AFixture : ITestFixture; const AMethodName : string; const AName : string; const ACategory : string; const AMethod :
  TTestMethod; const AEnabled : boolean; const AIgnored : boolean; const AIgnoreReason : string; const AMaxTime : Cardinal);
var
  categories : TArray<string>;
  cat : string;
begin
  inherited Create;
  FFixture := TWeakReference<ITestFixture>.Create(AFixture);
  FMethodName := AMethodName;
  FName := AName;

  FCategories := TList<string>.Create(TComparer<string>.Construct(
      function(const Left, Right : string) : integer
      begin
        result := AnsiCompareText(Left, Right);
      end));

  if ACategory <> '' then
  begin
    categories := TStrUtils.SplitString(ACategory, ',');
    for cat in categories do
      FCategories.Add(Trim(cat));
  end;

  FMethod := AMethod;
  FEnabled := AEnabled;
  FIgnored := AIgnored;
  FIgnoreReason := AIgnoreReason;
  FMaxTime := AMaxTime;
  FTimedOut := false;
end;

destructor TDUnitXTest.Destroy;
begin
  FCategories.Free;
  inherited;
end;

procedure TDUnitXTest.Execute(const context : ITestExecuteContext);
var
  timeout : ITimeout;

  //Stops timing before anything else runs, so that nothing executed afterwards is attributed to the test body, then
  //reports an overrun.
  procedure CheckTimeout;
  begin
    if timeout <> nil then
    begin
      timeout.Stop;
      FTimedOut := timeout.TimedOut;
      timeout.RaiseIfTimedOut;
    end;
  end;

begin
  FStartTime := Now();
  FTimedOut := false;
  try
    if FMaxTime > 0 then
      timeout := InitialiseTimeOut(FMaxTime);
    try
      ExecuteMethod;
    except
      //Assert.Pass ends the body early with ETestPass; an overrun before it is still a failure.
      on ETestPass do
      begin
        CheckTimeout;
        raise;
      end;
    end;
    CheckTimeout;
  finally
    FEndTime := Now();

    FDuration := TTimeSpan.Subtract(FEndTime, FStartTime);
  end;
end;

procedure TDUnitXTest.ExecuteMethod;
begin
  FMethod();
end;

function TDUnitXTest.GetActive : boolean;
begin
  //TODO: Need to set the internal active state
  result := True;
end;

function TDUnitXTest.GetCategories : TList<string>;
begin
  result := FCategories;
end;

function TDUnitXTest.GetEnabled : Boolean;
begin
  result := FEnabled;
end;

function TDUnitXTest.GetFullName : string;
var
  fixture : ITestFixture;
begin
  //The fixture is held weakly; a result can outlive it (the GUI runner keeps results across a reload).
  fixture := FFixture.Data;
  if fixture <> nil then
    result := fixture.FullName + '.' + Self.GetName
  else
    result := Self.GetName;
end;

function TDUnitXTest.GetIgnored : boolean;
begin
  result := FIgnored;
end;

function TDUnitXTest.GetIgnoreMemoryLeaks : Boolean;
begin
  Result := FIgnoreMemoryLeaks;
end;

function TDUnitXTest.GetIgnoreReason : string;
begin
  result := FIgnoreReason;
end;

function TDUnitXTest.GetIsTestCase : boolean;
begin
  result := false;
end;

function TDUnitXTest.GetMethodName : string;
begin
  result := FMethodName;
end;

function TDUnitXTest.GetName : string;
begin
  result := FName;
end;

function TDUnitXTest.GetTestDuration : TTimeSpan;
begin
  result := FDuration;
end;

function TDUnitXTest.GetTestEndTime : TDateTime;
begin
  result := FEndTime;
end;

function TDUnitXTest.GetTestFixture : ITestFixture;
begin
  if FFixture.IsAlive then
    result := FFixture.Data
  else
    result := nil;
end;

function TDUnitXTest.GetTestMethod : TTestMethod;
begin
  result := FMethod;
end;

function TDUnitXTest.GetTestStartTime : TDateTime;
begin
  result := FStartTime;
end;

function TDUnitXTest.ITestInfo_GetTestFixture : ITestFixtureInfo;
begin
  if FFixture.IsAlive then
    result := FFixture.Data as ITestFixtureInfo
  else
    result := nil;

end;

procedure TDUnitXTest.SetEnabled(const value : Boolean);
begin
  FEnabled := value;
end;

procedure TDUnitXTest.SetIgnoreMemoryLeaks(const AValue : Boolean);
begin
  FIgnoreMemoryLeaks := AValue;
end;

function TDUnitXTest.GetMaxTime : cardinal;
begin
  Result := FMaxTime;
end;

procedure TDUnitXTest.SetMaxTime(const AValue : cardinal);
begin
  FMaxTime := AValue;
end;

function TDUnitXTest.GetTimedOut : Boolean;
begin
  Result := FTimedOut;
end;

procedure TDUnitXTest.SetTimedOut(const AValue : Boolean);
begin
  FTimedOut := AValue;
end;

procedure TDUnitXTest.UpdateInstance(const fixtureInstance : TObject);
begin
  TMethod(FMethod).Data := fixtureInstance;
end;

procedure TDUnitXTest.SetResult(const value : ITestResult);
begin
  //TODO : what was meant to happen here?? Is this called?
end;

{ TDUnitXTestCase }

constructor TDUnitXTestCase.Create(const AInstance : TObject; const AFixture : ITestFixture; const AMethodName : string; const ACaseName : string;
  const AName : string; const ACategory : string; const AMethod : TRttiMethod; const AEnabled : boolean;
  const AArgs : TValueArray; const AMaxTime : Cardinal; const AExpectedException : ExceptClass;
  const AExceptionInheritance : TExceptionInheritance);
var
  len : integer;
  index : integer;
  parameters : TArray<TRttiParameter>;
  tmp : TValue;
  args : TValueArray;
  converted : boolean;
  typeName : string;
  reason : string;
begin
  inherited Create(AFixture, AMethodName, AName, ACategory, nil, AEnabled, false, '', AMaxTime);
  FInstance := AInstance;
  FRttiMethod := AMethod;
  FCaseName := ACaseName;
  FExpectedException := AExpectedException;
  FExceptionInheritance := AExceptionInheritance;

  parameters := FRttiMethod.GetParameters();

  //Work with the params as the limiter.
  len := Length(parameters);

  //Bad data must not silently become 0 / defaults. Raising here would abort the whole run,
  //so the problem is stored and Execute reports it as an error for this case alone.
  args := AArgs;
  //[TestCase('Empty', '')] splits into no values: for a single parameter that is one empty value.
  if (len = 1) and (Length(args) = 0) then
    args := [TValue.From<string>('')];
  if Length(args) <> len then
  begin
    FArgError := Format(STestCaseValueCount, [GetName, Length(args), len]);
    Exit;
  end;

  SetLength(FArgs, len);
  for index := 0 to Pred(len) do
  begin
    converted := Assigned(parameters[index].ParamType);
    reason := '';
    if converted then
    begin
      typeName := parameters[index].ParamType.Name;
      try
        converted := args[index].TryConvert(parameters[index].ParamType.Handle, tmp);
      except
        on E : Exception do
        begin
          converted := false;
          reason := ' (' + E.Message + ')';
        end;
      end;
    end
    else
      typeName := '(untyped)';
    if not converted then
    begin
      FArgError := Format(STestCaseValueConvert, [GetName, args[index].ToString, parameters[index].Name, typeName, reason]);
      Exit;
    end;
    FArgs[index] := tmp;
  end;
end;

destructor TDUnitXTestCase.Destroy;
begin

  inherited;
end;

procedure TDUnitXTestCase.ExecuteMethod;
begin
  if FArgError <> '' then
    raise EArgumentException.Create(FArgError);
  //[WillRaise] applies to each case of the method, as it does to a plain test.
  if FExpectedException = nil then
    InvokeMethod
  else if FExceptionInheritance = exDescendant then
    Assert.WillRaiseDescendant(InvokeMethod, FExpectedException)
  else
    Assert.WillRaise(InvokeMethod, FExpectedException);
end;

procedure TDUnitXTestCase.InvokeMethod;
begin
  FRttiMethod.Invoke(FInstance, FArgs);
end;

function TDUnitXTestCase.GetIsTestCase : boolean;
begin
  result := true;
end;

function TDUnitXTestCase.GetName : string;
begin
  if FCaseName <> '' then
  begin
    if StartsText('(', FCaseName) then
      Result := FName + FCaseName
    else
      Result := FName + '.' + FCaseName;
  end
  else
    Result := FName;

end;

procedure TDUnitXTestCase.UpdateInstance(const fixtureInstance : TObject);
begin
  inherited;
  FInstance := fixtureInstance;
end;

{ TDUnitXExceptionTest }

constructor TDUnitXExceptionTest.Create(const AFixture : ITestFixture;
  const AMethodName, AName, ACategory : string; const AMethod : TTestMethod;
  const AEnabled, AIgnored : boolean; const AIgnoreReason : string;
  const AMaxTime : Cardinal; const AExpectedException : ExceptClass; const AExceptionInheritance : TExceptionInheritance);
begin
  inherited Create(AFixture, AMethodName, AName, ACategory, AMethod, AEnabled, AIgnored, AIgnoreReason, AMaxTime);
  FExpectedException := AExpectedException;
  FExceptionInheritance := AExceptionInheritance;
end;

procedure TDUnitXExceptionTest.ExecuteMethod;
begin
  //Asserted inside the timed body, so [MaxTime] also applies when the expected exception is raised.
  //Nothing is kept from the execute context: holding it (the run results, which hold the fixture,
  //which holds this test) made a reference cycle that leaked the whole run.
  if FExceptionInheritance = exDescendant then
    Assert.WillRaiseDescendant(FMethod, FExpectedException)
  else
    Assert.WillRaise(FMethod, FExpectedException);
end;

{ TDUnitXErrorTest }

constructor TDUnitXErrorTest.Create(const AFixture : ITestFixture; const AMethodName, AName, ACategory, AError : string);
begin
  inherited Create(AFixture, AMethodName, AName, ACategory, nil, true);
  FError := AError;
end;

procedure TDUnitXErrorTest.ExecuteMethod;
begin
  raise EArgumentException.Create(FError);
end;

end.

