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

unit DUnitX.Tests.ConsoleWriter.Base;

interface

{$I DUnitX.inc}

uses
{$IFDEF USE_NS}
  System.Classes,
{$ELSE}
  Classes,
{$ENDIF}
  DUnitX.TestFramework,
  DUnitX.ConsoleWriter.Base;

type
{$M+}
  /// <summary>
  ///   Console writer exposing what the base class's wrapping logic actually emitted, so tests can count and
  ///   reassemble the physical lines a Write or WriteLn produced.
  /// </summary>
  IDUnitXConsoleWriterTester = interface(IDUnitXConsoleWriter)
    ['{F5A84F9E-69A8-479E-9321-E1C528E09B92}']
    /// <summary>
    ///   Reads the console width the wrapping logic is using.
    /// </summary>
    /// <returns>
    ///   The width in characters.
    /// </returns>
    function GetConsoleWidth : integer;
    /// <summary>
    ///   Sets the console width the wrapping logic wraps at.
    /// </summary>
    /// <param name="Value">
    ///   The width in characters.
    /// </param>
    procedure SetConsoleWidth(const Value : integer);

    /// <summary>
    ///   Returns the physical lines written so far, one entry per console line.
    /// </summary>
    /// <returns>
    ///   The writer's own list of written lines; owned by the writer, do not free.
    /// </returns>
    function WrittenLines : TStringList;
    /// <summary>
    ///   Console width in characters at which the base writer wraps output.
    /// </summary>
    property ConsoleWidth : integer read GetConsoleWidth write SetConsoleWidth;
  end;
{$M-}

  /// <summary>
  ///   Which console-writer call a shared test helper should make.
  /// </summary>
  TWriteMethod = (
    /// <summary>Call Write (no line terminator).</summary>
    Write,
    /// <summary>Call WriteLn (terminate the line).</summary>
    WriteLn
  );

{$M+}
  /// <summary>
  ///   Tests for <c>TDUnitXConsoleWriterBase</c>'s line wrapping: how many physical lines a Write or WriteLn of a
  ///   given length produces against a fixed console width, and that no characters are lost or duplicated.
  /// </summary>
  [TestFixture]
  TDUnitX_ConsoleWriterBaseTests = class
  private
    /// <summary>
    ///   Writes a string of digits of the given length and asserts the writer produced the expected number of
    ///   physical lines whose concatenation is the original string.
    /// </summary>
    /// <param name="AWriteMethod">
    ///   Whether to call Write or WriteLn.
    /// </param>
    /// <param name="AWriter">
    ///   The writer under test, with its console width already set.
    /// </param>
    /// <param name="ALength">
    ///   Length of the string to write.
    /// </param>
    /// <param name="ANumberOfLines">
    ///   Number of physical lines expected.
    /// </param>
    /// <exception cref="ETestFailure">
    ///   Raised (via Assert) when the line count or reassembled text differs from the expectation.
    /// </exception>
    procedure After_Write_String_Of_Length_Expect_X_Lines_Written(const AWriteMethod : TWriteMethod; const AWriter :
      IDUnitXConsoleWriterTester; const ALength : Integer; const ANumberOfLines : Integer);
  public
    /// <summary>
    ///   Proves a WriteLn of exactly the console width fits on one line, with no spurious wrap at the boundary.
    /// </summary>
    [Test]
    procedure After_WriteLn_String_Of_ConsoleWidth_Length_Expect_One_Line_Is_Written;
    /// <summary>
    ///   Proves a WriteLn one character longer than the console width wraps to two lines without losing text.
    /// </summary>
    [Test]
    procedure After_WriteLn_String_Of_One_More_Than_ConsoleWidth_Length_Expect_Two_Lines_Are_Written;

    /// <summary>
    ///   Proves a Write of exactly the console width produces a single line.
    /// </summary>
    [Test]
    procedure After_Write_String_Of_ConsoleWidth_Length_Expect_Single_Line_Is_Written;
    /// <summary>
    ///   Proves a Write shorter than the console width produces a single line.
    /// </summary>
    [Test]
    procedure After_Write_String_Of_One_Less_Than_ConsoleWidth_Length_Expect_Single_Line_Is_Written;
    /// <summary>
    ///   Proves a Write one character longer than the console width wraps to two lines without losing text.
    /// </summary>
    [Test]
    procedure After_Write_String_Of_One_More_Than_ConsoleWidth_Length_Expect_Two_Lines_Are_Written;
    /// <summary>
    ///   Proves an embedded CRLF in a Write splits the text into two physical lines that rejoin, with the CRLF, to
    ///   the original message (the name's "one line" predates the assertion of two).
    /// </summary>
    [Test]
    procedure After_Write_String_With_CRLF_Expect_One_Line_Is_Written;

    /// <summary>
    ///   Documents a known limitation: two consecutive Writes whose combined length exceeds the width stay on one
    ///   line, because the base class leaves line tracking across calls to the implementing writer.
    /// </summary>
    [Test]
    procedure After_Write_Two_Strings_Of_One_Less_Than_ConsoleWidth_Length_Expect_No_New_Line;
    /// <summary>
    ///   Documents a known limitation: a Write followed by a WriteLn yields two lines rather than continuing the
    ///   first, because the base class does not track what the previous call left on the line.
    /// </summary>
    [Test]
    procedure After_Write_Then_WriteLn_Two_Strings_Of_One_Less_Than_ConsoleWidth_Length_Expect_No_New_Line;
  end;
{$M-}

