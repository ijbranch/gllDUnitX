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

unit DUnitX.Loggers.XML.NUnit;

interface

{$I DUnitX.inc}

uses
{$IFDEF USE_NS}
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
{$ELSE}
  Classes,
  SysUtils,
  Generics.Collections,
{$ENDIF}
  DUnitX.TestFramework,
  DUnitX.Loggers.Null;

type
  /// <summary>
  ///   Logger that writes the whole run, once it has finished, as an NUnit 2.x XML results document (UTF-8 with a BOM)
  ///   to a stream, for CI servers that read NUnit results. Memory leaks are reported as failures, since the NUnit
  ///   format has no leak outcome.
  /// </summary>
  TDUnitXXMLNUnitLogger = class(TDUnitXNullLogger)
  private
    /// <summary>The stream the XML is written to.</summary>
    FOutputStream : TStream;
    /// <summary>True when the logger owns <c>FOutputStream</c> and frees it on destruction.</summary>
    FOwnsStream : boolean;
    /// <summary>The current indent of written lines, in spaces.</summary>
    FIndent : integer;
    /// <summary>Invariant number formatting (<c>.</c> decimal, <c>,</c> thousands) so times are valid in any locale.</summary>
    FFormatSettings : TFormatSettings;
  protected
    /// <summary>Increases the indent of following lines by two spaces.</summary>
    procedure Indent;
    /// <summary>Decreases the indent of following lines by two spaces.</summary>
    procedure Outdent;
    /// <summary>Writes one line, at the current indent and terminated by CR LF, to the stream as UTF-8.</summary>
    /// <param name="value">The XML text of the line, already escaped.</param>
    procedure WriteXMLLine(const value : string);

    /// <summary>
    ///   Rolls up the namespace fixtures (<c>IFixtureResult.Reduce</c>), then writes the complete document: the
    ///   <c>test-results</c> root with the run's totals, an assembly <c>test-suite</c>, and every fixture and test.
    /// </summary>
    /// <param name="RunResults">The results of the whole run.</param>
    procedure OnTestingEnds(const RunResults : IRunResults); override;

    /// <summary>Writes a <c>categories</c> element listing each category; writes nothing for an empty list.</summary>
    /// <param name="ACategoryList">The categories of a fixture or test.</param>
    procedure WriteCategoryNodes(const ACategoryList : TList<string>);
    /// <summary>
    ///   Writes a fixture as a <c>test-suite</c> element (type <c>Fixture</c> for a real test class, <c>Namespace</c>
    ///   for a grouping node), recursing into its tests and child fixtures. A real fixture with no results is skipped.
    /// </summary>
    /// <param name="fixtureResult">The fixture's results.</param>
    procedure WriteFixtureResult(const fixtureResult : IFixtureResult);
    /// <summary>
    ///   Writes a test as a <c>test-case</c> element, with a <c>failure</c> (message and stack trace) for a failure,
    ///   error or leak, or a <c>reason</c> for an ignored test.
    /// </summary>
    /// <param name="testResult">The test's result.</param>
    procedure WriteTestResult(const testResult : ITestResult);

    /// <summary>Formats text with the logger's invariant format settings rather than the user's locale.</summary>
    /// <param name="Format">A <c>Format</c> pattern.</param>
    /// <param name="Args">The arguments for the pattern.</param>
    /// <returns>The formatted text.</returns>
    function Format(const Format : string; const Args : array of const) : string;
  public
    /// <summary>Creates the logger and writes the UTF-8 BOM to the stream at once.</summary>
    /// <param name="AOutputStream">The stream to write the XML to.</param>
    /// <param name="AOwnsStream">True to free the stream when the logger is destroyed.</param>
    constructor Create(const AOutputStream : TStream; const AOwnsStream : boolean = false);
    /// <summary>Frees the output stream when owned.</summary>
    destructor Destroy; override;
  end;

  /// <summary>
  ///   NUnit XML logger that writes to a file it creates (replacing any existing file) and owns.
  /// </summary>
  TDUnitXXMLNUnitFileLogger = class(TDUnitXXMLNUnitLogger)
  public
    /// <summary>
    ///   Creates the results file, and its folder when the name includes one, and starts logging to it.
    /// </summary>
    /// <param name="AFilename">
    ///   The results file; empty means <c>dunitx-results.xml</c> beside the executable. A bare file name is created in
    ///   the current folder.
    /// </param>
    /// <exception cref="EFCreateError">The file cannot be created.</exception>
    constructor Create(const AFilename : string = '');
  end;

