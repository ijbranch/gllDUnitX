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

unit DUnitX.ConsoleWriter.Base;

interface

{$I DUnitX.inc}

uses
{$IFDEF USE_NS}
  System.Classes;
{$ELSE}
  Classes;
{$ENDIF}

type
  /// <summary>
  ///   Platform-neutral console text colours; each console writer maps them to its own colour codes.
  /// </summary>
  TConsoleColour = (
    /// <summary>The colour the console had when the writer was created.</summary>
    ccDefault,
    /// <summary>Bright (intense) red.</summary>
    ccBrightRed,
    /// <summary>Dark (normal-intensity) red.</summary>
    ccDarkRed,
    /// <summary>Bright (intense) blue.</summary>
    ccBrightBlue,
    /// <summary>Dark (normal-intensity) blue.</summary>
    ccDarkBlue,
    /// <summary>Bright (intense) green.</summary>
    ccBrightGreen,
    /// <summary>Dark (normal-intensity) green.</summary>
    ccDarkGreen,
    /// <summary>Bright (intense) yellow.</summary>
    ccBrightYellow,
    /// <summary>Dark (normal-intensity) yellow.</summary>
    ccDarkYellow,
    /// <summary>Bright (intense) aqua (cyan).</summary>
    ccBrightAqua,
    /// <summary>Dark (normal-intensity) aqua (cyan).</summary>
    ccDarkAqua,
    /// <summary>Bright (intense) purple (magenta).</summary>
    ccBrightPurple,
    /// <summary>Dark (normal-intensity) purple (magenta).</summary>
    ccDarkPurple,
    /// <summary>Grey (intensity only, no colour).</summary>
    ccGrey,
    /// <summary>Black.</summary>
    ccBlack,
    /// <summary>Bright (intense) white.</summary>
    ccBrightWhite,
    /// <summary>White: the normal colour of text on the console.</summary>
    ccWhite
  );

{$M+}
  /// <summary>
  ///   Writes indented, coloured text to the console, wrapping lines at the console width. Resolved from the service
  ///   locator by the console logger and the banner; the platform writer registers itself as the implementation.
  /// </summary>
  IDUnitXConsoleWriter = interface
    ['{EFE59EB8-0C0B-4790-A964-D8126A2728A9}']
    /// <summary>Returns the current indent.</summary>
    /// <returns>The number of spaces each line is indented by.</returns>
    function GetIndent : Integer;
    /// <summary>Sets the indent.</summary>
    /// <param name="count">The number of spaces to indent each line by; negative values become 0.</param>
    procedure SetIndent(const count : Integer);
    /// <summary>Sets the colours used for subsequent output.</summary>
    /// <param name="foreground">The text colour.</param>
    /// <param name="background">The background colour; <c>ccDefault</c> restores the original.</param>
    procedure SetColour(const foreground : TConsoleColour; const background : TConsoleColour = ccDefault);
    /// <summary>Writes text followed by a line break, indenting and wrapping it at the console width.</summary>
    /// <param name="s">The text to write; may contain line breaks.</param>
    procedure WriteLn(const s : string); overload;
    /// <summary>Writes an empty line.</summary>
    procedure WriteLn; overload;
    /// <summary>Writes text with no trailing line break, indenting and wrapping it at the console width.</summary>
    /// <param name="s">The text to write; may contain line breaks.</param>
    procedure Write(const s : string);
    /// <summary>Increases the indent.</summary>
    /// <param name="value">The number of spaces to add.</param>
    procedure Indent(const value : integer = 1);
    /// <summary>Decreases the indent, never below 0.</summary>
    /// <param name="value">The number of spaces to remove.</param>
    procedure Outdent(const value : integer = 1);
    /// <summary>The number of spaces each line is indented by.</summary>
    property CurrentIndentLevel : Integer read GetIndent write SetIndent;

  end;

  /// <summary>
  ///   Base console writer: keeps the indent and console width and splits text into console-width lines; descendants
  ///   supply the actual output (<c>InternalWrite</c>, <c>InternalWriteLn</c>) and colouring (<c>SetColour</c>).
  /// </summary>
  TDUnitXConsoleWriterBase = class(TInterfacedObject, IDUnitXConsoleWriter)
  private
    /// <summary>Number of spaces each line is indented by.</summary>
    FIndent : integer;
    /// <summary>Console width in characters, used for wrapping; 80 until a descendant sets it.</summary>
    FConsoleWidth : integer;
    /// <summary>True when standard output is not a console, so the indent is not clamped to the width.</summary>
    FRedirectedStdOut : boolean;
  protected
    /// <summary>Returns the current indent.</summary>
    /// <returns>The number of spaces each line is indented by.</returns>
    function GetIndent : Integer;
    /// <summary>
    ///   Sets the indent: negative values become 0 and, unless output is redirected, it is clamped to two less than
    ///   the console width.
    /// </summary>
    /// <param name="count">The requested indent.</param>
    procedure SetIndent(const count : Integer); virtual;
    /// <summary>
    ///   Splits text at its line breaks and then into chunks of at most (console width - indent) characters.
    /// </summary>
    /// <param name="s">The text to split; an empty string yields one empty line.</param>
    /// <returns>A new string list the caller must free.</returns>
    function InternalBreakupMessage(const s : string) : TStringList;
    /// <summary>Writes one line, indented, followed by a line break.</summary>
    /// <param name="s">The line text, already wrapped to fit.</param>
    procedure InternalWriteLn(const s : string); virtual; abstract;
    /// <summary>Writes text, indented, with no line break.</summary>
    /// <param name="s">The text, already wrapped to fit.</param>
    procedure InternalWrite(const s : string); virtual; abstract;
    /// <summary>Increases the indent.</summary>
    /// <param name="value">The number of spaces to add.</param>
    procedure Indent(const value : integer = 1);
    /// <summary>Decreases the indent, never below 0.</summary>
    /// <param name="value">The number of spaces to remove.</param>
    procedure Outdent(const value : integer = 1);
    /// <summary>Console width in characters, used for wrapping and to clamp the indent.</summary>
    property ConsoleWidth : integer read FConsoleWidth write FConsoleWidth;
    /// <summary>True when standard output is redirected rather than a console.</summary>
    property RedirectedStdOut : boolean read FRedirectedStdOut write FRedirectedStdOut;
  public
    /// <summary>Creates a writer with no indent and an 80-character console width.</summary>
    constructor Create; virtual;
    /// <summary>Sets the colours used for subsequent output.</summary>
    /// <param name="foreground">The text colour.</param>
    /// <param name="background">The background colour; <c>ccDefault</c> restores the original.</param>
    procedure SetColour(const foreground : TConsoleColour; const background : TConsoleColour = ccDefault); virtual; abstract;
    /// <summary>Writes text followed by a line break, every wrapped line through <c>InternalWriteLn</c>.</summary>
    /// <param name="s">The text to write; may contain line breaks.</param>
    procedure WriteLn(const s : string); overload; virtual;
    /// <summary>Writes an empty line.</summary>
    procedure WriteLn; overload; virtual;
    /// <summary>
    ///   Writes text with no trailing line break: every wrapped line but the last through <c>InternalWriteLn</c>, the
    ///   last through <c>InternalWrite</c>.
    /// </summary>
    /// <param name="s">The text to write; may contain line breaks.</param>
    procedure Write(const s : string); virtual;
    /// <summary>The number of spaces each line is indented by.</summary>
    property CurrentIndentLevel : Integer read GetIndent write SetIndent;
  end;

