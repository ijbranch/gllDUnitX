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

unit DUnitX.DUnitCompatibility;

/// <summary>
///   Provides basic source compatibility with DUnit tests (not the DUnit framework itself), so a DUnit
///   <c>TTestCase</c> descendant can run under DUnitX with its <c>Check*</c> calls mapped onto <c>Assert</c>.
/// </summary>

interface

{$I DUnitX.inc}

uses
{$IFDEF USE_NS}
  System.SysUtils,
{$ELSE}
  SysUtils,
{$ENDIF}
  DUnitX.TestFramework;

type
  /// <summary>
  ///   Stand-in for DUnit's <c>TTestCase</c>: a DUnit test class inheriting from it compiles and runs under DUnitX.
  ///   <c>SetUp</c>/<c>TearDown</c> overrides are called through DUnitX's setup and teardown attributes, and every
  ///   <c>Check*</c> method forwards to the matching <c>Assert</c> method, keeping DUnit's semantics.
  /// </summary>
  TTestCase = class
  protected
    /// <summary>Override to prepare each test, as in DUnit; called before every test. Does nothing here.</summary>
    procedure SetUp; virtual;
    /// <summary>Override to clean up after each test, as in DUnit; called after every test. Does nothing here.</summary>
    procedure TearDown; virtual;
    /// <summary>Reads the name of the test currently running.</summary>
    /// <returns>The current test's name, from the test runner.</returns>
    function GetName : string;
  public
    /// <summary>Checks that a condition is true. Same as <c>CheckTrue</c>.</summary>
    /// <param name="condition">The condition to check.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <exception cref="ETestFailure">The condition is false.</exception>
    procedure Check(const condition : Boolean; const msg : string = ''); deprecated 'Use DUnitX.Assert class';
    /// <summary>Checks that a condition is true.</summary>
    /// <param name="condition">The condition to check.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <exception cref="ETestFailure">The condition is false.</exception>
    procedure CheckTrue(const condition : Boolean; const msg : string = ''); deprecated 'Use DUnitX.Assert class';
    /// <summary>Checks that a condition is false.</summary>
    /// <param name="condition">The condition to check.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <exception cref="ETestFailure">The condition is true.</exception>
    procedure CheckFalse(const condition : Boolean; const msg : string = ''); deprecated 'Use DUnitX.Assert class';
    /// <summary>Checks that two floating-point values are exactly equal (a delta of zero).</summary>
    /// <param name="expected">The expected value.</param>
    /// <param name="actual">The value produced.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <exception cref="ETestFailure">The values differ.</exception>
    procedure CheckEquals(const expected, actual : extended; const msg : string = ''); overload; deprecated 'Use DUnitX.Assert class';
    /// <summary>Checks that two floating-point values are equal within a tolerance.</summary>
    /// <param name="expected">The expected value.</param>
    /// <param name="actual">The value produced.</param>
    /// <param name="delta">The largest difference still treated as equal.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <exception cref="ETestFailure">The values differ by more than <c>delta</c>.</exception>
    procedure CheckEquals(const expected, actual : extended; const delta : extended; const msg : string = ''); overload; deprecated 'Use DUnitX.Assert class';
    /// <summary>Checks that two integers are equal.</summary>
    /// <param name="expected">The expected value.</param>
    /// <param name="actual">The value produced.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <exception cref="ETestFailure">The values differ.</exception>
    procedure CheckEquals(const expected, actual : integer; const msg : string = ''); overload; deprecated 'Use DUnitX.Assert class';
    /// <summary>Checks that two unsigned 32-bit values are equal.</summary>
    /// <param name="expected">The expected value.</param>
    /// <param name="actual">The value produced.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <exception cref="ETestFailure">The values differ.</exception>
    procedure CheckEquals(const expected, actual : Cardinal; const msg : string = ''); overload; deprecated 'Use DUnitX.Assert class';
    /// <summary>Checks that two 64-bit integers are equal.</summary>
    /// <param name="expected">The expected value.</param>
    /// <param name="actual">The value produced.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <exception cref="ETestFailure">The values differ.</exception>
    procedure CheckEquals(const expected, actual : int64; const msg : string = ''); overload; deprecated 'Use DUnitX.Assert class';
    /// <summary>Checks that two strings are equal, case-sensitively (as DUnit does).</summary>
    /// <param name="expected">The expected string.</param>
    /// <param name="actual">The string produced.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <exception cref="ETestFailure">The strings differ, including in case only.</exception>
    procedure CheckEquals(const expected, actual : UnicodeString; const msg : string = ''); overload; deprecated 'Use DUnitX.Assert class';
{$IFNDEF NEXTGEN}
    /// <summary>Checks that two ANSI strings are equal.</summary>
    /// <param name="expected">The expected string.</param>
    /// <param name="actual">The string produced.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <exception cref="ETestFailure">The strings differ.</exception>
    procedure CheckEquals(const expected, actual : AnsiString; const msg : string = ''); overload; deprecated 'Use DUnitX.Assert class';
    /// <summary>Checks that two short strings are equal.</summary>
    /// <param name="expected">The expected string.</param>
    /// <param name="actual">The string produced.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <exception cref="ETestFailure">The strings differ.</exception>
    procedure CheckEquals(const expected, actual : ShortString; const msg : string = ''); overload; deprecated 'Use DUnitX.Assert class';
{$ENDIF}
    /// <summary>Checks that two strings are equal, case-sensitively.</summary>
    /// <param name="expected">The expected string.</param>
    /// <param name="actual">The string produced.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <exception cref="ETestFailure">The strings differ, including in case only.</exception>
    procedure CheckEqualsString(const expected, actual : string; const msg : string = ''); deprecated 'Use DUnitX.Assert class';
{$IFNDEF NEXTGEN}
    /// <summary>Checks that two wide strings are equal, case-sensitively.</summary>
    /// <param name="expected">The expected string.</param>
    /// <param name="actual">The string produced.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <exception cref="ETestFailure">The strings differ, including in case only.</exception>
    procedure CheckEquals(const expected, actual : WideString; const msg : string = ''); overload; deprecated 'Use DUnitX.Assert class';
    /// <summary>Checks that two wide strings are equal, case-sensitively.</summary>
    /// <param name="expected">The expected string.</param>
    /// <param name="actual">The string produced.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <exception cref="ETestFailure">The strings differ, including in case only.</exception>
    procedure CheckEqualsWideString(const expected, actual : WideString; const msg : string = ''); deprecated 'Use DUnitX.Assert class';
{$ENDIF}
    /// <summary>Checks that two memory blocks hold the same bytes.</summary>
    /// <param name="expected">The start of the expected bytes.</param>
    /// <param name="actual">The start of the bytes produced.</param>
    /// <param name="size">The number of bytes to compare.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <exception cref="ETestFailure">The blocks differ.</exception>
    procedure CheckEqualsMem(const expected, actual : pointer; const size : longword; const msg : string = ''); deprecated 'Use DUnitX.Assert class';
    /// <summary>Checks that two Boolean values are equal.</summary>
    /// <param name="expected">The expected value.</param>
    /// <param name="actual">The value produced.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <exception cref="ETestFailure">The values differ.</exception>
    procedure CheckEquals(const expected, actual : Boolean; const msg : string = ''); overload; deprecated 'Use DUnitX.Assert class';
    /// <summary>
    ///   Checks that two values are equal, reporting a difference as binary strings. As in DUnit, <c>digits</c> only
    ///   sets the display width; when the values differ above it, all 32 bits are shown.
    /// </summary>
    /// <param name="expected">The expected value.</param>
    /// <param name="actual">The value produced.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <param name="digits">The number of binary digits shown in the failure message.</param>
    /// <exception cref="ETestFailure">The values differ.</exception>
    procedure CheckEqualsBin(const expected, actual : longword; const msg : string = ''; digits : integer = 32); deprecated 'Use DUnitX.Assert class';
    /// <summary>Checks that two values are equal by comparing their hexadecimal forms.</summary>
    /// <param name="expected">The expected value.</param>
    /// <param name="actual">The value produced.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <param name="digits">The minimum number of hex digits each value is formatted to.</param>
    /// <exception cref="ETestFailure">The hexadecimal forms differ.</exception>
    procedure CheckEqualsHex(const expected, actual : longword; const msg : string = ''; digits : integer = 8); deprecated 'Use DUnitX.Assert class';

    /// <summary>Checks that two integers differ.</summary>
    /// <param name="expected">The value that must not be produced.</param>
    /// <param name="actual">The value produced.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <exception cref="ETestFailure">The values are equal.</exception>
    procedure CheckNotEquals(const expected, actual : integer; const msg : string = ''); overload; deprecated 'Use DUnitX.Assert class';
    /// <summary>Checks that two unsigned 32-bit values differ.</summary>
    /// <param name="expected">The value that must not be produced.</param>
    /// <param name="actual">The value produced.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <exception cref="ETestFailure">The values are equal.</exception>
    procedure CheckNotEquals(const expected, actual : Cardinal; const msg : string = ''); overload; deprecated 'Use DUnitX.Assert class';
    /// <summary>Checks that two 64-bit integers differ.</summary>
    /// <param name="expected">The value that must not be produced.</param>
    /// <param name="actual">The value produced.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <exception cref="ETestFailure">The values are equal.</exception>
    procedure CheckNotEquals(const expected, actual : int64; const msg : string = ''); overload; deprecated 'Use DUnitX.Assert class';
    /// <summary>Checks that two floating-point values differ by more than a tolerance.</summary>
    /// <param name="expected">The value that must not be produced.</param>
    /// <param name="actual">The value produced.</param>
    /// <param name="delta">The largest difference still treated as equal.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <exception cref="ETestFailure">The values are equal within <c>delta</c>.</exception>
    procedure CheckNotEquals(const expected : extended; const actual : extended; const delta : extended = 0; const msg : string = ''); overload; deprecated
      'Use DUnitX.Assert class';
    /// <summary>Checks that two strings differ, case-sensitively.</summary>
    /// <param name="expected">The string that must not be produced.</param>
    /// <param name="actual">The string produced.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <exception cref="ETestFailure">The strings are identical.</exception>
    procedure CheckNotEquals(const expected, actual : string; const msg : string = ''); overload; deprecated 'Use DUnitX.Assert class';
    /// <summary>Checks that two strings differ, case-sensitively.</summary>
    /// <param name="expected">The string that must not be produced.</param>
    /// <param name="actual">The string produced.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <exception cref="ETestFailure">The strings are identical.</exception>
    procedure CheckNotEqualsString(const expected, actual : string; const msg : string = ''); deprecated 'Use DUnitX.Assert class';
{$IFNDEF NEXTGEN}
    /// <summary>Checks that two wide strings differ, case-sensitively.</summary>
    /// <param name="expected">The string that must not be produced.</param>
    /// <param name="actual">The string produced.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <exception cref="ETestFailure">The strings are identical.</exception>
    procedure CheckNotEquals(const expected, actual : WideString; const msg : string = ''); overload; deprecated 'Use DUnitX.Assert class';
    /// <summary>Checks that two wide strings differ, case-sensitively.</summary>
    /// <param name="expected">The string that must not be produced.</param>
    /// <param name="actual">The string produced.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <exception cref="ETestFailure">The strings are identical.</exception>
    procedure CheckNotEqualsWideString(const expected, actual : WideString; const msg : string = ''); deprecated 'Use DUnitX.Assert class';
{$ENDIF}
    /// <summary>Checks that two memory blocks do not hold the same bytes.</summary>
    /// <param name="expected">The start of the bytes that must not be matched.</param>
    /// <param name="actual">The start of the bytes produced.</param>
    /// <param name="size">The number of bytes to compare.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <exception cref="ETestFailure">The blocks are identical.</exception>
    procedure CheckNotEqualsMem(const expected, actual : pointer; const size : longword; const msg : string = ''); deprecated 'Use DUnitX.Assert class';
    /// <summary>Checks that two Boolean values differ.</summary>
    /// <param name="expected">The value that must not be produced.</param>
    /// <param name="actual">The value produced.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <exception cref="ETestFailure">The values are equal.</exception>
    procedure CheckNotEquals(const expected, actual : Boolean; const msg : string = ''); overload; deprecated 'Use DUnitX.Assert class';
    /// <summary>Checks that two values differ; the binary display width is accepted for DUnit compatibility only.</summary>
    /// <param name="expected">The value that must not be produced.</param>
    /// <param name="actual">The value produced.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <param name="digits">Not used: the values themselves are compared.</param>
    /// <exception cref="ETestFailure">The values are equal.</exception>
    procedure CheckNotEqualsBin(const expected, actual : longword; const msg : string = ''; digits : integer = 32); deprecated 'Use DUnitX.Assert class';
    /// <summary>Checks that two values differ by comparing their hexadecimal forms.</summary>
    /// <param name="expected">The value that must not be produced.</param>
    /// <param name="actual">The value produced.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <param name="digits">The minimum number of hex digits each value is formatted to.</param>
    /// <exception cref="ETestFailure">The hexadecimal forms are equal.</exception>
    procedure CheckNotEqualsHex(const expected, actual : longword; const msg : string = ''; digits : integer = 8); deprecated 'Use DUnitX.Assert class';

    /// <summary>Checks that an interface reference is assigned.</summary>
    /// <param name="obj">The reference to check.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <exception cref="ETestFailure">The reference is nil.</exception>
    procedure CheckNotNull(const obj : IUnknown; const msg : string = ''); overload; deprecated 'Use DUnitX.Assert class';
    /// <summary>Checks that an interface reference is nil.</summary>
    /// <param name="obj">The reference to check.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <exception cref="ETestFailure">The reference is assigned.</exception>
    procedure CheckNull(const obj : IUnknown; const msg : string = ''); overload; deprecated 'Use DUnitX.Assert class';
    /// <summary>
    ///   Checks that two interface references belong to the same object, whichever of its interfaces was passed: their
    ///   <c>IInterface</c> identities are compared.
    /// </summary>
    /// <param name="expected">The expected reference.</param>
    /// <param name="actual">The reference produced.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <exception cref="ETestFailure">The references belong to different objects.</exception>
    procedure CheckSame(const expected, actual : IInterface; const msg : string = ''); overload; deprecated 'Use DUnitX.Assert class';
    /// <summary>Checks that two object references are the same instance (identity, as in DUnit, not <c>Equals</c>).</summary>
    /// <param name="expected">The expected instance.</param>
    /// <param name="actual">The instance produced.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <exception cref="ETestFailure">The references are different instances.</exception>
    procedure CheckSame(const expected, actual : TObject; const msg : string = ''); overload; deprecated 'Use DUnitX.Assert class';

    /// <summary>Checks that an object reference is assigned.</summary>
    /// <param name="obj">The reference to check.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <exception cref="ETestFailure">The reference is nil.</exception>
    procedure CheckNotNull(const obj : TObject; const msg : string = ''); overload; deprecated 'Use DUnitX.Assert class';
    /// <summary>Checks that an object reference is nil.</summary>
    /// <param name="obj">The reference to check.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <exception cref="ETestFailure">The reference is assigned.</exception>
    procedure CheckNull(const obj : TObject; const msg : string = ''); overload; deprecated 'Use DUnitX.Assert class';

    /// <summary>
    ///   Checks that a method raises an exception of a class or one of its descendants, with DUnit's semantics: when no
    ///   class is given, the method is simply called and any exception it raises propagates.
    /// </summary>
    /// <param name="AMethod">The method to call.</param>
    /// <param name="AExceptionClass">The exception class expected, or nil to just run the method.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <exception cref="ETestFailure">The method raised nothing, or an exception of an unrelated class.</exception>
    procedure CheckException(const AMethod : TTestMethod; const AExceptionClass : ExceptClass; const msg : string = ''); deprecated 'Use DUnitX.Assert class';
    /// <summary>Checks that two class references are the same class.</summary>
    /// <param name="expected">The expected class.</param>
    /// <param name="actual">The class produced.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <exception cref="ETestFailure">The classes differ.</exception>
    procedure CheckEquals(const expected, actual : TClass; const msg : string = ''); overload; deprecated 'Use DUnitX.Assert class';
    /// <summary>Checks that <c>actual</c> is <c>expected</c> or descends from it (DUnit's argument order).</summary>
    /// <param name="expected">The ancestor class.</param>
    /// <param name="actual">The class that must inherit from it.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <exception cref="ETestFailure">The class does not inherit from <c>expected</c>.</exception>
    procedure CheckInherits(const expected, actual : TClass; const msg : string = ''); overload; deprecated 'Use DUnitX.Assert class';
    /// <summary>Checks that an object is an instance of a class or one of its descendants.</summary>
    /// <param name="AObject">The object to check; must be assigned.</param>
    /// <param name="AClass">The class it must be.</param>
    /// <param name="msg">The message reported on failure.</param>
    /// <exception cref="ETestFailure">The object's class does not inherit from <c>AClass</c>.</exception>
    procedure CheckIs(const AObject : TObject; const AClass : TClass; const msg : string = ''); overload; deprecated 'Use DUnitX.Assert class';

    /// <summary>Writes a status message to the test log, as DUnit's <c>Status</c> does. Same as <c>WriteLn</c>.</summary>
    /// <param name="msg">The message text.</param>
    procedure Status(const msg : string);
    /// <summary>
    ///   Redirects a DUnit test's <c>WriteLn</c> to the active runner's loggers as an information message, or to the
    ///   console when no runner is active.
    /// </summary>
    /// <param name="msg">The message text.</param>
    procedure WriteLn(const msg : string); overload;
    /// <summary>Writes an empty line to the test log.</summary>
    procedure WriteLn; overload;
    /// <summary>DUnitX setup method: calls the DUnit-style <c>SetUp</c> before each test.</summary>
    [Setup]
    procedure TestSetupMethod;
    /// <summary>DUnitX teardown method: calls the DUnit-style <c>TearDown</c> after each test.</summary>
    [TearDown]
    procedure TestTeardownMethod;
    /// <summary>The name of the test currently running.</summary>
    property Name : string read GetName;
  end;

