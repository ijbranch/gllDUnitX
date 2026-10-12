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

unit DUnitX.CommandLine.Parser;

interface

{$I DUnitX.inc}

uses
{$IFDEF USE_NS}
  System.Classes,
{$ELSE}
  Classes,
{$ENDIF}
  DUnitX.CommandLine.Options,
  DUnitX.CommandLine.OptionDef;

type
  /// <summary>
  ///   The writable side of a parse result: lets the parser record errors on a result that callers only read.
  /// </summary>
  IParseResultAddError = interface
    ['{9EADABED-511B-4095-9ACA-A5E431AB653D}']
    /// <summary>Records one parse error.</summary>
    /// <param name="value">The error message.</param>
    procedure AddError(const value : string);
  end;

  /// <summary>
  ///   The outcome of a command-line parse: the list of errors found, empty on success.
  /// </summary>
  TCommandLineParseResult = class(TInterfacedObject, ICommandLineParseResult, IParseResultAddError)
  private
    /// <summary>The errors recorded, one per line.</summary>
    FErrors : TStringList;
  protected
    /// <summary>Returns every recorded error.</summary>
    /// <returns>The errors, one per line, each terminated by a line break; empty when there are none.</returns>
    function GetErrorText : string;
    /// <summary>Reports whether any error was recorded.</summary>
    /// <returns>True if at least one error was recorded.</returns>
    function GetHasErrors : Boolean;
    /// <summary>Records one parse error.</summary>
    /// <param name="value">The error message.</param>
    procedure AddError(const value : string);
  public
    /// <summary>Creates an empty (successful) result.</summary>
    constructor Create;
    /// <summary>Frees the error list.</summary>
    destructor Destroy; override;
  end;

  /// <summary>
  ///   Parses command-line arguments (or a list of strings) against the options registered in
  ///   <c>TOptionsRegistry</c>, invoking each matched option's action and collecting errors rather than raising.
  /// </summary>
  /// <remarks>
  ///   Accepts <c>--name[:value]</c>, <c>-name[:value]</c> and <c>/name[:value]</c>; <c>@file</c> reads an options
  ///   file through the option marked <c>IsOptionFile</c>; any other argument fills the next registered unnamed option.
  ///   Option files contain one argument per line; blank lines and lines starting with <c>#</c> or <c>;</c> are skipped.
  /// </remarks>
  TCommandLineParser = class(TInterfacedObject, ICommandLineParser)
  private
    /// <summary>Index of the next registered unnamed option to fill with a bare argument.</summary>
    FUnamedIndex : integer;
    /// <summary>Full paths of the options files currently being parsed, to stop a file including itself.</summary>
    FOpenOptionFiles : TStringList;
  protected
    /// <summary>Records an error for every option marked <c>Required</c> that was not found.</summary>
    /// <param name="parseErrors">Where to record the errors.</param>
    procedure InternalValidate(const parseErrors : IParseResultAddError);

    /// <summary>
    ///   Parses an options file: loads it, trims each line, drops blank and comment lines, and parses the rest as
    ///   arguments. A file that is already being parsed (directly or through an include chain) is reported, not
    ///   re-read.
    /// </summary>
    /// <param name="fileName">The options file to read.</param>
    /// <param name="parseErrors">Where to record errors.</param>
    /// <exception cref="EFOpenError">The file cannot be opened (the caller in <c>InternalParse</c> records it as an error).</exception>
    procedure InternalParseFile(const fileName : string; const parseErrors : IParseResultAddError);
    /// <summary>
    ///   Parses a list of arguments, invoking the action of each recognised option. Unknown options, missing values,
    ///   missing option files and values the option cannot convert are recorded as errors and parsing continues.
    /// </summary>
    /// <param name="values">The arguments, one per item.</param>
    /// <param name="parseErrors">Where to record errors.</param>
    procedure InternalParse(const values : TStrings; const parseErrors : IParseResultAddError);

    /// <summary>Parses the process's own command line (<c>ParamStr(1)</c> to <c>ParamStr(ParamCount)</c>).</summary>
    /// <returns>The parse result; check <c>HasErrors</c>.</returns>
    function Parse : ICommandLineParseResult; overload;
    /// <summary>Parses the given arguments, then checks that every required option was found.</summary>
    /// <param name="values">The arguments, one per item; makes testing easier than the process command line.</param>
    /// <returns>The parse result; check <c>HasErrors</c>.</returns>
    function Parse(const values : TStrings) : ICommandLineParseResult; overload;
  public
    /// <summary>Creates a parser positioned at the first unnamed option.</summary>
    constructor Create;
    /// <summary>Frees the open-options-file list.</summary>
    destructor Destroy; override;
  end;

