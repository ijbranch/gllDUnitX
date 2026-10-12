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

unit DUnitX.Generics;

interface

{$I DUnitX.inc}

uses
{$IFDEF USE_NS}
  System.Generics.Defaults,
  System.Generics.Collections;
{$ELSE}
  Generics.Defaults,
  Generics.Collections;
{$ENDIF}

type
  /// <summary>
  ///   A reference-counted, read-only view of a list. Delphi has no reference-counted collection types, so DUnitX
  ///   defines its own; typically used where a function returns an enumerable that the caller must not free.
  /// </summary>
  /// <remarks>
  ///   Upstream note: this unit still needs unit tests.
  /// </remarks>
  IReadOnlyList<T> = interface(IEnumerable<T>)
    /// <summary>Returns the number of items the list can hold before it must grow.</summary>
    /// <returns>The current capacity.</returns>
    function GetCapacity : integer;
    /// <summary>Returns the number of items in the list.</summary>
    /// <returns>The item count.</returns>
    function GetCount : integer;
    /// <summary>Returns the item at a position.</summary>
    /// <param name="index">Zero-based position of the item.</param>
    /// <returns>The item at <paramref name="index" />.</returns>
    function GetItem(index : integer) : T;
    /// <summary>Returns the handler called when items are added, removed or extracted.</summary>
    /// <returns>The current notification handler, or nil.</returns>
    function GetOnNotify : TCollectionNotifyEvent<T>;
    /// <summary>Sets the handler called when items are added, removed or extracted.</summary>
    /// <param name="value">The new notification handler, or nil.</param>
    procedure SetOnNotify(value : TCollectionNotifyEvent<T>);
    /// <summary>Returns the first item.</summary>
    /// <returns>The item at position 0.</returns>
    function First : T;
    /// <summary>Returns the last item.</summary>
    /// <returns>The item at position <c>Count - 1</c>.</returns>
    function Last : T;
    /// <summary>Reports whether the list holds a value, using the list's comparer.</summary>
    /// <param name="Value">The value to look for.</param>
    /// <returns>True if the value is present.</returns>
    function Contains(const Value : T) : Boolean;
    /// <summary>Finds the first occurrence of a value, searching forwards.</summary>
    /// <param name="Value">The value to look for.</param>
    /// <returns>Its zero-based position, or -1 if absent.</returns>
    function IndexOf(const Value : T) : Integer;
    /// <summary>Finds the last occurrence of a value, searching backwards.</summary>
    /// <param name="Value">The value to look for.</param>
    /// <returns>Its zero-based position, or -1 if absent.</returns>
    function LastIndexOf(const Value : T) : Integer;
    /// <summary>Binary-searches a sorted list using the list's own comparer.</summary>
    /// <param name="Item">The value to look for.</param>
    /// <param name="Index">Receives the position found, or the position at which the item would be inserted.</param>
    /// <returns>True if the item was found.</returns>
    function BinarySearch(const Item : T; out Index : Integer) : Boolean; overload;
    /// <summary>Binary-searches a sorted list using the given comparer.</summary>
    /// <param name="Item">The value to look for.</param>
    /// <param name="Index">Receives the position found, or the position at which the item would be inserted.</param>
    /// <param name="AComparer">The comparer the list was sorted with.</param>
    /// <returns>True if the item was found.</returns>
    function BinarySearch(const Item : T; out Index : Integer; const AComparer : IComparer<T>) : Boolean; overload;
    /// <summary>Number of items the list can hold before it must grow.</summary>
    property Capacity : Integer read GetCapacity;
    /// <summary>Number of items in the list.</summary>
    property Count : Integer read GetCount;
    /// <summary>The items, by zero-based position.</summary>
    property Items[Index : Integer] : T read GetItem; default;
    /// <summary>Handler called when items are added, removed or extracted.</summary>
    property OnNotify : TCollectionNotifyEvent<T> read GetOnNotify write SetOnNotify;

  end;

  /// <summary>
  ///   A reference-counted, modifiable list: <see cref="IReadOnlyList{T}" /> plus the mutating operations of
  ///   <c>TList&lt;T&gt;</c>.
  /// </summary>
  IList<T> = interface(IReadOnlyList<T>)
    /// <summary>Sets the number of items the list can hold before it must grow.</summary>
    /// <param name="value">The new capacity.</param>
    procedure SetCapacity(const value : integer);
    /// <summary>Sets the number of items, truncating or padding with default values.</summary>
    /// <param name="value">The new item count.</param>
    procedure SetCount(const value : integer);
    /// <summary>Replaces the item at a position.</summary>
    /// <param name="index">Zero-based position of the item.</param>
    /// <param name="value">The new item.</param>
    procedure SetItem(index : integer; value : T);

    /// <summary>Appends an item.</summary>
    /// <param name="Value">The item to append.</param>
    /// <returns>The zero-based position it was added at.</returns>
    function Add(const Value : T) : Integer;
    /// <summary>Appends every item of an open array.</summary>
    /// <param name="Values">The items to append.</param>
    procedure AddRange(const Values : array of T); overload;
    /// <summary>Appends every item of an enumerable interface.</summary>
    /// <param name="Collection">The items to append.</param>
    procedure AddRange(const Collection : IEnumerable<T>); overload;
    /// <summary>Appends every item of an enumerable collection object.</summary>
    /// <param name="Collection">The items to append.</param>
    procedure AddRange(Collection : TEnumerable<T>); overload;

    /// <summary>Inserts an item at a position, shifting later items up.</summary>
    /// <param name="Index">Zero-based position to insert at.</param>
    /// <param name="Value">The item to insert.</param>
    procedure Insert(Index : Integer; const Value : T);

    /// <summary>Inserts every item of an open array at a position.</summary>
    /// <param name="Index">Zero-based position to insert at.</param>
    /// <param name="Values">The items to insert.</param>
    procedure InsertRange(Index : Integer; const Values : array of T); overload;
    /// <summary>Inserts every item of an enumerable interface at a position.</summary>
    /// <param name="Index">Zero-based position to insert at.</param>
    /// <param name="Collection">The items to insert.</param>
    procedure InsertRange(Index : Integer; const Collection : IEnumerable<T>); overload;
    /// <summary>Inserts every item of an enumerable collection object at a position.</summary>
    /// <param name="Index">Zero-based position to insert at.</param>
    /// <param name="Collection">The items to insert.</param>
    procedure InsertRange(Index : Integer; const Collection : TEnumerable<T>); overload;

    /// <summary>Removes the first occurrence of a value.</summary>
    /// <param name="Value">The value to remove.</param>
    /// <returns>The position it was removed from, or -1 if absent.</returns>
    function Remove(const Value : T) : Integer;
    /// <summary>Removes the item at a position.</summary>
    /// <param name="Index">Zero-based position of the item.</param>
    procedure Delete(Index : Integer);
    /// <summary>Removes a run of items.</summary>
    /// <param name="AIndex">Zero-based position of the first item to remove.</param>
    /// <param name="ACount">Number of items to remove.</param>
    procedure DeleteRange(AIndex, ACount : Integer);
    /// <summary>Removes the first occurrence of a value and returns it, raising an extract (not remove) notification.</summary>
    /// <param name="Value">The value to extract.</param>
    /// <returns>The extracted value, or <c>Default(T)</c> if absent.</returns>
    function Extract(const Value : T) : T;

    /// <summary>Swaps two items.</summary>
    /// <param name="Index1">Zero-based position of the first item.</param>
    /// <param name="Index2">Zero-based position of the second item.</param>
    procedure Exchange(Index1, Index2 : Integer);
    /// <summary>Moves an item to a new position.</summary>
    /// <param name="CurIndex">Zero-based current position.</param>
    /// <param name="NewIndex">Zero-based destination position.</param>
    procedure Move(CurIndex, NewIndex : Integer);

    /// <summary>Removes every item.</summary>
    procedure Clear;

    /// <summary>Reverses the order of the items.</summary>
    procedure Reverse;

    /// <summary>Sorts the items with the list's own comparer.</summary>
    procedure Sort; overload;
    /// <summary>Sorts the items with the given comparer.</summary>
    /// <param name="AComparer">The comparer to order items by.</param>
    procedure Sort(const AComparer : IComparer<T>); overload;

    /// <summary>Reduces the capacity to the current count.</summary>
    procedure TrimExcess;

    /// <summary>Copies the items into a new array.</summary>
    /// <returns>A dynamic array holding the items in list order.</returns>
    function ToArray : TArray<T>;

    /// <summary>Number of items the list can hold before it must grow.</summary>
    property Capacity : Integer read GetCapacity write SetCapacity;
    /// <summary>Number of items in the list; setting it truncates or pads with default values.</summary>
    property Count : Integer read GetCount write SetCount;
    /// <summary>The items, by zero-based position.</summary>
    property Items[Index : Integer] : T read GetItem write SetItem; default;
    /// <summary>Handler called when items are added, removed or extracted.</summary>
    property OnNotify : TCollectionNotifyEvent<T> read GetOnNotify write SetOnNotify;
  end;

  /// <summary>
  ///   Base class implementing the non-generic IEnumerable, so that descendants can implement
  ///   <c>IEnumerable&lt;T&gt;</c> as well.
  /// </summary>
  /// <remarks>
  ///   Implementing <c>IEnumerable&lt;T&gt;</c> in the same class as <c>IEnumerable</c> is very awkward in Delphi
  ///   because both declare <c>GetEnumerator</c>; this class maps the non-generic one to
  ///   <c>GetNonGenEnumerator</c>.
  /// </remarks>
  TDUnitXEnumerable = class(TInterfacedObject, IEnumerable)
  protected
    /// <summary>Maps <c>IEnumerable.GetEnumerator</c> to <c>GetNonGenEnumerator</c>.</summary>
    function IEnumerable.GetEnumerator = GetNonGenEnumerator;
    /// <summary>Returns a non-generic enumerator over the collection.</summary>
    /// <returns>A new non-generic enumerator.</returns>
    function GetNonGenEnumerator : IEnumerator; virtual; abstract;
  end;

  /// <summary>
  ///   The implementation of <see cref="IList{T}" />: a reference-counted wrapper that delegates every operation to
  ///   an owned <c>TList&lt;T&gt;</c>.
  /// </summary>
  /// <remarks>
  ///   Enumerating takes an interface reference to the list, so hold instances through <see cref="IList{T}" />, not
  ///   an object reference.
  /// </remarks>
  TDUnitXList<T> = class(TDUnitXEnumerable, IList<T>, IEnumerable<T>)
  private
    /// <summary>The owned list every operation delegates to.</summary>
    FList : TList<T>;
  protected
    /// <summary>Returns a generic enumerator over the items.</summary>
    /// <returns>A new <see cref="TDUnitXIEnumerator{T}" /> over this list.</returns>
    function GetEnumerator : IEnumerator<T>; overload;
    /// <summary>Returns a non-generic enumerator over the items.</summary>
    /// <returns>A new <see cref="TDUnitXIEnumerator{T}" /> over this list.</returns>
    function GetNonGenEnumerator : IEnumerator; override;

    /// <summary>Returns the number of items the list can hold before it must grow.</summary>
    /// <returns>The current capacity.</returns>
    function GetCapacity : integer;
    /// <summary>Sets the number of items the list can hold before it must grow.</summary>
    /// <param name="value">The new capacity.</param>
    procedure SetCapacity(const value : integer);
    /// <summary>Returns the number of items in the list.</summary>
    /// <returns>The item count.</returns>
    function GetCount : integer;
    /// <summary>Sets the number of items, truncating or padding with default values.</summary>
    /// <param name="value">The new item count.</param>
    procedure SetCount(const value : integer);
    /// <summary>Returns the item at a position.</summary>
    /// <param name="index">Zero-based position of the item.</param>
    /// <returns>The item at <paramref name="index" />.</returns>
    function GetItem(index : integer) : T;
    /// <summary>Replaces the item at a position.</summary>
    /// <param name="index">Zero-based position of the item.</param>
    /// <param name="value">The new item.</param>
    procedure SetItem(index : integer; value : T);

    /// <summary>Returns the handler called when items are added, removed or extracted.</summary>
    /// <returns>The current notification handler, or nil.</returns>
    function GetOnNotify : TCollectionNotifyEvent<T>;
    /// <summary>Sets the handler called when items are added, removed or extracted.</summary>
    /// <param name="value">The new notification handler, or nil.</param>
    procedure SetOnNotify(value : TCollectionNotifyEvent<T>);

    /// <summary>Appends an item.</summary>
    /// <param name="Value">The item to append.</param>
    /// <returns>The zero-based position it was added at.</returns>
    function Add(const Value : T) : Integer;
    /// <summary>Appends every item of an open array.</summary>
    /// <param name="Values">The items to append.</param>
    procedure AddRange(const Values : array of T); overload;
    /// <summary>Appends every item of an enumerable interface.</summary>
    /// <param name="Collection">The items to append.</param>
    procedure AddRange(const Collection : IEnumerable<T>); overload;
    /// <summary>Appends every item of an enumerable collection object.</summary>
    /// <param name="Collection">The items to append.</param>
    procedure AddRange(Collection : TEnumerable<T>); overload;

    /// <summary>Inserts an item at a position, shifting later items up.</summary>
    /// <param name="Index">Zero-based position to insert at.</param>
    /// <param name="Value">The item to insert.</param>
    procedure Insert(Index : Integer; const Value : T);

    /// <summary>Inserts every item of an open array at a position.</summary>
    /// <param name="Index">Zero-based position to insert at.</param>
    /// <param name="Values">The items to insert.</param>
    procedure InsertRange(Index : Integer; const Values : array of T); overload;
    /// <summary>Inserts every item of an enumerable interface at a position.</summary>
    /// <param name="Index">Zero-based position to insert at.</param>
    /// <param name="Collection">The items to insert.</param>
    procedure InsertRange(Index : Integer; const Collection : IEnumerable<T>); overload;
    /// <summary>Inserts every item of an enumerable collection object at a position.</summary>
    /// <param name="Index">Zero-based position to insert at.</param>
    /// <param name="Collection">The items to insert.</param>
    procedure InsertRange(Index : Integer; const Collection : TEnumerable<T>); overload;

    /// <summary>Removes the first occurrence of a value.</summary>
    /// <param name="Value">The value to remove.</param>
    /// <returns>The position it was removed from, or -1 if absent.</returns>
    function Remove(const Value : T) : Integer;
    /// <summary>Removes the item at a position.</summary>
    /// <param name="Index">Zero-based position of the item.</param>
    procedure Delete(Index : Integer);
    /// <summary>Removes a run of items.</summary>
    /// <param name="AIndex">Zero-based position of the first item to remove.</param>
    /// <param name="ACount">Number of items to remove.</param>
    procedure DeleteRange(AIndex, ACount : Integer);
    /// <summary>Removes the first occurrence of a value and returns it, raising an extract (not remove) notification.</summary>
    /// <param name="Value">The value to extract.</param>
    /// <returns>The extracted value, or <c>Default(T)</c> if absent.</returns>
    function Extract(const Value : T) : T;

    /// <summary>Swaps two items.</summary>
    /// <param name="Index1">Zero-based position of the first item.</param>
    /// <param name="Index2">Zero-based position of the second item.</param>
    procedure Exchange(Index1, Index2 : Integer);
    /// <summary>Moves an item to a new position.</summary>
    /// <param name="CurIndex">Zero-based current position.</param>
    /// <param name="NewIndex">Zero-based destination position.</param>
    procedure Move(CurIndex, NewIndex : Integer);

    /// <summary>Returns the first item.</summary>
    /// <returns>The item at position 0.</returns>
    function First : T;
    /// <summary>Returns the last item.</summary>
    /// <returns>The item at position <c>Count - 1</c>.</returns>
    function Last : T;

    /// <summary>Removes every item.</summary>
    procedure Clear;

    /// <summary>Reports whether the list holds a value, using the list's comparer.</summary>
    /// <param name="Value">The value to look for.</param>
    /// <returns>True if the value is present.</returns>
    function Contains(const Value : T) : Boolean;
    /// <summary>Finds the first occurrence of a value, searching forwards.</summary>
    /// <param name="Value">The value to look for.</param>
    /// <returns>Its zero-based position, or -1 if absent.</returns>
    function IndexOf(const Value : T) : Integer;
    /// <summary>Finds the last occurrence of a value, searching backwards.</summary>
    /// <param name="Value">The value to look for.</param>
    /// <returns>Its zero-based position, or -1 if absent.</returns>
    function LastIndexOf(const Value : T) : Integer;

    /// <summary>Reverses the order of the items.</summary>
    procedure Reverse;

    /// <summary>Sorts the items with the list's own comparer.</summary>
    procedure Sort; overload;
    /// <summary>Sorts the items with the given comparer.</summary>
    /// <param name="AComparer">The comparer to order items by.</param>
    procedure Sort(const AComparer : IComparer<T>); overload;
    /// <summary>Binary-searches a sorted list using the list's own comparer.</summary>
    /// <param name="Item">The value to look for.</param>
    /// <param name="Index">Receives the position found, or the position at which the item would be inserted.</param>
    /// <returns>True if the item was found.</returns>
    function BinarySearch(const Item : T; out Index : Integer) : Boolean; overload;
    /// <summary>Binary-searches a sorted list using the given comparer.</summary>
    /// <param name="Item">The value to look for.</param>
    /// <param name="Index">Receives the position found, or the position at which the item would be inserted.</param>
    /// <param name="AComparer">The comparer the list was sorted with.</param>
    /// <returns>True if the item was found.</returns>
    function BinarySearch(const Item : T; out Index : Integer; const AComparer : IComparer<T>) : Boolean; overload;

    /// <summary>Reduces the capacity to the current count.</summary>
    procedure TrimExcess;

    /// <summary>Copies the items into a new array.</summary>
    /// <returns>A dynamic array holding the items in list order.</returns>
    function ToArray : TArray<T>;
  public
    /// <summary>Creates an empty list that compares items with the default comparer for <c>T</c>.</summary>
    constructor Create; overload;
    /// <summary>Creates an empty list that compares items with the given comparer.</summary>
    /// <param name="AComparer">The comparer used by searching and sorting.</param>
    constructor Create(const AComparer : IComparer<T>); overload;
    /// <summary>Creates a list holding a copy of a collection's items.</summary>
    /// <param name="Collection">The items to copy in.</param>
    constructor Create(Collection : TEnumerable<T>); overload;
    /// <summary>Frees the owned list (but not the items, which it does not own).</summary>
    destructor Destroy; override;
  end;

  /// <summary>
  ///   Enumerator over an <see cref="IList{T}" />, serving both the generic and the non-generic enumerator
  ///   interfaces.
  /// </summary>
  TDUnitXIEnumerator<T> = class(TInterfacedObject, IEnumerator<T>, IEnumerator)
  private
    /// <summary>The list being enumerated; the enumerator keeps it alive.</summary>
    FList : IList<T>;
    /// <summary>Zero-based position of the current item; -1 before the first <c>MoveNext</c>.</summary>
    FIndex : integer;
  protected
    /// <summary>Returns the current item.</summary>
    /// <returns>The item at the current position.</returns>
    function GetCurrentGen : T;
    /// <summary>Maps <c>IEnumerator&lt;T&gt;.GetCurrent</c> to <c>GetCurrentGen</c>.</summary>
    function IEnumerator<T>.GetCurrent = GetCurrentGen;
    /// <summary>Returns the current item as an object, for the non-generic enumerator.</summary>
    /// <returns>The current item when <c>T</c> is a class type; nil otherwise, as only objects can be yielded.</returns>
    function GetCurrent : TObject;
    /// <summary>Advances to the next item; stays past the end once it has been reached.</summary>
    /// <returns>True if there is a current item after the move.</returns>
    function MoveNext : Boolean;
    /// <summary>Returns to the position before the first item.</summary>
    procedure Reset;
  public
    /// <summary>Creates an enumerator positioned before the first item.</summary>
    /// <param name="AList">The list to enumerate.</param>
    constructor Create(const AList : IList<T>);
  end;

