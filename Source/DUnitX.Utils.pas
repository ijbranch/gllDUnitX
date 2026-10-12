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
{                                                                           }
{ Portions of the file also fall under the following license                }
{ as they were taken from the DSharp Project                                }
{ https://bitbucket.org/sglienke/dsharp                                     }
{                                                                           }
(*
  Copyright (c) 2011-2012, Stefan Glienke
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:

  - Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
  - Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.
  - Neither the name of this library nor the names of its contributors may be
    used to endorse or promote products derived from this software without
    specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE.
*)

unit DUnitX.Utils;

interface

{$I DUnitX.inc}

uses
{$IFDEF USE_NS}
  System.Generics.Collections,
  System.TimeSpan,
  System.Rtti,
  System.SysUtils,
  System.Types,
  System.TypInfo;
{$ELSE}
  Generics.Collections,
  TimeSpan,
  Rtti,
  SysUtils,
  Types,
  TypInfo;
{$ENDIF}

type
  /// <summary>
  ///   Class reference to an attribute class, used to search attribute arrays by exact class.
  /// </summary>
  TCustomAttributeClass = class of TCustomAttribute;

  /// <summary>
  ///   Static helpers that search an array of attributes (as returned by RTTI) for a given attribute class.
  /// </summary>
  /// <remarks>
  ///   Matching is by EXACT class (<c>ClassType = AttributeClass</c>); descendants of the class are not matched.
  /// </remarks>
  TAttributeUtils = class
  public
    /// <summary>
    ///   Reports whether the array holds an attribute of exactly the given class.
    /// </summary>
    /// <param name="attributes">
    ///   The attributes to search.
    /// </param>
    /// <param name="AttributeClass">
    ///   The attribute class to look for; descendants do not match.
    /// </param>
    /// <returns>
    ///   True when at least one attribute's class is exactly <c>AttributeClass</c>.
    /// </returns>
    class function ContainsAttribute(const attributes : TArray<TCustomAttribute>; const AttributeClass : TCustomAttributeClass) : boolean;
    /// <summary>
    ///   Returns the first attribute of exactly the given class.
    /// </summary>
    /// <param name="attributes">
    ///   The attributes to search.
    /// </param>
    /// <param name="AttributeClass">
    ///   The attribute class to look for; descendants do not match.
    /// </param>
    /// <returns>
    ///   The first matching attribute, or nil when there is none.
    /// </returns>
    class function FindAttribute(const attributes : TArray<TCustomAttribute>; const AttributeClass : TCustomAttributeClass) : TCustomAttribute; overload;
    /// <summary>
    ///   Finds the next attribute of exactly the given class at or after a start index, so a caller can iterate
    ///   through every match by passing the previous result plus one.
    /// </summary>
    /// <param name="attributes">
    ///   The attributes to search.
    /// </param>
    /// <param name="AttributeClass">
    ///   The attribute class to look for; descendants do not match.
    /// </param>
    /// <param name="attribute">
    ///   Receives the matching attribute, or nil when none is found.
    /// </param>
    /// <param name="startIndex">
    ///   Zero-based index at which the search starts.
    /// </param>
    /// <returns>
    ///   The zero-based index of the match, or -1 when there is none.
    /// </returns>
    class function FindAttribute(const attributes : TArray<TCustomAttribute>; const AttributeClass : TCustomAttributeClass;
      var attribute : TCustomAttribute; const startIndex : integer = 0) : integer; overload;
    /// <summary>
    ///   Returns every attribute of exactly the given class, in array order.
    /// </summary>
    /// <param name="attributes">
    ///   The attributes to search.
    /// </param>
    /// <param name="AttributeClass">
    ///   The attribute class to look for; descendants do not match.
    /// </param>
    /// <returns>
    ///   The matching attributes; an empty array when there are none.
    /// </returns>
    class function FindAttributes(const attributes : TArray<TCustomAttribute>; const AttributeClass : TCustomAttributeClass) : TArray<TCustomAttribute>;
  end;

{$IFDEF DELPHI_2010}
const
  /// <summary>Number of TTimeSpan ticks (100 ns units) in one millisecond; Delphi 2010 only.</summary>
  TicksPerMillisecond = 10000;

type
  /// <summary>
  ///   Back-fills <c>TTimeSpan.Subtract</c> for Delphi 2010, whose RTL lacks it.
  /// </summary>
  TTimeSpanHelper = record helper for TTimeSpan
  public
    /// <summary>
    ///   Returns the time span between two date-times, to millisecond precision.
    /// </summary>
    /// <param name="D1">
    ///   The later date-time.
    /// </param>
    /// <param name="D2">
    ///   The earlier date-time, subtracted from <c>D1</c>.
    /// </param>
    /// <returns>
    ///   <c>D1 - D2</c> as a TTimeSpan (negative when D2 is later).
    /// </returns>
    class function Subtract(const D1, D2 : TDateTime) : TTimeSpan; static;
  end;
{$ENDIF}

type
  /// <summary>
  ///   Static string helpers used by the framework's loggers and runners.
  /// </summary>
  TStrUtils = class
    /// <summary>
    ///   Pads a string with a fill character up to a minimum length.
    /// </summary>
    /// <param name="s">
    ///   The string to pad.
    /// </param>
    /// <param name="totalLength">
    ///   The length to pad up to; a longer string is returned unchanged, never truncated.
    /// </param>
    /// <param name="padLeft">
    ///   True to add the fill characters on the left (right-align), False to add them on the right.
    /// </param>
    /// <param name="padChr">
    ///   The fill character.
    /// </param>
    /// <returns>
    ///   The padded string.
    /// </returns>
    class function PadString(const s : string; const totalLength : integer; const padLeft : boolean = True; padChr : Char = ' ') : string;
    /// <summary>
    ///   Splits a string at every occurrence of any of the delimiter characters.
    /// </summary>
    /// <param name="S">
    ///   The string to split.
    /// </param>
    /// <param name="Delimiters">
    ///   The set of delimiter characters; each character is a delimiter on its own.
    /// </param>
    /// <returns>
    ///   The parts. Adjacent delimiters, and a leading or trailing delimiter, produce empty parts; an empty
    ///   <c>S</c> produces an empty array.
    /// </returns>
    class function SplitString(const S, Delimiters : string) : TArray<string>;
    /// <summary>
    ///   Concatenates strings with a delimiter between them.
    /// </summary>
    /// <param name="values">
    ///   The strings to join.
    /// </param>
    /// <param name="delim">
    ///   The delimiter placed between values.
    /// </param>
    /// <returns>
    ///   The joined string.
    /// </returns>
    /// <remarks>
    ///   The delimiter is only added once the result is non-empty, so leading empty values vanish without a
    ///   delimiter (<c>['', 'a']</c> gives <c>'a'</c>).
    /// </remarks>
    class function Join(const values : TArray<string>; const delim : string) : string; overload;
    /// <summary>
    ///   Renders a string as a Pascal-style literal so control characters are visible: printable runs are quoted
    ///   and each character below #32 becomes <c>#nn</c> (e.g. <c>'ab'#13#10'cd'</c>).
    /// </summary>
    /// <param name="S">
    ///   The string to encode.
    /// </param>
    /// <returns>
    ///   The encoded string; an empty <c>S</c> gives an empty result.
    /// </returns>
    class function EncodeWhitespace(const S : string) : string;
  end;

  /// <summary>
  ///   Static helpers for <c>TList&lt;string&gt;</c>.
  /// </summary>
  TListStringUtils = class
    /// <summary>
    ///   Copies a string list into a new dynamic array.
    /// </summary>
    /// <param name="values">
    ///   The list to copy; it is not modified.
    /// </param>
    /// <returns>
    ///   A new array holding the list's items in order.
    /// </returns>
    class function ToArray(const values : TList<string>) : TArray<string>;
  end;

  //  function GetElapsedTime(const ALastTick : Cardinal) : Cardinal;

type
{$REGION 'Documentation'}
  ///	<summary>
  ///	  Extends <see cref="System.TObject">TObject</see> for easier RTTI use.
  ///	</summary>
{$ENDREGION}
  TObjectHelper = class helper for TObject
  public
{$REGION 'Documentation'}
    ///	<summary>
    ///	  Returns a list of all fields of the object.
    ///	</summary>
    ///	<returns>
    ///	  The object's RTTI fields; nil when Self is nil or has no RTTI type.
    ///	</returns>
{$ENDREGION}
    function GetFields : TArray<TRttiField>;

{$REGION 'Documentation'}
    ///	<summary>
    ///	  Returns the field with the given name; <b>nil</b> if nothing is found.
    ///	</summary>
    ///	<param name="AName">
    ///	  Name of the field to find
    ///	</param>
    ///	<returns>
    ///	  The field, or nil when the object has no field of that name.
    ///	</returns>
{$ENDREGION}
    function GetField(const AName : string) : TRttiField;

{$REGION 'Documentation'}
    ///	<summary>
    ///	  Returns the member with the given name; <b>nil</b> if nothing is found.
    ///	</summary>
    ///	<param name="AName">
    ///	  Name of the member to find
    ///	</param>
    ///	<returns>
    ///	  The property, field or method of that name (searched in that order), or nil when there is none.
    ///	</returns>
{$ENDREGION}
    function GetMember(const AName : string) : TRttiMember;

{$REGION 'Documentation'}
    ///	<summary>
    ///	  Returns a list of all methods of the object.
    ///	</summary>
    ///	<returns>
    ///	  The object's RTTI methods, inherited ones included; nil when Self is nil or has no RTTI type.
    ///	</returns>
{$ENDREGION}
    function GetMethods : TArray<TRttiMethod>;

{$REGION 'Documentation'}
    ///	<summary>
    ///	  Returns the method at the given code address; <b>nil</b> if nothing
    ///	  is found.
    ///	</summary>
    ///	<param name="ACodeAddress">
    ///	  Code address of the method to find.
    ///	</param>
    ///	<returns>
    ///	  The method whose code address matches, or nil when there is none.
    ///	</returns>
{$ENDREGION}
    function GetMethod(ACodeAddress : Pointer) : TRttiMethod; overload;

{$REGION 'Documentation'}
    ///	<summary>
    ///	  Returns the method with the given name; <b>nil</b> if nothing is
    ///	  found.
    ///	</summary>
    ///	<param name="AName">
    ///	  Name of the method to find
    ///	</param>
    ///	<returns>
    ///	  The method, or nil when there is none; an exception from the RTTI lookup (e.g. an ambiguous overloaded
    ///	  name) is swallowed and also gives nil.
    ///	</returns>
{$ENDREGION}
    function GetMethod(const AName : string) : TRttiMethod; overload;

{$REGION 'Documentation'}
    ///	<summary>
    ///	  Returns a list of all properties of the object.
    ///	</summary>
    ///	<returns>
    ///	  The object's RTTI properties; nil when Self is nil or has no RTTI type.
    ///	</returns>
{$ENDREGION}
    function GetProperties : TArray<TRttiProperty>;

{$REGION 'Documentation'}
    ///	<summary>
    ///	  Returns the property with the given name; <b>nil</b> if nothing is
    ///	  found.
    ///	</summary>
    ///	<param name="AName">
    ///	  Name of the property to find
    ///	</param>
    ///	<returns>
    ///	  The property, or nil when there is none. Properties registered through
    ///	  <see cref="TRttiPropertyExtension" /> are found too.
    ///	</returns>
{$ENDREGION}
    function GetProperty(const AName : string) : TRttiProperty;

{$REGION 'Documentation'}
    ///	<summary>
    ///	  Returns the type of the object; nil if nothing is found.
    ///	</summary>
    ///	<returns>
    ///	  The RTTI type of the object's class.
    ///	</returns>
    ///	<remarks>
    ///	  Returns nil when Self is nil.
    ///	</remarks>
{$ENDREGION}
    function GetType : TRttiType;

{$REGION 'Documentation'}
    ///	<summary>
    ///	  Returns if the object contains a field with the given name.
    ///	</summary>
    ///	<param name="AName">
    ///	  Name of the field to find
    ///	</param>
    ///	<returns>
    ///	  True when the field exists.
    ///	</returns>
{$ENDREGION}
    function HasField(const AName : string) : Boolean;

{$REGION 'Documentation'}
    ///	<summary>
    ///	  Returns if the object contains a method with the given name.
    ///	</summary>
    ///	<param name="AName">
    ///	  Name of the method to find
    ///	</param>
    ///	<returns>
    ///	  True when the method exists.
    ///	</returns>
{$ENDREGION}
    function HasMethod(const AName : string) : Boolean;

{$REGION 'Documentation'}
    ///	<summary>
    ///	  Returns if the object contains a property with the given name.
    ///	</summary>
    ///	<param name="AName">
    ///	  Name of the property to find
    ///	</param>
    ///	<returns>
    ///	  True when the property exists.
    ///	</returns>
{$ENDREGION}
    function HasProperty(const AName : string) : Boolean;

{$REGION 'Documentation'}
    ///	<summary>
    ///	  Retrieves the field with the given name and returns if this was
    ///	  successful.
    ///	</summary>
    ///	<param name="AName">
    ///	  Name of the field to find
    ///	</param>
    ///	<param name="AField">
    ///	  Field that was found when Result is <b>True</b>
    ///	</param>
    ///	<returns>
    ///	  True when the field was found.
    ///	</returns>
{$ENDREGION}
    function TryGetField(const AName : string; out AField : TRttiField) : Boolean;

{$REGION 'Documentation'}
    ///	<summary>
    ///	  Retrieves the property, field or method with the given name and returns if this was successful.
    ///	</summary>
    ///	<param name="AName">
    ///	  Name of the member to find
    ///	</param>
    ///	<param name="AMember">
    ///	  Member that was found when Result is <b>True</b>
    ///	</param>
    ///	<returns>
    ///	  True when a member was found.
    ///	</returns>
{$ENDREGION}
    function TryGetMember(const AName : string; out AMember : TRttiMember) : Boolean;

{$REGION 'Documentation'}
    ///	<summary>
    ///	  Retrieves the method with the given code address and returns if this
    ///	  was successful.
    ///	</summary>
    ///	<param name="ACodeAddress">
    ///	  Code address of the method to find
    ///	</param>
    ///	<param name="AMethod">
    ///	  Method that was found when Result is <b>True</b>
    ///	</param>
    ///	<returns>
    ///	  True when a method was found.
    ///	</returns>
{$ENDREGION}
    function TryGetMethod(ACodeAddress : Pointer; out AMethod : TRttiMethod) : Boolean; overload;

{$REGION 'Documentation'}
    ///	<summary>
    ///	  Retrieves the method with the given name and returns if this was
    ///	  successful.
    ///	</summary>
    ///	<param name="AName">
    ///	  Name of the method to find
    ///	</param>
    ///	<param name="AMethod">
    ///	  Method that was found when Result is <b>True</b>
    ///	</param>
    ///	<returns>
    ///	  True when a method was found.
    ///	</returns>
{$ENDREGION}
    function TryGetMethod(const AName : string; out AMethod : TRttiMethod) : Boolean; overload;

{$REGION 'Documentation'}
    ///	<summary>
    ///	  Retrieves the property with the given name and returns if this was
    ///	  successful.
    ///	</summary>
    ///	<param name="AName">
    ///	  Name of the property to find
    ///	</param>
    ///	<param name="AProperty">
    ///	  Property that was found when Result is <b>True</b>
    ///	</param>
    ///	<returns>
    ///	  True when a property was found.
    ///	</returns>
{$ENDREGION}
    function TryGetProperty(const AName : string; out AProperty : TRttiProperty) : Boolean;

{$REGION 'Documentation'}
    ///	<summary>
    ///	  Retrieves the type of the object and returns if this was successful.
    ///	</summary>
    ///	<param name="AType">
    ///	  Type of the object when Result is <b>True</b>; nil when Self is nil.
    ///	</param>
    ///	<returns>
    ///	  True when Self is assigned and its class has an RTTI type.
    ///	</returns>
{$ENDREGION}
    function TryGetType(out AType : TRttiType) : Boolean;

{$IF CompilerVersion < 23}
    /// <summary>
    ///   Back-fills <c>TObject.QualifiedClassName</c> for compilers before XE2.
    /// </summary>
    /// <returns>
    ///   <c>UnitName.ClassName</c>, or just the class name when the unit name is empty.
    /// </returns>
    class function QualifiedClassName : string;
{$IFEND}
  end;

{$REGION 'Documentation'}
  ///	<summary>
  ///	  Extends <see cref="System.Rtti.TRttiField">TRttiField</see> for easier RTTI
  ///	  use.
  ///	</summary>
{$ENDREGION}
  TRttiFieldHelper = class helper for TRttiField
  public
{$REGION 'Documentation'}
    ///	<summary>
    ///	  Retrieves the value of the field and returns if this was successful.
    ///	</summary>
    ///	<param name="Instance">
    ///	  Pointer to the instance of the field
    ///	</param>
    ///	<param name="Value">
    ///	  Value of the field when Result is <b>True</b>
    ///	</param>
    ///	<returns>
    ///	  True when the value was read; False (with Value empty) when reading raised, the exception being swallowed.
    ///	</returns>
{$ENDREGION}
    function TryGetValue(Instance : Pointer; out Value : TValue) : Boolean;
  end;

{$IF CompilerVersion < 23}

{$REGION 'Documentation'}
  ///	<summary>
  ///	  Extends <see cref="Rtti.TRttiInstanceTypeHelper">TRttiInstanceTypeHelper</see>
  ///	  for easier RTTI use.
  ///	</summary>
{$ENDREGION}
  TRttiInstanceTypeHelper = class helper for TRttiInstanceType
  public
    /// <summary>
    ///   Back-fills the interfaces declared directly by this class (read from its VMT interface table), for
    ///   compilers before XE2.
    /// </summary>
    /// <returns>
    ///   The interfaces this class itself declares; ancestors' interfaces are not included.
    /// </returns>
    function GetDeclaredImplementedInterfaces : TArray<TRttiInterfaceType>;
    /// <summary>
    ///   Back-fills the interfaces implemented by this class and all its ancestors, for compilers before XE2.
    /// </summary>
    /// <returns>
    ///   The declared interfaces of this class followed by those of each ancestor in turn.
    /// </returns>
    function GetImplementedInterfaces : TArray<TRttiInterfaceType>;
  end;
{$IFEND}

{$IFDEF DELPHI_XE2_UP}

{$REGION 'Documentation'}
  ///	<summary>
  ///	  Extends <see cref="System.Rtti.TRttiInvokableType">TRttiInvokableType</see>
  ///	  for easier RTTI use.
  ///	</summary>
{$ENDREGION}
  TRttiInvokableTypeHelper = class helper for TRttiInvokableType
  private
    /// <summary>
    ///   Reader for <see cref="ParameterCount" />.
    /// </summary>
    /// <returns>
    ///   The length of <c>GetParameters</c>.
    /// </returns>
    function GetParameterCount : Integer;
  public
    /// <summary>
    ///   Number of parameters the procedural or method type declares.
    /// </summary>
    property ParameterCount : Integer read GetParameterCount;
  end;
{$ENDIF}

{$REGION 'Documentation'}
  ///	<summary>
  ///	  Extends <see cref="System.Rtti.TRttiMember">TRttiMember</see> for easier RTTI
  ///	  use.
  ///	</summary>
{$ENDREGION}
  TRttiMemberHelper = class helper for TRttiMember
  private
    /// <summary>
    ///   Reader for <see cref="IsReadable" />.
    /// </summary>
    /// <returns>
    ///   True for fields, methods and any other member; a property's own <c>IsReadable</c> for properties.
    /// </returns>
    function GetMemberIsReadable : Boolean;
    /// <summary>
    ///   Reader for <see cref="IsWritable" />.
    /// </summary>
    /// <returns>
    ///   True for fields; a property's own <c>IsWritable</c> for properties; False for anything else.
    /// </returns>
    function GetMemberIsWritable : Boolean;
    /// <summary>
    ///   Reader for <see cref="RttiType" />.
    /// </summary>
    /// <returns>
    ///   The field type, property type or method return type; nil for other members or a procedure.
    /// </returns>
    function GetMemberRttiType : TRttiType;
  public
    /// <summary>
    ///   Whether the member's value can be read, whatever kind of member it is.
    /// </summary>
    property IsReadable : Boolean read GetMemberIsReadable;
    /// <summary>
    ///   Whether the member's value can be written (fields and writable properties only).
    /// </summary>
    property IsWritable : Boolean read GetMemberIsWritable;
    /// <summary>
    ///   The member's value type: field type, property type or method return type (nil when there is none).
    /// </summary>
    property RttiType : TRttiType read GetMemberRttiType;
  end;

{$REGION 'Documentation'}
  ///	<summary>
  ///	  Extends <see cref="System.Rtti.TRttiMethod">TRttiMethod</see> for easier RTTI
  ///	  use.
  ///	</summary>
{$ENDREGION}
  TRttiMethodHelper = class helper for TRttiMethod
  private
    /// <summary>
    ///   Reader for <see cref="ParameterCount" />.
    /// </summary>
    /// <returns>
    ///   The length of <c>GetParameters</c>.
    /// </returns>
    function GetParameterCount : Integer;
  public
    /// <summary>
    ///   Formats a call of this method for display, as <c>Type.Method(argument)</c> with the unit prefix
    ///   <c>System.</c> stripped from the type name.
    /// </summary>
    /// <param name="Args">
    ///   The call's argument values, with the instance (Self) first.
    /// </param>
    /// <param name="SkipSelf">
    ///   True to skip <c>Args[0]</c> as Self; False to treat it as the first argument.
    /// </param>
    /// <returns>
    ///   The formatted call.
    /// </returns>
    /// <remarks>
    ///   Only ONE argument is ever shown: <c>Args[1]</c> when SkipSelf is True, otherwise <c>Args[0]</c>; none
    ///   when that argument is absent.
    /// </remarks>
    function Format(const Args : array of TValue; SkipSelf : Boolean = True) : string;
    /// <summary>
    ///   Number of parameters the method declares (Self not counted).
    /// </summary>
    property ParameterCount : Integer read GetParameterCount;
  end;

{$REGION 'Documentation'}
  ///	<summary>
  ///	  Extends <see cref="System.Rtti.TRttiObject">TRttiObject</see> for easier RTTI
  ///	  use.
  ///	</summary>
{$ENDREGION}
  TRttiObjectHelper = class helper for TRttiObject
  public
    /// <summary>
    ///   Returns the first attribute on this RTTI object that is a T or a descendant of T.
    /// </summary>
    /// <returns>
    ///   The first matching attribute, or nil when there is none.
    /// </returns>
    function GetAttributeOfType<T : TCustomAttribute> : T;
    /// <summary>
    ///   Returns every attribute on this RTTI object that is a T or a descendant of T.
    /// </summary>
    /// <returns>
    ///   The matching attributes in declaration order; an empty array when there are none.
    /// </returns>
    function GetAttributesOfType<T : TCustomAttribute> : TArray<T>;

    /// <summary>
    ///   Reports whether this RTTI object carries an attribute that is a T or a descendant of T.
    /// </summary>
    /// <returns>
    ///   True when at least one such attribute exists.
    /// </returns>
    function HasAttributeOfType<T : TCustomAttribute> : Boolean;

    /// <summary>
    ///   Retrieves the first attribute that is a T or a descendant of T and returns if this was successful.
    /// </summary>
    /// <param name="AAttribute">
    ///   The attribute found, or nil.
    /// </param>
    /// <returns>
    ///   True when an attribute was found.
    /// </returns>
    function TryGetAttributeOfType<T : TCustomAttribute>(out AAttribute : T) : Boolean;
  end;

{$REGION 'Documentation'}
  ///	<summary>
  ///	  Extends <see cref="System.Rtti.TRttiParameter">TRttiParameter</see> for easier
  ///	  RTTI use.
  ///	</summary>
{$ENDREGION}
  TRttiParameterHelper = class helper for TRttiParameter
  public
    /// <summary>
    ///   Compares two parameter lists by count and by each parameter's type (names and flags are ignored).
    /// </summary>
    /// <param name="Left">
    ///   The first parameter list.
    /// </param>
    /// <param name="Right">
    ///   The second parameter list.
    /// </param>
    /// <returns>
    ///   True when both lists have the same length and pairwise identical parameter types.
    /// </returns>
    class function Equals(const Left, Right : TArray<TRttiParameter>) : Boolean; //overload;
  end;

{$REGION 'Documentation'}
  ///	<summary>
  ///	  Extends <see cref="System.Rtti.TRttiProperty">TRttiProperty</see> for easier
  ///	  RTTI use.
  ///	</summary>
{$ENDREGION}
  TRttiPropertyHelper = class helper for TRttiProperty
  public
{$REGION 'Documentation'}
    ///	<summary>
    ///	  Retrieves the value of the property and returns if this was
    ///	  successful.
    ///	</summary>
    ///	<param name="Instance">
    ///	  Pointer to the instance of the field
    ///	</param>
    ///	<param name="Value">
    ///	  Value of the field when Result is <b>True</b>
    ///	</param>
    ///	<returns>
    ///	  True when the property is readable and was read; False when it is write-only or reading raised (the
    ///	  exception is swallowed and Value is empty).
    ///	</returns>
{$ENDREGION}
    function TryGetValue(Instance : Pointer; out Value : TValue) : Boolean;

{$REGION 'Documentation'}
    ///	<summary>
    ///	  Sets the value of the property and returns if this was successful.
    ///	</summary>
    ///	<param name="Instance">
    ///	  Pointer to the instance of the field
    ///	</param>
    ///	<param name="Value">
    ///	  Value the field should be set to
    ///	</param>
    ///	<returns>
    ///	  True when Value could be converted (via <c>TValue.TryConvert</c>) to the property type and was assigned;
    ///	  False when the conversion failed, in which case nothing is assigned.
    ///	</returns>
    ///	<remarks>
    ///	  Only the conversion is guarded: an exception raised by the property setter itself propagates.
    ///	</remarks>
{$ENDREGION}
    function TrySetValue(Instance : Pointer; Value : TValue) : Boolean;
  end;

{$REGION 'Documentation'}
  ///	<summary>
  ///	  Extends <see cref="System.Rtti.TRttiType">TRttiType</see> for easier RTTI use.
  ///	</summary>
{$ENDREGION}
  TRttiTypeHelper = class helper for TRttiType
  private
    /// <summary>
    ///   Reader for <see cref="AsInterface" />.
    /// </summary>
    /// <returns>
    ///   Self cast to TRttiInterfaceType.
    /// </returns>
    /// <exception cref="EInvalidCast">
    ///   Self is not an interface type.
    /// </exception>
    function GetAsInterface : TRttiInterfaceType;
    /// <summary>
    ///   Reader for <see cref="IsInterface" />.
    /// </summary>
    /// <returns>
    ///   True when Self is a TRttiInterfaceType.
    /// </returns>
    function GetIsInterface : Boolean;
    /// <summary>
    ///   Reader for <see cref="MethodCount" />.
    /// </summary>
    /// <returns>
    ///   The length of <c>GetMethods</c>, inherited methods included.
    /// </returns>
    function GetMethodCount : Integer;
    /// <summary>
    ///   Reports whether this type is, or descends from, the given type by walking the BaseType chain.
    /// </summary>
    /// <param name="OtherType">
    ///   Type information of the candidate ancestor.
    /// </param>
    /// <returns>
    ///   True when this type or one of its ancestors has the handle <c>OtherType</c>.
    /// </returns>
    function InheritsFrom(OtherType : PTypeInfo) : Boolean;
  public
    /// <summary>
    ///   Returns every attribute that is a T or a descendant of T on this type AND on each of its ancestors.
    /// </summary>
    /// <returns>
    ///   This type's matching attributes followed by its ancestors', nearest ancestor first.
    /// </returns>
    function GetAttributesOfType<T : TCustomAttribute> : TArray<T>;
    /// <summary>
    ///   Resolves the type arguments of a constructed generic type, parsed from the text between the angle
    ///   brackets of its type name.
    /// </summary>
    /// <returns>
    ///   One entry per type argument, nil for an argument whose name cannot be found; an empty array for a
    ///   non-generic type.
    /// </returns>
    function GetGenericArguments : TArray<TRttiType>;
    /// <summary>
    ///   Returns the open generic definition of a constructed generic type, with its arguments renamed to
    ///   <c>T</c> (one argument) or <c>T1</c>, <c>T2</c>... (several), e.g. <c>System.Generics.Collections.TList&lt;T&gt;</c>.
    /// </summary>
    /// <param name="AIncludeUnitName">
    ///   True to use the qualified name (public types only); False for the bare type name.
    /// </param>
    /// <returns>
    ///   The generic definition name. Upstream calls the renaming "naive": nested generic arguments are not
    ///   handled.
    /// </returns>
    function GetGenericTypeDefinition(const AIncludeUnitName : Boolean = True) : string;

    /// <summary>
    ///   Returns the member with the given name, looking for a property first, then a field, then a method.
    /// </summary>
    /// <param name="AName">
    ///   Name of the member to find.
    /// </param>
    /// <returns>
    ///   The member found, or nil when there is none.
    /// </returns>
    function GetMember(const AName : string) : TRttiMember;

{$REGION 'Documentation'}
    ///	<summary>
    ///	  Returns the method at the given code address; <b>nil</b> if nothing
    ///	  is found.
    ///	</summary>
    ///	<param name="ACodeAddress">
    ///	  Code address of the method to find
    ///	</param>
    ///	<returns>
    ///	  The first method (inherited ones included) whose CodeAddress matches, or nil.
    ///	</returns>
{$ENDREGION}
    function GetMethod(ACodeAddress : Pointer) : TRttiMethod; overload;
    /// <summary>
    ///   Returns the property with the given name, falling back to properties registered through
    ///   <see cref="TRttiPropertyExtension" /> on this type or an ancestor.
    /// </summary>
    /// <param name="AName">
    ///   Name of the property to find.
    /// </param>
    /// <returns>
    ///   The property, or nil when there is none.
    /// </returns>
    function GetProperty(const AName : string) : TRttiProperty;

    /// <summary>
    ///   Returns the first constructor (inherited ones included) that takes no parameters.
    /// </summary>
    /// <returns>
    ///   The parameterless constructor, or nil when there is none.
    /// </returns>
    function GetStandardConstructor : TRttiMethod;

    /// <summary>
    ///   Reports whether a value of this type can be used where the given class is expected.
    /// </summary>
    /// <param name="OtherClass">
    ///   The target class.
    /// </param>
    /// <returns>
    ///   False when OtherClass is nil; otherwise the result of the PTypeInfo overload for its class info.
    /// </returns>
    function IsCovariantTo(OtherClass : TClass) : Boolean; overload;
    /// <summary>
    ///   Reports whether a value of this type can be used where the given type is expected: for generic types,
    ///   the same generic definition with each type argument inheriting from the target's (an ancestor's
    ///   generic base is also tried); otherwise plain inheritance.
    /// </summary>
    /// <param name="OtherType">
    ///   Type information of the target type.
    /// </param>
    /// <returns>
    ///   True when this type is covariant to <c>OtherType</c>.
    /// </returns>
    function IsCovariantTo(OtherType : PTypeInfo) : Boolean; overload;
    /// <summary>
    ///   Reports whether this type, or any ancestor, is a constructed generic type (its name carries type
    ///   arguments).
    /// </summary>
    /// <returns>
    ///   True when this type or an ancestor has generic arguments.
    /// </returns>
    function IsGenericTypeDefinition : Boolean;
    /// <summary>
    ///   Reports whether this type's name is <c>BaseTypeName&lt;...&gt;</c>, i.e. a construction of the named
    ///   generic type.
    /// </summary>
    /// <param name="BaseTypeName">
    ///   The unqualified generic type name without its argument list, e.g. <c>TList</c>. Compared case-sensitively.
    /// </param>
    /// <returns>
    ///   True when the name starts with <c>BaseTypeName&lt;</c> and ends with <c>&gt;</c>.
    /// </returns>
    function IsGenericTypeOf(const BaseTypeName : string) : Boolean;
    /// <summary>
    ///   Reports whether this type is the given type or descends from it.
    /// </summary>
    /// <param name="OtherType">
    ///   The candidate ancestor; must not be nil.
    /// </param>
    /// <returns>
    ///   True when this type or one of its ancestors has the same handle as <c>OtherType</c>.
    /// </returns>
    function IsInheritedFrom(OtherType : TRttiType) : Boolean; overload;
    /// <summary>
    ///   Reports whether this type is, or descends from, a type with the given name.
    /// </summary>
    /// <param name="OtherTypeName">
    ///   The ancestor's bare or qualified name, compared case-insensitively.
    /// </param>
    /// <returns>
    ///   True when this type or an ancestor matches the name.
    /// </returns>
    function IsInheritedFrom(const OtherTypeName : string) : Boolean; overload;
    /// <summary>
    ///   Finds the construction of this (public) generic type with the given type arguments, e.g. turns
    ///   <c>TList&lt;T&gt;</c> plus <c>Integer</c> into <c>TList&lt;Integer&gt;</c>.
    /// </summary>
    /// <param name="TypeArguments">
    ///   Type information for each type argument, in order; there must be at least as many as the type has.
    /// </param>
    /// <returns>
    ///   The constructed type, or nil when this type is not public or that construction has no RTTI in the
    ///   application.
    /// </returns>
    function MakeGenericType(const TypeArguments : array of PTypeInfo) : TRttiType;

{$REGION 'Documentation'}
    ///	<summary>
    ///	  Retrieves the field with the given name and returns if this was
    ///	  successful.
    ///	</summary>
    ///	<param name="AName">
    ///	  Name of the field to find
    ///	</param>
    ///	<param name="AField">
    ///	  Field that was found when Result is <b>True</b>
    ///	</param>
    ///	<returns>
    ///	  True when the field was found.
    ///	</returns>
{$ENDREGION}
    function TryGetField(const AName : string; out AField : TRttiField) : Boolean;

{$REGION 'Documentation'}
    ///	<summary>
    ///	  Retrieves the member with the given name and returns if this was
    ///	  successful.
    ///	</summary>
    ///	<param name="AName">
    ///	  Name of the member to find
    ///	</param>
    ///	<param name="AMember">
    ///	  Member that was found when Result is <b>True</b>
    ///	</param>
    ///	<returns>
    ///	  True when a property, field or method of that name was found.
    ///	</returns>
{$ENDREGION}
    function TryGetMember(const AName : string; out AMember : TRttiMember) : Boolean;

{$REGION 'Documentation'}
    ///	<summary>
    ///	  Retrieves the method with the given code address and returns if this
    ///	  was successful.
    ///	</summary>
    ///	<param name="ACodeAddress">
    ///	  Code address of the method to find
    ///	</param>
    ///	<param name="AMethod">
    ///	  Method that was found when Result is <b>True</b>
    ///	</param>
    ///	<returns>
    ///	  True when a method was found.
    ///	</returns>
{$ENDREGION}
    function TryGetMethod(ACodeAddress : Pointer; out AMethod : TRttiMethod) : Boolean; overload;

{$REGION 'Documentation'}
    ///	<summary>
    ///	  Retrieves the method with the given name and returns if this
    ///	  was successful.
    ///	</summary>
    ///	<param name="AName">
    ///	  Name of the method to find
    ///	</param>
    ///	<param name="AMethod">
    ///	  Method that was found when Result is <b>True</b>
    ///	</param>
    ///	<returns>
    ///	  True when a method was found.
    ///	</returns>
{$ENDREGION}
    function TryGetMethod(const AName : string; out AMethod : TRttiMethod) : Boolean; overload;

    /// <summary>
    ///   Finds the first parameterless constructor DECLARED by this type or, failing that, by the nearest
    ///   ancestor below TObject that declares one.
    /// </summary>
    /// <param name="AMethod">
    ///   The constructor found; left unassigned when the result is False.
    /// </param>
    /// <returns>
    ///   True when a parameterless constructor was found before reaching TObject.
    /// </returns>
    function TryGetConstructor(out AMethod : TRttiMethod) : boolean;

    /// <summary>
    ///   Finds the first destructor declared by this type itself; ancestors are not searched.
    /// </summary>
    /// <param name="AMethod">
    ///   The destructor found; left unassigned when the result is False.
    /// </param>
    /// <returns>
    ///   True when this type declares a destructor.
    /// </returns>
    function TryGetDestructor(out AMethod : TRttiMethod) : boolean;

{$REGION 'Documentation'}
    ///	<summary>
    ///	  Retrieves the property with the given name and returns if this was
    ///	  successful.
    ///	</summary>
    ///	<param name="AName">
    ///	  Name of the property to find
    ///	</param>
    ///	<param name="AProperty">
    ///	  Property that was found when Result is <b>True</b>
    ///	</param>
    ///	<returns>
    ///	  True when a property (extension properties included) was found.
    ///	</returns>
{$ENDREGION}
    function TryGetProperty(const AName : string; out AProperty : TRttiProperty) : Boolean;

    /// <summary>
    ///   Retrieves the first parameterless constructor (inherited ones included) and returns if this was
    ///   successful.
    /// </summary>
    /// <param name="AMethod">
    ///   The constructor found, or nil.
    /// </param>
    /// <returns>
    ///   True when a parameterless constructor exists.
    /// </returns>
    function TryGetStandardConstructor(out AMethod : TRttiMethod) : Boolean;

    /// <summary>
    ///   This type as an interface type; raises EInvalidCast when it is not one (check IsInterface first).
    /// </summary>
    property AsInterface : TRttiInterfaceType read GetAsInterface;
    /// <summary>
    ///   Whether this type is an interface type.
    /// </summary>
    property IsInterface : Boolean read GetIsInterface;
    /// <summary>
    ///   Number of methods of the type, inherited ones included.
    /// </summary>
    property MethodCount : Integer read GetMethodCount;
  end;

  /// <summary>
  ///   Re-exports <c>System.Rtti.TValue</c> so units using DUnitX.Utils see the TValueHelper-extended type
  ///   without also naming System.Rtti.
  /// </summary>
  TValue = {$IFDEF USE_NS}System.{$ENDIF}Rtti.TValue;

{$REGION 'Documentation'}
  ///	<summary>
  ///	  Extends <see cref="System.Rtti.TValue">TValue</see> for easier RTTI use.
  ///	</summary>
{$ENDREGION}
  TValueHelper = record helper for TValue
  private
    /// <summary>
    ///   Reader for <see cref="RttiType" />.
    /// </summary>
    /// <returns>
    ///   The RTTI type for the value's TypeInfo; nil for an empty value.
    /// </returns>
    function GetRttiType : TRttiType;
    /// <summary>
    ///   Builds a TValue of the specific floating-point type described by ATypeInfo (Single, Double, Extended,
    ///   Comp or Currency).
    /// </summary>
    /// <param name="ATypeInfo">
    ///   Type information of a tkFloat type; its FloatType selects the result type.
    /// </param>
    /// <param name="AValue">
    ///   The value to store, narrowed to the target type.
    /// </param>
    /// <returns>
    ///   The value typed as the requested float type.
    /// </returns>
    class function FromFloat(ATypeInfo : PTypeInfo; AValue : Extended) : TValue; static;
  public
    /// <summary>
    ///   Reports whether the value is of a floating-point kind (tkFloat, which includes TDateTime and Currency).
    /// </summary>
    /// <returns>
    ///   True when Kind is tkFloat.
    /// </returns>
    function IsFloat : Boolean;
    /// <summary>
    ///   Reports whether the value is of a kind that holds a number.
    /// </summary>
    /// <returns>
    ///   True for tkInteger, tkInt64, tkFloat, tkChar, tkWChar and tkEnumeration (so Boolean and characters count
    ///   as numeric).
    /// </returns>
    function IsNumeric : Boolean;
    /// <summary>
    ///   Reports whether the value is a typed or untyped pointer.
    /// </summary>
    /// <returns>
    ///   True when Kind is tkPointer.
    /// </returns>
    function IsPointer : Boolean;
    /// <summary>
    ///   Reports whether the value is a string or a single character of any width.
    /// </summary>
    /// <returns>
    ///   True for tkChar, tkWChar, tkString, tkLString, tkWString and tkUString.
    /// </returns>
    function IsString : Boolean;

    /// <summary>
    ///   Reports whether the value holds an object or interface reference.
    /// </summary>
    /// <returns>
    ///   True when Kind is tkClass or tkInterface.
    /// </returns>
    function IsInstance : Boolean;
    /// <summary>
    ///   Reports whether the value holds an interface reference.
    /// </summary>
    /// <returns>
    ///   True when the value has TypeInfo and its kind is tkInterface.
    /// </returns>
    function IsInterface : Boolean;

    /// <summary>
    ///   Converts the value to the given type, covering almost all standard types (ordinals, floats, strings,
    ///   enumerations, sets, classes, interfaces, dynamic arrays and Spring-style nullable records).
    /// </summary>
    /// <param name="ATypeInfo">
    ///   Type information of the target type; TypeInfo(TValue) returns the value unchanged.
    /// </param>
    /// <param name="AResult">
    ///   The converted value when the result is True.
    /// </param>
    /// <returns>
    ///   True when the conversion succeeded; False when ATypeInfo is nil or no conversion applies.
    /// </returns>
    /// <remarks>
    ///   Between numeric kinds the converters' decision is final: a value that does not fit the target ordinal
    ///   type is refused rather than passed to TValue.TryCast, which would truncate it (Integer 300 to Byte 44).
    /// </remarks>
    function TryConvert(ATypeInfo : PTypeInfo; out AResult : TValue) : Boolean; overload;
    /// <summary>
    ///   Converts the value to type T; see the PTypeInfo overload for the rules.
    /// </summary>
    /// <param name="AResult">
    ///   The converted value when the result is True.
    /// </param>
    /// <returns>
    ///   True when the conversion succeeded.
    /// </returns>
    function TryConvert<T>(out AResult : TValue) : Boolean; overload;

    /// <summary>
    ///   Returns the value as a Byte.
    /// </summary>
    /// <returns>
    ///   The value cast through <c>AsType&lt;Byte&gt;</c>.
    /// </returns>
    /// <exception cref="EInvalidCast">
    ///   The value cannot be cast to Byte.
    /// </exception>
    function AsByte : Byte;
    /// <summary>
    ///   Returns the value as a Cardinal.
    /// </summary>
    /// <returns>
    ///   The value cast through <c>AsType&lt;Cardinal&gt;</c>.
    /// </returns>
    /// <exception cref="EInvalidCast">
    ///   The value cannot be cast to Cardinal.
    /// </exception>
    function AsCardinal : Cardinal;
    /// <summary>
    ///   Returns the value as a Currency.
    /// </summary>
    /// <returns>
    ///   The value cast through <c>AsType&lt;Currency&gt;</c>.
    /// </returns>
    /// <exception cref="EInvalidCast">
    ///   The value cannot be cast to Currency.
    /// </exception>
    function AsCurrency : Currency;
    /// <summary>
    ///   Returns the value as a TDate.
    /// </summary>
    /// <returns>
    ///   The value cast through <c>AsType&lt;TDate&gt;</c>.
    /// </returns>
    /// <exception cref="EInvalidCast">
    ///   The value cannot be cast to TDate.
    /// </exception>
    function AsDate : TDate;
    /// <summary>
    ///   Returns the value as a TDateTime.
    /// </summary>
    /// <returns>
    ///   The value cast through <c>AsType&lt;TDateTime&gt;</c>.
    /// </returns>
    /// <exception cref="EInvalidCast">
    ///   The value cannot be cast to TDateTime.
    /// </exception>
    function AsDateTime : TDateTime;
    /// <summary>
    ///   Returns the value as a Double.
    /// </summary>
    /// <returns>
    ///   The value cast through <c>AsType&lt;Double&gt;</c>.
    /// </returns>
    /// <exception cref="EInvalidCast">
    ///   The value cannot be cast to Double.
    /// </exception>
    function AsDouble : Double;
    /// <summary>
    ///   Returns the value as an Extended.
    /// </summary>
    /// <returns>
    ///   The value cast through <c>AsType&lt;Extended&gt;</c>.
    /// </returns>
    /// <exception cref="EInvalidCast">
    ///   The value cannot be cast to Extended.
    /// </exception>
    function AsFloat : Extended;
    /// <summary>
    ///   Returns a pointer for the value: the object itself for a class or interface value, otherwise a pointer
    ///   to the value's raw data inside this TValue.
    /// </summary>
    /// <returns>
    ///   The object reference, or the address of the raw data (valid only while this TValue is alive and
    ///   unchanged).
    /// </returns>
    function AsPointer : Pointer;
    /// <summary>
    ///   Returns the value as a ShortInt.
    /// </summary>
    /// <returns>
    ///   The value cast through <c>AsType&lt;ShortInt&gt;</c>.
    /// </returns>
    /// <exception cref="EInvalidCast">
    ///   The value cannot be cast to ShortInt.
    /// </exception>
    function AsShortInt : ShortInt;
    /// <summary>
    ///   Returns the value as a Single.
    /// </summary>
    /// <returns>
    ///   The value cast through <c>AsType&lt;Single&gt;</c>.
    /// </returns>
    /// <exception cref="EInvalidCast">
    ///   The value cannot be cast to Single.
    /// </exception>
    function AsSingle : Single;
    /// <summary>
    ///   Returns the value as a SmallInt.
    /// </summary>
    /// <returns>
    ///   The value cast through <c>AsType&lt;SmallInt&gt;</c>.
    /// </returns>
    /// <exception cref="EInvalidCast">
    ///   The value cannot be cast to SmallInt.
    /// </exception>
    function AsSmallInt : SmallInt;
    /// <summary>
    ///   Returns the value as a TTime.
    /// </summary>
    /// <returns>
    ///   The value cast through <c>AsType&lt;TTime&gt;</c>.
    /// </returns>
    /// <exception cref="EInvalidCast">
    ///   The value cannot be cast to TTime.
    /// </exception>
    function AsTime : TTime;
    /// <summary>
    ///   Returns the value as a UInt64.
    /// </summary>
    /// <returns>
    ///   The value cast through <c>AsType&lt;UInt64&gt;</c>.
    /// </returns>
    /// <exception cref="EInvalidCast">
    ///   The value cannot be cast to UInt64.
    /// </exception>
    function AsUInt64 : UInt64;
    /// <summary>
    ///   Returns the value as a Word.
    /// </summary>
    /// <returns>
    ///   The value cast through <c>AsType&lt;Word&gt;</c>.
    /// </returns>
    /// <exception cref="EInvalidCast">
    ///   The value cannot be cast to Word.
    /// </exception>
    function AsWord : Word;

    /// <summary>
    ///   Returns the object behind an object or interface value.
    /// </summary>
    /// <returns>
    ///   For an interface, the implementing object (<c>as TObject</c>); otherwise <c>AsObject</c>.
    /// </returns>
    function ToObject : TObject;
    ///	<summary>
    ///	  Converts the value to a TVarRec. A TVarRec cannot own memory, so its
    ///	  pointers refer into AStorage, which must outlive the result unchanged.
    ///	</summary>
    ///	<param name="AStorage">
    ///	  Receives a copy of the value (strings, objects and floats re-boxed as needed) that the result's pointers
    ///	  refer into.
    ///	</param>
    ///	<returns>
    ///	  The TVarRec: integers and non-Boolean enumerations as vtInteger, Boolean as vtBoolean, Int64 as vtInt64,
    ///	  Currency as vtCurrency, other floats widened to vtExtended, strings and objects (as their ToString) as
    ///	  vtUnicodeString.
    ///	</returns>
    ///	<exception cref="EInvalidCast">
    ///	  The value's kind (e.g. a record, set, array or method) has no TVarRec form.
    ///	</exception>
    function ToVarRec(var AStorage : TValue) : TVarRec;

    /// <summary>
    ///   Formats one value for display.
    /// </summary>
    /// <param name="Value">
    ///   The value to format.
    /// </param>
    /// <returns>
    ///   Dates, date-times and times through the locale's DateToStr/DateTimeToStr/TimeToStr; an object as
    ///   <c>ClassName($address)</c>; an interface as <c>ClassName($address) as IIntf</c>; anything else through
    ///   <c>TValue.ToString</c>; a nil object or interface as <c>nil</c>.
    /// </returns>
    class function ToString(const Value : TValue) : string; overload; static;
    /// <summary>
    ///   Formats several values as a comma-separated list, quoting string values with single quotes.
    /// </summary>
    /// <param name="Values">
    ///   The values to format.
    /// </param>
    /// <returns>
    ///   The values joined with <c>', '</c>; an empty string for no values.
    /// </returns>
    class function ToString(const Values : array of TValue) : string; overload; static;
    ///	<summary>
    ///	  Converts the values to TVarRecs whose pointers refer into AStorage,
    ///	  which must outlive the result unchanged.
    ///	</summary>
    ///	<param name="Values">
    ///	  The values to convert.
    ///	</param>
    ///	<param name="AStorage">
    ///	  Receives one storage TValue per value; keep it alive for as long as the result is used.
    ///	</param>
    ///	<returns>
    ///	  One TVarRec per value, as produced by <see cref="ToVarRec" />, suitable for <c>Format</c>.
    ///	</returns>
    ///	<exception cref="EInvalidCast">
    ///	  A value's kind has no TVarRec form.
    ///	</exception>
    class function ToVarRecs(const Values : array of TValue; out AStorage : TArray<TValue>) : TArray<TVarRec>; static;
    /// <summary>
    ///   Compares two value arrays element by element with <see cref="SameValue" />.
    /// </summary>
    /// <param name="Left">
    ///   The first array.
    /// </param>
    /// <param name="Right">
    ///   The second array.
    /// </param>
    /// <returns>
    ///   True when both arrays have the same length and every pair is the same value.
    /// </returns>
    class function Equals(const Left, Right : TArray<TValue>) : Boolean; overload; static;
    /// <summary>
    ///   Compares two values of type T with the default equality comparer for T.
    /// </summary>
    /// <param name="Left">
    ///   The first value.
    /// </param>
    /// <param name="Right">
    ///   The second value.
    /// </param>
    /// <returns>
    ///   True when <c>TEqualityComparer&lt;T&gt;.Default</c> considers them equal.
    /// </returns>
    class function Equals<T>(const Left, Right : T) : Boolean; overload; static;

    /// <summary>
    ///   Builds a TValue by copying a value of the given type from a buffer.
    /// </summary>
    /// <param name="ABuffer">
    ///   Address of the source data, laid out as ATypeInfo describes.
    /// </param>
    /// <param name="ATypeInfo">
    ///   Type information of the value in the buffer.
    /// </param>
    /// <returns>
    ///   A TValue holding a copy of the data.
    /// </returns>
    class function From(ABuffer : Pointer; ATypeInfo : PTypeInfo) : TValue; overload; static;
    /// <summary>
    ///   Builds a TValue of the given type from a pointer-sized raw value (via <c>TValue.Make</c>).
    /// </summary>
    /// <param name="AValue">
    ///   The raw pointer-sized data, e.g. an ordinal or a reference.
    /// </param>
    /// <param name="ATypeInfo">
    ///   Type information the value is to carry.
    /// </param>
    /// <returns>
    ///   The typed value.
    /// </returns>
    class function From(AValue : NativeInt; ATypeInfo : PTypeInfo) : TValue; overload; static;
    /// <summary>
    ///   Builds a TValue holding an object reference typed as the given class rather than the object's own.
    /// </summary>
    /// <param name="AObject">
    ///   The object reference (may be nil).
    /// </param>
    /// <param name="AClass">
    ///   The class whose type information the value carries; must not be nil.
    /// </param>
    /// <returns>
    ///   A tkClass value typed as AClass.
    /// </returns>
    class function From(AObject : TObject; AClass : TClass) : TValue; overload; static;
    /// <summary>
    ///   Builds a TValue typed as Boolean.
    /// </summary>
    /// <param name="Value">
    ///   The Boolean to store.
    /// </param>
    /// <returns>
    ///   The Boolean value.
    /// </returns>
    class function FromBoolean(const Value : Boolean) : TValue; static;
    /// <summary>
    ///   Builds a TValue typed as string.
    /// </summary>
    /// <param name="Value">
    ///   The string to store.
    /// </param>
    /// <returns>
    ///   The string value.
    /// </returns>
    class function FromString(const Value : string) : TValue; static;
    /// <summary>
    ///   Builds a TValue from a TVarRec (an <c>array of const</c> element); character, PChar, short, ANSI and wide
    ///   strings all become string values.
    /// </summary>
    /// <param name="Value">
    ///   The TVarRec to read.
    /// </param>
    /// <returns>
    ///   The equivalent TValue; empty for a VType this routine does not handle.
    /// </returns>
    class function FromVarRec(const Value : TVarRec) : TValue; static;

    /// <summary>
    ///   Reports whether the value's type is exactly Boolean.
    /// </summary>
    /// <returns>
    ///   True when TypeInfo is TypeInfo(Boolean).
    /// </returns>
    function IsBoolean : Boolean;
    /// <summary>
    ///   Reports whether the value's type is exactly Byte.
    /// </summary>
    /// <returns>
    ///   True when TypeInfo is TypeInfo(Byte).
    /// </returns>
    function IsByte : Boolean;
    /// <summary>
    ///   Reports whether the value's type is Cardinal (or, on Win32, NativeUInt).
    /// </summary>
    /// <returns>
    ///   True when TypeInfo is TypeInfo(Cardinal), or TypeInfo(NativeUInt) on 32-bit targets.
    /// </returns>
    function IsCardinal : Boolean;
    /// <summary>
    ///   Reports whether the value's type is exactly Currency.
    /// </summary>
    /// <returns>
    ///   True when TypeInfo is TypeInfo(Currency).
    /// </returns>
    function IsCurrency : Boolean;
    /// <summary>
    ///   Reports whether the value's type is exactly TDate.
    /// </summary>
    /// <returns>
    ///   True when TypeInfo is TypeInfo(TDate).
    /// </returns>
    function IsDate : Boolean;
    /// <summary>
    ///   Reports whether the value's type is exactly TDateTime.
    /// </summary>
    /// <returns>
    ///   True when TypeInfo is TypeInfo(TDateTime).
    /// </returns>
    function IsDateTime : Boolean;
    /// <summary>
    ///   Reports whether the value's type is exactly Double.
    /// </summary>
    /// <returns>
    ///   True when TypeInfo is TypeInfo(Double).
    /// </returns>
    function IsDouble : Boolean;
    /// <summary>
    ///   Reports whether the value's type is Integer (or, on Win32, NativeInt).
    /// </summary>
    /// <returns>
    ///   True when TypeInfo is TypeInfo(Integer), or TypeInfo(NativeInt) on 32-bit targets.
    /// </returns>
    function IsInteger : Boolean;
    /// <summary>
    ///   Reports whether the value's type is Int64 (or, on Win64, NativeInt).
    /// </summary>
    /// <returns>
    ///   True when TypeInfo is TypeInfo(Int64), or TypeInfo(NativeInt) on 64-bit targets.
    /// </returns>
    function IsInt64 : Boolean;
    /// <summary>
    ///   Reports whether the value's type is exactly ShortInt.
    /// </summary>
    /// <returns>
    ///   True when TypeInfo is TypeInfo(ShortInt).
    /// </returns>
    function IsShortInt : Boolean;
    /// <summary>
    ///   Reports whether the value's type is exactly Single.
    /// </summary>
    /// <returns>
    ///   True when TypeInfo is TypeInfo(Single).
    /// </returns>
    function IsSingle : Boolean;
    /// <summary>
    ///   Reports whether the value's type is exactly SmallInt.
    /// </summary>
    /// <returns>
    ///   True when TypeInfo is TypeInfo(SmallInt).
    /// </returns>
    function IsSmallInt : Boolean;
    /// <summary>
    ///   Reports whether the value's type is exactly TTime.
    /// </summary>
    /// <returns>
    ///   True when TypeInfo is TypeInfo(TTime).
    /// </returns>
    function IsTime : Boolean;
    /// <summary>
    ///   Reports whether the value's type is UInt64 (or, on Win64, NativeUInt).
    /// </summary>
    /// <returns>
    ///   True when TypeInfo is TypeInfo(UInt64), or TypeInfo(NativeUInt) on 64-bit targets.
    /// </returns>
    function IsUInt64 : Boolean;
    /// <summary>
    ///   Reports whether the value's type is exactly Variant.
    /// </summary>
    /// <returns>
    ///   True when TypeInfo is TypeInfo(Variant).
    /// </returns>
    function IsVariant : Boolean;
    /// <summary>
    ///   Reports whether the value's type is exactly Word.
    /// </summary>
    /// <returns>
    ///   True when TypeInfo is TypeInfo(Word).
    /// </returns>
    function IsWord : Boolean;

    /// <summary>
    ///   The RTTI type of the value's TypeInfo (nil for an empty value).
    /// </summary>
    property RttiType : TRttiType read GetRttiType;
  end;

{$IFDEF DELPHI_XE3_UP}
  /// <summary>Pointer to a <see cref="TPropInfoExt" />.</summary>
  PPropInfoExt = ^TPropInfoExt;
  /// <summary>
  ///   A writable mirror of the RTL's TPropInfo layout with room for the inline short-string name, used as the
  ///   synthetic property information behind a <see cref="TRttiPropertyExtension" />.
  /// </summary>
  TPropInfoExt = record
    /// <summary>Indirect type information of the property's type.</summary>
    PropType : PPTypeInfo;
    /// <summary>Getter address; unused (nil) for an extension property.</summary>
    GetProc : Pointer;
    /// <summary>Setter address; unused (nil) for an extension property.</summary>
    SetProc : Pointer;
    /// <summary>Stored specifier address; unused (nil) for an extension property.</summary>
    StoredProc : Pointer;
    /// <summary>Index specifier value, as in TPropInfo.</summary>
    Index : Integer;
    /// <summary>Default specifier value, as in TPropInfo.</summary>
    Default : Integer;
    /// <summary>Name index, as in TPropInfo.</summary>
    NameIndex : SmallInt;
    /// <summary>Length byte of the inline short-string name (at most 255).</summary>
    NameLength : Byte;
    /// <summary>The name's ANSI characters, stored inline after NameLength.</summary>
    NameData : array[0..255] of Byte;
    /// <summary>
    ///   Returns an accessor over the inline short-string name.
    /// </summary>
    /// <returns>
    ///   A TTypeInfoFieldAccessor positioned at NameLength.
    /// </returns>
    function NameFld : TTypeInfoFieldAccessor; inline;
    /// <summary>
    ///   Returns the address just past the variable-length name, as the RTL does for TPropInfo.
    /// </summary>
    /// <returns>
    ///   The address following the name.
    /// </returns>
    function Tail : PPropInfoExt; inline;
  end;
{$ENDIF}

  /// <summary>
  ///   A synthetic RTTI property, attached to a class at run time and backed by getter/setter closures, which
  ///   <c>TRttiTypeHelper.GetProperty</c> returns when the class has no real property of that name.
  /// </summary>
  /// <remarks>
  ///   Inherited upstream code that works by patching a copy of the VMT. The slot indices in
  ///   InitVirtualMethodTable were derived from an older System.Rtti and have NOT been re-verified against
  ///   Delphi 13, which changed the TRttiMember hierarchy; nothing in DUnitX constructs an instance, so the
  ///   stale map is currently unreachable. Re-verify every index before using this class.
  /// </remarks>
  TRttiPropertyExtension = class(TRttiInstanceProperty)
  private
{$IFDEF DELPHI_XE3_UP}
    /// <summary>The synthetic property information this property's Handle points at.</summary>
    FPropInfo : TPropInfoExt;
{$ELSE}
    /// <summary>The synthetic property information this property's Handle points at.</summary>
    FPropInfo : TPropInfo;
{$ENDIF}
    /// <summary>Closure that reads the property's value from an instance; nil makes it write-only.</summary>
    FGetter : TFunc<Pointer, TValue>;
    /// <summary>Closure that writes the property's value to an instance; nil makes it read-only.</summary>
    FSetter : TProc<Pointer, TValue>;
    class var
      /// <summary>Every extension property, keyed by (parent type, name); owns its values.</summary>
      FRegister : TDictionary<TPair<PTypeInfo, string>, TRttiPropertyExtension>;
      /// <summary>Maps each class to its patched VMT copy, which new instances are switched to.</summary>
      FPatchedClasses : TDictionary<TClass, TClass>;
    /// <summary>
    ///   Static-dispatch entry patched into the VMT slot of TRttiProperty.GetIsReadable.
    /// </summary>
    /// <returns>
    ///   The result of the virtual <see cref="GetIsReadable" />.
    /// </returns>
    function GetIsReadableStub : Boolean; //override;
    /// <summary>
    ///   Static-dispatch entry patched into the VMT slot of TRttiProperty.GetIsWritable.
    /// </summary>
    /// <returns>
    ///   The result of the virtual <see cref="GetIsWritable" />.
    /// </returns>
    function GetIsWritableStub : Boolean; //override;
    /// <summary>
    ///   Static-dispatch entry patched into the VMT slot of TRttiProperty.DoGetValue.
    /// </summary>
    /// <param name="Instance">
    ///   The instance to read from.
    /// </param>
    /// <returns>
    ///   The result of the virtual <see cref="DoGetValue" />.
    /// </returns>
    function DoGetValueStub(Instance : Pointer) : TValue; //override;
    /// <summary>
    ///   Static-dispatch entry patched into the VMT slot of TRttiProperty.DoSetValue.
    /// </summary>
    /// <param name="Instance">
    ///   The instance to write to.
    /// </param>
    /// <param name="AValue">
    ///   The value to write.
    /// </param>
    procedure DoSetValueStub(Instance : Pointer; const AValue : TValue); //override;
    /// <summary>
    ///   Static-dispatch entry patched into the VMT slot of TRttiInstanceProperty.GetPropInfo.
    /// </summary>
    /// <returns>
    ///   The result of the virtual <see cref="GetPropInfo" />.
    /// </returns>
    function GetPropInfoStub : PPropInfo; // override;
  protected
    /// <summary>
    ///   Builds this class's patched VMT copy (registered in FPatchedClasses) whose property slots point at the
    ///   *Stub methods. Called once from the class constructor.
    /// </summary>
    class procedure InitVirtualMethodTable;

    /// <summary>
    ///   Reports whether the property can be read.
    /// </summary>
    /// <returns>
    ///   True when a Getter is assigned.
    /// </returns>
    function GetIsReadable : Boolean; virtual;
    /// <summary>
    ///   Reports whether the property can be written.
    /// </summary>
    /// <returns>
    ///   True when a Setter is assigned.
    /// </returns>
    function GetIsWritable : Boolean; virtual;
    /// <summary>
    ///   Reads the property's value by calling the Getter.
    /// </summary>
    /// <param name="Instance">
    ///   The instance to read from.
    /// </param>
    /// <returns>
    ///   The value the Getter returns.
    /// </returns>
    function DoGetValue(Instance : Pointer) : TValue; virtual;
    /// <summary>
    ///   Writes the property's value by calling the Setter.
    /// </summary>
    /// <param name="Instance">
    ///   The instance to write to.
    /// </param>
    /// <param name="AValue">
    ///   The value to write.
    /// </param>
    procedure DoSetValue(Instance : Pointer; const AValue : TValue); virtual;
    /// <summary>
    ///   Returns the synthetic property information.
    /// </summary>
    /// <returns>
    ///   The RTTI Handle, which points at FPropInfo.
    /// </returns>
    function GetPropInfo : PPropInfo; virtual;
  public
    /// <summary>
    ///   Creates the registry and patched-class map and builds the patched VMT.
    /// </summary>
    class constructor Create;
    /// <summary>
    ///   Frees every registered extension property, then the patched VMT copies and the maps.
    /// </summary>
    /// <remarks>
    ///   The instances are freed BEFORE the patched VMT memory: each dispatches through it, so the reverse
    ///   order destroyed them through freed memory.
    /// </remarks>
    class destructor Destroy;

    /// <summary>
    ///   Creates an extension property on the given class and registers it; the registry owns and frees it.
    /// </summary>
    /// <param name="Parent">
    ///   Type information of the class the property is attached to.
    /// </param>
    /// <param name="Name">
    ///   The property name (truncated to 255 characters in the synthetic property information).
    /// </param>
    /// <param name="PropertyType">
    ///   Type information of the property's value type.
    /// </param>
    /// <exception cref="EListError">
    ///   A property of that name is already registered for Parent (duplicate dictionary key).
    /// </exception>
    constructor Create(Parent : PTypeInfo; const Name : string; PropertyType : PTypeInfo);

    /// <summary>
    ///   Finds an extension property by name on a type or, failing that, on its ancestors.
    /// </summary>
    /// <param name="Parent">
    ///   The type to search first; must not be nil.
    /// </param>
    /// <param name="PropertyName">
    ///   The property name, compared case-insensitively.
    /// </param>
    /// <returns>
    ///   The extension property, or nil when there is none.
    /// </returns>
    class function FindByName(Parent : TRttiType;
      const PropertyName : string) : TRttiPropertyExtension; overload;
    /// <summary>
    ///   Finds an extension property by a dotted name such as <c>TMyClass.MyProp</c> or
    ///   <c>MyUnit.TMyClass.MyProp</c>.
    /// </summary>
    /// <param name="FullPropertyName">
    ///   The scope and property name separated by the last dot; the scope must END the parent's qualified class
    ///   name and the name matches case-insensitively.
    /// </param>
    /// <returns>
    ///   The first matching extension property, or nil.
    /// </returns>
    class function FindByName(const FullPropertyName : string) : TRttiPropertyExtension; overload;

    /// <summary>
    ///   Closure that reads the property's value from an instance pointer; nil makes the property write-only.
    /// </summary>
    property Getter : TFunc<Pointer, TValue> read FGetter write FGetter;
    /// <summary>
    ///   Closure that writes a value to an instance pointer; nil makes the property read-only.
    /// </summary>
    property Setter : TProc<Pointer, TValue> read FSetter write FSetter;
  end;

  /// <summary>
  ///   Static generic helpers for dynamic arrays.
  /// </summary>
  TArrayHelper = class
  public
    /// <summary>
    ///   Concatenates several arrays into one new array.
    /// </summary>
    /// <param name="Arrays">
    ///   The arrays to join, in order.
    /// </param>
    /// <returns>
    ///   A new array holding every element of every input array.
    /// </returns>
    class function Concat<T>(const Arrays : array of TArray<T>) : TArray<T>; static;
    /// <summary>
    ///   Builds a two-element array.
    /// </summary>
    /// <param name="a">
    ///   The first element.
    /// </param>
    /// <param name="b">
    ///   The second element.
    /// </param>
    /// <returns>
    ///   The array <c>[a, b]</c>.
    /// </returns>
    class function Create<T>(const a : T; const b : T) : TArray<T>; static;
    /// <summary>
    ///   Removes elements from an array in place, shifting the tail down and shortening the array.
    /// </summary>
    /// <param name="source">
    ///   The array to modify.
    /// </param>
    /// <param name="index">
    ///   Zero-based index of the first element to remove; an index below 0 or past the end is ignored.
    /// </param>
    /// <param name="count">
    ///   Number of elements to remove; clamped to the elements from index onwards; zero or less does nothing.
    /// </param>
    class procedure Delete<T>(var source : TArray<T>; index, count : integer); static;
{$IFDEF DELPHI_2010}
    /// <summary>
    ///   Copies an enumerable into a new array, for Delphi 2010 whose TEnumerable lacks ToArray.
    /// </summary>
    /// <param name="Enumerable">
    ///   The collection to copy.
    /// </param>
    /// <param name="Count">
    ///   The collection's exact element count; the array is sized from it.
    /// </param>
    /// <returns>
    ///   The elements in enumeration order.
    /// </returns>
    class function ToArray<T>(Enumerable : TEnumerable<T>; Count : Integer) : TArray<T>; static;
{$ENDIF}
  end;

{$IFNDEF DELPHI_XE8_UP }
  /// <summary>
  ///   Back-fills <c>TFormatSettings.Invariant</c> for compilers before XE8.
  /// </summary>
  TFormatSettingsHelper = record helper for TFormatSettings
    /// <summary>
    ///   Returns culture-invariant format settings (US-style dates, '.' decimal separator, English month and
    ///   day names).
    /// </summary>
    /// <returns>
    ///   The invariant settings.
    /// </returns>
    class function Invariant : TFormatSettings; static;
  end;
{$ENDIF}

  /// <summary>Pointer to an object reference.</summary>
  PObject = ^TObject;

/// <summary>
///   Finds an RTTI type by qualified name or, failing that, by its bare name (case-insensitive) among all types.
/// </summary>
/// <param name="AName">
///   The qualified (<c>Unit.TType</c>) or bare type name.
/// </param>
/// <param name="AType">
///   The type found, or nil.
/// </param>
/// <returns>
///   True when a type was found.
/// </returns>
/// <remarks>
///   The bare-name fallback enumerates every type in the application, so it is slow; the first match wins.
/// </remarks>
function FindType(const AName : string; out AType : TRttiType) : Boolean; overload;
/// <summary>
///   Finds the interface type with the given GUID among all RTTI types.
/// </summary>
/// <param name="AGuid">
///   The interface GUID.
/// </param>
/// <param name="AType">
///   The interface type found, or nil.
/// </param>
/// <returns>
///   True when an interface with that GUID was found.
/// </returns>
function FindType(const AGuid : TGUID; out AType : TRttiType) : Boolean; overload;

{$REGION 'Documentation'}
///	<summary>
///	  Returns the RTTI type of the given TClass.
///	</summary>
///	<param name="AClass">
///	  The class to look up.
///	</param>
///	<returns>
///	  The class's RTTI type, from the unit's shared TRttiContext.
///	</returns>
{$ENDREGION}
function GetRttiType(AClass : TClass) : TRttiType; overload;

{$REGION 'Documentation'}
///	<summary>
///	  Returns the RTTI type of the given TypeInfo.
///	</summary>
///	<param name="ATypeInfo">
///	  The type information to look up.
///	</param>
///	<returns>
///	  The RTTI type, from the unit's shared TRttiContext; nil when ATypeInfo is nil.
///	</returns>
{$ENDREGION}
function GetRttiType(ATypeInfo : PTypeInfo) : TRttiType; overload;
/// <summary>
///   Returns every RTTI type in the application, through the unit's shared TRttiContext.
/// </summary>
/// <returns>
///   All types the context knows; slow, as it enumerates every package.
/// </returns>
function GetRttiTypes : TArray<TRttiType>;
/// <summary>
///   Reports whether an instance of one class can be used where another class is expected.
/// </summary>
/// <param name="ThisClass">
///   The class being tested.
/// </param>
/// <param name="OtherClass">
///   The target class; must not be nil.
/// </param>
/// <returns>
///   True when ThisClass has RTTI and <c>TRttiTypeHelper.IsCovariantTo</c> accepts OtherClass.
/// </returns>
function IsClassCovariantTo(ThisClass, OtherClass : TClass) : Boolean;
/// <summary>
///   Reports whether a value of one type can be used where another type is expected (inheritance, or generic
///   covariance of type arguments).
/// </summary>
/// <param name="ThisType">
///   Type information of the type being tested.
/// </param>
/// <param name="OtherType">
///   Type information of the target type.
/// </param>
/// <returns>
///   True when ThisType has RTTI and <c>TRttiTypeHelper.IsCovariantTo</c> accepts OtherType.
/// </returns>
function IsTypeCovariantTo(ThisType, OtherType : PTypeInfo) : Boolean;
/// <summary>
///   Retrieves the RTTI type of a class and returns if this was successful.
/// </summary>
/// <param name="AClass">
///   The class to look up.
/// </param>
/// <param name="AType">
///   The RTTI type, or nil.
/// </param>
/// <returns>
///   True when an RTTI type was found.
/// </returns>
function TryGetRttiType(AClass : TClass; out AType : TRttiType) : Boolean; overload;
/// <summary>
///   Retrieves the RTTI type for type information and returns if this was successful.
/// </summary>
/// <param name="ATypeInfo">
///   The type information to look up.
/// </param>
/// <param name="AType">
///   The RTTI type, or nil.
/// </param>
/// <returns>
///   True when an RTTI type was found.
/// </returns>
function TryGetRttiType(ATypeInfo : PTypeInfo; out AType : TRttiType) : Boolean; overload;

/// <summary>
///   Orders two values: ordinals by ordinal value, floats by value, strings by case-sensitive CompareStr.
/// </summary>
/// <param name="Left">
///   The first value.
/// </param>
/// <param name="Right">
///   The second value.
/// </param>
/// <returns>
///   Negative, zero or positive as Left is less than, equal to or greater than Right. Values of any other
///   kind, or of mismatched kinds (an ordinal and a float included), return 0 - "equal".
/// </returns>
function CompareValue(const Left, Right : TValue) : Integer;
/// <summary>
///   Reports whether two values are the same: numbers (ordinals and floats, mixed freely) through
///   <c>Math.SameValue</c>'s default tolerance, strings case-sensitively, classes, objects, pointers and variants
///   by equality.
/// </summary>
/// <param name="Left">
///   The first value.
/// </param>
/// <param name="Right">
///   The second value.
/// </param>
/// <returns>
///   True when the values are considered the same; False for unrelated kinds.
/// </returns>
/// <remarks>
///   Any other pair with identical TypeInfo (records, sets, arrays...) is compared byte for byte over its raw
///   data, so a managed field or a dynamic array compares by reference, not by content.
/// </remarks>
function SameValue(const Left, Right : TValue) : Boolean;

/// <summary>
///   Removes the <c>System.</c> unit prefix from a type name for display.
/// </summary>
/// <param name="s">
///   The name to clean.
/// </param>
/// <returns>
///   The name with EVERY occurrence of <c>System.</c> removed (case-insensitive); other unit prefixes are kept.
/// </returns>
function StripUnitName(const s : string) : string;

{$IFDEF DELPHI_2010}
/// <summary>
///   Back-fills <c>StrUtils.SplitString</c> for Delphi 2010: splits a string at every occurrence of any of the
///   delimiter characters.
/// </summary>
/// <param name="S">
///   The string to split.
/// </param>
/// <param name="Delimiters">
///   The set of delimiter characters.
/// </param>
/// <returns>
///   The parts, empty parts included; an empty array for an empty S.
/// </returns>
function SplitString(const S : string; const Delimiters : string) : TStringDynArray;
{$ENDIF}

/// <summary>
///   Overload of <c>SysUtils.Supports</c> for a TValue: queries the object behind an object or interface value
///   for an interface.
/// </summary>
/// <param name="Instance">
///   The value to query.
/// </param>
/// <param name="IID">
///   The GUID of the interface wanted.
/// </param>
/// <param name="Intf">
///   Receives the interface reference when the result is True.
/// </param>
/// <returns>
///   True when the value holds an object or interface whose object supports IID; False for any other kind.
/// </returns>
function Supports(const Instance : TValue; const IID : TGUID; out Intf) : Boolean; overload;

implementation

uses
  DUnitX.Helpers,
{$IFDEF USE_NS}
  System.Classes,
  System.Generics.Defaults,
  System.Math,
  System.StrUtils,
  System.UIConsts,
  System.UITypes;
{$ELSE}
  Classes,
  Generics.Defaults,
  Math,
  StrUtils,
  UIConsts,
  UITypes;
{$ENDIF}

var
  Context : TRttiContext;
  Enumerations : TDictionary<PTypeInfo, TStrings>;

  { TAttributeUtils }

class function TAttributeUtils.ContainsAttribute(const attributes : TArray<TCustomAttribute>; const AttributeClass : TCustomAttributeClass)
  : boolean;
begin
  result := FindAttribute(attributes, AttributeClass) <> nil;
end;

class function TAttributeUtils.FindAttribute(const attributes : TArray<TCustomAttribute>; const AttributeClass : TCustomAttributeClass) :
  TCustomAttribute;
var
  attribute : TCustomAttribute;
begin
  result := nil;
  for attribute in attributes do
  begin
    if attribute.ClassType = AttributeClass then
      Exit(attribute);
  end;
end;

class function TAttributeUtils.FindAttribute(const attributes : TArray<TCustomAttribute>; const AttributeClass : TCustomAttributeClass;
  var attribute : TCustomAttribute; const startIndex : integer) : integer;
var
  i : integer;
begin
  result := -1;
  attribute := nil;
  for i := startIndex to Length(attributes) - 1 do
  begin
    if attributes[i].ClassType = AttributeClass then
    begin
      attribute := attributes[i];
      Exit(i);
    end;
  end;
end;

class function TAttributeUtils.FindAttributes(const attributes : TArray<TCustomAttribute>; const AttributeClass : TCustomAttributeClass) :
  TArray<TCustomAttribute>;
var
  i : integer;
  attribute : TCustomAttribute;
begin
  i := 0;
  SetLength(result, 0);
  for attribute in attributes do
  begin
    if attribute.ClassType = AttributeClass then
    begin
      SetLength(result, i + 1);
      result[i] := attribute;
      Inc(i);
    end;
  end;
end;

class function TStrUtils.EncodeWhitespace(const S : string) : string;
const
  DELIMITER         : array[boolean] of string = (#39, '');
var
  index : integer;
  lastWhitespace : boolean;
begin
  Result := '';
  lastWhitespace := true;
  for index := 1 to Length(S) do
  begin
    if S[index] < #32 then
    begin
      Result := Result + DELIMITER[lastWhitespace] + '#' + IntToStr(Ord(S[index]));
      lastWhitespace := true;
    end
    else
    begin
      Result := Result + DELIMITER[not lastWhitespace] + S[index];
      lastWhitespace := false;
    end;
  end;
  Result := Result + DELIMITER[lastWhitespace];
end;

class function TStrUtils.Join(const values : TArray<string>; const delim : string) : string;
var
  v : string;
begin
  result := '';
  for v in values do
  begin
    if result <> '' then
      result := result + delim;
    result := result + v;
  end;
end;

class function TStrUtils.PadString(const s : string; const totalLength : integer; const padLeft : boolean = True; padChr : Char = ' ') :
  string;
begin
  Result := s;
  while Length(result) < totalLength do
  begin
    if padLeft then
      Result := padChr + Result
    else
      Result := Result + padChr;
  end;
end;

{$REGION 'Conversion functions'}
type
  TConvertFunc = function(const ASource : TValue; ATarget : PTypeInfo; out AResult : TValue) : Boolean;

function ConvFail(const ASource : TValue; ATarget : PTypeInfo; out AResult : TValue) : Boolean;
begin
  Result := False;
end;

{$IFDEF DELPHI_XE3_UP}
function ConvStr2DynArray(const ASource : TValue; ATarget : PTypeInfo; out AResult : TValue) : Boolean;
var
  s : string;
  values : TStringDynArray;
  i : NativeInt;
  p : Pointer;
  v1, v2 : TValue;
  elType : PTypeInfo;
begin
  s := ASource.AsString;
  if StartsStr('[', s) and EndsStr(']', s) then
    s := Copy(s, 2, Length(s) - 2);
  values := SplitString(s, ',');
  i := Length(values);
  p := nil;
  DynArraySetLength(p, ATarget, 1, @i);
  TValue.MakeWithoutCopy(@p, ATarget, AResult);
  elType := ATarget.TypeData.DynArrElType^;
  for i := 0 to High(values) do
  begin
    v1 := TValue.FromString(values[i]);
    if not v1.TryConvert(elType, v2) then
      Exit(False);
    AResult.SetArrayElement(i, v2);
  end;
  Result := True;
end;
{$ENDIF}

function ConvAny2Nullable(const ASource : TValue; ATarget : PTypeInfo; out AResult : TValue) : Boolean;
var
  LType : TRttiType;
  LValue : TValue;
  LBuffer : array of Byte;
begin
  Result := TryGetRttiType(ATarget, LType) and LType.IsGenericTypeOf('Nullable')
    and ASource.TryConvert(LType.GetGenericArguments[0].Handle, LValue);
  if Result then
  begin
    SetLength(LBuffer, LType.TypeSize);
    Move(LValue.GetReferenceToRawData^, LBuffer[0], LType.TypeSize - SizeOf(string));
    PString(@LBuffer[LType.TypeSize - SizeOf(string)])^ := DefaultTrueBoolStr;
    TValue.Make(LBuffer, LType.Handle, AResult);
    PString(@LBuffer[LType.TypeSize - SizeOf(string)])^ := '';
  end;
end;

function ConvClass2Class(const ASource : TValue; ATarget : PTypeInfo; out AResult : TValue) : Boolean;
begin
  Result := ASource.TryCast(ATarget, AResult);
  if not Result and IsTypeCovariantTo(ASource.TypeInfo, ATarget) then
  begin
    AResult := TValue.From(ASource.AsObject, GetTypeData(ATarget).ClassType);
    Result := True;
  end;
end;

function ConvClass2Enum(const ASource : TValue; ATarget : PTypeInfo; out AResult : TValue) : Boolean;
begin
  Result := ATarget = TypeInfo(Boolean);
  if Result then
    AResult := ASource.AsObject <> nil;
end;

function ConvEnum2Class(const ASource : TValue; ATarget : PTypeInfo; out AResult : TValue) : Boolean;
var
  LType : TRttiType;
  LStrings : TStrings;
  i : Integer;
begin
  Result := TryGetRttiType(ATarget, LType)
    and LType.AsInstance.MetaclassType.InheritsFrom(TStrings);
  if Result then
  begin
    if not Enumerations.TryGetValue(ASource.TypeInfo, LStrings) then
    begin
      LStrings := TStringList.Create;
      with TRttiEnumerationType(ASource.RttiType) do
      begin
        for i := MinValue to MaxValue do
        begin
          LStrings.Add(GetEnumName(Handle, i));
        end;
      end;
      Enumerations.Add(ASource.TypeInfo, LStrings);
    end;
    AResult := TValue.From(LStrings, TStrings);
    Result := True;
  end;
end;

//True when AValue lies within the range of the ordinal type ATarget, so TValue.FromOrdinal does not truncate it
//(Integer 300 used to become Byte 44). A 64-bit target takes any Int64.
function OrdinalFitsType(const AValue : Int64; ATarget : PTypeInfo) : Boolean;
var
  LTypeData : PTypeData;
begin
  if ATarget.Kind = tkInt64 then
    Exit(True);
  LTypeData := GetTypeData(ATarget);
  if (ATarget.Kind = tkInteger) and (LTypeData.OrdType = otULong) then
    Result := (AValue >= Cardinal(LTypeData.MinValue)) and (AValue <= Cardinal(LTypeData.MaxValue))
  else
    Result := (AValue >= LTypeData.MinValue) and (AValue <= LTypeData.MaxValue);
end;

function ConvFloat2Ord(const ASource : TValue; ATarget : PTypeInfo; out AResult : TValue) : Boolean;
var
  LValue : Extended;
begin
  LValue := ASource.AsExtended;
  //Within Int64's range first, or Trunc raises; then a whole number that fits the target.
  Result := (Abs(LValue) < 9.2E18) and (Frac(LValue) = 0) and OrdinalFitsType(Trunc(LValue), ATarget);
  if Result then
    AResult := TValue.FromOrdinal(ATarget, Trunc(LValue));
end;

function ConvFloat2Str(const ASource : TValue; ATarget : PTypeInfo; out AResult : TValue) : Boolean;
var
  LValue : TValue;
begin
  if ASource.TypeInfo = TypeInfo(TDate) then
    LValue := DateToStr(ASource.AsExtended)
  else if ASource.TypeInfo = TypeInfo(TDateTime) then
    LValue := DateTimeToStr(ASource.AsExtended)
  else if ASource.TypeInfo = TypeInfo(TTime) then
    LValue := TimeToStr(ASource.AsExtended)
  else
    LValue := FloatToStr(ASource.AsExtended);
  Result := LValue.TryCast(ATarget, AResult);
end;

function ConvIntf2Class(const ASource : TValue; ATarget : PTypeInfo; out AResult : TValue) : Boolean;
begin
  Result := ConvClass2Class(ASource.AsInterface as TObject, ATarget, AResult);
end;

function ConvIntf2Intf(const ASource : TValue; ATarget : PTypeInfo; out AResult : TValue) : Boolean;
var
  LType : TRttiType;
  LMethod : TRttiMethod;
  LInterface : IInterface;
begin
  Result := ASource.TryCast(ATarget, AResult);
  if not Result then
  begin
    if IsTypeCovariantTo(ASource.TypeInfo, ATarget) then
    begin
      AResult := TValue.From(ASource.GetReferenceToRawData, ATarget);
      Result := True;
    end
    else if TryGetRttiType(ASource.TypeInfo, LType) and (GetTypeName(ATarget) = 'IList')
      and LType.IsGenericTypeOf('IList') and LType.TryGetMethod('AsList', LMethod) then
    begin
      LInterface := LMethod.Invoke(ASource, []).AsInterface;
      AResult := TValue.From(@LInterface, ATarget);
      Result := True;
    end;
  end;
end;

function ConvNullable2Any(const ASource : TValue; ATarget : PTypeInfo; out AResult : TValue) : Boolean;
var
  LType : TRttiType;
  LValue : TValue;
begin
  Result := TryGetRttiType(ASource.TypeInfo, LType)
    and LType.IsGenericTypeOf('Nullable');
  if Result then
  begin
    LValue := TValue.From(ASource.GetReferenceToRawData, LType.GetGenericArguments[0].Handle);
    Result := LValue.TryConvert(ATarget, AResult);
  end;
end;

function ConvOrd2Float(const ASource : TValue; ATarget : PTypeInfo; out AResult : TValue) : Boolean;
begin
  AResult := TValue.FromFloat(ATarget, ASource.AsOrdinal);
  Result := True;
end;

function ConvOrd2Ord(const ASource : TValue; ATarget : PTypeInfo; out AResult : TValue) : Boolean;
begin
  Result := OrdinalFitsType(ASource.AsOrdinal, ATarget);
  if Result then
    AResult := TValue.FromOrdinal(ATarget, ASource.AsOrdinal);
end;

function ConvOrd2Str(const ASource : TValue; ATarget : PTypeInfo; out AResult : TValue) : Boolean;
var
  LValue : TValue;
begin
  LValue := ASource.ToString;
  Result := LValue.TryCast(ATarget, AResult);
end;

function ConvRec2Meth(const ASource : TValue; ATarget : PTypeInfo; out AResult : TValue) : Boolean;
begin
  if ASource.TypeInfo = TypeInfo(TMethod) then
  begin
    AResult := TValue.From(ASource.GetReferenceToRawData, ATarget);
    Result := True;
  end
  else
  begin
    Result := ConvNullable2Any(ASource, ATarget, AResult);
  end;
end;

function ConvSet2Class(const ASource : TValue; ATarget : PTypeInfo; out AResult : TValue) : Boolean;
var
  LType : TRttiType;
  LTypeData : PTypeData;
  LStrings : TStrings;
  i : Integer;
begin
  Result := TryGetRttiType(ATarget, LType)
    and LType.AsInstance.MetaclassType.InheritsFrom(TStrings);
  if Result then
  begin
    LTypeData := GetTypeData(ASource.TypeInfo);
    if not Enumerations.TryGetValue(LTypeData.CompType^, LStrings) then
    begin
      LStrings := TStringList.Create;
      with TRttiEnumerationType(TRttiSetType(ASource.RttiType).ElementType) do
      begin
        for i := MinValue to MaxValue do
        begin
          LStrings.Add(GetEnumName(Handle, i));
        end;
      end;
      Enumerations.Add(LTypeData.CompType^, LStrings);
    end;
    AResult := TValue.From(LStrings, TStrings);
  end;
end;

function ConvStr2Enum(const ASource : TValue; ATarget : PTypeInfo; out AResult : TValue) : Boolean;
var
  LTypeData : PTypeData;
  LValue : Integer;
begin
  // GetEnumValue returns -1 for an unknown name (and raises for a non-numeric ByteBool/WordBool/LongBool name).
  try
    LValue := GetEnumValue(ATarget, ASource.AsString);
  except
    on EConvertError do
      Exit(False);
  end;
  LTypeData := GetTypeData(ATarget);
  Result := (LValue >= LTypeData.MinValue) and (LValue <= LTypeData.MaxValue);
  if Result then
    AResult := TValue.FromOrdinal(ATarget, LValue);
end;

function StripIso8601TimeZone(const ASource : string) : string;
var
  i : Integer;
  len : Integer;
begin
  // TestCase values such as '1988-10-21T17:44:23.456Z' / '+02:30' are wall-clock
  // timestamps; the suffix is not applied. StrToDateTimeDef rejects those suffixes
  // and returns 0 (30.12.1899), which is what the ISO-8601 verbose tests hit.
  Result := ASource;
  len := Length(Result);
  if len = 0 then
    Exit;

  if CharInSet(Result[len], ['Z', 'z']) then
  begin
    SetLength(Result, len - 1);
    Exit;
  end;

  // yyyy-mm-dd is 10 characters; any later '+' or '-' is a timezone offset.
  for i := 11 to len do
  begin
    if CharInSet(Result[i], ['+', '-']) then
    begin
      SetLength(Result, i - 1);
      Exit;
    end;
  end;
end;

// ISO 8601 first, then the invariant culture, so that a value has the same meaning on every machine;
// the machine locale is the last resort, for test cases written in the local format.
function Iso8601FormatSettings : TFormatSettings;
begin
  Result := TFormatSettings.Invariant();
  Result.ShortDateFormat := 'yyyy/mm/dd';
  Result.DateSeparator := '-';
  Result.ShortTimeFormat := 'hh:nn:ss\.nnn';
  Result.TimeSeparator := ':';
end;

function Str2DateTimeValue(const ASource : string; out AResult : TValue) : Boolean;
var
  dateTime : TDateTime;
begin
  Result := TryStrToDateTime(StripIso8601TimeZone(ASource), dateTime, Iso8601FormatSettings)
    or TryStrToDateTime(ASource, dateTime, TFormatSettings.Invariant)
    or TryStrToDateTime(ASource, dateTime);
  if Result then
    AResult := TValue.From<TDateTime>(dateTime);
end;

function Str2TimeValue(const ASource : string; out AResult : TValue) : Boolean;
var
  time : TDateTime;
begin
  Result := TryStrToTime(ASource, time, Iso8601FormatSettings)
    or TryStrToTime(ASource, time, TFormatSettings.Invariant)
    or TryStrToTime(ASource, time);
  if Result then
    AResult := TValue.From<TDateTime>(time);
end;

function Str2DateValue(const ASource : string; out AResult : TValue) : Boolean;
var
  date : TDateTime;
begin
  Result := TryStrToDate(ASource, date, Iso8601FormatSettings)
    or TryStrToDate(ASource, date, TFormatSettings.Invariant)
    or TryStrToDate(ASource, date);
  if Result then
    AResult := TValue.From<TDate>(date);
end;

//True when AValue's only comma is followed by exactly three digits and preceded by a whole number that does not start
//with 0, as in '1,000' or '-12,500': a thousands group in one locale and a decimal comma in another.
function IsAmbiguousDecimalComma(const AValue : string) : Boolean;
var
  commaPos : Integer;
  wholePart : string;
  fraction : string;
  ch : Char;
begin
  Result := False;
  commaPos := Pos(',', AValue);
  if (commaPos = 0) or (Pos(',', AValue, commaPos + 1) > 0) or (Pos('.', AValue) > 0) then
    Exit;
  wholePart := Copy(AValue, 1, commaPos - 1);
  if (wholePart <> '') and CharInSet(wholePart[1], ['+', '-']) then
    Delete(wholePart, 1, 1);
  fraction := Copy(AValue, commaPos + 1, MaxInt);
  if (wholePart = '') or (wholePart[1] = '0') or (Length(fraction) <> 3) then
    Exit;
  for ch in wholePart + fraction do
    if not CharInSet(ch, ['0'..'9']) then
      Exit;
  Result := True;
end;

function ConvStr2Float(const ASource : TValue; ATarget : PTypeInfo; out AResult : TValue) : Boolean;
var
  lValue : string;
  lFloat : Extended;
begin
  //A decimal comma is accepted ('2,5'), except where it could be a thousands separator, which is refused rather
  //than read as a decimal ('1,000' used to become 1.0).
  if IsAmbiguousDecimalComma(Trim(ASource.AsString)) then
    Exit(False);
  lValue := StringReplace(ASource.AsString, ',', '.', [rfReplaceAll]);

  if ATarget = TypeInfo(TDate) then
    Result := Str2DateValue(lValue, AResult)
  else if ATarget = TypeInfo(TDateTime) then
    Result := Str2DateTimeValue(lValue, AResult)
  else if ATarget = TypeInfo(TTime) then
    Result := Str2TimeValue(lValue, AResult)
  else
  begin
    Result := TryStrToFloat(lValue, lFloat, TFormatSettings.Invariant);
    if Result then
      AResult := TValue.FromFloat(ATarget, lFloat);
  end;
end;

function ConvStr2Int(const ASource : TValue; ATarget : PTypeInfo; out AResult : TValue) : Boolean;
var
  LTypeData : PTypeData;
  LValue : Int64;
begin
  try
    if ATarget = TypeInfo(TAlphaColor) then
      LValue := StringToAlphaColor(ASource.AsString)
    else if ATarget = TypeInfo(TColor) then
      LValue := StringToColor(ASource.AsString)
    else if not TryStrToInt64(ASource.AsString, LValue) then
      Exit(False);
  except
    on EConvertError do
      Exit(False);
  end;
  // Range-check before FromOrdinal, which would silently truncate ('300' -> Byte 44).
  LTypeData := GetTypeData(ATarget);
  if LTypeData.OrdType = otULong then
    Result := (LValue >= Cardinal(LTypeData.MinValue)) and (LValue <= Cardinal(LTypeData.MaxValue))
  else
    Result := (LValue >= LTypeData.MinValue) and (LValue <= LTypeData.MaxValue);
  if Result then
    AResult := TValue.FromOrdinal(ATarget, LValue);
end;

function ConvStr2Ord(const ASource : TValue; ATarget : PTypeInfo; out AResult : TValue) : Boolean;
var
  LTypeData : PTypeData;
  LValue : Int64;
{$IFDEF DELPHI_XE6_UP}
  LUValue : UInt64;
{$ENDIF}
begin
  LTypeData := GetTypeData(ATarget);
{$IFDEF DELPHI_XE6_UP}
  // An unsigned 64-bit type stores its range as signed values, so Min > Max.
  if LTypeData.MinInt64Value > LTypeData.MaxInt64Value then
  begin
    Result := (not StartsStr('-', Trim(ASource.AsString))) and TryStrToUInt64(ASource.AsString, LUValue);
    if Result then
      AResult := TValue.FromOrdinal(ATarget, Int64(LUValue));
    Exit;
  end;
{$ENDIF}
  Result := TryStrToInt64(ASource.AsString, LValue)
    and (LValue >= LTypeData.MinInt64Value) and (LValue <= LTypeData.MaxInt64Value);
  if Result then
    AResult := TValue.FromOrdinal(ATarget, LValue);
end;

function ConvStr2Set(const ASource : TValue; ATarget : PTypeInfo; out AResult : TValue) : Boolean;
var
  LValue : Integer;
begin
  // StringToSet raises for an unknown element name.
  try
    LValue := StringToSet(ATarget, ASource.AsString);
  except
    on EPropertyConvertError do
      Exit(False);
  end;
  // StringToSet returns at most 32 elements as an Integer; copy only as many bytes as the set occupies.
  TValue.Make(nil, ATarget, AResult);
  Move(LValue, AResult.GetReferenceToRawData^, Min(SizeOfSet(ATarget), SizeOf(LValue)));
  Result := True;
end;

{$ENDREGION}

{$REGION 'Conversions'}
const
  Conversions       : array[TTypeKind, TTypeKind] of TConvertFunc = (
    // tkUnknown
    (
    // tkUnknown, tkInteger, tkChar, tkEnumeration, tkFloat, tkString,
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkSet, tkClass, tkMethod, tkWChar, tkLString, tkWString
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkVariant, tkArray, tkRecord, tkInterface, tkInt64, tkDynArray
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkUString, tkClassRef, tkPointer, tkProcedure
    ConvFail, ConvFail, ConvFail, ConvFail{$IFDEF DELPHI_XE103_UP}, ConvFail{$ENDIF}
    ),
    // tkInteger
    (
    // tkUnknown, tkInteger, tkChar, tkEnumeration, tkFloat, tkString,
    ConvFail, ConvOrd2Ord, ConvOrd2Ord, ConvOrd2Ord, ConvOrd2Float, ConvOrd2Str,
    // tkSet, tkClass, tkMethod, tkWChar, tkLString, tkWString
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkVariant, tkArray, tkRecord, tkInterface, tkInt64, tkDynArray
    ConvFail, ConvFail, ConvFail, ConvFail, ConvOrd2Ord, ConvFail,
    // tkUString, tkClassRef, tkPointer, tkProcedure, tkMRecord
    ConvOrd2Str, ConvFail, ConvFail, ConvFail{$IFDEF DELPHI_XE103_UP}, ConvFail{$ENDIF}
    ),
    // tkChar
    (
    // tkUnknown, tkInteger, tkChar, tkEnumeration, tkFloat, tkString,
    ConvFail, ConvOrd2Ord, ConvOrd2Ord, ConvOrd2Ord, ConvOrd2Float, ConvFail,
    // tkSet, tkClass, tkMethod, tkWChar, tkLString, tkWString
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkVariant, tkArray, tkRecord, tkInterface, tkInt64, tkDynArray
    ConvFail, ConvFail, ConvFail, ConvFail, ConvOrd2Ord, ConvFail,
    // tkUString, tkClassRef, tkPointer, tkProcedure, tkMRecord
    ConvFail, ConvFail, ConvFail, ConvFail{$IFDEF DELPHI_XE103_UP}, ConvFail{$ENDIF}
    ),
    // tkEnumeration
    (
    // tkUnknown, tkInteger, tkChar, tkEnumeration, tkFloat, tkString,
    ConvFail, ConvOrd2Ord, ConvOrd2Ord, ConvOrd2Ord, ConvOrd2Float, ConvFail,
    // tkSet, tkClass, tkMethod, tkWChar, tkLString, tkWString
    ConvFail, ConvEnum2Class, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkVariant, tkArray, tkRecord, tkInterface, tkInt64, tkDynArray
    ConvFail, ConvFail, ConvFail, ConvFail, ConvOrd2Ord, ConvFail,
    // tkUString, tkClassRef, tkPointer, tkProcedure, tkMRecord
    ConvOrd2Str, ConvFail, ConvFail, ConvFail{$IFDEF DELPHI_XE103_UP}, ConvFail{$ENDIF}
    ),
    // tkFloat
    (
    // tkUnknown, tkInteger, tkChar, tkEnumeration, tkFloat, tkString,
    ConvFail, ConvFloat2Ord, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkSet, tkClass, tkMethod, tkWChar, tkLString, tkWString
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkVariant, tkArray, tkRecord, tkInterface, tkInt64, tkDynArray
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFloat2Ord, ConvFail,
    // tkUString, tkClassRef, tkPointer, tkProcedure, tkMRecord
    ConvFloat2Str, ConvFail, ConvFail, ConvFail{$IFDEF DELPHI_XE103_UP}, ConvFail{$ENDIF}
    ),
    // tkString
    (
    // tkUnknown, tkInteger, tkChar, tkEnumeration, tkFloat, tkString,
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkSet, tkClass, tkMethod, tkWChar, tkLString, tkWString
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkVariant, tkArray, tkRecord, tkInterface, tkInt64, tkDynArray
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkUString, tkClassRef, tkPointer, tkProcedure, tkMRecord
    ConvFail, ConvFail, ConvFail, ConvFail{$IFDEF DELPHI_XE103_UP}, ConvFail{$ENDIF}
    ),
    // tkSet
    (
    // tkUnknown, tkInteger, tkChar, tkEnumeration, tkFloat, tkString,
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkSet, tkClass, tkMethod, tkWChar, tkLString, tkWString
    ConvFail, ConvSet2Class, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkVariant, tkArray, tkRecord, tkInterface, tkInt64, tkDynArray
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkUString, tkClassRef, tkPointer, tkProcedure, tkMRecord
    ConvFail, ConvFail, ConvFail, ConvFail{$IFDEF DELPHI_XE103_UP}, ConvFail{$ENDIF}
    ),
    // tkClass
    (
    // tkUnknown, tkInteger, tkChar, tkEnumeration, tkFloat, tkString,
    ConvFail, ConvFail, ConvFail, ConvClass2Enum, ConvFail, ConvFail,
    // tkSet, tkClass, tkMethod, tkWChar, tkLString, tkWString
    ConvFail, ConvClass2Class, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkVariant, tkArray, tkRecord, tkInterface, tkInt64, tkDynArray
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkUString, tkClassRef, tkPointer, tkProcedure, tkMRecord
    ConvFail, ConvFail, ConvFail, ConvFail{$IFDEF DELPHI_XE103_UP}, ConvFail{$ENDIF}
    ),
    // tkMethod
    (
    // tkUnknown, tkInteger, tkChar, tkEnumeration, tkFloat, tkString,
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkSet, tkClass, tkMethod, tkWChar, tkLString, tkWString
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkVariant, tkArray, tkRecord, tkInterface, tkInt64, tkDynArray
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkUString, tkClassRef, tkPointer, tkProcedure, tkMRecord
    ConvFail, ConvFail, ConvFail, ConvFail{$IFDEF DELPHI_XE103_UP}, ConvFail{$ENDIF}
    ),
    // tkWChar
    (
    // tkUnknown, tkInteger, tkChar, tkEnumeration, tkFloat, tkString,
    ConvFail, ConvOrd2Ord, ConvOrd2Ord, ConvOrd2Ord, ConvOrd2Float, ConvFail,
    // tkSet, tkClass, tkMethod, tkWChar, tkLString, tkWString
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkVariant, tkArray, tkRecord, tkInterface, tkInt64, tkDynArray
    ConvFail, ConvFail, ConvFail, ConvFail, ConvOrd2Ord, ConvFail,
    // tkUString, tkClassRef, tkPointer, tkProcedure, tkMRecord
    ConvFail, ConvFail, ConvFail, ConvFail{$IFDEF DELPHI_XE103_UP}, ConvFail{$ENDIF}
    ),
    // tkLString
    (
    // tkUnknown, tkInteger, tkChar, tkEnumeration, tkFloat, tkString,
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkSet, tkClass, tkMethod, tkWChar, tkLString, tkWString
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkVariant, tkArray, tkRecord, tkInterface, tkInt64, tkDynArray
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkUString, tkClassRef, tkPointer, tkProcedure, tkMRecord
    ConvFail, ConvFail, ConvFail, ConvFail{$IFDEF DELPHI_XE103_UP}, ConvFail{$ENDIF}
    ),
    // tkWString
    (
    // tkUnknown, tkInteger, tkChar, tkEnumeration, tkFloat, tkString,
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkSet, tkClass, tkMethod, tkWChar, tkLString, tkWString
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkVariant, tkArray, tkRecord, tkInterface, tkInt64, tkDynArray
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkUString, tkClassRef, tkPointer, tkProcedure, tkMRecord
    ConvFail, ConvFail, ConvFail, ConvFail{$IFDEF DELPHI_XE103_UP}, ConvFail{$ENDIF}
    ),
    // tkVariant
    (
    // tkUnknown, tkInteger, tkChar, tkEnumeration, tkFloat, tkString,
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkSet, tkClass, tkMethod, tkWChar, tkLString, tkWString
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkVariant, tkArray, tkRecord, tkInterface, tkInt64, tkDynArray
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkUString, tkClassRef, tkPointer, tkProcedure, tkMRecord
    ConvFail, ConvFail, ConvFail, ConvFail{$IFDEF DELPHI_XE103_UP}, ConvFail{$ENDIF}
    ),
    // tkArray
    (
    // tkUnknown, tkInteger, tkChar, tkEnumeration, tkFloat, tkString,
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkSet, tkClass, tkMethod, tkWChar, tkLString, tkWString
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkVariant, tkArray, tkRecord, tkInterface, tkInt64, tkDynArray
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkUString, tkClassRef, tkPointer, tkProcedure, tkMRecord
    ConvFail, ConvFail, ConvFail, ConvFail{$IFDEF DELPHI_XE103_UP}, ConvFail{$ENDIF}
    ),
    // tkRecord
    (
    // tkUnknown, tkInteger, tkChar, tkEnumeration, tkFloat, tkString,
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkSet, tkClass, tkMethod, tkWChar, tkLString, tkWString
    ConvFail, ConvFail, ConvRec2Meth, ConvFail, ConvFail, ConvFail,
    // tkVariant, tkArray, tkRecord, tkInterface, tkInt64, tkDynArray
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkUString, tkClassRef, tkPointer, tkProcedure, tkMRecord
    ConvFail, ConvFail, ConvFail, ConvFail{$IFDEF DELPHI_XE103_UP}, ConvFail{$ENDIF}
    ),
    // tkInterface
    (
    // tkUnknown, tkInteger, tkChar, tkEnumeration, tkFloat, tkString,
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkSet, tkClass, tkMethod, tkWChar, tkLString, tkWString
    ConvFail, ConvIntf2Class, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkVariant, tkArray, tkRecord, tkInterface, tkInt64, tkDynArray
    ConvFail, ConvFail, ConvFail, ConvIntf2Intf, ConvFail, ConvFail,
    // tkUString, tkClassRef, tkPointer, tkProcedure, tkMRecord
    ConvFail, ConvFail, ConvFail, ConvFail{$IFDEF DELPHI_XE103_UP}, ConvFail{$ENDIF}
    ),
    // tkInt64
    (
    // tkUnknown, tkInteger, tkChar, tkEnumeration, tkFloat, tkString,
    ConvFail, ConvOrd2Ord, ConvOrd2Ord, ConvOrd2Ord, ConvOrd2Float, ConvFail,
    // tkSet, tkClass, tkMethod, tkWChar, tkLString, tkWString
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkVariant, tkArray, tkRecord, tkInterface, tkInt64, tkDynArray
    ConvFail, ConvFail, ConvFail, ConvFail, ConvOrd2Ord, ConvFail,
    // tkUString, tkClassRef, tkPointer, tkProcedure, tkMRecord
    ConvOrd2Str, ConvFail, ConvFail, ConvFail{$IFDEF DELPHI_XE103_UP}, ConvFail{$ENDIF}
    ),
    // tkDynArray
    (
    // tkUnknown, tkInteger, tkChar, tkEnumeration, tkFloat, tkString,
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkSet, tkClass, tkMethod, tkWChar, tkLString, tkWString
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkVariant, tkArray, tkRecord, tkInterface, tkInt64, tkDynArray
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkUString, tkClassRef, tkPointer, tkProcedure, tkMRecord
    ConvFail, ConvFail, ConvFail, ConvFail{$IFDEF DELPHI_XE103_UP}, ConvFail{$ENDIF}
    ),
    // tkUString
    (
    // tkUnknown, tkInteger, tkChar, tkEnumeration, tkFloat, tkString,
    ConvFail, ConvStr2Int, ConvFail, ConvStr2Enum, ConvStr2Float, ConvFail,
    // tkSet, tkClass, tkMethod, tkWChar, tkLString, tkWString
    ConvStr2Set, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkVariant, tkArray, tkRecord, tkInterface, tkInt64, tkDynArray
    ConvFail, ConvFail, ConvFail, ConvFail, ConvStr2Ord, {$IFDEF DELPHI_XE3_UP}ConvStr2DynArray{$ELSE}ConvFail{$ENDIF},
    // tkUString, tkClassRef, tkPointer, tkProcedure, tkMRecord
    ConvFail, ConvFail, ConvFail, ConvFail{$IFDEF DELPHI_XE103_UP}, ConvFail{$ENDIF}
    ),
    // tkClassRef
    (
    // tkUnknown, tkInteger, tkChar, tkEnumeration, tkFloat, tkString,
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkSet, tkClass, tkMethod, tkWChar, tkLString, tkWString
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkVariant, tkArray, tkRecord, tkInterface, tkInt64, tkDynArray
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkUString, tkClassRef, tkPointer, tkProcedure, tkMRecord
    ConvFail, ConvFail, ConvFail, ConvFail{$IFDEF DELPHI_XE103_UP}, ConvFail{$ENDIF}
    ),
    // tkPointer
    (
    // tkUnknown, tkInteger, tkChar, tkEnumeration, tkFloat, tkString,
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkSet, tkClass, tkMethod, tkWChar, tkLString, tkWString
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkVariant, tkArray, tkRecord, tkInterface, tkInt64, tkDynArray
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkUString, tkClassRef, tkPointer, tkProcedure, tkMRecord
    ConvFail, ConvFail, ConvFail, ConvFail{$IFDEF DELPHI_XE103_UP}, ConvFail{$ENDIF}
    ),
    // tkProcedure
    (
    // tkUnknown, tkInteger, tkChar, tkEnumeration, tkFloat, tkString,
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkSet, tkClass, tkMethod, tkWChar, tkLString, tkWString
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkVariant, tkArray, tkRecord, tkInterface, tkInt64, tkDynArray
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkUString, tkClassRef, tkPointer, tkProcedure, tkMRecord
    ConvFail, ConvFail, ConvFail, ConvFail{$IFDEF DELPHI_XE103_UP}, ConvFail{$ENDIF}
    )
{$IFDEF DELPHI_XE103_UP}
    ,
    // tkMRecord
    (
    // tkUnknown, tkInteger, tkChar, tkEnumeration, tkFloat, tkString,
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkSet, tkClass, tkMethod, tkWChar, tkLString, tkWString
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkVariant, tkArray, tkRecord, tkInterface, tkInt64, tkDynArray
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail, ConvFail,
    // tkUString, tkClassRef, tkPointer, tkProcedure, tkMRecord
    ConvFail, ConvFail, ConvFail, ConvFail, ConvFail
    )
{$ENDIF}
    );
{$ENDREGION}

function ExtractGenericArguments(ATypeInfo : PTypeInfo) : string;
var
  i : Integer;
  s : string;
begin
  s := UTF8ToString(ATypeInfo.Name);
{$IFNDEF NEXTGEN}
  i := Pos('<', s);
  if i > 0 then
  begin
    Result := Copy(s, Succ(i), Length(s) - Succ(i));
  end
  else
  begin
    Result := '';
  end;
{$ELSE}
  i := s.IndexOf('<');
  if i > -1 then
    Result := s.SubString(Succ(i), s.Length - (Succ(i) + 1))
  else
    Result := string.Empty;
{$ENDIF}
end;

function FindType(const AName : string; out AType : TRttiType) : Boolean;
var
  LType : TRttiType;
begin
  AType := Context.FindType(AName);
  if not Assigned(AType) then
  begin
    for LType in Context.GetTypes do
    begin
      if SameText(LType.Name, AName) then
      begin
        AType := LType;
        Break;
      end;
    end;
  end;
  Result := Assigned(AType);
end;

function FindType(const AGuid : TGUID; out AType : TRttiType) : Boolean;
var
  LType : TRttiType;
begin
  AType := nil;
  for LType in Context.GetTypes do
  begin
    if (LType is TRttiInterfaceType)
      and IsEqualGUID(TRttiInterfaceType(LType).GUID, AGuid) then
    begin
      AType := LType;
      Break;
    end;
  end;
  Result := Assigned(AType);
end;

function GetRttiType(AClass : TClass) : TRttiType;
begin
  Result := Context.GetType(AClass);
end;

function GetRttiType(ATypeInfo : PTypeInfo) : TRttiType;
begin
  Result := Context.GetType(ATypeInfo);
end;

function GetRttiTypes : TArray<TRttiType>;
begin
  Result := Context.GetTypes();
end;

function IsClassCovariantTo(ThisClass, OtherClass : TClass) : Boolean;
var
  LType : TRttiType;
begin
  LType := Context.GetType(ThisClass);
  Result := Assigned(LType) and LType.IsCovariantTo(OtherClass.ClassInfo);
end;

function IsTypeCovariantTo(ThisType, OtherType : PTypeInfo) : Boolean;
var
  LType : TRttiType;
begin
  LType := Context.GetType(ThisType);
  Result := Assigned(LType) and LType.IsCovariantTo(OtherType);
end;

function MergeStrings(Values : TStringDynArray; const Delimiter : string) : string;
var
  i : Integer;
begin
  result := '';
  for i := Low(Values) to High(Values) do
  begin
    if i = 0 then
      Result := Values[i]
    else
      Result := Result + Delimiter + Values[i];
  end;
end;

function TryGetRttiType(AClass : TClass; out AType : TRttiType) : Boolean; overload;
begin
  AType := Context.GetType(AClass);
  Result := Assigned(AType);
end;

function TryGetRttiType(ATypeInfo : PTypeInfo; out AType : TRttiType) : Boolean; overload;
begin
  AType := Context.GetType(ATypeInfo);
  Result := Assigned(AType);
end;

function StripUnitName(const s : string) : string;
begin
  Result := ReplaceText(s, 'System.', '');
end;

{$IFDEF DELPHI_2010}
function SplitString(const S : string; const Delimiters : string) : TStringDynArray;
var
  StartIdx : Integer;
  FoundIdx : Integer;
  SplitPoints : Integer;
  CurrentSplit : Integer;
  i : Integer;
begin
  Result := nil;

  if S <> '' then
  begin
    SplitPoints := 0;
    for i := 1 to Length(S) do
      if IsDelimiter(Delimiters, S, i) then
        Inc(SplitPoints);

    SetLength(Result, SplitPoints + 1);

    StartIdx := 1;
    CurrentSplit := 0;
    repeat
      FoundIdx := FindDelimiter(Delimiters, S, StartIdx);
      if FoundIdx <> 0 then
      begin
        Result[CurrentSplit] := Copy(S, StartIdx, FoundIdx - StartIdx);
        Inc(CurrentSplit);
        StartIdx := FoundIdx + 1;
      end;
    until CurrentSplit = SplitPoints;

    Result[SplitPoints] := Copy(S, StartIdx, Length(S) - StartIdx + 1);
  end;
end;
{$ENDIF}

function Supports(const Instance : TValue; const IID : TGUID; out Intf) : Boolean; overload;
begin
  if Instance.Kind in [tkClass, tkInterface] then
  begin
    Result := Supports(Instance.ToObject, IID, Intf);
  end
  else
  begin
    Result := False;
  end;
end;

function CompareValue(const Left, Right : TValue) : Integer;
begin
  if Left.IsOrdinal and Right.IsOrdinal then
  begin
    Result := {$IFDEF USE_NS}System.Math.{$ENDIF}CompareValue(Left.AsOrdinal, Right.AsOrdinal);
  end
  else if Left.IsFloat and Right.IsFloat then
  begin
    Result := {$IFDEF USE_NS}System.Math.{$ENDIF}CompareValue(Left.AsFloat, Right.AsFloat);
  end
  else if Left.IsString and Right.IsString then
  begin
    Result := {$IFDEF USE_NS}System.SysUtils.{$ENDIF}CompareStr(Left.AsString, Right.AsString);
  end
  else
  begin
    Result := 0;
  end;
end;

function SameValue(const Left, Right : TValue) : Boolean;
begin
  if Left.IsNumeric and Right.IsNumeric then
  begin
    if Left.IsOrdinal then
    begin
      if Right.IsOrdinal then
      begin
        Result := Left.AsOrdinal = Right.AsOrdinal;
      end
      else if Right.IsSingle then
      begin
        Result := {$IFDEF USE_NS}System.Math.{$ENDIF}SameValue(Left.AsOrdinal, Right.AsSingle);
      end
      else if Right.IsDouble then
      begin
        Result := {$IFDEF USE_NS}System.Math.{$ENDIF}SameValue(Left.AsOrdinal, Right.AsDouble);
      end
      else
      begin
        Result := {$IFDEF USE_NS}System.Math.{$ENDIF}SameValue(Left.AsOrdinal, Right.AsExtended);
      end;
    end
    else if Left.IsSingle then
    begin
      if Right.IsOrdinal then
      begin
        Result := {$IFDEF USE_NS}System.Math.{$ENDIF}SameValue(Left.AsSingle, Right.AsOrdinal);
      end
      else if Right.IsSingle then
      begin
        Result := {$IFDEF USE_NS}System.Math.{$ENDIF}SameValue(Left.AsSingle, Right.AsSingle);
      end
      else if Right.IsDouble then
      begin
        Result := {$IFDEF USE_NS}System.Math.{$ENDIF}SameValue(Left.AsSingle, Right.AsDouble);
      end
      else
      begin
        Result := {$IFDEF USE_NS}System.Math.{$ENDIF}SameValue(Left.AsSingle, Right.AsExtended);
      end;
    end
    else if Left.IsDouble then
    begin
      if Right.IsOrdinal then
      begin
        Result := {$IFDEF USE_NS}System.Math.{$ENDIF}SameValue(Left.AsDouble, Right.AsOrdinal);
      end
      else if Right.IsSingle then
      begin
        Result := {$IFDEF USE_NS}System.Math.{$ENDIF}SameValue(Left.AsDouble, Right.AsSingle);
      end
      else if Right.IsDouble then
      begin
        Result := {$IFDEF USE_NS}System.Math.{$ENDIF}SameValue(Left.AsDouble, Right.AsDouble);
      end
      else
      begin
        Result := {$IFDEF USE_NS}System.Math.{$ENDIF}SameValue(Left.AsDouble, Right.AsExtended);
      end;
    end
    else
    begin
      if Right.IsOrdinal then
      begin
        Result := {$IFDEF USE_NS}System.Math.{$ENDIF}SameValue(Left.AsExtended, Right.AsOrdinal);
      end
      else if Right.IsSingle then
      begin
        Result := {$IFDEF USE_NS}System.Math.{$ENDIF}SameValue(Left.AsExtended, Right.AsSingle);
      end
      else if Right.IsDouble then
      begin
        Result := {$IFDEF USE_NS}System.Math.{$ENDIF}SameValue(Left.AsExtended, Right.AsDouble);
      end
      else
      begin
        Result := {$IFDEF USE_NS}System.Math.{$ENDIF}SameValue(Left.AsExtended, Right.AsExtended);
      end;
    end;
  end
  else if Left.IsString and Right.IsString then
  begin
    Result := Left.AsString = Right.AsString;
  end
  else if Left.IsClass and Right.IsClass then
  begin
    Result := Left.AsClass = Right.AsClass;
  end
  else if Left.IsObject and Right.IsObject then
  begin
    Result := Left.AsObject = Right.AsObject;
  end
  else if Left.IsPointer and Right.IsPointer then
  begin
    Result := Left.AsPointer = Right.AsPointer;
  end
  else if Left.IsVariant and Right.IsVariant then
  begin
    Result := Left.AsVariant = Right.AsVariant;
  end
  else if Left.TypeInfo = Right.TypeInfo then
  begin
    Result := (Left.DataSize = Right.DataSize)
      and CompareMem(Left.GetReferenceToRawData, Right.GetReferenceToRawData, Left.DataSize);
  end
  else
  begin
    Result := False;
  end;
end;

{ TArrayHelper }

class function TArrayHelper.Concat<T>(const Arrays : array of TArray<T>) : TArray<T>;
var
  i, k, LIndex, LLength : Integer;
begin
  LLength := 0;
  for i := 0 to High(Arrays) do
    Inc(LLength, Length(Arrays[i]));
  SetLength(Result, LLength);
  LIndex := 0;
  for i := 0 to High(Arrays) do
  begin
    for k := 0 to High(Arrays[i]) do
    begin
      Result[LIndex] := Arrays[i][k];
      Inc(LIndex);
    end;
  end;
end;

{$IFDEF DELPHI_2010}
class function TArrayHelper.ToArray<T>(Enumerable : TEnumerable<T>; Count : Integer) : TArray<T>;
var
  LItem : T;
begin
  SetLength(Result, Count);
  Count := 0;
  for LItem in Enumerable do
  begin
    Result[Count] := LItem;
    Inc(Count);
  end;
end;
{$ENDIF}

class function TArrayHelper.Create<T>(const a, b : T) : TArray<T>;
begin
  SetLength(result, 2);
  result[0] := a;
  result[1] := b;
end;

class procedure TArrayHelper.Delete<T>(var source : TArray<T>; index, count : integer);
var
  len : integer;
  i : integer;
begin
  len := Length(source);
  if (index >= 0) and (index < len) and (count > 0) then
  begin
    if count > len - index then
      count := len - index;
    for i := index to len - count - 1 do
      source[i] := source[i + count];
    SetLength(source, len - count);
  end;
end;

{ TObjectHelper }

function TObjectHelper.GetField(const AName : string) : TRttiField;
var
  LType : TRttiType;
begin
  Result := nil;
  if TryGetType(LType) then
    Result := LType.GetField(AName);
end;

function TObjectHelper.GetFields : TArray<TRttiField>;
var
  LType : TRttiType;
begin
  Result := nil;
  if TryGetType(LType) then
    Result := LType.GetFields();
end;

function TObjectHelper.GetMember(const AName : string) : TRttiMember;
var
  LType : TRttiType;
begin
  Result := nil;
  if TryGetType(LType) then
    Result := LType.GetMember(AName);
end;

function TObjectHelper.GetMethod(const AName : string) : TRttiMethod;
var
  LType : TRttiType;
begin
  Result := nil;
  if TryGetType(LType) then
    try
      Result := LType.GetMethod(AName);
    except
      Result := nil;
    end;
end;

function TObjectHelper.GetMethod(ACodeAddress : Pointer) : TRttiMethod;
var
  LType : TRttiType;
begin
  Result := nil;
  if TryGetType(LType) then
    Result := LType.GetMethod(ACodeAddress);
end;

function TObjectHelper.GetMethods : TArray<TRttiMethod>;
var
  LType : TRttiType;
begin
  Result := nil;
  if TryGetType(LType) then
    Result := LType.GetMethods();
end;

function TObjectHelper.GetProperties : TArray<TRttiProperty>;
var
  LType : TRttiType;
begin
  Result := nil;
  if TryGetType(LType) then
    Result := LType.GetProperties();
end;

function TObjectHelper.GetProperty(const AName : string) : TRttiProperty;
var
  LType : TRttiType;
  //  LParent: TObject;
begin
  Result := nil;
  if TryGetType(LType) then
    Result := LType.GetProperty(AName);
  {
   if not Assigned(Result) and (Self is TComponent) then
   begin
     LParent := TFramework.GetParent(TComponent(Self));
     if Assigned(LParent) then
     begin
       Result := LParent.GetProperty(AName);
     end;
   end;
   }
end;

function TObjectHelper.GetType : TRttiType;
begin
  TryGetType(Result);
end;

function TObjectHelper.HasField(const AName : string) : Boolean;
begin
  Result := GetField(AName) <> nil;
end;

function TObjectHelper.HasMethod(const AName : string) : Boolean;
begin
  Result := GetMethod(AName) <> nil;
end;

function TObjectHelper.HasProperty(const AName : string) : Boolean;
begin
  Result := GetProperty(AName) <> nil;
end;

{$IF CompilerVersion < 23}
class function TObjectHelper.QualifiedClassName : string;
var
  LUnitName : string;
begin
  LUnitName := UnitName;
  if LUnitName = '' then
    Result := ClassName
  else
    Result := LUnitName + '.' + ClassName;
end;
{$IFEND}

function TObjectHelper.TryGetField(const AName : string;
  out AField : TRttiField) : Boolean;
begin
  AField := GetField(AName);
  Result := Assigned(AField);
end;

function TObjectHelper.TryGetMember(const AName : string;
  out AMember : TRttiMember) : Boolean;
begin
  AMember := GetMember(AName);
  Result := Assigned(AMember);
end;

function TObjectHelper.TryGetMethod(ACodeAddress : Pointer;
  out AMethod : TRttiMethod) : Boolean;
begin
  AMethod := GetMethod(ACodeAddress);
  Result := Assigned(AMethod);
end;

function TObjectHelper.TryGetMethod(const AName : string;
  out AMethod : TRttiMethod) : Boolean;
begin
  AMethod := GetMethod(AName);
  Result := Assigned(AMethod);
end;

function TObjectHelper.TryGetProperty(const AName : string;
  out AProperty : TRttiProperty) : Boolean;
begin
  AProperty := GetProperty(AName);
  Result := Assigned(AProperty);
end;

function TObjectHelper.TryGetType(out AType : TRttiType) : Boolean;
begin
  Result := False;
  AType := nil;
  if Assigned(Self) then
  begin
    AType := Context.GetType(ClassInfo);
    Result := Assigned(AType);
  end;
end;

{ TRttiFieldHelper }

function TRttiFieldHelper.TryGetValue(Instance : Pointer;
  out Value : TValue) : Boolean;
begin
  try
    Value := GetValue(Instance);
    Result := True;
  except
    Value := TValue.Empty;
    Result := False;
  end;
end;

{ TRttiInstanceTypeHelper }

{$IF CompilerVersion < 23}
function TRttiInstanceTypeHelper.GetDeclaredImplementedInterfaces : TArray<TRttiInterfaceType>;
var
  LInterfaceTable : PInterfaceTable;
  p : PPointer;
  i : Integer;
  LTypeInfo : PTypeInfo;
begin
  LInterfaceTable := PPointer(PByte(MetaclassType) + vmtIntfTable)^;

  if Assigned(LInterfaceTable) then
  begin
    p := @LInterfaceTable.Entries[LInterfaceTable.EntryCount];
    SetLength(Result, LInterfaceTable.EntryCount);

    for i := 0 to LInterfaceTable.EntryCount - 1 do
    begin
      LTypeInfo := PPTypeInfo(p^)^;
      Result[i] := GetRttiType(LTypeInfo) as TRttiInterfaceType;
      Inc(p);
    end;
  end;
end;

function TRttiInstanceTypeHelper.GetImplementedInterfaces : TArray<TRttiInterfaceType>;
var
  LCount : Integer;
  LInterfaces : TArray<TArray<TRttiInterfaceType>>;
  LType : TRttiInstanceType;
begin
  LCount := 0;
  LType := Self;
  repeat
    Inc(LCount);
    LType := LType.BaseType.AsInstance;
  until not Assigned(LType);

  SetLength(LInterfaces, LCount);
  LCount := 0;
  LType := Self;
  repeat
    LInterfaces[LCount] := LType.GetDeclaredImplementedInterfaces;
    Inc(LCount);
    LType := LType.BaseType.AsInstance;
  until not Assigned(LType);

  Result := TArrayHelper.Concat<TRttiInterfaceType>(LInterfaces);
end;
{$IFEND}

{ TRttiInvokableTypeHelper }

{$IFDEF DELPHI_XE2_UP}
function TRttiInvokableTypeHelper.GetParameterCount : Integer;
begin
  Result := Length(GetParameters());
end;
{$ENDIF}

{ TRttiMemberHelper }

function TRttiMemberHelper.GetMemberIsReadable : Boolean;
begin
  Result := True;
  if Self is TRttiField then
  begin
    Result := True;
  end
  else if Self is TRttiProperty then
  begin
    Result := TRttiProperty(Self).IsReadable;
  end
  else if Self is TRttiMethod then
  begin
    Result := True;
  end;
end;

function TRttiMemberHelper.GetMemberIsWritable : Boolean;
begin
  Result := False;
  if Self is TRttiField then
  begin
    Result := True;
  end
  else if Self is TRttiProperty then
  begin
    Result := TRttiProperty(Self).IsWritable;
  end;
end;

function TRttiMemberHelper.GetMemberRttiType : TRttiType;
begin
  Result := nil;
  if Self is TRttiField then
  begin
    Result := TRttiField(Self).FieldType;
  end
  else if Self is TRttiProperty then
  begin
    Result := TRttiProperty(Self).PropertyType;
  end
  else if Self is TRttiMethod then
  begin
    Result := TRttiMethod(Self).ReturnType;
  end;
end;

{ TRttiMethodHelper }

function TRttiMethodHelper.Format(const Args : array of TValue;
  SkipSelf : Boolean) : string;
begin
  Result := StripUnitName(Parent.Name) + '.' + Name + '(';
  if SkipSelf then
  begin
    if Length(Args) > 1 then
      Result := Result + TValue.ToString(Args[1]);
  end
  else if Length(Args) > 0 then
    Result := Result + TValue.ToString(Args[0]);
  Result := Result + ')';
end;

function TRttiMethodHelper.GetParameterCount : Integer;
begin
  Result := Length(GetParameters());
end;

{ TRttiObjectHelper }

function TRttiObjectHelper.GetAttributeOfType<T> : T;
var
  LAttribute : TCustomAttribute;
begin
  Result := Default(T);
  for LAttribute in GetAttributes do
  begin
    if LAttribute.InheritsFrom(T) then
    begin
      Result := T(LAttribute);
      Break;
    end;
  end;
end;

function TRttiObjectHelper.GetAttributesOfType<T> : TArray<T>;
var
  LAttribute : TCustomAttribute;
begin
  SetLength(Result, 0);
  for LAttribute in GetAttributes do
  begin
    if LAttribute.InheritsFrom(T) then
    begin
      SetLength(Result, Length(Result) + 1);
      Result[High(Result)] := T(LAttribute);
    end;
  end;
end;

function TRttiObjectHelper.HasAttributeOfType<T> : Boolean;
begin
  Result := GetAttributeOfType<T> <> nil;
end;

function TRttiObjectHelper.TryGetAttributeOfType<T>(out AAttribute : T) : Boolean;
begin
  AAttribute := GetAttributeOfType<T>;
  Result := Assigned(AAttribute);
end;

{ TRttiParameterHelper }

class function TRttiParameterHelper.Equals(const Left,
  Right : TArray<TRttiParameter>) : Boolean;
var
  i : Integer;
begin
  Result := Length(Left) = Length(Right);
  if Result then
  begin
    for i := Low(Left) to High(Left) do
    begin
      if Left[i].ParamType <> Right[i].ParamType then
      begin
        Result := False;
        Break;
      end;
    end;
  end;
end;

{ TRttiPropertyHelper }

function TRttiPropertyHelper.TryGetValue(Instance : Pointer;
  out Value : TValue) : Boolean;
begin
  try
    if IsReadable then
    begin
      Value := GetValue(Instance);
      Result := True;
    end
    else
    begin
      Result := False;
    end;
  except
    Value := TValue.Empty;
    Result := False;
  end;
end;

function TRttiPropertyHelper.TrySetValue(Instance : Pointer;
  Value : TValue) : Boolean;
var
  LValue : TValue;
begin
  Result := Value.TryConvert(PropertyType.Handle, LValue);
  if Result then
  begin
    SetValue(Instance, LValue);
  end;
end;

{ TRttiTypeHelper }

function TRttiTypeHelper.GetAsInterface : TRttiInterfaceType;
begin
  Result := Self as TRttiInterfaceType;
end;

function TRttiTypeHelper.GetAttributesOfType<T> : TArray<T>;
var
  LAttribute : TCustomAttribute;
begin
  SetLength(Result, 0);
  for LAttribute in GetAttributes do
  begin
    if LAttribute.InheritsFrom(T) then
    begin
      SetLength(Result, Length(Result) + 1);
      Result[High(Result)] := T(LAttribute);
    end;
  end;

  if Assigned(BaseType) then
  begin
    for LAttribute in BaseType.GetAttributesOfType<T> do
    begin
      if LAttribute.InheritsFrom(T) then
      begin
        SetLength(Result, Length(Result) + 1);
        Result[High(Result)] := T(LAttribute);
      end;
    end;
  end;
end;

function TRttiTypeHelper.GetGenericArguments : TArray<TRttiType>;
var
  i : Integer;
  args : TStringDynArray;
begin
  args := SplitString(ExtractGenericArguments(Handle), ',');
  SetLength(Result, Length(args));
  for i := 0 to Pred(Length(args)) do
    FindType(args[i], Result[i]);
end;

function TRttiTypeHelper.GetGenericTypeDefinition(
  const AIncludeUnitName : Boolean = True) : string;
var
  i : Integer;
  args : TStringDynArray;
  s : string;
begin
  args := SplitString(ExtractGenericArguments(Handle), ',');
  for i := Low(args) to High(args) do
  begin
    // naive implementation - but will work in most cases
    if (i = 0) and (Length(args) = 1) then
      args[i] := 'T'
    else
      args[i] := 'T' + IntToStr(Succ(i));
  end;
  if IsPublicType and AIncludeUnitName then
    s := QualifiedName
  else
    s := Name;
{$IFNDEF NEXTGEN}
  Result := Copy(s, 1, Pos('<', s)) + MergeStrings(args, ',') + '>';
{$ELSE}
  Result := s.SubString(0, s.IndexOf('<') + 1) + MergeStrings(args, ',') + '>';
{$ENDIF}
end;

function TRttiTypeHelper.GetIsInterface : Boolean;
begin
  Result := Self is TRttiInterfaceType;
end;

function TRttiTypeHelper.GetMember(const AName : string) : TRttiMember;
var
  LProperty : TRttiProperty;
  LField : TRttiField;
  LMethod : TRttiMethod;
begin
  if TryGetProperty(AName, LProperty) then
  begin
    Result := LProperty;
  end
  else if TryGetField(AName, LField) then
  begin
    Result := LField;
  end
  else if TryGetMethod(AName, LMethod) then
  begin
    Result := LMethod;
  end
  else
  begin
    Result := nil;
  end;
end;

function TRttiTypeHelper.GetMethod(ACodeAddress : Pointer) : TRttiMethod;
var
  LMethod : TRttiMethod;
begin
  Result := nil;
  for LMethod in GetMethods() do
  begin
    if LMethod.CodeAddress = ACodeAddress then
    begin
      Result := LMethod;
      Break;
    end;
  end;
end;

function TRttiTypeHelper.GetMethodCount : Integer;
begin
  Result := Length(GetMethods);
end;

function TRttiTypeHelper.GetProperty(const AName : string) : TRttiProperty;
begin
  Result := inherited GetProperty(AName);

  if not Assigned(Result) then
  begin
    Result := TRttiPropertyExtension.FindByName(Self, AName);
  end;
end;

function TRttiTypeHelper.GetStandardConstructor : TRttiMethod;
var
  LMethod : TRttiMethod;
begin
  Result := nil;
  for LMethod in GetMethods do
  begin
    if LMethod.IsConstructor and (LMethod.ParameterCount = 0) then
    begin
      Result := LMethod;
      Break;
    end;
  end;
end;

function TRttiTypeHelper.InheritsFrom(OtherType : PTypeInfo) : Boolean;
var
  LType : TRttiType;
begin
  Result := Handle = OtherType;

  if not Result then
  begin
    LType := BaseType;
    while Assigned(LType) and not Result do
    begin
      Result := LType.Handle = OtherType;
      LType := LType.BaseType;
    end;
  end;
end;

function TRttiTypeHelper.IsCovariantTo(OtherType : PTypeInfo) : Boolean;
var
  t : TRttiType;
  args, otherArgs : TArray<TRttiType>;
  i : Integer;
begin
  Result := False;
  t := Context.GetType(OtherType);
  if Assigned(t) and IsGenericTypeDefinition then
  begin
    if SameText(GetGenericTypeDefinition, t.GetGenericTypeDefinition)
      or SameText(GetGenericTypeDefinition(False), t.GetGenericTypeDefinition(False)) then
    begin
      Result := True;
      args := GetGenericArguments;
      otherArgs := t.GetGenericArguments;
      for i := Low(args) to High(args) do
      begin
        if args[i].IsInterface and otherArgs[i].IsInterface
          and args[i].InheritsFrom(otherArgs[i].Handle) then
        begin
          Continue;
        end;

        if args[i].IsInstance and otherArgs[i].IsInstance
          and args[i].InheritsFrom(otherArgs[i].Handle) then
        begin
          Continue;
        end;

        Result := False;
        Break;
      end;
    end
    else
    begin
      if Assigned(BaseType) then
      begin
        Result := BaseType.IsCovariantTo(OtherType);
      end;
    end;
  end
  else
  begin
    Result := InheritsFrom(OtherType);
  end;
end;

function TRttiTypeHelper.IsCovariantTo(OtherClass : TClass) : Boolean;
begin
  Result := Assigned(OtherClass) and IsCovariantTo(OtherClass.ClassInfo);
end;

function TRttiTypeHelper.IsGenericTypeDefinition : Boolean;
begin
  Result := Length(GetGenericArguments) > 0;
  if not Result and Assigned(BaseType) then
  begin
    Result := BaseType.IsGenericTypeDefinition;
  end;
end;

function TRttiTypeHelper.IsGenericTypeOf(const BaseTypeName : string) : Boolean;
var
  s : string;
begin
  s := Name;
{$IFNDEF NEXTGEN}
  Result := (Copy(s, 1, Succ(Length(BaseTypeName))) = (BaseTypeName + '<')) and (Copy(s, Length(s), 1) = '>');
{$ELSE}
  Result := (s.SubString(0, Succ(BaseTypeName.Length)) = (BaseTypeName + '<')) and (s.SubString(s.Length - 1, 1) = '>');
{$ENDIF}
end;

function TRttiTypeHelper.IsInheritedFrom(const OtherTypeName : string) : Boolean;
var
  LType : TRttiType;
begin
  Result := SameText(Name, OtherTypeName)
    or (IsPublicType and SameText(QualifiedName, OtherTypeName));

  if not Result then
  begin
    LType := BaseType;
    while Assigned(LType) and not Result do
    begin
      Result := SameText(LType.Name, OtherTypeName)
        or (LType.IsPublicType and SameText(LType.QualifiedName, OtherTypeName));
      LType := LType.BaseType;
    end;
  end;
end;

function TRttiTypeHelper.IsInheritedFrom(OtherType : TRttiType) : Boolean;
var
  LType : TRttiType;
begin
  Result := Self.Handle = OtherType.Handle;

  if not Result then
  begin
    LType := BaseType;
    while Assigned(LType) and not Result do
    begin
      Result := LType.Handle = OtherType.Handle;
      LType := LType.BaseType;
    end;
  end;
end;

function TRttiTypeHelper.MakeGenericType(const TypeArguments : array of PTypeInfo) : TRttiType;
var
  i : Integer;
  args : TStringDynArray;
  s : string;
begin
  if IsPublicType then
  begin
    args := SplitString(ExtractGenericArguments(Handle), ',');
    for i := Low(args) to High(args) do
      args[i] := Context.GetType(TypeArguments[i]).QualifiedName;
{$IFNDEF NEXTGEN}
    s := Copy(QualifiedName, 1, Pos('<', QualifiedName)) + MergeStrings(args, ',') + '>';
{$ELSE}
    s := QualifiedName.SubString(0, QualifiedName.IndexOf('<') + 1) + MergeStrings(args, ',') + '>';
{$ENDIF}
    Result := Context.FindType(s);
  end
  else
    Result := nil;
end;

function TRttiTypeHelper.TryGetConstructor(out AMethod : TRttiMethod) : boolean;
var
  methods : TArray<TRttiMethod>;
  method : TRttiMethod;
  rttiType : TRttiType;
begin
  result := False;
  rttiType := Self;

  while (rttiType <> nil) and (rttiType.Handle <> TypeInfo(TObject)) do
  begin
    methods := rttiType.GetDeclaredMethods;
    for method in methods do
    begin
      if method.IsConstructor and (Length(method.GetParameters) = 0) then
      begin
        AMethod := method;
        Exit(true);
      end;
    end;
    rttiType := rttiType.BaseType;
  end;
end;

function TRttiTypeHelper.TryGetDestructor(out AMethod : TRttiMethod) : boolean;
var
  methods : TArray<TRttiMethod>;
  method : TRttiMethod;
begin
  result := False;
  methods := GetDeclaredMethods;
  for method in methods do
  begin
    if method.IsDestructor then
    begin
      AMethod := method;
      Exit(true);
    end;
  end;
end;

function TRttiTypeHelper.TryGetField(const AName : string;
  out AField : TRttiField) : Boolean;
begin
  AField := GetField(AName);
  Result := Assigned(AField);
end;

function TRttiTypeHelper.TryGetMethod(ACodeAddress : Pointer;
  out AMethod : TRttiMethod) : Boolean;
begin
  AMethod := GetMethod(ACodeAddress);
  Result := Assigned(AMethod);
end;

function TRttiTypeHelper.TryGetMember(const AName : string;
  out AMember : TRttiMember) : Boolean;
begin
  AMember := GetMember(AName);
  Result := Assigned(AMember);
end;

function TRttiTypeHelper.TryGetMethod(const AName : string;
  out AMethod : TRttiMethod) : Boolean;
begin
  AMethod := GetMethod(AName);
  Result := Assigned(AMethod);
end;

function TRttiTypeHelper.TryGetProperty(const AName : string;
  out AProperty : TRttiProperty) : Boolean;
begin
  AProperty := GetProperty(AName);
  Result := Assigned(AProperty);
end;

function TRttiTypeHelper.TryGetStandardConstructor(
  out AMethod : TRttiMethod) : Boolean;
begin
  AMethod := GetStandardConstructor();
  Result := Assigned(AMethod);
end;

{ TValueHelper }

function TValueHelper.AsByte : Byte;
begin
  Result := AsType<Byte>;
end;

function TValueHelper.AsCardinal : Cardinal;
begin
  Result := AsType<Cardinal>;
end;

function TValueHelper.AsCurrency : Currency;
begin
  Result := AsType<Currency>;
end;

function TValueHelper.AsDate : TDate;
begin
  Result := AsType<TDate>;
end;

function TValueHelper.AsDateTime : TDateTime;
begin
  Result := AsType<TDateTime>;
end;

function TValueHelper.AsDouble : Double;
begin
  Result := AsType<Double>;
end;

function TValueHelper.AsFloat : Extended;
begin
  Result := AsType<Extended>;
end;

function TValueHelper.AsPointer : Pointer;
begin
  if Kind in [tkClass, tkInterface] then
    Result := ToObject
  else
    Result := GetReferenceToRawData;
end;

function TValueHelper.AsShortInt : ShortInt;
begin
  Result := AsType<ShortInt>;
end;

function TValueHelper.AsSingle : Single;
begin
  Result := AsType<Single>;
end;

function TValueHelper.AsSmallInt : SmallInt;
begin
  Result := AsType<SmallInt>;
end;

function TValueHelper.AsTime : TTime;
begin
  Result := AsType<TTime>;
end;

function TValueHelper.AsUInt64 : UInt64;
begin
  Result := AsType<UInt64>;
end;

function TValueHelper.AsWord : Word;
begin
  Result := AsType<Word>;
end;

class function TValueHelper.Equals(const Left, Right : TArray<TValue>) : Boolean;
var
  i : Integer;
begin
  Result := Length(Left) = Length(Right);
  if Result then
  begin
    for i := Low(Left) to High(Left) do
    begin
      if not SameValue(Left[i], Right[i]) then
      begin
        Result := False;
        Break;
      end;
    end;
  end;
end;

class function TValueHelper.Equals<T>(const Left, Right : T) : Boolean;
begin
  Result := TEqualityComparer<T>.Default.Equals(Left, Right);
end;

class function TValueHelper.From(ABuffer : Pointer;
  ATypeInfo : PTypeInfo) : TValue;
begin
  TValue.Make(ABuffer, ATypeInfo, Result);
end;

class function TValueHelper.From(AValue : NativeInt;
  ATypeInfo : PTypeInfo) : TValue;
begin
  TValue.Make(AValue, ATypeInfo, Result);
end;

class function TValueHelper.From(AObject : TObject; AClass : TClass) : TValue;
begin
  TValue.Make(NativeInt(AObject), AClass.ClassInfo, Result);
end;

class function TValueHelper.FromBoolean(const Value : Boolean) : TValue;
begin
  Result := TValue.From<Boolean>(Value);
end;

class function TValueHelper.FromFloat(ATypeInfo : PTypeInfo;
  AValue : Extended) : TValue;
begin
  case GetTypeData(ATypeInfo).FloatType of
    ftSingle : Result := TValue.From<Single>(AValue);
    ftDouble : Result := TValue.From<Double>(AValue);
    ftExtended : Result := TValue.From<Extended>(AValue);
    ftComp : Result := TValue.From<Comp>(AValue);
    ftCurr : Result := TValue.From<Currency>(AValue);
  end;
end;

class function TValueHelper.FromString(const Value : string) : TValue;
begin
  Result := TValue.From<string>(Value);
end;

class function TValueHelper.FromVarRec(const Value : TVarRec) : TValue;
begin
  case Value.VType of
    vtInteger : Result := Value.VInteger;
    vtBoolean : Result := Value.VBoolean;
{$IFNDEF NEXTGEN}
    vtChar : Result := string(Value.VChar);
{$ENDIF}
    vtExtended : Result := Value.VExtended^;
{$IFNDEF NEXTGEN}
    vtString : Result := string(Value.VString^);
{$ENDIF}
    vtPointer : Result := TValue.From<Pointer>(Value.VPointer);
{$IFNDEF NEXTGEN}
    vtPChar : Result := string(Value.VPChar);
{$ENDIF}
    vtObject : Result := Value.VObject;
    vtClass : Result := Value.VClass;
    vtWideChar : Result := string(Value.VWideChar);
    vtPWideChar : Result := string(Value.VPWideChar);
{$IFNDEF NEXTGEN}
    vtAnsiString : Result := string(AnsiString(Value.VAnsiString));
{$ENDIF}
    vtCurrency : Result := Value.VCurrency^;
    vtVariant : Result := TValue.FromVariant(Value.VVariant^);
    vtInterface : Result := TValue.From<IInterface>(IInterface(Value.VInterface));
    vtWideString :
{$IFNDEF NEXTGEN}
      Result := WideString(Value.VWideString);
{$ELSE}
      Result := string(Value.VWideString);
{$ENDIF}
    vtInt64 : Result := Value.VInt64^;
    vtUnicodeString : Result := string(Value.VUnicodeString);
  end;
end;

function TValueHelper.GetRttiType : TRttiType;
begin
  Result := Context.GetType(TypeInfo);
end;

function TValueHelper.IsBoolean : Boolean;
begin
  Result := TypeInfo = System.TypeInfo(Boolean);
end;

function TValueHelper.IsByte : Boolean;
begin
  Result := TypeInfo = System.TypeInfo(Byte);
end;

function TValueHelper.IsCardinal : Boolean;
begin
  Result := TypeInfo = System.TypeInfo(Cardinal);
{$IFNDEF CPUX64}
  Result := Result or (TypeInfo = System.TypeInfo(NativeUInt));
{$ENDIF}
end;

function TValueHelper.IsCurrency : Boolean;
begin
  Result := TypeInfo = System.TypeInfo(Currency);
end;

function TValueHelper.IsDate : Boolean;
begin
  Result := TypeInfo = System.TypeInfo(TDate);
end;

function TValueHelper.IsDateTime : Boolean;
begin
  Result := TypeInfo = System.TypeInfo(TDateTime);
end;

function TValueHelper.IsDouble : Boolean;
begin
  Result := TypeInfo = System.TypeInfo(Double);
end;

function TValueHelper.IsFloat : Boolean;
begin
  Result := Kind = tkFloat;
end;

function TValueHelper.IsInstance : Boolean;
begin
  Result := Kind in [tkClass, tkInterface];
end;

function TValueHelper.IsInt64 : Boolean;
begin
  Result := TypeInfo = System.TypeInfo(Int64);
{$IFDEF CPUX64}
  Result := Result or (TypeInfo = System.TypeInfo(NativeInt));
{$ENDIF}
end;

function TValueHelper.IsInteger : Boolean;
begin
  Result := TypeInfo = System.TypeInfo(Integer);
{$IFNDEF CPUX64}
  Result := Result or (TypeInfo = System.TypeInfo(NativeInt));
{$ENDIF}
end;

function TValueHelper.IsInterface : Boolean;
begin
  Result := Assigned(TypeInfo) and (TypeInfo.Kind = tkInterface);
end;

function TValueHelper.IsNumeric : Boolean;
begin
  Result := Kind in [tkInteger, tkChar, tkEnumeration, tkFloat, tkWChar, tkInt64];
end;

function TValueHelper.IsPointer : Boolean;
begin
  Result := Kind = tkPointer;
end;

function TValueHelper.IsShortInt : Boolean;
begin
  Result := TypeInfo = System.TypeInfo(ShortInt);
end;

function TValueHelper.IsSingle : Boolean;
begin
  Result := TypeInfo = System.TypeInfo(Single);
end;

function TValueHelper.IsSmallInt : Boolean;
begin
  Result := TypeInfo = System.TypeInfo(SmallInt);
end;

function TValueHelper.IsString : Boolean;
begin
  Result := Kind in [tkChar, tkString, tkWChar, tkLString, tkWString, tkUString];
end;

function TValueHelper.IsTime : Boolean;
begin
  Result := TypeInfo = System.TypeInfo(TTime);
end;

function TValueHelper.IsUInt64 : Boolean;
begin
  Result := TypeInfo = System.TypeInfo(UInt64);
{$IFDEF CPUX64}
  // NativeUInt, not NativeInt: this is the unsigned test, and NativeInt is what IsInt64 uses.
  Result := Result or (TypeInfo = System.TypeInfo(NativeUInt));
{$ENDIF}
end;

function TValueHelper.IsVariant : Boolean;
begin
  Result := TypeInfo = System.TypeInfo(Variant);
end;

function TValueHelper.IsWord : Boolean;
begin
  Result := TypeInfo = System.TypeInfo(Word);
end;

function TValueHelper.ToObject : TObject;
begin
  if IsInterface then
    Result := AsInterface as TObject
  else
    Result := AsObject;
end;

class function TValueHelper.ToString(const Values : array of TValue) : string;
var
  i : Integer;
begin
  Result := '';
  for i := Low(Values) to High(Values) do
  begin
    if i > Low(Values) then
      Result := Result + ', ';

    if Values[i].IsString then
      Result := Result + '''' + TValue.ToString(Values[i]) + ''''
    else
      Result := Result + TValue.ToString(Values[i]);
  end;
end;

function TValueHelper.ToVarRec(var AStorage : TValue) : TVarRec;
begin
  // A TVarRec cannot own memory, so every pointer in the result refers into AStorage, never into a temporary.
  AStorage := Self;
  case Kind of
    tkInteger :
      begin
        Result.VType := vtInteger;
        Result.VInteger := AsInteger;
      end;
{$IFNDEF NEXTGEN}
    tkChar :
      begin
        Result.VType := vtChar;
        Result.VChar := AsType<AnsiChar>;
      end;
{$ENDIF}
    tkWChar :
      begin
        Result.VType := vtWideChar;
        Result.VWideChar := AsType<WideChar>;
      end;
    tkEnumeration :
      begin
        if IsBoolean then
        begin
          Result.VType := vtBoolean;
          Result.VBoolean := AsBoolean;
        end
        else
        begin
          Result.VType := vtInteger;
          Result.VInteger := AsInteger;
        end;
      end;
    tkInt64 :
      begin
        Result.VType := vtInt64;
        Result.VInt64 := AStorage.GetReferenceToRawData;
      end;
    tkFloat :
      begin
        if IsCurrency then
        begin
          Result.VType := vtCurrency;
          Result.VCurrency := AStorage.GetReferenceToRawData;
        end
        else
        begin
          // vtExtended is read as an Extended (10 bytes on Win32), so a Single or Double is widened first.
          AStorage := TValue.From<Extended>(AsExtended);
          Result.VType := vtExtended;
          Result.VExtended := AStorage.GetReferenceToRawData;
        end;
      end;
    tkString, tkLString, tkWString, tkUString :
      begin
        AStorage := TValue.From<string>(AsString);
        Result.VType := vtUnicodeString;
        Result.VUnicodeString := PPointer(AStorage.GetReferenceToRawData)^;
      end;
    tkClass, tkInterface :
      begin
        AStorage := TValue.From<string>(ToObject.ToString);
        Result.VType := vtUnicodeString;
        Result.VUnicodeString := PPointer(AStorage.GetReferenceToRawData)^;
      end;
  else
    raise EInvalidCast.CreateFmt('Cannot convert a %s value to a TVarRec', [GetEnumName(System.TypeInfo(TTypeKind), Ord(Kind))]);
  end;
end;

class function TValueHelper.ToVarRecs(
  const Values : array of TValue; out AStorage : TArray<TValue>) : TArray<TVarRec>;
var
  i : Integer;
begin
  SetLength(Result, Length(Values));
  SetLength(AStorage, Length(Values));
  for i := Low(Values) to High(Values) do
    Result[i] := Values[i].ToVarRec(AStorage[i]);
end;

class function TValueHelper.ToString(const Value : TValue) : string;
var
  LInterface : IInterface;
  LObject : TObject;
begin
  case Value.Kind of
    tkFloat :
      begin
        if Value.IsDate then
        begin
          Result := DateToStr(Value.AsDate);
        end
        else if Value.IsDateTime then
        begin
          Result := DateTimeToStr(Value.AsDateTime);
        end
        else if Value.IsTime then
        begin
          Result := TimeToStr(Value.AsTime);
        end
        else
        begin
          Result := Value.ToString;
        end;
      end;
    tkClass :
      begin
        LObject := Value.AsObject;
        if not Assigned(LObject) then
          Exit('nil');
        Result := Format('%s($%x)', [StripUnitName(LObject.ClassName),
            NativeInt(LObject)]);
      end;
    tkInterface :
      begin
        LInterface := Value.AsInterface;
        if not Assigned(LInterface) then
          Exit('nil');
        LObject := LInterface as TObject;
        Result := Format('%s($%x) as %s', [StripUnitName(LObject.ClassName),
            NativeInt(LInterface), StripUnitName(GetTypeName(Value.TypeInfo))]);
      end
  else
    Result := Value.ToString;
  end;
end;

function TValueHelper.TryConvert(ATypeInfo : PTypeInfo;
  out AResult : TValue) : Boolean;
begin
  Result := False;

  if ATypeInfo = System.TypeInfo(TValue) then
  begin
    AResult := Self;
    Exit(True);
  end;

  if Assigned(ATypeInfo) then
  begin
    Result := Conversions[Kind, ATypeInfo.Kind](Self, ATypeInfo, AResult);

    if not Result then
    begin
      case Kind of
        tkRecord : Result := ConvNullable2Any(Self, ATypeInfo, AResult);
{$IFDEF VER210}
        // workaround for bug in RTTI.pas (fixed in XE)
        tkUnknown :
          begin
            case ATypeInfo.Kind of
              tkInteger, tkEnumeration, tkChar, tkWChar, tkInt64 :
                begin
                  AResult := TValue.FromOrdinal(ATypeInfo, 0);
                  Result := True;
                end;
              tkFloat :
                begin
                  AResult := TValue.From<Extended>(0);
                  Result := True;
                end;
              tkUString :
                begin
                  AResult := TValue.FromString('');
                  Result := True;
                end;
            end;
          end;
{$ENDIF}
      end;
      case ATypeInfo.Kind of
        tkRecord : Result := ConvAny2Nullable(Self, ATypeInfo, AResult);
      end;
    end;
    //Between numeric types the converters above have decided: they refuse a value that does not fit, and TryCast
    //would truncate it instead (Integer 300 to Byte 44).
    if (not Result) and not ((Kind in [tkInteger, tkChar, tkWChar, tkEnumeration, tkInt64, tkFloat])
      and (ATypeInfo.Kind in [tkInteger, tkChar, tkWChar, tkEnumeration, tkInt64])) then
    begin
      Result := TryCast(ATypeInfo, AResult);
    end;
  end;
end;

function TValueHelper.TryConvert<T>(out AResult : TValue) : Boolean;
begin
  Result := TryConvert(System.TypeInfo(T), AResult);
end;

type
  // Declare compatible members of TRttiObject in System.Rtti.pas
  TRttiObjectFieldRef = class abstract
  public
    FHandle : Pointer;
    FRttiDataSize : Integer;
    FPackage : Pointer {TRttiPackage};
    FParent : Pointer {TRttiObject};
    FAttributeGetter : Pointer {TFunc<TArray<TCustomAttribute>>};
  end;

  TRttiObjectAccess = class helper for TRttiObject
  public
    procedure Init(Parent : TRttiType; PropInfo : {$IFDEF DELPHI_XE3_UP}PPropInfoExt{$ELSE}PPropInfo{$ENDIF});
  end;

procedure TRttiObjectAccess.Init(Parent : TRttiType; PropInfo : {$IFDEF DELPHI_XE3_UP}PPropInfoExt{$ELSE}PPropInfo{$ENDIF});
const
{$IFDEF AUTOREFCOUNT}
  FHANDLE_OFFSET    = (SizeOf(Pointer) * 2);
  FPARENT_OFFSET    = (SizeOf(Pointer) * 3);
{$ELSE}
  FHANDLE_OFFSET    = (SizeOf(Pointer) * 1);
  FPARENT_OFFSET    = (SizeOf(Pointer) * 2);
{$ENDIF}
begin
  //if TRttiObject.InstanceSize <> TRttiObjectFieldRef.InstanceSize then
  //  assert;
  TRttiObjectFieldRef(Self).FParent := Parent;
  TRttiObjectFieldRef(Self).FHandle := PropInfo;
end;

{$IFDEF DELPHI_XE3_UP}
{ TPropInfoExt }

function TPropInfoExt.NameFld : TTypeInfoFieldAccessor;
begin
  Result.SetData(@NameLength);
end;

function TPropInfoExt.Tail : PPropInfoExt;
begin
  Result := PPropInfoExt(NameFld.Tail);
end;
{$ENDIF}
{ TRttiPropertyExtension }

class constructor TRttiPropertyExtension.Create;
begin
  FRegister := TObjectDictionary < TPair<PTypeInfo, string>, TRttiPropertyExtension > .Create([doOwnsValues]);
  FPatchedClasses := TDictionary<TClass, TClass>.Create;

  TRttiPropertyExtension.InitVirtualMethodTable;
end;

class destructor TRttiPropertyExtension.Destroy;
var
  LClass : TClass;
  LPointer : Pointer;
begin
  //Destroy the instances first. FRegister owns them, and each one dispatches through a
  //patched VMT, so releasing that memory beforehand meant destroying them through freed
  //memory.
  FRegister.Free;

  for LClass in FPatchedClasses.Values do
  begin
    LPointer := PByte(LClass) + vmtSelfPtr;
    FreeMem(LPointer);
  end;

  FPatchedClasses.Free;
end;

constructor TRttiPropertyExtension.Create(Parent : PTypeInfo; const Name : string; PropertyType : PTypeInfo);
{$IFDEF DELPHI_XE3_UP}
var
  M : TMarshaller;
{$ENDIF}
begin
  inherited Create;
  FPropInfo.PropType := Pointer(NativeInt(PropertyType) - SizeOf(PTypeInfo));
{$IFNDEF DELPHI_XE3_UP}
  FPropInfo.Name := ShortString(Name);
{$ELSE}
  if Name.Length > 255 then
    FPropInfo.NameLength := 255
  else
    FPropInfo.NameLength := Name.Length;
  Move(M.AsAnsi(Name).ToPointer^, FPropInfo.NameData[0], FPropInfo.NameLength);
{$ENDIF}
  Init(GetRttiType(Parent), @FPropInfo);

  FRegister.Add(TPair<PTypeInfo, string>.Create(Parent, Name), Self);

  PPointer(Self)^ := FPatchedClasses[Self.ClassType];
end;

function TRttiPropertyExtension.DoGetValue(Instance : Pointer) : TValue;
begin
  Result := FGetter(Instance);
end;

function TRttiPropertyExtension.DoGetValueStub(Instance : Pointer) : TValue;
begin
  Result := DoGetValue(Instance);
end;

procedure TRttiPropertyExtension.DoSetValue(Instance : Pointer;
  const AValue : TValue);
begin
  FSetter(Instance, AValue);
end;

procedure TRttiPropertyExtension.DoSetValueStub(Instance : Pointer;
  const AValue : TValue);
begin
  DoSetValue(Instance, AValue);
end;

class function TRttiPropertyExtension.FindByName(Parent : TRttiType;
  const PropertyName : string) : TRttiPropertyExtension;
var
  LPropertyExtension : TRttiPropertyExtension;
begin
  for LPropertyExtension in FRegister.Values do
  begin
    if (LPropertyExtension.Parent = Parent) and SameText(LPropertyExtension.Name, PropertyName) then
    begin
      Result := LPropertyExtension;
      Exit;
    end;
  end;

  if Assigned(Parent.BaseType) then
    Result := FindByName(Parent.BaseType, PropertyName)
  else
    Result := nil;
end;

class function TRttiPropertyExtension.FindByName(
  const FullPropertyName : string) : TRttiPropertyExtension;
var
  LScope : string;
  LName : string;
  LProp : TRttiPropertyExtension;
begin
  Result := nil;
{$IFNDEF NEXTGEN}
  LScope := Copy(FullPropertyName, 1, LastDelimiter('.', FullPropertyName) - 1);
  LName := Copy(FullPropertyName, LastDelimiter('.', FullPropertyName) + 1);
  for LProp in FRegister.Values do
  begin
    if SameText(LProp.Name, LName)
      and EndsText(LScope, LProp.Parent.AsInstance.MetaclassType.QualifiedClassName) then
    begin
      Result := LProp;
      Break;
    end;
  end;
{$ELSE}
  LScope := FullPropertyName.SubString(0, FullPropertyName.LastDelimiter('.'));
  LName := FullPropertyName.SubString(FullPropertyName.LastDelimiter('.') + 1);
  for LProp in FRegister.Values do
  begin
    if (string.Compare(LProp.Name, LName, [coIgnoreCase]) = 0)
      and LProp.Parent.AsInstance.MetaclassType.QualifiedClassName.EndsWith(LScope, True) then
    begin
      Result := LProp;
      Break;
    end;
  end;
{$ENDIF}
end;

function TRttiPropertyExtension.GetIsReadable : Boolean;
begin
  Result := Assigned(FGetter);
end;

function TRttiPropertyExtension.GetIsReadableStub : Boolean;
begin
  Result := GetIsReadable;
end;

function TRttiPropertyExtension.GetIsWritable : Boolean;
begin
  Result := Assigned(FSetter);
end;

function TRttiPropertyExtension.GetIsWritableStub : Boolean;
begin
  Result := GetIsWritable;
end;

function TRttiPropertyExtension.GetPropInfo : PPropInfo;
begin
  Result := Handle;
end;

function TRttiPropertyExtension.GetPropInfoStub : PPropInfo;
begin
  Result := GetPropInfo;
end;

/// <remarks>
///   WARNING: the slot indices below were derived from an older System.Rtti. Delphi 13
///   inserted TRttiPlaceMember and TRttiDataMember into the TRttiMember hierarchy, so the
///   map has NOT been re-verified against 37.0 and is very likely wrong. Nothing in DUnitX
///   constructs a TRttiPropertyExtension, so no patched instance is ever produced and the
///   stale map is currently unreachable. Re-verify every index against System.Rtti before
///   using this extension, or it will overwrite unrelated virtual methods.
/// </remarks>
class procedure TRttiPropertyExtension.InitVirtualMethodTable;
const
  MaxIndex          = 17;               // TRttiInstanceProperty.GetPropInfo
{$POINTERMATH ON}
type
  PVtable = ^Pointer;
{$POINTERMATH OFF}
var
  LSize : Integer;
  LData : Pointer;
  LPatchedClass : TClass;
begin
  LSize := SizeOf(Pointer) * (1 + MaxIndex - (vmtSelfPtr div SizeOf(Pointer)));
  LData := AllocMem(LSize);
  LPatchedClass := TClass(PByte(LData) - vmtSelfPtr);
  FPatchedClasses.Add(Self, LPatchedClass);
  Move((PByte(Self) + vmtSelfPtr)^, LData^, LSize);

  PVtable(LPatchedClass)[5] := @TRttiPropertyExtension.GetIsReadableStub;
  PVtable(LPatchedClass)[6] := @TRttiPropertyExtension.GetIsWritableStub;
  PVtable(LPatchedClass)[7] := @TRttiPropertyExtension.DoGetValueStub;
  PVtable(LPatchedClass)[8] := @TRttiPropertyExtension.DoSetValueStub;
  PVtable(LPatchedClass)[12] := @TRttiPropertyExtension.GetPropInfoStub;
end;

{TTimeSpanHelper}
{$IFDEF DELPHI_2010}
class function TTimeSpanHelper.Subtract(const D1, D2 : TDateTime) : TTimeSpan;
begin
  Result := TTimeSpan.Create(Trunc(TimeStampToMSecs(DateTimeToTimeStamp(D1)) - TimeStampToMSecs(DateTimeToTimeStamp(D2))) *
    TicksPerMillisecond);
end;
{$ENDIF}

class function TStrUtils.SplitString(const S, Delimiters : string) : TArray<string>;
var
  StartIdx : Integer;
  FoundIdx : Integer;
  SplitPoints : Integer;
  CurrentSplit : Integer;
  i : Integer;
begin
  Result := nil;

{$IFNDEF NEXTGEN}
  if S <> '' then
  begin
    { Determine the length of the resulting array }
    SplitPoints := 0;
    for i := 1 to Length(S) do
      if IsDelimiter(Delimiters, S, i) then
        Inc(SplitPoints);

    SetLength(Result, SplitPoints + 1);

    { Split the string and fill the resulting array }
    StartIdx := 1;
    CurrentSplit := 0;
    repeat
      FoundIdx := FindDelimiter(Delimiters, S, StartIdx);
      if FoundIdx <> 0 then
      begin
        Result[CurrentSplit] := Copy(S, StartIdx, FoundIdx - StartIdx);
        Inc(CurrentSplit);
        StartIdx := FoundIdx + 1;
      end;
    until CurrentSplit = SplitPoints;

    // copy the remaining part in case the string does not end in a delimiter
    Result[SplitPoints] := Copy(S, StartIdx, Length(S) - StartIdx + 1);
  end;
{$ELSE}
  if S <> string.Empty then
  begin
    { Determine the length of the resulting array }
    SplitPoints := 0;
    for I := 0 to S.Length - 1 do
      if S.IsDelimiter(Delimiters, i) then
        Inc(SplitPoints);

    SetLength(Result, SplitPoints + 1);

    { Split the string and fill the resulting array }
    StartIdx := 0;
    CurrentSplit := 0;
    repeat
      FoundIdx := S.IndexOfAny(Delimiters.ToCharArray, StartIdx);
      if FoundIdx <> -1 then
      begin
        Result[CurrentSplit] := S.SubString(StartIdx, FoundIdx - StartIdx);
        Inc(CurrentSplit);
        StartIdx := FoundIdx + 1;
      end;
    until CurrentSplit = SplitPoints;

    // copy the remaining part in case the string does not end in a delimiter
    Result[SplitPoints] := S.SubString(StartIdx, S.Length - StartIdx + 1);
  end;
{$ENDIF}

end;

{ TListStringUtils }

class function TListStringUtils.ToArray(const values : TList<string>) : TArray<string>;
var
  i : integer;
begin
  SetLength(result, values.Count);
  for i := 0 to values.Count - 1 do
    result[i] := values[i];
end;

{$IFNDEF DELPHI_XE8_UP}

//copied from System.Sysconst - can't use Sysconst as when compiling with runtime packages
//it results in 'E2201 Need imported data reference ($G) to access...'
resourcestring
  SShortMonthNameJan = 'Jan';
  SShortMonthNameFeb = 'Feb';
  SShortMonthNameMar = 'Mar';
  SShortMonthNameApr = 'Apr';
  SShortMonthNameMay = 'May';
  SShortMonthNameJun = 'Jun';
  SShortMonthNameJul = 'Jul';
  SShortMonthNameAug = 'Aug';
  SShortMonthNameSep = 'Sep';
  SShortMonthNameOct = 'Oct';
  SShortMonthNameNov = 'Nov';
  SShortMonthNameDec = 'Dec';

  SLongMonthNameJan = 'January';
  SLongMonthNameFeb = 'February';
  SLongMonthNameMar = 'March';
  SLongMonthNameApr = 'April';
  SLongMonthNameMay = 'May';
  SLongMonthNameJun = 'June';
  SLongMonthNameJul = 'July';
  SLongMonthNameAug = 'August';
  SLongMonthNameSep = 'September';
  SLongMonthNameOct = 'October';
  SLongMonthNameNov = 'November';
  SLongMonthNameDec = 'December';

  SShortDayNameSun  = 'Sun';
  SShortDayNameMon  = 'Mon';
  SShortDayNameTue  = 'Tue';
  SShortDayNameWed  = 'Wed';
  SShortDayNameThu  = 'Thu';
  SShortDayNameFri  = 'Fri';
  SShortDayNameSat  = 'Sat';

  SLongDayNameSun   = 'Sunday';
  SLongDayNameMon   = 'Monday';
  SLongDayNameTue   = 'Tuesday';
  SLongDayNameWed   = 'Wednesday';
  SLongDayNameThu   = 'Thursday';
  SLongDayNameFri   = 'Friday';
  SLongDayNameSat   = 'Saturday';

var
  DefShortMonthNames : array[1..12] of Pointer = (@SShortMonthNameJan,
    @SShortMonthNameFeb, @SShortMonthNameMar, @SShortMonthNameApr,
    @SShortMonthNameMay, @SShortMonthNameJun, @SShortMonthNameJul,
    @SShortMonthNameAug, @SShortMonthNameSep, @SShortMonthNameOct,
    @SShortMonthNameNov, @SShortMonthNameDec);

  DefLongMonthNames : array[1..12] of Pointer = (@SLongMonthNameJan,
    @SLongMonthNameFeb, @SLongMonthNameMar, @SLongMonthNameApr,
    @SLongMonthNameMay, @SLongMonthNameJun, @SLongMonthNameJul,
    @SLongMonthNameAug, @SLongMonthNameSep, @SLongMonthNameOct,
    @SLongMonthNameNov, @SLongMonthNameDec);

  DefShortDayNames : array[1..7] of Pointer = (@SShortDayNameSun,
    @SShortDayNameMon, @SShortDayNameTue, @SShortDayNameWed,
    @SShortDayNameThu, @SShortDayNameFri, @SShortDayNameSat);

  DefLongDayNames : array[1..7] of Pointer = (@SLongDayNameSun,
    @SLongDayNameMon, @SLongDayNameTue, @SLongDayNameWed,
    @SLongDayNameThu, @SLongDayNameFri, @SLongDayNameSat);

  { TFormatSettingsHelper }

class function TFormatSettingsHelper.Invariant : TFormatSettings;
var
  I : Integer;
begin
  Result.CurrencyString := #$00A4;
  Result.CurrencyFormat := 0;
  Result.CurrencyDecimals := 2;
  Result.DateSeparator := '/';
  Result.TimeSeparator := ':';
  Result.ListSeparator := ',';
  Result.ShortDateFormat := 'MM/dd/yyyy';
  Result.LongDateFormat := 'dddd, dd MMMMM yyyy HH:mm:ss';
  Result.TimeAMString := 'AM';
  Result.TimePMString := 'PM';
  Result.ShortTimeFormat := 'HH:mm';
  Result.LongTimeFormat := 'HH:mm:ss';
  for I := Low(DefShortMonthNames) to High(DefShortMonthNames) do
  begin
    Result.ShortMonthNames[I] := LoadResString(DefShortMonthNames[I]);
    Result.LongMonthNames[I] := LoadResString(DefLongMonthNames[I]);
  end;
  for I := Low(DefShortDayNames) to High(DefShortDayNames) do
  begin
    Result.ShortDayNames[I] := LoadResString(DefShortDayNames[I]);
    Result.LongDayNames[I] := LoadResString(DefLongDayNames[I]);
  end;
  Result.ThousandSeparator := ',';
  Result.DecimalSeparator := '.';
  Result.TwoDigitYearCenturyWindow := 50;
  Result.NegCurrFormat := 0;
end;

{$ENDIF}

initialization
  Enumerations := TObjectDictionary<PTypeInfo, TStrings>.Create([doOwnsValues]);

finalization
  Enumerations.Free;

end.

