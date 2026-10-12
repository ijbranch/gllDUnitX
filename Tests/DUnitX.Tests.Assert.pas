{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2017 Vincent Parrett                              }
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
  [TestFixture]
  TTestsAssert = class
  published
    [Test]
    procedure Pass_Throws_ETestPass_Exception;

    [Test]
    procedure Pass_Throws_ETestPass_Exception_With_Message;

    [Test]
    procedure Ignore_Throws_ETestIgnored_Exception;

    [Test]
    procedure Ignore_Throws_ETestIgnored_Exception_With_Message;

    [Test]
    procedure Fail_Throws_ETestFailure_Exception;

    [Test]
    procedure Fail_Throws_ETestFailure_Exception_With_Message;

    [Test]
    procedure Fail_Throws_ETestFailure_Exception_With_Return_Address_Reference;

    [Test]
    procedure Fail_Throws_ETestFailure_Exception_With_Caller_Address_Reference;

    [Test]
    procedure AreEqual_String_Throws_No_Exception_When_Values_Are_Equal;

    [Test]
    procedure AreEqual_Integer_Throws_No_Exception_When_Values_Are_Equal;

    [Test]
    procedure AreEqual_Integer_Throws_ETestFailure_When_Values_Are_NotEqual;

{$IFDEF CPU64BITS}
    [Test]
    procedure AreEqual_Integer_NativeInt_Throws_No_Exception_When_Values_Are_Equal;

    [Test]
    procedure AreEqual_Integer_NativeInt_Throws_ETestFailure_When_Values_Are_NotEqual;
{$ENDIF}

    [Test]
    procedure AreEqual_Extended_Throws_No_Exception_When_Values_Are_Equal;

    [Test]
    procedure AreEqual_Extended_Throws_ETestFailure_When_Values_Are_NotEqual;

    [Test]
    procedure AreEqual_Double_Throws_No_Exception_When_Values_Are_Equal;

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

    [Test]
    procedure AreEqual_Currency_Throws_ETestFailure_When_Values_Are_NotEqual;

    [Test]
    procedure AreEqual_GUID_Throws_No_Exception_When_Values_Are_Equal;

    [Test]
    procedure AreEqual_GUID_Throws_ETestFailure_When_Values_Are_NotEqual;

    [Test]
    procedure AreEqual_Stream_Throws_No_Exception_When_Values_Are_Equal;

    [Test]
    procedure AreEqual_Stream_Throws_ETestFailure_When_Values_Are_NotEqual;

    [Test]
    procedure AreEqual_TClass_Throws_No_Exception_When_Classes_Are_Equal;

    [Test]
    procedure AreEqual_TClass_Throws_ETestFailure_When_Classes_Are_NotEqual;

    [Test]
    [TestCase('Empty', ',,false')]
    [TestCase('CR', #13','#13',false')]
    [TestCase('Simple', 'abc,abc,false')]
    [TestCase('Ignore case simple', 'abc,ABC,true')]
    [TestCase('Ignore case complex', 'LoReM iPsUm DoLoR sIt AmEt,lOrEm IpSuM dOlOr SiT aMeT,true')]
    procedure NoDiff_Throws_No_Exception_When_Strings_Are_Equal(const A, B : string; AIgnoreCase : boolean = false);

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

    [Test]
    procedure AreEqual_TStrings_Throws_No_Exception_When_Strings_Are_Equal;

    [Test]
    procedure AreEqual_TStrings_Throws_ETestFailure_When_Strings_Are_NotEqual;

{$IFDEF DELPHI_XE2_UP}
    [Test]
    procedure AreEqual_T_Throws_No_Exception_When_Interfaces_Are_Equal;

    [Test]
    procedure AreEqual_T_Throws_ETestFailure_When_Interfaces_Are_NotEqual;

    [Test]
    procedure AreEqual_T_Throws_ETestFailure_When_Interfaces_Are_Nil;

    [Test]
    procedure AreEqual_T_Throws_No_Exception_When_Objects_Are_Equal;

    [Test]
    procedure AreEqual_T_Throws_ETestFailure_When_Objects_Are_NotEqual;

    [Test]
    procedure AreEqual_T_Throws_ETestFailure_When_Objects_Are_Nil;

    [Test]
    procedure AreEqual_Array_T_Throws_No_Exception_When_Arrays_Are_Equal;

    [Test]
    procedure AreEqual_Array_T_Throws_ETestFailure_When_Arrays_Are_Not_Equal;

{$ENDIF}

    [Test]
    procedure AreEqualMemory_Throws_No_Exception_When_Pointers_Are_Equal;

    [Test]
    procedure AreEqualMemory_Throws_ETestFailure_When_Pointers_Are_NotEqual;

    [Test]
    procedure AreEqual_Throws_No_Exception_When_Values_Are_Exactly_Equal;

    [Test]
    procedure AreNotEqual_Integer_Throws_No_Exception_When_Values_Are_NotEqual;

    [Test]
    procedure AreNotEqual_Integer_Throws_Exception_When_Values_Are_Equal;

    [Test]
    procedure AreNotEqual_Currency_Throws_Exception_When_Values_Are_Equal;

    [Test]
    procedure AreNotEqual_GUID_Throws_No_Exception_When_Values_Are_NotEqual;

    [Test]
    procedure AreNotEqual_GUID_Throws_Exception_When_Values_Are_Equal;

    [Test]
    procedure WillRaise_Without_Exception_Class_Will_Capture_Any_Exception;

    [Test]
    procedure WillRaiseWithMessage_Exception_And_Message_Will_Check_ExceptionClass_And_Exception_Message;

    [Test]
    procedure WillRaiseWithMessage_Without_Exception_Class_And_Message_Will_Capture_Any_Exception;

    [Test]
    procedure WillRaiseWithMessage_Without_Exception_Class_With_Message_Will_Capture_Any_Exception_With_Message;

    [Test]
    procedure WillRaiseWithMessage_Exception_Not_Thrown_Throws_ETestFailure_Exception;

    [Test]
    procedure WillRaiseDescendant_With_NonDescendingClass;

    [Test]
    procedure WillRaiseDescendant_With_DescendingClass;

    [Test]
    procedure WillRaiseDescendant_With_ExactClass;

    [Test]
    procedure WillRaiseAny;

    [Test]
    procedure WillRaiseAny_NoExecption;

    [Test]
    procedure WillNotRaise_With_ExactClass_Positive;

    [Test]
    procedure WillNotRaise_With_ExactClass_Negative;

    [Test]
    procedure WillNotRaise_With_DescendingClass_Positive;

    [Test]
    procedure WillNotRaise_With_DescendingClass_Negative;

    [Test]
    procedure WillNotRaise_With_NoClass;

    [Test]
    procedure Test_Implements_Will_Fail_If_Not_Implemented;

    [Test]
    procedure Test_Implements_Will_Pass_If_Implemented;

    [Test]
    procedure Test_AreSameOnSameObjectWithDifferentInterfaces_No_Exception;

    [Test]
    procedure Test_AreNotSameOnSameObjectWithDifferentInterfaces_Throws_Exception;

{$IFDEF DELPHI_XE_UP}
    [Test]
    procedure Contains_ArrayOfT_Throws_No_Exception_When_Value_In_Array;

    [Test]
    procedure Contains_ArrayOfT_Throws_Exception_When_Value_Not_In_Array;

    [Test]
    procedure DoesNotContain_ArrayOfT_Throws_No_Exception_When_Value_Not_In_Array;

    [Test]
    procedure DoesNotContain_ArrayOfT_Throws_Exception_When_Value_In_Array;
{$ENDIF}

    [Test]
    [TestCase('substring', 'a str,a string,false')]
    [TestCase('substring - case sensitive', 'a str,a string,true')]
    procedure StartsWith_SubString_Is_At_The_Start_Of_String(const subString, theString : string; caseSensitive : boolean);

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

    [Test]
    [TestCase('substring', 'ing,a string,false')]
    [TestCase('substring - case sensitive', 'ing,a string,true')]
    procedure EndsWith_SubString_Is_At_The_End_Of_String(const subString, theString : string; caseSensitive : boolean);

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

    [Test]
    procedure IgnoreCaseDefault;

{$IFDEF SUPPORTS_REGEX}
    [Test]
    [TestCase('GUID with dash', '[0-9A-F]{8}[-]?([0-9A-F]{4}[-]?){3}[0-9A-F]{12},C687683F-F25B-4F9A-A231-31C52253B6A1')]
    [TestCase('GUID without dash', '[0-9A-F]{8}[-]?([0-9A-F]{4}[-]?){3}[0-9A-F]{12},C687683FF25B4F9AA23131C52253B6A1')]
    procedure IsMatch_True_Will_Not_Raise(const regexPattern, theString : string);

    [Test]
    [TestCase('GUID with dash', '[0-9A-F]{8}[-]([0-9A-F]{4}[-]){3}[0-9A-F]{12},C687683F-F25B-4F9A-A231-31C52253B6A#')]
    [TestCase('GUID without dash', '[0-9A-F]{8}[-]?([0-9A-F]{4}[-]?){3}[0-9A-F]{12},C687683FF25B4F9AA23131C52253B6A#')]
    procedure IsMatch_False_Will_Raise_ETestFailure(const regexPattern, theString : string);

    [Test]
    procedure WillRaiseWithMessageRegex;
{$ENDIF}

    procedure WillNotRaiseWithMessage_NilExceptionParam_NoExceptionMessage_WillRaise;
    procedure WillNotRaiseWithMessage_MatchingExceptionParam_MatchingExceptionMessage_WillRaise;
    procedure WillNotRaiseWithMessage_MatchingExceptionParam_NoExceptionMessage_WillRaise;
    procedure WillNotRaiseWithMessage_MatchingExceptionParam_NonMatchingExceptionMessage_WillNotRaise;
    procedure WillNotRaiseWithMessage_NilExceptionParam_MatchingExceptionMessage_WillRaise;
    procedure WillNotRaiseWithMessage_NilExceptionParam_NonMatchingExceptionMessage_WillNotRaise;
    procedure WillNotRaiseWithMessage_NonMatchingExceptionParam_MatchingExceptionMessage_WillNotRaise;
    procedure WillNotRaiseWithMessage_NonMatchingExceptionParam_NoExceptionMessage_WillNotRaise;
    procedure WillNotRaiseWithMessage_NonMatchingExceptionParam_NonMatchingExceptionMessage_WillNotRaise;

    [Test]
    procedure CheckExpectation_Not_Empty_String_Will_Raise;

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
    ///   Proves AreEqual( TStream ) restores both streams' positions and passes for the same instance.
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
  Assert.WillRaise(
    procedure
    begin
      Assert.Fail(EXPECTED_EXCEPTION_MSG);
    end, ETestFailure, EXPECTED_EXCEPTION_MSG);
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
  Assert.WillRaise(
    procedure
    begin
      Assert.Pass(EXPECTED_EXCEPTION_MSG);
    end, ETestPass, EXPECTED_EXCEPTION_MSG);
end;

//  Assert.Ignore is the runtime counterpart of the [Ignore] attribute: it
//  stops a test whose PRECONDITION turned out to be absent and reports it
//  as ignored rather than passed. Without it the only ways to skip are
//  Assert.Pass, which lies, and doing nothing, which lies more quietly.
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
  Assert.WillRaise(
    procedure
    begin
      Assert.Ignore(EXPECTED_EXCEPTION_MSG);
    end, ETestIgnored, EXPECTED_EXCEPTION_MSG);
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
  Assert.WillNotRaise(
    procedure
    begin
      Assert.WillNotRaiseWithMessage(
        procedure
        begin
          raise Exception.Create('Test');
        end, nil, 'Different Exception Message');
    end);
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
  Assert.WillNotRaise(
    procedure
    begin
      Assert.WillNotRaiseWithMessage(
        procedure
        begin
          raise TestExceptionOne.Create('Test');
        end, TestExceptionOne, 'Different Exception Message');
    end);
end;

procedure TTestsAssert.WillNotRaiseWithMessage_NonMatchingExceptionParam_NoExceptionMessage_WillNotRaise;
begin
  Assert.WillNotRaise(
    procedure
    begin
      Assert.WillNotRaiseWithMessage(
        procedure
        begin
          raise TestExceptionOne.Create('Test');
        end, TestExceptionTwo);
    end);
end;

procedure TTestsAssert.WillNotRaiseWithMessage_NonMatchingExceptionParam_MatchingExceptionMessage_WillNotRaise;
begin
  Assert.WillNotRaise(
    procedure
    begin
      Assert.WillNotRaiseWithMessage(
        procedure
        begin
          raise TestExceptionOne.Create('Test');
        end, TestExceptionTwo, 'Test');
    end);
end;

procedure TTestsAssert.WillNotRaiseWithMessage_NonMatchingExceptionParam_NonMatchingExceptionMessage_WillNotRaise;
begin
  Assert.WillNotRaise(
    procedure
    begin
      Assert.WillNotRaiseWithMessage(
        procedure
        begin
          raise TestExceptionOne.Create('Test');
        end, TestExceptionTwo, 'Different Exception Message');
    end);
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
  Assert.WillNotRaiseDescendant(
    procedure
    begin
      raise Exception.Create('Test');
    end,
    EStreamError);
end;

procedure TTestsAssert.WillNotRaise_With_ExactClass_Negative;
const
  EXPECTED_EXCEPTION_MSG = 'Passing Message';
begin
  Assert.WillRaise(
    procedure
    begin
      Assert.WillNotRaise(
        procedure
        begin
          raise EStreamError.Create('Error Message');
        end,
        EStreamError, EXPECTED_EXCEPTION_MSG);
    end,
    ETestFailure,
      EXPECTED_EXCEPTION_MSG);
end;

procedure TTestsAssert.WillNotRaise_With_ExactClass_Positive;
begin
  Assert.WillNotRaise(
    procedure
    begin
      // Don't raise an exception we are looking for.
      raise Exception.Create('Error Message');
    end,
    EStreamError, '');
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
begin
  Assert.Pass;
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
  EXPECTED_GUID     : TGUID = (D1 : 0; D2 : 0; D3 : 0; D4 : (0, 0, 0, 0, 0, 0, 0, 0));
  ACTUAL_GUID       : TGUID = (D1 : 1; D2 : 1; D3 : 1; D4 : (1, 1, 1, 1, 1, 1, 1, 1));
begin
  Assert.WillNotRaise(
    procedure
    begin
      Assert.AreNotEqual(EXPECTED_GUID, ACTUAL_GUID);
    end, Exception);
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

