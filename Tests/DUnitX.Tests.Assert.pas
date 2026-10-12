{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2017 Vincent Parrett                              }
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

unit DUnitX.Tests.Assert;

interface

{$I ..\Source\DUnitX.inc}

uses
  DUnitX.TestFramework;

type
{$M+}
  /// <summary>
  ///   Tests for the <c>Assert</c> class itself: every assertion must pass when its condition holds and raise
  ///   ETestFailure (or the outcome exception ETestPass / ETestIgnored) when it does not, including the NaN,
  ///   infinity, identity and message-format cases fixed in the fork (issue #398).
  /// </summary>
  [TestFixture]
  TTestsAssert = class
  published
    /// <summary>
    ///   Proves Assert.Pass ends the test by raising ETestPass, the exception the runner records as a pass.
    /// </summary>
    [Test]
    procedure Pass_Throws_ETestPass_Exception;

    /// <summary>
    ///   Proves Assert.Pass with a message raises ETestPass carrying exactly that message (WillRaiseWithMessage
    ///   compares it case-sensitively), so the pass reason reaches the runner.
    /// </summary>
    [Test]
    procedure Pass_Throws_ETestPass_Exception_With_Message;

    /// <summary>
    ///   Proves Assert.Ignore raises ETestIgnored. Assert.Ignore is the runtime counterpart of the [Ignore] attribute:
    ///   it stops a test whose precondition turned out to be absent and reports it as ignored rather than passed;
    ///   without it the only ways to skip are Assert.Pass, which lies, and doing nothing, which lies more quietly.
    /// </summary>
    [Test]
    procedure Ignore_Throws_ETestIgnored_Exception;

    /// <summary>
    ///   Proves Assert.Ignore with a reason still raises ETestIgnored; the reason must survive to the runner, since a
    ///   skip whose reason is dropped is nearly as unhelpful as no skip at all. WillRaiseWithMessage compares the
    ///   exception's message with the reason, case-sensitively.
    /// </summary>
    [Test]
    procedure Ignore_Throws_ETestIgnored_Exception_With_Message;

    /// <summary>
    ///   Proves the deprecated IsType&lt;T&gt; fails rather than passing whatever it is given: a value of type T is
    ///   always of type T, so it checked nothing.
    /// </summary>
    [Test]
    procedure IsType_Fails_Because_It_Cannot_Check;

    /// <summary>
    ///   Proves Assert.Fail raises ETestFailure.
    /// </summary>
    [Test]
    procedure Fail_Throws_ETestFailure_Exception;

    /// <summary>
    ///   Proves Assert.Fail with a message raises ETestFailure carrying exactly that message (WillRaiseWithMessage
    ///   compares it case-sensitively), so the failure reason reaches the runner.
    /// </summary>
    [Test]
    procedure Fail_Throws_ETestFailure_Exception_With_Message;

    /// <summary>
    ///   Proves Assert.Fail given an explicit error address raises at that address: the inner WillNotRaise does not
    ///   see the failure, which surfaces only when the enclosing method returns.
    /// </summary>
    [Test]
    procedure Fail_Throws_ETestFailure_Exception_With_Return_Address_Reference;

    /// <summary>
    ///   Proves Assert.Fail without an address raises at its caller, so an enclosing WillRaise catches it and the
    ///   outer WillNotRaise sees nothing.
    /// </summary>
    [Test]
    procedure Fail_Throws_ETestFailure_Exception_With_Caller_Address_Reference;

    /// <summary>
    ///   Proves AreEqual( string ) passes for identical strings.
    /// </summary>
    [Test]
    procedure AreEqual_String_Throws_No_Exception_When_Values_Are_Equal;

    /// <summary>
    ///   Proves AreEqual( Integer ) passes for equal values.
    /// </summary>
    [Test]
    procedure AreEqual_Integer_Throws_No_Exception_When_Values_Are_Equal;

    /// <summary>
    ///   Proves AreEqual( Integer ) raises ETestFailure for different values.
    /// </summary>
    [Test]
    procedure AreEqual_Integer_Throws_ETestFailure_When_Values_Are_NotEqual;

