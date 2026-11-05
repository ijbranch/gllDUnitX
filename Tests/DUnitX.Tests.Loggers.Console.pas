{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Originally part of DUnitX, by Vincent Parrett & Contributors    }
{           Modified (C) 2026 Ian Branch (GITLAK Software) - gllDUnitX fork }
{                                                                           }
{           Licensed under the Apache License, Version 2.0                  }
{           http://www.apache.org/licenses/LICENSE-2.0                      }
{                                                                           }
{***************************************************************************}

unit DUnitX.Tests.Loggers.Console;

interface

{$I DUnitX.inc}

uses
  DUnitX.TestFramework,
  DUnitX.ConsoleWriter.Base;

type
  /// <summary>
  ///   Console writer that keeps everything written as one string, a line end as <c>#10</c>, so a test can compare
  ///   the console logger's exact output.
  /// </summary>
  TCapturingConsoleWriter = class(TInterfacedObject, IDUnitXConsoleWriter)
  private
    /// <summary>Everything written so far; each line end is <c>#10</c>.</summary>
    FText : string;
    /// <summary>The indent the logger last set; kept only so the interface is honoured.</summary>
    FIndent : Integer;
  public
    /// <summary>Returns the current indent.</summary>
    /// <returns>The indent last set.</returns>
    function GetIndent : Integer;
    /// <summary>Sets the indent.</summary>
    /// <param name="count">The new indent; negative values become 0.</param>
    procedure SetIndent(const count : Integer);
    /// <summary>Ignored: colour is not captured.</summary>
    /// <param name="foreground">The text colour.</param>
    /// <param name="background">The background colour.</param>
    procedure SetColour(const foreground : TConsoleColour; const background : TConsoleColour = ccDefault);
    /// <summary>Captures the text followed by a line end.</summary>
    /// <param name="s">The text written.</param>
    procedure WriteLn(const s : string); overload;
    /// <summary>Captures a line end.</summary>
    procedure WriteLn; overload;
    /// <summary>Captures the text with no line end.</summary>
    /// <param name="s">The text written.</param>
    procedure Write(const s : string);
    /// <summary>Increases the indent.</summary>
    /// <param name="value">The amount to add.</param>
    procedure Indent(const value : integer = 1);
    /// <summary>Decreases the indent, never below 0.</summary>
    /// <param name="value">The amount to remove.</param>
    procedure Outdent(const value : integer = 1);
    /// <summary>Everything written so far; each line end is <c>#10</c>.</summary>
    property Text : string read FText;
  end;

  /// <summary>A console writer class, to make again the one registered before a test ( upstream #584 ).</summary>
  TConsoleWriterClass = class of TDUnitXConsoleWriterBase;

{$M+}
  /// <summary>
  ///   Tests for <c>TDUnitXConsoleLogger</c>'s quiet mode with a row width (upstream #582): the progress marks wrap
  ///   after exactly that many characters, and without a width they stay on one row as before.
  /// </summary>
  [TestFixture]
  TDUnitX_ConsoleLoggerTests = class
  private
    /// <summary>The capturing writer the logger under test resolves.</summary>
    FWriter : TCapturingConsoleWriter;
    /// <summary>Holds the capturing writer's reference count for the test's lifetime.</summary>
    FWriterRef : IDUnitXConsoleWriter;
    /// <summary>The console writer class registered before the test, which TearDown registers again.</summary>
    FSavedWriterClass : TConsoleWriterClass;
    /// <summary>
    ///   Creates a quiet-mode logger, drives it through every call that writes a progress mark, and returns what it
    ///   wrote.
    /// </summary>
    /// <param name="ARowWidth">The row width passed to the logger, or <c>MaxInt</c> to use the default.</param>
    /// <param name="AEndRun">True to end the run afterwards (<c>OnTestingEnds</c> with empty results).</param>
    /// <returns>
    ///   The captured output of the script <c>XPXFXEIXPM</c> (X execute, P pass, F failure, E error, I ignored,
    ///   M leak), which writes the ten marks <c>...F.EI..M</c>.
    /// </returns>
    function RunQuietScript(const ARowWidth : Integer; const AEndRun : Boolean = False) : string;
  public
    /// <summary>Points the service locator's console writer at a new capturing writer.</summary>
    [Setup]
    procedure Setup;
    /// <summary>Restores the Windows console writer as the registered implementation.</summary>
    [TearDown]
    procedure TearDown;
    /// <summary>
    ///   Proves a row width of 4 ends a row after exactly four marks, counting every mark (both of a passing test's
    ///   dots, failures, errors, ignores and leaks), not one per test as upstream #582 counts.
    /// </summary>
    [Test]
    procedure RowWidth_Ends_A_Row_After_Exactly_That_Many_Marks;
    /// <summary>Proves a row width of 1 puts every mark on its own row.</summary>
    [Test]
    procedure RowWidth_Of_One_Puts_Each_Mark_On_Its_Own_Row;
    /// <summary>
    ///   Proves the default, zero and a negative row width keep every mark on one row, the behaviour before #582.
    /// </summary>
    /// <param name="ARowWidth">The row width; <c>MaxInt</c> means the constructor's default.</param>
    [Test]
    [NamedTestCase('Default', '2147483647')]
    [NamedTestCase('Zero', '0')]
    [NamedTestCase('Negative', '-5')]
    procedure No_RowWidth_Keeps_Every_Mark_On_One_Row(const ARowWidth : Integer);
    /// <summary>
    ///   Proves the summary follows the marks after exactly one blank line whether the last row was ended by the
    ///   width (5), is partly filled (4) or no width is set: a row the width has just ended must not get a second line
    ///   end of its own.
    /// </summary>
    /// <param name="ARowWidth">The row width; <c>MaxInt</c> means the constructor's default.</param>
    /// <param name="AExpectedMarks">The expected marks and row ends before the summary, <c>|</c> standing for a line end.</param>
    [Test]
    [NamedTestCase('RowJustEnded', '5,...F.|EI..M|')]
    [NamedTestCase('RowPartlyFilled', '4,...F|.EI.|.M')]
    [NamedTestCase('NoWidth', '2147483647,...F.EI..M')]
    procedure Summary_Follows_The_Marks_After_One_Blank_Line(const ARowWidth : Integer; const AExpectedMarks : string);
  end;
{$M-}

implementation

uses
  System.Classes,
  System.SysUtils,
  DUnitX.Loggers.Console,
  DUnitX.ResStrs,
  DUnitX.RunResults,
  DUnitX.ServiceLocator;

{ TCapturingConsoleWriter }

function TCapturingConsoleWriter.GetIndent : Integer;
begin
  Result := FIndent;
end;

procedure TCapturingConsoleWriter.Indent(const value : integer);
begin
  SetIndent(FIndent + value);
end;

procedure TCapturingConsoleWriter.Outdent(const value : integer);
begin
  SetIndent(FIndent - value);
end;

procedure TCapturingConsoleWriter.SetColour(const foreground, background : TConsoleColour);
begin
  // Colour is not part of what these tests compare.
end;

procedure TCapturingConsoleWriter.SetIndent(const count : Integer);
begin
  if count < 0 then
    FIndent := 0
  else
    FIndent := count;
end;

procedure TCapturingConsoleWriter.Write(const s : string);
begin
  FText := FText + s;
end;

procedure TCapturingConsoleWriter.WriteLn(const s : string);
begin
  FText := FText + s + #10;
end;

procedure TCapturingConsoleWriter.WriteLn;
begin
  FText := FText + #10;
end;

{ TDUnitX_ConsoleLoggerTests }

procedure TDUnitX_ConsoleLoggerTests.Setup;
var
  current : IDUnitXConsoleWriter;
begin
  //Remember the platform's console writer so TearDown can put it back.
  current := TDUnitXServiceLocator.DefaultContainer.Resolve<IDUnitXConsoleWriter>();
  FSavedWriterClass := TConsoleWriterClass((current as TObject).ClassType);
  current := nil;

  FWriter := TCapturingConsoleWriter.Create;
  FWriterRef := FWriter;
  TDUnitXServiceLocator.DefaultContainer.RegisterType<IDUnitXConsoleWriter>(
    function : IDUnitXConsoleWriter
    begin
      Result := FWriterRef;
    end);
end;

procedure TDUnitX_ConsoleLoggerTests.TearDown;
var
  writerClass : TConsoleWriterClass;
begin
  writerClass := FSavedWriterClass;
  TDUnitXServiceLocator.DefaultContainer.RegisterType<IDUnitXConsoleWriter>(
    function : IDUnitXConsoleWriter
    begin
      Result := writerClass.Create;
    end);
  FWriter := nil;
  FWriterRef := nil;
end;

function TDUnitX_ConsoleLoggerTests.RunQuietScript(const ARowWidth : Integer; const AEndRun : Boolean) : string;
const
  CScript = 'XPXFXEIXPM';
var
  logger : ITestLogger;
  threadId : TThreadID;
begin
  if ARowWidth = MaxInt then
    logger := TDUnitXConsoleLogger.Create(True)
  else
    logger := TDUnitXConsoleLogger.Create(True, ARowWidth);
  threadId := TThread.CurrentThread.ThreadID;
  for var step in CScript do
    case step of
      'X' : logger.OnExecuteTest(threadId, nil);
      'P' : logger.OnTestSuccess(threadId, nil);
      'F' : logger.OnTestFailure(threadId, nil);
      'E' : logger.OnTestError(threadId, nil);
      'I' : logger.OnTestIgnored(threadId, nil);
      'M' : logger.OnTestMemoryLeak(threadId, nil);
    end;
  if AEndRun then
  begin
    // Held in a variable: a constructor passed straight to a const interface parameter is never released.
    var results : IRunResults := TDUnitXRunResults.Create;
    logger.OnTestingEnds(results);
  end;
  Result := FWriter.Text;
end;

procedure TDUnitX_ConsoleLoggerTests.RowWidth_Ends_A_Row_After_Exactly_That_Many_Marks;
begin
  Assert.AreEqual('...F'#10'.EI.'#10'.M', RunQuietScript(4), False);
end;

procedure TDUnitX_ConsoleLoggerTests.RowWidth_Of_One_Puts_Each_Mark_On_Its_Own_Row;
begin
  Assert.AreEqual('.'#10'.'#10'.'#10'F'#10'.'#10'E'#10'I'#10'.'#10'.'#10'M'#10, RunQuietScript(1), False);
end;

procedure TDUnitX_ConsoleLoggerTests.No_RowWidth_Keeps_Every_Mark_On_One_Row(const ARowWidth : Integer);
begin
  Assert.AreEqual('...F.EI..M', RunQuietScript(ARowWidth), False);
end;

procedure TDUnitX_ConsoleLoggerTests.Summary_Follows_The_Marks_After_One_Blank_Line(const ARowWidth : Integer; const
  AExpectedMarks : string);
begin
  // A row still open needs its line end, then one blank line; a row already ended needs only the blank line.
  var expected := StringReplace(AExpectedMarks, '|', #10, [rfReplaceAll]);
  if not expected.EndsWith(#10) then
    expected := expected + #10;
  expected := expected + #10 + Format(STestsFound, [0]);
  var actual := RunQuietScript(ARowWidth, True);
  Assert.AreEqual(expected, Copy(actual, 1, Length(expected)), False);
end;

end.
