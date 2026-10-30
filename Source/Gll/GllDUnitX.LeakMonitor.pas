(* GITLAK Software
  ***************************************************************************

    Copyright (C) 2026 Ian Branch (GITLAK Software).

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

  ***************************************************************************

  This code Unit is a GITLAK addition to the gllDUnitX fork ( not upstream ).

  ***************************************************************************

  Author(s) :
  Ian Branch - GITLAK Software.

  ***************************************************************************
  File last update : 2026-10-31 09:30:00 (UTC+11:00 DST)
  ***************************************************************************
*)

/// <summary>
///   Per-test memory-leak detection for a DUnitX suite: a FastMM5-backed <c>IMemoryLeakMonitor</c>, so DUnitX reports
///   every test, setup or teardown that leaves memory allocated as a <c>MemoryLeak</c> result naming the test.
/// </summary>
/// <remarks>
///   <para>
///     Shared by every GITLAK suite through <c>GllDUnitX.SuiteRunner.RunGllSuite</c>; compiled into each test exe as
///     source ( add <c>gllDUnitX\Source\Gll</c> to the test project's unit search path ), not into the gllDUnitX
///     package, because it needs FastMM5, which must be the test exe's own first unit.
///   </para>
///   <para>
///     Before every measurement <c>Settle</c> lets queued main-thread work, window messages, the RTL's
///     <c>TThreadPool.Default</c> and every check registered with <c>RegisterSettleCheck</c> ( OmniThreadLibrary's
///     pool, in a suite that uses it ) finish, so late clean-up is not charged to the wrong test.  Moved here from
///     GITLAKLibTests, where it was built and measured on 2026-10-22.
///   </para>
/// </remarks>
unit GllDUnitX.LeakMonitor;

interface

uses
  System.SysUtils;

/// <summary>
///   Keeps <see cref="POOL_WORKERS"/> workers alive for the whole run in the RTL's <c>TThreadPool.Default</c>, and
///   finds the RTL pool monitor's status field.  Call BEFORE the warm-up pass, so the workers it creates are the ones
///   the measured pass uses and none is created or retired inside a measured test.  A suite using another pool pins
///   that pool itself, also before the warm-up.
/// </summary>
procedure StartSharedThreadPools;

/// <summary>
///   Adds a check <c>Settle</c> waits on before every measurement: while it returns True, work is still pending.
///   Register at start-up, before the warm-up pass; e.g. <c>function: Boolean begin Result := not
///   GlobalParallelPool.IsIdle; end</c> for OmniThreadLibrary.
/// </summary>
/// <param name="AIsBusy">Returns True while work the check covers is still running; must not allocate memory.</param>
/// <exception cref="EInvalidOpException">More than <see cref="MAX_SETTLE_CHECKS"/> checks registered.</exception>
procedure RegisterSettleCheck( const AIsBusy: TFunc<Boolean> );

/// <summary>
///   Makes the FastMM5 monitor DUnitX's <c>IMemoryLeakMonitor</c>, replacing the do-nothing default.  Call after
///   the warm-up pass and before the measured runner is created; DUnitX resolves the monitor per test, so a
///   registration made later still takes effect for the tests that follow.
/// </summary>
/// <exception cref="EServiceLocatorRegistrationException">
///   A monitor instance has already been created as a singleton ( it is registered as a factory, so this does not
///   happen in practice ).
/// </exception>
procedure RegisterFastMM5LeakMonitor;

const
  /// <summary>
  ///   Workers kept for the whole run by the RTL's <c>TThreadPool.Default</c> ( <c>SetMinWorkerThreads</c>, kept once
  ///   created ).  Above every test's concurrent need, so a worker is never created, or retired after its idle
  ///   timeout and re-created, inside a measured test, which would charge that test kilobytes at random.
  /// </summary>
  POOL_WORKERS = 32;
  /// <summary>
  ///   Longest <c>Settle</c> waits for pending work to finish, in milliseconds.  A real hang shows as the test's own
  ///   timeout or failure; this only bounds the wait before a measurement.
  /// </summary>
  SETTLE_LIMIT_MS = 2000;
  /// <summary>
  ///   How long a test start waits, in milliseconds, for a just-restarted RTL pool monitor thread to finish its own
  ///   start-up allocations ( its debug name and handle registration ) before the baseline is taken.
  /// </summary>
  MONITOR_STARTUP_MS = 100;
  /// <summary>Most checks <see cref="RegisterSettleCheck"/> accepts; a fixed array, so settling allocates nothing.</summary>
  MAX_SETTLE_CHECKS = 8;

var
  /// <summary>
  ///   Measurements whose <c>Settle</c> gave up at <see cref="SETTLE_LIMIT_MS"/> with work still pending ( a task left
  ///   running ): each cost 2 s and measured work in progress.  An integer, so counting it allocates nothing; the
  ///   suite runner prints it at the end when it is not 0.
  /// </summary>
  SettleLimitHits: Integer = 0;

implementation

