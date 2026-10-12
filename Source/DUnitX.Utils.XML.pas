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

unit DUnitX.Utils.XML;

interface

{$I DUnitX.inc}

/// <summary>
///   Reports whether a UTF-16 code unit may appear in an XML 1.0 document: tab, line feed, carriage return, the
///   printable BMP ranges and either half of a surrogate pair. Every other C0 control (form feed included) is invalid.
/// </summary>
/// <param name="wc">
///   The code unit to test.
/// </param>
/// <returns>
///   True when the code unit is legal in XML 1.0 text; otherwise False.
/// </returns>
function IsValidXMLChar(const wc : WideChar) : Boolean;
/// <summary>
///   Returns a copy of a string with every code unit that XML 1.0 forbids replaced by a space, so the length is kept.
/// </summary>
/// <param name="s">
///   The text to clean.
/// </param>
/// <returns>
///   The text with each invalid XML character replaced by a space.
/// </returns>
function StripInvalidXML(const s : string) : string;
/// <summary>
///   Makes a string safe to write into an XML document: invalid characters are stripped (see
///   <c>StripInvalidXML</c>), then the text is escaped for element content, an attribute value or a CDATA section.
/// </summary>
/// <param name="value">
///   The raw text to escape.
/// </param>
/// <param name="isAttribute">
///   True to also escape single and double quotes, as an attribute value requires.
/// </param>
/// <param name="isCDATASection">
///   True when the text goes inside a CDATA section: entities are not used; instead each <c>]]&gt;</c> is split across
///   two adjacent CDATA sections so that a parser reads back the original text.
/// </param>
/// <returns>
///   The escaped text.
/// </returns>
function EscapeForXML(const value : string; const isAttribute : boolean = True; const isCDATASection : Boolean = False) : string;

implementation

uses
{$IFDEF USE_NS}
  System.SysUtils;
{$ELSE}
  SysUtils;
{$ENDIF}

function IsValidXMLChar(const wc : WideChar) : Boolean;
begin
  case Word(wc) of
    $0009, $000A, $000D,                // XML 1.0 forbids every other C0 control, form feed ($0C) included
    $0020..$D7FF,
    $E000..$FFFD,                       // Standard Unicode chars below $FFFF
    $D800..$DBFF,                       // High surrogate of Unicode character  = $10000 - $10FFFF
    $DC00..$DFFF :                      // Low surrogate of Unicode character  = $10000 - $10FFFF
      result := True;
  else
    result := False;
  end;
end;

function StripInvalidXML(const s : string) : string;
var
  i, count : Integer;
begin
{$IFNDEF NEXTGEN}
  count := Length(s);
  setLength(result, count);
  for i := 1 to Count do                // Iterate
  begin
    if IsValidXMLChar(WideChar(s[i])) then
      result[i] := s[i]
    else
      result[i] := ' ';
  end;                                  // for}
{$ELSE}
  count := s.Length;
  SetLength(result, count);
  for i := 0 to count - 1 do            // Iterate
  begin
    if IsValidXMLChar(s.Chars[i]) then
    begin
      result := result.Remove(i, 1);
      result := result.Insert(i, s.Chars[i]);
    end
    else
    begin
      result := result.Remove(i, 1);
      result := result.Insert(i, s.Chars[i]);
    end;
  end;                                  // for}
{$ENDIF}
end;

function EscapeForXML(const value : string; const isAttribute : boolean = True; const isCDATASection : Boolean = False) : string;
begin
  result := StripInvalidXML(value);
{$IFNDEF NEXTGEN}
  if isCDATASection then
  begin
    //A CDATA section cannot contain ']]>', so the text is split there into two adjacent sections, which an XML
    //parser reads back as the original text. (Replacing it with ']>' changed the text, and turned ']]]>' into a
    //']]>' that ended the section early.)
    Result := StringReplace(Result, ']]>', ']]]]><![CDATA[>', [rfReplaceAll]);
    exit;
  end;

  //An existing "&amp;" is escaped like any other "&" (to "&amp;amp;"), so the text reads back exactly as given.
  Result := StringReplace(result, '&amp;', '[[-xy-amp--]]', [rfReplaceAll]);
  Result := StringReplace(result, '&', '&amp;', [rfReplaceAll]);
  Result := StringReplace(result, '[[-xy-amp--]]', '&amp;amp;', [rfReplaceAll]);
  Result := StringReplace(result, '<', '&lt;', [rfReplaceAll]);
  Result := StringReplace(result, '>', '&gt;', [rfReplaceAll]);

  if isAttribute then
  begin
    Result := StringReplace(result, '''', '&#39;', [rfReplaceAll]);
    Result := StringReplace(result, '"', '&quot;', [rfReplaceAll]);
  end;
{$ELSE}
  if isCDATASection then
  begin
    Result := Result.Replace(']]>', ']>', [rfReplaceAll]);
    exit;
  end;

  //An existing "&amp;" is escaped like any other "&" (to "&amp;amp;"), so the text reads back exactly as given.
  Result := Result.Replace('&amp;', '[[-xy-amp--]]', [rfReplaceAll]);
  Result := Result.Replace('&', '&amp;', [rfReplaceAll]);
  Result := Result.Replace('[[-xy-amp--]]', '&amp;amp;', [rfReplaceAll]);
  Result := Result.Replace('<', '&lt;', [rfReplaceAll]);
  Result := Result.Replace('>', '&gt;', [rfReplaceAll]);

  if isAttribute then
  begin
    Result := Result.Replace('''', '&#39;', [rfReplaceAll]);
    Result := Result.Replace('"', '&quot;', [rfReplaceAll]);
  end;
{$ENDIF}
end;

end.