implementation

uses
  DUnitX.TestRunner;

//Borrowed from DUnit.

function IntToBin(const value, digits : longword) : string;
const
  ALL_32_BIT_0      = '00000000000000000000000000000000';
var
  counter : integer;
  pow : integer;
begin
  Result := ALL_32_BIT_0;
  SetLength(Result, digits);
  pow := 1 shl (digits - 1);
  if value <> 0 then
    for counter := 0 to digits - 1 do
    begin
      if (value and (pow shr counter)) <> 0 then
      begin
{$IFDEF NEXTGEN}
        Result.Remove(counter, 1);
        Result.Insert(counter, '1');
{$ELSE}
        Result[counter + 1] := '1';
{$ENDIF}
      end;
    end;
end;

procedure TTestCase.Check(const condition : Boolean; const msg : string);
begin
  Assert.IsTrue(condition, msg);
end;

procedure TTestCase.CheckTrue(const condition : Boolean; const msg : string);
begin
  Assert.IsTrue(condition, msg);
end;

function TTestCase.GetName : string;
begin
  result := TDUnitXTestRunner.GetCurrentTestName;
end;

procedure TTestCase.SetUp;
begin

end;

procedure TTestCase.Status(const msg : string);
begin
  Self.WriteLn(msg);
end;

procedure TTestCase.TearDown;
begin

