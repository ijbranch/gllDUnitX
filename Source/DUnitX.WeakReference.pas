{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2015 Vincent Parrett & Contributors               }
{           Modified (C) 2026 Ian Branch (GITLAK Software) - gllDUnitX fork }
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

unit DUnitX.WeakReference;

(*

The idea behind this unit is provide a similar lifecycle to reference counted objects
in delphi as WeakReference does in .NET.

Reference counted objects in delphi have some limitations when it comes to circular references,
where for example TParent references it's children (via IChild), and TChild references it's parent
(via IParent). If we remove any external references to our IParent and IChild instances without first
getting the child to remove it's reference to IParent, we would end up with orphaned objects. This
is because our IChild and IParent instances are holding references to each other, and thus they never
get released.

This unit was borrowed from FinalBuilder 7(with permission), it has been extensively used with
Delphi 2010 and has so far proven to be very reliable.

*)

interface

{$I DUnitX.inc}

uses
{$IFDEF USE_NS}
  Winapi.Windows,
  System.Generics.Collections;
{$ELSE}
  Windows,
  Generics.Collections;
{$ENDIF}

type
  /// <summary>
  ///   Implemented by the weak-referenceable object base class: lets a <see cref="TWeakReference{T}" /> register the
  ///   address of its target field so the target can clear it when it is destroyed.
  /// </summary>
  IWeakReferenceableObject = interface
    ['{3D7F9CB5-27F2-41BF-8C5F-F6195C578755}']
    /// <summary>Registers the address of a weak reference's target field, to be set to nil on destruction.</summary>
    /// <param name="value">Address of the pointer field that refers to this object.</param>
    procedure AddWeakRef(value : Pointer);
    /// <summary>Unregisters a weak reference's target field previously added by <c>AddWeakRef</c>.</summary>
    /// <param name="value">Address of the pointer field to forget.</param>
    procedure RemoveWeakRef(value : Pointer);
    /// <summary>Returns the object's current reference count.</summary>
    /// <returns>The number of strong interface references held, excluding the destroying flag.</returns>
    function GetRefCount : integer;
  end;

  /// <summary>
  ///   Base class for any object that can have a weak reference to it. It implements IInterface so the object can
  ///   also be used just like any normal reference-counted object in Delphi.
  /// </summary>
  /// <remarks>
  ///   Delphi reference counting leaks circular references (a parent holding <c>IChild</c> and a child holding
  ///   <c>IParent</c> keep each other alive). A weak reference to such an object does not count, and is cleared to
  ///   nil when the object is destroyed - the .NET WeakReference lifecycle. Borrowed from FinalBuilder 7.
  /// </remarks>
  TWeakReferencedObject = class(TObject, IInterface, IWeakReferenceableObject)
  private const
    /// <summary>
    ///   High bit set in <c>FRefCount</c> once the count has reached zero and destruction has begun, so a weak
    ///   reference does not revive the object.
    /// </summary>
    objDestroyingFlag = Integer($80000000);
  private
    /// <summary>
    ///   Guards all weak-reference bookkeeping: the lists of weak references and every TWeakReference's target field.
    /// </summary>
    /// <remarks>
    ///   A critical section record, not an object, and never deleted: objects holding weak references are still
    ///   being destroyed after this unit finalizes (a VCL form freed by Vcl.Forms' finalization), so a lock freed
    ///   there was used after it was freed. The operating system releases it at process exit.
    /// </remarks>
    class var FWeakReferenceLock : TRTLCriticalSection;
    /// <summary>Initialises <c>FWeakReferenceLock</c> once, before the class is first used.</summary>
    class constructor Create;
    /// <summary>Enters the process-wide weak-reference lock.</summary>
    class procedure LockWeakReferences; static;
    /// <summary>Leaves the process-wide weak-reference lock.</summary>
    class procedure UnlockWeakReferences; static;
  protected
{$IFNDEF AUTOREFCOUNT}
    /// <summary>
    ///   Interface reference count; its high bit is <c>objDestroyingFlag</c> once destruction has begun.
    /// </summary>
    FRefCount : Integer;
{$ENDIF}
    /// <summary>
    ///   Addresses of the target fields of every live weak reference to this object; nil when there are none.
    /// </summary>
    FWeakReferences : TList<Pointer>;
    /// <summary>Returns the requested interface if the object implements it.</summary>
    /// <param name="IID">The interface identifier asked for.</param>
    /// <param name="Obj">Receives the interface reference on success.</param>
    /// <returns>0 (S_OK) when supported, otherwise E_NOINTERFACE.</returns>
    function QueryInterface(const IID : TGUID; out Obj) : HResult; stdcall;
    /// <summary>Atomically increments the reference count.</summary>
    /// <returns>The new reference count.</returns>
    function _AddRef : Integer; stdcall;
    /// <summary>
    ///   Atomically decrements the reference count; at zero, sets the destroying flag and destroys the object.
    /// </summary>
    /// <returns>The new reference count.</returns>
    function _Release : Integer; stdcall;
    /// <summary>
    ///   Registers the address of a weak reference's target field, under the weak-reference lock, creating the list
    ///   on first use.
    /// </summary>
    /// <param name="value">Address of the pointer field that refers to this object.</param>
    procedure AddWeakRef(value : Pointer);
    /// <summary>
    ///   Unregisters a weak reference's target field under the weak-reference lock, freeing the list when it empties.
    /// </summary>
    /// <param name="value">Address of the pointer field to forget.</param>
    /// <exception cref="Exception">
    ///   DEBUG builds only: no weak reference was ever registered (the list is nil). Release builds just return.
    /// </exception>
    procedure RemoveWeakRef(value : Pointer);
    /// <summary>Returns the reference count with the destroying flag masked off.</summary>
    /// <returns>The number of strong interface references held.</returns>
    function GetRefCount : integer; inline;
  public
    /// <summary>Drops the implicit reference that <c>NewInstance</c> took for the duration of construction.</summary>
    procedure AfterConstruction; override;
    /// <summary>
    ///   Sets every registered weak reference's target field to nil, under the weak-reference lock, and frees the list.
    ///   Raises an invalid-pointer runtime error if strong references are still outstanding.
    /// </summary>
    procedure BeforeDestruction; override;
    /// <summary>
    ///   Allocates the instance with an implicit reference count of 1 so that reference counting during construction
    ///   cannot destroy it.
    /// </summary>
    /// <returns>The new, uninitialised instance.</returns>
{$IFDEF AUTOREFCOUNT} [Result : Unsafe]{$ENDIF}class function NewInstance : TObject; override;
{$IFNDEF AUTOREFCOUNT}
    /// <summary>Number of strong interface references currently held.</summary>
    property RefCount : Integer read GetRefCount;
{$ENDIF}
  end;

  /// <summary>
  ///   A reference to an interface that does not keep its target alive; the target must descend from
  ///   <see cref="TWeakReferencedObject" /> (or implement <see cref="IWeakReferenceableObject" />).
  /// </summary>
  IWeakReference<T : IInterface> = interface
    /// <summary>Reports whether the target still exists.</summary>
    /// <returns>True until the target is destroyed.</returns>
    function IsAlive : boolean;
    /// <summary>Returns a strong reference to the target, or nil if it has been or is being destroyed.</summary>
    /// <returns>The target as <c>T</c>, or nil.</returns>
    function Data : T;
  end;

  /// <summary>
  ///   The implementation of <see cref="IWeakReference{T}" />: holds the target as a raw pointer which the target
  ///   clears when it is destroyed.
  /// </summary>
  TWeakReference<T : IInterface> = class(TInterfacedObject, IWeakReference<T>)
  private
    /// <summary>The target object as a raw, uncounted pointer; nil once the target is destroyed.</summary>
    FData : Pointer;
  protected
    /// <summary>Reports whether the target still exists.</summary>
    /// <returns>True while the target field is non-nil.</returns>
    function IsAlive : boolean;
    /// <summary>
    ///   Returns a strong reference to the target, taken under the weak-reference lock; a target whose last reference
    ///   has already gone (destroying flag set) is not revived.
    /// </summary>
    /// <returns>The target as <c>T</c>, or nil if it is gone or does not support <c>T</c>'s GUID.</returns>
    function Data : T;
  public
    /// <summary>Creates a weak reference to <paramref name="data" /> and registers it with the target.</summary>
    /// <param name="data">The target interface; its object must implement <see cref="IWeakReferenceableObject" />.</param>
    /// <exception cref="Exception">
    ///   <paramref name="data" /> is nil, or its object does not implement <see cref="IWeakReferenceableObject" />.
    /// </exception>
    constructor Create(const data : T);
    /// <summary>Unregisters this reference from its target, if the target is still alive.</summary>
    destructor Destroy; override;
  end;

