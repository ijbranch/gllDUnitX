{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2012 Vincent Parrett                              }
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

unit DUnitX.Tests.DUnitCompatibility;

interface

uses
  DUnitX.TestFramework,
  DUnitX.DUnitCompatibility;

type
  /// <summary>
  ///   First of two marker interfaces implemented by one object, so CheckSame(IUnknown) can be handed two different
  ///   interface pointers to the same object.
  /// </summary>
  ICompatFirst = interface
    ['{3C0D7B0E-5A61-4C2B-9C59-1E0A9B4C7D11}']
  end;

  /// <summary>
  ///   Second marker interface; its pointer to a <c>TCompatBoth</c> differs from the ICompatFirst pointer.
  /// </summary>
  ICompatSecond = interface
    ['{8F7B2C44-0D3E-4B9A-A6E1-52C7D0F3B812}']
  end;

  /// <summary>
  ///   Reference-counted object implementing both marker interfaces.
  /// </summary>
  TCompatBoth = class(TInterfacedObject, ICompatFirst, ICompatSecond)
  end;

  /// <summary>
  ///   Every instance equals every other, so only an identity check tells two of them apart.
  /// </summary>
  TCompatAlwaysEqual = class
  public
    /// <summary>
    ///   Reports equality with any other TCompatAlwaysEqual instance.
    /// </summary>
    /// <param name="Obj">
    ///   The object to compare with.
    /// </param>
    /// <returns>
    ///   True when Obj is a TCompatAlwaysEqual (or descendant), whatever its identity.
    /// </returns>
    function Equals(Obj : TObject) : Boolean; override;
  end;

{$M+}
  /// <summary>
  ///   A typical DUnit-style <c>TTestCase</c> with published test methods, run by DUnitX through the compatibility
  ///   layer to prove the Check* methods behave as they did in classic DUnit.
  /// </summary>
  TMyDUnitTest = class(TTestCase)
  private
    /// <summary>
    ///   Raises EConvertError; the method handed to CheckException.
    /// </summary>
    /// <exception cref="EConvertError">
    ///   Always.
    /// </exception>
    procedure RaiseConvertError;
    /// <summary>
    ///   Does nothing; the method handed to CheckException when no exception should occur.
    /// </summary>
    procedure RaiseNothing;
  published
    /// <summary>
    ///   Proves a published DUnit-style method is discovered and run, and that Status and CheckTrue work through the
    ///   compatibility layer.
    /// </summary>
    procedure ATest;
    /// <summary>
    ///   Proves the compatibility checks keep DUnit's semantics: string checks are case-sensitive, CheckInherits tests
    ///   actual.InheritsFrom(expected), CheckException accepts a descendant and lets an exception through when no
    ///   class is named, and CheckSame(IUnknown) compares object identity rather than the interface pointers passed.
    /// </summary>
    procedure Checks_Have_DUnit_Semantics;
    /// <summary>
    ///   Proves CheckSame(TObject) is an identity check, as in DUnit: two distinct objects whose class overrides
    ///   Equals to call them equal still fail, and the same object passes.
    /// </summary>
    procedure CheckSame_Object_Compares_Identity;
    /// <summary>
    ///   Proves CheckEqualsBin compares the values, as DUnit does: values that differ only above the displayed digits
    ///   fail. Issue #398 item 4.
    /// </summary>
    procedure CheckEqualsBin_Compares_Values_Not_Digits;
    /// <summary>
    ///   Proves CheckIs fails with ETestFailure for a nil object, as DUnit does, instead of raising an access violation
    ///   by reading the nil object's class; and that it still passes for an instance of the class and fails for an
    ///   instance of an unrelated class.
    /// </summary>
    procedure CheckIs_Nil_Object_Fails;
  end;

{$M+}
  /// <summary>
  ///   DUnit-style test case using the SetUp/TearDown overrides, to prove DUnitX calls them around each published
  ///   test and exposes the test's name through <c>Name</c>.
  /// </summary>
  TMyDUnitTestSetup = class(TTestCase)
  protected
    /// <summary>Object created by SetUp and freed by TearDown; non-nil inside every test.</summary>
    FObject : TObject;
    /// <summary>
    ///   Creates FObject before each test.
    /// </summary>
    procedure SetUp; override;
    /// <summary>
    ///   Frees FObject after each test.
    /// </summary>
    procedure TearDown; override;
  published
    /// <summary>
    ///   Proves the DUnit-style SetUp override ran before the test: FObject is assigned.
    /// </summary>
    procedure ATest;
    /// <summary>
    ///   Proves <c>Name</c> returns the running published method's name, as DUnit's TTestCase.Name did.
    /// </summary>
    procedure Test_TestName;
  end;

implementation

uses
  System.SysUtils,
  DUnitX.Exceptions;

{ TMyDUnitTest }

procedure TMyDUnitTest.ATest;
begin
  Status('Testing Status Redirect');
{$WARN SYMBOL_DEPRECATED OFF}
  CheckTrue(true, 'true is always true!');
{$WARN SYMBOL_DEPRECATED ON}
end;

procedure TMyDUnitTest.RaiseConvertError;
begin
  raise EConvertError.Create('raised on purpose');
end;

procedure TMyDUnitTest.RaiseNothing;
begin
end;

procedure TMyDUnitTest.Checks_Have_DUnit_Semantics;
var
  first : ICompatFirst;
  second : ICompatSecond;
