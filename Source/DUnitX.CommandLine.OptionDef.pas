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

unit DUnitX.CommandLine.OptionDef;

interface

{$I DUnitX.inc}

uses
{$IFDEF USE_NS}
  System.Classes,
  System.SysUtils,
  System.Rtti,
  System.TypInfo,
  System.Generics.Collections,
{$ELSE}
  Classes,
  SysUtils,
  Rtti,
  TypInfo,
  Generics.Collections,
{$ENDIF}

  DUnitX.CommandLine.Options;

type
  /// <summary>
  ///   The parser's side of an option definition: applies a parsed value to the option and reports whether it was
  ///   seen. Kept separate from <c>IOptionDefinition</c> so registering code cannot invoke an option.
  /// </summary>
  IOptionDefInvoke = interface
    ['{580B5B40-CD7B-41B8-AE53-2C6890141FF0}']
    /// <summary>Converts a parsed value to the option's type and calls its action; marks the option found.</summary>
    /// <param name="value">The value text; empty means "given without a value", which passes the option's default.</param>
    /// <exception cref="Exception">The value cannot be converted to the option's type (caught by the parser).</exception>
    procedure Invoke(const value : string);
    /// <summary>Reports whether the option was given on the command line.</summary>
    /// <returns>True once <c>Invoke</c> has been called.</returns>
    function WasFound : boolean;
    /// <summary>Returns the run-time type information of the option's value type.</summary>
    /// <returns>The type information for <c>T</c>.</returns>
    function GetTypeInfo : PTypeInfo;
  end;

  /// <summary>
  ///   The implementation of a command-line option whose value is converted to <c>T</c> and passed to an action.
  ///   <c>T</c> must be an integer, Int64, float, string, enumeration (including Boolean) or set type.
  /// </summary>
  TOptionDefinition<T> = class(TInterfacedObject, IOptionDefinition, IOptionDefInvoke)
  private
    /// <summary>Long name (<c>--name</c>); empty for an unnamed option.</summary>
    FLongName : string;
    /// <summary>Short name (<c>-name</c>); may be empty.</summary>
    FShortName : string;
    /// <summary>Help text shown in the usage listing.</summary>
    FHelpText : string;
    /// <summary>True if the option takes a value; True by default.</summary>
    FHasValue : boolean;
    /// <summary>True if parsing reports an error when the option is absent.</summary>
    FRequired : boolean;
    /// <summary>Value-required flag; stored only.</summary>
    FValueRequired : boolean;
    /// <summary>True if the option's value names an options file.</summary>
    FIsOptionFile : boolean;
    /// <summary>Allow-multiple flag; stored only.</summary>
    FAllowMultiple : boolean;
    /// <summary>Action called with the converted value.</summary>
    FProc : TProc<T>;
    /// <summary>True once the option has been invoked.</summary>
    FWasFound : boolean;
    /// <summary>Type information for <c>T</c>, used to choose the conversion.</summary>
    FTypeInfo : PTypeInfo;
    /// <summary>Value passed to the action when the option is given without one.</summary>
    FDefault : T;
    /// <summary>True if the option is left out of the usage listing.</summary>
    FHidden : boolean;
  protected
    /// <summary>Returns the allow-multiple flag.</summary>
    /// <returns>The flag as last set.</returns>
    function GetAllowMultiple : Boolean;
    /// <summary>Reports whether the option takes a value.</summary>
    /// <returns>True if a value is expected.</returns>
    function GetHasValue : Boolean;
    /// <summary>Returns the help text.</summary>
    /// <returns>The help text; may be empty.</returns>
    function GetHelpText : string;
    /// <summary>Returns the long name.</summary>
    /// <returns>The long name; empty for an unnamed option.</returns>
    function GetLongName : string;
    /// <summary>Reports whether the option must be given.</summary>
    /// <returns>True if required.</returns>
    function GetRequired : Boolean;
    /// <summary>Returns the short name.</summary>
    /// <returns>The short name; may be empty.</returns>
    function GetShortName : string;
    /// <summary>Returns the value-required flag.</summary>
    /// <returns>The flag as last set.</returns>
    function GetValueRequired : Boolean;
    /// <summary>Reports whether the option's value names an options file.</summary>
    /// <returns>True for the options-file option.</returns>
    function GetIsOptionFile : Boolean;
    /// <summary>Reports whether the option is unnamed.</summary>
    /// <returns>True when the long name is empty.</returns>
    function GetIsUnnamed : Boolean;
    /// <summary>Reports whether the option is left out of the usage listing.</summary>
    /// <returns>True if hidden.</returns>
    function GetIsHidden : Boolean;

    /// <summary>Sets whether the option is left out of the usage listing.</summary>
    /// <param name="value">True to hide it.</param>
    procedure SetIsHidden(const value : Boolean);
    /// <summary>Sets whether the option's value names an options file.</summary>
    /// <param name="value">True to make this the options-file option.</param>
    procedure SetIsOptionFile(const value : Boolean);
    /// <summary>Sets the allow-multiple flag (stored only).</summary>
    /// <param name="value">The new flag.</param>
    procedure SetAllowMultiple(const value : Boolean);
    /// <summary>Sets whether the option takes a value, and recomputes the default passed when it has none.</summary>
    /// <param name="value">True if a value is expected.</param>
    procedure SetHasValue(const value : Boolean);
    /// <summary>Sets the help text.</summary>
    /// <param name="value">The help text.</param>
    procedure SetHelpText(const value : string);
    /// <summary>Sets the long name. Does not update the registry's lookup.</summary>
    /// <param name="value">The new long name.</param>
    procedure SetLongName(const value : string);
    /// <summary>Sets whether the option must be given.</summary>
    /// <param name="value">True to report an error when it is absent.</param>
    procedure SetRequired(const value : Boolean);
    /// <summary>Sets the short name. Does not update the registry's lookup.</summary>
    /// <param name="value">The new short name.</param>
    procedure SetShortName(const value : string);
    /// <summary>Sets the value-required flag (stored only).</summary>
    /// <param name="value">The new flag.</param>
    procedure SetValueRequired(const value : Boolean);
    /// <summary>
    ///   Marks the option found and, if it has an action, converts the value to <c>T</c> and calls the action; an
    ///   empty value passes the default instead. Floats are parsed with invariant format settings.
    /// </summary>
    /// <param name="value">The value text from the command line.</param>
    /// <exception cref="Exception">
    ///   The value is not a valid enumeration name or Boolean word, or <c>T</c>'s kind is unsupported.
    /// </exception>
    /// <exception cref="EConvertError">The value is not a valid integer, Int64 or float.</exception>
    procedure Invoke(const value : string);
    /// <summary>Reports whether the option was given.</summary>
    /// <returns>True once <c>Invoke</c> has been called.</returns>
    function WasFound : boolean;
    /// <summary>Returns the type information for <c>T</c>.</summary>
    /// <returns>The type information captured at construction.</returns>
    function GetTypeInfo : PTypeInfo;
    /// <summary>
    ///   Sets the default passed when the option is given without a value: <c>Default(T)</c>, except True for a
    ///   Boolean option that takes no value (so a bare flag switches it on).
    /// </summary>
    procedure InitDefault;
  public
    /// <summary>Creates an option definition that takes a value, with no help text.</summary>
    /// <param name="longName">The long name; empty for an unnamed option.</param>
    /// <param name="shortName">The short name; may be empty.</param>
    /// <param name="proc">Action called with the converted value.</param>
    /// <exception cref="Exception"><c>T</c> is not a supported option type.</exception>
    constructor Create(const longName : string; const shortName : string; const proc : TProc<T>); overload;
    /// <summary>Creates an option definition that takes a value, with help text.</summary>
    /// <param name="longName">The long name; empty for an unnamed option.</param>
    /// <param name="shortName">The short name; may be empty.</param>
    /// <param name="helpText">The help text shown in the usage listing.</param>
    /// <param name="proc">Action called with the converted value.</param>
    /// <exception cref="Exception"><c>T</c> is not a supported option type.</exception>
    constructor Create(const longName : string; const shortName : string; const helpText : string; const proc : TProc<T>); overload;

  end;

