{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2015 Vincent Parrett & Contributors               }
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

unit DUnitX.CommandLine.Options;

interface

{$I DUnitX.inc}

uses
{$IFDEF USE_NS}
  System.Generics.Collections,
  System.Rtti,
  System.TypInfo,
  System.SysUtils,
  System.Classes;
{$ELSE}
  Generics.Collections,
  Rtti,
  TypInfo,
  SysUtils,
  Classes;
{$ENDIF}

type
  /// <summary>
  ///   The outcome of a command-line parse.
  /// </summary>
  ICommandLineParseResult = interface
    ['{1715B9FF-8A34-47C9-843E-619C5AEA3F32}']
    /// <summary>Reports whether any error was recorded.</summary>
    /// <returns>True if at least one error was recorded.</returns>
    function GetHasErrors : boolean;
    /// <summary>Returns every recorded error.</summary>
    /// <returns>The errors, one per line; empty when there are none.</returns>
    function GetErrorText : string;
    /// <summary>True if the parse recorded at least one error.</summary>
    property HasErrors : boolean read GetHasErrors;
    /// <summary>The recorded errors, one per line.</summary>
    property ErrorText : string read GetErrorText;
  end;

  /// <summary>
  ///   Parses command-line arguments against the registered options, invoking each matched option's action.
  /// </summary>
  ICommandLineParser = interface
    ['{6F970026-D1EE-4A3E-8A99-300AD3EE9C33}']
    /// <summary>Parses the process's own command line.</summary>
    /// <returns>The parse result; check <c>HasErrors</c>.</returns>
    function Parse : ICommandLineParseResult; overload;
    /// <summary>Parses the given arguments instead of the process command line, which makes testing easier.</summary>
    /// <param name="values">The arguments, one per item.</param>
    /// <returns>The parse result; check <c>HasErrors</c>.</returns>
    function Parse(const values : TStrings) : ICommandLineParseResult; overload;
  end;

  /// <summary>
  ///   One registered command-line option: its names, help text and parsing rules. Returned by the
  ///   <c>TOptionsRegistry.Register*</c> functions so the caller can adjust the rules after registering.
  /// </summary>
  IOptionDefinition = interface
    ['{1EAA06BA-8FBF-43F8-86D7-9F5DE26C4E86}']
    /// <summary>Returns the long name, used as <c>--name</c>.</summary>
    /// <returns>The long name; empty for an unnamed option.</returns>
    function GetLongName : string;
    /// <summary>Returns the short name, used as <c>-name</c>.</summary>
    /// <returns>The short name; may be empty.</returns>
    function GetShortName : string;
    /// <summary>Reports whether the option takes a value (<c>--name:value</c>).</summary>
    /// <returns>True if a value is expected.</returns>
    function GetHasValue : boolean;
    /// <summary>Sets whether the option takes a value; a Boolean option without one defaults to True when given.</summary>
    /// <param name="value">True if a value is expected.</param>
    procedure SetHasValue(const value : boolean);
    /// <summary>Returns the help text shown by <c>PrintUsage</c>.</summary>
    /// <returns>The help text; may be empty.</returns>
    function GetHelpText : string;
    /// <summary>Sets the help text shown by <c>PrintUsage</c>.</summary>
    /// <param name="value">The help text.</param>
    procedure SetHelpText(const value : string);
    /// <summary>Reports whether the option must be given.</summary>
    /// <returns>True if parsing reports an error when the option is absent.</returns>
    function GetRequired : boolean;
    /// <summary>Sets whether the option must be given.</summary>
    /// <param name="value">True to report an error when the option is absent.</param>
    procedure SetRequired(const value : boolean);
    /// <summary>Returns the value-required flag.</summary>
    /// <returns>The flag as last set.</returns>
    function GetValueRequired : boolean;
    /// <summary>Sets the value-required flag. Stored only: the parser enforces values through <c>HasValue</c>.</summary>
    /// <param name="value">The new flag.</param>
    procedure SetValueRequired(const value : boolean);
    /// <summary>Returns the allow-multiple flag.</summary>
    /// <returns>True if the option is meant to be given more than once.</returns>
    function GetAllowMultiple : boolean;
    /// <summary>
    ///   Sets the allow-multiple flag. Stored only: the parser invokes the action for every occurrence regardless.
    /// </summary>
    /// <param name="value">True if the option is meant to be given more than once.</param>
    procedure SetAllowMultiple(const value : boolean);
    /// <summary>Reports whether the option's value names an options file to read further arguments from.</summary>
    /// <returns>True for the options-file option.</returns>
    function GetIsOptionFile : boolean;
    /// <summary>Marks the option as the one whose value names an options file (also used for <c>@file</c>).</summary>
    /// <param name="value">True to make this the options-file option.</param>
    procedure SetIsOptionFile(const value : boolean);
    /// <summary>Reports whether the option is left out of <c>PrintUsage</c>.</summary>
    /// <returns>True if hidden.</returns>
    function GetIsHidden : boolean;
    /// <summary>Sets whether the option is left out of <c>PrintUsage</c>.</summary>
    /// <param name="value">True to hide it.</param>
    procedure SetIsHidden(const value : boolean);

    /// <summary>Reports whether the option is unnamed (filled by a bare, positional argument).</summary>
    /// <returns>True when the long name is empty.</returns>
    function GetIsUnnamed : boolean;
    /// <summary>The long name, used as <c>--name</c>; empty for an unnamed option.</summary>
    property LongName : string read GetLongName;
    /// <summary>The short name, used as <c>-name</c>; may be empty.</summary>
    property ShortName : string read GetShortName;
    /// <summary>True if the option takes a value (<c>--name:value</c>); parsing reports an error when it is missing.</summary>
    property HasValue : boolean read GetHasValue write SetHasValue;
    /// <summary>The help text shown by <c>PrintUsage</c>.</summary>
    property HelpText : string read GetHelpText write SetHelpText;
    /// <summary>True if parsing reports an error when the option is absent.</summary>
    property Required : boolean read GetRequired write SetRequired;
    /// <summary>Value-required flag; stored but not enforced by the parser (see <c>HasValue</c>).</summary>
    property ValueRequired : boolean read GetValueRequired write SetValueRequired;
    /// <summary>True if the option is meant to be given more than once; not enforced by the parser.</summary>
    property AllowMultiple : boolean read GetAllowMultiple write SetAllowMultiple;
    /// <summary>True if the option's value names an options file to read further arguments from.</summary>
    property IsOptionFile : boolean read GetIsOptionFile write SetIsOptionFile;
    /// <summary>True if the option is filled by a bare, positional argument.</summary>
    property IsUnnamed : boolean read GetIsUnnamed;
    /// <summary>True if the option is left out of <c>PrintUsage</c>.</summary>
    property Hidden : boolean read GetIsHidden write SetIsHidden;
  end;

  /// <summary>
  ///   Process-wide registry of command-line options: units register options (typically in their initialization),
  ///   and <c>Parse</c> applies the command line to them.
  /// </summary>
  TOptionsRegistry = class
  private
    class var
      /// <summary>Options keyed by lower-cased long and short name, for fast lookup.</summary>
      FOptionsLookup : TDictionary<string, IOptionDefinition>;
      /// <summary>Unnamed options, in registration order; they have no name to key a dictionary by.</summary>
      FUnnamedOptions : TList<IOptionDefinition>;
      /// <summary>Every registered option, named and unnamed, in registration order.</summary>
      FRegisteredOptions : TList<IOptionDefinition>;
  protected
    /// <summary>Creates the option lists.</summary>
    class constructor Create;
    /// <summary>Frees the option lists.</summary>
    class destructor Destroy;
  public
    /// <summary>Registers a named option whose value is converted to <c>T</c> and passed to an action.</summary>
    /// <param name="longName">The long name (<c>--name</c>); required, matched case-insensitively.</param>
    /// <param name="shortName">The short name (<c>-name</c>); may be empty.</param>
    /// <param name="Action">Called with the converted value each time the option is parsed.</param>
    /// <returns>The new definition, to adjust its rules.</returns>
    /// <exception cref="Exception">
    ///   <paramref name="longName" /> is empty, <c>T</c> is not a supported option type, or either name is already
    ///   registered.
    /// </exception>
    class function RegisterOption<T>(const longName : string; const shortName : string; const Action : TProc<T>) : IOptionDefinition; overload;
    /// <summary>Registers a named option with help text, whose value is converted to <c>T</c> and passed to an action.</summary>
    /// <param name="longName">The long name (<c>--name</c>); required, matched case-insensitively.</param>
    /// <param name="shortName">The short name (<c>-name</c>); may be empty.</param>
    /// <param name="helpText">The help text shown by <c>PrintUsage</c>.</param>
    /// <param name="Action">Called with the converted value each time the option is parsed.</param>
    /// <returns>The new definition, to adjust its rules.</returns>
    /// <exception cref="Exception">
    ///   <paramref name="longName" /> is empty, <c>T</c> is not a supported option type, or either name is already
    ///   registered.
    /// </exception>
    class function RegisterOption<T>(const longName : string; const shortName : string; const helpText : string; const Action : TProc<T>) : IOptionDefinition;
      overload;
    /// <summary>
    ///   Registers an unnamed option, filled by the next bare (positional) argument; the whole argument is its value.
    /// </summary>
    /// <param name="helpText">The help text.</param>
    /// <param name="Action">Called with the converted argument.</param>
    /// <returns>The new definition, to adjust its rules.</returns>
    /// <exception cref="Exception"><c>T</c> is not a supported option type.</exception>
    class function RegisterUnNamedOption<T>(const helpText : string; const Action : TProc<T>) : IOptionDefinition; overload;
    /// <summary>Returns every registered option, named and unnamed, in registration order.</summary>
    /// <returns>The registry's own list; do not free or modify it.</returns>
    class function AllRegisteredOptions : TList<IOptionDefinition>;
    /// <summary>Parses the process's own command line against the registered options.</summary>
    /// <returns>The parse result; check <c>HasErrors</c>.</returns>
    class function Parse : ICommandLineParseResult; overload;
    /// <summary>Parses the given arguments against the registered options.</summary>
    /// <param name="values">The arguments, one per item.</param>
    /// <returns>The parse result; check <c>HasErrors</c>.</returns>
    class function Parse(const values : TStrings) : ICommandLineParseResult; overload;
    /// <summary>Named options keyed by lower-cased long and short name (an option appears once per name).</summary>
    class property RegisteredOptions : TDictionary<string, IOptionDefinition> read FOptionsLookup;
    /// <summary>Unnamed options, in the order bare arguments fill them.</summary>
    class property RegisteredUnamedOptions : TList<IOptionDefinition> read FUnnamedOptions;
    /// <summary>
    ///   Writes one usage line per non-hidden option: <c>--long[:value] or -short[:value]</c>, padded, then the help text.
    /// </summary>
    /// <param name="proc">Called with each usage line.</param>
    /// <param name="pad">Width the option syntax is padded to before the help text.</param>
    class procedure PrintUsage(const proc : TProc<string>; const pad : integer = 30);
  end;