implementation

{ TDUnitXConsoleWriterBase }

uses
{$IFDEF USE_NS}
  System.Types,
  System.StrUtils,
  System.SysUtils;
{$ELSE}
  Types,
  StrUtils,
  SysUtils;
{$ENDIF}

const
  DEFAULT_CONSOLE_WIDTH = 80;
  MINIMUM_CONSOLE_WIDTH = 2;

constructor TDUnitXConsoleWriterBase.Create;
begin
  FConsoleWidth := DEFAULT_CONSOLE_WIDTH;
  FIndent := 0;
end;

function TDUnitXConsoleWriterBase.GetIndent : Integer;
begin
  result := FIndent;
end;

procedure TDUnitXConsoleWriterBase.Indent(const value : integer);
begin
  SetIndent(FIndent + value);
end;

function TDUnitXConsoleWriterBase.InternalBreakupMessage(const s : string) : TStringList;
var
  line : string;
  offset, width, len : Integer;
  slLines : TStringList;
begin
  Result := TStringList.Create;

  //If we are blank string, add on line entry and leave.
  if s = '' then
  begin
    Result.Add('');
    Exit;
  end;

  width := FConsoleWidth - FIndent;
  slLines := TStringList.Create;
  try
    slLines.StrictDelimiter := True;
    slLines.Text := s;

    //Walk through the string list pulling of the console width of characters at a time.
    for line in slLines do
    begin
{$IFDEF NEXTGEN}
      len := line.Length;
{$ELSE}
      len := Length(line);
{$ENDIF}

      if (width > 0) and (len > width) then
      begin
        offset := 1;
        while offset <= len do
        begin
          //Write a line as we have hit the limit of the console.
{$IFDEF NEXTGEN}
          Result.Add(line.Substring(offset - 1, width));
{$ELSE}
          Result.Add(Copy(line, offset, width));
{$ENDIF}
          Inc(offset, width);
        end;
      end
      else
        //Can write out on a single line
        Result.Add(line);
    end;
  finally
    slLines.Free;
  end;
end;

procedure TDUnitXConsoleWriterBase.Outdent(const value : integer);
begin
  SetIndent(FIndent - value);
end;

procedure TDUnitXConsoleWriterBase.SetIndent(const count : Integer);
begin
  if Count < 0 then
    FIndent := 0
  else
  begin
    FIndent := count;
    if not FRedirectedStdOut then
    begin
      if FIndent > FConsoleWidth - MINIMUM_CONSOLE_WIDTH then
        FIndent := FConsoleWidth - MINIMUM_CONSOLE_WIDTH;
    end;
  end;
end;

procedure TDUnitXConsoleWriterBase.Write(const s : string);
var
  // offset, width, len : Integer;
  slLines : TStringList;
  iLineIndx : integer;
begin
  slLines := InternalBreakupMessage(s);
  try
    //Write out all the lines except the last one.
    for iLineIndx := 0 to slLines.Count - 2 do
      InternalWriteLn(slLines[iLineIndx]);

    //Now write out the last one without an end of line character.
    if slLines.Count > 0 then
      InternalWrite(slLines[slLines.Count - 1]);
  finally
    FreeAndNil(slLines);
  end;

end;

procedure TDUnitXConsoleWriterBase.WriteLn;
begin
  WriteLn('');
end;

procedure TDUnitXConsoleWriterBase.WriteLn(const s : string);
var
  // offset, width, len : Integer;
  slLines : TStringList;
  iLineIndx : integer;
begin
  slLines := InternalBreakupMessage(s);
  try
    //Write out all the lines except the last one.
    for iLineIndx := 0 to slLines.Count - 1 do
      InternalWriteLn(slLines[iLineIndx]);
  finally
    FreeAndNil(slLines);
  end;
end;

end.