const
  /// <summary>
  ///   Words <c>StringToBoolean</c> accepts as True, matched case-insensitively. Includes the empty string. In the
  ///   interface so they can be unit tested.
  /// </summary>
  trueStrings       : array[0..10] of string = ('True', 'T', '+', 'Yes', 'Y', 'On', 'Enable', 'Enabled', '1', '-1', '');
  /// <summary>
  ///   Words <c>StringToBoolean</c> accepts as False, matched case-insensitively. In the interface so they can be unit
  ///   tested.
  /// </summary>
  falseStrings      : array[0..8] of string = ('False', 'F', '-', 'No', 'N', 'Off', 'Disable', 'Disabled', '0');

/// <summary>Converts a command-line word to a Boolean using <c>trueStrings</c> and <c>falseStrings</c>.</summary>
/// <param name="value">The word to convert, matched case-insensitively.</param>
/// <returns>True for a word in <c>trueStrings</c> (including the empty string), False for one in <c>falseStrings</c>.</returns>
/// <exception cref="Exception">The word is in neither list.</exception>
function StringToBoolean(const value : string) : boolean;

implementation

uses
  DUnitX.ResStrs,
{$IFDEF USE_NS}
  System.StrUtils;
{$ELSE}
  StrUtils;
{$ENDIF}

{ TOptionDefinition<T> }

function StringToBoolean(const value : string) : boolean;
begin
  if MatchText(value, trueStrings) then
    result := true
  else if MatchText(value, falseStrings) then
    result := false
  else
    raise Exception.Create(SInvalidValueBool);
end;

constructor TOptionDefinition<T>.Create(const longName, shortName : string; const proc : TProc<T>);
begin
  FTypeInfo := TypeInfo(T);
  if FTypeInfo.Kind not in [tkInteger, tkEnumeration, tkFloat, tkString, tkSet, tkLString, tkWString, tkInt64, tkUString] then
    raise Exception.Create(SInvalidOptionType);

  FLongName := longName;
  FShortName := shortName;
  FHasValue := true;
  FProc := proc;
  InitDefault;