end;

procedure TTestCase.TestSetupMethod;
begin
  Self.SetUp;
end;

procedure TTestCase.TestTeardownMethod;
begin
  Self.TearDown;
end;

procedure TTestCase.WriteLn(const msg : string);
var
  runner : ITestRunner;
begin
  runner := TDUnitXTestRunner.GetActiveRunner;
  if runner <> nil then
    runner.Log(TLogLevel.Information, msg)
  else
    System.Writeln(msg);
end;

procedure TTestCase.WriteLn;
begin
  Self.WriteLn('');
end;

procedure TTestCase.CheckFalse(const condition : Boolean; const msg : string);
begin
  Assert.IsFalse(condition, msg);
end;

procedure TTestCase.CheckEquals(const expected, actual : extended; const msg : string);
begin
  Assert.AreEqual(expected, actual, 0, msg);
end;

procedure TTestCase.CheckEquals(const expected, actual : extended; const delta : extended; const msg : string);
begin
  Assert.AreEqual(expected, actual, delta, msg);
end;

procedure TTestCase.CheckEquals(const expected, actual : integer; const msg : string);
begin
{$IFDEF DELPHI_XE2_UP}
  Assert.AreEqual<integer>(expected, actual, msg);
{$ELSE}
  Assert.IsTrue(expected = actual, msg);
{$ENDIF}
end;