implementation

uses
{$IFDEF USE_NS}
  System.SysUtils;
{$ELSE}
  SysUtils;
{$ENDIF}

type
  TDUnitXConsoleWriterTester = class(TDUnitXConsoleWriterBase, IDUnitXConsoleWriterTester)
  private
    FLastLine : string;
    FWrittenLine : TStringList;
  protected
    function GetConsoleWidth : integer;
    procedure SetConsoleWidth(const Value : integer);
  public
    procedure InternalWriteLn(const s : string); override;
    procedure InternalWrite(const s : string); override;
    function WrittenLines : TStringList;
    procedure SetColour(const foreground : TConsoleColour; const background : TConsoleColour = ccDefault); override;

    constructor Create; override;
    destructor Destroy; override;

    property ConsoleWidth;
  end;

  { TDUnitX_ConsoleWriterBaseTests }

function StringOfNumbers(const ALength : integer) : string;
var
  iIndx : Integer;
begin
  SetLength(Result, ALength);

  for iIndx := 0 to ALength - 1 do
    Result[iIndx + 1] := Char(48 + (iIndx mod 10));
end;

procedure TDUnitX_ConsoleWriterBaseTests.After_Write_String_Of_Length_Expect_X_Lines_Written(const AWriteMethod : TWriteMethod; const
  AWriter : IDUnitXConsoleWriterTester; const ALength, ANumberOfLines : Integer);
var
  sWidthString : string;
  sLine : string;
  sLines : string;
begin
  sWidthString := StringOfNumbers(ALength);

  case AWriteMethod of
    TWriteMethod.Write : AWriter.Write(sWidthString);
    TWriteMethod.WriteLn : AWriter.WriteLn(sWidthString);
  end;

  Assert.IsNotNull(AWriter.WrittenLines);
  Assert.AreEqual(AWriter.WrittenLines.Count, ANumberOfLines);

  for sLine in AWriter.WrittenLines do
    sLines := sLines + sLine;

  Assert.AreEqual(sLines, sWidthString);
end;

procedure TDUnitX_ConsoleWriterBaseTests.After_WriteLn_String_Of_ConsoleWidth_Length_Expect_One_Line_Is_Written;
var
  consoleWriterSUT : IDUnitXConsoleWriterTester;
begin
  consoleWriterSUT := TDUnitXConsoleWriterTester.Create;
  consoleWriterSUT.ConsoleWidth := 20;

  After_Write_String_Of_Length_Expect_X_Lines_Written(TWriteMethod.WriteLn,
    consoleWriterSUT,
    consoleWriterSUT.ConsoleWidth,
    1);