/// <summary>
///   <c>TMonitor.TryEnter</c> with a nil check, which <c>TMonitor.TryEnter</c> lacks. Only here to work around a
///   compiler limitation.
/// </summary>
/// <param name="AObject">The object whose monitor to try to enter; may be nil.</param>
/// <returns>True if the monitor was entered; False if it was not or <paramref name="AObject" /> is nil.</returns>
function SafeMonitorTryEnter(const AObject : TObject) : Boolean;

implementation

uses
  DUnitX.ResStrs,
{$IFDEF USE_NS}
  System.TypInfo,
  System.Classes,
  System.Sysutils,
  System.SyncObjs;
{$ELSE}
  TypInfo,
  classes,
  SysUtils,
  SyncObjs;
{$ENDIF}

{$IFNDEF DELPHI_XE2_UP}
type
  TInterlocked = class
  public
    class function Increment(var Target : Integer) : Integer; static; inline;
    class function Decrement(var Target : Integer) : Integer; static; inline;
    class function Add(var Target : Integer; Increment : Integer) : Integer; static;
    class function CompareExchange(var Target : Integer; Value, Comparand : Integer) : Integer; static;
  end;

class function TInterlocked.Decrement(var Target : Integer) : Integer;
begin
  result := Add(Target, -1);
end;

