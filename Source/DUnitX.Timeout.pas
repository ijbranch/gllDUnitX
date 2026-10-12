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
  ///   <para>
  ///     The test body is timed on its own thread with a stopwatch started
  ///     immediately before the method and read immediately after it. A
  ///     watchdog thread polling every 20 ms used to do this, and missed an
  ///     overrun that ended between two polls.
  ///   </para>
  /// </remarks>
  ITimeout = interface(IUnknown)
    ['{0A380F7B-9CEE-4FD7-9D86-60CE05B97C1A}']
    /// <summary>Stops timing. Safe to call more than once.</summary>
    procedure Stop;
    /// <summary>True when more than the allowed time elapsed before timing was stopped.</summary>
    function TimedOut : boolean;
    /// <summary>Raises ETimedOut when more than the allowed time elapsed, otherwise does nothing.</summary>
    procedure RaiseIfTimedOut;
  end;

/// <summary>Starts timing, allowing ATime milliseconds.</summary>
/// <param name="ATime">The permitted duration, in milliseconds.</param>
/// <returns>The timer, already running.</returns>
function InitialiseTimeout(const ATime : cardinal) : ITimeout;

implementation

uses
{$IFDEF USE_NS}
  System.Diagnostics,
{$ELSE}
  Diagnostics,
{$ENDIF}
  DUnitX.ResStrs,
  DUnitX.TestFramework,
  DUnitX.Exceptions;

type
  TTimeout = class(TInterfacedObject, ITimeout)
  private
    FTimeout : Cardinal;
    FStopwatch : TStopwatch;
  public
    constructor Create(const ATimeout : Cardinal);

    procedure Stop;
    function TimedOut : boolean;
    procedure RaiseIfTimedOut;
  end;

function InitialiseTimeout(const ATime : cardinal) : ITimeout;
begin
  Result := TTimeout.Create(ATime);
end;

{ TTimeout }

constructor TTimeout.Create(const ATimeout : Cardinal);
begin
  inherited Create;
  FTimeout := ATimeout;
  FStopwatch := TStopwatch.StartNew;
end;

procedure TTimeout.Stop;
begin
  FStopwatch.Stop;
end;

function TTimeout.TimedOut : boolean;
begin
  Result := FStopwatch.ElapsedMilliseconds > FTimeout;
end;

procedure TTimeout.RaiseIfTimedOut;
begin
  if TimedOut then
    raise ETimedOut.Create(SOperationTimedOut);
end;

end.
