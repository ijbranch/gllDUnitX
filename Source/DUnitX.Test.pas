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
  TDUnitXTest = class(TWeakReferencedObject, ITest, ITestInfo, ISetTestResult, ITestExecute)
  private
    FName : string;
    FMethodName : string;
    FCategories : TList<string>;
    FMethod : TTestMethod;
    FFixture : IWeakReference<ITestFixture>;
    FStartTime : TDateTime;
    FEndTime : TDateTime;
    FDuration : TTimeSpan;
    FEnabled : boolean;
    FIgnored : boolean;
    FIgnoreReason : string;
    FIgnoreMemoryLeaks : Boolean;
    FMaxTime : cardinal;                // milliseconds for timeout
    FTimedOut : Boolean;
  protected
    //ITest
    function GetName : string; virtual;
    function GetMethodName : string;
    function GetCategories : TList<string>;
    function GetFullName : string; virtual;
    function GetTestFixture : ITestFixture;
    function GetTestMethod : TTestMethod;
    function GetTestStartTime : TDateTime;
    function GetTestEndTime : TDateTime;
    function GetTestDuration : TTimeSpan;
    function GetIgnoreMemoryLeaks() : Boolean;
    procedure SetIgnoreMemoryLeaks(const AValue : Boolean);
    function GetMaxTime : cardinal;
    procedure SetMaxTime(const AValue : cardinal);
    function GetTimedOut : Boolean;
    procedure SetTimedOut(const AValue : Boolean);
    function GetIsTestCase : boolean; virtual;

    //ITestInfo
    function GetActive : boolean;
    function ITestInfo.GetTestFixture = ITestInfo_GetTestFixture;
    function ITestInfo_GetTestFixture : ITestFixtureInfo;
    function GetEnabled : Boolean;
    procedure SetEnabled(const value : Boolean);
    function GetIgnored : boolean;
    function GetIgnoreReason : string;

    //ISetTestResult
    procedure SetResult(const value : ITestResult);

    //ITestExecute
    procedure Execute(const context : ITestExecuteContext); virtual;
    procedure UpdateInstance(const fixtureInstance : TObject); virtual;
    //Runs the test body; Execute times it against [MaxTime].
    procedure ExecuteMethod; virtual;
  public
    constructor Create(const AFixture : ITestFixture; const AMethodName : string; const AName : string; const ACategory : string; const AMethod : TTestMethod;
      const AEnabled : boolean; const AIgnored : boolean = false; const AIgnoreReason : string = ''; const AMaxTime : Cardinal = 0);
    destructor Destroy; override;
  end;

  TDUnitXExceptionTest = class(TDUnitXTest, ITestExecute)
  private
    FExpectedException : ExceptClass;
    FExceptionInheritance : TExceptionInheritance;
  protected
    procedure ExecuteMethod; override;
  public
    constructor Create(const AFixture : ITestFixture; const AMethodName : string; const AName : string; const ACategory : string;
      const AMethod : TTestMethod; const AEnabled : boolean; const AIgnored : boolean = false;
      const AIgnoreReason : string = ''; const AMaxTime : Cardinal = 0;
      const AExpectedException : ExceptClass = nil; const AExceptionInheritance : TExceptionInheritance = exExact);
  end;

  TDUnitXTestCase = class(TDUnitXTest, ITestExecute)
  private
    FCaseName : string;
    FArgs : TValueArray;
    FRttiMethod : TRttiMethod;
    FInstance : TObject;
    FArgError : string;
    FExpectedException : ExceptClass;
    FExceptionInheritance : TExceptionInheritance;
    procedure InvokeMethod;
  protected
    function GetIsTestCase : boolean; override;
    function GetName : string; override;
    procedure ExecuteMethod; override;
    procedure UpdateInstance(const fixtureInstance : TObject); override;
  public
    constructor Create(const AInstance : TObject; const AFixture : ITestFixture; const AMethodName : string; const ACaseName : string; const AName : string;
      const ACategory : string; const AMethod : TRttiMethod;
      const AEnabled : boolean; const AArgs : TValueArray; const AMaxTime : Cardinal = 0;
      const AExpectedException : ExceptClass = nil; const AExceptionInheritance : TExceptionInheritance = exExact); reintroduce;
    destructor Destroy; override;
  end;

  //A test that reports, when it runs, a problem found while the tests were generated (such as a
  //[TestCaseProvider] that is not registered), so the problem is not silently a missing test.
  TDUnitXErrorTest = class(TDUnitXTest, ITestExecute)
  private
    FError : string;
  protected
    procedure ExecuteMethod; override;
  public
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
begin
  FStartTime := Now();
  try
    if FMaxTime > 0 then
      timeout := InitialiseTimeOut(FMaxTime);
    ExecuteMethod;
    //Stop timing before anything else runs, so that nothing executed afterwards is
    //attributed to the test body, then report an overrun.
    if timeout <> nil then
    begin
      timeout.Stop;
      timeout.RaiseIfTimedOut;
    end;
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
begin
  result := FFixture.Data.FullName + '.' + Self.GetName;
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