end;

procedure TDUnitX_ConsoleWriterBaseTests.After_WriteLn_String_Of_One_More_Than_ConsoleWidth_Length_Expect_Two_Lines_Are_Written;
var
  consoleWriterSUT : IDUnitXConsoleWriterTester;
begin
  consoleWriterSUT := TDUnitXConsoleWriterTester.Create;
  consoleWriterSUT.ConsoleWidth := 20;

  After_Write_String_Of_Length_Expect_X_Lines_Written(TWriteMethod.WriteLn,
    consoleWriterSUT,
    consoleWriterSUT.ConsoleWidth + 1,
    2);
end;

procedure TDUnitX_ConsoleWriterBaseTests.After_Write_String_Of_ConsoleWidth_Length_Expect_Single_Line_Is_Written;
var
  consoleWriterSUT : IDUnitXConsoleWriterTester;
begin
  consoleWriterSUT := TDUnitXConsoleWriterTester.Create;
  consoleWriterSUT.ConsoleWidth := 20;

  After_Write_String_Of_Length_Expect_X_Lines_Written(TWriteMethod.Write,
    consoleWriterSUT,
    consoleWriterSUT.ConsoleWidth,
    1);
end;

procedure TDUnitX_ConsoleWriterBaseTests.After_Write_String_Of_One_Less_Than_ConsoleWidth_Length_Expect_Single_Line_Is_Written;
var
  consoleWriterSUT : IDUnitXConsoleWriterTester;
begin
  consoleWriterSUT := TDUnitXConsoleWriterTester.Create;
  consoleWriterSUT.ConsoleWidth := 20;

  After_Write_String_Of_Length_Expect_X_Lines_Written(TWriteMethod.Write,
    consoleWriterSUT,
    consoleWriterSUT.ConsoleWidth - 1,
    1);
end;

procedure TDUnitX_ConsoleWriterBaseTests.After_Write_String_Of_One_More_Than_ConsoleWidth_Length_Expect_Two_Lines_Are_Written;
var
  consoleWriterSUT : IDUnitXConsoleWriterTester;
begin
  consoleWriterSUT := TDUnitXConsoleWriterTester.Create;
  consoleWriterSUT.ConsoleWidth := 20;

  After_Write_String_Of_Length_Expect_X_Lines_Written(TWriteMethod.Write,
    consoleWriterSUT,
    consoleWriterSUT.ConsoleWidth + 1,
    2);
end;

procedure TDUnitX_ConsoleWriterBaseTests.After_Write_String_With_CRLF_Expect_One_Line_Is_Written;
var
  consoleWriterSUT : IDUnitXConsoleWriterTester;

  sMessage : string;
  sLines : string;
  iLineIndx : integer;
begin
  consoleWriterSUT := TDUnitXConsoleWriterTester.Create;

  sMessage := '0' + #13#10 + '1';
  consoleWriterSUT.Write(sMessage);

  Assert.IsNotNull(consoleWriterSUT.WrittenLines);
  Assert.AreEqual(consoleWriterSUT.WrittenLines.Count, 2);

  for iLineIndx := 0 to consoleWriterSUT.WrittenLines.Count - 1 do
  begin
    if iLineIndx <> 0 then
      sLines := sLines + #13#10;

    sLines := sLines + consoleWriterSUT.WrittenLines[iLineIndx];
  end;

  Assert.AreEqual(sLines, sMessage);
end;

procedure TDUnitX_ConsoleWriterBaseTests.After_Write_Then_WriteLn_Two_Strings_Of_One_Less_Than_ConsoleWidth_Length_Expect_No_New_Line;
var
  consoleWriterSUT : IDUnitXConsoleWriterTester;

  sWidthString : string;
  sLine : string;
  sLines : string;
