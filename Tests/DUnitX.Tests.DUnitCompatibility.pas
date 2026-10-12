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
  ICompatFirst = interface
    ['{3C0D7B0E-5A61-4C2B-9C59-1E0A9B4C7D11}']
  end;

  ICompatSecond = interface
    ['{8F7B2C44-0D3E-4B9A-A6E1-52C7D0F3B812}']
  end;

  TCompatBoth = class(TInterfacedObject, ICompatFirst, ICompatSecond)
  end;

  // a typical DUnit like class
{$M+}
  TMyDUnitTest = class(TTestCase)
  private
    procedure RaiseConvertError;
    procedure RaiseNothing;
  published
    procedure ATest;
    // Proves the compatibility checks keep DUnit's semantics: string checks are case-sensitive, CheckInherits tests
    // actual.InheritsFrom(expected), CheckException accepts a descendant and lets an exception through when no class
    // is named, and CheckSame(IUnknown) compares object identity rather than the interface pointers passed.
    procedure Checks_Have_DUnit_Semantics;
    // Proves CheckEqualsBin compares the values, as DUnit does: values that differ only above the displayed digits
    // fail. Issue #398 item 4.
    procedure CheckEqualsBin_Compares_Values_Not_Digits;
  end;

{$M+}
  TMyDUnitTestSetup = class(TTestCase)
  protected
    FObject : TObject;
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure ATest;
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

