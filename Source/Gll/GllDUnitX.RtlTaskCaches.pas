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
  File last update : 2026-11-28 05:15:00 (UTC+11:00 DST)
  ***************************************************************************
*)

/// <summary>
///   Fills the RTL's caches of task objects and of <c>TMonitor</c> wait objects, so a measured test never grows one.
/// </summary>
/// <remarks>
///   <para>
///     <c>System.Threading</c> keeps up to <c>TObjectCache.CObjectCacheLimit</c> + 1 freed instances of each task
///     class instead of freeing them ( <c>TThreadPool.TAbstractWorkerData.FreeInstance</c> ).  A cache grows only when
///     more instances are alive at once than ever before, so a test whose <c>TParallel.For</c> happened to reach a new
///     peak of concurrent tasks kept the extra instances and was charged them as a leak, at random: gllSynEdit's
///     <c>MaxWidthFindsTheLongestLine</c> failed in 2 of 3 runs on 2026-11-28, with 30 to 158 bytes.
///   </para>
///   <para>
///     <c>System.SysUtils</c> caches <c>TMonitor</c> wait objects the same way: each thread waiting on a monitor takes
///     one, and handing it back allocates a holder ( 16 bytes on Win64, 8 on Win32 ) whenever more threads have waited
///     at once than ever before.  The pool's idle workers wait on a monitor, so a parallel loop that woke more of them
///     than before was charged a holder a thread ( 30 to 180 bytes in 11 of 300 rounds of a probe, after the task caches were filled ).
///   </para>
///   <para>
///     A full task cache can still take one more instance, rarely: <c>TObjectCache.Insert</c> tests its count before it
///     pushes and counts after, so threads freeing at the same moment can each see room.  That needs a test with more
///     than 51 tasks of one class alive at once, and <c>GllDUnitX.LeakConfirm</c>'s re-run clears it.
///   </para>
///   <para>
///     RTL-only and free of FastMM5, so the self-test suite, which does not run under the leak monitor, can test it.
///     <c>TFuture&lt;T&gt;</c> has a cache per <c>T</c> and cannot be listed here: a suite that uses one fills it itself.
///   </para>
/// </remarks>
unit GllDUnitX.RtlTaskCaches;

interface

const
  /// <summary>
  ///   Qualified RTTI names of the RTL classes whose freed instances <c>TThreadPool</c> caches; the last three are
  ///   private types of <c>TParallel</c>, so they are found by name.
  /// </summary>
  RTL_CACHED_TASK_CLASSES: array[ 0..4 ] of string = (
    'System.Threading.TTask',
    'System.Threading.TThreadPool.TWorkerData',
    'System.Threading.TParallel.TReplicableTask',
    'System.Threading.TParallel.TReplicaTask',
    'System.Threading.TParallel.TJoinTask' );

  /// <summary>
  ///   <c>TMonitor</c> wait objects put in the cache at start-up: more than the threads a suite has waiting at once
  ///   ( the leak monitor's <c>POOL_WORKERS</c> pool workers and any beyond them ).  Each costs one
  ///   kernel event and a 16-byte holder ( 8 on Win32 ).
  /// </summary>
  RTL_WAIT_OBJECTS  = 256;

/// <summary>
///   Fills the cache of every class in <see cref="RTL_CACHED_TASK_CLASSES"/> to its limit.  Call once at start-up,
///   before the warm-up pass; after it, allocating and freeing task objects leaves the memory in use unchanged.
/// </summary>
/// <returns>
///   How many of the classes were found and filled.  A class the executable does not link is not found, and needs no
///   filling: nothing can allocate one.
/// </returns>
function FillRtlTaskCaches: Integer;

/// <summary>
///   Puts <paramref name="ACount"/> wait objects in the RTL's <c>TMonitor</c> wait-object cache.  Call once at start-up;
///   after it, up to that many threads waiting on monitors at once leave the memory in use unchanged.
/// </summary>
/// <param name="ACount">Wait objects to add; <see cref="RTL_WAIT_OBJECTS"/> for a test runner.</param>
procedure FillRtlWaitObjectCache( ACount: Integer );

implementation

uses
  System.Rtti, System.Threading;

function FillRtlTaskCaches: Integer;
const
  // Insert keeps an instance while the cache holds CObjectCacheLimit or fewer, so a full cache holds one more
  CInstances        = TObjectCache.CObjectCacheLimit + 1;
var
  aInstances        : array[ 0..CInstances - 1 ] of TObject;
begin
  Result            := 0;
  var lContext      := TRttiContext.Create;
  for var sName in RTL_CACHED_TASK_CLASSES do
  begin
    var lType       := lContext.FindType( sName );
    if not ( lType is TRttiInstanceType ) then Continue;
    var lClass      := TRttiInstanceType( lType ).MetaclassType;

    // Every instance alive at once takes what the cache holds and allocates the rest; freeing them all fills it.
    // NewInstance and FreeInstance alone are the classes' own cache path: no constructor or destructor runs, and
    // FreeInstance's CleanupInstance finalises only the zeroed fields InitInstance gave them.
    for var i := 0 to High( aInstances ) do aInstances[ i ] := lClass.NewInstance;
    for var i := 0 to High( aInstances ) do aInstances[ i ].FreeInstance;
    Inc( Result );
  end;
end;

procedure FillRtlWaitObjectCache( ACount: Integer );
begin
  // Taken all at once, each comes from the cache or is created; handed back, each lands in the cache with a holder.
  var aObjects      : TArray<Pointer>;
  SetLength( aObjects, ACount );
  for var i := 0 to High( aObjects ) do aObjects[ i ] := System.MonitorSupport.NewWaitObject;
  for var i := 0 to High( aObjects ) do System.MonitorSupport.FreeWaitObject( aObjects[ i ] );
end;

end.
