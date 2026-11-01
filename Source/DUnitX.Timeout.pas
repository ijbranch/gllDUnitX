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
  ///   Enforces a test's [MaxTime] two ways: a watchdog thread interrupts a test that is still running when the time
  ///   is up, so a test that never returns fails and the run continues; and a stopwatch read the moment the test
  ///   returns catches an overrun the watchdog's 20 ms poll missed.
  /// </summary>
  /// <remarks>
  ///   <para>
  ///     The watchdog suspends the test thread and rewrites its context so that it raises ETimedOut where it stands.
  ///     On Win32 the thread is sent to a procedure that raises: Win32 exception handling follows a chain of frames
  ///     on the stack, so it unwinds from anywhere.
  ///   </para>
  ///   <para>
  ///     On Win64 that cannot work. Unwinding is driven from the unwind tables and needs a return address and a stack
  ///     aligned for a call, and a thread stopped inside a system call has neither (measured: it crashed in ntdll).
  ///     Instead the interrupted address is pushed as a return address and the thread is sent to a page that can
  ///     never be executed, so it faults as if it had called that page from where it stood. Windows unwinds from a
  ///     fault, and chained ExceptObjProc and ExceptClsProc report that fault as ETimedOut. A debugger stops on it as
  ///     a first-chance access violation.
  ///   </para>
  ///   <para>
  ///     A thread blocked in the kernel only reaches the redirect when its call returns, so the watchdog also queues
  ///     a no-op APC, which ends an alertable wait (a blocking Winsock call waits alertably), and calls
  ///     CancelSynchronousIo, which ends a synchronous read or write. Nothing ends a wait that never ends and is not
  ///     alertable, such as Sleep(INFINITE).
  ///   </para>
  ///   <para>
  ///     Until the test stops it, the watchdog interrupts again every second: a test that caught the interruption
  ///     and then hung somewhere else (a close that blocks too) is stopped again. A test that catches every
  ///     interruption and retries forever is never stopped.
  ///   </para>
  ///   <para>
  ///     The test is interrupted wherever it is, so a lock it holds then (the memory manager's included) stays
  ///     taken, which can hang the run, the interrupted test included (raising ETimedOut allocates): measured, about
  ///     half the time for a test interrupted while allocating in a loop. Upstream's Win32 watchdog has always had
  ///     this risk. On Win64 a thread stopped in assembler that moved the stack without unwind data cannot be
  ///     unwound, and the process ends.
  ///   </para>
  /// </remarks>
  ITimeout = interface(IUnknown)
    ['{0A380F7B-9CEE-4FD7-9D86-60CE05B97C1A}']
    /// <summary>
    ///   Stops timing; once it returns, the watchdog can no longer interrupt the test. Safe to call more than once.
    /// </summary>
    procedure Stop;
    /// <summary>
    ///   True when the watchdog interrupted the test, or more than the allowed time elapsed before timing was
    ///   stopped.
    /// </summary>
    /// <returns>Whether the test ran past its [MaxTime].</returns>
    function TimedOut : boolean;
    /// <summary>
    ///   True when the watchdog redirected the test thread to raise ETimedOut at least once; False when it never
    ///   fired, or fired but could not redirect the thread.
    /// </summary>
    /// <returns>Whether the test was interrupted.</returns>
    function Interrupted : boolean;
    /// <summary>Raises ETimedOut when <see cref="TimedOut" /> is True, otherwise does nothing.</summary>
    /// <exception cref="ETimedOut">
    ///   The test was interrupted, or the elapsed time exceeded the permitted duration.
    /// </exception>
    procedure RaiseIfTimedOut;
  end;

/// <summary>
///   Starts timing the calling thread, allowing ATime milliseconds before the watchdog interrupts it.
/// </summary>
/// <param name="ATime">The permitted duration, in milliseconds.</param>
/// <returns>The timer, already running.</returns>
function InitialiseTimeout(const ATime : cardinal) : ITimeout;

implementation

uses
  Winapi.Windows,
  System.Classes,
  System.Diagnostics,
  System.SysUtils,
  DUnitX.ResStrs,
  DUnitX.TestFramework,
  DUnitX.Exceptions;

const
  TIMEOUT_RUNNING = 0;
  TIMEOUT_STOPPED = 1;
  //How long after an interruption the watchdog interrupts again, if the test has not stopped the timeout by then.
  REINTERRUPT_INTERVAL = 1000;