class function TInterlocked.Increment(var Target : Integer) : Integer;
begin
  result := Add(Target, 1);
end;

class function TInterlocked.Add(var Target : Integer; Increment : Integer) : Integer;
{$IFNDEF CPUX86}
asm
  .NOFRAME
  MOV  EAX,EDX
  LOCK XADD [RCX].Integer,EAX
  ADD  EAX,EDX
end;
{$ELSE CPUX86}
asm
  MOV  ECX,EDX
  XCHG EAX,EDX
  LOCK XADD [EDX],EAX
  ADD  EAX,ECX
end;
{$ENDIF}

class function TInterlocked.CompareExchange(var Target : Integer; Value, Comparand : Integer) : Integer;
asm
  XCHG EAX,EDX
  XCHG EAX,ECX
  LOCK CMPXCHG [EDX],ECX
end;
{$ENDIF DELPHI_XE2_UPE2}

//MonitorTryEnter doesn't do a nil check!
function SafeMonitorTryEnter(const AObject : TObject) : Boolean;
begin
  if AObject <> nil then
    Result := TMonitor.TryEnter(AObject)
  else
    result := False;
end;

constructor TWeakReference<T>.Create(const data : T);
var
  target : IWeakReferenceableObject;
begin
  if data = nil then
    raise Exception.Create(format('[%s] passed to TWeakReference was nil', [PTypeInfo(TypeInfo(T)).Name]));

  inherited Create;

  if Supports(IInterface(data), IWeakReferenceableObject, target) then
  begin
    FData := IInterface(data) as TObject;
    target.AddWeakRef(@FData);
  end
  else
    raise Exception.Create(SWeakReferenceError);
end;

function TWeakReference<T>.Data : T;
begin
  result := Default(T);                 /// can't assign nil to T
  //The target clears FData under the weak-reference lock as it starts destroying, so while the lock is held a non-nil
  //FData is a live object. One whose last reference has already gone (destroying flag set) is not revived.
  TWeakReferencedObject.LockWeakReferences;
  try
    if (FData <> nil) and not ((TObject(FData) is TWeakReferencedObject)
      and ((TWeakReferencedObject(FData).FRefCount and TWeakReferencedObject.objDestroyingFlag) <> 0)) then
    begin
      //Make sure that the object supports the interface which is our generic type if we
      //simply pass in the interface base type, the method table doesn't work correctly
      if Supports(TObject(FData), GetTypeData(TypeInfo(T))^.Guid, result) then
        result := T(result);
    end;
  finally
    TWeakReferencedObject.UnlockWeakReferences;
  end;
end;

destructor TWeakReference<T>.Destroy;
var
  target : IWeakReferenceableObject;