procedure TTestCase.CheckEquals(const expected, actual : Cardinal; const msg : string);
begin
{$IFDEF DELPHI_XE2_UP}
  Assert.AreEqual<Cardinal>(expected, actual, msg);
{$ELSE}
  Assert.IsTrue(expected = actual, msg);
{$ENDIF}
end;

procedure TTestCase.CheckEquals(const expected, actual : int64; const msg : string);
begin
{$IFDEF DELPHI_XE2_UP}
  Assert.AreEqual<Int64>(expected, actual, msg);
{$ELSE}
  Assert.IsTrue(expected = actual, msg);
{$ENDIF}
end;

procedure TTestCase.CheckEquals(const expected, actual : UnicodeString; const msg : string);
begin
{$IFDEF DELPHI_XE2_UP}
  Assert.AreEqual(expected, actual, false, msg);
{$ELSE}
  Assert.IsTrue(expected = actual, msg);
{$ENDIF}
end;

{$IFNDEF NEXTGEN}
procedure TTestCase.CheckEquals(const expected, actual : AnsiString; const msg : string);
begin
{$IFDEF DELPHI_XE2_UP}
  Assert.AreEqual<AnsiString>(expected, actual, msg);
{$ELSE}
  Assert.IsTrue(expected = actual, msg);
{$ENDIF}
end;

