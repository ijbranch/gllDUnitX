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

unit DUnitX.StackTrace.EurekaLog7;

interface

{$I DUnitX.inc}

uses
{$IFDEF USE_NS}
  System.Classes,
  System.SysUtils,
{$ELSE}
  Classes,
  SysUtils,
{$ENDIF}
{$IFDEF USE_EUREKALOG7}
  ECallStack,
  EDebugInfo,
{$ENDIF}
  DUnitX.TestFramework;

type
  /// <summary>
  ///   Stack trace provider backed by EurekaLog 7. It is registered as the <c>IStacktraceProvider</c> only when
  ///   <c>USE_EUREKALOG7</c> is defined; without it every method returns an empty string.
  /// </summary>
  TEurekaLog7StackTraceProvider = class(TInterfacedObject, IStacktraceProvider)
  public
    /// <summary>
    ///   Builds a textual call stack starting at the exception address, using EurekaLog's <c>TEurekaStackListV7</c>.
    /// </summary>
    /// <param name="ex">
    ///   The exception being reported (not used by this provider).
    /// </param>
    /// <param name="exAddressAddress">
    ///   The address at which the exception was raised; the stack walk starts there.
    /// </param>
    /// <returns>
    ///   The formatted call stack, or an empty string when EurekaLog support is not compiled in.
    /// </returns>
    function GetStackTrace(const ex : Exception; const exAddressAddress : Pointer) : string;
    /// <summary>
    ///   Resolves a code address to EurekaLog's location description (unit, routine and line).
    /// </summary>
    /// <param name="Addrs">
    ///   The code address to resolve.
    /// </param>
    /// <returns>
    ///   The location text, or an empty string when EurekaLog support is not compiled in.
    /// </returns>
    function PointerToLocationInfo(const Addrs : Pointer) : string;
    /// <summary>
    ///   Resolves a code address to descriptive text. This provider returns the same location text as
    ///   <c>PointerToLocationInfo</c>.
    /// </summary>
    /// <param name="Addrs">
    ///   The code address to resolve.
    /// </param>
    /// <returns>
    ///   The location text, or an empty string when EurekaLog support is not compiled in.
    /// </returns>
    function PointerToAddressInfo(Addrs : Pointer) : string;
  end;

implementation

uses
  DUnitX.ServiceLocator;

{ TEurekaLog7StackTraceProvider }

function TEurekaLog7StackTraceProvider.GetStackTrace(const ex : Exception; const exAddressAddress : Pointer) : string;
{$IFDEF USE_EUREKALOG7}
var
  LEurekaBaseStackList : TEurekaStackListV7;
{$ENDIF}
begin
  result := '';
{$IFDEF USE_EUREKALOG7}
  LEurekaBaseStackList := nil;
  try
    LEurekaBaseStackList := TEurekaStackListV7.Create(exAddressAddress);
    Result := LEurekaBaseStackList.ToString;
  finally
    LEurekaBaseStackList.Free;
  end;
{$ENDIF}
end;

function TEurekaLog7StackTraceProvider.PointerToAddressInfo(Addrs : Pointer) : string;
begin
{$IFDEF USE_EUREKALOG7}
  Result := GetLocationInfoStr(Addrs);
{$ELSE}
  Result := '';
{$ENDIF}
end;

function TEurekaLog7StackTraceProvider.PointerToLocationInfo(const Addrs : Pointer) : string;
begin
{$IFDEF USE_EUREKALOG7}
  Result := GetLocationInfoStr(Addrs);
{$ELSE}
  Result := '';
{$ENDIF}
end;

initialization
{$IFDEF USE_EUREKALOG7}

{$IFDEF DELPHI_XE_UP}
  TDUnitXServiceLocator.DefaultContainer.RegisterType<IStacktraceProvider, TEurekaLog7StackTraceProvider>(true);
{$ELSE}
  //D2010 bug prevents using above method.
  TDUnitXServiceLocator.DefaultContainer.RegisterType<IStacktraceProvider>(true,
    function : IStacktraceProvider
    begin
      result := TEurekaLog7StackTraceProvider.Create;
    end
    );
{$ENDIF}
{$ENDIF}

end.