implementation

uses
  DUnitX.Utils.XML,
{$IFDEF USE_NS}
  System.TypInfo;
{$ELSE}
  TypInfo;
{$ENDIF}

{ TDUnitXXMLNUnitLogger }

constructor TDUnitXXMLNUnitLogger.Create(const AOutputStream : TStream; const AOwnsStream : boolean = false);
var
  preamble : TBytes;
{$IFNDEF DELPHI_XE_UP}
  oldThousandSeparator : Char;
  oldDecimalSeparator : Char;
{$ENDIF}
begin
  inherited Create;
{$IFDEF DELPHI_XE_UP }
  FFormatSettings := TFormatSettings.Create;
{$ENDIF}
  FFormatSettings.ThousandSeparator := ',';
  FFormatSettings.DecimalSeparator := '.';
{$IFNDEF DELPHI_XE_UP}
  oldThousandSeparator := {$IFDEF USE_NS}System.{$ENDIF}SysUtils.ThousandSeparator;
  oldDecimalSeparator := {$IFDEF USE_NS}System.{$ENDIF}DecimalSeparator;
  try
    SysUtils.ThousandSeparator := ',';
    SysUtils.DecimalSeparator := '.';
{$ENDIF}
    FOutputStream := AOutputStream;
    FOwnsStream := AOwnsStream;

    Preamble := TEncoding.UTF8.GetPreamble;
    FOutputStream.WriteBuffer(preamble[0], Length(preamble));
{$IFNDEF DELPHI_XE_UP}
  finally
{$IFDEF USE_NS}System.{$ENDIF}SysUtils.ThousandSeparator := oldThousandSeparator;
{$IFDEF USE_NS}System.{$ENDIF}SysUtils.DecimalSeparator := oldDecimalSeparator;
  end;
{$ENDIF}

end;

destructor TDUnitXXMLNUnitLogger.Destroy;
begin
  if FOwnsStream then
    FOutputStream.Free;
  inherited;
end;

function TDUnitXXMLNUnitLogger.Format(const Format : string; const Args : array of const) : string;
begin
  Result := {$IFDEF USE_NS}System.{$ENDIF}SysUtils.Format(Format, Args, FFormatSettings);
end;

procedure TDUnitXXMLNUnitLogger.Indent;
begin
  Inc(FIndent, 2);
end;

procedure TDUnitXXMLNUnitLogger.OnTestingEnds(const RunResults : IRunResults);

  procedure LogFixture(const fixture : IFixtureResult; level : integer);
  var
    child : IFixtureResult;
    sLevel : string;
  begin
    sLevel := StringOfChar(' ', level * 2);
    System.WriteLn(sLevel + fixture.Fixture.NameSpace + ':' + fixture.Fixture.Name + Format(' [Tests: %d] [Children: %d] [Passed : %d]', [fixture.ResultCount,
      fixture.ChildCount, fixture.PassCount]));

    Inc(level);
    for child in fixture.Children do
    begin
      LogFixture(child, level);
    end;

  end;

var
  fixtureRes : IFixtureResult;
  sExeName : string;
  sResult : string;
  sTime : string;
  sDate : string;
  sDuration : string;
  totalTests : integer;
begin

  { first things first, rollup the namespaces.
    So, where parent fixtures have no tests, or only one child fixture, combine into a single fixture.
    }
  for fixtureRes in RunResults.FixtureResults do
  begin
    fixtureRes.Reduce;
    //    LogFixture(fixtureRes,0);
  end;

  //NUnit reports the total without the Ignored.
  totalTests := RunResults.TestCount - RunResults.IgnoredCount;

  sExeName := ParamStr(0);
  FIndent := 0;
  sTime := FormatDateTime('hh":"nn":"ss', RunResults.StartTime);
  sDate := FormatDateTime('yyyy-MM-dd', RunResults.StartTime);
  sDuration := Format('%.3f', [RunResults.Duration.TotalSeconds]);

  WriteXMLLine('<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>');
  WriteXMLLine(Format('<test-results name="%s" total="%d" errors="%d" failures="%d" ignored="%d" inconclusive="0" not-run="%d" skipped="0" invalid="0" date="%s" time="%s">',
      [EscapeForXML(sExeName), totalTests, RunResults.ErrorCount, RunResults.FailureCount + RunResults.MemoryLeakCount, RunResults.IgnoredCount,
      RunResults.IgnoredCount, sDate, sTime])); //a leaked test is written as result="Failure"
  sExeName := ExtractFileName(sExeName);

  if RunResults.AllPassed then
    sResult := 'Success'
  else
    sResult := 'Failure';

  Indent;
  //TODO: Populate these properly.
