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

unit DUnitX.Windows.Console;

interface

{$I DUnitX.inc}
uses
{$IFDEF USE_NS}
  System.Classes,
{$ELSE}
  Classes,
{$ENDIF}
  DUnitX.ConsoleWriter.Base;

type
  /// <summary>
  ///   Console writer for Windows: writes to standard output with <c>WriteConsoleW</c> (or <c>System.Write</c> when
  ///   output is redirected), colours text with console attributes, and restores the original colours when freed.
  ///   Registered as the <c>IDUnitXConsoleWriter</c> implementation when this unit initialises.
  /// </summary>
  TDUnitXWindowsConsoleWriter = class(TDUnitXConsoleWriterBase)
  private
    /// <summary>Foreground attribute bits in effect when the writer was created; what <c>ccDefault</c> maps to.</summary>
    FDefaultForeground : Word;
    /// <summary>Background attribute bits in effect when the writer was created; what <c>ccDefault</c> maps to.</summary>
    FDefaultBackground : Word;
    /// <summary>Foreground colour last applied, so an unchanged <c>SetColour</c> call is skipped.</summary>
    FLastForeground : TConsoleColour;
    /// <summary>Background colour last applied, so an unchanged <c>SetColour</c> call is skipped.</summary>
    FLastBackground : TConsoleColour;
    /// <summary>The standard output handle.</summary>
    FStdOut : THandle;
    /// <summary>Maps a colour to its Windows console foreground attribute bits.</summary>
    /// <param name="cc">The colour to map.</param>
    /// <returns>The <c>FOREGROUND_*</c> bits; for <c>ccDefault</c>, the original foreground.</returns>
    function GetForegroundColourCode(const cc : TConsoleColour) : Word;
    /// <summary>Maps a colour to its Windows console background attribute bits.</summary>
    /// <param name="cc">The colour to map.</param>
    /// <returns>The <c>BACKGROUND_*</c> bits; for <c>ccDefault</c>, the original background.</returns>
    function GetBackgroundColourCode(const cc : TConsoleColour) : Word;
    /// <summary>Reads the console screen buffer width.</summary>
    /// <returns>The buffer width in characters, or <c>High(Integer)</c> (unlimited) when it cannot be read.</returns>
    function GetConsoleWidth : Integer;
  protected
    /// <summary>
    ///   Writes one line, indented, followed by CRLF - except when the line exactly fills its last console row, where
    ///   the console has already wrapped the cursor.
    /// </summary>
    /// <param name="s">The line text, without indent or line break.</param>
    procedure InternalWriteLn(const s : string); override;
    /// <summary>Writes text, indented, with no line break.</summary>
    /// <param name="s">The text to write.</param>
    procedure InternalWrite(const s : string); override;
  public
    /// <summary>Sets the console text colours; does nothing if they are already the last colours applied.</summary>
    /// <param name="foreground">The text colour.</param>
    /// <param name="background">The background colour; <c>ccDefault</c> restores the original.</param>
    procedure SetColour(const foreground : TConsoleColour; const background : TConsoleColour = ccDefault); override;
    /// <summary>
    ///   Opens standard output, detects redirection (not a console handle), reads the console width and saves the
    ///   current colours so they can be restored.
    /// </summary>
    constructor Create; override;
    /// <summary>Restores the original console colours.</summary>
    destructor Destroy; override;
  end;

implementation

uses
{$IFDEF USE_NS}
  WinAPI.Windows,                       // Delphi XE2 (CompilerVersion 23) added scopes in front of unit names
{$ELSE}
  Windows,
{$ENDIF}
  DUnitX.Utils,
  DUnitX.ServiceLocator;

constructor TDUnitXWindowsConsoleWriter.Create;
var
  dummy : Cardinal;
  consoleInfo : _CONSOLE_SCREEN_BUFFER_INFO;
begin
  inherited;

  FStdOut := GetStdHandle(STD_OUTPUT_HANDLE);

  if not GetConsoleMode(FStdOut, dummy) then // Not a console handle
    Self.RedirectedStdOut := True;

  Self.ConsoleWidth := GetConsoleWidth;
  FLastForeground := ccDarkYellow;      // Just to ensure the first colour change goes through
  FLastBackground := ccDarkYellow;

  //Save the current console colour settings so we can restore them:
  if GetConsoleScreenBufferInfo(FStdOut, consoleInfo) then
  begin
    FDefaultForeground := consoleInfo.wAttributes and (FOREGROUND_BLUE or FOREGROUND_GREEN or FOREGROUND_RED or FOREGROUND_INTENSITY);
    FDefaultBackground := consoleInfo.wAttributes and (BACKGROUND_BLUE or BACKGROUND_GREEN or BACKGROUND_RED or BACKGROUND_INTENSITY);
  end
  else
  begin
    FDefaultForeground := GetForegroundColourCode(ccWhite);
    FDefaultBackground := GetBackgroundColourCode(ccBlack);
  end;
end;

procedure TDUnitXWindowsConsoleWriter.SetColour(const foreground, background : TConsoleColour);
begin
  if (FLastForeground <> foreground) or (FLastBackground <> background) then
  begin
    SetConsoleTextAttribute(FStdOut,
      GetForegroundColourCode(foreground) or
      GetBackgroundColourCode(background));

    FLastForeground := foreground;
    FLastBackground := background;
  end;
end;

