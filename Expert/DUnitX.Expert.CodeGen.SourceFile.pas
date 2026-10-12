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

unit DUnitX.Expert.CodeGen.SourceFile;

interface

{$I DUnitX.inc}

uses
  System.SysUtils,
  System.Classes,
  ToolsAPI;

type
  /// <summary>
  ///   In-memory IOTAFile handed to the IDE by the creators: holds source text formatted from a template.
  /// </summary>
  TSourceFile = class(TInterfacedObject, IOTAFile)
  private
    /// <summary>The formatted source text returned to the IDE.</summary>
    FSource : string;
  public
    /// <summary>
    ///   Gives the IDE the file's content (IOTAFile).
    /// </summary>
    /// <returns>
    ///   The source text formatted in the constructor.
    /// </returns>
    function GetSource : string;
    /// <summary>
    ///   Gives the IDE the file's timestamp (IOTAFile).
    /// </summary>
    /// <returns>
    ///   The current date and time.
    /// </returns>
    function GetAge : TDateTime;
    /// <summary>
    ///   Creates the file by formatting a source template with <c>Format</c>.
    /// </summary>
    /// <param name="Source">
    ///   Template text with <c>%s</c>-style format specifiers.
    /// </param>
    /// <param name="Args">
    ///   Values substituted into the template's specifiers, in order.
    /// </param>
    /// <exception cref="EConvertError">
    ///   When <paramref name="Args" /> does not match the template's specifiers.
    /// </exception>
    constructor Create(const Source : string; const Args : array of const);
  end;

implementation

{ TSourceFile }

constructor TSourceFile.Create(const Source : string; const Args : array of const);
begin
  FSource := Format(Source, Args);
end;

function TSourceFile.GetAge : TDateTime;
begin
  result := now;
end;

function TSourceFile.GetSource : string;
begin
  result := FSource;
end;

end.