end;

constructor TOptionDefinition<T>.Create(const longName, shortName, helpText : string; const proc : TProc<T>);
begin
  Self.Create(longName, shortName, proc);
  FHelpText := helpText;
end;

function TOptionDefinition<T>.GetAllowMultiple : Boolean;
begin
  result := FAllowMultiple;
end;

function TOptionDefinition<T>.GetHasValue : Boolean;
begin
  result := FHasValue;
end;

function TOptionDefinition<T>.GetHelpText : string;
begin
  result := FHelpText;
end;

function TOptionDefinition<T>.GetIsHidden : Boolean;
begin
  result := FHidden;
end;

function TOptionDefinition<T>.GetIsOptionFile : Boolean;
begin
  Result := FIsOptionFile;
end;

function TOptionDefinition<T>.GetIsUnnamed : Boolean;
begin
  result := FLongName = '';
end;

function TOptionDefinition<T>.GetLongName : string;
begin
  result := FLongName;
end;

function TOptionDefinition<T>.GetRequired : Boolean;
begin
  result := FRequired;
end;

function TOptionDefinition<T>.GetShortName : string;
begin
  result := FShortName;
end;

function TOptionDefinition<T>.GetTypeInfo : PTypeInfo;
begin
  result := FTypeInfo;
end;

function TOptionDefinition<T>.GetValueRequired : Boolean;
begin
  result := FValueRequired;
end;

function TOptionDefinition<T>.WasFound : boolean;
begin
  result := FWasFound;
end;

procedure TOptionDefinition<T>.InitDefault;
begin
  FDefault := Default(T);
  if not FHasValue and (GetTypeName(FTypeInfo) = 'Boolean') then
    FDefault := TValue.FromVariant(true).AsType<T>;

end;

//Note : Using TValue.FromVariant as TValue.From<T>
procedure TOptionDefinition<T>.Invoke(const value : string);
var
  v : TValue;
  intVal : integer;
  int64Val : Int64;
  floatVal : Double;
  setBuffer : array[0..31] of Byte;
begin
  FWasFound := True;
  if Assigned(FProc) then
  begin
    if value <> '' then
    begin
      //there must be a cleaner way to do this, TValue still fails at the most basic conversions.
      case FTypeInfo.Kind of
        tkInteger :
          begin
            intVal := StrToInt(value);
            v := TValue.From<Integer>(intVal);
          end;
        tkInt64 :
          begin
            int64Val := StrToInt64(value);
            v := TValue.From<Int64>(int64Val);
          end;
        tkString, tkLString, tkWString, tkUString :
          begin
            v := TValue.From<string>(value);
          end;
        tkSet :
          begin
            //StringToSet gives the set's bits as an Integer. They are copied into a buffer as large as any set, so a
            //set wider than 4 bytes is not read past the end of the Integer (T(PInteger^) did).
            intVal := StringToSet(FTypeInfo, value);
            FillChar(setBuffer, SizeOf(setBuffer), 0);
            Move(intVal, setBuffer, SizeOf(intVal));
            TValue.Make(@setBuffer, FTypeInfo, v);
          end;
        tkEnumeration :
          begin
            if GetTypeName(FTypeInfo) = 'Boolean' then
            begin
              v := TValue.From<Boolean>(StringToBoolean(value));
            end
            else
            begin
              intVal := GetEnumValue(FTypeInfo, value);
              if intVal < 0 then
                raise Exception.Create(SInvalidEnum + value);

              v := TValue.FromOrdinal(FTypeInfo, intVal);
            end;
          end;
        tkFloat :
          begin
            floatVal := StrToFloat(value, TFormatSettings.Invariant);
            v := TValue.From<Double>(floatVal);
          end;
      else
        raise Exception.Create(SInvalidOpt);
        //what?
      end;
      FProc(v.AsType<T>);
    end
    else
    begin
      FProc(FDefault);
    end;
  end;
end;

procedure TOptionDefinition<T>.SetAllowMultiple(const value : Boolean);
begin
  FAllowMultiple := value;
end;

procedure TOptionDefinition<T>.SetHasValue(const value : Boolean);
begin
  FHasValue := value;
  InitDefault;
end;

procedure TOptionDefinition<T>.SetHelpText(const value : string);
begin
  FHelpText := value;
end;

procedure TOptionDefinition<T>.SetIsHidden(const value : Boolean);
begin
  FHidden := value;
end;

procedure TOptionDefinition<T>.SetIsOptionFile(const value : Boolean);
begin
  FIsOptionFile := value;
end;

procedure TOptionDefinition<T>.SetLongName(const value : string);
begin
  FLongName := value;
end;

procedure TOptionDefinition<T>.SetRequired(const value : Boolean);
begin
  FRequired := value;
end;

procedure TOptionDefinition<T>.SetShortName(const value : string);
begin
  FShortName := value;
end;

procedure TOptionDefinition<T>.SetValueRequired(const value : Boolean);
begin
  FValueRequired := value;
end;

end.