{$IFDEF CPU64BITS}
    /// <summary>
    ///   Proves on Win64 that AreEqual resolves an overload for a NativeInt against an Integer, either way round,
    ///   and passes for equal values.
    /// </summary>
    [Test]
    procedure AreEqual_Integer_NativeInt_Throws_No_Exception_When_Values_Are_Equal;

    /// <summary>
    ///   Proves on Win64 that AreEqual of an Integer and a different NativeInt raises ETestFailure.
    /// </summary>
    [Test]
    procedure AreEqual_Integer_NativeInt_Throws_ETestFailure_When_Values_Are_NotEqual;
{$ENDIF}

    /// <summary>
    ///   Proves AreEqual( Extended ) passes when the values differ by less than the tolerance.
    /// </summary>
    [Test]
    procedure AreEqual_Extended_Throws_No_Exception_When_Values_Are_Equal;

    /// <summary>
    ///   Proves AreEqual( Extended ) raises ETestFailure when the values differ by more than the tolerance.
    /// </summary>
    [Test]
    procedure AreEqual_Extended_Throws_ETestFailure_When_Values_Are_NotEqual;

    /// <summary>
    ///   Proves AreEqual( Double ) passes when the values differ by less than the tolerance.
    /// </summary>
    [Test]
    procedure AreEqual_Double_Throws_No_Exception_When_Values_Are_Equal;

    /// <summary>
    ///   Proves AreEqual( Double ) raises ETestFailure when the values differ by more than the tolerance.
    /// </summary>
    [Test]
    procedure AreEqual_Double_Throws_ETestFailure_When_Values_Are_NotEqual;

    /// <summary>
    ///   Proves AreEqual( Double ) fails when the actual value is NaN. Every ordered comparison with NaN is false,
    ///   so a tolerance check built on comparisons can report NaN as "within tolerance" and pass a test whose
    ///   calculation produced no number at all.
    /// </summary>
    [Test]
    procedure AreEqual_Double_Throws_ETestFailure_When_Actual_Is_NaN;

    /// <summary>
    ///   Proves AreEqual( Double ) fails when the expected value is NaN; the NaN check must not depend on which
    ///   argument carries it.
    /// </summary>
    [Test]
    procedure AreEqual_Double_Throws_ETestFailure_When_Expected_Is_NaN;

    /// <summary>
    ///   Proves AreNotEqual( Double ) passes when one value is NaN, since NaN is not equal to any number.
    /// </summary>
    [Test]
    procedure AreNotEqual_Double_Throws_No_Exception_When_One_Value_Is_NaN;

    /// <summary>
    ///   Proves AreEqual( Extended ) fails when the actual value is NaN. On Win32 Extended is the 80-bit x87
    ///   type, so its NaN comparisons take a different code path from Double's.
    /// </summary>
    [Test]
    procedure AreEqual_Extended_Throws_ETestFailure_When_Actual_Is_NaN;

    /// <summary>
    ///   Proves AreEqual( Extended ) fails when the expected value is NaN.
    /// </summary>
    [Test]
    procedure AreEqual_Extended_Throws_ETestFailure_When_Expected_Is_NaN;

    /// <summary>
    ///   Proves AreNotEqual( Extended ) passes when one value is NaN, since NaN is not equal to any number.
    /// </summary>
    [Test]
    procedure AreNotEqual_Extended_Throws_No_Exception_When_One_Value_Is_NaN;

    /// <summary>
    ///   Proves AreEqual( Currency ) raises ETestFailure for values a cent apart.
    /// </summary>
    [Test]
    procedure AreEqual_Currency_Throws_ETestFailure_When_Values_Are_NotEqual;

    /// <summary>
    ///   Proves AreEqual( TGUID ) passes for two separately built GUIDs with the same value: the comparison is by
    ///   value, not by identity.
    /// </summary>
    [Test]
    procedure AreEqual_GUID_Throws_No_Exception_When_Values_Are_Equal;

    /// <summary>
    ///   Proves AreEqual( TGUID ) raises ETestFailure for different GUIDs.
    /// </summary>
    [Test]
    procedure AreEqual_GUID_Throws_ETestFailure_When_Values_Are_NotEqual;

    /// <summary>
    ///   Proves AreEqual( TStream ) passes for two streams with the same content.
    /// </summary>
    [Test]
    procedure AreEqual_Stream_Throws_No_Exception_When_Values_Are_Equal;

    /// <summary>
    ///   Proves AreEqual( TStream ) raises ETestFailure for streams with different content.
    /// </summary>
    [Test]
    procedure AreEqual_Stream_Throws_ETestFailure_When_Values_Are_NotEqual;

    /// <summary>
    ///   Proves AreEqual( TClass ) passes for the same class.
    /// </summary>
    [Test]
    procedure AreEqual_TClass_Throws_No_Exception_When_Classes_Are_Equal;

    /// <summary>
    ///   Proves AreEqual( TClass ) raises ETestFailure for two unrelated classes.
    /// </summary>
    [Test]
    procedure AreEqual_TClass_Throws_ETestFailure_When_Classes_Are_NotEqual;

    /// <summary>
    ///   Proves NoDiff passes for equal strings - empty, a lone CR, plain text - and, with AIgnoreCase, for strings
    ///   that differ only in case.
    /// </summary>
    /// <param name="A">
    ///   Expected string.
    /// </param>
    /// <param name="B">
    ///   Actual string.
    /// </param>
    /// <param name="AIgnoreCase">
    ///   Whether NoDiff ignores case.
    /// </param>
    [Test]
    [TestCase('Empty', ',,false')]
    [TestCase('CR', #13','#13',false')]
    [TestCase('Simple', 'abc,abc,false')]
    [TestCase('Ignore case simple', 'abc,ABC,true')]
    [TestCase('Ignore case complex', 'LoReM iPsUm DoLoR sIt AmEt,lOrEm IpSuM dOlOr SiT aMeT,true')]
    procedure NoDiff_Throws_No_Exception_When_Strings_Are_Equal(const A, B : string; AIgnoreCase : boolean = false);

    /// <summary>
    ///   Proves NoDiff raises ETestFailure whose message names the first differing position and shows the text around
    ///   it - for length, first and last character, leading and trailing spaces, prefixes, extra spaces, case, CR
    ///   against LF (with a "Linebreak style" note) and space against tab.
    /// </summary>
    /// <param name="A">
    ///   Expected string.
    /// </param>
    /// <param name="B">
    ///   Actual string.
    /// </param>
    /// <param name="AException">
    ///   The exact ETestFailure message expected.
    /// </param>
    /// <param name="AMessage">
    ///   The user message passed to NoDiff, appended to the failure text.
    /// </param>
    [TestCase('Length',
        '  '#8',' +
        ' ,' +
        'Difference at position 2: [''  ''#8] does not match ['' '']' + ',',
        ',', false)]
    [TestCase('First Char',
        'lorem ipsum,' +
        '1orem ipsum,' +
        'Difference at position 1: [''lorem ''] does not match [''1orem '']' + ',',
        ',', false)]
    [TestCase('Last Char',
        'Lorem ipsum,' +
        'Lorem ipsuw,' +
        'Difference at position 11: ['' ipsum''] does not match ['' ipsuw'']' + ',',
        ',', false)]
    [TestCase('Leading Space',
        ' Lorem ipsum,' +
        'Lorem ipsum ,' +
        'Difference at position 1: ['' Lorem''] does not match [''Lorem '']' + ',',
        ',', false)]
    [TestCase('Trailing Space',
        'Lorem ipsum,' +
        'Lorem ipsum ,' +
        'Difference at position 12: [''ipsum''] does not match [''ipsum '']' + ',',
        ',', false)]
    [TestCase('A sub B',
        'Lorem ip,' +
        'Lorem ipsum,' +
        'Difference at position 9: [''em ip''] does not match [''em ipsum'']' + ',',
        ',', false)]
    [TestCase('B sub A',
        'Lorem ipsum,' +
        'Lorem ip,' +
        'Difference at position 9: [''em ipsum''] does not match [''em ip'']' + ',',
        ',', false)]
    [TestCase('Different Spaces',
        'lorem ipsum,' +
        'lorem  ipsum,' +
        'Difference at position 7: [''orem ipsum''] does not match [''orem  ipsu'']' + ',',
        ',', false)]
    [TestCase('Capitalization',
        'lorem ipsum,' +
        'lorem Ipsum,' +
        'Difference at position 7: [''orem ipsum''] does not match [''orem Ipsum'']' + ',',
        ',', false)]
    [TestCase('CR vs LF',
        #13',' +
        #10',' +
        'Difference at position 1: [#13] does not match [#10] Linebreak style,Linebreak style',
        ',', false)]
    [TestCase('Space vs TAB',
        'lorem ipsum,' +
        'lorem'#9'ipsum,' +
        'Difference at position 6: [''lorem ipsu''] does not match [''lorem''#9''ipsu'']' + ',',
        ',', false)]
    [TestCase('TAB vs Space',
        'lorem'#9'ipsum,' +
        'lorem ipsum,' +
        'Difference at position 6: [''lorem''#9''ipsu''] does not match [''lorem ipsu'']' + ',',
        ',', false)]
    procedure NoDiff_Throws_ETestFailure_When_Strings_Are_NotEqual(const A, B, AException, AMessage : string);

    /// <summary>
    ///   Proves AreEqual( TStrings ) passes for two empty lists, for equal lists, and for lists that differ only on a
    ///   line listed in ignoreLines.
    /// </summary>
    [Test]
    procedure AreEqual_TStrings_Throws_No_Exception_When_Strings_Are_Equal;

    /// <summary>
    ///   Proves AreEqual( TStrings ) fails with a message giving the two counts when the lengths differ, and with the
    ///   position, surrounding text and line number of the first difference otherwise.
    /// </summary>
    [Test]
    procedure AreEqual_TStrings_Throws_ETestFailure_When_Strings_Are_NotEqual;

{$IFDEF DELPHI_XE2_UP}
    /// <summary>
    ///   Proves AreEqual&lt;IInterface&gt; passes for the same interface reference.
    /// </summary>
    [Test]
    procedure AreEqual_T_Throws_No_Exception_When_Interfaces_Are_Equal;

    /// <summary>
    ///   Proves AreEqual&lt;IInterface&gt; raises ETestFailure for references to two different objects.
    /// </summary>
    [Test]
    procedure AreEqual_T_Throws_ETestFailure_When_Interfaces_Are_NotEqual;

    /// <summary>
    ///   Proves AreEqual&lt;IInterface&gt; raises ETestFailure, not an access violation, when either side is nil.
    /// </summary>
    [Test]
    procedure AreEqual_T_Throws_ETestFailure_When_Interfaces_Are_Nil;

    /// <summary>
    ///   Proves AreEqual&lt;TObject&gt; passes for the same object.
    /// </summary>
    [Test]
    procedure AreEqual_T_Throws_No_Exception_When_Objects_Are_Equal;

    /// <summary>
    ///   Proves AreEqual&lt;TObject&gt; raises ETestFailure for two distinct objects.
    /// </summary>
    [Test]
    procedure AreEqual_T_Throws_ETestFailure_When_Objects_Are_NotEqual;

    /// <summary>
    ///   Proves AreEqual&lt;TObject&gt; raises ETestFailure, not an access violation, when either side is nil.
    /// </summary>
    [Test]
    procedure AreEqual_T_Throws_ETestFailure_When_Objects_Are_Nil;

    /// <summary>
    ///   Proves AreEqual&lt;T&gt;( TArray ) passes for string and real arrays with the same elements in the same
    ///   order.
    /// </summary>
    [Test]
    procedure AreEqual_Array_T_Throws_No_Exception_When_Arrays_Are_Equal;

    /// <summary>
    ///   Proves AreEqual&lt;T&gt;( TArray ) fails for arrays of different length and for the same elements in a
    ///   different order (integer, real and string arrays).
    /// </summary>
    [Test]
    procedure AreEqual_Array_T_Throws_ETestFailure_When_Arrays_Are_Not_Equal;

{$ENDIF}

    /// <summary>
    ///   Proves AreEqualMemory passes when both pointers address the same memory.
    /// </summary>
    [Test]
    procedure AreEqualMemory_Throws_No_Exception_When_Pointers_Are_Equal;

    /// <summary>
    ///   Proves AreEqualMemory raises ETestFailure for two blocks that differ only in their LAST byte, so the whole
    ///   size is compared and not just a prefix.
    /// </summary>
    [Test]
    procedure AreEqualMemory_Throws_ETestFailure_When_Pointers_Are_NotEqual;

    /// <summary>
    ///   Proves AreEqual( Extended ) passes for identical values with a zero tolerance (the boundary of the
    ///   tolerance comparison).
    /// </summary>
    [Test]
    procedure AreEqual_Throws_No_Exception_When_Values_Are_Exactly_Equal;

    /// <summary>
    ///   Proves AreNotEqual( Integer ) passes for different values.
    /// </summary>
    [Test]
    procedure AreNotEqual_Integer_Throws_No_Exception_When_Values_Are_NotEqual;

    /// <summary>
    ///   Proves AreNotEqual( Integer ) raises ETestFailure for equal values.
    /// </summary>
    [Test]
    procedure AreNotEqual_Integer_Throws_Exception_When_Values_Are_Equal;

    /// <summary>
    ///   Proves AreNotEqual( Currency ) raises ETestFailure for equal values.
    /// </summary>
    [Test]
    procedure AreNotEqual_Currency_Throws_Exception_When_Values_Are_Equal;

    /// <summary>
    ///   Proves AreNotEqual( TGUID ) passes for different GUIDs.
    /// </summary>
    [Test]
    procedure AreNotEqual_GUID_Throws_No_Exception_When_Values_Are_NotEqual;

    /// <summary>
    ///   Proves AreNotEqual( TGUID ) raises ETestFailure for equal GUIDs.
    /// </summary>
    [Test]
    procedure AreNotEqual_GUID_Throws_Exception_When_Values_Are_Equal;

    /// <summary>
    ///   Proves WillRaise with no exception class accepts any exception.
    /// </summary>
    [Test]
    procedure WillRaise_Without_Exception_Class_Will_Capture_Any_Exception;

    /// <summary>
    ///   Proves WillRaiseWithMessage passes when both the exception class and its message match (here the
    ///   ETestPass from Assert.Pass and its message).
    /// </summary>
    [Test]
    procedure WillRaiseWithMessage_Exception_And_Message_Will_Check_ExceptionClass_And_Exception_Message;

    /// <summary>
    ///   Proves WillRaiseWithMessage with neither class nor message accepts any exception.
    /// </summary>
    [Test]
    procedure WillRaiseWithMessage_Without_Exception_Class_And_Message_Will_Capture_Any_Exception;

    /// <summary>
    ///   Proves WillRaiseWithMessage with no class but a message accepts any exception carrying that message.
    /// </summary>
    [Test]
    procedure WillRaiseWithMessage_Without_Exception_Class_With_Message_Will_Capture_Any_Exception_With_Message;

    /// <summary>
    ///   Proves WillRaiseWithMessage raises ETestFailure when handed a nil method in place of one that raises.
    /// </summary>
    [Test]
    procedure WillRaiseWithMessage_Exception_Not_Thrown_Throws_ETestFailure_Exception;

    /// <summary>
    ///   Proves WillRaiseDescendant fails when the raised class is not the named class or a descendant of it.
    /// </summary>
    [Test]
    procedure WillRaiseDescendant_With_NonDescendingClass;

    /// <summary>
    ///   Proves WillRaiseDescendant passes for a descendant of the named class (EFilerError for EStreamError).
    /// </summary>
    [Test]
    procedure WillRaiseDescendant_With_DescendingClass;

    /// <summary>
    ///   Proves WillRaiseDescendant passes for exactly the named class.
    /// </summary>
    [Test]
    procedure WillRaiseDescendant_With_ExactClass;

    /// <summary>
    ///   Proves WillRaiseAny passes for any exception, here EAbort.
    /// </summary>
    [Test]
    procedure WillRaiseAny;

    /// <summary>
    ///   Proves WillRaiseAny raises ETestFailure when the method raises nothing.
    /// </summary>
    [Test]
    procedure WillRaiseAny_NoExecption;

    /// <summary>
    ///   Proves WillNotRaise( class ) lets a different exception class PROPAGATE unchanged (same class, same message)
    ///   rather than swallowing it: the assertion is not about that exception, but the test must not pass over it.
    /// </summary>
    [Test]
    procedure WillNotRaise_With_ExactClass_Positive;

    /// <summary>
    ///   Proves WillNotRaise( class ) fails with ETestFailure when the method raises exactly the named class, and that
    ///   the failure message carries the caller's message.
    /// </summary>
    [Test]
    procedure WillNotRaise_With_ExactClass_Negative;

    /// <summary>
    ///   Proves WillNotRaiseDescendant lets an ancestor (Exception), not a descendant, of the named class PROPAGATE
    ///   unchanged rather than swallowing it.
    /// </summary>
    [Test]
    procedure WillNotRaise_With_DescendingClass_Positive;

    /// <summary>
    ///   Proves WillNotRaiseDescendant raises ETestFailure when the method raises a descendant of the named class.
    /// </summary>
    [Test]
    procedure WillNotRaise_With_DescendingClass_Negative;

    /// <summary>
    ///   Proves WillNotRaise with no class raises ETestFailure for any exception.
    /// </summary>
    [Test]
    procedure WillNotRaise_With_NoClass;

    /// <summary>
    ///   Proves Implements&lt;I&gt; raises ETestFailure when the object does not support the interface.
    /// </summary>
    [Test]
    procedure Test_Implements_Will_Fail_If_Not_Implemented;

    /// <summary>
    ///   Proves Implements&lt;I&gt; passes and returns a non-nil interface when the object supports it.
    /// </summary>
    [Test]
    procedure Test_Implements_Will_Pass_If_Implemented;

    /// <summary>
    ///   Proves AreSame( IInterface ) compares the underlying object, so two different interfaces of one object are
    ///   the same.
    /// </summary>
    [Test]
    procedure Test_AreSameOnSameObjectWithDifferentInterfaces_No_Exception;

    /// <summary>
    ///   Proves AreNotSame( IInterface ) fails for two different interfaces of one object.
    /// </summary>
    [Test]
    procedure Test_AreNotSameOnSameObjectWithDifferentInterfaces_Throws_Exception;

{$IFDEF DELPHI_XE_UP}
    /// <summary>
    ///   Proves Contains&lt;T&gt;( array ) passes when the value is in the array.
    /// </summary>
    [Test]
    procedure Contains_ArrayOfT_Throws_No_Exception_When_Value_In_Array;

    /// <summary>
    ///   Proves Contains&lt;T&gt;( array ) raises ETestFailure when the value is not in the array.
    /// </summary>
    [Test]
    procedure Contains_ArrayOfT_Throws_Exception_When_Value_Not_In_Array;

    /// <summary>
    ///   Proves DoesNotContain&lt;T&gt;( array ) passes when the value is not in the array.
    /// </summary>
    [Test]
    procedure DoesNotContain_ArrayOfT_Throws_No_Exception_When_Value_Not_In_Array;

    /// <summary>
    ///   Proves DoesNotContain&lt;T&gt;( array ) raises ETestFailure when the value is in the array.
    /// </summary>
    [Test]
    procedure DoesNotContain_ArrayOfT_Throws_Exception_When_Value_In_Array;
{$ENDIF}

    /// <summary>
    ///   Proves StartsWith passes when the substring begins the string, with and without case sensitivity.
    /// </summary>
    /// <param name="subString">
    ///   The expected prefix.
    /// </param>
    /// <param name="theString">
    ///   The string searched.
    /// </param>
    /// <param name="caseSensitive">
    ///   Whether the comparison is case-sensitive.
    /// </param>
    [Test]
    [TestCase('substring', 'a str,a string,false')]
    [TestCase('substring - case sensitive', 'a str,a string,true')]
    procedure StartsWith_SubString_Is_At_The_Start_Of_String(const subString, theString : string; caseSensitive : boolean);

    /// <summary>
    ///   Proves StartsWith fails for an empty substring, an empty string, and a substring found only at the end, in
    ///   the middle or not at all.
    /// </summary>
    /// <param name="subString">
    ///   The prefix that must not match.
    /// </param>
    /// <param name="theString">
    ///   The string searched.
    /// </param>
    /// <param name="caseSensitive">
    ///   Whether the comparison is case-sensitive.
    /// </param>
    [Test]
    [TestCase('empty substring', ',a string,false')]
    [TestCase('empty substring - case sensitive', ',a string,true')]
    [TestCase('empty string', 'substring,,false')]
    [TestCase('empty string - case sensitive', 'substring,,true')]
    [TestCase('at end of string', 'substring,at the end if the substring,false')]
    [TestCase('at end of string - case sensitive', 'substring,at the end if the substring,true')]
    [TestCase('in the middle of string', 'substring,the substring is in the middle,false')]
    [TestCase('in the middle of string - case sensitive', 'substring,the substring is in the middle,true')]
    [TestCase('not in the string', 'something else,the substring is not here,false')]
    [TestCase('not in the string - case sensitive', 'something else,the substring is not here,true')]
    procedure StartsWith_SubString_Is_Not_At_Start(const subString, theString : string; caseSensitive : boolean);

    /// <summary>
    ///   Proves EndsWith passes when the substring ends the string, with and without case sensitivity.
    /// </summary>
    /// <param name="subString">
    ///   The expected suffix.
    /// </param>
    /// <param name="theString">
    ///   The string searched.
    /// </param>
    /// <param name="caseSensitive">
    ///   Whether the comparison is case-sensitive.
    /// </param>
    [Test]
    [TestCase('substring', 'ing,a string,false')]
    [TestCase('substring - case sensitive', 'ing,a string,true')]
    procedure EndsWith_SubString_Is_At_The_End_Of_String(const subString, theString : string; caseSensitive : boolean);

    /// <summary>
    ///   Proves EndsWith fails for an empty substring, an empty string, and a substring found only at the start, in
    ///   the middle or not at all.
    /// </summary>
    /// <param name="subString">
    ///   The suffix that must not match.
    /// </param>
    /// <param name="theString">
    ///   The string searched.
    /// </param>
    /// <param name="caseSensitive">
    ///   Whether the comparison is case-sensitive.
    /// </param>
    [Test]
    [TestCase('empty substring', ',a string,false')]
    [TestCase('empty substring - case sensitive', ',a string,true')]
    [TestCase('empty string', 'substring,,false')]
    [TestCase('empty string - case sensitive', 'substring,,true')]
    [TestCase('at start of string', 'at the,at the end if the substring,false')]
    [TestCase('at start of string - case sensitive', 'at the,at the end if the substring,true')]
    [TestCase('in the middle of string', 'substring,the substring is in the middle,false')]
    [TestCase('in the middle of string - case sensitive', 'substring,the substring is in the middle,true')]
    [TestCase('not in the string', 'something else,the substring is not here,false')]
    [TestCase('not in the string - case sensitive', 'something else,the substring is not here,true')]
    procedure EndsWith_SubString_Is_Not_At_End(const subString, theString : string; caseSensitive : boolean);

    /// <summary>
    ///   Proves Assert.IgnoreCaseDefault governs AreEqual, AreNotEqual, StartsWith and EndsWith on strings when no
    ///   case argument is passed: True makes 'String' and 'STRING' equal, False makes them differ. The original
    ///   setting is restored afterwards.
    /// </summary>
    [Test]
    procedure IgnoreCaseDefault;

{$IFDEF SUPPORTS_REGEX}
    /// <summary>
    ///   Proves IsMatch passes when the string matches the regular expression (a GUID with or without dashes).
    /// </summary>
    /// <param name="regexPattern">
    ///   The regular expression.
    /// </param>
    /// <param name="theString">
    ///   The string that must match.
    /// </param>
    [Test]
    [TestCase('GUID with dash', '[0-9A-F]{8}[-]?([0-9A-F]{4}[-]?){3}[0-9A-F]{12},C687683F-F25B-4F9A-A231-31C52253B6A1')]
    [TestCase('GUID without dash', '[0-9A-F]{8}[-]?([0-9A-F]{4}[-]?){3}[0-9A-F]{12},C687683FF25B4F9AA23131C52253B6A1')]
    procedure IsMatch_True_Will_Not_Raise(const regexPattern, theString : string);

    /// <summary>
    ///   Proves IsMatch raises ETestFailure when the string does not match (a GUID ending in '#').
    /// </summary>
    /// <param name="regexPattern">
    ///   The regular expression.
    /// </param>
    /// <param name="theString">
    ///   The string that must not match.
    /// </param>
    [Test]
    [TestCase('GUID with dash', '[0-9A-F]{8}[-]([0-9A-F]{4}[-]){3}[0-9A-F]{12},C687683F-F25B-4F9A-A231-31C52253B6A#')]
    [TestCase('GUID without dash', '[0-9A-F]{8}[-]?([0-9A-F]{4}[-]?){3}[0-9A-F]{12},C687683FF25B4F9AA23131C52253B6A#')]
    procedure IsMatch_False_Will_Raise_ETestFailure(const regexPattern, theString : string);

    /// <summary>
    ///   Proves WillRaiseWithMessageRegex passes when the exception message matches the pattern and fails when it
    ///   does not.
    /// </summary>
    [Test]
    procedure WillRaiseWithMessageRegex;
{$ENDIF}

    /// <summary>
    ///   Proves WillNotRaiseWithMessage with no class and no message fails for any exception. (Published, so a test
    ///   without [Test].)
    /// </summary>
    procedure WillNotRaiseWithMessage_NilExceptionParam_NoExceptionMessage_WillRaise;
    /// <summary>
    ///   Proves WillNotRaiseWithMessage fails when both the class and the message match the raised exception.
    /// </summary>
    procedure WillNotRaiseWithMessage_MatchingExceptionParam_MatchingExceptionMessage_WillRaise;
    /// <summary>
    ///   Proves WillNotRaiseWithMessage with a matching class and no message fails.
    /// </summary>
    procedure WillNotRaiseWithMessage_MatchingExceptionParam_NoExceptionMessage_WillRaise;
    /// <summary>
    ///   Proves WillNotRaiseWithMessage lets the exception PROPAGATE unchanged when the class matches but the message
    ///   does not (it is not the exception asserted against, and must not be swallowed).
    /// </summary>
    procedure WillNotRaiseWithMessage_MatchingExceptionParam_NonMatchingExceptionMessage_WillNotRaise;
    /// <summary>
    ///   Proves WillNotRaiseWithMessage with no class but a matching message fails.
    /// </summary>
    procedure WillNotRaiseWithMessage_NilExceptionParam_MatchingExceptionMessage_WillRaise;
    /// <summary>
    ///   Proves WillNotRaiseWithMessage with no class and a different message lets the exception PROPAGATE unchanged
    ///   rather than swallowing it.
    /// </summary>
    procedure WillNotRaiseWithMessage_NilExceptionParam_NonMatchingExceptionMessage_WillNotRaise;
    /// <summary>
    ///   Proves WillNotRaiseWithMessage lets the exception PROPAGATE unchanged when the message matches but the class
    ///   does not.
    /// </summary>
    procedure WillNotRaiseWithMessage_NonMatchingExceptionParam_MatchingExceptionMessage_WillNotRaise;
    /// <summary>
    ///   Proves WillNotRaiseWithMessage with a non-matching class and no message lets the exception PROPAGATE
    ///   unchanged.
    /// </summary>
    procedure WillNotRaiseWithMessage_NonMatchingExceptionParam_NoExceptionMessage_WillNotRaise;
    /// <summary>
    ///   Proves WillNotRaiseWithMessage lets the exception PROPAGATE unchanged when neither the class nor the message
    ///   matches.
    /// </summary>
    procedure WillNotRaiseWithMessage_NonMatchingExceptionParam_NonMatchingExceptionMessage_WillNotRaise;

    /// <summary>
    ///   Proves CheckExpectation fails when given a non-empty expectation message (a mock's unmet expectation).
    /// </summary>
    [Test]
    procedure CheckExpectation_Not_Empty_String_Will_Raise;

    /// <summary>
    ///   Proves AreEqual resolves an Int64 overload (Int64 against Int64, either side a cast literal) and passes for
    ///   equal values; a compile-time overload check as much as a run-time one.
    /// </summary>
    [Test]
    procedure Test64BitListIndex;

    /// <summary>
    ///   Proves IsEmpty( Variant ) fails for an assigned value and passes for Unassigned and Null; the condition was
    ///   inverted, so IsEmpty( 'abc' ) passed and IsEmpty( Unassigned ) failed. Issue #398 item 1.1.
    /// </summary>
    [Test]
    procedure IsEmpty_Variant_Fails_Only_When_Value_Is_Assigned;

    /// <summary>
    ///   Proves IsNotEmpty( Variant ) fails for Null as well as for Unassigned. Issue #398 item 1.1.
    /// </summary>
    [Test]
    procedure IsNotEmpty_Variant_Fails_When_Value_Is_Null;

    /// <summary>
    ///   Proves the TTestMethod overload of WillNotRaiseDescendant fails when the method raises a DESCENDANT of the
    ///   named class; it forwarded to the exact-match WillNotRaise, so a descendant passed. Issue #398 item 1.2.
    /// </summary>
    [Test]
    procedure WillNotRaiseDescendant_Method_Fails_When_Descendant_Raised;

    /// <summary>
    ///   Proves AreEqual&lt;Double&gt; and AreEqual&lt;T&gt;( TArray ) fail when one value is NaN, and
    ///   AreNotEqual&lt;Double&gt; passes. TComparer&lt;Double&gt; reports NaN as equal to everything.
    ///   Issue #398 item 1.3.
    /// </summary>
    [Test]
    procedure AreEqual_T_Double_Fails_When_One_Value_Is_NaN;

    /// <summary>
    ///   Proves Contains&lt;Double&gt; fails, and DoesNotContain&lt;Double&gt; passes, for a NaN value that is not in
    ///   the array. Issue #398 item 1.3.
    /// </summary>
    [Test]
    procedure Contains_T_Double_Does_Not_Match_NaN;

    /// <summary>
    ///   Proves WillRaiseAny, WillRaise, WillRaiseDescendant and WillRaiseWithMessage let a failed assertion inside
    ///   the method through as the failure it is, rather than counting it as the expected exception.
    ///   Issue #398 item 1.4.
    /// </summary>
    [Test]
    procedure WillRaise_Family_Does_Not_Swallow_A_Failed_Assertion;

    /// <summary>
    ///   Proves the WillRaise family lets Assert.Pass and Assert.Ignore inside the method through, so the test
    ///   outcome they set is not swallowed. Issue #398 item 1.4.
    /// </summary>
    [Test]
    procedure WillRaise_Family_Does_Not_Swallow_Pass_Or_Ignore;

    /// <summary>
    ///   Proves '%' and '%s' in the user message of WillNotRaiseAny and WillNotRaise appear literally instead of
    ///   being parsed as format specifiers (which raised EConvertError). Issue #398 item 3.1.
    /// </summary>
    [Test]
    procedure WillNotRaise_User_Message_Is_Not_A_Format_String;

    /// <summary>
    ///   Proves a nil exception class in WillNotRaiseDescendant and WillNotRaiseWithMessage gives a readable failure
    ///   naming the raised class, not an access violation. Issue #398 item 3.2.
    /// </summary>
    [Test]
    procedure WillNotRaise_Nil_Class_Fails_Readably;

    /// <summary>
    ///   Proves that when WillRaise, WillRaiseDescendant or WillRaiseWithMessage gets the WRONG exception class, the
    ///   failure message carries the caller's message; it used to be dropped, leaving no clue which assertion failed.
    /// </summary>
    [Test]
    procedure WillRaise_Family_Wrong_Class_Failure_Includes_Caller_Message;

    /// <summary>
    ///   Proves the WillNotRaise family lets Assert.Pass, Assert.Ignore and Assert.Fail inside the method through as
    ///   the outcome they set, instead of reporting "Method raised ETestPass" or swallowing a failure because its
    ///   class is not the one named. Issue #398 item 3.
    /// </summary>
    [Test]
    procedure WillNotRaise_Family_Passes_Test_Outcomes_Through;

    /// <summary>
    ///   Proves AreSame and AreNotSame( TObject ) compare identity, ignoring an overridden Equals, and handle nil
    ///   without an access violation. Issue #398 item 3.3.
    /// </summary>
    [Test]
    procedure AreSame_Object_Compares_Identity;

    /// <summary>
    ///   Proves AreEqual and AreNotEqual( Double ) treat +Inf as equal only to +Inf, and reject a negative
    ///   tolerance. Issue #398 item 3.4.
    /// </summary>
    [Test]
    procedure AreEqual_Double_Infinity_And_Negative_Tolerance;

    /// <summary>
    ///   Proves AreEqual and AreNotEqual( Extended ) treat +Inf as equal only to +Inf, and reject a negative
    ///   tolerance. Issue #398 item 3.4.
    /// </summary>
    [Test]
    procedure AreEqual_Extended_Infinity_And_Negative_Tolerance;

    /// <summary>
    ///   Proves the failure messages of AreEqual( Currency ), DoesNotContain( string ), AreEqual( Cardinal ) and
    ///   WillNotRaiseDescendant say what actually happened. Issue #398 item 3.5.
    /// </summary>
    [Test]
    procedure Failure_Messages_Describe_The_Failure;

    /// <summary>
    ///   Proves AreEqual( TStrings ) passes for the same instance and accepts a duplicated ignoreLines entry.
    ///   Issue #398 item 3.6.
    /// </summary>
    [Test]
    procedure AreEqual_TStrings_Same_Instance_And_Duplicate_IgnoreLines;

    /// <summary>
    ///   Proves Contains and DoesNotContain( string ) both reject an empty substring, as StartsWith and EndsWith
    ///   do. Issue #398 item 3.7.
    /// </summary>
    [Test]
    procedure Contains_And_DoesNotContain_Reject_Empty_SubString;

    /// <summary>
    ///   Proves AreEqual( TStream ) restores both streams' positions and passes for the same instance, so an
    ///   assertion does not disturb the stream the test goes on to use.
    /// </summary>
    [Test]
    procedure AreEqual_Stream_Restores_Positions_And_Accepts_Same_Instance;

    /// <summary>
    ///   Proves AreEqual( TStream ) fails, rather than looping for ever, for streams whose Read returns nothing
    ///   short of their Size.
    /// </summary>
    [Test]
    procedure AreEqual_Stream_Fails_When_Read_Returns_Nothing;
  end;

implementation

uses
{$IFDEF USE_NS}
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.Math,
  System.Variants,
{$ELSE}
  SysUtils,
  Classes,
  Math,
  Variants,
{$ENDIF}
  DUnitX.Exceptions,
  DUnitX.Assert;

type
{$M+}
  IMockInterface = interface
    ['{8DB1A216-0E95-4241-9522-C50DF99AFB71}']
    procedure Stub;
  end;
{$M-}

  TMockClassOne = class(TObject)
  end;
  TMockClassTwo = class(TObject)
  end;

  IAmImplemented = interface
    ['{4B503CDD-6262-403C-BF68-5D5DE01C3B13}']
  end;

  TImplemented = class(TInterfacedObject, IAmImplemented)
  end;

  TestExceptionOne = class(Exception);
  TestExceptionTwo = class(Exception);

  TAlwaysEqual = class(TObject)
  public
    function Equals(Obj : TObject) : Boolean; override;
  end;

  TMethodRaiser = class(TObject)
  public
    procedure RaiseFilerError;
  end;

  // Reports a Size but delivers no bytes, as a broken or exhausted source stream can.
  TStreamThatReadsNothing = class(TStream)
  protected
    function GetSize : Int64; override;
  public
    function Read(var Buffer; Count : Longint) : Longint; override;
    function Write(const Buffer; Count : Longint) : Longint; override;
    function Seek(const Offset : Int64; Origin : TSeekOrigin) : Int64; override;
  end;

  //Mask to override the default AssertEx in DUnitX.TestFramework
  Assert = class(DUnitX.Assert.Assert);

// Runs AProc and returns the message of the ETestFailure it raised, or '' when it raised none. Any other exception
// propagates, so an access violation or EConvertError inside an assertion still errors the calling test.
function FailureMessage(const AProc : TProc) : string;
begin
  Result := '';
  try
    AProc;
  except
    on E : ETestFailure do
      Result := E.Message;
  end;
end;

function TAlwaysEqual.Equals(Obj : TObject) : Boolean;
begin
  Result := True;
end;

procedure TMethodRaiser.RaiseFilerError;
begin
  raise EFilerError.Create('Test');
end;

function TStreamThatReadsNothing.GetSize : Int64;
begin
  Result := 10;
end;

function TStreamThatReadsNothing.Read(var Buffer; Count : Longint) : Longint;
begin
  Result := 0;
end;

function TStreamThatReadsNothing.Write(const Buffer; Count : Longint) : Longint;
begin
  Result := 0;
end;

function TStreamThatReadsNothing.Seek(const Offset : Int64; Origin : TSeekOrigin) : Int64;
begin
  Result := 0;
end;

procedure TTestsAssert.Fail_Throws_ETestFailure_Exception;
begin
  Assert.WillRaise(
    procedure
    begin
      Assert.Fail
    end, ETestFailure);
end;

procedure TTestsAssert.Fail_Throws_ETestFailure_Exception_With_Caller_Address_Reference;
var
  MyProc : TTestLocalMethod;
begin
  MyProc := procedure
    begin
      Assert.WillRaise(
        procedure
        begin
          Assert.Fail;

          //We will raise at this point, when we return.
        end, ETestFailure);
    end;

  Assert.WillNotRaise(MyProc, ETestFailure);
end;

procedure TTestsAssert.Fail_Throws_ETestFailure_Exception_With_Message;
const
  EXPECTED_EXCEPTION_MSG = 'Failed Message';
begin
  Assert.WillRaiseWithMessage(
    procedure
    begin
      Assert.Fail(EXPECTED_EXCEPTION_MSG);
    end, ETestFailure, EXPECTED_EXCEPTION_MSG, 'The failure message did not reach the exception');
end;

procedure TTestsAssert.Fail_Throws_ETestFailure_Exception_With_Return_Address_Reference;
var
  MyProc : TTestLocalMethod;
begin
  MyProc := procedure
    begin
      Assert.WillNotRaise(
        procedure
        begin
          Assert.Fail('', @MyProc);

          //We will not raise internally, as we are passing the address of our caller
        end, ETestFailure);

      //We will raise it here, when MyProc returns.
    end;

  Assert.WillRaise(MyProc, ETestFailure);
  MyProc := nil;
end;

procedure TTestsAssert.IgnoreCaseDefault;
const
  cStr1             = 'String';
  cStr2             = 'STRING';
var
  OldVal : Boolean;
begin
  //Don't assume start value
  OldVal := Assert.IgnoreCaseDefault;
  try
    Assert.IgnoreCaseDefault := True;
    Assert.WillNotRaiseAny(procedure
      begin
        Assert.AreEqual(cStr1, cStr2)
      end);
    Assert.WillNotRaiseAny(procedure
      begin
        Assert.StartsWith(cStr1, cStr2)
      end);
    Assert.WillNotRaiseAny(procedure
      begin
        Assert.EndsWith(cStr1, cStr2)
      end);
    Assert.WillRaise(procedure
      begin
        Assert.AreNotEqual(cStr1, cStr2)
      end, ETestFailure);

    Assert.IgnoreCaseDefault := False;
    Assert.WillRaise(procedure
      begin
        Assert.AreEqual(cStr1, cStr2)
      end, ETestFailure);
    Assert.WillRaise(procedure
      begin
        Assert.StartsWith(cStr1, cStr2)
      end, ETestFailure);
    Assert.WillRaise(procedure
      begin
        Assert.EndsWith(cStr1, cStr2)
      end, ETestFailure);
    Assert.WillNotRaiseAny(procedure
      begin
        Assert.AreNotEqual(cStr1, cStr2)
      end);
  finally
    Assert.IgnoreCaseDefault := OldVal;
  end;
end;

procedure TTestsAssert.NoDiff_Throws_ETestFailure_When_Strings_Are_NotEqual(const A, B, AException, AMessage : string);
begin
  Assert.WillRaiseWithMessage(procedure
    begin
      Assert.NoDiff(A, B, AMessage);
    end, ETestFailure, AException);
end;

procedure TTestsAssert.NoDiff_Throws_No_Exception_When_Strings_Are_Equal(const A, B : string; AIgnoreCase : boolean = false);
begin
  Assert.WillNotRaise(procedure
    begin
      Assert.NoDiff(A, B, AIgnoreCase);
    end);
end;

procedure TTestsAssert.Pass_Throws_ETestPass_Exception;
begin
  Assert.WillRaise(
    procedure
    begin
      Assert.Pass;
    end, ETestPass);
end;

procedure TTestsAssert.Pass_Throws_ETestPass_Exception_With_Message;
const
  EXPECTED_EXCEPTION_MSG = 'Passing Message';
begin
  Assert.WillRaiseWithMessage(
    procedure
    begin
      Assert.Pass(EXPECTED_EXCEPTION_MSG);
    end, ETestPass, EXPECTED_EXCEPTION_MSG, 'The pass message did not reach the exception');
end;

//  Assert.Ignore is the runtime counterpart of the [Ignore] attribute: it
//  stops a test whose PRECONDITION turned out to be absent and reports it
//  as ignored rather than passed. Without it the only ways to skip are
//  Assert.Pass, which lies, and doing nothing, which lies more quietly.
procedure TTestsAssert.IsType_Fails_Because_It_Cannot_Check;
begin
  Assert.WillRaise(
    procedure
    begin
{$WARN SYMBOL_DEPRECATED OFF}
      Assert.IsType<Integer>(1);
{$WARN SYMBOL_DEPRECATED ON}
    end, ETestFailure);
end;

procedure TTestsAssert.Ignore_Throws_ETestIgnored_Exception;
begin
  Assert.WillRaise(
    procedure
    begin
      Assert.Ignore;
    end, ETestIgnored);
end;

//  The message is the REASON the test was skipped, and it must survive to
//  the runner - a skip whose reason is dropped is nearly as unhelpful as
//  no skip at all.
procedure TTestsAssert.Ignore_Throws_ETestIgnored_Exception_With_Message;
const
  EXPECTED_EXCEPTION_MSG = 'Ignoring Message';
begin
  Assert.WillRaiseWithMessage(
    procedure
    begin
      Assert.Ignore(EXPECTED_EXCEPTION_MSG);
    end, ETestIgnored, EXPECTED_EXCEPTION_MSG, 'The ignore reason did not reach the exception');
end;

procedure TTestsAssert.Test_Implements_Will_Fail_If_Not_Implemented;
var
  obj : IInterface;
  res : IAmImplemented;
begin
  obj := TInterfacedObject.Create;
  Assert.WillRaise(
    procedure
    begin
      res := Assert.Implements<IAmImplemented>(obj);
    end,
    ETestFailure);
end;

procedure TTestsAssert.Test_Implements_Will_Pass_If_Implemented;
var
  obj : IInterface;
  res : IAmImplemented;
begin
  obj := TImplemented.Create;
  Assert.WillNotRaiseAny(
    procedure
    begin
      res := Assert.Implements<IAmImplemented>(obj);
    end);
  Assert.IsNotNull(res);
end;

procedure TTestsAssert.WillNotRaiseWithMessage_NilExceptionParam_NoExceptionMessage_WillRaise;
begin
  Assert.WillRaise(
    procedure
    begin
      Assert.WillNotRaiseWithMessage(
        procedure
        begin
          raise Exception.Create('Test');
        end);
    end, ETestFailure);
end;

procedure TTestsAssert.WillNotRaiseWithMessage_NilExceptionParam_MatchingExceptionMessage_WillRaise;
begin
  Assert.WillRaise(
    procedure
    begin
      Assert.WillNotRaiseWithMessage(
        procedure
        begin
          raise Exception.Create('Test');
        end, nil, 'Test');
    end, ETestFailure);
end;

procedure TTestsAssert.WillNotRaiseWithMessage_NilExceptionParam_NonMatchingExceptionMessage_WillNotRaise;
begin
  Assert.WillRaiseWithMessage(
    procedure
    begin
      Assert.WillNotRaiseWithMessage(
        procedure
        begin
          raise Exception.Create('Test');
        end, nil, 'Different Exception Message');
    end, Exception, 'Test', 'The unasserted exception was swallowed instead of propagating');
end;

procedure TTestsAssert.WillNotRaiseWithMessage_MatchingExceptionParam_NoExceptionMessage_WillRaise;
begin
  Assert.WillRaise(
    procedure
    begin
      Assert.WillNotRaiseWithMessage(
        procedure
        begin
          raise TestExceptionOne.Create('Test');
        end, TestExceptionOne);
    end, ETestFailure);
end;

procedure TTestsAssert.WillNotRaiseWithMessage_MatchingExceptionParam_MatchingExceptionMessage_WillRaise;
begin
  Assert.WillRaise(
    procedure
    begin
      Assert.WillNotRaiseWithMessage(
        procedure
        begin
          raise TestExceptionOne.Create('Test');
        end, TestExceptionOne, 'Test');
    end, ETestFailure);
end;

procedure TTestsAssert.WillNotRaiseWithMessage_MatchingExceptionParam_NonMatchingExceptionMessage_WillNotRaise;
begin
  Assert.WillRaiseWithMessage(
    procedure
    begin
      Assert.WillNotRaiseWithMessage(
        procedure
        begin
          raise TestExceptionOne.Create('Test');
        end, TestExceptionOne, 'Different Exception Message');
    end, TestExceptionOne, 'Test', 'The unasserted exception was swallowed instead of propagating');
end;

procedure TTestsAssert.WillNotRaiseWithMessage_NonMatchingExceptionParam_NoExceptionMessage_WillNotRaise;
begin
  Assert.WillRaiseWithMessage(
    procedure
    begin
      Assert.WillNotRaiseWithMessage(
        procedure
        begin
          raise TestExceptionOne.Create('Test');
        end, TestExceptionTwo);
    end, TestExceptionOne, 'Test', 'The unasserted exception was swallowed instead of propagating');
end;

procedure TTestsAssert.WillNotRaiseWithMessage_NonMatchingExceptionParam_MatchingExceptionMessage_WillNotRaise;
begin
  Assert.WillRaiseWithMessage(
    procedure
    begin
      Assert.WillNotRaiseWithMessage(
        procedure
        begin
          raise TestExceptionOne.Create('Test');
        end, TestExceptionTwo, 'Test');
    end, TestExceptionOne, 'Test', 'The unasserted exception was swallowed instead of propagating');
end;

procedure TTestsAssert.WillNotRaiseWithMessage_NonMatchingExceptionParam_NonMatchingExceptionMessage_WillNotRaise;
begin
  Assert.WillRaiseWithMessage(
    procedure
    begin
      Assert.WillNotRaiseWithMessage(
        procedure
        begin
          raise TestExceptionOne.Create('Test');
        end, TestExceptionTwo, 'Different Exception Message');
    end, TestExceptionOne, 'Test', 'The unasserted exception was swallowed instead of propagating');
end;

procedure TTestsAssert.WillNotRaise_With_DescendingClass_Negative;
begin
  Assert.WillRaise(
    procedure
    begin
      Assert.WillNotRaiseDescendant(
        procedure
        begin
          raise EFilerError.Create('Test');
        end,
        EStreamError);
    end,
    ETestFailure);
end;

procedure TTestsAssert.WillNotRaise_With_DescendingClass_Positive;
begin
  Assert.WillRaiseWithMessage(
    procedure
    begin
      Assert.WillNotRaiseDescendant(
        procedure
        begin
          raise Exception.Create('Test');
        end,
        EStreamError);
    end, Exception, 'Test', 'The unasserted exception was swallowed instead of propagating');
end;

procedure TTestsAssert.WillNotRaise_With_ExactClass_Negative;
const
  EXPECTED_EXCEPTION_MSG = 'Passing Message';
var
  msg : string;
begin
  msg := FailureMessage(
    procedure
    begin
      Assert.WillNotRaise(
        procedure
        begin
          raise EStreamError.Create('Error Message');
        end,
        EStreamError, EXPECTED_EXCEPTION_MSG);
    end);
  Assert.Contains(msg, EXPECTED_EXCEPTION_MSG, False, 'WillNotRaise did not fail, or dropped the caller''s message');
end;

procedure TTestsAssert.WillNotRaise_With_ExactClass_Positive;
begin
  Assert.WillRaiseWithMessage(
    procedure
    begin
      Assert.WillNotRaise(
        procedure
        begin
          // Not the class being asserted against, so it must propagate untouched.
          raise Exception.Create('Error Message');
        end,
        EStreamError, '');
    end, Exception, 'Error Message', 'The unasserted exception was swallowed instead of propagating');
end;

procedure TTestsAssert.WillNotRaise_With_NoClass;
const
  EXPECTED_EXCEPTION_MSG = 'Passing Message';
begin
  Assert.WillRaise(
    procedure
    begin
      Assert.WillNotRaise(
        procedure
        begin
          // Raise an exception
          raise Exception.Create('Error Message');
        end);
    end,
    ETestFailure,
      EXPECTED_EXCEPTION_MSG);
end;

procedure TTestsAssert.WillRaiseAny;
begin
  Assert.WillRaiseAny(
    procedure
    begin
      raise EAbort.Create('Test');
    end);
end;

procedure TTestsAssert.WillRaiseAny_NoExecption;
const
  EXPECTED_EXCEPTION_MSG = 'Failed Message';
begin
  Assert.WillRaise(
    procedure
    begin
      Assert.WillRaiseAny(
        procedure
        begin
          // Do nothing on purpose.
        end
        );
    end, ETestFailure, EXPECTED_EXCEPTION_MSG);
end;

procedure TTestsAssert.WillRaiseDescendant_With_DescendingClass;
const
  EXPECTED_EXCEPTION_MSG = 'Failed Message';
begin
  Assert.WillRaiseDescendant(
    procedure
    begin
      raise EFilerError.Create('Test');
    end,
    EStreamError, EXPECTED_EXCEPTION_MSG);

end;

procedure TTestsAssert.WillRaiseDescendant_With_ExactClass;
const
  EXPECTED_EXCEPTION_MSG = 'Failed Message';
begin
  Assert.WillRaiseDescendant(
    procedure
    begin
      raise EFilerError.Create('Test');
    end,
    EFilerError, EXPECTED_EXCEPTION_MSG);
end;

procedure TTestsAssert.WillRaiseDescendant_With_NonDescendingClass;
const
  EXPECTED_EXCEPTION_MSG = 'Failed Message';
begin
  Assert.WillRaise(
    procedure
    begin
      Assert.WillRaiseDescendant(
        procedure
        begin
          raise Exception.Create('Test');
        end,
        EStreamError, EXPECTED_EXCEPTION_MSG);
    end,
    ETestFailure, EXPECTED_EXCEPTION_MSG);
end;

procedure TTestsAssert.WillRaiseWithMessage_Exception_And_Message_Will_Check_ExceptionClass_And_Exception_Message;
const
  EXPECTED_EXCEPTION_MSG = 'Passing Message';
begin
  Assert.WillRaiseWithMessage(
    procedure
    begin
      Assert.Pass(EXPECTED_EXCEPTION_MSG);
    end, ETestPass, EXPECTED_EXCEPTION_MSG);
end;

procedure TTestsAssert.WillRaiseWithMessage_Exception_Not_Thrown_Throws_ETestFailure_Exception;
const
  EXPECTED_EXCEPTION_MSG = 'Failed Message';
begin
  Assert.WillRaise(
    procedure
    begin
      Assert.WillRaiseWithMessage(nil, ETestFailure);
    end, ETestFailure, EXPECTED_EXCEPTION_MSG);
end;

procedure TTestsAssert.WillRaiseWithMessage_Without_Exception_Class_And_Message_Will_Capture_Any_Exception;
begin
  Assert.WillRaiseWithMessage(
    procedure
    begin
      raise Exception.Create('Pass');
    end);
end;

procedure TTestsAssert.WillRaiseWithMessage_Without_Exception_Class_With_Message_Will_Capture_Any_Exception_With_Message;
const
  EXPECTED_EXCEPTION_MSG = 'Passing Message';
begin
  Assert.WillRaiseWithMessage(
    procedure
    begin
      raise Exception.Create(EXPECTED_EXCEPTION_MSG);
    end, nil, EXPECTED_EXCEPTION_MSG);
end;

procedure TTestsAssert.WillRaise_Without_Exception_Class_Will_Capture_Any_Exception;
begin
  Assert.WillRaise(
    procedure
    begin
      raise Exception.Create('Test')
    end);
end;

procedure TTestsAssert.AreEqualMemory_Throws_ETestFailure_When_Pointers_Are_NotEqual;
var
  expected, actual : array[0..7] of Byte;
begin
  FillChar(expected, SizeOf(expected), 0);
  FillChar(actual, SizeOf(actual), 0);
  //Only the last byte differs, so a comparison that stops short of the full size would pass.
  actual[High(actual)] := 1;
  Assert.WillRaise(
    procedure
    begin
      Assert.AreEqualMemory(@expected, @actual, SizeOf(expected));
    end, ETestFailure);
end;

procedure TTestsAssert.AreEqualMemory_Throws_No_Exception_When_Pointers_Are_Equal;
var
  mock : IInterface;
begin
  mock := TInterfacedObject.Create();

  Assert.WillNotRaise(
    procedure
    begin
      Assert.AreEqualMemory(@mock, @mock, SizeOf(mock));
    end, ETestFailure);
end;

procedure TTestsAssert.AreEqual_Double_Throws_ETestFailure_When_Values_Are_NotEqual;
const
  ACTUAL_DOUBLE     : double = 1.19E20;
  EXPECTED_DOUBLE   : double = 1.18E20;
  TOLERANCE_DOUBLE  : double = 0.001E20;
begin
  Assert.WillRaise(
    procedure
    begin
      Assert.AreEqual(ACTUAL_DOUBLE, EXPECTED_DOUBLE, TOLERANCE_DOUBLE);
    end, ETestFailure, Format('[%e] with in [%e] from [%e]', [ACTUAL_DOUBLE, TOLERANCE_DOUBLE, EXPECTED_DOUBLE]));
end;

procedure TTestsAssert.AreEqual_Double_Throws_ETestFailure_When_Actual_Is_NaN;
const
  EXPECTED_DOUBLE  : double = 1.0;
  TOLERANCE_DOUBLE : double = 0.001;
var
  ActualDouble : double;
begin
  ActualDouble := NaN;
  Assert.WillRaise(
    procedure
    begin
      Assert.AreEqual(EXPECTED_DOUBLE, ActualDouble, TOLERANCE_DOUBLE);
    end, ETestFailure, 'AreEqual( Double ) passed with a NaN actual value');
end;

procedure TTestsAssert.AreEqual_Double_Throws_ETestFailure_When_Expected_Is_NaN;
const
  ACTUAL_DOUBLE    : double = 1.0;
  TOLERANCE_DOUBLE : double = 0.001;
var
  ExpectedDouble : double;
begin
  ExpectedDouble := NaN;
  Assert.WillRaise(
    procedure
    begin
      Assert.AreEqual(ExpectedDouble, ACTUAL_DOUBLE, TOLERANCE_DOUBLE);
    end, ETestFailure, 'AreEqual( Double ) passed with a NaN expected value');
end;

procedure TTestsAssert.AreNotEqual_Double_Throws_No_Exception_When_One_Value_Is_NaN;
const
  EXPECTED_DOUBLE  : double = 1.0;
  TOLERANCE_DOUBLE : double = 0.001;
var
  ActualDouble : double;
begin
  ActualDouble := NaN;
  Assert.WillNotRaiseAny(
    procedure
    begin
      Assert.AreNotEqual(EXPECTED_DOUBLE, ActualDouble, TOLERANCE_DOUBLE);
    end, 'AreNotEqual( Double ) failed although one value is NaN');
end;

procedure TTestsAssert.AreEqual_Extended_Throws_ETestFailure_When_Actual_Is_NaN;
const
  EXPECTED_EXTENDED  : extended = 1.0;
  TOLERANCE_EXTENDED : extended = 0.001;
var
  ActualExtended : extended;
begin
  ActualExtended := NaN;
  Assert.WillRaise(
    procedure
    begin
      Assert.AreEqual(EXPECTED_EXTENDED, ActualExtended, TOLERANCE_EXTENDED);
    end, ETestFailure, 'AreEqual( Extended ) passed with a NaN actual value');
end;

procedure TTestsAssert.AreEqual_Extended_Throws_ETestFailure_When_Expected_Is_NaN;
const
  ACTUAL_EXTENDED    : extended = 1.0;
  TOLERANCE_EXTENDED : extended = 0.001;
var
  ExpectedExtended : extended;
begin
  ExpectedExtended := NaN;
  Assert.WillRaise(
    procedure
    begin
      Assert.AreEqual(ExpectedExtended, ACTUAL_EXTENDED, TOLERANCE_EXTENDED);
    end, ETestFailure, 'AreEqual( Extended ) passed with a NaN expected value');
end;

procedure TTestsAssert.AreNotEqual_Extended_Throws_No_Exception_When_One_Value_Is_NaN;
const
  EXPECTED_EXTENDED  : extended = 1.0;
  TOLERANCE_EXTENDED : extended = 0.001;
var
  ActualExtended : extended;
begin
  ActualExtended := NaN;
  Assert.WillNotRaiseAny(
    procedure
    begin
      Assert.AreNotEqual(EXPECTED_EXTENDED, ActualExtended, TOLERANCE_EXTENDED);
    end, 'AreNotEqual( Extended ) failed although one value is NaN');
end;

procedure TTestsAssert.AreEqual_Currency_Throws_ETestFailure_When_Values_Are_NotEqual;
const
  ACTUAL_CURRENCY   : Currency = 1.34;
  EXPECTED_CURRENCY : Currency = 1.35;
begin
  Assert.WillRaise(
    procedure
    begin
      Assert.AreEqual(ACTUAL_CURRENCY, EXPECTED_CURRENCY);
    end, ETestFailure, Format('[%e] not equal to [%e]', [ACTUAL_CURRENCY, EXPECTED_CURRENCY]));
end;

procedure TTestsAssert.AreEqual_Double_Throws_No_Exception_When_Values_Are_Equal;
const
  ACTUAL_DOUBLE     : double = 1.19E20;
  EXPECTED_DOUBLE   : double = 1.18E20;
  TOLERANCE_DOUBLE  : double = 0.011E20;
begin
  Assert.WillNotRaise(
    procedure
    begin
      Assert.AreEqual(ACTUAL_DOUBLE, EXPECTED_DOUBLE, TOLERANCE_DOUBLE);
    end, Exception);
end;

procedure TTestsAssert.AreEqual_Extended_Throws_ETestFailure_When_Values_Are_NotEqual;
const
  ACTUAL_EXTENDED   : extended = 1.19E20;
  EXPECTED_EXTENDED : extended = 1.18E20;
  TOLERANCE_EXTENDED : extended = 0.001E20;
begin
  Assert.WillRaise(
    procedure
    begin
      Assert.AreEqual(ACTUAL_EXTENDED, EXPECTED_EXTENDED, TOLERANCE_EXTENDED);
    end, ETestFailure, Format('[%e] with in [%e] from [%e]', [ACTUAL_EXTENDED, TOLERANCE_EXTENDED, EXPECTED_EXTENDED]));
end;

procedure TTestsAssert.AreEqual_Extended_Throws_No_Exception_When_Values_Are_Equal;
const
  ACTUAL_EXTENDED   : extended = 1.19E20;
  EXPECTED_EXTENDED : extended = 1.18E20;
  TOLERANCE_EXTENDED : extended = 0.011E20;
begin
  Assert.WillNotRaise(
    procedure
    begin
      Assert.AreEqual(ACTUAL_EXTENDED, EXPECTED_EXTENDED, TOLERANCE_EXTENDED);
    end, Exception);
end;

procedure TTestsAssert.AreEqual_GUID_Throws_ETestFailure_When_Values_Are_NotEqual;
const
  EXPECTED_GUID     : TGUID = (D1 : 0; D2 : 0; D3 : 0; D4 : (0, 0, 0, 0, 0, 0, 0, 0));
  ACTUAL_GUID       : TGUID = (D1 : 1; D2 : 1; D3 : 1; D4 : (1, 1, 1, 1, 1, 1, 1, 1));
begin
  Assert.WillRaise(
    procedure
    begin
      Assert.AreEqual(EXPECTED_GUID, ACTUAL_GUID);
    end, ETestFailure);
end;

procedure TTestsAssert.AreEqual_GUID_Throws_No_Exception_When_Values_Are_Equal;
const
  EXPECTED_GUID     : TGUID = '{6F1C2A3B-4D5E-4F60-8A7B-9C0D1E2F3A4B}';
var
  actualGuid : TGUID;
begin
  //A separate variable built from the string, so equality is by value and not by sharing one constant.
  actualGuid := StringToGUID('{6F1C2A3B-4D5E-4F60-8A7B-9C0D1E2F3A4B}');
  Assert.WillNotRaiseAny(
    procedure
    begin
      Assert.AreEqual(EXPECTED_GUID, actualGuid);
    end);
end;

procedure TTestsAssert.AreEqual_Integer_Throws_ETestFailure_When_Values_Are_NotEqual;
begin
  Assert.WillRaise(
    procedure
    begin
      Assert.AreEqual(1, 2);
    end, ETestFailure, Format('[%d] is Not Equal to [%d] %s', [2, 1, '']));
end;

{$IFDEF CPU64BITS}
procedure TTestsAssert.AreEqual_Integer_NativeInt_Throws_No_Exception_When_Values_Are_Equal;
begin
  Assert.WillNotRaise(
    procedure
    var
      actual : NativeInt;
      expected : Integer;
    begin
      actual := 1;
      expected := 1;
      Assert.AreEqual(1, actual);
      Assert.AreEqual(actual, expected);
    end, Exception);
end;

procedure TTestsAssert.AreEqual_Integer_NativeInt_Throws_ETestFailure_When_Values_Are_NotEqual;
begin
  Assert.WillRaise(
    procedure
    var
      actual : NativeInt;
    begin
      actual := 2;
      Assert.AreEqual(1, actual);
    end, ETestFailure, Format('[%d] is Not Equal to [%d] %s', [2, 1, '']));
end;
{$ENDIF}

procedure TTestsAssert.AreEqual_Integer_Throws_No_Exception_When_Values_Are_Equal;
begin
  Assert.WillNotRaise(
    procedure
    begin
      Assert.AreEqual(1, 1);
    end, Exception);
end;

procedure TTestsAssert.AreEqual_Stream_Throws_ETestFailure_When_Values_Are_NotEqual;
const
  TESTSTR_STRING    = 'This is a test';
var
  Expected : TStringStream;
  Actual : TStringStream;
begin
  Expected := TStringStream.Create(TESTSTR_STRING);
  Actual := TStringStream.Create('A different value');
  try
    Assert.WillRaise(
      procedure
      begin
        Assert.AreEqual(Expected, Actual);
      end, ETestFailure);
  finally
    Expected.Free();
    Actual.Free();
  end;
end;

procedure TTestsAssert.AreEqual_Stream_Throws_No_Exception_When_Values_Are_Equal;
const
  TESTSTR_STRING    = 'This is a test';
var
  Expected : TStringStream;
  Actual : TStringStream;
begin
  Expected := TStringStream.Create(TESTSTR_STRING);
  Actual := TStringStream.Create(TESTSTR_STRING);
  try
    Assert.WillNotRaise(
      procedure
      begin
        Assert.AreEqual(Expected, Actual);
      end, Exception);
  finally
    Expected.Free();
    Actual.Free();
  end;
end;

procedure TTestsAssert.AreEqual_String_Throws_No_Exception_When_Values_Are_Equal;
const
  ACTUAL_AND_EXPECTED_STRING = 'the brown dog jumped something';
begin
  Assert.WillNotRaise(
    procedure
    begin
      Assert.AreEqual(ACTUAL_AND_EXPECTED_STRING, ACTUAL_AND_EXPECTED_STRING);
    end, Exception);
end;

procedure TTestsAssert.AreEqual_TClass_Throws_ETestFailure_When_Classes_Are_NotEqual;
begin
  Assert.WillRaise(
    procedure
    begin
      Assert.AreEqual(TMockClassOne, TMockClassTwo);
    end, ETestFailure);
end;

procedure TTestsAssert.AreEqual_TClass_Throws_No_Exception_When_Classes_Are_Equal;
begin
  Assert.WillNotRaise(
    procedure
    begin
      Assert.AreEqual(TMockClassOne, TMockClassOne);
    end, ETestFailure);
end;

procedure TTestsAssert.AreEqual_Throws_No_Exception_When_Values_Are_Exactly_Equal;
var
  actualAndExpected, tolerance : Extended;
begin
  //Ensure they are the same value.
  actualAndExpected := 1.1;
  tolerance := 0;

  Assert.WillNotRaise(
    procedure
    begin
      Assert.AreEqual(actualAndExpected, actualAndExpected, tolerance);
    end, Exception);
end;

procedure TTestsAssert.AreEqual_TStrings_Throws_ETestFailure_When_Strings_Are_NotEqual;
var
  expected, actual : TStrings;
begin
  expected := TStringList.Create;
  actual := TStringList.Create;
  try
    expected.CommaText := '1,2,3';
    actual.CommaText := '1,2,3,4';
    Assert.WillRaiseWithMessage(procedure
      begin
        Assert.AreEqual(expected, actual);
      end, ETestFailure, 'Number of strings is not equal: Expected [3] but got [4]');

    expected.CommaText := '"Lorem ipsum dolor sit amet","consectetur adipisici elit","sed eiusmod tempor incidunt"';
    actual.CommaText := '"Lorem ipsum dolor sit amet","consectetur adisipici elit","sed eiusmod tempor incidunt"';
    Assert.WillRaiseWithMessage(procedure
      begin
        Assert.AreEqual(expected, actual);
      end, ETestFailure,
      'Difference at position 16: [''r adipisic''] does not match [''r adisipic''] at line 2');
  finally
    expected.Free;
    actual.Free;
  end;
end;

procedure TTestsAssert.AreEqual_TStrings_Throws_No_Exception_When_Strings_Are_Equal;
var
  expected, actual : TStrings;
begin
  expected := TStringList.Create;
  actual := TStringList.Create;
  try
    Assert.WillNotRaise(procedure
      begin
        Assert.AreEqual(expected, actual);
      end, Exception);

    expected.CommaText := '1,2,3';
    actual.CommaText := '1,2,3';
    Assert.WillNotRaise(procedure
      begin
        Assert.AreEqual(expected, actual);
      end, Exception);

    expected.CommaText := '1,2,3';
    actual.CommaText := '1,-,3';
    Assert.WillNotRaise(procedure
      begin
        Assert.AreEqual(expected, actual, [2]);
      end, Exception);
  finally
    expected.Free;
    actual.Free;
  end;
end;

{$IFDEF DELPHI_XE2_UP}
procedure TTestsAssert.AreEqual_T_Throws_ETestFailure_When_Interfaces_Are_NotEqual;
var
  mock : IInterface;
  mock2 : IInterface;
begin
  mock := TInterfacedObject.Create();
  mock2 := TInterfacedObject.Create();

  Assert.WillRaise(
    procedure
    begin
      Assert.AreEqual<IInterface>(mock, mock2);
    end, ETestFailure);
end;

procedure TTestsAssert.AreEqual_T_Throws_ETestFailure_When_Objects_Are_Nil;
var
  mock : TObject;
  nilObject : TObject;
begin
  mock := TObject.Create();
  try
    nilObject := nil;

    Assert.WillRaise(
      procedure
      begin
        Assert.AreEqual<TObject>(mock, nilObject);
      end, ETestFailure);

    Assert.WillRaise(
      procedure
      begin
        Assert.AreEqual<TObject>(nilObject, mock);
      end, ETestFailure);
  finally
    FreeAndNil(mock);
  end;
end;

procedure TTestsAssert.AreEqual_T_Throws_ETestFailure_When_Objects_Are_NotEqual;
var
  mock : TObject;
  mock2 : TObject;
begin
  mock := TObject.Create;
  mock2 := TObject.Create;
  try
    Assert.WillRaise(
      procedure
      begin
        Assert.AreEqual<TObject>(mock, mock2);
      end, ETestFailure);
  finally
    FreeAndNil(mock);
    FreeAndNil(mock2);
  end;
end;

procedure TTestsAssert.AreEqual_T_Throws_ETestFailure_When_Interfaces_Are_Nil;
var
  mock : IInterface;
begin
  mock := TInterfacedObject.Create();

  Assert.WillRaise(
    procedure
    begin
      Assert.AreEqual<IInterface>(mock, nil);
    end, ETestFailure);

  Assert.WillRaise(
    procedure
    begin
      Assert.AreEqual<IInterface>(nil, mock);
    end, ETestFailure);
end;

procedure TTestsAssert.AreEqual_T_Throws_No_Exception_When_Interfaces_Are_Equal;
var
  mock : IInterface;
begin
  mock := TInterfacedObject.Create();

  Assert.WillNotRaise(
    procedure
    begin
      Assert.AreEqual<IInterface>(mock, mock);
    end, ETestFailure);
end;

procedure TTestsAssert.AreEqual_T_Throws_No_Exception_When_Objects_Are_Equal;
var
  mock : TObject;
begin
  mock := TObject.Create;
  try
    Assert.WillNotRaise(
      procedure
      begin
        Assert.AreEqual<TObject>(mock, mock);
      end, ETestFailure);
  finally
    FreeAndNil(mock);
  end;
end;

procedure TTestsAssert.AreEqual_Array_T_Throws_ETestFailure_When_Arrays_Are_Not_Equal;
begin
  Assert.WillRaise(
    procedure
    begin
      Assert.AreEqual<integer>(TArray<integer>.Create(1, 2, 3), TArray<integer>.Create(1, 2, 3, 4));
    end, ETestFailure);

  Assert.WillRaise(
    procedure
    begin
      Assert.AreEqual<real>(TArray<real>.Create(3.14, 3.15), TArray<real>.Create(3.15, 3.14));
    end, ETestFailure);

  Assert.WillRaise(
    procedure
    begin
      Assert.AreEqual<string>(TArray<string>.Create('a', 'b', 'c'), TArray<string>.Create('a', 'c', 'b'));
    end, ETestFailure);
end;

procedure TTestsAssert.AreEqual_Array_T_Throws_No_Exception_When_Arrays_Are_Equal;
begin
  Assert.WillNotRaise(
    procedure
    begin
      Assert.AreEqual<string>(TArray<string>.Create('a', 'b', 'c'), TArray<string>.Create('a', 'b', 'c'));
    end, ETestFailure);

  Assert.WillNotRaise(
    procedure
    begin
      Assert.AreEqual<real>(TArray<real>.Create(3.14, 3.15), TArray<real>.Create(3.14, 3.15));
    end, ETestFailure);
end;
{$ENDIF}

procedure TTestsAssert.Test_AreSameOnSameObjectWithDifferentInterfaces_No_Exception;
var
  myObject : IInterfaceList;
begin
  myObject := TInterfaceList.Create;
  Assert.WillNotRaise(
    procedure
    begin
      Assert.AreSame(myObject, myObject as IInterface);
    end, ETestFailure);
end;

procedure TTestsAssert.Test64BitListIndex;
var
  x : Int64;
begin
  x := 0;
  Assert.AreEqual(x, x);
  Assert.AreEqual(Int64(0), x);         //compiler can't find overload with 0
  Assert.AreEqual(x, Int64(0));         //compiler can't find overload with 0
end;

procedure TTestsAssert.Test_AreNotSameOnSameObjectWithDifferentInterfaces_Throws_Exception;
var
  myObject : IInterfaceList;
begin
  myObject := TInterfaceList.Create;
  Assert.WillRaise(
    procedure
    begin
      Assert.AreNotSame(myObject, myObject as IInterface);
    end, ETestFailure);
end;

procedure TTestsAssert.AreNotEqual_Integer_Throws_No_Exception_When_Values_Are_NotEqual;
begin
  Assert.WillNotRaise(
    procedure
    begin
      Assert.AreNotEqual(1, 2);
    end, ETestFailure);
end;

procedure TTestsAssert.CheckExpectation_Not_Empty_String_Will_Raise;
begin
  Assert.WillRaise(
    procedure
    begin
      Assert.CheckExpectation('My expectation');
    end, ETestFailure);
end;

procedure TTestsAssert.AreNotEqual_Currency_Throws_Exception_When_Values_Are_Equal;
const
  expected          : currency = 1.34;
  actual            : currency = 1.34;
begin
  Assert.WillRaise(
    procedure
    begin
      Assert.AreNotEqual(expected, actual);
    end, ETestFailure);

end;

procedure TTestsAssert.AreNotEqual_GUID_Throws_Exception_When_Values_Are_Equal;
const
  EXPECTED_GUID     : TGUID = (D1 : 0; D2 : 0; D3 : 0; D4 : (0, 0, 0, 0, 0, 0, 0, 0));
  ACTUAL_GUID       : TGUID = (D1 : 0; D2 : 0; D3 : 0; D4 : (0, 0, 0, 0, 0, 0, 0, 0));
begin
  Assert.WillRaise(
    procedure
    begin
      Assert.AreNotEqual(EXPECTED_GUID, ACTUAL_GUID);
    end, ETestFailure);
end;

procedure TTestsAssert.AreNotEqual_GUID_Throws_No_Exception_When_Values_Are_NotEqual;
const
  EXPECTED_GUID     : TGUID = (D1 : 0; D2 : 0; D3 : 0; D4 : (0, 0, 0, 0, 0, 0, 0, 0));
  ACTUAL_GUID       : TGUID = (D1 : 1; D2 : 1; D3 : 1; D4 : (1, 1, 1, 1, 1, 1, 1, 1));
begin
  Assert.WillNotRaise(
    procedure
    begin
      Assert.AreNotEqual(EXPECTED_GUID, ACTUAL_GUID);
    end, ETestFailure);
end;

procedure TTestsAssert.AreNotEqual_Integer_Throws_Exception_When_Values_Are_Equal;
begin
  Assert.WillRaise(
    procedure
    begin
      Assert.AreNotEqual(1, 1);
    end, ETestFailure);
end;

{$IFDEF DELPHI_XE_UP}
procedure TTestsAssert.Contains_ArrayOfT_Throws_No_Exception_When_Value_In_Array;
begin
  Assert.WillNotRaise(
    procedure
    begin
      Assert.Contains<string>(['x', 'y', 'z'], 'x');
    end, ETestFailure);
end;

procedure TTestsAssert.Contains_ArrayOfT_Throws_Exception_When_Value_Not_In_Array;
begin
  Assert.WillRaise(
    procedure
    begin
      Assert.Contains<string>(['x', 'y', 'z'], 'a');
    end, ETestFailure);
end;

procedure TTestsAssert.DoesNotContain_ArrayOfT_Throws_No_Exception_When_Value_Not_In_Array;
begin
  Assert.WillNotRaise(
    procedure
    begin
      Assert.DoesNotContain<string>(['x', 'y', 'z'], 'a');
    end, ETestFailure);
end;

procedure TTestsAssert.DoesNotContain_ArrayOfT_Throws_Exception_When_Value_In_Array;
begin
  Assert.WillRaise(
    procedure
    begin
      Assert.DoesNotContain<string>(['x', 'y', 'z'], 'x');
    end, ETestFailure);
end;
{$ENDIF}

procedure TTestsAssert.StartsWith_SubString_Is_At_The_Start_Of_String(const subString, theString : string; caseSensitive : boolean);
begin
  Assert.WillNotRaise(
    procedure
    begin
      Assert.StartsWith(subString, theString, caseSensitive);
    end, ETestFailure);
end;

procedure TTestsAssert.StartsWith_SubString_Is_Not_At_Start(const subString, theString : string; caseSensitive : boolean);
begin
  Assert.WillRaise(
    procedure
    begin
      Assert.StartsWith(subString, theString, caseSensitive);
    end, ETestFailure);
end;

procedure TTestsAssert.EndsWith_SubString_Is_At_The_End_Of_String(const subString, theString : string; caseSensitive : boolean);
begin
  Assert.WillNotRaise(
    procedure
    begin
      Assert.EndsWith(subString, theString, caseSensitive);
    end, ETestFailure);
end;

procedure TTestsAssert.EndsWith_SubString_Is_Not_At_End(const subString, theString : string; caseSensitive : boolean);
begin
  Assert.WillRaise(
    procedure
    begin
      Assert.EndsWith(subString, theString, caseSensitive);
    end, ETestFailure);
end;

{$IFDEF SUPPORTS_REGEX}
procedure TTestsAssert.IsMatch_True_Will_Not_Raise(const regexPattern, theString : string);
begin
  Assert.WillNotRaiseAny(
    procedure
    begin
      Assert.IsMatch(regexPattern, theString);
    end
    );
end;

procedure TTestsAssert.IsMatch_False_Will_Raise_ETestFailure(const regexPattern, theString : string);
begin
  Assert.WillRaise(
    procedure
    begin
      Assert.IsMatch(regexPattern, theString);
    end, ETestFailure);
end;

procedure TTestsAssert.WillRaiseWithMessageRegex;
const
  EXCEPTION_MSG_PATT = 'Exception on "%s" doing "%s"';
  EXCEPTION_RE_MATCH = 'Exception on ".+?" doing ".+?"';
  EXCEPTION_RE_NOT_MATCH = 'Exception on something doing anything';
begin
  Assert.WillNotRaiseAny(
    procedure
    begin
      Assert.WillRaiseWithMessageRegex(
        procedure
        begin
          raise Exception.CreateFmt(EXCEPTION_MSG_PATT, ['this', 'that']);
        end,
        nil,
          EXCEPTION_RE_MATCH
          );
    end
    );

  Assert.WillRaise(
    procedure
    begin
      Assert.WillRaiseWithMessageRegex(
        procedure
        begin
          raise Exception.CreateFmt(EXCEPTION_MSG_PATT, ['this', 'that']);
        end,
        nil,
          EXCEPTION_RE_NOT_MATCH
          );
    end,
    ETestFailure);
end;

{$ENDIF}

procedure TTestsAssert.IsEmpty_Variant_Fails_Only_When_Value_Is_Assigned;
var
  value : Variant;
begin
  value := Unassigned;
  Assert.AreEqual('', FailureMessage(procedure begin Assert.IsEmpty(value) end), 'IsEmpty( Unassigned ) failed');
  value := Null;
  Assert.AreEqual('', FailureMessage(procedure begin Assert.IsEmpty(value) end), 'IsEmpty( Null ) failed');
  value := 'abc';
  Assert.AreNotEqual('', FailureMessage(procedure begin Assert.IsEmpty(value) end), 'IsEmpty( ''abc'' ) passed');
end;

procedure TTestsAssert.IsNotEmpty_Variant_Fails_When_Value_Is_Null;
var
  value : Variant;
begin
  value := Null;
  Assert.AreNotEqual('', FailureMessage(procedure begin Assert.IsNotEmpty(value) end), 'IsNotEmpty( Null ) passed');
  value := Unassigned;
  Assert.AreNotEqual('', FailureMessage(procedure begin Assert.IsNotEmpty(value) end), 'IsNotEmpty( Unassigned ) passed');
  value := 'abc';
  Assert.AreEqual('', FailureMessage(procedure begin Assert.IsNotEmpty(value) end), 'IsNotEmpty( ''abc'' ) failed');
end;

procedure TTestsAssert.WillNotRaiseDescendant_Method_Fails_When_Descendant_Raised;
var
  raiser : TMethodRaiser;
begin
  raiser := TMethodRaiser.Create;
  try
    Assert.AreNotEqual('', FailureMessage(
      procedure
      begin
        Assert.WillNotRaiseDescendant(raiser.RaiseFilerError, EStreamError);
      end), 'WillNotRaiseDescendant( TTestMethod ) passed when a descendant of EStreamError was raised');
  finally
    raiser.Free;
  end;
end;

procedure TTestsAssert.AreEqual_T_Double_Fails_When_One_Value_Is_NaN;
var
  nanValue : Double;
begin
  nanValue := NaN;
  Assert.AreNotEqual('', FailureMessage(procedure begin Assert.AreEqual<Double>(1.0, nanValue) end), 'AreEqual<Double>( 1, NaN ) passed');
  Assert.AreNotEqual('', FailureMessage(procedure begin Assert.AreEqual<Double>(nanValue, 1.0) end), 'AreEqual<Double>( NaN, 1 ) passed');
  Assert.AreEqual('', FailureMessage(procedure begin Assert.AreNotEqual<Double>(1.0, nanValue) end), 'AreNotEqual<Double>( 1, NaN ) failed');
  Assert.AreNotEqual('', FailureMessage(
    procedure
    begin
      Assert.AreEqual<Double>(TArray<Double>.Create(1.0, 2.0), TArray<Double>.Create(1.0, nanValue));
    end), 'AreEqual<Double>( TArray ) passed with a NaN element');
end;

procedure TTestsAssert.Contains_T_Double_Does_Not_Match_NaN;
var
  nanValue : Double;
begin
  nanValue := NaN;
  Assert.AreNotEqual('', FailureMessage(procedure begin Assert.Contains<Double>([1.0, 2.0], nanValue) end), 'Contains<Double> matched NaN');
  Assert.AreEqual('', FailureMessage(procedure begin Assert.DoesNotContain<Double>([1.0, 2.0], nanValue) end), 'DoesNotContain<Double> matched NaN');
end;

procedure TTestsAssert.WillRaise_Family_Does_Not_Swallow_A_Failed_Assertion;
const
  INNER_MSG = 'inner failure';
begin
  Assert.WillRaiseWithMessage(
    procedure
    begin
      Assert.WillRaiseAny(procedure begin Assert.Fail(INNER_MSG) end);
    end, ETestFailure, INNER_MSG, 'WillRaiseAny swallowed a failed assertion');
  Assert.WillRaiseWithMessage(
    procedure
    begin
      Assert.WillRaise(procedure begin Assert.Fail(INNER_MSG) end);
    end, ETestFailure, INNER_MSG, 'WillRaise swallowed a failed assertion');
  Assert.WillRaiseWithMessage(
    procedure
    begin
      Assert.WillRaiseDescendant(procedure begin Assert.Fail(INNER_MSG) end, Exception);
    end, ETestFailure, INNER_MSG, 'WillRaiseDescendant( Exception ) swallowed a failed assertion');
  Assert.WillRaiseWithMessage(
    procedure
    begin
      Assert.WillRaiseWithMessage(procedure begin Assert.Fail(INNER_MSG) end);
    end, ETestFailure, INNER_MSG, 'WillRaiseWithMessage swallowed a failed assertion');
{$IFDEF SUPPORTS_REGEX}
  Assert.WillRaiseWithMessage(
    procedure
    begin
      Assert.WillRaiseWithMessageRegex(procedure begin Assert.Fail(INNER_MSG) end);
    end, ETestFailure, INNER_MSG, 'WillRaiseWithMessageRegex swallowed a failed assertion');
{$ENDIF}
end;

procedure TTestsAssert.WillRaise_Family_Does_Not_Swallow_Pass_Or_Ignore;
begin
  Assert.WillRaiseWithMessage(
    procedure
    begin
      Assert.WillRaiseAny(procedure begin Assert.Pass('inner pass') end);
    end, ETestPass, 'inner pass', 'WillRaiseAny swallowed Assert.Pass');
  Assert.WillRaiseWithMessage(
    procedure
    begin
      Assert.WillRaiseDescendant(procedure begin Assert.Ignore('inner ignore') end, Exception);
    end, ETestIgnored, 'inner ignore', 'WillRaiseDescendant( Exception ) swallowed Assert.Ignore');
end;

procedure TTestsAssert.WillNotRaise_Family_Passes_Test_Outcomes_Through;
begin
  Assert.WillRaiseWithMessage(
    procedure
    begin
      Assert.WillNotRaiseAny(procedure begin Assert.Pass('inner pass') end);
    end, ETestPass, 'inner pass', 'WillNotRaiseAny converted Assert.Pass');
  Assert.WillRaiseWithMessage(
    procedure
    begin
      Assert.WillNotRaise(procedure begin Assert.Ignore('inner ignore') end, nil);
    end, ETestIgnored, 'inner ignore', 'WillNotRaise( nil ) converted Assert.Ignore');
  Assert.WillRaiseWithMessage(
    procedure
    begin
      Assert.WillNotRaise(procedure begin Assert.Fail('inner fail') end, EConvertError);
    end, ETestFailure, 'inner fail', 'WillNotRaise( EConvertError ) swallowed Assert.Fail');
  Assert.WillRaiseWithMessage(
    procedure
    begin
      Assert.WillNotRaiseDescendant(procedure begin Assert.Pass('inner pass') end, nil);
    end, ETestPass, 'inner pass', 'WillNotRaiseDescendant( nil ) converted Assert.Pass');
  Assert.WillRaiseWithMessage(
    procedure
    begin
      Assert.WillNotRaiseWithMessage(procedure begin Assert.Pass('inner pass') end, nil, '');
    end, ETestPass, 'inner pass', 'WillNotRaiseWithMessage( nil ) converted Assert.Pass');
end;

procedure TTestsAssert.WillNotRaise_User_Message_Is_Not_A_Format_String;
const
  USER_MSG = 'coverage 100% %s';
var
  msg : string;
begin
  msg := FailureMessage(
    procedure
    begin
      Assert.WillNotRaiseAny(procedure begin raise Exception.Create('boom') end, USER_MSG);
    end);
  Assert.Contains(msg, USER_MSG, False, 'WillNotRaiseAny lost or reformatted the user message');

  msg := FailureMessage(
    procedure
    begin
      Assert.WillNotRaise(procedure begin raise Exception.Create('boom') end, nil, USER_MSG);
    end);
  Assert.Contains(msg, USER_MSG, False, 'WillNotRaise( nil ) lost or reformatted the user message');
end;

procedure TTestsAssert.WillNotRaise_Nil_Class_Fails_Readably;
var
  msg : string;
begin
  msg := FailureMessage(
    procedure
    begin
      Assert.WillNotRaiseDescendant(procedure begin raise EFilerError.Create('boom') end, nil);
    end);
  Assert.Contains(msg, 'EFilerError', False, 'WillNotRaiseDescendant( nil ) did not name the raised class');

  msg := FailureMessage(
    procedure
    begin
      Assert.WillNotRaiseWithMessage(procedure begin raise EFilerError.Create('boom') end, nil, 'boom');
    end);
  Assert.Contains(msg, 'EFilerError', False, 'WillNotRaiseWithMessage( nil ) did not name the raised class');
end;

procedure TTestsAssert.WillRaise_Family_Wrong_Class_Failure_Includes_Caller_Message;
const
  CALLER_MSG = 'caller context 7Q';
var
  msg : string;
begin
  msg := FailureMessage(
    procedure
    begin
      Assert.WillRaise(procedure begin raise EFilerError.Create('boom') end, EConvertError, CALLER_MSG);
    end);
  Assert.Contains(msg, CALLER_MSG, False, 'WillRaise dropped the caller''s message on a wrong class');

  msg := FailureMessage(
    procedure
    begin
      Assert.WillRaiseDescendant(procedure begin raise EFilerError.Create('boom') end, EConvertError, CALLER_MSG);
    end);
  Assert.Contains(msg, CALLER_MSG, False, 'WillRaiseDescendant dropped the caller''s message on a wrong class');

  msg := FailureMessage(
    procedure
    begin
      Assert.WillRaiseWithMessage(procedure begin raise EFilerError.Create('boom') end, EConvertError, 'boom', CALLER_MSG);
    end);
  Assert.Contains(msg, CALLER_MSG, False, 'WillRaiseWithMessage dropped the caller''s message on a wrong class');
end;

procedure TTestsAssert.AreSame_Object_Compares_Identity;
var
  first, second : TAlwaysEqual;
begin
  first := TAlwaysEqual.Create;
  second := TAlwaysEqual.Create;
  try
    Assert.AreNotEqual('', FailureMessage(procedure begin Assert.AreSame(first, second) end),
      'AreSame passed for two instances whose Equals is overridden');
    Assert.AreEqual('', FailureMessage(procedure begin Assert.AreNotSame(first, second) end),
      'AreNotSame failed for two distinct instances');
    Assert.AreEqual('', FailureMessage(procedure begin Assert.AreSame(first, first) end), 'AreSame failed for one instance');
    Assert.AreNotEqual('', FailureMessage(procedure begin Assert.AreSame(TObject(nil), first) end), 'AreSame( nil, obj ) passed');
    Assert.AreEqual('', FailureMessage(procedure begin Assert.AreNotSame(TObject(nil), first) end), 'AreNotSame( nil, obj ) failed');
  finally
    second.Free;
    first.Free;
  end;
end;

procedure TTestsAssert.AreEqual_Double_Infinity_And_Negative_Tolerance;
var
  posInf, negInf, one, two, zeroTol, negTol : Double;
  msg : string;
begin
  posInf := Infinity;
  negInf := NegInfinity;
  one := 1;
  two := 2;
  zeroTol := 0;
  negTol := -0.5;
  Assert.AreEqual('', FailureMessage(procedure begin Assert.AreEqual(posInf, posInf, zeroTol) end), 'AreEqual( Inf, Inf ) failed');
  Assert.AreNotEqual('', FailureMessage(procedure begin Assert.AreNotEqual(posInf, posInf, zeroTol) end), 'AreNotEqual( Inf, Inf ) passed');
  Assert.AreNotEqual('', FailureMessage(procedure begin Assert.AreEqual(posInf, negInf, zeroTol) end), 'AreEqual( Inf, -Inf ) passed');
  Assert.AreNotEqual('', FailureMessage(procedure begin Assert.AreNotEqual(one, two, negTol) end),
    'AreNotEqual accepted a negative tolerance');
  msg := FailureMessage(procedure begin Assert.AreEqual(one, one, negTol) end);
  Assert.Contains(msg, 'negative', False, 'AreEqual accepted a negative tolerance');
end;

procedure TTestsAssert.AreEqual_Extended_Infinity_And_Negative_Tolerance;
var
  posInf, negInf, one, two, zeroTol, negTol : Extended;
  msg : string;
begin
  posInf := Infinity;
  negInf := NegInfinity;
  one := 1;
  two := 2;
  zeroTol := 0;
  negTol := -0.5;
  Assert.AreEqual('', FailureMessage(procedure begin Assert.AreEqual(posInf, posInf, zeroTol) end), 'AreEqual( Inf, Inf ) failed');
  Assert.AreNotEqual('', FailureMessage(procedure begin Assert.AreNotEqual(posInf, posInf, zeroTol) end), 'AreNotEqual( Inf, Inf ) passed');
  Assert.AreNotEqual('', FailureMessage(procedure begin Assert.AreEqual(posInf, negInf, zeroTol) end), 'AreEqual( Inf, -Inf ) passed');
  Assert.AreNotEqual('', FailureMessage(procedure begin Assert.AreNotEqual(one, two, negTol) end),
    'AreNotEqual accepted a negative tolerance');
  msg := FailureMessage(procedure begin Assert.AreEqual(one, one, negTol) end);
  Assert.Contains(msg, 'negative', False, 'AreEqual accepted a negative tolerance');
end;

procedure TTestsAssert.Failure_Messages_Describe_The_Failure;
var
  currencyOne, currencyTwo : Currency;
  cardinalMax, cardinalZero : Cardinal;
  msg : string;
begin
  currencyOne := 1;
  currencyTwo := 2;
  msg := FailureMessage(procedure begin Assert.AreEqual(currencyOne, currencyTwo) end);
  Assert.StartsWith('Expected [1] but got [2]', msg, False, 'AreEqual( Currency ) message: ' + msg);

  msg := FailureMessage(procedure begin Assert.DoesNotContain('abc', 'b', False) end);
  Assert.Contains(msg, '[abc] contains [b]', False, 'DoesNotContain message: ' + msg);

  cardinalMax := High(Cardinal);
  cardinalZero := 0;
  msg := FailureMessage(procedure begin Assert.AreEqual(cardinalMax, cardinalZero) end);
  Assert.Contains(msg, '4294967295', False, 'AreEqual( Cardinal ) message: ' + msg);

  msg := FailureMessage(
    procedure
    begin
      Assert.WillNotRaiseDescendant(procedure begin raise EFilerError.Create('boom') end, EStreamError);
    end);
  Assert.Contains(msg, 'EFilerError', False, 'WillNotRaiseDescendant message: ' + msg);
end;

procedure TTestsAssert.AreEqual_TStrings_Same_Instance_And_Duplicate_IgnoreLines;
var
  expected, actual : TStringList;
begin
  expected := TStringList.Create;
  actual := TStringList.Create;
  try
    expected.Add('a');
    expected.Add('b');
    actual.Add('a');
    actual.Add('c');
    Assert.AreEqual('', FailureMessage(procedure begin Assert.AreEqual(expected, expected) end),
      'AreEqual( TStrings ) failed for the same instance');
    Assert.AreEqual('', FailureMessage(procedure begin Assert.AreEqual(expected, actual, [2, 2]) end),
      'AreEqual( TStrings ) failed with a duplicated ignoreLines entry');
  finally
    actual.Free;
    expected.Free;
  end;
end;

procedure TTestsAssert.Contains_And_DoesNotContain_Reject_Empty_SubString;
var
  msg : string;
begin
  msg := FailureMessage(procedure begin Assert.Contains('abc', '', False) end);
  Assert.Contains(msg, 'cannot be empty', False, 'Contains( '''' ) message: ' + msg);
  msg := FailureMessage(procedure begin Assert.DoesNotContain('abc', '', False) end);
  Assert.Contains(msg, 'cannot be empty', False, 'DoesNotContain( '''' ) message: ' + msg);
end;

procedure TTestsAssert.AreEqual_Stream_Restores_Positions_And_Accepts_Same_Instance;
var
  first, second : TStringStream;
begin
  first := TStringStream.Create('abcdef');
  second := TStringStream.Create('abcdef');
  try
    first.Position := 2;
    second.Position := 3;
    Assert.AreEqual(TStream(first), TStream(second));
    Assert.AreEqual(Int64(2), first.Position, 'expected stream position not restored');
    Assert.AreEqual(Int64(3), second.Position, 'actual stream position not restored');
    Assert.AreEqual('', FailureMessage(procedure begin Assert.AreEqual(TStream(first), TStream(first)) end),
      'AreEqual( TStream ) failed for the same instance');
  finally
    second.Free;
    first.Free;
  end;
end;

procedure TTestsAssert.AreEqual_Stream_Fails_When_Read_Returns_Nothing;
var
  first, second : TStream;
begin
  first := TStreamThatReadsNothing.Create;
  second := TStreamThatReadsNothing.Create;
  try
    Assert.AreNotEqual('', FailureMessage(procedure begin Assert.AreEqual(first, second) end),
      'AreEqual( TStream ) passed for streams that delivered no bytes');
  finally
    second.Free;
    first.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestsAssert);

end.