implementation

{ TListFactory }

{ TDUnitList<T> }

function TDUnitXList<T>.Add(const Value : T) : Integer;
begin
  result := FList.Add(Value);
end;

procedure TDUnitXList<T>.AddRange(const Collection : IEnumerable<T>);
begin
  FList.AddRange(collection);
end;

procedure TDUnitXList<T>.AddRange(Collection : TEnumerable<T>);
begin
  FList.AddRange(collection);
end;

procedure TDUnitXList<T>.AddRange(const Values : array of T);
begin
  FList.AddRange(Values);
end;

function TDUnitXList<T>.BinarySearch(const Item : T; out Index : Integer; const AComparer : IComparer<T>) : Boolean;
begin
  result := FList.BinarySearch(Item, Index, AComparer);
end;

function TDUnitXList<T>.BinarySearch(const Item : T; out Index : Integer) : Boolean;
begin
  result := FList.BinarySearch(Item, Index);
end;

procedure TDUnitXList<T>.Clear;
begin
  FList.Clear;
end;

function TDUnitXList<T>.Contains(const Value : T) : Boolean;
begin
  result := FList.Contains(Value);
end;

constructor TDUnitXList<T>.Create;
begin
  FList := TList<T>.Create;
end;

constructor TDUnitXList<T>.Create(Collection : TEnumerable<T>);
begin
  FList := TList<T>.Create(collection);