//  WriteXMLLine('<environment nunit-version="DUnitX" clr-version="2.0.0.0" os-version="6.1.0.0" platform="Windows" cwd="" machine-name="" user="" user-domain=""  />');
  WriteXMLLine('<culture-info current-culture="en" current-uiculture="en" />');
  WriteXMLLine(Format('<test-suite type="Assembly" name="%s" executed="true" result="%s" success="%s" time="%s" asserts="0">', [EscapeForXML(sExeName), sResult,
    BoolToStr(RunResults.AllPassed, true), sDuration]));
  Indent;
  WriteXMLLine('<results>');

  Indent;
  for fixtureRes in RunResults.FixtureResults do
    WriteFixtureResult(fixtureRes);
  Outdent;
  WriteXMLLine('</results>');
  Outdent;
  WriteXMLLine('</test-suite>');
  Outdent;
  WriteXMLLine('</test-results>');

end;

procedure TDUnitXXMLNUnitLogger.Outdent;
begin
  Dec(FIndent, 2);
end;

procedure TDUnitXXMLNUnitLogger.WriteFixtureResult(const fixtureResult : IFixtureResult);
var
  sResult : string;
  sTime : string;
  sLineEnd : string;
  child : IFixtureResult;
  testResult : ITestResult;
  sExecuted : string;
  sName : string;
  sSuccess : string;
begin
  Indent;
  try
    if not fixtureResult.HasFailures then
      sResult := 'Success'
    else
      sResult := 'Failure';
    sTime := Format('%.3f', [fixtureResult.Duration.TotalSeconds]);

    sName := EscapeForXML(fixtureResult.Fixture.Name);
    sResult := EscapeForXML(sResult);
    sSuccess := EscapeForXML(BoolToStr(not fixtureResult.HasFailures, true));
    sTime := EscapeForXML(sTime);

    //its a real fixture if the class is not TObject.
    if (not fixtureResult.Fixture.TestClass.ClassNameIs('TObject')) then
    begin
      //if there were no tests then just ignore this fixture.
      if fixtureResult.ResultCount = 0 then
        exit;
      sExecuted := BoolToStr(fixtureResult.ResultCount > 0, true);
      sExecuted := EscapeForXML(sExecuted);

      WriteXMLLine(Format('<test-suite type="Fixture" name="%s" executed="%s" result="%s" success="%s" time="%s" >', [sName, sExecuted, sResult, sSuccess,
        sTime]));
      WriteCategoryNodes(fixtureResult.Fixture.Categories);
      Indent;
      WriteXMLLine('<results>');
      for testResult in fixtureResult.TestResults do
      begin
        WriteTestResult(testResult);
      end;

      for child in fixtureResult.Children do
      begin
        WriteFixtureResult(child);
      end;
      WriteXMLLine('</results>');
      Outdent;
      WriteXMLLine('</test-suite>');
    end
    else
    begin
      if fixtureResult.ChildCount = 0 then
        sLineEnd := '/';
      //It's a Namespace.

      WriteXMLLine(Format('<test-suite type="Namespace" name="%s" executed="true" result="%s" success="%s" time="%s" asserts="0" %s>', [sName, sResult,
        sSuccess, sTime, sLineEnd]));

      if fixtureResult.ChildCount > 0 then
      begin
        Indent;
        WriteXMLLine('<results>');
        Indent;
        for child in fixtureResult.Children do
        begin
          WriteFixtureResult(child);
        end;
        Outdent;
        WriteXMLLine('</results>');
        Outdent;
        WriteXMLLine('</test-suite>');
      end;
    end;
  finally
    Outdent;
  end;
end;

function ResultTypeToString(const value : TTestResultType) : string;
begin
  case value of
    TTestResultType.Pass : result := 'Success';
    TTestResultType.Failure : result := 'Failure';
    TTestResultType.Error : result := 'Error';
    TTestResultType.Ignored : result := 'Ignored';
    TTestResultType.MemoryLeak : result := 'Failure'; //NUnit xml doesn't understand memory leak
  else
    result := GetEnumName(TypeInfo(TTestResultType), Ord(value));
  end;
end;

procedure TDUnitXXMLNUnitLogger.WriteTestResult(const testResult : ITestResult);
var
  sLineEnd : string;
  sResult : string;
  sTime : string;
  sExecuted : string;
  sSuccess : string;
  sName : string;