implementation

uses
  DUnitX.Utils,
  DUnitX.CommandLine.Parser,
  DUnitX.Commandline.OptionDef,
  DUnitX.ResStrs;

{ TOptionsRegistry }

class function TOptionsRegistry.RegisterOption<T>(const longName, shortName : string; const Action : TProc<T>) : IOptionDefinition;
begin
  if longName = '' then
    raise Exception.Create(SNameRequired);

  if FOptionsLookup.ContainsKey(LowerCase(longName)) then
    raise Exception.Create(Format(SOptionAlreadyRegistered, [longName]));

  if FOptionsLookup.ContainsKey(LowerCase(shortName)) then
    raise Exception.Create(Format(SOptionAlreadyRegistered, [shortName]));

  result := TOptionDefinition<T>.Create(longName, shortName, Action);

  FOptionsLookup.Add(LowerCase(longName), Result);
  FRegisteredOptions.Add(Result);

  if shortName <> '' then
    FOptionsLookup.Add(LowerCase(shortName), Result);
end;

class function TOptionsRegistry.Parse : ICommandLineParseResult;
var
  parser : ICommandLineParser;
begin
  parser := TCommandLineParser.Create;
  result := parser.Parse;
end;

class function TOptionsRegistry.AllRegisteredOptions : TList<IOptionDefinition>;
begin
  result := FRegisteredOptions;