end;

constructor TDUnitXList<T>.Create(const AComparer : IComparer<T>);
begin
  FList := TList<T>.Create(AComparer);
end;

procedure TDUnitXList<T>.Delete(Index : Integer);
begin
  FList.Delete(index);
end;

procedure TDUnitXList<T>.DeleteRange(AIndex, ACount : Integer);
begin
  FList.DeleteRange(AIndex, ACount);
end;

destructor TDUnitXList<T>.Destroy;
begin
  FList.Free;
  inherited;
end;

procedure TDUnitXList<T>.Exchange(Index1, Index2 : Integer);
begin
  FList.Exchange(Index1, Index2);
end;

function TDUnitXList<T>.Extract(const Value : T) : T;
begin
  result := FList.Extract(Value);
end;

function TDUnitXList<T>.First : T;
begin
  result := FList.First;
end;

function TDUnitXList<T>.GetCapacity : integer;
begin
  result := FList.Capacity;
end;

function TDUnitXList<T>.GetCount : integer;
begin
  result := FList.Count;
end;

function TDUnitXList<T>.GetEnumerator : IEnumerator<T>;
begin
  result := TDUnitXIEnumerator<T>.Create(Self);
end;

function TDUnitXList<T>.GetItem(index : integer) : T;
begin
  result := FList.Items[index];