begin
{$WARN SYMBOL_DEPRECATED OFF}
  Assert.WillRaiseDescendant(procedure begin CheckEqualsString('abc', 'ABC') end, ETestFailure, 'CheckEqualsString');
  Assert.WillRaiseDescendant(procedure begin CheckEquals(UnicodeString('abc'), UnicodeString('ABC')) end, ETestFailure, 'CheckEquals(string)');
  Assert.WillRaiseDescendant(procedure begin CheckEquals(WideString('abc'), WideString('ABC')) end, ETestFailure, 'CheckEquals(WideString)');
  Assert.WillRaiseDescendant(procedure begin CheckEqualsWideString('abc', 'ABC') end, ETestFailure, 'CheckEqualsWideString');
  CheckNotEquals('abc', 'ABC', 'CheckNotEquals(string)');
  CheckNotEqualsString('abc', 'ABC', 'CheckNotEqualsString');
  CheckNotEquals(WideString('abc'), WideString('ABC'), 'CheckNotEquals(WideString)');
  CheckNotEqualsWideString('abc', 'ABC', 'CheckNotEqualsWideString');

  CheckInherits(Exception, EConvertError, 'CheckInherits(parent, descendant)');
  Assert.WillRaiseDescendant(procedure begin CheckInherits(EConvertError, Exception) end, ETestFailure, 'CheckInherits reversed');

  CheckException(RaiseConvertError, Exception, 'CheckException descendant');
  Assert.WillRaiseDescendant(procedure begin CheckException(RaiseNothing, EConvertError) end, ETestFailure, 'CheckException nothing raised');
  Assert.WillRaise(procedure begin CheckException(RaiseConvertError, nil) end, EConvertError, 'CheckException nil class');
  CheckException(RaiseNothing, nil, 'CheckException nil class, nothing raised');

  first := TCompatBoth.Create;
  second := first as ICompatSecond;
  CheckSame(first, second, 'CheckSame(IUnknown) same object');
  Assert.WillRaiseDescendant(procedure begin CheckSame(first, TCompatBoth.Create as ICompatFirst) end, ETestFailure, 'CheckSame(IUnknown) other object');
{$WARN SYMBOL_DEPRECATED ON}
end;

{ TCompatAlwaysEqual }

function TCompatAlwaysEqual.Equals(Obj : TObject) : Boolean;
begin
  Result := Obj is TCompatAlwaysEqual;
end;

procedure TMyDUnitTest.CheckSame_Object_Compares_Identity;
var
  first : TCompatAlwaysEqual;
  second : TCompatAlwaysEqual;
begin
  first := TCompatAlwaysEqual.Create;
  second := TCompatAlwaysEqual.Create;
  try
    Assert.IsTrue(first.Equals(second), 'precondition: the two objects are Equal');
{$WARN SYMBOL_DEPRECATED OFF}
    CheckSame(first, first, 'CheckSame(TObject) same object');
    Assert.WillRaiseDescendant(procedure begin CheckSame(first, second) end, ETestFailure, 'CheckSame(TObject) other object');
{$WARN SYMBOL_DEPRECATED ON}
  finally
    second.Free;
    first.Free;
  end;
end;

procedure TMyDUnitTest.CheckEqualsBin_Compares_Values_Not_Digits;
begin
{$WARN SYMBOL_DEPRECATED OFF}
  CheckEqualsBin($A5, $A5, 'CheckEqualsBin equal values', 8);
  Assert.WillRaiseDescendant(procedure begin CheckEqualsBin($1A5, $A5, '', 8) end, ETestFailure,
    'CheckEqualsBin passed values differing above the displayed digits');
  Assert.WillRaiseDescendant(procedure begin CheckEqualsBin($A4, $A5, '', 8) end, ETestFailure,
    'CheckEqualsBin passed different values');
{$WARN SYMBOL_DEPRECATED ON}
end;

procedure TMyDUnitTest.CheckIs_Nil_Object_Fails;
var
  obj : TObject;
begin
  obj := EConvertError.Create('probe');
  try
{$WARN SYMBOL_DEPRECATED OFF}
    CheckIs(obj, Exception, 'CheckIs descendant instance');
    Assert.WillRaise(procedure begin CheckIs(obj, TCompatAlwaysEqual) end, ETestFailure, 'CheckIs passed an unrelated class');
    Assert.WillRaise(procedure begin CheckIs(nil, Exception) end, ETestFailure, 'CheckIs( nil ) did not fail cleanly');
{$WARN SYMBOL_DEPRECATED ON}
  finally
    obj.Free;
  end;
end;

{ TMyDUnitTestSetup }

procedure TMyDUnitTestSetup.ATest;
begin
{$WARN SYMBOL_DEPRECATED OFF}
  CheckNotNull(FObject);
{$WARN SYMBOL_DEPRECATED ON}
end;

procedure TMyDUnitTestSetUp.SetUp;
begin
  inherited;
  FObject := TObject.Create;
end;

procedure TMyDUnitTestSetup.TearDown;
begin
  FObject.Free;
  inherited;
end;

procedure TMyDUnitTestSetup.Test_TestName;
begin
  Status('The Test Name is : ' + Self.Name);
{$WARN SYMBOL_DEPRECATED OFF}
  CheckEqualsString('Test_TestName', Self.Name, 'Test Name not working');
{$WARN SYMBOL_DEPRECATED ON}
end;

initialization
  TDUnitX.RegisterTestFixture(TMyDUnitTest);
  TDUnitX.RegisterTestFixture(TMyDUnitTestSetup);

end.

