{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2015 Vincent Parrett & Contributors               }
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

unit DUnitX.TestResult;

interface

{$I DUnitX.inc}

uses
{$IFDEF USE_NS}
  System.SysUtils,
  System.TimeSpan,
{$ELSE}
  SysUtils,
  Timespan,
{$ENDIF}
  DUnitX.TestFramework,
  DUnitX.WeakReference,
  DUnitX.InternalInterfaces,
  DUnitX.ComparableFormat,
  DUnitX.Exceptions;

type
  /// <summary>
  ///   The outcome of one test run: its result type, message and log messages. Timing is read live from the test
  ///   through a weak reference, so it is unavailable once the test object is gone.
  /// </summary>
  TDUnitXTestResult = class(TInterfacedObject, ITestResult)
  private
    /// <summary>
    ///   The message as the user passed it; not used for internal purposes such as exception messages.
    /// </summary>
    FMessage : string;
    /// <summary>Messages logged by the test while it ran.</summary>
    FLogMessages : TLogMessageArray;
    /// <summary>The outcome: pass, failure, error, ignored or memory leak.</summary>
    FResultType : TTestResultType;
    /// <summary>Weak reference to the test, so the result does not keep the test alive.</summary>
    FTest : IWeakReference<ITestInfo>;
    /// <summary>Stack trace text; set only by <c>TDUnitXTestError</c> when a stack-trace provider is registered.</summary>
    FStackTrace : string;
  protected
    /// <summary>
    ///   Gives the user-supplied message.
    /// </summary>
    /// <returns>
    ///   The message passed to the constructor.
    /// </returns>
    function GetMessage : string;
    /// <summary>
    ///   Gives the messages the test logged.
    /// </summary>
    /// <returns>
    ///   The log messages passed to the constructor.
    /// </returns>
    function GetLogMessages : TLogMessageArray;
    /// <summary>
    ///   Reports whether the test passed.
    /// </summary>
    /// <returns>
    ///   True only when the result type is <c>Pass</c>.
    /// </returns>
    function GetResult : Boolean;
    /// <summary>
    ///   Gives the outcome of the test.
    /// </summary>
    /// <returns>
    ///   The result type.
    /// </returns>
    function GetResultType : TTestResultType;
    /// <summary>
    ///   Gives the test this result belongs to.
    /// </summary>
    /// <returns>
    ///   The test, or nil when it has already been destroyed.
    /// </returns>
    function GetTest : ITestInfo;
    /// <summary>
    ///   Gives the time the test started.
    /// </summary>
    /// <returns>
    ///   The test's start time, or 0 when the test has been destroyed.
    /// </returns>
    function GetStartTime : TDateTime;
    /// <summary>
    ///   Gives the time the test finished.
    /// </summary>
    /// <returns>
    ///   The test's end time, or 0 when the test has been destroyed.
    /// </returns>
    function GetFinishTime : TDateTime;
    /// <summary>
    ///   Gives how long the test took.
    /// </summary>
    /// <returns>
    ///   The test's duration, or zero when the test has been destroyed.
    /// </returns>
    function GetDuration : TTimeSpan;
    /// <summary>
    ///   Gives the stack trace captured for the result.
    /// </summary>
    /// <returns>
    ///   The stack trace, or an empty string when none was captured.
    /// </returns>
    function GetStackTrace : string;
  public
    /// <summary>
    ///   Creates a result with log messages.
    /// </summary>
    /// <param name="ATestInfo">
    ///   The test the result belongs to; held weakly.
    /// </param>
    /// <param name="AType">
    ///   The outcome.
    /// </param>
    /// <param name="AMessage">
    ///   The user-facing message.
    /// </param>
    /// <param name="ALogMessages">
    ///   Messages the test logged while it ran.
    /// </param>
    constructor Create(const ATestInfo : ITestInfo; const AType : TTestResultType; const AMessage : string; const ALogMessages : TLogMessageArray); overload;
    /// <summary>
    ///   Creates a result with no log messages.
    /// </summary>
    /// <param name="ATestInfo">
    ///   The test the result belongs to; held weakly.
    /// </param>
    /// <param name="AType">
    ///   The outcome.
    /// </param>
    /// <param name="AMessage">
    ///   The user-facing message; empty by default.
    /// </param>
    constructor Create(const ATestInfo : ITestInfo; const AType : TTestResultType; const AMessage : string = ''); overload;
    /// <summary>
    ///   Releases the weak reference to the test.
    /// </summary>
    destructor Destroy; override;
  end;

  /// <summary>
  ///   A test result caused by an exception (a failure or an error), carrying the exception's class, message and
  ///   address, a stack trace when a provider is registered, and the expected/actual pair of a string-comparison
  ///   failure.
  /// </summary>
  TDUnitXTestError = class(TDUnitXTestResult, ITestError)
  private
    /// <summary>Class of the exception that ended the test.</summary>
    FExceptionClass : ExceptClass;
    /// <summary>The user message followed by the exception's message when the two differ.</summary>
    FExceptionMessage : string;
    /// <summary>Address the exception was raised at.</summary>
    FExceptionAddress : Pointer;
    /// <summary>True when the exception is an <c>ETestFailureStrCompare</c> (or descendant), so expected and actual are filled.</summary>
    FIsComparable : boolean;
    /// <summary>Expected value of a string-comparison failure.</summary>
    FExpected : string;
    /// <summary>Actual value of a string-comparison failure.</summary>
    FActual : string;
    /// <summary>Format class used to display the expected and actual values of a string-comparison failure.</summary>
    FFormat : TDUnitXComparableFormatClass;
  protected
    /// <summary>
    ///   Gives the class of the exception that ended the test.
    /// </summary>
    /// <returns>
    ///   The exception class.
    /// </returns>
    function GetExceptionClass : ExceptClass;
    /// <summary>
    ///   Resolves the exception address to source location text through the registered stack-trace provider.
    /// </summary>
    /// <returns>
    ///   The location text, or an empty string when no provider is registered.
    /// </returns>
    function GetExceptionLocationInfo : string;
    /// <summary>
    ///   Resolves the exception address to address text through the registered stack-trace provider.
    /// </summary>
    /// <returns>
    ///   The address text, or an empty string when no provider is registered.
    /// </returns>
    function GetExceptionAddressInfo : string;
    /// <summary>
    ///   Gives the combined user and exception message.
    /// </summary>
    /// <returns>
    ///   The user message, followed by the exception's message when it differs.
    /// </returns>
    function GetExceptionMessage : string;
    /// <summary>
    ///   Gives the address the exception was raised at.
    /// </summary>
    /// <returns>
    ///   The raw exception address.
    /// </returns>
    function GetExceptionAddress : Pointer;
    /// <summary>
    ///   Reports whether the failure carries expected and actual values for comparison.
    /// </summary>
    /// <returns>
    ///   True for an <c>ETestFailureStrCompare</c> failure.
    /// </returns>
    function GetIsComparable : boolean;
    /// <summary>
    ///   Gives the expected value of a string-comparison failure.
    /// </summary>
    /// <returns>
    ///   The expected text, empty when the failure is not comparable.
    /// </returns>
    function GetExpected : string;
    /// <summary>
    ///   Gives the actual value of a string-comparison failure.
    /// </summary>
    /// <returns>
    ///   The actual text, empty when the failure is not comparable.
    /// </returns>
    function GetActual : string;
    /// <summary>
    ///   Gives the format class for displaying a comparison failure.
    /// </summary>
    /// <returns>
    ///   The format class, nil when the failure is not comparable.
    /// </returns>
    function GetFormat : TDUnitXComparableFormatClass;
  public
    /// <summary>
    ///   Creates the result from the exception that ended a test, capturing its class, message, address and, when a
    ///   stack-trace provider is registered, its stack trace.
    /// </summary>
    /// <param name="ATestInfo">
    ///   The test the result belongs to; held weakly.
    /// </param>
    /// <param name="AType">
    ///   The outcome, normally <c>Failure</c> or <c>Error</c>.
    /// </param>
    /// <param name="AThrownException">
    ///   The exception that ended the test.
    /// </param>
    /// <param name="Addrs">
    ///   The address the exception was raised at.
    /// </param>
    /// <param name="AMessage">
    ///   The user-facing message.
    /// </param>
    /// <param name="AMessageExList">
    ///   Messages the test logged while it ran.
    /// </param>
    constructor Create(const ATestInfo : ITestInfo; const AType : TTestResultType; const AThrownException : Exception; const Addrs : Pointer;
                       const AMessage : string; const AMessageExList : TLogMessageArray); reintroduce;
  end;