end;

function TDUnitXList<T>.GetNonGenEnumerator : IEnumerator;
begin
  result := TDUnitXIEnumerator<T>.Create(Self);
end;

function TDUnitXList<T>.GetOnNotify : TCollectionNotifyEvent<T>;
begin
  result := FList.OnNotify;
end;

function TDUnitXList<T>.IndexOf(const Value : T) : Integer;
begin
  result := FList.IndexOf(Value);
end;

procedure TDUnitXList<T>.Insert(Index : Integer; const Value : T);
begin
  FList.Insert(Index, Value);
end;

procedure TDUnitXList<T>.InsertRange(Index : Integer; const Collection : TEnumerable<T>);
begin
  FList.InsertRange(Index, Collection);
end;

procedure TDUnitXList<T>.InsertRange(Index : Integer; const Values : array of T);
begin
  FList.InsertRange(Index, Values);
end;

procedure TDUnitXList<T>.InsertRange(Index : Integer; const Collection : IEnumerable<T>);
begin
  FList.InsertRange(Index, Collection);
end;

function TDUnitXList<T>.Last : T;
begin
  result := FList.Last;
end;

function TDUnitXList<T>.LastIndexOf(const Value : T) : Integer;
begin
  result := FList.LastIndexOf(Value);
end;

procedure TDUnitXList<T>.Move(CurIndex, NewIndex : Integer);
begin
  FList.Move(CurIndex, NewIndex);