type
  PTimeoutContext = ^_CONTEXT;

  //Waits out the [MaxTime] and then interrupts the test thread, again every REINTERRUPT_INTERVAL, until the test stops
  //the timeout.
  TTimeoutThread = class(TThread)
  private
    procedure Interrupt;
    procedure WaitUntil(const AStopwatch : TStopwatch; const AElapsed : Int64);
  protected
    procedure Execute; override;
  public
    //The test thread, duplicated; owned and closed by TTimeout.
    ThreadHandle : THandle;
    Timeout : Cardinal;
    //TIMEOUT_RUNNING until the test stops the timeout.  Only the test thread changes it, and the watchdog reads it only
    //while that thread is suspended, so the test cannot stop the timeout while an interruption is decided.
    State : Integer;
    //Set before the test thread is resumed, once it has been redirected to raise ETimedOut.
    Interrupted : Boolean;
  end;

  TTimeout = class(TInterfacedObject, ITimeout)
  private
    FTimeout : Cardinal;
    FStopwatch : TStopwatch;
    FThreadHandle : THandle;
    FWatchdog : TTimeoutThread;
    FStarted : Boolean;
    procedure Start;
  public
    constructor Create(const ATimeout : Cardinal; const AThreadHandle : THandle);
    destructor Destroy; override;

    procedure Stop;
    function TimedOut : boolean;
    function Interrupted : boolean;
    procedure RaiseIfTimedOut;
  end;

{$IFDEF CPUX64}
var
  //A page that can never be executed: the Win64 watchdog sends the test thread here, to fault.  nil if it could not be
  //allocated, when a Win64 test is not interrupted (the stopwatch still fails it once it returns).
  GTimeoutFaultAddress : Pointer;
  GPreviousExceptObjProc : Pointer;
  GPreviousExceptClsProc : Pointer;
{$ENDIF}

function InitialiseTimeout(const ATime : cardinal) : ITimeout;
var
  threadHandle : THandle;
  timeout : TTimeout;
begin
  if not DuplicateHandle(GetCurrentProcess, GetCurrentThread, GetCurrentProcess, @threadHandle, 0, False,
    DUPLICATE_SAME_ACCESS) then
    RaiseLastOSError;
  //Owns the handle from here: if the constructor fails, its destructor closes it.
  timeout := TTimeout.Create(ATime, threadHandle);
  Result := timeout;
  //Only now: had it fired before Result was set, nothing would have freed the timeout.
  timeout.Start;
end;

{$IFDEF CPUX86}
procedure RaiseTimeOutException;
begin
  raise ETimedOut.Create(SOperationTimedOut);
end;
{$ENDIF}

{$IFDEF CPUX64}
//Reports the fault at GTimeoutFaultAddress as ETimedOut; every other exception is mapped as before.
function TimeoutExceptObjProc(P : PExceptionRecord) : Pointer;
begin
  if P^.ExceptionAddress = GTimeoutFaultAddress then
    Result := ETimedOut.Create(SOperationTimedOut)
  else if GPreviousExceptObjProc <> nil then
    Result := TExceptObjProc(GPreviousExceptObjProc)(P)
  else
    Result := nil;
end;

//The class the RTL matches "on E : ETimedOut do" against.
function TimeoutExceptClsProc(P : PExceptionRecord) : Pointer;
begin
  if P^.ExceptionAddress = GTimeoutFaultAddress then
    Result := ETimedOut
  else if GPreviousExceptClsProc <> nil then
    Result := TExceptClsProc(GPreviousExceptClsProc)(P)
  else
    Result := nil;
end;

//True if the thread's stack can take the return address at AAddress (it is not, say, in the guard page).
function StackSlotWritable(const AAddress : NativeUInt) : Boolean;
var
  memoryInfo : TMemoryBasicInformation;
begin
  Result := (VirtualQuery(Pointer(AAddress), memoryInfo, SizeOf(memoryInfo)) = SizeOf(memoryInfo)) and
    (memoryInfo.State = MEM_COMMIT) and (memoryInfo.Protect and PAGE_GUARD = 0) and
    (memoryInfo.Protect and (PAGE_READWRITE or PAGE_EXECUTE_READWRITE) <> 0);
end;
{$ENDIF}

//Queued to the timed-out thread so that an alertable wait it is blocked in ends.
procedure WakeAlertableWait(AParam : ULONG_PTR); stdcall;
begin
end;

{ TTimeoutThread }

procedure TTimeoutThread.Execute;
var
  stopwatch : TStopwatch;
  nextInterrupt : Int64;
begin
  stopwatch := TStopwatch.StartNew;
  nextInterrupt := Timeout;
  WaitUntil(stopwatch, nextInterrupt);
  //Until the test stops the timeout: an interruption it caught does not stop it.
  while not Terminated do
  begin
    Interrupt;
    Inc(nextInterrupt, REINTERRUPT_INTERVAL);
    WaitUntil(stopwatch, nextInterrupt);
  end;
end;

//Returns once AStopwatch reads AElapsed milliseconds, or as soon as the test stops the timeout.
procedure TTimeoutThread.WaitUntil(const AStopwatch : TStopwatch; const AElapsed : Int64);
begin
  while not Terminated and (AStopwatch.ElapsedMilliseconds < AElapsed) do
    //Give some time back to the system to process the test.
    Sleep(20);
end;

