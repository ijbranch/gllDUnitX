{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Originally part of DUnitX, by Vincent Parrett & Contributors    }
{           Modified (C) 2026 Ian Branch (GITLAK Software) - gllDUnitX fork }
{                                                                           }
{           Licensed under the Apache License, Version 2.0                  }
{           http://www.apache.org/licenses/LICENSE-2.0                      }
{                                                                           }
{***************************************************************************}

unit DUnitX.Tests.UtilsHelpers;

{$I DUnitX.inc}

interface

uses
  DUnitX.TestFramework;

type
  /// <summary>
  ///   An interface descending from IInterface, used as a generic type argument to prove covariance of
  ///   interface arguments.
  /// </summary>
  IUtilsHelpersProbe = interface(IInterface)
    ['{5E0C7B5A-3F1D-4C1E-9B7A-2D6E8F4A1C30}']
  end;

  /// <summary>
  ///   A small record used to prove that <c>SameValue</c> compares the data of two record values.
  /// </summary>
  TUtilsHelpersPoint = record
    /// <summary>Horizontal coordinate.</summary>
    X : Integer;
    /// <summary>Vertical coordinate.</summary>
    Y : Integer;
  end;

  /// <summary>
  ///   Regression tests for defects in the helpers of <c>DUnitX.Utils</c>: <c>TArrayHelper.Delete</c>,
  ///   <c>SameValue</c>, <c>TObjectHelper.GetType</c>, <c>TValueHelper.ToString</c>,
  ///   <c>TRttiMethodHelper.Format</c> and <c>TRttiTypeHelper.IsCovariantTo</c>.
  /// </summary>
  [TestFixture('UtilsHelpers')]
  [Category('Utils')]
  TUtilsHelpersTests = class
  public
    /// <summary>
    ///   Proves Delete removes the FIRST element: upstream refused index 0 and left the array unchanged.
    /// </summary>
    [Test]
    procedure Delete_IndexZero_RemovesFirstElement;
    /// <summary>
    ///   Proves Delete removes a run from the middle of a managed-type array and shifts the remaining tail down
    ///   intact; upstream's copy loop read elements past the end of the array while doing so.
    /// </summary>
    [Test]
    procedure Delete_MiddleRun_ShiftsTailDown;
    /// <summary>
    ///   Proves a count running past the end is clamped to the elements from index onwards.
    /// </summary>
    [Test]
    procedure Delete_CountPastEnd_TruncatesFromIndex;
    /// <summary>
    ///   Proves an index outside the array, or a count of zero, leaves the array untouched.
    /// </summary>
    [Test]
    procedure Delete_OutOfRange_LeavesArrayUnchanged;
    /// <summary>
    ///   Proves two record values holding the same data are the same: upstream compared the addresses of each
    ///   TValue's own copy of the data, so equal records never matched.
    /// </summary>
    [Test]
    procedure SameValue_EqualRecords_AreSame;
    /// <summary>
    ///   Proves two record values holding different data are not the same, so the fix is not a blanket True.
    /// </summary>
    [Test]
    procedure SameValue_DifferentRecords_AreNotSame;
    /// <summary>
    ///   Proves GetType on a nil instance returns nil. Upstream left the result unassigned, so it returned
    ///   whatever the stack slot held; a preceding GetType on a live object leaves a non-nil type there.
    /// </summary>
    [Test]
    procedure GetType_NilInstance_ReturnsNil;
    /// <summary>
    ///   Proves TValue.ToString formats a nil object value as 'nil' instead of dereferencing nil.
    /// </summary>
    [Test]
    procedure ToString_NilObject_ReturnsNil;
    /// <summary>
    ///   Proves TValue.ToString formats a nil interface value as 'nil' instead of dereferencing nil.
    /// </summary>
    [Test]
    procedure ToString_NilInterface_ReturnsNil;
    /// <summary>
    ///   Proves Format with SkipSelf False and no arguments yields empty parentheses instead of reading Args[0]
    ///   out of range.
    /// </summary>
    [Test]
    procedure Format_NoArgsWithoutSkipSelf_HasEmptyParentheses;
    /// <summary>
    ///   Proves Format with SkipSelf False shows the first argument.
    /// </summary>
    [Test]
    procedure Format_OneArgWithoutSkipSelf_ShowsIt;
    /// <summary>
    ///   Proves a generic type whose interface argument descends from the target's interface argument is
    ///   covariant to it, and that the reverse direction is not. This pins the interface branch whose second
    ///   IsInterface test named the wrong array.
    /// </summary>
    [Test]
    procedure IsCovariantTo_InterfaceArgument_FollowsInheritance;
  end;

implementation

uses
{$IFDEF USE_NS}
  System.Generics.Collections,
  System.Rtti,
{$ELSE}
  Generics.Collections,
  Rtti,
{$ENDIF}
  DUnitX.Utils;

{ TUtilsHelpersTests }

procedure TUtilsHelpersTests.Delete_IndexZero_RemovesFirstElement;
var
  LValues : TArray<Integer>;
begin
  LValues := [10, 20, 30];
  TArrayHelper.Delete<Integer>(LValues, 0, 1);
  Assert.AreEqual(2, Length(LValues), 'Length');
  Assert.AreEqual(20, LValues[0], 'Element 0');
  Assert.AreEqual(30, LValues[1], 'Element 1');
end;

procedure TUtilsHelpersTests.Delete_MiddleRun_ShiftsTailDown;
var
  LValues : TArray<string>;
begin
  LValues := ['a', 'b', 'c', 'd', 'e'];
  TArrayHelper.Delete<string>(LValues, 1, 2);
  Assert.AreEqual(3, Length(LValues), 'Length');
  Assert.AreEqual('a', LValues[0], False, 'Element 0');
  Assert.AreEqual('d', LValues[1], False, 'Element 1');
  Assert.AreEqual('e', LValues[2], False, 'Element 2');
end;

procedure TUtilsHelpersTests.Delete_CountPastEnd_TruncatesFromIndex;
var
  LValues : TArray<string>;
begin
  LValues := ['a', 'b', 'c', 'd', 'e'];
  TArrayHelper.Delete<string>(LValues, 3, 10);
  Assert.AreEqual(3, Length(LValues), 'Length');
  Assert.AreEqual('c', LValues[2], False, 'Element 2');
end;

procedure TUtilsHelpersTests.Delete_OutOfRange_LeavesArrayUnchanged;
var
  LValues : TArray<Integer>;
begin
  LValues := [10, 20, 30];
  TArrayHelper.Delete<Integer>(LValues, 3, 1);
  Assert.AreEqual(3, Length(LValues), 'Index past the end');
  TArrayHelper.Delete<Integer>(LValues, -1, 1);
  Assert.AreEqual(3, Length(LValues), 'Negative index');
  TArrayHelper.Delete<Integer>(LValues, 1, 0);
  Assert.AreEqual(3, Length(LValues), 'Zero count');
  Assert.AreEqual(20, LValues[1], 'Element 1 untouched');
end;

procedure TUtilsHelpersTests.SameValue_EqualRecords_AreSame;
var
  LLeft, LRight : TUtilsHelpersPoint;
begin
  LLeft.X := 1;
  LLeft.Y := 2;
  LRight := LLeft;
  Assert.IsTrue(DUnitX.Utils.SameValue(TValue.From<TUtilsHelpersPoint>(LLeft),
    TValue.From<TUtilsHelpersPoint>(LRight)));
end;

procedure TUtilsHelpersTests.SameValue_DifferentRecords_AreNotSame;
var
  LLeft, LRight : TUtilsHelpersPoint;
begin
  LLeft.X := 1;
  LLeft.Y := 2;
  LRight.X := 1;
  LRight.Y := 3;
  Assert.IsFalse(DUnitX.Utils.SameValue(TValue.From<TUtilsHelpersPoint>(LLeft),
    TValue.From<TUtilsHelpersPoint>(LRight)));
end;

procedure TUtilsHelpersTests.GetType_NilInstance_ReturnsNil;
var
  LLive, LNil : TObject;
begin
  LLive := TObject.Create;
  try
    Assert.IsNotNull(LLive.GetType, 'Live instance');
  finally
    LLive.Free;
  end;
  LNil := nil;
  Assert.IsNull(LNil.GetType, 'Nil instance');
end;

procedure TUtilsHelpersTests.ToString_NilObject_ReturnsNil;
begin
  Assert.AreEqual('nil', TValue.ToString(TValue.From<TObject>(nil)), False);
end;

procedure TUtilsHelpersTests.ToString_NilInterface_ReturnsNil;
begin
  Assert.AreEqual('nil', TValue.ToString(TValue.From<IInterface>(nil)), False);
end;

procedure TUtilsHelpersTests.Format_NoArgsWithoutSkipSelf_HasEmptyParentheses;
var
  LContext : TRttiContext;
  LMethod : TRttiMethod;
begin
  LMethod := LContext.GetType(TObject).GetMethod('Free');
  Assert.IsNotNull(LMethod, 'TObject.Free RTTI');
  Assert.AreEqual('TObject.Free()', LMethod.Format([], False), False);
end;

procedure TUtilsHelpersTests.Format_OneArgWithoutSkipSelf_ShowsIt;
var
  LContext : TRttiContext;
  LMethod : TRttiMethod;
begin
  LMethod := LContext.GetType(TObject).GetMethod('Free');
  Assert.IsNotNull(LMethod, 'TObject.Free RTTI');
  Assert.AreEqual('TObject.Free(42)', LMethod.Format([42], False), False);
end;

procedure TUtilsHelpersTests.IsCovariantTo_InterfaceArgument_FollowsInheritance;
begin
  Assert.IsTrue(IsTypeCovariantTo(TypeInfo(TList<IUtilsHelpersProbe>), TypeInfo(TList<IInterface>)), 'Descendant');
  Assert.IsFalse(IsTypeCovariantTo(TypeInfo(TList<IInterface>), TypeInfo(TList<IUtilsHelpersProbe>)), 'Ancestor');
end;

initialization
  TDUnitX.RegisterTestFixture(TUtilsHelpersTests);

end.