begin
  //One lock for all weak-reference bookkeeping. Locking the target's own monitor meant reading FData first, and the
  //target could be freed by another thread between that read and the lock.
  TWeakReferencedObject.LockWeakReferences;
  try
    if FData <> nil then
    begin
      //No interface reference to our own class: taking one would revive a target whose count has reached zero.
      if TObject(FData) is TWeakReferencedObject then
        TWeakReferencedObject(FData).RemoveWeakRef(@FData)
      else if Supports(TObject(FData), IWeakReferenceableObject, target) then
      begin
        target.RemoveWeakRef(@FData);
        target := nil;                  //release the reference asap.
      end;
      FData := nil;
    end;
  finally
    TWeakReferencedObject.UnlockWeakReferences;
  end;
  inherited;
end;

function TWeakReference<T>.IsAlive : boolean;
begin
  result := FData <> nil;
end;

{ TWeakReferencedObject }

procedure TWeakReferencedObject.AddWeakRef(value : Pointer);
begin
  TWeakReferencedObject.LockWeakReferences;
  try
    if FWeakReferences = nil then
      FWeakReferences := TList<Pointer>.Create;
    FWeakReferences.Add(value);
  finally
    TWeakReferencedObject.UnlockWeakReferences;
  end;
end;

procedure TWeakReferencedObject.RemoveWeakRef(value : Pointer);
begin
  TWeakReferencedObject.LockWeakReferences;
  try
    if FWeakReferences = nil then       // should never happen
{$IFDEF DEBUG}
      raise Exception.Create('FWeakReferences = nil');
{$ELSE}
      exit;
{$ENDIF}
    FWeakReferences.Remove(value);
    if FWeakReferences.Count = 0 then
      FreeAndNil(FWeakReferences);
  finally
    TWeakReferencedObject.UnlockWeakReferences;
  end;
end;

procedure TWeakReferencedObject.AfterConstruction;
begin
{$IFNDEF AUTOREFCOUNT}
  TInterlocked.Decrement(FRefCount);
{$ENDIF}
end;

procedure TWeakReferencedObject.BeforeDestruction;
var
  value : PPointer;
  i : Integer;
begin
{$IFNDEF AUTOREFCOUNT}
  if RefCount <> 0 then
    System.Error(reInvalidPtr);
{$ELSE}
  inherited BeforeDestruction;
{$ENDIF}
  TWeakReferencedObject.LockWeakReferences;
  try
    if FWeakReferences <> nil then
    begin
      for i := 0 to FWeakReferences.Count - 1 do
      begin
        value := FWeakReferences.Items[i];
        value^ := nil;
      end;
      FreeAndNil(FWeakReferences);
    end;
  finally
    TWeakReferencedObject.UnlockWeakReferences;
  end;
end;

function TWeakReferencedObject.GetRefCount : integer;
begin
  Result := FRefCount and not objDestroyingFlag;
end;

class function TWeakReferencedObject.NewInstance : TObject;
begin
  Result := inherited NewInstance;
{$IFNDEF AUTOREFCOUNT}
  // Set an implicit refcount so that refcounting
  // during construction won't destroy the object.
  TWeakReferencedObject(Result).FRefCount := 1;
{$ENDIF}
end;

function TWeakReferencedObject.QueryInterface(const IID : TGUID; out Obj) : HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

function TWeakReferencedObject._AddRef : Integer;
begin
{$IFNDEF AUTOREFCOUNT}
  Result := TInterlocked.Increment(FRefCount);
{$ELSE}
  Result := __ObjAddRef;
{$ENDIF}
end;

function TWeakReferencedObject._Release : Integer;

{$IFNDEF AUTOREFCOUNT}
  procedure __MarkDestroying(const Obj);
  var
    LRef : Integer;
  begin
    repeat
      LRef := TWeakReferencedObject(Obj).FRefCount;
    until TInterlocked.CompareExchange(TWeakReferencedObject(Obj).FRefCount, LRef or objDestroyingFlag, LRef) = LRef;
  end;
{$ENDIF}

begin
{$IFNDEF AUTOREFCOUNT}
  Result := TInterlocked.Decrement(FRefCount);
  if Result = 0 then
  begin
    __MarkDestroying(Self);
    Destroy;
  end;
{$ELSE}
  Result := __ObjRelease;
{$ENDIF}
end;

class constructor TWeakReferencedObject.Create;
begin
  InitializeCriticalSection(FWeakReferenceLock);
end;

class procedure TWeakReferencedObject.LockWeakReferences;
begin
  EnterCriticalSection(FWeakReferenceLock);
end;

class procedure TWeakReferencedObject.UnlockWeakReferences;
begin
  LeaveCriticalSection(FWeakReferenceLock);
end;

end.

