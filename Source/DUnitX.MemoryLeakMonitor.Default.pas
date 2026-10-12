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

unit DUnitX.MemoryLeakMonitor.Default;

interface

{$I DUnitX.inc}

uses
{$IFDEF USE_NS}
  System.Classes,
{$ELSE}
  Classes,
{$ENDIF}
  DUnitX.TestFramework;

type
  /// <summary>
  ///   The do-nothing memory leak monitor used when no memory-manager-specific monitor is registered: it takes no
  ///   measurements and always reports zero bytes allocated, so no test is ever reported as leaking.
  /// </summary>
  TDUnitXDefaultMemoryLeakMonitor = class(TInterfacedObject, IMemoryLeakMonitor)
  public
    /// <summary>Called before a test's setup runs. Does nothing.</summary>
    procedure PreSetup;
    /// <summary>Called after a test's setup has run. Does nothing.</summary>
    procedure PostSetUp;
    /// <summary>Called before a test method runs. Does nothing.</summary>
    procedure PreTest;
    /// <summary>Called after a test method has run. Does nothing.</summary>
    procedure PostTest;
    /// <summary>Called before a test's teardown runs. Does nothing.</summary>
    procedure PreTearDown;
    /// <summary>Called after a test's teardown has run. Does nothing.</summary>
    procedure PostTearDown;

    /// <summary>Reports the memory the setup left allocated.</summary>
    /// <returns>Always 0: this monitor does not measure.</returns>
    function SetUpMemoryAllocated : Int64;
    /// <summary>Reports the memory the teardown left allocated.</summary>
    /// <returns>Always 0: this monitor does not measure.</returns>
    function TearDownMemoryAllocated : Int64;
    /// <summary>Reports the memory the test method left allocated.</summary>
    /// <returns>Always 0: this monitor does not measure.</returns>
    function TestMemoryAllocated : Int64;
  end;

/// <summary>
///   Registers <c>TDUnitXDefaultMemoryLeakMonitor</c> as the <c>IMemoryLeakMonitor</c> implementation in the default
///   service locator container.
/// </summary>
procedure RegisterDefaultProvider;

implementation

uses
  DUnitX.ServiceLocator;

procedure RegisterDefaultProvider;
begin
  TDUnitXServiceLocator.DefaultContainer.RegisterType<IMemoryLeakMonitor, TDUnitXDefaultMemoryLeakMonitor>;
end;

{ TDUnitXDefaultMemoryLeakMonitor }

procedure TDUnitXDefaultMemoryLeakMonitor.PostSetUp;
begin

end;

procedure TDUnitXDefaultMemoryLeakMonitor.PostTearDown;
begin

end;

procedure TDUnitXDefaultMemoryLeakMonitor.PostTest;
begin

end;

procedure TDUnitXDefaultMemoryLeakMonitor.PreSetup;
begin

end;

procedure TDUnitXDefaultMemoryLeakMonitor.PreTearDown;
begin

end;

procedure TDUnitXDefaultMemoryLeakMonitor.PreTest;
begin

end;

function TDUnitXDefaultMemoryLeakMonitor.SetUpMemoryAllocated : Int64;
begin
  Result := 0;
end;

function TDUnitXDefaultMemoryLeakMonitor.TearDownMemoryAllocated : Int64;
begin
  Result := 0;
end;

function TDUnitXDefaultMemoryLeakMonitor.TestMemoryAllocated : Int64;
begin
  Result := 0;
end;

end.