uses
  Winapi.Windows, System.Classes, System.Diagnostics, System.Threading, System.Rtti,
  DUnitX.TestFramework, DUnitX.ServiceLocator, FastMM5;

var
  /// <summary>
  ///   Byte offset of <c>TThreadPool.FMonitorThreadStatus</c> in <c>TThreadPool.Default</c>, found once through RTTI
  ///   by <c>StartSharedThreadPools</c> so each test start reads it with no allocation; -1 when RTTI did not find it
  ///   ( a later RTL ), which turns the monitor check off rather than guessing.
  /// </summary>
  GMonitorStatusOffset: Integer = -1;
  /// <summary>The checks registered with <c>RegisterSettleCheck</c>.</summary>
  GSettleChecks: array[ 0..MAX_SETTLE_CHECKS - 1 ] of TFunc<Boolean>;
  /// <summary>How many of <c>GSettleChecks</c> are in use.</summary>
  GSettleCheckCount: Integer = 0;

procedure RegisterSettleCheck( const AIsBusy: TFunc<Boolean> );
begin
  if GSettleCheckCount >= MAX_SETTLE_CHECKS then
    raise EInvalidOpException.CreateFmt( 'At most %d settle checks can be registered.', [ MAX_SETTLE_CHECKS ] );
  GSettleChecks[ GSettleCheckCount ] := AIsBusy;
  Inc( GSettleCheckCount );
end;

/// <summary>
///   Makes sure the RTL pool's monitor thread is running before a test's baseline is taken.
/// </summary>
/// <remarks>
///   The monitor retires after 30 s without a wake-up and the next queued task creates a new one, so its
///   allocations ( the thread object, its debug name, its handle registration ) landed in whichever concurrent test
///   ran next, at random.  Restarting it here, before the baseline, keeps those tests leak-checked.  The status is
///   read directly at <c>GMonitorStatusOffset</c>: bit 0 is <c>TMonitorThreadStat.Created</c>.
/// </remarks>
procedure EnsureRtlPoolMonitor;
begin
  if GMonitorStatusOffset < 0 then Exit;

  var pStatus       := PCardinal( PByte( TThreadPool.Default ) + GMonitorStatusOffset );

  if ( pStatus^ and 1 ) <> 0 then Exit;

  TTask.Run( procedure begin end ).Wait;

  var lWatch        := TStopwatch.StartNew;
  while ( ( pStatus^ and 1 ) = 0 ) and ( lWatch.ElapsedMilliseconds < SETTLE_LIMIT_MS ) do Sleep( 1 );

  Sleep( MONITOR_STARTUP_MS );
end;

/// <summary>Dispatches every window message waiting for this thread.  Win32 calls, so no VCL is linked.</summary>
/// <returns>True when at least one message was dispatched.</returns>
function PumpMessages: Boolean;
var
  lMsg              : TMsg;
begin
  Result            := False;
  while PeekMessage( lMsg, 0, 0, 0, PM_REMOVE ) do
  begin
    Result          := True;
    TranslateMessage( lMsg );
    DispatchMessage( lMsg );
  end;
end;

/// <summary>
///   Lets asynchronous work the test started finish before memory is measured: runs queued main-thread calls and
///   window messages until the RTL pool and every registered check are idle and a pass runs nothing, or
///   <see cref="SETTLE_LIMIT_MS"/> elapses.
/// </summary>
/// <remarks>
///   Without it a test is charged for clean-up that is merely late ( a pipeline's tasks released by queued messages
///   after the test returns, a TTask still releasing its closure ), and the next test is credited with it, so counts
///   change from run to run.  It only lets already-queued work run: memory nothing will free is still reported.
/// </remarks>
procedure Settle;
begin
  var lWatch        := TStopwatch.StartNew;
  var iQuietPasses  := 0;
  while ( iQuietPasses < 2 ) and ( lWatch.ElapsedMilliseconds < SETTLE_LIMIT_MS ) do
  begin
    var bRan        := CheckSynchronize( 0 );
    if PumpMessages then bRan := True;
    // The RTL pool ( TTask / TParallel ): a test that waits only for its task's effect returns while the task is
    // still finishing, and the task then releases its closure after the measurement.  A record, no allocation.
    var lRtl        := TThreadPoolStats.Get( TThreadPool.Default );
    var bBusy       := ( lRtl.QueuedRequestCount > 0 ) or ( lRtl.IdleWorkerThreadCount < lRtl.WorkerThreadCount );
    for var i := 0 to GSettleCheckCount - 1 do
      if ( not bBusy ) and GSettleChecks[ i ]( ) then bBusy := True;
    if bRan or bBusy then
    begin
      iQuietPasses  := 0;
      Sleep( 1 );
    end
    else
      Inc( iQuietPasses );
  end;
  if iQuietPasses < 2 then Inc( SettleLimitHits );
end;