function TDUnitXWindowsConsoleWriter.GetForegroundColourCode(const cc : TConsoleColour) : Word;
begin
  case cc of
    ccDefault : Result := FDefaultForeground;
    ccBrightRed : Result := FOREGROUND_RED or FOREGROUND_INTENSITY;
    ccDarkRed : Result := FOREGROUND_RED;
    ccBrightBlue : Result := FOREGROUND_BLUE or FOREGROUND_INTENSITY;
    ccDarkBlue : Result := FOREGROUND_BLUE;
    ccBrightGreen : Result := FOREGROUND_GREEN or FOREGROUND_INTENSITY;
    ccDarkGreen : Result := FOREGROUND_GREEN;
    ccBrightYellow : Result := FOREGROUND_GREEN or FOREGROUND_RED or FOREGROUND_INTENSITY;
    ccDarkYellow : Result := FOREGROUND_GREEN or FOREGROUND_RED;
    ccBrightAqua : Result := FOREGROUND_GREEN or FOREGROUND_BLUE or FOREGROUND_INTENSITY;
    ccDarkAqua : Result := FOREGROUND_GREEN or FOREGROUND_BLUE;
    ccBrightPurple : Result := FOREGROUND_BLUE or FOREGROUND_RED or FOREGROUND_INTENSITY;
    ccDarkPurple : Result := FOREGROUND_BLUE or FOREGROUND_RED;
    ccGrey : Result := FOREGROUND_INTENSITY;
    ccBlack : Result := 0;
    ccBrightWhite : Result := FOREGROUND_BLUE or FOREGROUND_GREEN or FOREGROUND_RED or FOREGROUND_INTENSITY;
    ccWhite : Result := FOREGROUND_BLUE or FOREGROUND_GREEN or FOREGROUND_RED;
  else
    Result := 0;
  end;
end;

procedure TDUnitXWindowsConsoleWriter.InternalWrite(const s : string);
var
  output : string;
  dummy : Cardinal;
begin
  //Add the indenting.
  output := TStrUtils.PadString(s, length(s) + Self.CurrentIndentLevel, True, ' ');
  if Self.RedirectedStdOut then
    System.Write(output)
  else
    WriteConsoleW(FStdOut, PWideChar(output), Length(output), dummy, nil);
end;

procedure TDUnitXWindowsConsoleWriter.InternalWriteLn(const s : string);
var
  output : string;
  dummy : Cardinal;
begin
  //Add the indenting.
  output := TStrUtils.PadString(s, length(s) + Self.CurrentIndentLevel, True, ' ');

  //A line that exactly fills the last console row it reaches has already moved the cursor to the next line; any other
  //line, longer than the width or not, still needs its CRLF (dropping it for every long line ran the next line on).
  if (ConsoleWidth <= 0) or (Length(output) = 0) or (Length(output) mod ConsoleWidth <> 0) then
    output := output + #13#10;

  if Self.RedirectedStdOut then
    System.Write(output)
  else
    WriteConsoleW(FStdOut, PWideChar(output), Length(output), dummy, nil);
end;

destructor TDUnitXWindowsConsoleWriter.Destroy;
begin
  SetColour(ccDefault);                 // Restore default console colours
  inherited;
end;

function TDUnitXWindowsConsoleWriter.GetBackgroundColourCode(const cc : TConsoleColour) : Word;
begin
  case cc of
    ccDefault : Result := FDefaultBackground;
    ccBrightRed : Result := BACKGROUND_RED or BACKGROUND_INTENSITY;
    ccDarkRed : Result := BACKGROUND_RED;
    ccBrightBlue : Result := BACKGROUND_BLUE or BACKGROUND_INTENSITY;
    ccDarkBlue : Result := BACKGROUND_BLUE;
    ccBrightGreen : Result := BACKGROUND_GREEN or BACKGROUND_INTENSITY;
    ccDarkGreen : Result := BACKGROUND_GREEN;
    ccBrightYellow : Result := BACKGROUND_GREEN or BACKGROUND_RED or BACKGROUND_INTENSITY;
    ccDarkYellow : Result := BACKGROUND_GREEN or BACKGROUND_RED;
    ccBrightAqua : Result := BACKGROUND_GREEN or BACKGROUND_BLUE or BACKGROUND_INTENSITY;
    ccDarkAqua : Result := BACKGROUND_GREEN or BACKGROUND_BLUE;
    ccBrightPurple : Result := BACKGROUND_BLUE or BACKGROUND_RED or BACKGROUND_INTENSITY;
    ccDarkPurple : Result := BACKGROUND_BLUE or BACKGROUND_RED;
    ccGrey : Result := BACKGROUND_INTENSITY;
    ccBlack : Result := 0;
    ccBrightWhite : Result := BACKGROUND_BLUE or BACKGROUND_GREEN or BACKGROUND_RED or BACKGROUND_INTENSITY;
    ccWhite : Result := BACKGROUND_BLUE or BACKGROUND_GREEN or BACKGROUND_RED;
  else
    Result := 0;
  end;
end;

function TDUnitXWindowsConsoleWriter.GetConsoleWidth : Integer;
var
  info : CONSOLE_SCREEN_BUFFER_INFO;
begin
  Result := High(Integer);              // Default is unlimited width
  if GetConsoleScreenBufferInfo(FStdOut, info) then
    Result := info.dwSize.X;
end;

initialization
  TDUnitXServiceLocator.DefaultContainer.RegisterType<IDUnitXConsoleWriter, TDUnitXWindowsConsoleWriter>;
  //    TDUnitXServiceLocator.DefaultContainer.RegisterType<IDUnitXConsoleWriter>(
  //        function : IDUnitXConsoleWriter
  //        begin
  //          Result := TDUnitXWindowsConsoleWriter.Create;
  //        end
  //    );
end.

