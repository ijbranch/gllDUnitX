{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2012 Vincent Parrett                              }
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
  [TestFixture]
  TUtilsXMLTests = class
  public
    // Proves form feed (#$0C) is rejected: XML 1.0 forbids it, so a message containing one made ill-formed XML.
    [Test]
    procedure IsValidXMLChar_Rejects_Characters_XML_Forbids;
  end;

implementation

uses
  DUnitX.Utils.XML;

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