procedure TTestCase.CheckEquals(const expected, actual : ShortString; const msg : string);
begin
{$IFDEF DELPHI_XE2_UP}
  Assert.AreEqual<ShortString>(expected, actual, msg);
{$ELSE}
  Assert.IsTrue(expected = actual, msg);
{$ENDIF}
end;
{$ENDIF}

procedure TTestCase.CheckEqualsString(const expected, actual : string; const msg : string);
begin
  Assert.AreEqual(expected, actual, false, msg);
end;

{$IFNDEF NEXTGEN}
procedure TTestCase.CheckEquals(const expected, actual : WideString; const msg : string);
begin
  Assert.AreEqual(expected, actual, false, msg);
end;

procedure TTestCase.CheckEqualsWideString(const expected, actual : WideString; const msg : string);
begin
  Assert.AreEqual(expected, actual, false, msg);
end;
{$ENDIF}

procedure TTestCase.CheckEqualsMem(const expected, actual : pointer; const size : longword; const msg : string = '');
begin
  Assert.AreEqualMemory(expected, actual, size, msg);
end;

procedure TTestCase.CheckEquals(const expected, actual : Boolean; const msg : string);
begin
{$IFDEF DELPHI_XE2_UP}
  Assert.AreEqual<Boolean>(expected, actual, msg);
{$ELSE}
  Assert.IsTrue(expected = actual, msg);
{$ENDIF}
end;

