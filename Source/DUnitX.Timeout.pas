{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2017 Vincent Parrett & Contributors               }
{           Copyright (c) 2026 Ian Branch (GITLAK Software)                 }
{           CO-DEVELOPED: substantially reworked in the GITLAK fork.               }
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

unit DUnitX.Timeout;

interface

{$I DUnitX.inc}

uses
{$IFDEF USE_NS}
  System.Classes;
{$ELSE}
  Classes;
{$ENDIF}

type
  /// <summary>
  ///   Watches how long a test takes and records whether it ran past its
  ///   [MaxTime]. The verdict is reported once the test method returns.
  /// </summary>
  /// <remarks>
  ///   <para>
  ///     This previously suspended the test thread and rewrote its instruction
  ///     pointer so that it jumped into a raise. That cannot work on Win64.
  ///     The address was truncated to 32 bits, and Delphi 13 links binaries
  ///     with a preferred base above 4GB, so the rewritten instruction pointer
  ///     was always unmapped and the test thread faulted the moment it
  ///     resumed.
  ///   </para>
  ///   <para>
  ///     Correcting the truncation would not have been enough. An injected
  ///     frame pushes no return address and has no entry in the unwind tables
  ///     that x64 structured exception handling is driven from, so the raise
  ///     could not have unwound either. The x86 build only worked because its
  ///     exception chain lives on the stack.
  ///   </para>
  ///   <para>
  ///     [MaxTime] is an assertion about elapsed time, so it is now observed
  ///     and reported rather than injected. This is correct on every platform
  ///     and needs no operating system support. The one behavioural difference
  ///     is that it cannot interrupt a test that never returns.
  ///   </para>
  /// </remarks>
  ITimeout = interface(IUnknown)
    ['{0A380F7B-9CEE-4FD7-9D86-60CE05B97C1A}']
    /// <summary>Stops the watchdog. Safe to call more than once.</summary>
    procedure Stop;
    /// <summary>True when the allowed time elapsed before the watchdog was stopped.</summary>
    function TimedOut : boolean;
    /// <summary>Raises ETimedOut when the allowed time elapsed, otherwise does nothing.</summary>
    procedure RaiseIfTimedOut;
  end;

/// <summary>Starts a watchdog allowing ATime milliseconds.</summary>
/// <param name="ATime">The permitted duration, in milliseconds.</param>
/// <returns>The watchdog. Releasing it stops the underlying thread.</returns>
function InitialiseTimeout(const ATime : cardinal) : ITimeout;

implementation

uses
{$IFDEF USE_NS}
  System.SysUtils,
  System.SyncObjs,
  System.Diagnostics,
{$ELSE}
  SysUtils,
  SyncObjs,
  Diagnostics,
{$ENDIF}
  DUnitX.ResStrs,
  DUnitX.TestFramework,
  DUnitX.Exceptions;

type
  TTimeoutThread = class(TThread)
  private
    FTimeout  : Cardinal;
    FTimedOut : Integer;
    function GetTimedOut : boolean;
  protected
    procedure Execute; override;
  public
    constructor Create(const ATimeout : Cardinal);
    property TimedOut : boolean read GetTimedOut;
  end;

  TTimeout = class(TInterfacedObject, ITimeout)
  private
    FTimeoutThread : TTimeoutThread;
  public
    constructor Create(const ATimeout : Cardinal);
    destructor Destroy; override;

    procedure Stop;
    function TimedOut : boolean;
    procedure RaiseIfTimedOut;
  end;

function InitialiseTimeout(const ATime : cardinal) : ITimeout;
begin
  Result := TTimeout.Create(ATime);
end;

{ TTimeoutThread }

constructor TTimeoutThread.Create(const ATimeout : Cardinal);
begin
  inherited Create(true);
  FreeOnTerminate := false;
  FTimeout := ATimeout;
  FTimedOut := 0;
end;

function TTimeoutThread.GetTimedOut : boolean;
begin
  //Read through an interlocked compare so the test thread sees the flag reliably.
  Result := TInterlocked.CompareExchange(FTimedOut, 0, 0) <> 0;
end;

procedure TTimeoutThread.Execute;
var
  stopwatch : TStopWatch;
begin
  inherited;
  stopwatch := TStopWatch.Create;
  stopwatch.Reset;
  stopwatch.Start;

  while not Terminated do
  begin
    if stopwatch.ElapsedMilliseconds >= FTimeout then
    begin
      TInterlocked.Exchange(FTimedOut, 1);
      Break;
    end;

    //Give some time back to the system to process the test.
    Sleep(20);
  end;
end;

{ TTimeout }

constructor TTimeout.Create(const ATimeout : Cardinal);
begin
  inherited Create;
  FTimeoutThread := TTimeoutThread.Create(ATimeout);
  FTimeoutThread.Start;
end;

destructor TTimeout.Destroy;
begin
  Stop;
  FTimeoutThread.WaitFor;
  FTimeoutThread.Free;
  inherited;
end;

procedure TTimeout.Stop;
begin
  FTimeoutThread.Terminate;
end;

function TTimeout.TimedOut : boolean;
begin
  Result := FTimeoutThread.TimedOut;
end;

procedure TTimeout.RaiseIfTimedOut;
begin
  if TimedOut then
    raise ETimedOut.Create(SOperationTimedOut);
end;

end.
