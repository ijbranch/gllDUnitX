{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2012 Vincent Parrett                              }
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

unit DUnitX.Tests.Utils.XML;

interface

uses
  DUnitX.TestFramework;

type
  /// <summary>
  ///   Tests for the XML helpers in <c>DUnitX.Utils.XML</c> that the XML loggers rely on to write well-formed output.
  /// </summary>
  [TestFixture]
  TUtilsXMLTests = class
  public
    /// <summary>
    ///   Proves form feed (#$0C) is rejected: XML 1.0 forbids it, so a message containing one made ill-formed XML.
    ///   Also checks NUL and #$1F are rejected, tab, LF and CR accepted, and StripInvalidXML replaces the form feed.
    /// </summary>
    [Test]
    procedure IsValidXMLChar_Rejects_Characters_XML_Forbids;
    /// <summary>
    ///   Proves EscapeForXML's CDATA form keeps a message whole: wrapped as the loggers wrap it, the text an XML
    ///   parser reads back is the original, including ']]&gt;' and ']]]&gt;'. Replacing ']]&gt;' with ']&gt;' changed
    ///   the text, and turned ']]]&gt;' into a ']]&gt;' that ended the section early (ill-formed XML).
    /// </summary>
    [Test]
    procedure EscapeForXML_CDATA_Round_Trips;
  end;

implementation

uses
  System.SysUtils,
  DUnitX.Utils.XML;

//Reads AXml as an XML parser reads character data that consists only of adjacent CDATA sections, and returns the
//text. Raises EConvertError if anything else is found between or after the sections.
function ReadCDATASections(const AXml : string) : string;
const
  CDataOpen = '<![CDATA[';
  CDataClose = ']]>';
var
  position : Integer;
  closing : Integer;
begin
  Result := '';
  position := 1;
  while position <= Length(AXml) do
  begin
    if Copy(AXml, position, Length(CDataOpen)) <> CDataOpen then
      raise EConvertError.CreateFmt('Not a CDATA section at %d: %s', [position, AXml]);
    Inc(position, Length(CDataOpen));
    closing := Pos(CDataClose, AXml, position);
    if closing = 0 then
      raise EConvertError.CreateFmt('Unterminated CDATA section: %s', [AXml]);
    Result := Result + Copy(AXml, position, closing - position);
    position := closing + Length(CDataClose);
  end;
end;

procedure TUtilsXMLTests.EscapeForXML_CDATA_Round_Trips;
var
  text : string;
begin
  for text in ['a]]>b', 'x]]]>y', ']]>]]>', 'plain'] do
    Assert.AreEqual(text, ReadCDATASections('<![CDATA[' + EscapeForXML(text, False, True) + ']]>'), False, text);
end;

procedure TUtilsXMLTests.IsValidXMLChar_Rejects_Characters_XML_Forbids;
begin
  Assert.IsFalse(IsValidXMLChar(#$0C), 'form feed');
  Assert.IsFalse(IsValidXMLChar(#$00), 'NUL');
  Assert.IsFalse(IsValidXMLChar(#$1F), 'unit separator');
  Assert.IsTrue(IsValidXMLChar(#$09), 'tab');
  Assert.IsTrue(IsValidXMLChar(#$0A), 'line feed');
  Assert.IsTrue(IsValidXMLChar(#$0D), 'carriage return');
  Assert.AreEqual('a b', StripInvalidXML('a'#$0C'b'), False, 'StripInvalidXML');
end;

initialization
  TDUnitX.RegisterTestFixture(TUtilsXMLTests);

end.