begin
  //TODO: This is a failing of this class. It pushes the responibility of the write call working out
  //whether or not to add a new line based on what was called prior to it. This case shows that a
  //write call followed by a write line does not call to writeln as it should.
  consoleWriterSUT := TDUnitXConsoleWriterTester.Create;
  consoleWriterSUT.ConsoleWidth := 20;

  sWidthString := StringOfNumbers(consoleWriterSUT.ConsoleWidth - 1);

  //Write the first line.
  consoleWriterSUT.Write(sWidthString);
  //Write the second line.
  consoleWriterSUT.WriteLn(sWidthString);

  Assert.IsNotNull(consoleWriterSUT.WrittenLines);
  Assert.AreEqual(consoleWriterSUT.WrittenLines.Count, 2);

  for sLine in consoleWriterSUT.WrittenLines do
    sLines := sLines + sLine;

  Assert.AreEqual(sLines, sWidthString + sWidthString);
end;

procedure TDUnitX_ConsoleWriterBaseTests.After_Write_Two_Strings_Of_One_Less_Than_ConsoleWidth_Length_Expect_No_New_Line;
var
  consoleWriterSUT : IDUnitXConsoleWriterTester;

  sWidthString : string;
  sLine : string;
  sLines : string;
begin
  //TODO: This is a failing of this class. It pushes the responibility of the write call working out
  //whether or not to add a new line based on what was called prior to it. This case shows that two
  //write calls in a row, which are over the console width don't force a writeln call.
  consoleWriterSUT := TDUnitXConsoleWriterTester.Create;
  consoleWriterSUT.ConsoleWidth := 20;

  sWidthString := StringOfNumbers(consoleWriterSUT.ConsoleWidth - 1);

  //Write the first line.
  consoleWriterSUT.Write(sWidthString);
  //Write the second line.
  consoleWriterSUT.Write(sWidthString);

  Assert.IsNotNull(consoleWriterSUT.WrittenLines);
  Assert.AreEqual(consoleWriterSUT.WrittenLines.Count, 1);

  for sLine in consoleWriterSUT.WrittenLines do
    sLines := sLines + sLine;

  Assert.AreEqual(sLines, sWidthString + sWidthString);
end;

{ TDUnitXConsoleWriterTester }

constructor TDUnitXConsoleWriterTester.Create;
begin
  inherited Create;
  FWrittenLine := TStringList.Create;
  FLastLine := '';
end;

destructor TDUnitXConsoleWriterTester.Destroy;
begin
  FreeAndNil(FWrittenLine);
  inherited;
end;

function TDUnitXConsoleWriterTester.GetConsoleWidth : integer;
begin
  Result := ConsoleWidth;
end;

procedure TDUnitXConsoleWriterTester.InternalWrite(const s : string);
begin
  inherited;

  //TODO: This shows that the implementing class of TDUnitXConsoleWriterBase needs
  //to keep track of written lines if it wants to handle write lines after writes.
  if FWrittenLine.Count = 0 then
  begin
    FLastLine := FLastLine + s;
    FWrittenLine.Add(FLastLine);
    Exit;
  end
  else
  begin
    if FWrittenLine[FWrittenLine.Count - 1] = FLastLine then
    begin
      FLastLine := FLastLine + s;
      FWrittenLine[FWrittenLine.Count - 1] := FLastLine;
      Exit;
    end
    else
    begin
      FLastLine := s;
      FWrittenLine.Add(FLastLine);
    end;
  end;
end;

procedure TDUnitXConsoleWriterTester.InternalWriteLn(const s : string);
begin
  inherited;
  FWrittenLine.Add(s);
  FLastLine := '';
end;

procedure TDUnitXConsoleWriterTester.SetColour(const foreground, background : TConsoleColour);
begin
  inherited;
end;

procedure TDUnitXConsoleWriterTester.SetConsoleWidth(const Value : integer);
begin
  ConsoleWidth := Value;
end;

function TDUnitXConsoleWriterTester.WrittenLines : TStringList;
begin
  Result := FWrittenLine;
end;

initialization
  TDUnitX.RegisterTestFixture(TDUnitX_ConsoleWriterBaseTests);

end.