implementation

uses
  DUnitX.ServiceLocator;

constructor TDUnitXTestResult.Create(const ATestInfo : ITestInfo; const AType : TTestResultType; const AMessage : string; const ALogMessages :
  TLogMessageArray);
begin
  FTest := TWeakReference<ITestInfo>.Create(ATestInfo);
  FResultType := AType;
  FMessage := AMessage;
  FLogMessages := ALogMessages;
end;

function TDUnitXTestResult.GetMessage : string;
begin
  result := FMessage;
end;

function TDUnitXTestResult.GetLogMessages : TLogMessageArray;
begin
  result := FLogMessages;
end;

function TDUnitXTestResult.GetResult : Boolean;
begin
  result := GetResultType = TTestResultType.Pass;
end;

function TDUnitXTestResult.GetResultType : TTestResultType;
begin
  result := FResultType;
end;

function TDUnitXTestResult.GetTest : ITestInfo;
begin
  if FTest.IsAlive then
    result := FTest.Data
  else
    result := nil;
end;

constructor TDUnitXTestResult.Create(const ATestInfo : ITestInfo; const AType : TTestResultType; const AMessage : string);
var
  LogMessages : TLogMessageArray;
begin
  SetLength(LogMessages, 0);
  Create(ATestInfo, AType, AMessage, LogMessages);