procedure TTimeoutThread.Interrupt;
var
  //GetThreadContext needs the context 16-byte aligned on Win64.
  contextBuffer : array [0 .. SizeOf(_CONTEXT) + 15] of Byte;
  context : PTimeoutContext;
begin
  context := PTimeoutContext((NativeUInt(@contextBuffer) + 15) and not NativeUInt(15));
  if SuspendThread(ThreadHandle) = Cardinal(-1) then
    Exit;
  try
    context^.ContextFlags := CONTEXT_FULL;
    //Also waits until the thread is actually suspended, so it cannot stop the timeout while State is checked below.
    if not GetThreadContext(ThreadHandle, context^) then
      Exit;
    //If the test stopped the timeout first, it finished: leave it alone.  (A fenced read.)
    if InterlockedCompareExchange(State, TIMEOUT_RUNNING, TIMEOUT_RUNNING) <> TIMEOUT_RUNNING then
      Exit;
{$IFDEF CPUX86}
    context^.Eip := Cardinal(@RaiseTimeOutException);
{$ENDIF}
{$IFDEF CPUX64}
    if (GTimeoutFaultAddress = nil) or not StackSlotWritable(context^.Rsp - SizeOf(NativeUInt)) then
      Exit;
    context^.Rsp := context^.Rsp - SizeOf(NativeUInt);
    PNativeUInt(context^.Rsp)^ := context^.Rip;
    context^.Rip := NativeUInt(GTimeoutFaultAddress);
{$ENDIF}
    if not SetThreadContext(ThreadHandle, context^) then
      Exit;
    Interrupted := True;
    //Queued while the thread is still suspended, so only a wait it is already in is ended.
    QueueUserAPC(@WakeAlertableWait, ThreadHandle, 0);
  finally
    ResumeThread(ThreadHandle);
  end;
  //Reached only once the thread is redirected (every Exit above skips it).  CancelSynchronousIo waits for the call to
  //end, so the thread must be running (on a suspended thread it hangs).  It is called at once, so the read or write
  //ended is the one the thread was blocked in.
  CancelSynchronousIo(ThreadHandle);
end;

{ TTimeout }

constructor TTimeout.Create(const ATimeout : Cardinal; const AThreadHandle : THandle);
begin
  inherited Create;
  FTimeout := ATimeout;
  FThreadHandle := AThreadHandle;
  FWatchdog := TTimeoutThread.Create(True);
  FWatchdog.FreeOnTerminate := False;
  FWatchdog.ThreadHandle := AThreadHandle;
  FWatchdog.Timeout := ATimeout;
  FWatchdog.State := TIMEOUT_RUNNING;
  FStopwatch := TStopwatch.StartNew;
end;

destructor TTimeout.Destroy;
begin
  if FWatchdog <> nil then
  begin
    Stop;
    //A thread created suspended and never started would never end.
    if FStarted then
      FWatchdog.WaitFor;
    //Runs the wake-ups queued to this (the test's) thread if no alertable wait has, so that they cannot cut short one
    //in the next test.  Any other user APC already queued to the thread runs here too.
    if FWatchdog.Interrupted then
      SleepEx(0, True);
    FWatchdog.Free;
  end;
  if FThreadHandle <> 0 then
    CloseHandle(FThreadHandle);
  inherited;
end;

procedure TTimeout.Start;
begin
  FWatchdog.Start;
  FStarted := True;
end;

procedure TTimeout.Stop;
begin
  if FWatchdog = nil then
    Exit;
  InterlockedExchange(FWatchdog.State, TIMEOUT_STOPPED);
  FWatchdog.Terminate;
  FStopwatch.Stop;
end;

function TTimeout.TimedOut : boolean;
begin
  Result := Interrupted or (FStopwatch.ElapsedMilliseconds > FTimeout);
end;

function TTimeout.Interrupted : boolean;
begin
  Result := (FWatchdog <> nil) and FWatchdog.Interrupted;
end;

procedure TTimeout.RaiseIfTimedOut;
begin
  if TimedOut then
    raise ETimedOut.Create(SOperationTimedOut);
end;

{$IFDEF CPUX64}
initialization
  GTimeoutFaultAddress := VirtualAlloc(nil, 4096, MEM_COMMIT or MEM_RESERVE, PAGE_NOACCESS);
  if GTimeoutFaultAddress <> nil then
  begin
    GPreviousExceptObjProc := ExceptObjProc;
    ExceptObjProc := @TimeoutExceptObjProc;
    GPreviousExceptClsProc := ExceptClsProc;
    ExceptClsProc := @TimeoutExceptClsProc;
  end;

finalization
  if ExceptObjProc = @TimeoutExceptObjProc then
    ExceptObjProc := GPreviousExceptObjProc;
  if ExceptClsProc = @TimeoutExceptClsProc then
    ExceptClsProc := GPreviousExceptClsProc;
  if GTimeoutFaultAddress <> nil then
    VirtualFree(GTimeoutFaultAddress, 0, MEM_RELEASE);
{$ENDIF}

end.