procedure TTestCase.CheckEqualsBin(const expected, actual : longword; const msg : string; digits : integer);
begin
  //As in DUnit, the values are compared and digits only sets the display width; show all 32 bits when the
  //difference lies above the requested digits, or the failure would show two equal strings.
  if (expected <> actual) and (IntToBin(expected, digits) = IntToBin(actual, digits)) then
    digits := 32;
  Assert.AreEqual(IntToBin(expected, digits), IntToBin(actual, digits), false, msg);
end;

procedure TTestCase.CheckEqualsHex(const expected, actual : longword; const msg : string; digits : integer);
begin
  Assert.AreEqual(IntToHex(expected, digits), IntToHex(actual, digits), true, msg);
end;

procedure TTestCase.CheckNotEquals(const expected, actual : integer; const msg : string);
begin
{$IFDEF DELPHI_XE2_UP}
  Assert.AreNotEqual<integer>(expected, actual, msg);
{$ELSE}
  Assert.IsFalse(expected = actual, msg);
{$ENDIF}
end;

procedure TTestCase.CheckNotEquals(const expected, actual : Cardinal; const msg : string);
begin
{$IFDEF DELPHI_XE2_UP}
  Assert.AreNotEqual<Cardinal>(expected, actual, msg);
{$ELSE}
  Assert.IsFalse(expected = actual, msg);
{$ENDIF}
end;

procedure TTestCase.CheckNotEquals(const expected, actual : int64; const msg : string);
begin
{$IFDEF DELPHI_XE2_UP}
  Assert.AreNotEqual<int64>(expected, actual, msg);
{$ELSE}
  Assert.IsFalse(expected = actual, msg);
{$ENDIF}
end;

procedure TTestCase.CheckNotEquals(const expected : extended; const actual : extended; const delta : extended; const msg : string);
begin
  Assert.AreNotEqual(expected, actual, delta, msg);
