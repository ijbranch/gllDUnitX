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

unit DUnitX.StackTrace.JCL;

interface

{$I DUnitX.inc}

uses
{$IFDEF USE_NS}
  System.SysUtils,
  System.Classes,
{$ELSE}
  SysUtils,
  Classes,
{$ENDIF}
{$IFDEF USE_JCL}
  JclDebug,
{$ENDIF}
  DUnitX.TestFramework;

type
  /// <summary>
  ///   Stack trace provider backed by the JEDI Code Library's <c>JclDebug</c>. It is registered as the
  ///   <c>IStacktraceProvider</c> only when <c>USE_JCL</c> is defined; without it every method returns an empty string.
  /// </summary>
  TJCLStackTraceProvider = class(TInterfacedObject, IStacktraceProvider)
  protected
    /// <summary>
    ///   Returns the stack JCL captured for the most recent exception (<c>JclLastExceptStackListToStrings</c>).
    /// </summary>
    /// <param name="ex">
    ///   The exception being reported (not used: JCL supplies its last recorded exception stack).
    /// </param>
    /// <param name="exAddressAddress">
    ///   The address at which the exception was raised (not used by this provider).
    /// </param>
    /// <returns>
    ///   The call stack, one frame per line, or an empty string when JCL support is not compiled in.
    /// </returns>
    function GetStackTrace(const ex : Exception; const exAddressAddress : Pointer) : string;
    /// <summary>
    ///   Resolves a code address to <c>file:line</c> from the map information, falling back to the module name when
    ///   no source file is known. Borrowed from DUnit.
    /// </summary>
    /// <param name="Addrs">
    ///   The code address to resolve.
    /// </param>
    /// <returns>
    ///   The location text, or an empty string when JCL support is not compiled in.
    /// </returns>
    function PointerToLocationInfo(const Addrs : Pointer) : string;
    /// <summary>
    ///   Resolves a code address to its procedure name followed by the address in hex (<c>Proc$Address</c>).
    /// </summary>
    /// <param name="Addrs">
    ///   The code address to resolve.
    /// </param>
    /// <returns>
    ///   The address text, or an empty string when JCL support is not compiled in.
    /// </returns>
    function PointerToAddressInfo(Addrs : Pointer) : string;
  end;

implementation

uses
  DUnitX.ServiceLocator;

{ TJCLStackTraceProvider }

function TJCLStackTraceProvider.GetStackTrace(const ex : Exception; const exAddressAddress : Pointer) : string;
{$IFDEF USE_JCL}
var
  traceList : TStrings;
{$ENDIF}
begin
  result := '';
{$IFDEF USE_JCL}
  traceList := TStringList.Create;
  try
    JclDebug.JclLastExceptStackListToStrings(traceList, true);
    Result := traceList.Text;
  finally
    traceList.Free;
  end;
{$ENDIF}
end;

function TJCLStackTraceProvider.PointerToAddressInfo(Addrs : Pointer) : string;
{$IFDEF USE_JCL}
var
  _file,
    _module,
    _proc : string;
  _line : integer;
{$ENDIF}
begin
  Result := '';
{$IFDEF USE_JCL}
  JclDebug.MapOfAddr(Addrs, _file, _module, _proc, _line);
  Result := Format('%s$%p', [_proc, Addrs]);
{$ENDIF}
end;

//Borrowed from DUnit.
function TJCLStackTraceProvider.PointerToLocationInfo(const Addrs : Pointer) : string;
{$IFDEF USE_JCL}
var
  _file,
    _module,
    _proc : string;
  _line : integer;
{$ENDIF}
begin
  Result := '';
{$IFDEF USE_JCL}
  JclDebug.MapOfAddr(Addrs, _file, _module, _proc, _line);

  if _file <> '' then
    Result := Format('%s:%d', [_file, _line])
  else
    Result := _module;
{$ENDIF}
end;

initialization
{$IFDEF USE_JCL}

{$IFDEF DELPHI_XE_UP}
  TDUnitXServiceLocator.DefaultContainer.RegisterType<IStacktraceProvider, TJCLStackTraceProvider>(true);
{$ELSE}
  //D2010 bug prevents using above method.
  TDUnitXServiceLocator.DefaultContainer.RegisterType<IStacktraceProvider>(true,
    function : IStacktraceProvider
    begin
      result := TJCLStackTraceProvider.Create;
    end
    );
{$ENDIF}
{$ENDIF}

end.