begin
  Indent;
  try
    sTime := Format('%.3f', [testResult.Duration.TotalSeconds]);
    sResult := ResultTypeToString(testResult.ResultType);
    if (testResult.ResultType = TTestResultType.Pass) and (testResult.Test.Categories.Count = 0) then
      sLineEnd := '/';
    sExecuted := BoolToStr(testResult.ResultType <> TTestResultType.Ignored, true);

    if testResult.ResultType <> TTestResultType.Ignored then
      sSuccess := Format('success="%s"', [EscapeForXML(BoolToStr(testResult.ResultType = TTestResultType.Pass, true))])
    else
      sSuccess := '';

    sName := EscapeForXML(testResult.Test.Name);
    sExecuted := EscapeForXML(sExecuted);
    sResult := EscapeForXML(sResult);
    sTime := EscapeForXML(sTime);

    WriteXMLLine(Format('<test-case name="%s" executed="%s" result="%s" %s time="%s" asserts="0" %s>', [sName, sExecuted, sResult, sSuccess, sTime,
      sLineEnd]));
    WriteCategoryNodes(testResult.Test.Categories);
    case testResult.ResultType of
      TTestResultType.MemoryLeak,
        TTestResultType.Failure,
        TTestResultType.Error :
        begin
          Indent;
          WriteXMLLine('<failure>');
          Indent;
          WriteXMLLine('<message>');
          Indent;
          WriteXMLLine(Format('<![CDATA[ %s ]]>', [EscapeForXML(testResult.Message, False, True)]));
          Outdent;
          WriteXMLLine('</message>');
          Outdent;
          Indent;
          WriteXMLLine('<stack-trace>');
          Indent;
          WriteXMLLine(Format('<![CDATA[ %s ]]>', [EscapeForXML(testResult.StackTrace, False, True)]));
          Outdent;
          WriteXMLLine('</stack-trace>');
          Outdent;
          WriteXMLLine('</failure>');
        end;
      TTestResultType.Ignored :
        begin
          Indent;
          WriteXMLLine('<reason>');
          Indent;
          WriteXMLLine('<message>');
          Indent;
          WriteXMLLine(Format('<![CDATA[ %s ]]>', [EscapeForXML(testResult.Message, False, True)]));
          Outdent;
          WriteXMLLine('</message>');
          Outdent;
          WriteXMLLine('</reason>');
        end;
      TTestResultType.Pass :
        begin
          if testResult.Test.Categories.Count = 0 then
          begin
            exit;
          end;
          Indent;
        end;
    end;
    Outdent;
    WriteXMLLine('</test-case>');

  finally
    Outdent;
  end;
end;

procedure TDUnitXXMLNUnitLogger.WriteCategoryNodes(const ACategoryList : TList<string>);
var
  sCategory : string;
begin
  if ACategoryList.Count > 0 then
  begin
    Indent;
    WriteXMLLine('<categories>');
    Indent;
    for sCategory in ACategoryList do
      WriteXMLLine(Format('<category name="%s" />', [EscapeForXML(sCategory)]));
    Outdent;
    WriteXMLLine('</categories>');
    Outdent;
  end;
end;

procedure TDUnitXXMLNUnitLogger.WriteXMLLine(const value : string);
var
  bytes : TBytes;
  s : string;
begin
  s := StringOfChar(' ', FIndent) + value + #13#10;
  bytes := TEncoding.UTF8.GetBytes(s);
  FOutputStream.Write(bytes[0], Length(bytes));
end;

{ TDUnitXXMLNUnitFileLogger }

constructor TDUnitXXMLNUnitFileLogger.Create(const AFilename : string);
var
  sXmlFilename : string;
  fileStream : TFileStream;
  lXmlDirectory : string;
const
  DEFAULT_NUNIT_FILE_NAME = 'dunitx-results.xml';
begin
  sXmlFilename := AFilename;

  if sXmlFilename = '' then
    sXmlFilename := ExtractFilePath(ParamStr(0)) + DEFAULT_NUNIT_FILE_NAME;

  lXmlDirectory := ExtractFilePath(sXmlFilename);
  //A bare file name has no folder: ForceDirectories('') raises EInOutError
  //("Unable to create directory") before a single test runs. It means the
  //current folder, which needs no creating.
  if lXmlDirectory <> '' then
    ForceDirectories(lXmlDirectory);

  fileStream := TFileStream.Create(sXmlFilename, fmCreate);

  //base class will destroy the stream;
  inherited Create(fileStream, true);
end;

end.