implementation

uses
  DUnitX.ResStrs,
{$IFDEF USE_NS}
  System.Generics.Collections,
  System.StrUtils,
  System.SysUtils;
{$ELSE}
  Generics.Collections,
  StrUtils,
  SysUtils;
{$ENDIF}

procedure StripQuotes(var value : string);
var
  l : integer;
begin
{$IFDEF NEXTGEN}
  l := value.Length - 1;
  if l < 1 then
    exit;

  if CharInSet(value.Chars[0], ['''', '"']) and CharInSet(value.Chars[l], ['''', '"']) then
  begin
    value := value.Remove(l, 1);
    value := value.Remove(0, 1);
  end;
{$ELSE}
  l := Length(value);
  if l < 2 then
    exit;

  if CharInSet(value[1], ['''', '"']) and CharInSet(value[l], ['''', '"']) then
  begin
    Delete(value, l, 1);
    Delete(value, 1, 1);
  end;
{$ENDIF}
end;

//The registered option that names an options file, or nil if there is none.
function FindOptionFileOption : IOptionDefinition;
var
  option : IOptionDefinition;
begin
  Result := nil;
  for option in TOptionsRegistry.RegisteredOptions.Values do
    if option.IsOptionFile then
      Exit(option);
end;

{ TCommandLineParser }

constructor TCommandLineParser.Create;
begin
  FUnamedIndex := 0;
  FOpenOptionFiles := TStringList.Create;
end;

destructor TCommandLineParser.Destroy;
begin
  FOpenOptionFiles.Free;
  inherited;
end;

procedure TCommandLineParser.InternalParse(const values : TStrings; const parseErrors : IParseResultAddError);
var
  i : integer;
  j : integer;
  value : string;
  key : string;
  option : IOptionDefinition;
  bTryValue : boolean;
  bUseKey : boolean;
  isAtFile : boolean;
begin
  for i := 0 to values.Count - 1 do
  begin
    j := {$IFDEF NEXTGEN} - 1{$ELSE}0{$ENDIF};
    option := nil;
    bTryValue := true;
    bUseKey := false;
    isAtFile := false;
    value := values.Strings[i];
{$IFDEF NEXTGEN}
    if value = string.Empty then
      continue;
    if value.StartsWith('--') then
      value := value.Remove(0, 2)
    else if value.StartsWith('-') then
      value := value.Remove(0, 1)
    else if value.StartsWith('/') then
      value := value.Remove(0, 1)
    else if value.StartsWith('@') then
      value := value.Remove(0, 1)
{$ELSE}

    if value = '' then
      continue;
    if StartsStr('--', value) then
      Delete(value, 1, 2)
    else if StartsStr('-', value) then
      Delete(value, 1, 1)
    else if StartsStr('/', value) then
      Delete(value, 1, 1)
    else if StartsStr('@', value) then
    begin
      //'@<file>' reads an options file. The name is taken whole, so a drive colon does not split it.
      Delete(value, 1, 1);
      StripQuotes(value);
      option := FindOptionFileOption;
      bTryValue := false;
      isAtFile := true;
    end
{$ENDIF}
    else if FUnamedIndex < TOptionsRegistry.RegisteredUnamedOptions.Count then
    begin
      option := TOptionsRegistry.RegisteredUnamedOptions.Items[FUnamedIndex];
      Inc(FUnamedIndex);
      bTryValue := false;
      bUseKey := True;
    end
    else
    begin
      //don't recognize the start so report it and continue.
      parseErrors.AddError(SUnknownOptionStart + values.Strings[i]);
      continue;
    end;

{$IFDEF NEXTGEN}
    if bTryValue then
      j := value.IndexOf(':');
    if j > -1 then
    begin
      //separate out into key and value
      key := value.SubString(0, j);
      value := value.Remove(0, j + 1);
      //it should already come in here without quotes when parsing paramstr(x).
      //but it might have quotes if it came in from a parameter file;
      StripQuotes(value);
    end
{$ELSE}
    if bTryValue then
      j := Pos(':', value);
    if j > 0 then
    begin
      //separate out into key and value
      key := Copy(value, 1, j - 1);
      Delete(value, 1, j);
      //it should already come in here without quotes when parsing paramstr(x).
      //but it might have quotes if it came in from a parameter file;
      StripQuotes(value);
    end
{$ENDIF}
    else
    begin
      //no value just a key
      key := value;
      value := '';
    end;
    if isAtFile then
      value := key;

    if option = nil then
      TOptionsRegistry.RegisteredOptions.TryGetValue(LowerCase(key), option);

    if option <> nil then
    begin
      if option.HasValue and (value = '') then
      begin
        parseErrors.AddError(Format(SOptionExpectedValue, [key]));
        continue;
      end;
      if option.IsOptionFile then
      begin
        if not option.HasValue then
          value := key;
        //A relative name inside an options file is relative to that file's folder, not the current directory.
        if (FOpenOptionFiles.Count > 0) and IsRelativePath(value) then
          value := ExpandFileName(ExtractFilePath(FOpenOptionFiles[FOpenOptionFiles.Count - 1]) + value);

        //TODO : should options file override other options or vica versa?
        if not FileExists(value) then
        begin
          parseErrors.AddError(Format(SParameterFileDoesNotExist, [value]));
          continue;
        end;
        try
          InternalParseFile(value, parseErrors);
        except
          on e : Exception do
          begin
            parseErrors.AddError(Format(SErrorParsingParameterFile, [value]) + e.Message);
          end;
        end;
      end
      else
      begin
        try
          if bUseKey then
            (option as IOptionDefInvoke).Invoke(key)
          else
            (option as IOptionDefInvoke).Invoke(value);
        except
          on e : Exception do
          begin
            parseErrors.AddError(Format(SErrorSettingOption, [key, value]) + e.Message);
          end;
        end;
      end;
    end
    else
    begin
      parseErrors.AddError(SUnknownCommandLineOption + values.Strings[i]);
      continue;
    end;
  end;
end;

procedure TCommandLineParser.InternalParseFile(const fileName : string; const parseErrors : IParseResultAddError);
var
  sList : TStringList;
  fullName : string;
  line : string;
  i : integer;
begin
  fullName := ExpandFileName(fileName);
  if FOpenOptionFiles.IndexOf(fullName) >= 0 then
  begin
    parseErrors.AddError(Format(SParameterFileIncludesItself, [fileName]));
    exit;
  end;
  FOpenOptionFiles.Add(fullName);
  sList := TStringList.Create;
  try
    sList.LoadFromFile(fileName);
    //trim each line; skip blank lines and '#' / ';' comment lines
    for i := sList.Count - 1 downto 0 do
    begin
      line := Trim(sList[i]);
      if (line = '') or StartsStr('#', line) or StartsStr(';', line) then
        sList.Delete(i)
      else
        sList[i] := line;
    end;
    InternalParse(sList, parseErrors);
  finally
    sList.Free;
    FOpenOptionFiles.Delete(FOpenOptionFiles.IndexOf(fullName));
  end;
end;

procedure TCommandLineParser.InternalValidate(const parseErrors : IParseResultAddError);
var
  option : IOptionDefinition;
begin
  for option in TOptionsRegistry.AllRegisteredOptions do
  begin
    if option.Required then
    begin
      if not (option as IOptionDefInvoke).WasFound then
      begin
        parseErrors.AddError(Format(SOptionNotSpecified, [option.LongName]));
      end;
    end;
  end;
end;

function TCommandLineParser.Parse(const values : TStrings) : ICommandLineParseResult;
begin
  result := TCommandLineParseResult.Create;
  InternalParse(values, result as IParseResultAddError);
  InternalValidate(result as IParseResultAddError);
end;

function TCommandLineParser.Parse : ICommandLineParseResult;
var
  sList : TStringList;
  i : integer;
begin
  sList := TStringList.Create;
  try
    if ParamCount > 0 then
    begin
      for i := 1 to ParamCount do
        sList.Add(ParamStr(i));
    end;
    result := Self.Parse(sList);

  finally
    sList.Free;
  end;
end;

{ TCommandLineParseResult }

procedure TCommandLineParseResult.AddError(const value : string);
begin
  FErrors.Add(value);
end;

constructor TCommandLineParseResult.Create;
begin
  FErrors := TStringList.Create;
end;

destructor TCommandLineParseResult.Destroy;
begin
  FErrors.Free;
  inherited;
end;

function TCommandLineParseResult.GetErrorText : string;
begin
  result := FErrors.Text;
end;

function TCommandLineParseResult.GetHasErrors : Boolean;
begin
  result := FErrors.Count > 0;
end;

end.

