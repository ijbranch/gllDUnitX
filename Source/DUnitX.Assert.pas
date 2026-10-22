{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2017 Vincent Parrett & Contributors               }
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

unit DUnitX.Assert;

// This unit should ONLY contain Assert commands and mechanisms that are
// not directly tied to DUnitX to keep the file neutral and usable in other
// test frameworks such as DUnit.  DUnitX specific implementations should be
// implemented in DUnitX.Assert.Ex.pas

interface

{$I DUnitX.inc}

uses
{$IFDEF USE_NS}
  System.Classes,
  System.SysUtils;
{$ELSE}
  Classes,
  SysUtils;
{$ENDIF}

type
  /// <summary>
  ///   A parameterless anonymous method, the form of code block passed to the WillRaise / WillNotRaise family.
  /// </summary>
  TTestLocalMethod = TProc;

  /// <summary>
  ///   A parameterless method of an object, accepted by the WillRaise / WillNotRaise overloads that take a method
  ///   pointer instead of an anonymous method.
  /// </summary>
  TTestMethod = procedure of object;

  /// <summary>
  ///   The framework-neutral assertion library. Every check is a class method that raises the configured failure
  ///   exception when the check does not hold.
  /// </summary>
  /// <remarks>
  ///   <para>
  ///     This unit holds only assertions that are not tied to DUnitX, so that it stays usable from other test
  ///     frameworks such as DUnit; DUnitX-specific assertions belong in DUnitX.Assert.Ex.
  ///   </para>
  ///   <para>
  ///     The exception classes raised for a failure, a pass and an ignore are set through <c>TestFailure</c>,
  ///     <c>TestPass</c> and <c>TestIgnored</c>; DUnitX sets them to <c>ETestFailure</c>, <c>ETestPass</c> and
  ///     <c>ETestIgnored</c>. Failures are raised at the caller's address so the debugger and stack trace stop on the
  ///     test line, not inside this class.
  ///   </para>
  ///   <para>
  ///     Every check except <c>Pass</c>, <c>Ignore</c> and <c>Fail</c> calls <c>OnAssert</c> first, which is how the
  ///     runner counts assertions for FailsOnNoAsserts.
  ///   </para>
  /// </remarks>
  Assert = class
  private
    /// <summary>Whether string comparisons without an ignoreCase argument ignore case; True by default.</summary>
    class var fIgnoreCaseDefault : boolean;
    /// <summary>Called by every assertion before it checks anything; the runner uses it to count assertions.</summary>
    class var fOnAssert : TProc;
    /// <summary>Exception class raised by a failing assertion.</summary>
    class var fTestFailure : ExceptClass;
    /// <summary>Exception class raised by <c>Pass</c>.</summary>
    class var fTestPass : ExceptClass;
    /// <summary>Exception class raised by <c>Ignore</c>.</summary>
    class var fTestIgnored : ExceptClass;
    /// <summary>
    ///   Fails unless the exception's class is exactly the expected class; a nil expected class accepts any exception.
    /// </summary>
    /// <param name="E">
    ///   The exception that was raised.
    /// </param>
    /// <param name="exceptionClass">
    ///   The expected class, or nil for any.
    /// </param>
    /// <param name="msg">
    ///   The caller's message, added to the failure text.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   <paramref name="E" /> is not exactly <paramref name="exceptionClass" />.
    /// </exception>
    class procedure CheckExceptionClass(E : Exception; const exceptionClass : ExceptClass; const msg : string);
    /// <summary>
    ///   Fails unless the exception is the expected class or a descendant; a nil expected class accepts any exception.
    /// </summary>
    /// <param name="E">
    ///   The exception that was raised.
    /// </param>
    /// <param name="exceptionClass">
    ///   The expected base class, or nil for any.
    /// </param>
    /// <param name="msg">
    ///   The caller's message, added to the failure text.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   <paramref name="E" /> does not inherit from <paramref name="exceptionClass" />.
    /// </exception>
    class procedure CheckExceptionClassDescendant(E : Exception; const exceptionClass : ExceptClass; const msg : string);
    /// <summary>
    ///   Decides whether an exception caught from the code under test is really a test outcome (a failure, pass or
    ///   ignore raised by an assertion inside that code) that must be re-raised rather than treated as the exception
    ///   being tested for.
    /// </summary>
    /// <param name="E">
    ///   The caught exception.
    /// </param>
    /// <param name="exceptionClass">
    ///   The class the caller is testing for, or nil.
    /// </param>
    /// <returns>
    ///   True when <paramref name="E" /> is a test-outcome exception and the caller did not explicitly ask for a
    ///   framework exception.
    /// </returns>
    class function IsUnrequestedTestOutcome(E : Exception; const exceptionClass : ExceptClass) : boolean;
  protected
    /// <summary>
    ///   Compares the whole contents of two streams byte for byte, restoring both stream positions afterwards.
    /// </summary>
    /// <param name="stream1">
    ///   First stream.
    /// </param>
    /// <param name="stream2">
    ///   Second stream.
    /// </param>
    /// <returns>
    ///   True when both are the same instance, or have the same size and identical bytes; a stream that delivers fewer
    ///   bytes than its Size is treated as unequal.
    /// </returns>
    class function StreamsEqual(const stream1, stream2 : TStream) : boolean;
    /// <summary>
    ///   Prefixes a non-empty message with a line break, for appending to a failure text.
    /// </summary>
    /// <param name="msg">
    ///   The message.
    /// </param>
    /// <returns>
    ///   <c>sLineBreak + msg</c>, or an empty string when <paramref name="msg" /> is empty.
    /// </returns>
    class function AddLineBreak(const msg : string) : string;
    /// <summary>
    ///   Calls <c>OnAssert</c>, if assigned, to record that an assertion was made.
    /// </summary>
    class procedure DoAssert; inline;
  public
    /// <summary>
    ///   Stops the test immediately and reports it as passed.
    /// </summary>
    /// <param name="message">
    ///   Text recorded with the pass.
    /// </param>
    /// <exception cref="ETestPass">
    ///   Always (the <c>TestPass</c> class).
    /// </exception>
    /// <remarks>
    ///   Does not count as an assertion. Never use it to skip a test - use <c>Ignore</c>.
    /// </remarks>
    class procedure Pass(const message : string = '');
    ///  <summary>
    ///    Stops the test and reports it as IGNORED - neither passed nor
    ///    failed - carrying message as the reason.
    ///  </summary>
    ///  <param name="message">
    ///    The reason the test was skipped.
    ///  </param>
    ///  <exception cref="ETestIgnored">
    ///    Always (the <c>TestIgnored</c> class).
    ///  </exception>
    ///  <remarks>
    ///    For a test whose PRECONDITION is absent at run time: an external
    ///    tool, a source tree, a database. Prefer the [Ignore] attribute
    ///    when the condition is known at compile time; this is for when it
    ///    can only be discovered by looking.
    ///
    ///    Do NOT reach for Pass() to skip a test. A skipped test that
    ///    reports PASS is indistinguishable from one that verified
    ///    something, so the gap it leaves is invisible on every later run.
    ///    That is the whole reason this exists.
    ///
    ///    Deliberately does not count as an assertion, so a test cannot satisfy FailsOnNoAsserts by skipping itself.
    ///  </remarks>
    class procedure Ignore(const message : string = '');
    /// <summary>
    ///   Fails the test unconditionally.
    /// </summary>
    /// <param name="message">
    ///   The failure message.
    /// </param>
    /// <param name="errorAddrs">
    ///   Address to report the failure at (normally the caller's <c>ReturnAddress</c>), or nil for this method's own
    ///   return address.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   Always (the <c>TestFailure</c> class).
    /// </exception>
    class procedure Fail(const message : string = ''; const errorAddrs : pointer = nil);
    /// <summary>
    ///   Fails the test unconditionally with a formatted, trimmed message.
    /// </summary>
    /// <param name="message">
    ///   The format string.
    /// </param>
    /// <param name="args">
    ///   The format arguments.
    /// </param>
    /// <param name="errorAddrs">
    ///   Address to report the failure at, or nil for <c>Fail</c>'s own return address.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   Always.
    /// </exception>
    class procedure FailFmt(const message : string; const args : array of const; const errorAddrs : pointer = nil);

    /// <summary>
    ///   Fails the test with the "Not Implemented!" message; a placeholder for an unwritten test.
    /// </summary>
    /// <exception cref="ETestFailure">
    ///   Always.
    /// </exception>
    class procedure NotImplemented;

    /// <summary>
    ///   Asserts that two strings are equal.
    /// </summary>
    /// <param name="expected">
    ///   The expected string.
    /// </param>
    /// <param name="actual">
    ///   The actual string.
    /// </param>
    /// <param name="ignoreCase">
    ///   True compares with <c>SameText</c>; False with <c>SameStr</c>.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The strings differ.
    /// </exception>
    class procedure AreEqual(const expected : string; const actual : string; const ignoreCase : boolean; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that two strings are equal, IGNORING CASE unless <c>IgnoreCaseDefault</c> has been set to False.
    /// </summary>
    /// <param name="expected">
    ///   The expected string.
    /// </param>
    /// <param name="actual">
    ///   The actual string.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The strings differ.
    /// </exception>
    /// <remarks>
    ///   When casing is what is being tested, use the overload with <c>ignoreCase = False</c>.
    /// </remarks>
    class procedure AreEqual(const expected : string; const actual : string; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that two Double values are equal within a tolerance.
    /// </summary>
    /// <param name="expected">
    ///   The expected value.
    /// </param>
    /// <param name="actual">
    ///   The actual value.
    /// </param>
    /// <param name="tolerance">
    ///   Largest permitted difference; must not be negative.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The tolerance is negative, or the values differ by more than it.
    /// </exception>
    /// <remarks>
    ///   An infinity equals only itself; NaN equals nothing.
    /// </remarks>
    class procedure AreEqual(const expected, actual : Double; const tolerance : Double; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that two Double values are equal (tolerance 0, which <c>SameValue</c> widens to its default epsilon).
    /// </summary>
    /// <param name="expected">
    ///   The expected value.
    /// </param>
    /// <param name="actual">
    ///   The actual value.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The values differ.
    /// </exception>
    class procedure AreEqual(const expected, actual : Double; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that two Extended values are equal within a tolerance.
    /// </summary>
    /// <param name="expected">
    ///   The expected value.
    /// </param>
    /// <param name="actual">
    ///   The actual value.
    /// </param>
    /// <param name="tolerance">
    ///   Largest permitted difference; must not be negative.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The tolerance is negative, or the values differ by more than it.
    /// </exception>
    /// <remarks>
    ///   An infinity equals only itself; NaN equals nothing.
    /// </remarks>
    class procedure AreEqual(const expected, actual : Extended; const tolerance : Extended; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that two Extended values are equal (tolerance 0, which <c>SameValue</c> widens to its default epsilon).
    /// </summary>
    /// <param name="expected">
    ///   The expected value.
    /// </param>
    /// <param name="actual">
    ///   The actual value.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The values differ.
    /// </exception>
    class procedure AreEqual(const expected, actual : Extended; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that two Currency values are exactly equal.
    /// </summary>
    /// <param name="expected">
    ///   The expected value.
    /// </param>
    /// <param name="actual">
    ///   The actual value.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The values differ.
    /// </exception>
    class procedure AreEqual(const expected, actual : Currency; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that two class references are the same class.
    /// </summary>
    /// <param name="expected">
    ///   The expected class; may be nil.
    /// </param>
    /// <param name="actual">
    ///   The actual class; may be nil.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The classes differ.
    /// </exception>
    class procedure AreEqual(const expected, actual : TClass; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that two streams have identical contents (compared from position 0; positions are restored).
    /// </summary>
    /// <param name="expected">
    ///   The expected stream.
    /// </param>
    /// <param name="actual">
    ///   The actual stream.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The sizes or contents differ.
    /// </exception>
    class procedure AreEqual(const expected, actual : TStream; const message : string = ''); overload;
{$IFDEF DELPHI_XE2_UP}
    /// <summary>
    ///   Asserts that two values of any type are equal according to <c>TEqualityComparer&lt;T&gt;.Default</c>.
    /// </summary>
    /// <param name="expected">
    ///   The expected value.
    /// </param>
    /// <param name="actual">
    ///   The actual value.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The comparer reports the values unequal.
    /// </exception>
    /// <remarks>
    ///   Uses an equality comparer rather than <c>TComparer&lt;T&gt;</c>, which reports a Double NaN equal to
    ///   everything. Excluded before XE2 because of a Delphi 2010/XE compiler bug.
    /// </remarks>
    class procedure AreEqual<T>(const expected, actual : T; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that two arrays have the same length and equal elements, compared with
    ///   <c>TEqualityComparer&lt;T&gt;.Default</c>.
    /// </summary>
    /// <param name="expected">
    ///   The expected array.
    /// </param>
    /// <param name="actual">
    ///   The actual array.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The lengths differ, or an element differs (the first differing index is reported).
    /// </exception>
    class procedure AreEqual<T>(const expected, actual : TArray<T>; const message : string = ''); overload;
{$ENDIF}
    /// <summary>
    ///   Asserts that two Word values are equal.
    /// </summary>
    /// <param name="expected">
    ///   The expected value.
    /// </param>
    /// <param name="actual">
    ///   The actual value.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The values differ.
    /// </exception>
    class procedure AreEqual(const expected, actual : word; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that two Integer values are equal.
    /// </summary>
    /// <param name="expected">
    ///   The expected value.
    /// </param>
    /// <param name="actual">
    ///   The actual value.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The values differ.
    /// </exception>
    class procedure AreEqual(const expected, actual : Integer; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that two Int64 values are equal.
    /// </summary>
    /// <param name="expected">
    ///   The expected value.
    /// </param>
    /// <param name="actual">
    ///   The actual value.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The values differ.
    /// </exception>
    class procedure AreEqual(const expected, actual : Int64; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that an Integer and an Int64 are equal.
    /// </summary>
    /// <param name="expected">
    ///   The expected value.
    /// </param>
    /// <param name="actual">
    ///   The actual value.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The values differ.
    /// </exception>
    /// <remarks>
    ///   An Integer against an Int64 matches no overload exactly, so without this one overload resolution would pick
    ///   AreEqual&lt;T&gt; and type inference would fail with E2532.  On 64-bit, Count and Length are NativeInt (Int64);
    ///   on both platforms, Round and Trunc return Int64.  Declared on Win32 as well as Win64 (upstream has it on 64-bit
    ///   only), so a suite resolves the same overload on both.  The comparison is in 64 bits: nothing is truncated.
    /// </remarks>
    class procedure AreEqual(const expected : Integer; const actual : Int64; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that an Int64 and an Integer are equal.
    /// </summary>
    /// <param name="expected">
    ///   The expected value.
    /// </param>
    /// <param name="actual">
    ///   The actual value.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The values differ.
    /// </exception>
    /// <remarks>
    ///   The mirror of the Integer/Int64 overload; it exists for the same E2532 reason.
    /// </remarks>
    class procedure AreEqual(const expected : Int64; const actual : Integer; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that two Cardinal values are equal.
    /// </summary>
    /// <param name="expected">
    ///   The expected value.
    /// </param>
    /// <param name="actual">
    ///   The actual value.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The values differ.
    /// </exception>
    class procedure AreEqual(const expected, actual : cardinal; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that two Boolean values are equal.
    /// </summary>
    /// <param name="expected">
    ///   The expected value.
    /// </param>
    /// <param name="actual">
    ///   The actual value.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The values differ.
    /// </exception>
    class procedure AreEqual(const expected, actual : boolean; const message : string = ''); overload;

    /// <summary>
    ///   Asserts that two GUIDs are equal.
    /// </summary>
    /// <param name="expected">
    ///   The expected GUID.
    /// </param>
    /// <param name="actual">
    ///   The actual GUID.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The GUIDs differ.
    /// </exception>
    class procedure AreEqual(const expected, actual : TGUID; const message : string = ''); overload;

    /// <summary>
    ///   Asserts that two string lists have the same line count and equal lines (case-sensitive), skipping the given
    ///   line numbers.
    /// </summary>
    /// <param name="expected">
    ///   The expected lines.
    /// </param>
    /// <param name="actual">
    ///   The actual lines.
    /// </param>
    /// <param name="ignoreLines">
    ///   One-based line numbers not compared.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The counts differ, or a compared line differs (reported with its line number and position).
    /// </exception>
    class procedure AreEqual(const expected, actual : TStrings; const ignoreLines : array of integer; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that two string lists have the same line count and equal lines (case-sensitive).
    /// </summary>
    /// <param name="expected">
    ///   The expected lines.
    /// </param>
    /// <param name="actual">
    ///   The actual lines.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The counts differ, or a line differs.
    /// </exception>
    class procedure AreEqual(const expected, actual : TStrings; const message : string = ''); overload;

    /// <summary>
    ///   Asserts that two memory blocks hold the same bytes.
    /// </summary>
    /// <param name="expected">
    ///   Start of the expected block.
    /// </param>
    /// <param name="actual">
    ///   Start of the actual block.
    /// </param>
    /// <param name="size">
    ///   Number of bytes to compare.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The blocks differ.
    /// </exception>
    class procedure AreEqualMemory(const expected : Pointer; const actual : Pointer; const size : Cardinal; const message : string = '');

    /// <summary>
    ///   Asserts that two strings differ.
    /// </summary>
    /// <param name="expected">
    ///   The value the actual string must not equal.
    /// </param>
    /// <param name="actual">
    ///   The actual string.
    /// </param>
    /// <param name="ignoreCase">
    ///   True compares with <c>SameText</c>; False with <c>SameStr</c>.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The strings are equal.
    /// </exception>
    class procedure AreNotEqual(const expected : string; const actual : string; const ignoreCase : boolean; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that two strings differ, IGNORING CASE unless <c>IgnoreCaseDefault</c> has been set to False.
    /// </summary>
    /// <param name="expected">
    ///   The value the actual string must not equal.
    /// </param>
    /// <param name="actual">
    ///   The actual string.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The strings are equal.
    /// </exception>
    class procedure AreNotEqual(const expected : string; const actual : string; const message : string = ''); overload;

    /// <summary>
    ///   Asserts that two Extended values differ by more than a tolerance.
    /// </summary>
    /// <param name="expected">
    ///   The value the actual value must not equal.
    /// </param>
    /// <param name="actual">
    ///   The actual value.
    /// </param>
    /// <param name="tolerance">
    ///   Difference within which the values count as equal; must not be negative.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The tolerance is negative, or the values are equal within it.
    /// </exception>
    class procedure AreNotEqual(const expected, actual : Extended; const tolerance : Extended; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that two Extended values differ (tolerance 0, which <c>SameValue</c> widens to its default epsilon).
    /// </summary>
    /// <param name="expected">
    ///   The value the actual value must not equal.
    /// </param>
    /// <param name="actual">
    ///   The actual value.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The values are equal.
    /// </exception>
    class procedure AreNotEqual(const expected, actual : Extended; const message : string = ''); overload;

    /// <summary>
    ///   Asserts that two Double values differ by more than a tolerance.
    /// </summary>
    /// <param name="expected">
    ///   The value the actual value must not equal.
    /// </param>
    /// <param name="actual">
    ///   The actual value.
    /// </param>
    /// <param name="tolerance">
    ///   Difference within which the values count as equal; must not be negative.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The tolerance is negative, or the values are equal within it.
    /// </exception>
    class procedure AreNotEqual(const expected, actual : Double; const tolerance : double; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that two Double values differ (tolerance 0, which <c>SameValue</c> widens to its default epsilon).
    /// </summary>
    /// <param name="expected">
    ///   The value the actual value must not equal.
    /// </param>
    /// <param name="actual">
    ///   The actual value.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The values are equal.
    /// </exception>
    class procedure AreNotEqual(const expected, actual : Double; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that two Currency values differ.
    /// </summary>
    /// <param name="expected">
    ///   The value the actual value must not equal.
    /// </param>
    /// <param name="actual">
    ///   The actual value.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The values are equal.
    /// </exception>
    class procedure AreNotEqual(const expected, actual : Currency; const message : string = ''); overload;

    /// <summary>
    ///   Asserts that two class references are different classes.
    /// </summary>
    /// <param name="expected">
    ///   The class the actual class must not be; may be nil.
    /// </param>
    /// <param name="actual">
    ///   The actual class; may be nil.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The classes are the same.
    /// </exception>
    class procedure AreNotEqual(const expected, actual : TClass; const message : string = ''); overload;

    /// <summary>
    ///   Asserts that two streams differ in size or contents.
    /// </summary>
    /// <param name="expected">
    ///   The stream the actual stream must not match.
    /// </param>
    /// <param name="actual">
    ///   The actual stream.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The streams are the same instance or have identical contents.
    /// </exception>
    class procedure AreNotEqual(const expected, actual : TStream; const message : string = ''); overload;
{$IFDEF DELPHI_XE2_UP}
    /// <summary>
    ///   Asserts that two values of any type differ according to <c>TEqualityComparer&lt;T&gt;.Default</c>.
    /// </summary>
    /// <param name="expected">
    ///   The value the actual value must not equal.
    /// </param>
    /// <param name="actual">
    ///   The actual value.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The comparer reports the values equal.
    /// </exception>
    /// <remarks>
    ///   Excluded before XE2 because of a Delphi 2010/XE compiler bug.
    /// </remarks>
    class procedure AreNotEqual<T>(const expected, actual : T; const message : string = ''); overload;
{$ENDIF}
    /// <summary>
    ///   Asserts that two Integer values differ.
    /// </summary>
    /// <param name="expected">
    ///   The value the actual value must not equal.
    /// </param>
    /// <param name="actual">
    ///   The actual value.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The values are equal.
    /// </exception>
    class procedure AreNotEqual(const expected, actual : Integer; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that two Int64 values differ.
    /// </summary>
    /// <param name="expected">
    ///   The value the actual value must not equal.
    /// </param>
    /// <param name="actual">
    ///   The actual value.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The values are equal.
    /// </exception>
    class procedure AreNotEqual(const expected, actual : Int64; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that two GUIDs differ.
    /// </summary>
    /// <param name="expected">
    ///   The GUID the actual GUID must not equal.
    /// </param>
    /// <param name="actual">
    ///   The actual GUID.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The GUIDs are equal.
    /// </exception>
    class procedure AreNotEqual(const expected, actual : TGUID; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that two memory blocks do not hold the same bytes.
    /// </summary>
    /// <param name="expected">
    ///   Start of the block the actual block must not match.
    /// </param>
    /// <param name="actual">
    ///   Start of the actual block.
    /// </param>
    /// <param name="size">
    ///   Number of bytes to compare.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The blocks are identical.
    /// </exception>
    class procedure AreNotEqualMemory(const expected : Pointer; const actual : Pointer; const size : Cardinal; const message : string = '');

    /// <summary>
    ///   Asserts that two object references point to the same instance.
    /// </summary>
    /// <param name="expected">
    ///   The expected instance; may be nil.
    /// </param>
    /// <param name="actual">
    ///   The actual instance; may be nil.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The references differ.
    /// </exception>
    class procedure AreSame(const expected, actual : TObject; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that two interface references refer to the same object, compared through their IInterface identity.
    /// </summary>
    /// <param name="expected">
    ///   The expected reference; may be nil.
    /// </param>
    /// <param name="actual">
    ///   The actual reference; may be nil.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The references differ.
    /// </exception>
    class procedure AreSame(const expected, actual : IInterface; const message : string = ''); overload;

    /// <summary>
    ///   Asserts that two object references point to different instances.
    /// </summary>
    /// <param name="expected">
    ///   The instance the actual reference must not be; may be nil.
    /// </param>
    /// <param name="actual">
    ///   The actual instance; may be nil.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The references are the same (including both nil).
    /// </exception>
    class procedure AreNotSame(const expected, actual : TObject; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that two interface references refer to different objects, compared through their IInterface identity.
    /// </summary>
    /// <param name="expected">
    ///   The reference the actual reference must not match; may be nil.
    /// </param>
    /// <param name="actual">
    ///   The actual reference; may be nil.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The references are the same (including both nil).
    /// </exception>
    class procedure AreNotSame(const expected, actual : IInterface; const message : string = ''); overload;

{$IFDEF DELPHI_XE_UP}
    /// <summary>
    ///   Asserts that an enumerable contains a value, compared with <c>TEqualityComparer&lt;T&gt;.Default</c>.
    /// </summary>
    /// <param name="list">
    ///   The collection to search.
    /// </param>
    /// <param name="value">
    ///   The value that must be present.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   No element equals <paramref name="value" />.
    /// </exception>
    /// <remarks>
    ///   Excluded before XE because of a Delphi 2010 compiler bug.
    /// </remarks>
    class procedure Contains<T>(const list : IEnumerable<T>; const value : T; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that an array contains a value, compared with <c>TEqualityComparer&lt;T&gt;.Default</c>.
    /// </summary>
    /// <param name="arr">
    ///   The array to search.
    /// </param>
    /// <param name="value">
    ///   The value that must be present.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   No element equals <paramref name="value" />.
    /// </exception>
    class procedure Contains<T>(const arr : array of T; const value : T; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that an enumerable does not contain a value, compared with <c>TEqualityComparer&lt;T&gt;.Default</c>.
    /// </summary>
    /// <param name="list">
    ///   The collection to search.
    /// </param>
    /// <param name="value">
    ///   The value that must be absent.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   An element equals <paramref name="value" />.
    /// </exception>
    class procedure DoesNotContain<T>(const list : IEnumerable<T>; const value : T; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that an array does not contain a value, compared with <c>TEqualityComparer&lt;T&gt;.Default</c>.
    /// </summary>
    /// <param name="arr">
    ///   The array to search.
    /// </param>
    /// <param name="value">
    ///   The value that must be absent.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   An element equals <paramref name="value" />.
    /// </exception>
    class procedure DoesNotContain<T>(const arr : array of T; const value : T; const message : string = ''); overload;
{$ENDIF}
    /// <summary>
    ///   Asserts that an interface reference supports the interface <c>T</c> and returns it as <c>T</c>.
    /// </summary>
    /// <param name="value">
    ///   The reference to query.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <returns>
    ///   <paramref name="value" /> queried for <c>T</c>.
    /// </returns>
    /// <exception cref="ETestFailure">
    ///   <paramref name="value" /> does not support <c>T</c>.
    /// </exception>
    class function Implements<T : IInterface>(value : IInterface; const message : string = '') : T;
    /// <summary>
    ///   Asserts that a condition is True.
    /// </summary>
    /// <param name="condition">
    ///   The condition.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   <paramref name="condition" /> is False.
    /// </exception>
    class procedure IsTrue(const condition : boolean; const message : string = '');
    /// <summary>
    ///   Asserts that a condition is False.
    /// </summary>
    /// <param name="condition">
    ///   The condition.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   <paramref name="condition" /> is True.
    /// </exception>
    class procedure IsFalse(const condition : boolean; const message : string = '');

    /// <summary>
    ///   Asserts that an object reference is nil.
    /// </summary>
    /// <param name="condition">
    ///   The reference.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The reference is not nil.
    /// </exception>
    class procedure IsNull(const condition : TObject; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that a pointer is nil.
    /// </summary>
    /// <param name="condition">
    ///   The pointer.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The pointer is not nil.
    /// </exception>
    class procedure IsNull(const condition : Pointer; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that an interface reference is nil.
    /// </summary>
    /// <param name="condition">
    ///   The reference.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The reference is not nil.
    /// </exception>
    class procedure IsNull(const condition : IInterface; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that a variant is Null (an Unassigned variant is not Null).
    /// </summary>
    /// <param name="condition">
    ///   The variant.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   <c>VarIsNull</c> is False.
    /// </exception>
    class procedure IsNull(const condition : Variant; const message : string = ''); overload;

    /// <summary>
    ///   Asserts that an object reference is not nil.
    /// </summary>
    /// <param name="condition">
    ///   The reference.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The reference is nil.
    /// </exception>
    class procedure IsNotNull(const condition : TObject; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that a pointer is not nil.
    /// </summary>
    /// <param name="condition">
    ///   The pointer.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The pointer is nil.
    /// </exception>
    class procedure IsNotNull(const condition : Pointer; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that an interface reference is not nil.
    /// </summary>
    /// <param name="condition">
    ///   The reference.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The reference is nil.
    /// </exception>
    class procedure IsNotNull(const condition : IInterface; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that a variant is not Null (an Unassigned variant passes).
    /// </summary>
    /// <param name="condition">
    ///   The variant.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   <c>VarIsNull</c> is True.
    /// </exception>
    class procedure IsNotNull(const condition : Variant; const message : string = ''); overload;

    /// <summary>
    ///   Asserts that a string is empty.
    /// </summary>
    /// <param name="value">
    ///   The string.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The string has any characters.
    /// </exception>
    class procedure IsEmpty(const value : string; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that a variant is Unassigned or Null.
    /// </summary>
    /// <param name="value">
    ///   The variant.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The variant holds a value.
    /// </exception>
    class procedure IsEmpty(const value : Variant; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that a string list has no lines.
    /// </summary>
    /// <param name="value">
    ///   The list; must not be nil.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The list has any lines.
    /// </exception>
    class procedure IsEmpty(const value : TStrings; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that a pointer list has no items.
    /// </summary>
    /// <param name="value">
    ///   The list; must not be nil.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The list has any items.
    /// </exception>
    class procedure IsEmpty(const value : TList; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that an interface list has no items.
    /// </summary>
    /// <param name="value">
    ///   The list; must not be nil.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The list has any items.
    /// </exception>
    class procedure IsEmpty(const value : IInterfaceList; const message : string = ''); overload;
{$IFDEF DELPHI_XE_UP}
    /// <summary>
    ///   Asserts that an enumerable yields no elements.
    /// </summary>
    /// <param name="value">
    ///   The collection.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   Enumeration yields any element.
    /// </exception>
    /// <remarks>
    ///   Excluded before XE because of a Delphi 2010 compiler bug.
    /// </remarks>
    class procedure IsEmpty<T>(const value : IEnumerable<T>; const message : string = ''); overload;
{$ENDIF}

    /// <summary>
    ///   Asserts that a string is not empty.
    /// </summary>
    /// <param name="value">
    ///   The string.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The string is empty.
    /// </exception>
    class procedure IsNotEmpty(const value : string; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that a variant is neither Unassigned nor Null.
    /// </summary>
    /// <param name="value">
    ///   The variant.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The variant is Unassigned or Null.
    /// </exception>
    class procedure IsNotEmpty(const value : Variant; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that a string list has at least one line.
    /// </summary>
    /// <param name="value">
    ///   The list; must not be nil.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The list is empty.
    /// </exception>
    class procedure IsNotEmpty(const value : TStrings; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that a pointer list has at least one item.
    /// </summary>
    /// <param name="value">
    ///   The list; must not be nil.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The list is empty.
    /// </exception>
    class procedure IsNotEmpty(const value : TList; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that an interface list has at least one item.
    /// </summary>
    /// <param name="value">
    ///   The list; must not be nil.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The list is empty.
    /// </exception>
    class procedure IsNotEmpty(const value : IInterfaceList; const message : string = ''); overload;
{$IFDEF DELPHI_XE_UP}
    /// <summary>
    ///   Asserts that an enumerable yields at least one element.
    /// </summary>
    /// <param name="value">
    ///   The collection.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   Enumeration yields nothing.
    /// </exception>
    /// <remarks>
    ///   Excluded before XE because of a Delphi 2010 compiler bug.
    /// </remarks>
    class procedure IsNotEmpty<T>(const value : IEnumerable<T>; const message : string = ''); overload;
{$ENDIF}

    /// <summary>
    ///   Asserts that two date-times fall on the same calendar day (<c>SameDate</c>); the time parts are ignored.
    /// </summary>
    /// <param name="expected">
    ///   The expected date.
    /// </param>
    /// <param name="actual">
    ///   The actual date.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The dates differ.
    /// </exception>
    class procedure IsSameDate(const expected, actual: TDateTime; const message : string = '');
    /// <summary>
    ///   Asserts that two date-times have the same time of day (<c>SameTime</c>); the date parts are ignored.
    /// </summary>
    /// <param name="expected">
    ///   The expected time.
    /// </param>
    /// <param name="actual">
    ///   The actual time.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The times differ.
    /// </exception>
    class procedure IsSameTime(const expected, actual: TDateTime; const message : string = '');
    /// <summary>
    ///   Asserts that two date-times are the same moment (<c>SameDateTime</c>, to the millisecond).
    /// </summary>
    /// <param name="expected">
    ///   The expected date-time.
    /// </param>
    /// <param name="actual">
    ///   The actual date-time.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The date-times differ.
    /// </exception>
    class procedure IsSameDateTime(const expected, actual: TDateTime; const message : string = '');

    /// <summary>
    ///   Checks that an exception exactly matching ExceptClass will be raised.
    /// </summary>
    /// <param name="AMethod">
    ///   The code to run.
    /// </param>
    /// <param name="exceptionClass">
    ///   The exact class expected, or nil to accept any exception.
    /// </param>
    /// <param name="msg">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   Nothing is raised, or a different class is raised.
    /// </exception>
    /// <remarks>
    ///   A failure, pass or ignore raised by an assertion inside <paramref name="AMethod" /> is re-raised as the
    ///   test's own outcome unless <paramref name="exceptionClass" /> is itself a framework exception.
    /// </remarks>
    class procedure WillRaise(const AMethod : TTestLocalMethod; const exceptionClass : ExceptClass = nil; const msg : string = ''); overload;
    /// <summary>
    ///   Checks that an exception exactly matching ExceptClass and Message will be raised.
    /// </summary>
    /// <param name="AMethod">
    ///   The code to run.
    /// </param>
    /// <param name="exceptionClass">
    ///   The exact class expected, or nil to accept any exception.
    /// </param>
    /// <param name="exceptionMsg">
    ///   The exact (case-sensitive) exception message expected, or empty to accept any message.
    /// </param>
    /// <param name="msg">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   Nothing is raised, a different class is raised, or the message differs.
    /// </exception>
    class procedure WillRaiseWithMessage(const AMethod : TTestLocalMethod; const exceptionClass : ExceptClass = nil; const exceptionMsg : string = ''; const msg
      : string = ''); overload;
{$IFDEF SUPPORTS_REGEX}
    /// <summary>
    ///   Checks that an exception exactly matching ExceptClass and RegExp-matching Message will be raised.
    /// </summary>
    /// <param name="AMethod">
    ///   The code to run.
    /// </param>
    /// <param name="exceptionClass">
    ///   The exact class expected, or nil to accept any exception.
    /// </param>
    /// <param name="exceptionMsgRegexPattern">
    ///   Regular expression the exception message must match, or empty to accept any message.
    /// </param>
    /// <param name="msg">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   Nothing is raised, a different class is raised, or the message does not match.
    /// </exception>
    class procedure WillRaiseWithMessageRegex(const AMethod : TTestLocalMethod; const exceptionClass : ExceptClass = nil; const exceptionMsgRegexPattern :
      string = ''; const msg : string = ''); overload;
{$ENDIF}
    /// <summary>
    ///   Checks that an exception exactly matching ExceptClass will be raised.
    /// </summary>
    /// <param name="AMethod">
    ///   The method to run.
    /// </param>
    /// <param name="exceptionClass">
    ///   The exact class expected, or nil to accept any exception.
    /// </param>
    /// <param name="msg">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   Nothing is raised, or a different class is raised.
    /// </exception>
    class procedure WillRaise(const AMethod : TTestMethod; const exceptionClass : ExceptClass = nil; const msg : string = ''); overload;

    /// <summary>
    ///   Checks that an exception that descends from ExceptClass will be raised.
    /// </summary>
    /// <param name="AMethod">
    ///   The code to run.
    /// </param>
    /// <param name="exceptionClass">
    ///   The expected base class, or nil to accept any exception.
    /// </param>
    /// <param name="msg">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   Nothing is raised, or the raised class does not inherit from <paramref name="exceptionClass" />.
    /// </exception>
    class procedure WillRaiseDescendant(const AMethod : TTestLocalMethod; const exceptionClass : ExceptClass = nil; const msg : string = ''); overload;
    /// <summary>
    ///   Checks that an exception that descends from ExceptClass will be raised.
    /// </summary>
    /// <param name="AMethod">
    ///   The method to run.
    /// </param>
    /// <param name="exceptionClass">
    ///   The expected base class, or nil to accept any exception.
    /// </param>
    /// <param name="msg">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   Nothing is raised, or the raised class does not inherit from <paramref name="exceptionClass" />.
    /// </exception>
    class procedure WillRaiseDescendant(const AMethod : TTestMethod; const exceptionClass : ExceptClass = nil; const msg : string = ''); overload;

    /// <summary>
    ///   Checks that an exception will be raised.
    /// </summary>
    /// <param name="AMethod">
    ///   The code to run.
    /// </param>
    /// <param name="msg">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   Nothing derived from Exception is raised.
    /// </exception>
    class procedure WillRaiseAny(const AMethod : TTestLocalMethod; const msg : string = ''); overload;
    /// <summary>
    ///   Checks that an exception will be raised.
    /// </summary>
    /// <param name="AMethod">
    ///   The method to run.
    /// </param>
    /// <param name="msg">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   Nothing derived from Exception is raised.
    /// </exception>
    class procedure WillRaiseAny(const AMethod : TTestMethod; const msg : string = ''); overload;

    /// <summary>
    ///   Checks that an exception exactly matching ExceptClass will not be raised.
    /// </summary>
    /// <param name="AMethod">
    ///   The code to run.
    /// </param>
    /// <param name="exceptionClass">
    ///   The class that must not be raised (matched EXACTLY), or nil to forbid any exception.
    /// </param>
    /// <param name="msg">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The forbidden class (or, with nil, any exception) is raised.
    /// </exception>
    /// <remarks>
    ///   Any other exception, a descendant included, propagates, so the test is reported as an error (since 2026-10-13;
    ///   it used to be swallowed and the test passed). To forbid every exception as a failure use <c>WillNotRaiseAny</c>.
    /// </remarks>
    class procedure WillNotRaise(const AMethod : TTestLocalMethod; const exceptionClass : ExceptClass = nil; const msg : string = ''); overload;
    /// <summary>
    ///   Checks that an exception exactly matching ExceptClass will not be raised.
    /// </summary>
    /// <param name="AMethod">
    ///   The method to run.
    /// </param>
    /// <param name="exceptionClass">
    ///   The class that must not be raised (matched EXACTLY), or nil to forbid any exception.
    /// </param>
    /// <param name="msg">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The forbidden class (or, with nil, any exception) is raised.
    /// </exception>
    class procedure WillNotRaise(const AMethod : TTestMethod; const exceptionClass : ExceptClass = nil; const msg : string = ''); overload;

    /// <summary>
    ///   Checks that an exception that descends from ExceptClass not will be raised.
    /// </summary>
    /// <param name="AMethod">
    ///   The code to run.
    /// </param>
    /// <param name="exceptionClass">
    ///   The base class whose instances must not be raised, or nil to forbid any exception.
    /// </param>
    /// <param name="msg">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   An instance of <paramref name="exceptionClass" /> or a descendant (or, with nil, any exception) is raised.
    /// </exception>
    class procedure WillNotRaiseDescendant(const AMethod : TTestLocalMethod; const exceptionClass : ExceptClass = nil; const msg : string = ''); overload;
    /// <summary>
    ///   Checks that an exception that descends from ExceptClass not will be raised.
    /// </summary>
    /// <param name="AMethod">
    ///   The method to run.
    /// </param>
    /// <param name="exceptionClass">
    ///   The base class whose instances must not be raised, or nil to forbid any exception.
    /// </param>
    /// <param name="msg">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   An instance of <paramref name="exceptionClass" /> or a descendant (or, with nil, any exception) is raised.
    /// </exception>
    class procedure WillNotRaiseDescendant(const AMethod : TTestMethod; const exceptionClass : ExceptClass = nil; const msg : string = ''); overload;

    /// <summary>
    ///   Checks that an exception of Any type not will be raised. This method
    ///   is to complement <see cref="DUnitX.Assert|Assert.WillRaiseAny(TTestLocalMethod,string)">
    ///   WillRaiseAny</see> method, and is not required, as the default behavior of a test
    ///   is to fail when any exception is raised.
    /// </summary>
    /// <param name="AMethod">
    ///   The code to run.
    /// </param>
    /// <param name="msg">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   Anything is raised, including an object not derived from Exception.
    /// </exception>
    class procedure WillNotRaiseAny(const AMethod : TTestLocalMethod; const msg : string = ''); overload;
    /// <summary>
    ///   Checks that an exception of Any type not will be raised. This method
    ///   is to complement <see cref="DUnitX.Assert|Assert.WillRaiseAny(TTestMethod,string)">
    ///   WillRaiseAny</see> method, and is not required, as the default behavior of a test
    ///   is to fail when any exception is raised.
    /// </summary>
    /// <param name="AMethod">
    ///   The method to run.
    /// </param>
    /// <param name="msg">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   Anything is raised, including an object not derived from Exception.
    /// </exception>
    class procedure WillNotRaiseAny(const AMethod : TTestMethod; const msg : string = ''); overload;

    /// <summary>
    ///   Checks that an exception exactly matching ExceptClass and Message will not be raised.
    /// </summary>
    /// <param name="AMethod">
    ///   The code to run.
    /// </param>
    /// <param name="exceptionClass">
    ///   The exact class that must not be raised with that message, or nil for any class.
    /// </param>
    /// <param name="exceptionMsg">
    ///   The exact (case-sensitive) message that must not be raised, or empty for any message.
    /// </param>
    /// <param name="msg">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   An exception matching both the class and the message filters is raised.
    /// </exception>
    /// <remarks>
    ///   A non-matching exception propagates, so the test is reported as an error (since 2026-10-13; it used to be
    ///   swallowed and the test passed).
    /// </remarks>
    class procedure WillNotRaiseWithMessage(const AMethod : TTestLocalMethod; const exceptionClass : ExceptClass = nil; const exceptionMsg : string = ''; const
      msg : string = ''); overload;
    /// <summary>
    ///   Checks that an exception exactly matching ExceptClass and Message will not be raised.
    /// </summary>
    /// <param name="AMethod">
    ///   The method to run.
    /// </param>
    /// <param name="exceptionClass">
    ///   The exact class that must not be raised with that message, or nil for any class.
    /// </param>
    /// <param name="exceptionMsg">
    ///   The exact (case-sensitive) message that must not be raised, or empty for any message.
    /// </param>
    /// <param name="msg">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   An exception matching both the class and the message filters is raised.
    /// </exception>
    class procedure WillNotRaiseWithMessage(const AMethod : TTestMethod; const exceptionClass : ExceptClass = nil; const exceptionMsg : string = ''; const msg
      : string = ''); overload;

    /// <summary>
    ///   Asserts that a string contains a substring.
    /// </summary>
    /// <param name="theString">
    ///   The string searched.
    /// </param>
    /// <param name="subString">
    ///   The text that must occur; must not be empty.
    /// </param>
    /// <param name="ignoreCase">
    ///   True compares with <c>ContainsText</c>; False with <c>ContainsStr</c>.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   <paramref name="subString" /> is empty (every string trivially contains it), or does not occur.
    /// </exception>
    class procedure Contains(const theString : string; const subString : string; const ignoreCase : boolean; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that a string contains a substring, IGNORING CASE unless <c>IgnoreCaseDefault</c> is False.
    /// </summary>
    /// <param name="theString">
    ///   The string searched.
    /// </param>
    /// <param name="subString">
    ///   The text that must occur; must not be empty.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   <paramref name="subString" /> is empty, or does not occur.
    /// </exception>
    class procedure Contains(const theString : string; const subString : string; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that a string does not contain a substring.
    /// </summary>
    /// <param name="theString">
    ///   The string searched.
    /// </param>
    /// <param name="subString">
    ///   The text that must not occur; must not be empty.
    /// </param>
    /// <param name="ignoreCase">
    ///   True compares with <c>ContainsText</c>; False with <c>ContainsStr</c>.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   <paramref name="subString" /> is empty, or occurs.
    /// </exception>
    class procedure DoesNotContain(const theString : string; const subString : string; const ignoreCase : boolean; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that a string does not contain a substring, IGNORING CASE unless <c>IgnoreCaseDefault</c> is False.
    /// </summary>
    /// <param name="theString">
    ///   The string searched.
    /// </param>
    /// <param name="subString">
    ///   The text that must not occur; must not be empty.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   <paramref name="subString" /> is empty, or occurs.
    /// </exception>
    class procedure DoesNotContain(const theString : string; const subString : string; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that the text of a string list contains a substring (searched in <c>Text</c>, so it may span lines).
    /// </summary>
    /// <param name="theStrings">
    ///   The list searched; must not be nil.
    /// </param>
    /// <param name="subString">
    ///   The text that must occur; must not be empty.
    /// </param>
    /// <param name="ignoreCase">
    ///   True for a case-insensitive search.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   <paramref name="subString" /> is empty, or does not occur.
    /// </exception>
    class procedure Contains(const theStrings : TStrings; const subString : string; const ignoreCase : boolean; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that the text of a string list contains a substring, IGNORING CASE unless <c>IgnoreCaseDefault</c> is
    ///   False.
    /// </summary>
    /// <param name="theStrings">
    ///   The list searched; must not be nil.
    /// </param>
    /// <param name="subString">
    ///   The text that must occur; must not be empty.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   <paramref name="subString" /> is empty, or does not occur.
    /// </exception>
    class procedure Contains(const theStrings : TStrings; const subString : string; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that the text of a string list does not contain a substring (searched in <c>Text</c>).
    /// </summary>
    /// <param name="theStrings">
    ///   The list searched; must not be nil.
    /// </param>
    /// <param name="subString">
    ///   The text that must not occur; must not be empty.
    /// </param>
    /// <param name="ignoreCase">
    ///   True for a case-insensitive search.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   <paramref name="subString" /> is empty, or occurs.
    /// </exception>
    class procedure DoesNotContain(const theStrings : TStrings; const subString : string; const ignoreCase : boolean; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that the text of a string list does not contain a substring, IGNORING CASE unless
    ///   <c>IgnoreCaseDefault</c> is False.
    /// </summary>
    /// <param name="theStrings">
    ///   The list searched; must not be nil.
    /// </param>
    /// <param name="subString">
    ///   The text that must not occur; must not be empty.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   <paramref name="subString" /> is empty, or occurs.
    /// </exception>
    class procedure DoesNotContain(const theStrings : TStrings; const subString : string; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that a string starts with a given prefix. Note the argument order: the prefix comes first.
    /// </summary>
    /// <param name="subString">
    ///   The prefix; must not be empty.
    /// </param>
    /// <param name="theString">
    ///   The string tested.
    /// </param>
    /// <param name="ignoreCase">
    ///   True compares with <c>StartsText</c>; False with <c>StartsStr</c>.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   <paramref name="subString" /> is empty, or <paramref name="theString" /> does not start with it.
    /// </exception>
    class procedure StartsWith(const subString : string; const theString : string; const ignoreCase : boolean; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that a string starts with a given prefix, IGNORING CASE unless <c>IgnoreCaseDefault</c> is False.
    /// </summary>
    /// <param name="subString">
    ///   The prefix; must not be empty.
    /// </param>
    /// <param name="theString">
    ///   The string tested.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   <paramref name="subString" /> is empty, or <paramref name="theString" /> does not start with it.
    /// </exception>
    class procedure StartsWith(const subString : string; const theString : string; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that a string ends with a given suffix. Note the argument order: the suffix comes first.
    /// </summary>
    /// <param name="subString">
    ///   The suffix; must not be empty.
    /// </param>
    /// <param name="theString">
    ///   The string tested.
    /// </param>
    /// <param name="ignoreCase">
    ///   True compares with <c>EndsText</c>; False with <c>EndsStr</c>.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   <paramref name="subString" /> is empty, or <paramref name="theString" /> does not end with it.
    /// </exception>
    class procedure EndsWith(const subString : string; const theString : string; const ignoreCase : boolean; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that a string ends with a given suffix, IGNORING CASE unless <c>IgnoreCaseDefault</c> is False.
    /// </summary>
    /// <param name="subString">
    ///   The suffix; must not be empty.
    /// </param>
    /// <param name="theString">
    ///   The string tested.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   <paramref name="subString" /> is empty, or <paramref name="theString" /> does not end with it.
    /// </exception>
    class procedure EndsWith(const subString : string; const theString : string; const message : string = ''); overload;
    /// <summary>
    ///   Asserts that one class is, or descends from, another.
    /// </summary>
    /// <param name="descendant">
    ///   The class tested.
    /// </param>
    /// <param name="parent">
    ///   The class it must inherit from.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   Either class is nil, or <paramref name="descendant" /> does not inherit from <paramref name="parent" />.
    /// </exception>
    class procedure InheritsFrom(const descendant : TClass; const parent : TClass; const message : string = '');
{$IFDEF DELPHI_XE_UP}
    /// <summary>
    ///   Deprecated: a value of type <c>T</c> is always of type <c>T</c>, so this cannot check anything; it now always
    ///   fails so that a test relying on it is not reported as a pass.
    /// </summary>
    /// <param name="value">
    ///   Ignored.
    /// </param>
    /// <param name="message">
    ///   Ignored.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   Always, directing the caller to <c>InheritsFrom</c> or <c>Implements</c>.
    /// </exception>
    class procedure IsType<T>(const value : T; const message : string = ''); overload;
      deprecated 'IsType<T> always fails: it cannot check anything. Use InheritsFrom or Implements';
{$ENDIF}

    /// <summary>
    ///   Checks that there is no difference between the given strings. If there is a difference, then
    ///   the test will fail with extended informations about the starting position of the difference.
    /// </summary>
    /// <param name="expected">
    ///   The expected string.
    /// </param>
    /// <param name="actual">
    ///   The actual string.
    /// </param>
    /// <param name="ignoreCase">
    ///   True to compare upper-cased copies.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The strings differ; the message gives the first differing position and the surrounding text of each, with
    ///   white space made visible.
    /// </exception>
    class procedure NoDiff(const expected, actual : string; const ignoreCase : boolean; const message : string = ''); overload;
    /// <summary>
    ///   Checks that there is no difference between the given strings. If there is a difference, then
    ///   the test will fail with extended informations about the starting position of the difference.
    /// </summary>
    /// <param name="expected">
    ///   The expected string.
    /// </param>
    /// <param name="actual">
    ///   The actual string.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The strings differ (compared case-sensitively).
    /// </exception>
    class procedure NoDiff(const expected, actual : string; const message : string = ''); overload;

{$IFDEF SUPPORTS_REGEX}
    /// <summary>
    ///   Asserts that a string matches a regular expression (anywhere in the string unless the pattern is anchored).
    /// </summary>
    /// <param name="regexPattern">
    ///   The regular expression.
    /// </param>
    /// <param name="theString">
    ///   The string tested.
    /// </param>
    /// <param name="message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   The string does not match.
    /// </exception>
    class procedure IsMatch(const regexPattern : string; const theString : string; const message : string = '');
{$ENDIF}

    /// <summary>
    ///   Fails when an expectation report is non-empty; used to turn a mock or expectation verifier's unmet-expectation
    ///   text into a test failure.
    /// </summary>
    /// <param name="EmptyExpectation">
    ///   The verifier's report: empty when every expectation was met.
    /// </param>
    /// <param name="Message">
    ///   Text added to the failure message.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   <paramref name="EmptyExpectation" /> is not empty.
    /// </exception>
    class procedure CheckExpectation(const EmptyExpectation : string; const Message : string = '');

    /// <summary>Called by every assertion before it checks anything; the runner uses it to count assertions.</summary>
    class property OnAssert : TProc read fOnAssert write fOnAssert;
    /// <summary>Exception class raised by a failing assertion (<c>ETestFailure</c> under DUnitX).</summary>
    class property TestFailure : ExceptClass read fTestFailure write fTestFailure;
    /// <summary>Exception class raised by <c>Pass</c> (<c>ETestPass</c> under DUnitX).</summary>
    class property TestPass : ExceptClass read fTestPass write fTestPass;
    /// <summary>Exception class raised by <c>Ignore</c> (<c>ETestIgnored</c> under DUnitX).</summary>
    class property TestIgnored : ExceptClass read fTestIgnored write fTestIgnored;
    /// <summary>
    ///   Whether string assertions without an ignoreCase argument ignore case. True by default, so
    ///   <c>AreEqual('a', 'A')</c> PASSES; set it False, or pass ignoreCase, when casing matters.
    /// </summary>
    class property IgnoreCaseDefault : boolean read fIgnoreCaseDefault write fIgnoreCaseDefault;

    /// <summary>
    ///   Initialises <c>IgnoreCaseDefault</c> to True.
    /// </summary>
    class constructor Create;
  end;

{$IFNDEF DELPHI_XE2_UP}
/// <summary>
///   Returns the address the calling routine will return to, for compilers before XE2 that lack the intrinsic.
/// </summary>
/// <returns>
///   The caller's return address, or nil when the frame pointer is invalid.
/// </returns>
function ReturnAddress : Pointer; assembler;
{$ENDIF}

implementation

uses
  DUnitX.ResStrs,
  DUnitX.Utils,
  DUnitX.Exceptions,
{$IFDEF SUPPORTS_REGEX}
{$IFDEF USE_TREGEXPR}
  RegExpr,
{$ELSE}
  System.RegularExpressions,
{$ENDIF}
{$ENDIF}
{$IFDEF USE_NS}
  System.DateUtils,
  System.Generics.Collections,
  System.Generics.Defaults,
  System.Math,
  System.Rtti,
  System.StrUtils,
  System.TypInfo,
  System.Variants;
{$ELSE}
  Generics.Collections,
  Generics.Defaults,
  Math,
  Rtti,
  StrUtils,
  TypInfo,
  Variants;
{$ENDIF}

{$IFNDEF DELPHI_XE2_UP}
function IsBadPointer(P : Pointer) : Boolean; register;
begin
  try
    Result := (p = nil) or ((Pointer(P^) <> P) and (Pointer(P^) = P));
  except
    Result := true;
  end;
end;

function ReturnAddress : Pointer; assembler;
const
  CallerIP          = $4;
asm
   mov   eax, ebp
   call  IsBadPointer
   test  eax,eax
   jne   @@Error

   mov   eax, [ebp].CallerIP
   sub   eax, 5   // 5 bytes for call

   push  eax
   call  IsBadPointer
   test  eax,eax
   pop   eax
   je    @@Finish

@@Error:
   xor eax, eax
@@Finish:
end;
{$ENDIF}

{$IFDEF SUPPORTS_REGEX}
{$IFDEF USE_TREGEXPR}
function PerformIsMatch(const regexPattern, theString : string) : boolean;
var
  RegExp : TRegExpr;
begin
  RegExp := TRegExpr.Create;
  try
    RegExp.Expression := regexPattern;
    Result := RegExp.Exec(theString);
  finally
    RegExp.Free;
  end;
end;

{$ELSE}
function PerformIsMatch(const regexPattern, theString : string) : boolean;
begin
  Result := TRegEx.IsMatch(theString, regexPattern);
end;
{$ENDIF}
{$ENDIF}

function ObjectToString(const obj : TObject) : string;
begin
  if obj = nil then
    Result := 'nil'
  else
    Result := obj.ToString;
end;

{ Assert }

class procedure Assert.DoAssert;
begin
  if Assigned(fOnAssert) then
    fOnAssert();
end;

class procedure Assert.AreEqual(const expected, actual, tolerance : Extended; const message : string);
begin
  DoAssert;
  if tolerance < 0 then
    FailFmt(SNegativeTolerance, [tolerance, message], ReturnAddress);
  // expected = actual first: SameValue(Inf, Inf) is False (Inf - Inf is NaN). Infinities equal only themselves:
  // SameValue(Inf, -Inf) is True because its derived epsilon is itself infinite. NaN still equals nothing.
  if not ((expected = actual) or ((not IsInfinite(expected)) and (not IsInfinite(actual)) and
    {$IFDEF USE_NS}System.Math.{$ENDIF}SameValue(expected, actual, tolerance))) then
    FailFmt(SUnexpectedErrorExt, [expected, actual, message], ReturnAddress);
end;

class procedure Assert.AreEqual(const expected, actual : TClass; const message : string);
var
  msg : string;
begin
  DoAssert;
  if expected <> actual then
  begin
    msg := ' is not equal to ';
    if expected = nil then
      msg := 'nil' + msg
    else
      msg := expected.ClassName + msg;

    if actual = nil then
      msg := msg + 'nil'
    else
      msg := msg + actual.ClassName;

    if message <> '' then
      msg := msg + '. ' + message;

    Fail(msg, ReturnAddress);
  end;
end;

{$IFDEF DELPHI_XE2_UP}
//Delphi 2010 and XE compiler bug breaks this
class procedure Assert.AreEqual<T>(const expected, actual : T; const message : string);
var
  comparer : IEqualityComparer<T>;
  expectedValue, actualValue : TValue;
begin
  DoAssert;
  // An equality comparer, not TComparer: TComparer<Double> reports NaN as equal to everything.
  comparer := TEqualityComparer<T>.Default;
  if not comparer.Equals(actual, expected) then
  begin
    expectedValue := TValue.From<T>(expected);
    actualValue := TValue.From<T>(actual);
    FailFmt(SNotEqualErrorStr, [expectedValue.ToString, actualValue.ToString, message], ReturnAddress);
  end;
end;

class procedure Assert.AreEqual<T>(const expected, actual : TArray<T>; const message : string = '');
var
  i : integer;
  comparer : IEqualityComparer<T>;
  expectedValue, actualValue : TValue;
begin
  DoAssert;
  if Length(expected) <> Length(actual) then
    FailFmt(SArraysHaveDifferentLength, [Length(expected), Length(actual), message], ReturnAddress)
  else
  begin
    comparer := TEqualityComparer<T>.Default;
    for i := 0 to High(expected) do
    begin
      if not comparer.Equals(expected[i], actual[i]) then
      begin
        expectedValue := TValue.From<T>(expected[i]);
        actualValue := TValue.From<T>(actual[i]);
        FailFmt(SArraysAreDifferent, [i, expectedValue.ToString, actualValue.ToString, message], ReturnAddress);
      end;
    end;
  end;
end;

{$ENDIF}

class function Assert.AddLineBreak(const msg : string) : string;
begin
  if msg <> '' then
    Result := sLineBreak + msg
  else
    Result := '';
end;

class procedure Assert.AreEqual(const expected, actual : Integer; const message : string);
begin
  DoAssert;
  if expected <> actual then
    FailFmt(SUnexpectedErrorInt, [expected, actual, message], ReturnAddress);
end;

class procedure Assert.AreEqual(const expected, actual : Int64; const message : string);
begin
  DoAssert;
  if expected <> actual then
    FailFmt(SUnexpectedErrorInt, [expected, actual, message], ReturnAddress);
end;

class procedure Assert.AreEqual(const expected : Integer; const actual : Int64; const message : string);
begin
  DoAssert;
  if expected <> actual then
    FailFmt(SUnexpectedErrorInt, [expected, actual, message], ReturnAddress);
end;

class procedure Assert.AreEqual(const expected : Int64; const actual : Integer; const message : string);
begin
  DoAssert;
  if expected <> actual then
    FailFmt(SUnexpectedErrorInt, [expected, actual, message], ReturnAddress);
end;

class procedure Assert.AreEqual(const expected, actual : boolean; const message : string);
begin
  DoAssert;
  if expected <> actual then
    FailFmt(SUnexpectedErrorStr, [BoolToStr(expected, true), BoolToStr(actual, true), message], ReturnAddress);
end;

class procedure Assert.AreEqual(const expected, actual : cardinal; const message : string);
begin
  DoAssert;
  if expected <> actual then
    FailFmt(SUnexpectedErrorStr, [UIntToStr(expected), UIntToStr(actual), message], ReturnAddress);
end;

class procedure Assert.AreEqual(const expected, actual, tolerance : Double; const message : string);
begin
  DoAssert;
  if tolerance < 0 then
    FailFmt(SNegativeTolerance, [tolerance, message], ReturnAddress);
  // See AreEqual(Extended): expected = actual first for Inf, and infinities equal only themselves.
  if not ((expected = actual) or ((not IsInfinite(expected)) and (not IsInfinite(actual)) and
    {$IFDEF USE_NS}System.Math.{$ENDIF}SameValue(expected, actual, tolerance))) then
    FailFmt(SUnexpectedErrorDbl, [expected, actual, message], ReturnAddress);
end;

class procedure Assert.AreEqual(const expected, actual : Double; const message : string);
var
  tolerance : Double;
begin
  tolerance := 0;
  AreEqual(expected, actual, tolerance, message);
end;

class procedure Assert.AreEqual(const expected, actual : Extended; const message : string);
var
  tolerance : Extended;
begin
  tolerance := 0;
  AreEqual(expected, actual, tolerance, message);
end;

class procedure Assert.AreEqual(const expected, actual : Currency; const message : string);
begin
  DoAssert;
  if expected <> actual then
    FailFmt(SUnexpectedErrorExt, [expected, actual, message], ReturnAddress);
end;

class procedure Assert.AreEqualMemory(const expected : Pointer; const actual : Pointer; const size : Cardinal; const message : string);
begin
  DoAssert;
  if not CompareMem(expected, actual, size) then
    Fail(SMemoryValuesNotEqual + message, ReturnAddress);
end;

class procedure Assert.AreNotEqual(const expected, actual, tolerance : Extended; const message : string);
begin
  DoAssert;
  if tolerance < 0 then
    FailFmt(SNegativeTolerance, [tolerance, message], ReturnAddress);
  // See AreEqual(Extended): expected = actual first for Inf, and infinities equal only themselves.
  if (expected = actual) or ((not IsInfinite(expected)) and (not IsInfinite(actual)) and
    {$IFDEF USE_NS}System.Math.{$ENDIF}SameValue(expected, actual, tolerance)) then
    FailFmt(SEqualsErrorExt, [expected, actual, message], ReturnAddress);
end;

class procedure Assert.AreNotEqual(const expected, actual : string; const ignoreCase : boolean; const message : string);

  function AreNotEqualText(const expected, actual : string; const ignoreCase : boolean) : boolean;
  begin
    if ignoreCase then
      Result := SameText(expected, actual)
    else
      Result := SameStr(expected, actual);
  end;

begin
  DoAssert;
  if AreNotEqualText(expected, actual, ignoreCase) then
    FailFmt(SEqualsErrorStr, [expected, actual, message], ReturnAddress);
end;

class procedure Assert.AreNotEqual(const expected, actual : TClass; const message : string);
var
  msg : string;
begin
  DoAssert;
  if expected = actual then
  begin
    msg := ' is equal to ';
    if expected = nil then
      msg := 'nil' + msg
    else
      msg := expected.ClassName + msg;

    if actual = nil then
      msg := msg + 'nil'
    else
      msg := msg + actual.ClassName;
    if message <> '' then
      msg := msg + '. ' + message;

    Fail(msg, ReturnAddress);
  end;
end;

{$IFDEF DELPHI_XE2_UP}
//Delphi 2010 and XE compiler bug breaks this
class procedure Assert.AreNotEqual<T>(const expected, actual : T; const message : string);
var
  comparer : IEqualityComparer<T>;
  expectedValue, actualValue : TValue;
begin
  DoAssert;
  comparer := TEqualityComparer<T>.Default;
  if comparer.Equals(actual, expected) then
  begin
    expectedValue := TValue.From<T>(expected);
    actualValue := TValue.From<T>(actual);

    FailFmt(SEqualsErrorStr, [expectedValue.ToString, actualValue.ToString, message], ReturnAddress);
  end;
end;
{$ENDIF}

class procedure Assert.AreNotEqual(const expected, actual : Integer; const message : string);
begin
  DoAssert;
  if expected = actual then
    FailFmt(SEqualsErrorInt, [expected, actual, message], ReturnAddress);
end;

class procedure Assert.AreNotEqual(const expected, actual : Int64; const message : string);
begin
  DoAssert;
  if expected = actual then
    FailFmt(SEqualsErrorInt, [expected, actual, message], ReturnAddress);
end;

class procedure Assert.AreNotEqual(const expected, actual : Extended; const message : string);
var
  tolerance : Extended;
begin
  tolerance := 0;
  Assert.AreNotEqual(expected, actual, tolerance, message);
end;

class procedure Assert.AreNotEqual(const expected, actual : Double; const message : string);
var
  tolerance : double;
begin
  tolerance := 0;
  Assert.AreNotEqual(expected, actual, tolerance, message);
end;

class procedure Assert.AreNotEqual(const expected, actual, tolerance : double; const message : string);
begin
  DoAssert;
  if tolerance < 0 then
    FailFmt(SNegativeTolerance, [tolerance, message], ReturnAddress);
  // See AreEqual(Extended): expected = actual first for Inf, and infinities equal only themselves.
  if (expected = actual) or ((not IsInfinite(expected)) and (not IsInfinite(actual)) and
    {$IFDEF USE_NS}System.Math.{$ENDIF}SameValue(expected, actual, tolerance)) then
    FailFmt(SEqualsErrorDbl, [expected, actual, message], ReturnAddress);
end;

class procedure Assert.AreNotEqualMemory(const expected, actual : Pointer; const size : Cardinal; const message : string);
begin
  DoAssert;
  if CompareMem(expected, actual, size) then
    Fail(SMemoryValuesEqual + message, ReturnAddress);
end;

class procedure Assert.AreNotSame(const expected, actual : TObject; const message : string);
begin
  DoAssert;
  if expected = actual then
    FailFmt(SEqualsErrorObj, [ObjectToString(expected), ObjectToString(actual), message], ReturnAddress);
end;

class procedure Assert.AreNotSame(const expected, actual : IInterface; const message : string);
begin
  DoAssert;
  if (expected as IInterface) = (actual as IInterface) then
    FailFmt(SEqualsErrorIntf, [message], ReturnAddress);
end;

class procedure Assert.AreSame(const expected, actual : IInterface; const message : string);
begin
  DoAssert;
  if (expected as IInterface) <> (actual as IInterface) then
    FailFmt(SNotEqualErrorIntf, [message], ReturnAddress);
end;

class procedure Assert.AreSame(const expected, actual : TObject; const message : string);
begin
  DoAssert;
  if expected <> actual then
    FailFmt(SNotEqualErrorObj, [ObjectToString(expected), ObjectToString(actual), message], ReturnAddress);
end;

{$IFDEF DELPHI_XE_UP}
//Delphi 2010 compiler bug breaks this
class procedure Assert.Contains<T>(const list : IEnumerable<T>; const value : T; const message : string);
var
  o : T;
  comparer : IEqualityComparer<T>;
begin
  DoAssert;
  comparer := TEqualityComparer<T>.Default;
  for o in list do
  begin
    if comparer.Equals(o, value) then
      exit;
  end;

  FailFmt(SValueNotInList, [TValue.From<T>(value).ToString, message], ReturnAddress);
end;

class procedure Assert.Contains<T>(const arr : array of T; const value : T; const message : string = '');
var
  o : T;
  comparer : IEqualityComparer<T>;
begin
  DoAssert;
  comparer := TEqualityComparer<T>.Default;
  for o in arr do
  begin
    if comparer.Equals(o, value) then
      exit;
  end;

  FailFmt(SValueNotInList, [TValue.From<T>(value).ToString, message], ReturnAddress);
end;
{$ENDIF}

{$IFDEF DELPHI_XE_UP}
//Delphi 2010 compiler bug breaks this
class procedure Assert.DoesNotContain<T>(const list : IEnumerable<T>; const value : T; const message : string);
var
  o : T;
  comparer : IEqualityComparer<T>;
begin
  DoAssert;
  comparer := TEqualityComparer<T>.Default;
  for o in list do
  begin
    if comparer.Equals(o, value) then
      FailFmt(SValueInList, [TValue.From<T>(value).ToString, message], ReturnAddress);
  end;
end;

class procedure Assert.DoesNotContain<T>(const arr : array of T; const value : T; const message : string = '');
var
  o : T;
  comparer : IEqualityComparer<T>;
begin
  DoAssert;
  comparer := TEqualityComparer<T>.Default;
  for o in arr do
  begin
    if comparer.Equals(o, value) then
      FailFmt(SValueInList, [TValue.From<T>(value).ToString, message], ReturnAddress);
  end;
end;
{$ENDIF}

class procedure Assert.Fail(const message : string; const errorAddrs : pointer);
begin
  //If we have been given a return then use it. (makes the exception appear on level above in the stack)
  if errorAddrs <> nil then
    raise fTestFailure.Create(message) at errorAddrs
  else
    //Otherwise use the return address we can currently get to for where to raise the exception
    raise fTestFailure.Create(message) at ReturnAddress;
end;

class procedure Assert.FailFmt(const message : string; const args : array of const; const errorAddrs : pointer);
begin
  Fail(Trim(Format(message, args)), errorAddrs);
end;

class procedure Assert.Pass(const message : string);
begin
  raise fTestPass.Create(message);
end;

class procedure Assert.Ignore(const message : string);
begin
  //  Deliberately does NOT call DoAssert. Being skipped is not an
  //  assertion, and counting it as one would let a test satisfy
  //  FailsOnNoAsserts by doing nothing but skipping itself.
  raise fTestIgnored.Create(message);
end;

class procedure Assert.StartsWith(const subString, theString, message : string);
begin
  Assert.StartsWith(subString, theString, fIgnoreCaseDefault, message);
end;

class function Assert.StreamsEqual(const stream1, stream2 : TStream) : boolean;
const
  BlockSize         = 4096;
var
  Buffer1 : array[0..BlockSize - 1] of byte;
  Buffer2 : array[0..BlockSize - 1] of byte;
  BufferLen : integer;
  remaining, position1, position2 : Int64;
begin
  if stream1 = stream2 then
    Exit(True);

  Result := False;

  if stream1.Size = stream2.Size then
  begin
    position1 := stream1.Position;
    position2 := stream2.Position;
    try
      stream1.Position := 0;
      stream2.Position := 0;

      // Compare only the bytes actually read, and treat a stream that stops delivering short of its Size as
      // unequal rather than looping for ever.
      remaining := stream1.Size;
      while remaining > 0 do
      begin
        BufferLen := stream1.Read(Buffer1, BlockSize);
        if (BufferLen <= 0) or (stream2.Read(Buffer2, BufferLen) <> BufferLen) or
          (not CompareMem(@Buffer1, @Buffer2, BufferLen)) then
          exit;
        Dec(remaining, BufferLen);
      end;

      Result := True;
    finally
      stream1.Position := position1;
      stream2.Position := position2;
    end;
  end;
end;

class function Assert.Implements<T>(value : IInterface; const message : string) : T;
begin
  DoAssert;
  if not Supports(value, GetTypeData(TypeInfo(T)).Guid, result) then
    FailFmt(SIntfNotImplemented, [GetTypeName(TypeInfo(T)), message], ReturnAddress);
end;

class procedure Assert.InheritsFrom(const descendant, parent : TClass; const message : string);
var
  msg : string;
begin
  DoAssert;
  if (descendant = nil) or (parent = nil) or (not descendant.InheritsFrom(parent)) then
  begin
    msg := ' does not inherit from ';
    if descendant = nil then
      msg := 'nil' + msg
    else
      msg := descendant.ClassName + msg;
    if parent = nil then
      msg := msg + 'nil'
    else
      msg := msg + parent.ClassName;
    msg := msg + '.';
    if message <> '' then
      msg := msg + ' ' + message;

    Fail(msg, ReturnAddress);
  end;
end;

class procedure Assert.IsEmpty(const value : IInterfaceList; const message : string);
begin
  DoAssert;
  if value.Count > 0 then
    FailFmt(SListNotEmpty, [message], ReturnAddress);
end;

class procedure Assert.IsEmpty(const value : TList; const message : string);
begin
  DoAssert;
  if value.Count > 0 then
    FailFmt(SListNotEmpty, [message], ReturnAddress);
end;

class procedure Assert.IsEmpty(const value, message : string);
begin
  DoAssert;
  if Length(value) > 0 then
    FailFmt(SStrNotEmpty, [message], ReturnAddress);
end;

class procedure Assert.IsEmpty(const value : Variant; const message : string);
begin
  DoAssert;
  if not (VarIsEmpty(value) or VarIsNull(value)) then
    FailFmt(SVarNotEmpty, [message], ReturnAddress);
end;

class procedure Assert.IsEmpty(const value : TStrings; const message : string);
begin
  DoAssert;
  if value.Count > 0 then
    FailFmt(SListNotEmpty, [message], ReturnAddress);
end;

{$IFDEF DELPHI_XE_UP}
//Delphi 2010 compiler bug breaks this
class procedure Assert.IsEmpty<T>(const value : IEnumerable<T>; const message : string);
var
  o : T;
  count : integer;
begin
  DoAssert;
  count := 0;
  for o in value do
    Inc(count);

  if count > 0 then
    FailFmt(SListNotEmpty, [message], ReturnAddress);
end;
{$ENDIF}

class procedure Assert.IsFalse(const condition : boolean; const message : string);
begin
  DoAssert;
  if condition then
    FailFmt(SIsFalseError, [message], ReturnAddress);
end;

class procedure Assert.IsNotEmpty(const value : TList; const message : string);
begin
  DoAssert;
  if value.Count = 0 then
    FailFmt(SListEmpty, [message], ReturnAddress);
end;

class procedure Assert.IsNotEmpty(const value : IInterfaceList; const message : string);
begin
  DoAssert;
  if value.Count = 0 then
    FailFmt(SListEmpty, [message], ReturnAddress);
end;

class procedure Assert.IsNotEmpty(const value : TStrings; const message : string);
begin
  DoAssert;
  if value.Count = 0 then
    FailFmt(SListEmpty, [message], ReturnAddress);
end;

class procedure Assert.IsNotEmpty(const value, message : string);
begin
  DoAssert;
  if value = '' then
    FailFmt(SStrEmpty, [message], ReturnAddress);
end;

class procedure Assert.IsNotEmpty(const value : Variant; const message : string);
begin
  DoAssert;
  if VarIsEmpty(value) or VarIsNull(value) then
    FailFmt(SVarEmpty, [message], ReturnAddress);
end;

{$IFDEF DELPHI_XE_UP}
//Delphi 2010 compiler bug breaks this
class procedure Assert.IsNotEmpty<T>(const value : IEnumerable<T>; const message : string);
var
  x : T;
  count : integer;
begin
  DoAssert;
  count := 0;
  for x in value do
    Inc(count);

  if count = 0 then
    FailFmt(SListEmpty, [message], ReturnAddress);
end;
{$ENDIF}

class procedure Assert.IsNotNull(const condition : IInterface; const message : string);
begin
  DoAssert;
  if condition = nil then
    FailFmt(SIntfNil, [message], ReturnAddress);
end;

class procedure Assert.IsNotNull(const condition : Pointer; const message : string);
begin
  DoAssert;
  if condition = nil then
    FailFmt(SPointerNil, [message], ReturnAddress);
end;

class procedure Assert.IsNotNull(const condition : TObject; const message : string);
begin
  DoAssert;
  if condition = nil then
    FailFmt(SObjNil, [message], ReturnAddress);
end;

class procedure Assert.IsNotNull(const condition : Variant; const message : string);
begin
  DoAssert;
  if VarIsNull(condition) then
    FailFmt(SVariantNull, [message], ReturnAddress);
end;

class procedure Assert.IsNull(const condition : Variant; const message : string);
begin
  DoAssert;
  if not VarIsNull(condition) then
    FailFmt(SVariantNotNull, [message], ReturnAddress);
end;

class procedure Assert.IsNull(const condition : IInterface; const message : string);
begin
  DoAssert;
  if condition <> nil then
    FailFmt(SIntfNotNil, [message], ReturnAddress);
end;

class procedure Assert.IsNull(const condition : TObject; const message : string);
begin
  DoAssert;
  if condition <> nil then
    FailFmt(SObjNotNil, [message], ReturnAddress);
end;

class procedure Assert.IsNull(const condition : Pointer; const message : string);
begin
  DoAssert;
  if condition <> nil then
    FailFmt(SPointerNotNil, [message], ReturnAddress);
end;

class procedure Assert.IsSameDate(const expected, actual: TDateTime;
  const message: string);
begin
  DoAssert;
  if not SameDate(expected, actual) then
    FailFmt(SUnexpectedErrorStr, [DateToStr(expected), DateToStr(actual), message], ReturnAddress);
end;

class procedure Assert.IsSameDateTime(const expected, actual: TDateTime;
  const message: string);
begin
  DoAssert;
  if not SameDateTime(expected, actual) then
    FailFmt(SUnexpectedErrorStr, [DateTimeToStr(expected), DateTimeToStr(actual), message], ReturnAddress);
end;

class procedure Assert.IsSameTime(const expected, actual: TDateTime;
  const message: string);
begin
  DoAssert;
  if not SameTime(expected, actual) then
    FailFmt(SUnexpectedErrorStr, [TimeToStr(expected), TimeToStr(actual), message], ReturnAddress);
end;

class procedure Assert.IsTrue(const condition : boolean; const message : string);
begin
  DoAssert;
  if not condition then
    FailFmt(SIsTrueError, [message], ReturnAddress);
end;

class procedure Assert.NoDiff(const expected, actual : string; const ignoreCase : boolean; const message : string);

  procedure FailSubstring(position : integer);
  const
    HALF_LENGTH     = 5;
    DIFF_LENGTH     = 2 * HALF_LENGTH;
  var
    startCopy, copyLen : integer;
  begin
    startCopy := position - HALF_LENGTH;
    if startCopy < 0 then
    begin
      copyLen := DIFF_LENGTH + startCopy;
      startCopy := 0;
    end
    else
      copyLen := DIFF_LENGTH;

    FailFmt(SDiffAtPosition + ': ' + SStrDoesNotMatch, [position,
        TStrUtils.EncodeWhitespace(Copy(expected, startCopy, copyLen)),
        TStrUtils.EncodeWhitespace(Copy(actual, startCopy, copyLen)), message]);
  end;

var
  lenExp, lenAct, lenCmp : integer;
  strExp, strAct : string;
  position : Integer;
begin
  DoAssert;
  lenExp := Length(expected);
  lenAct := Length(actual);
  lenCmp := Min(lenExp, lenAct);

  if ignoreCase then
  begin
    strExp := UpperCase(expected);
    strAct := UpperCase(actual);
  end
  else
  begin
    strExp := expected;
    strAct := actual;
  end;
  for position := 1 to lenCmp do
  begin
    if strExp[position] <> strAct[position] then
      FailSubstring(position);
  end;
  if lenExp <> lenAct then
    FailSubstring(lenCmp + 1);
end;

class procedure Assert.NoDiff(const expected, actual, message : string);
begin
  NoDiff(expected, actual, false, message);
end;

class procedure Assert.NotImplemented;
begin
  Assert.Fail(SNotImplemented);
end;

{$IFDEF DELPHI_XE_UP}
//Delphi 2010 compiler bug breaks this
class procedure Assert.IsType<T>(const value : T; const message : string);
begin
  //A value of type T is always of type T, so this used to pass whatever was tested. It fails instead, so a test
  //that relies on it is not reported as a pass.
  DoAssert;
  Fail(SIsTypeCannotCheck, ReturnAddress);
end;
{$ENDIF}

class procedure Assert.WillNotRaise(const AMethod : TTestMethod; const exceptionClass : ExceptClass; const msg : string);
begin
  Assert.WillNotRaise(
    procedure
    begin
      AMethod;
    end,
    exceptionClass, msg);
end;

class procedure Assert.WillNotRaiseAny(const AMethod : TTestLocalMethod; const msg : string);
begin
  DoAssert;
  try
    AMethod;
  except
    on e : TObject do                   // For those who throw exceptions not descending from Exception.
    begin
      if (e is Exception) and IsUnrequestedTestOutcome(Exception(e), nil) then
        raise;
      // msg is an argument, never part of the format string, so '%' in it is literal.
      if e is Exception then
        FailFmt(SUnexpectedException + '%s', [e.ClassName, exception(e).message, AddLineBreak(msg)], ReturnAddress)
      else
        FailFmt(SUnexpectedExceptionAlt + '%s', [e.ClassName, AddLineBreak(msg)], ReturnAddress);
    end;
  end;
end;

class procedure Assert.WillNotRaiseAny(const AMethod : TTestMethod; const msg : string);
begin
  Assert.WillNotRaiseAny(
    procedure
    begin
      AMethod;
    end,
    msg);
end;

class procedure Assert.WillNotRaiseDescendant(const AMethod : TTestLocalMethod; const exceptionClass : ExceptClass; const msg : string);
begin
  DoAssert;
  try
    AMethod;
  except
    on e : Exception do
    begin
      if IsUnrequestedTestOutcome(e, exceptionClass) then
        raise;
      if exceptionClass <> nil then
      begin
        if e is exceptionClass then
          FailFmt(SMethodRaisedExceptionAlt, [e.ClassName, exceptionClass.ClassName, e.message, AddLineBreak(msg)], ReturnAddress)
        else
          //Another exception propagates, so the test is reported as an error rather than passing.
          raise;
      end
      else
        // nil means any exception, as in WillNotRaise.
        FailFmt(SUnexpectedException + '%s', [e.ClassName, e.message, AddLineBreak(msg)], ReturnAddress);
    end;
  end;
end;

class procedure Assert.WillNotRaiseDescendant(const AMethod : TTestMethod; const exceptionClass : ExceptClass; const msg : string);
begin
  Assert.WillNotRaiseDescendant(
    procedure
    begin
      AMethod;
    end,
    exceptionClass, msg);
end;

class procedure Assert.WillNotRaiseWithMessage(const AMethod : TTestLocalMethod; const exceptionClass : ExceptClass; const exceptionMsg, msg : string);
begin
  DoAssert;
  try
    AMethod;
  except
    on E : Exception do
    begin
      if IsUnrequestedTestOutcome(E, exceptionClass) then
        raise;
      if ((exceptionMsg = '') or SameStr(e.Message, exceptionMsg)) and
        (((exceptionClass <> nil) and (e.ClassType = exceptionClass)) or (exceptionClass = nil)) then
        FailFmt(SMethodRaisedExceptionMessage, [e.ClassName, e.Message, AddLineBreak(msg)], ReturnAddress)
      else
        //Another exception propagates, so the test is reported as an error rather than passing.
        raise;
    end;
  end;
end;

class procedure Assert.WillNotRaiseWithMessage(const AMethod : TTestMethod; const exceptionClass : ExceptClass; const exceptionMsg, msg : string);
begin
  Assert.WillNotRaiseWithMessage(
    procedure
    begin
      AMethod;
    end,
    exceptionClass, exceptionMsg, msg);
end;

class procedure Assert.WillRaise(const AMethod : TTestLocalMethod; const exceptionClass : ExceptClass; const msg : string);
begin
  DoAssert;
  try
    AMethod;
  except
    on E : Exception do
    begin
      if IsUnrequestedTestOutcome(E, exceptionClass) then
        raise;
      CheckExceptionClass(e, exceptionClass, msg);
      Exit;
    end;
  end;
  Fail(SNoException + AddLineBreak(msg), ReturnAddress);
end;

class procedure Assert.WillNotRaise(const AMethod : TTestLocalMethod; const exceptionClass : ExceptClass; const msg : string);
begin
  DoAssert;
  try
    AMethod;
  except
    on e : Exception do
    begin
      if IsUnrequestedTestOutcome(e, exceptionClass) then
        raise;
      if exceptionClass <> nil then
      begin
        if e.ClassType = exceptionClass then
          Fail(SMethodRaisedException + exceptionClass.ClassName + sLineBreak + e.Message + AddLineBreak(msg), ReturnAddress)
        else
          //Another exception is not what this assertion is about, but it is not a pass either: it propagates, so the
          //test is reported as an error. It used to be swallowed and the test passed.
          raise;
      end
      else
        FailFmt(SUnexpectedException + '%s', [e.ClassName, e.message, AddLineBreak(msg)], ReturnAddress);
    end;
  end;
end;

class procedure Assert.WillRaise(const AMethod : TTestMethod; const exceptionClass : ExceptClass; const msg : string);
begin
  Assert.WillRaise(
    procedure
    begin
      AMethod;
    end,
    exceptionClass, msg);
end;

class procedure Assert.WillRaiseAny(const AMethod : TTestLocalMethod; const msg : string);
begin
  DoAssert;
  try
    AMethod;
  except
    on E : Exception do
    begin
      if IsUnrequestedTestOutcome(E, nil) then
        raise;
      Exit;
    end;
  end;
  Fail(SNoException + AddLineBreak(msg), ReturnAddress);
end;

class procedure Assert.WillRaiseAny(const AMethod : TTestMethod; const msg : string);
begin
  Assert.WillRaiseAny(
    procedure
    begin
      AMethod;
    end,
    msg);
end;

class procedure Assert.WillRaiseDescendant(const AMethod : TTestLocalMethod; const exceptionClass : ExceptClass; const msg : string);
begin
  DoAssert;
  try
    AMethod;
  except
    on E : Exception do
    begin
      if IsUnrequestedTestOutcome(E, exceptionClass) then
        raise;
      CheckExceptionClassDescendant(e, exceptionClass, msg);
      Exit;
    end;
  end;
  Fail(SNoException + AddLineBreak(msg), ReturnAddress);
end;

class procedure Assert.WillRaiseDescendant(const AMethod : TTestMethod; const exceptionClass : ExceptClass; const msg : string);
begin
  Assert.WillRaiseDescendant(
    procedure
    begin
      AMethod;
    end,
    exceptionClass, msg);
end;

class procedure Assert.WillRaiseWithMessage(const AMethod : TTestLocalMethod; const exceptionClass : ExceptClass; const exceptionMsg, msg : string);
begin
  DoAssert;
  try
    AMethod;
  except
    on E : Exception do
    begin
      if IsUnrequestedTestOutcome(E, exceptionClass) then
        raise;
      CheckExceptionClass(E, exceptionClass, msg);
      if (exceptionMsg <> '') and (not SameStr(E.Message, exceptionMsg)) then
        FailFmt(SUnexpectedExceptionMessage, [E.ClassName, E.Message, exceptionMsg, msg], ReturnAddress);
      Exit;
    end;
  end;
  Fail(SNoException + AddLineBreak(msg), ReturnAddress);
end;

{$IFDEF SUPPORTS_REGEX}
class procedure Assert.WillRaiseWithMessageRegex(const AMethod : TTestLocalMethod; const exceptionClass : ExceptClass; const exceptionMsgRegexPattern : string;
  const msg : string);
begin
  DoAssert;
  try
    AMethod;
  except
    on E : Exception do
    begin
      if IsUnrequestedTestOutcome(E, exceptionClass) then
        raise;
      CheckExceptionClass(E, exceptionClass, msg);
      if (exceptionMsgRegexPattern <> '') and (not PerformIsMatch(exceptionMsgRegexPattern, E.Message)) then
        FailFmt(SUnexpectedExceptionMessage, [E.ClassName, E.Message, exceptionMsgRegexPattern, msg], ReturnAddress);
      Exit;
    end;
  end;
  Fail(SNoException + AddLineBreak(msg), ReturnAddress);
end;
{$ENDIF}

class procedure Assert.AreEqual(const expected : string; const actual : string; const message : string);
begin
  Assert.AreEqual(expected, actual, fIgnoreCaseDefault, message);
end;

class procedure Assert.AreEqual(const expected, actual : string; const ignoreCase : boolean; const message : string);
begin
  DoAssert;
  if ignoreCase then
  begin
    if not SameText(expected, actual) then
      FailFmt(SNotEqualErrorStr, [expected, actual, message], ReturnAddress);
  end
  else if not SameStr(expected, actual) then
    FailFmt(SNotEqualErrorStr, [expected, actual, message], ReturnAddress);
end;

class procedure Assert.CheckExceptionClass(E : Exception; const exceptionClass : ExceptClass; const msg : string);
begin
  DoAssert;
  if exceptionClass = nil then
    Exit;

  if E.ClassType <> exceptionClass then
    FailFmt(SCheckExceptionClassError + '%s', [E.ClassName, exceptionClass.ClassName, E.message, AddLineBreak(msg)], ReturnAddress);
end;

class procedure Assert.CheckExceptionClassDescendant(E : Exception; const exceptionClass : ExceptClass; const msg : string);
begin
  DoAssert;
  if exceptionClass = nil then
    Exit;

  if not (E is exceptionClass) then
    FailFmt(SCheckExceptionClassDescError + '%s', [E.ClassName, exceptionClass.ClassName, E.message, AddLineBreak(msg)], ReturnAddress);
end;

class function Assert.IsUnrequestedTestOutcome(E : Exception; const exceptionClass : ExceptClass) : boolean;

  function IsTestOutcome(const cls : TClass) : boolean;
  begin
    Result := ((fTestFailure <> nil) and cls.InheritsFrom(fTestFailure)) or
      ((fTestPass <> nil) and cls.InheritsFrom(fTestPass)) or
      ((fTestIgnored <> nil) and cls.InheritsFrom(fTestIgnored));
  end;

begin
  // A failure, pass or ignore raised by an assertion inside the method under test is the test's own outcome, not
  // the exception being tested for, unless the caller explicitly asked for one of DUnitX's own exceptions.
  Result := IsTestOutcome(E.ClassType) and
    not ((exceptionClass <> nil) and (exceptionClass.InheritsFrom(ETestFrameworkException) or IsTestOutcome(exceptionClass)));
end;

class procedure Assert.CheckExpectation(const EmptyExpectation, Message : string);
begin
  DoAssert;

  if EmptyExpectation <> '' then
    FailFmt(SCheckEmptyExpectation, [EmptyExpectation, Message], ReturnAddress);
end;

class procedure Assert.Contains(const theStrings : TStrings; const subString : string; const ignoreCase : boolean; const message : string);
begin

  contains(theStrings.Text, subString, ignoreCase, message);
end;

class procedure Assert.Contains(const theStrings : TStrings; const subString, message : string);
begin

  contains(theStrings.Text, subString, message);
end;

class procedure Assert.Contains(const theString, subString, message : string);
begin

  contains(theString, subString, fIgnoreCaseDefault, message);
end;

class procedure Assert.Contains(const theString : string; const subString : string; const ignoreCase : boolean; const message : string);
begin
  DoAssert;
  // As StartsWith and EndsWith: every string trivially contains '', so an empty subString is a test mistake.
  if subString = '' then
    FailFmt(SStrCannotBeEmpty, [], ReturnAddress);
  if ignoreCase then
  begin
    if not {$IFDEF USE_NS}System.StrUtils.{$ENDIF}ContainsText(theString, subString) then
      FailFmt(SStrDoesNotContain, [theString, subString, message], ReturnAddress);
  end
  else if not {$IFDEF USE_NS}System.StrUtils.{$ENDIF}ContainsStr(theString, subString) then
    FailFmt(SStrDoesNotContain, [theString, subString, message], ReturnAddress);
end;

class constructor Assert.Create;
begin
  fIgnoreCaseDefault := true;
end;

class procedure Assert.DoesNotContain(const theString, subString, message : string);
begin
  DoesNotContain(theString, subString, fIgnoreCaseDefault, message);
end;

class procedure Assert.DoesNotContain(const theString, subString : string; const ignoreCase : boolean; const message : string);
begin
  DoAssert;
  if subString = '' then
    FailFmt(SStrCannotBeEmpty, [], ReturnAddress);
  if ignoreCase then
  begin
    if {$IFDEF USE_NS}System.{$ENDIF}StrUtils.ContainsText(theString, subString) then
      FailFmt(SStrContains, [theString, subString, message], ReturnAddress);
  end
  else if {$IFDEF USE_NS}System.{$ENDIF}StrUtils.ContainsStr(theString, subString) then
    FailFmt(SStrContains, [theString, subString, message], ReturnAddress);
end;

class procedure Assert.EndsWith(const subString : string; const theString : string; const ignoreCase : boolean; const message : string);
begin
  DoAssert;
  if (subString = '') then
    FailFmt(SStrCannotBeEmpty, [], ReturnAddress);
  if ignoreCase then
  begin
    if not {$IFDEF USE_NS}System.StrUtils.{$ENDIF}EndsText(subString, theString) then
      FailFmt(SStrDoesNotEndWith, [theString, subString, message], ReturnAddress);
  end
  else if not {$IFDEF USE_NS}System.StrUtils.{$ENDIF}EndsStr(subString, theString) then
    FailFmt(SStrDoesNotEndWith, [theString, subString, message], ReturnAddress);
end;

{$IFDEF SUPPORTS_REGEX}
class procedure Assert.IsMatch(const regexPattern, theString, message : string);
begin
  DoAssert;

  if not PerformIsMatch(regexPattern, theString) then
    FailFmt(SStrDoesNotMatch, [theString, regexPattern, message], ReturnAddress);
end;
{$ENDIF}

class procedure Assert.StartsWith(const subString : string; const theString : string; const ignoreCase : boolean; const message : string);
begin
  DoAssert;

  // passing an empty string into the StartsText results in an accessviolation
  if subString = '' then
    FailFmt(SStrCannotBeEmpty, [], ReturnAddress);

  if ignoreCase then
  begin
    if not {$IFDEF USE_NS}System.StrUtils.{$ENDIF}StartsText(subString, theString) then
      FailFmt(SStrDoesNotStartWith, [theString, subString, message], ReturnAddress);
  end
  else if not {$IFDEF USE_NS}System.StrUtils.{$ENDIF}StartsStr(subString, theString) then
    FailFmt(SStrDoesNotStartWith, [theString, subString, message], ReturnAddress);
end;

class procedure Assert.AreEqual(const expected, actual : TGUID; const message : string);
begin
  DoAssert;
  if not IsEqualGUID(expected, actual) then
    FailFmt(SUnexpectedErrorGUID, [GUIDToString(expected), GUIDToString(actual), message], ReturnAddress);
end;

class procedure Assert.AreEqual(const expected, actual : word; const message : string);
begin
  DoAssert;
  if expected <> actual then
    FailFmt(SUnexpectedErrorInt, [expected, actual, message], ReturnAddress);
end;

class procedure Assert.AreEqual(const expected, actual : TStream; const message : string);
begin
  DoAssert;
  if not StreamsEqual(expected, actual) then
    FailFmt(SUnexpectedErrorStream, [message], ReturnAddress);
end;

class procedure Assert.AreNotEqual(const expected, actual : TGUID; const message : string);
begin
  DoAssert;
  if IsEqualGUID(expected, actual) then
    FailFmt(SEqualsErrorGUID, [GUIDToString(expected), GUIDToString(actual), message], ReturnAddress);
end;

class procedure Assert.AreNotEqual(const expected, actual : Currency; const message : string);
begin
  DoAssert;
  if expected = actual then
    FailFmt(SEqualsErrorExt, [expected, actual, message], ReturnAddress);

end;

class procedure Assert.AreNotEqual(const expected, actual : TStream; const message : string);
begin
  DoAssert;
  if StreamsEqual(expected, actual) then
    FailFmt(SEqualsErrorStream, [message], ReturnAddress);
end;

class procedure Assert.AreNotEqual(const expected, actual, message : string);
begin
  AreNotEqual(expected, actual, fIgnoreCaseDefault, message);
end;

class procedure Assert.EndsWith(const subString, theString, message : string);
begin
  Assert.EndsWith(subString, theString, fIgnoreCaseDefault, message);
end;

class procedure Assert.DoesNotContain(const theStrings : TStrings; const subString : string; const ignoreCase : boolean; const message : string);
begin
  DoesNotContain(theStrings.Text, subString, ignoreCase, message);
end;

class procedure Assert.DoesNotContain(const theStrings : TStrings; const subString, message : string);
begin
  DoesNotContain(theStrings.Text, subString, message);
end;

class procedure Assert.AreEqual(const expected, actual : TStrings; const ignoreLines : array of integer; const message : string);
var
  index : Integer;
  lineNumber : integer;
  ignoreLinesDict : TDictionary<Integer, Boolean>;
begin
  DoAssert;
  // The same instance is identical, so equal.
  if expected = actual then
    Exit;
  ignoreLinesDict := TDictionary<Integer, Boolean>.Create;
  try
    if (Length(ignoreLines) > 0) then
    begin
      for index := 0 to Length(ignoreLines) - 1 do
      begin
        ignoreLinesDict.AddOrSetValue(ignoreLines[index], true);
      end;
    end;

    if (expected.Count <> actual.Count) then
      FailFmt(SNumberOfStringsNotEqual + ': ' + SUnexpectedErrorInt, [expected.Count, actual.Count, message], ReturnAddress);

    for index := 0 to expected.Count - 1 do
    begin
      lineNumber := index + 1;
      if not ignoreLinesDict.ContainsKey(lineNumber) then
      begin
        if (expected[index] <> actual[index]) then
        begin
          NoDiff(expected[index], actual[index], Format('at line %d', [lineNumber]) + ' ' + message);
        end;
      end;
    end;
  finally
    ignoreLinesDict.Free;
  end;
end;

class procedure Assert.AreEqual(const expected, actual : TStrings; const message : string);
begin
  AreEqual(expected, actual, [], message);
end;

end.