type
  /// <summary>Measures the bytes FastMM5 has allocated before and after each setup, test and teardown.</summary>
  TFastMM5LeakMonitor = class( TInterfacedObject, IMemoryLeakMonitor )
  private
    /// <summary>Allocated bytes before the setup.</summary>
    FPreSetUp: Int64;
    /// <summary>Allocated bytes after the setup.</summary>
    FPostSetUp: Int64;
    /// <summary>Allocated bytes before the test method.</summary>
    FPreTest: Int64;
    /// <summary>Allocated bytes after the test method.</summary>
    FPostTest: Int64;
    /// <summary>Allocated bytes before the teardown.</summary>
    FPreTearDown: Int64;
    /// <summary>Allocated bytes after the teardown.</summary>
    FPostTearDown: Int64;
    /// <summary>
    ///   Bytes FastMM5 has allocated now, once pending asynchronous work has settled ( <c>Settle</c> ) and FastMM5's
    ///   pending frees are released, so neither late clean-up nor deferred frees are counted.
    /// </summary>
    /// <returns>The allocated byte count.</returns>
    class function Allocated: Int64; static;
  public
    /// <summary>Records the allocation before the setup.</summary>
    procedure PreSetup;
    /// <summary>Records the allocation after the setup.</summary>
    procedure PostSetUp;
    /// <summary>Records the allocation before the test method.</summary>
    procedure PreTest;
    /// <summary>Records the allocation after the test method.</summary>
    procedure PostTest;
    /// <summary>Records the allocation before the teardown.</summary>
    procedure PreTearDown;
    /// <summary>Records the allocation after the teardown.</summary>
    procedure PostTearDown;
    /// <summary>Net bytes the setup left allocated.</summary>
    /// <returns>Post-setup minus pre-setup.</returns>
    function SetUpMemoryAllocated: Int64;
    /// <summary>Net bytes the test method left allocated.</summary>
    /// <returns>Post-test minus pre-test.</returns>
    function TestMemoryAllocated: Int64;
    /// <summary>Net bytes the teardown left allocated ( usually negative: it frees what setup made ).</summary>
    /// <returns>Post-teardown minus pre-teardown.</returns>
    function TearDownMemoryAllocated: Int64;
  end;

class function TFastMM5LeakMonitor.Allocated: Int64;
begin
  Settle;
  FastMM_ProcessAllPendingFrees;
  Result := FastMM_GetUsageSummary.AllocatedBytes;
end;

procedure TFastMM5LeakMonitor.PreSetup;
begin
  EnsureRtlPoolMonitor;
  FPreSetUp := Allocated;
end;

procedure TFastMM5LeakMonitor.PostSetUp;
begin
  FPostSetUp := Allocated;
end;

procedure TFastMM5LeakMonitor.PreTest;
begin
  EnsureRtlPoolMonitor;
  FPreTest := Allocated;
end;

procedure TFastMM5LeakMonitor.PostTest;
begin
  FPostTest := Allocated;
end;

procedure TFastMM5LeakMonitor.PreTearDown;
begin
  FPreTearDown := Allocated;
end;

procedure TFastMM5LeakMonitor.PostTearDown;
begin
  FPostTearDown := Allocated;
end;

function TFastMM5LeakMonitor.SetUpMemoryAllocated: Int64;
begin
  Result := FPostSetUp - FPreSetUp;
end;

function TFastMM5LeakMonitor.TestMemoryAllocated: Int64;
begin
  Result := FPostTest - FPreTest;
end;

function TFastMM5LeakMonitor.TearDownMemoryAllocated: Int64;
begin
  Result := FPostTearDown - FPreTearDown;
end;

procedure StartSharedThreadPools;
begin
  // Process-lifetime: the RTL pool keeps the workers it creates, so the warm-up pass creates them and none retires
  // and is re-created inside a test.
  TThreadPool.Default.SetMinWorkerThreads( POOL_WORKERS );

  // Found once, here, so the per-test check allocates nothing.  The set is 4 bytes ( ForceSize = 31 ).
  var lContext      := TRttiContext.Create;
  var lField        := lContext.GetType( TThreadPool ).GetField( 'FMonitorThreadStatus' );
  // Bit 0 is read as Created, so the set's element type must start with it; a later RTL that reorders it turns the
  // check off rather than reading the wrong bit
  if Assigned( lField ) and ( lField.FieldType.TypeSize = SizeOf( Cardinal ) ) and ( lField.FieldType is TRttiSetType )
    and ( TRttiSetType( lField.FieldType ).ElementType is TRttiEnumerationType )
    and SameText( TRttiEnumerationType( TRttiSetType( lField.FieldType ).ElementType ).GetNames[ 0 ], 'Created' ) then
    GMonitorStatusOffset := lField.Offset;
end;

procedure RegisterFastMM5LeakMonitor;
begin
  TDUnitXServiceLocator.DefaultContainer.RegisterType<IMemoryLeakMonitor>(
    function: IMemoryLeakMonitor
    begin
      Result := TFastMM5LeakMonitor.Create;
    end );
end;

end.