end;

function TDUnitXList<T>.Remove(const Value : T) : Integer;
begin
  result := FList.Remove(Value);
end;

procedure TDUnitXList<T>.Reverse;
begin
  FList.Reverse;
end;

procedure TDUnitXList<T>.SetCapacity(const value : integer);
begin
  FList.Capacity := value;
end;

procedure TDUnitXList<T>.SetCount(const value : integer);
begin
  FList.Count := value;
end;

procedure TDUnitXList<T>.SetItem(index : integer; value : T);
begin
  FList.Items[index] := value;
end;

procedure TDUnitXList<T>.SetOnNotify(value : TCollectionNotifyEvent<T>);
begin
  FList.OnNotify := value;
end;

procedure TDUnitXList<T>.Sort(const AComparer : IComparer<T>);
begin
  FList.Sort(AComparer);
end;

procedure TDUnitXList<T>.Sort;
begin
  FList.Sort;
end;

function TDUnitXList<T>.ToArray : TArray<T>;
begin
  result := FList.ToArray;
end;

procedure TDUnitXList<T>.TrimExcess;
begin
  FList.TrimExcess;
end;

{ TDUnitIEnumerator<T> }

constructor TDUnitXIEnumerator<T>.Create(const AList : IList<T>);
begin
  FList := AList;
  FIndex := -1;
end;

function TDUnitXIEnumerator<T>.GetCurrent : TObject;
var
  item : T;
begin
  //The non-generic IEnumerator can only yield objects, so Current is nil when T is not a class.
  if GetTypeKind(T) = tkClass then
  begin
    item := FList[FIndex];
    result := TObject(PPointer(@item)^);
  end
  else
    result := nil;
end;

function TDUnitXIEnumerator<T>.GetCurrentGen : T;
begin
  Result := FList[FIndex];
end;

function TDUnitXIEnumerator<T>.MoveNext : Boolean;
begin
  if FIndex >= FList.Count then
    Exit(False);
  Inc(FIndex);
  Result := FIndex < FList.Count;
end;

procedure TDUnitXIEnumerator<T>.Reset;
begin
  FIndex := -1;
end;

end.

