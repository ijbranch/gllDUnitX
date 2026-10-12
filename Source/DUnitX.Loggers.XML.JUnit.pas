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

unit DUnitX.Loggers.XML.JUnit;

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
  ///   Logger that writes the whole run, once it has finished, as a JUnit XML results document (UTF-8 with a BOM) to a
  ///   stream, for CI servers that read JUnit results. Ignored tests are written as <c>skipped</c> and counted as
  ///   <c>disabled</c>; memory leaks are written as errors, since the JUnit format has no leak outcome.
  /// </summary>
  TDUnitXXMLJUnitLogger = class(TDUnitXNullLogger)
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
    ///   <c>testsuites</c> root with the run's totals and one <c>testsuite</c> per real fixture.
    /// </summary>
    /// <param name="RunResults">The results of the whole run.</param>
    procedure OnTestingEnds(const RunResults : IRunResults); override;

    /// <summary>
    ///   Writes a <c>categories</c> element listing each category; writes nothing for an empty list. Not currently
    ///   called: the JUnit output omits categories.
    /// </summary>
    /// <param name="ACategoryList">The categories of a fixture or test.</param>
    procedure WriteCategoryNodes(const ACategoryList : TList<string>);
    /// <summary>
    ///   Writes a real fixture as a flat <c>testsuite</c> element (named by its namespace, with counts of its own test
    ///   cases and an ISO 8601 timestamp), followed by its child fixtures as further suites. A namespace node writes
    ///   only its children; a real fixture with no results is skipped.
    /// </summary>
    /// <param name="fixtureResult">The fixture's results.</param>
    procedure WriteFixtureResult(const fixtureResult : IFixtureResult);
    /// <summary>
    ///   Writes a test as a <c>testcase</c> element, with a <c>failure</c> for a failure, an <c>error</c> for an error
    ///   or leak (message plus stack trace), or <c>skipped</c> for an ignored test.
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
  ///   JUnit XML logger that writes to a file it creates (replacing any existing file) and owns.
  /// </summary>
  TDUnitXXMLJUnitFileLogger = class(TDUnitXXMLJUnitLogger)
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
  System.StrUtils,
  System.TypInfo;
{$ELSE}
  StrUtils,
  TypInfo;
{$ENDIF}

{ TDUnitXXMLJUnitLogger }

constructor TDUnitXXMLJUnitLogger.Create(const AOutputStream : TStream; const AOwnsStream : boolean = false);
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

destructor TDUnitXXMLJUnitLogger.Destroy;
begin
  if FOwnsStream then
    FOutputStream.Free;
  inherited;
end;

function TDUnitXXMLJUnitLogger.Format(const Format : string; const Args : array of const) : string;
begin
  Result := {$IFDEF USE_NS}System.{$ENDIF}SysUtils.Format(Format, Args, FFormatSettings);
end;

procedure TDUnitXXMLJUnitLogger.Indent;
begin
  Inc(FIndent, 2);
end;

procedure TDUnitXXMLJUnitLogger.OnTestingEnds(const RunResults : IRunResults);

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
  sTime : string;
  //totalTests  : integer;
begin

  { first things first, rollup the namespaces.
    So, where parent fixtures have no tests, or only one child fixture, combine into a single fixture.
    }
  for fixtureRes in RunResults.FixtureResults do
  begin
    fixtureRes.Reduce;
    //    LogFixture(fixtureRes,0);
  end;

  //JUnit reports the total without the Ignored.
//  totalTests := RunResults.TestCount - RunResults.IgnoredCount;

  sExeName := ParamStr(0);
  FIndent := 0;
  sTime := Format('%.3f', [RunResults.Duration.TotalSeconds]);

  WriteXMLLine('<?xml version="1.0" encoding="UTF-8"?>');

  // Global overview
  // There is only a "disabled" attribute on the top level, but "disabled" and "skipped" on fixture level. Return ignored tests as "disabled"
  WriteXMLLine(Format('<testsuites name="%s" tests="%d" disabled="%d" errors="%d" failures="%d" time="%s">',
      [EscapeForXML(sExeName), RunResults.TestCount, RunResults.IgnoredCount, RunResults.ErrorCount + RunResults.MemoryLeakCount,
      RunResults.FailureCount, sTime])); //a leaked test is written as <error>

  Indent;

  for fixtureRes in RunResults.FixtureResults do
    WriteFixtureResult(fixtureRes);

  Outdent;
  WriteXMLLine('</testsuites>');
end;

procedure TDUnitXXMLJUnitLogger.Outdent;
begin
  Dec(FIndent, 2);
end;

procedure TDUnitXXMLJUnitLogger.WriteFixtureResult(const fixtureResult : IFixtureResult);
var
  sTime : string;
  sDate : string;
  child : IFixtureResult;
  testResult : ITestResult;
  sExecuted : string;
  sName : string;
  ignoredCount : integer;
  errorCount : integer;
  failureCount : integer;
