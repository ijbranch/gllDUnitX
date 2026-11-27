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

/// <summary>Tests of <c>GllDUnitX.RtlTaskCaches</c>, which stops the RTL's task-object and wait-object caches reading as leaks.</summary>
unit GllDUnitX.Tests.RtlTaskCaches;

interface

uses
  DUnitX.TestFramework;

type
  /// <summary>Tests of <c>FillRtlTaskCaches</c> and <c>FillRtlWaitObjectCache</c>.</summary>
  [TestFixture]
  TTestRtlTaskCaches = class
  public
    /// <summary>
    ///   Proves every class in <c>RTL_CACHED_TASK_CLASSES</c> is found and filled in this RTL: a name a later RTL
    ///   changes turns this red instead of silently leaving that cache to grow inside measured tests.
    /// </summary>
    [Test]
    procedure TestEveryCachedClassIsFound;
    /// <summary>
    ///   Proves that after the fill, allocating and freeing more task objects of each class than its cache holds
    ///   leaves the memory in use unchanged: no cache keeps a new instance, which is what the per-test leak check saw
    ///   as a leak whenever a <c>TParallel.For</c> reached a new peak of concurrent tasks.  Single-threaded, so the
    ///   race in <c>TObjectCache.Insert</c> between threads freeing at once cannot occur here.
    /// </summary>
    [Test]
    procedure TestTaskObjectsNoLongerGrowAnyCache;
    /// <summary>
    ///   Proves that after the fill, as many threads' worth of <c>TMonitor</c> wait objects as the fill added can be
    ///   taken at once and handed back without allocating a holder: the holder a thread the per-test leak check saw
    ///   when a parallel loop woke more idle pool workers than ever before.
    /// </summary>
    [Test]
    procedure TestWaitObjectsNoLongerGrowTheCache;
  end;

implementation

uses
  System.SysUtils, System.Rtti, System.Threading, GllDUnitX.RtlTaskCaches;

const
  /// <summary>Instances allocated at once per class: more than a cache holds, so a cache with room would keep some.</summary>
  CInstances        = TObjectCache.CObjectCacheLimit + 10;

var
  /// <summary>The memory manager the counting one forwards to, saved while it is installed.</summary>
  GInner            : TMemoryManagerEx;
  /// <summary>
///   Blocks allocated minus blocks freed while the counting memory manager is installed, on any thread.  Sound while
///   these tests run no thread of their own; a test that starts pool work inside the window needs its own count.
/// </summary>
  GNetBlocks        : Integer;

/// <summary>Counting <c>GetMem</c>: forwards, and counts one block more.</summary>
/// <param name="Size">Bytes asked for.</param>
/// <returns>The block.</returns>
function CountingGetMem( Size: NativeInt ): Pointer;
begin
  Result            := GInner.GetMem( Size );
  if Assigned( Result ) then AtomicIncrement( GNetBlocks );
end;

/// <summary>Counting <c>FreeMem</c>: forwards, and counts one block fewer.</summary>
/// <param name="P">Block to free.</param>
/// <returns>0 on success, as the inner memory manager returns.</returns>
function CountingFreeMem( P: Pointer ): Integer;
begin
  Result            := GInner.FreeMem( P );
  if Result = 0 then AtomicDecrement( GNetBlocks );
end;

/// <summary>Counting <c>AllocMem</c>: forwards, and counts one block more.</summary>
/// <param name="Size">Bytes asked for, zeroed.</param>
/// <returns>The block.</returns>
function CountingAllocMem( Size: NativeInt ): Pointer;
begin
  Result            := GInner.AllocMem( Size );
  if Assigned( Result ) then AtomicIncrement( GNetBlocks );
end;

/// <summary>Counting <c>ReallocMem</c>: forwards; a block resized is still one block.</summary>
/// <param name="P">Block to resize.</param>
/// <param name="Size">New size in bytes.</param>
/// <returns>The block, perhaps moved.</returns>
function CountingReallocMem( P: Pointer; Size: NativeInt ): Pointer;
begin
  Result            := GInner.ReallocMem( P, Size );
end;

/// <summary>Installs the counting memory manager, with the count at 0.</summary>
procedure StartCounting;
begin
  GetMemoryManager( GInner );
  GNetBlocks        := 0;
  var rCounting     := GInner;
  rCounting.GetMem  := CountingGetMem;
  rCounting.FreeMem := CountingFreeMem;
  rCounting.AllocMem := CountingAllocMem;
  rCounting.ReallocMem := CountingReallocMem;
  SetMemoryManager( rCounting );
end;

/// <summary>Puts the saved memory manager back.</summary>
/// <returns>Blocks allocated minus blocks freed while counting.</returns>
function StopCounting: Integer;
begin
  SetMemoryManager( GInner );
  Result            := GNetBlocks;
end;

{ TTestRtlTaskCaches }

procedure TTestRtlTaskCaches.TestEveryCachedClassIsFound;
begin
  Assert.AreEqual( Length( RTL_CACHED_TASK_CLASSES ), FillRtlTaskCaches );
end;

procedure TTestRtlTaskCaches.TestTaskObjectsNoLongerGrowAnyCache;
begin
  FillRtlTaskCaches;

  var lContext      := TRttiContext.Create;
  var aInstances    : array[ 0..CInstances - 1 ] of TObject;
  for var sName in RTL_CACHED_TASK_CLASSES do
  begin
    var lType       := lContext.FindType( sName );
    Assert.IsTrue( lType is TRttiInstanceType, sName + ' not found' );
    var lClass      := TRttiInstanceType( lType ).MetaclassType;

    StartCounting;
    for var i := 0 to High( aInstances ) do aInstances[ i ] := lClass.NewInstance;
    for var i := 0 to High( aInstances ) do aInstances[ i ].FreeInstance;
    var iKept       := StopCounting;

    Assert.AreEqual( 0, iKept, sName + ': its cache kept new instances' );
  end;
end;

procedure TTestRtlTaskCaches.TestWaitObjectsNoLongerGrowTheCache;
begin
  FillRtlWaitObjectCache( RTL_WAIT_OBJECTS );

  var aObjects      : TArray<Pointer>;
  SetLength( aObjects, RTL_WAIT_OBJECTS );
  StartCounting;
  for var i := 0 to High( aObjects ) do aObjects[ i ] := System.MonitorSupport.NewWaitObject;
  for var i := 0 to High( aObjects ) do System.MonitorSupport.FreeWaitObject( aObjects[ i ] );
  var iKept         := StopCounting;

  Assert.AreEqual( 0, iKept, 'handing the wait objects back allocated holders' );
end;

initialization
  TDUnitX.RegisterTestFixture( TTestRtlTaskCaches );

end.