end;

class constructor TOptionsRegistry.Create;
begin
  FOptionsLookup := TDictionary<string, IOptionDefinition>.Create;
  FUnnamedOptions := TList<IOptionDefinition>.Create;
  FRegisteredOptions := TList<IOptionDefinition>.Create;

end;

class destructor TOptionsRegistry.Destroy;
begin
  FOptionsLookup.Free;
  FUnnamedOptions.Free;
  FRegisteredOptions.Free;
end;

class function TOptionsRegistry.Parse(const values : TStrings) : ICommandLineParseResult;
var
  parser : ICommandLineParser;
begin
  parser := TCommandLineParser.Create;
  result := parser.Parse(values);
end;

class procedure TOptionsRegistry.PrintUsage(const proc : TProc<string>; const pad : integer);
var
  option : IOptionDefinition;
  helpString : string;
begin
  for option in AllRegisteredOptions do
  begin
    if option.Hidden then
      continue;
    helpString := '--' + option.LongName;
    if option.HasValue then
      helpString := helpString + ':value';
    if option.ShortName <> '' then
    begin
      helpString := helpString + ' or -' + option.ShortName;
      if option.HasValue then
        helpString := helpString + ':value';
    end;
    helpString := TStrUtils.PadString(helpString, pad, false);

    if option.HelpText <> '' then
      helpString := helpString + ' - ' + option.HelpText;
    proc(helpString);
  end;
end;

class function TOptionsRegistry.RegisterOption<T>(const longName, shortName, helpText : string; const Action : TProc<T>) : IOptionDefinition;
begin
  result := RegisterOption<T>(longName, shortName, Action);
  result.HelpText := helpText;
end;

class function TOptionsRegistry.RegisterUnNamedOption<T>(const helpText : string; const Action : TProc<T>) : IOptionDefinition;
begin
  result := TOptionDefinition<T>.Create('', '', helptext, Action);
  result.HasValue := false;
  FUnNamedOptions.Add(Result);
  FRegisteredOptions.Add(Result);
end;

end.