begin
  //its a real fixture if the class is not TObject.
  if (not fixtureResult.Fixture.TestClass.ClassNameIs('TObject')) then
  begin
    //if there were no tests then just ignore this fixture.
    if fixtureResult.ResultCount = 0 then
      exit;
    sExecuted := BoolToStr(fixtureResult.ResultCount > 0, true);
    sExecuted := EscapeForXML(sExecuted);

    //The suite name is the full name without its trailing '.Name' (not the first '.Name' found).
    sName := fixtureResult.Fixture.FullName;
    if EndsStr('.' + fixtureResult.Fixture.Name, sName) then
      SetLength(sName, Length(sName) - Length(fixtureResult.Fixture.Name) - 1);
    sTime := Format('%.3f', [fixtureResult.Duration.TotalSeconds]);

    sName := EscapeForXML(sName);
    sTime := EscapeForXML(sTime);
    //':' unquoted is the locale's time separator; ISO 8601 needs a literal ':'.
    sDate := FormatDateTime('yyyy-MM-dd"T"hh":"nn":"ss', fixtureResult.StartTime);

    //The counts are of this suite's own <testcase> elements, as tests="" is. The fixture result's counts are rolled up
    //from its children, which are written as suites of their own. A leaked test is written as <error>, so it counts
    //as one.
    ignoredCount := 0;
    errorCount := 0;
    failureCount := 0;
    for testResult in fixtureResult.TestResults do
      case testResult.ResultType of
        TTestResultType.Ignored : Inc(ignoredCount);
        TTestResultType.Error, TTestResultType.MemoryLeak : Inc(errorCount);
        TTestResultType.Failure : Inc(failureCount);
      end;

    // There is only a "disabled" attribute on the top level, but "disabled" and "skipped" on fixture level. Return ignored tests as "disabled"
    WriteXMLLine(Format('<testsuite name="%s" tests="%d" disabled="%d" errors="%d" failures="%d" time="%s" timestamp="%s">',
        [sName, fixtureResult.TestResults.Count, ignoredCount, errorCount, failureCount, sTime, sDate]));
    //WriteCategoryNodes(fixtureResult.Fixture.Categories);

    for testResult in fixtureResult.TestResults do
    begin
      WriteTestResult(testResult);
    end;
    WriteXMLLine('</testsuite>');

    for child in fixtureResult.Children do
    begin
      WriteFixtureResult(child);
    end;
  end
  else
  begin
    //It's a Namespace.

    if fixtureResult.ChildCount > 0 then
    begin
      for child in fixtureResult.Children do
      begin
        WriteFixtureResult(child);
      end;
    end;
  end;
end;

procedure TDUnitXXMLJUnitLogger.WriteTestResult(const testResult : ITestResult);
var
  sTime : string;
  sName : string;
  sClassName : string;
begin
  Indent;
  try
    sTime := Format('%.3f', [testResult.Duration.TotalSeconds]);

    sName := EscapeForXML(testResult.Test.Name);
    sClassName := EscapeForXML(testResult.Test.Fixture.Name);
    sTime := EscapeForXML(sTime);

    WriteXMLLine(Format('<testcase classname="%s" name="%s" time="%s">', [sClassName, sName, sTime]));
    //WriteCategoryNodes(testResult.Test.Categories);
    case testResult.ResultType of
      TTestResultType.Failure :
        begin
          Indent;
          WriteXMLLine(Format('<failure message="%s">', [EscapeForXML(testResult.Message)]));
          Indent;
          WriteXMLLine(Format('<![CDATA[ %s ]]>', [EscapeForXML(testResult.StackTrace, False, True)]));
          Outdent;
          WriteXMLLine('</failure>');
          Outdent;
        end;
      TTestResultType.MemoryLeak,
        TTestResultType.Error :
        begin
          Indent;
          WriteXMLLine(Format('<error message="%s">', [EscapeForXML(testResult.Message)]));
          Indent;
          WriteXMLLine(Format('<![CDATA[ %s ]]>', [EscapeForXML(testResult.StackTrace, False, True)]));
          Outdent;
          WriteXMLLine('</error>');
          Outdent;
        end;
      TTestResultType.Ignored :
        begin
          Indent;
          WriteXMLLine('<skipped/>');
          Outdent;
        end;
      TTestResultType.Pass :
        begin
          //        if testResult.Test.Categories.Count = 0 then
          //        begin
          //          exit;
          //        end;
          //        Indent;
        end;
    end;
    WriteXMLLine('</testcase>');

  finally
    Outdent;
  end;
end;

procedure TDUnitXXMLJUnitLogger.WriteCategoryNodes(const ACategoryList : TList<string>);
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

procedure TDUnitXXMLJUnitLogger.WriteXMLLine(const value : string);
var
  bytes : TBytes;
  s : string;
begin
  s := StringOfChar(' ', FIndent) + value + #13#10;
  bytes := TEncoding.UTF8.GetBytes(s);
  FOutputStream.Write(bytes[0], Length(bytes));
end;

{ TDUnitXXMLJUnitFileLogger }

constructor TDUnitXXMLJUnitFileLogger.Create(const AFilename : string);
var
  sXmlFilename : string;
  fileStream : TFileStream;
  lXmlDirectory : string;
const
  DEFAULT_JUNIT_FILE_NAME = 'dunitx-results.xml';
begin
  sXmlFilename := AFilename;

  if sXmlFilename = '' then
    sXmlFilename := ExtractFilePath(ParamStr(0)) + DEFAULT_JUNIT_FILE_NAME;

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