end;

destructor TDUnitXTestResult.Destroy;
begin
  FTest := nil;                         //trying to track down memory leak.
  inherited;
end;

function TDUnitXTestResult.GetDuration : TTimeSpan;
begin
  if FTest.IsAlive then
    Result := FTest.Data.GetTestDuration
  else
    Result := TTimeSpan.Zero;
end;

function TDUnitXTestResult.GetFinishTime : TDateTime;
begin
  if FTest.IsAlive then
    Result := FTest.Data.GetTestEndTime
  else
    Result := 0;
end;

function TDUnitXTestResult.GetStackTrace : string;
begin
  result := FStackTrace;
end;

function TDUnitXTestResult.GetStartTime : TDateTime;
begin
  if FTest.IsAlive then
    Result := FTest.Data.GetTestStartTime
  else
    Result := 0;
end;

{ TDUnitXTestError }

constructor TDUnitXTestError.Create(const ATestInfo : ITestInfo; const AType : TTestResultType; const AThrownException : Exception; const Addrs : Pointer; const
  AMessage : string; const AMessageExList : TLogMessageArray);
{$IFDEF DELPHI_XE_UP}
var
  stackTraceProvider : IStacktraceProvider;
{$ENDIF}
var
  StrCompareEx : ETestFailureStrCompare;
begin
  inherited Create(ATestInfo, AType, AMessage, AMessageExList);

  FExceptionClass := ExceptClass(AThrownException.ClassType);

  FExceptionMessage := FMessage;
  //The two are separated: they were run together into one line.
  if FMessage <> AThrownException.Message then
  begin
    if (FExceptionMessage <> '') and (AThrownException.Message <> '') then
      FExceptionMessage := FExceptionMessage + sLineBreak;
    FExceptionMessage := FExceptionMessage + AThrownException.Message;
  end;
  FExceptionAddress := Addrs;

  //A descendant of ETestFailureStrCompare carries expected and actual too.
  if AThrownException is ETestFailureStrCompare then
  begin
    StrCompareEx := AThrownException as ETestFailureStrCompare;
    FIsComparable := True;
    FExpected := StrCompareEx.Expected;
    FActual := StrCompareEx.Actual;
    FFormat := StrCompareEx.Format;
  end
  else
    FIsComparable := False;

{$IFDEF DELPHI_XE_UP}
  stackTraceProvider := TDUnitXServiceLocator.DefaultContainer.Resolve<IStacktraceProvider>();

  if stackTraceProvider <> nil then
    FStackTrace := stackTraceProvider.GetStackTrace(AThrownException, Addrs);
{$ENDIF}
end;

function TDUnitXTestError.GetActual : string;
begin
  Result := FActual;
end;

function TDUnitXTestError.GetExceptionAddress : Pointer;
begin
  Result := FExceptionAddress;
end;

function TDUnitXTestError.GetExceptionAddressInfo : string;
{$IFDEF DELPHI_XE_UP}
var
  stackTraceProvider : IStacktraceProvider;
{$ENDIF}
begin
{$IFDEF DELPHI_XE_UP}
  stackTraceProvider := TDUnitXServiceLocator.DefaultContainer.Resolve<IStacktraceProvider>();
  if stackTraceProvider <> nil then
    Result := stackTraceProvider.PointerToAddressInfo(FExceptionAddress)
  else
{$ENDIF}
    Result := '';
end;

function TDUnitXTestError.GetExceptionClass : ExceptClass;
begin
  result := FExceptionClass;
end;

function TDUnitXTestError.GetExceptionLocationInfo : string;
{$IFDEF DELPHI_XE_UP}
var
  stackTraceProvider : IStacktraceProvider;
{$ENDIF}
begin
{$IFDEF DELPHI_XE_UP}
  stackTraceProvider := TDUnitXServiceLocator.DefaultContainer.Resolve<IStacktraceProvider>();
  if stackTraceProvider <> nil then
    Result := stackTraceProvider.PointerToLocationInfo(FExceptionAddress)
  else
{$ENDIF}
    Result := '';
end;

function TDUnitXTestError.GetExceptionMessage : string;
begin
  Result := FExceptionMessage;
end;

function TDUnitXTestError.GetExpected : string;
begin
  Result := FExpected;
end;

function TDUnitXTestError.GetFormat : TDUnitXComparableFormatClass;
begin
  Result := FFormat;
end;

function TDUnitXTestError.GetIsComparable : boolean;
begin
  Result := FIsComparable;
end;

end.