end;

procedure TTestCase.CheckNotEquals(const expected, actual : string; const msg : string);
begin
  Assert.AreNotEqual(expected, actual, false, msg);
end;

procedure TTestCase.CheckNotEqualsString(const expected, actual : string; const msg : string);
begin
  Assert.AreNotEqual(expected, actual, false, msg);
end;

{$IFNDEF NEXTGEN}
procedure TTestCase.CheckNotEquals(const expected, actual : WideString; const msg : string);
begin
  Assert.AreNotEqual(expected, actual, false, msg);
end;

procedure TTestCase.CheckNotEqualsWideString(const expected, actual : WideString; const msg : string);
begin
  Assert.AreNotEqual(expected, actual, false, msg);
end;
{$ENDIF}

procedure TTestCase.CheckNotEqualsMem(const expected, actual : pointer; const size : longword; const msg : string = '');
begin
  Assert.AreNotEqualMemory(expected, actual, size, msg);
end;

procedure TTestCase.CheckNotEquals(const expected, actual : Boolean; const msg : string);
begin
{$IFDEF DELPHI_XE2_UP}
  Assert.AreNotEqual<boolean>(expected, actual, msg);
{$ELSE}
  Assert.IsFalse(expected = actual, msg);
{$ENDIF}
end;

procedure TTestCase.CheckNotEqualsBin(const expected, actual : longword; const msg : string; digits : integer);
begin
{$IFDEF DELPHI_XE2_UP}
  Assert.AreNotEqual<longword>(expected, actual, msg);
{$ELSE}
  Assert.IsFalse(expected = actual, msg);
{$ENDIF}
end;

procedure TTestCase.CheckNotEqualsHex(const expected, actual : longword; const msg : string; digits : integer);
begin
  Assert.AreNotEqual(IntToHex(expected, digits), IntToHex(actual, digits), true, msg);
end;

procedure TTestCase.CheckNotNull(const obj : IUnknown; const msg : string);
begin
  Assert.IsNotNull(obj, msg);
end;

procedure TTestCase.CheckNull(const obj : IUnknown; const msg : string);
begin
  Assert.IsNull(obj, msg);
end;

procedure TTestCase.CheckSame(const expected, actual : IUnknown; const msg : string);
begin
{$IFDEF DELPHI_XE2_UP}
  //Same object, whichever of its interfaces was passed: compare the IUnknown identities.
  Assert.AreEqual<IInterface>(expected as IInterface, actual as IInterface, msg);
{$ELSE}
  Assert.IsTrue(expected = actual, msg);
{$ENDIF}
end;

procedure TTestCase.CheckSame(const expected, actual : TObject; const msg : string);
begin
  //DUnit's CheckSame is an identity check; AreEqual<TObject> would call Equals.
  Assert.AreSame(expected, actual, msg);
end;

procedure TTestCase.CheckNotNull(const obj : TObject; const msg : string);
begin
  Assert.IsNotNull(obj, msg);
end;

procedure TTestCase.CheckNull(const obj : TObject; const msg : string);
begin
  Assert.IsNull(obj, msg);
end;

procedure TTestCase.CheckException(const AMethod : TTestMethod; const AExceptionClass : ExceptClass; const msg : string);
begin
  //DUnit semantics: a descendant of AExceptionClass passes; with no class, any exception propagates.
  if AExceptionClass = nil then
    AMethod
  else
    Assert.WillRaiseDescendant(AMethod, AExceptionClass, msg);
end;

procedure TTestCase.CheckEquals(const expected, actual : TClass; const msg : string);
begin
  Assert.AreEqual(expected, actual, msg);
end;

procedure TTestCase.CheckInherits(const expected, actual : TClass; const msg : string);
begin
  //DUnit checks actual.InheritsFrom(expected); Assert.InheritsFrom takes (descendant, parent).
  Assert.InheritsFrom(actual, expected, msg);
end;

procedure TTestCase.CheckIs(const AObject : TObject; const AClass : TClass; const msg : string);
begin
  //A nil object fails the check, as in DUnit; reading its ClassType was an access violation.
  Assert.IsNotNull(AObject, msg);
  Assert.InheritsFrom(AObject.ClassType, AClass, msg);
end;

end.

