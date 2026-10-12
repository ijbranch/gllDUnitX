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

unit DUnitX.Expert.CodeGen.Templates;

interface

{$I DUnitX.inc}

resourcestring

  { Delphi template code }

  /// <summary>
  ///   Source of a new DUnitX console test project (.dpr): runs every RTTI-registered fixture with the console and
  ///   NUnit XML loggers, sets <c>EXIT_ERRORS</c> on any failure or abort, and pauses only for <c>--exit:Pause</c>.
  /// </summary>
  /// <remarks>
  ///   Format arguments: 0 - program name; 1 - extra uses entries for leak reporting (empty, or complete lines each
  ///   ending in a comma and CRLF).
  /// </remarks>
  STestDPR          ='program %0:s;'#13#10 +
    #13#10 +
    '{$APPTYPE CONSOLE}'#13#10 +
    '{$R *.res}'#13#10 +
    '{$STRONGLINKTYPES ON}'#13#10 +
    'uses'#13#10 +
    '%1:s' +
    '  System.SysUtils,'#13#10 +
    '  DUnitX.Loggers.Console,'#13#10 +
    '  DUnitX.Loggers.Xml.NUnit,'#13#10 +
    '  DUnitX.TestFramework;'#13#10 +
    #13#10 +
    'var'#13#10 +
    '  runner: ITestRunner;'#13#10 +
    '  results: IRunResults;'#13#10 +
    '  logger: ITestLogger;'#13#10 +
    '  nunitLogger : ITestLogger;'#13#10 +
    'begin'#13#10 +
    '  try'#13#10 +
    '    //Check command line options, will exit if invalid'#13#10 +
    '    TDUnitX.CheckCommandLine;'#13#10 +
    '    //Create the test runner'#13#10 +
    '    runner := TDUnitX.CreateRunner;'#13#10 +
    '    //Tell the runner to use RTTI to find Fixtures'#13#10 +
    '    runner.UseRTTI := True;'#13#10 +
    '    //When true, Assertions must be made during tests;'#13#10 +
    '    runner.FailsOnNoAsserts := False;'#13#10 +
    #13#10 +
    '    //tell the runner how we will log things'#13#10 +
    '    //Log to the console window if desired'#13#10 +
    '    if TDUnitX.Options.ConsoleMode <> TDunitXConsoleMode.Off then'#13#10 +
    '    begin'#13#10 +
    '      logger := TDUnitXConsoleLogger.Create(TDUnitX.Options.ConsoleMode = TDunitXConsoleMode.Quiet);'#13#10 +
    '      runner.AddLogger(logger);'#13#10 +
    '    end;'#13#10 +
    '    //Generate an NUnit compatible XML File'#13#10 +
    '    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);'#13#10 +
    '    runner.AddLogger(nunitLogger);'#13#10 +
    #13#10 +
    '    //Run tests'#13#10 +
    '    results := runner.Execute;'#13#10 +
    '    if not results.AllPassed then'#13#10 +
    '      System.ExitCode := EXIT_ERRORS;'#13#10 +
    #13#10 +
    '    //Only pause when asked to (--exit:Pause); the default is Continue.'#13#10 +
    '    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then'#13#10 +
    '    begin'#13#10 +
    '      System.Write(''Done.. press <Enter> key to quit.'');'#13#10 +
    '      System.Readln;'#13#10 +
    '    end;'#13#10 +
    '  except'#13#10 +
    '    on E: Exception do'#13#10 +
    '    begin'#13#10 +
    '      //A run that aborts (e.g. no tests registered) must not report success.'#13#10 +
    '      System.Writeln(E.ClassName, '': '', E.Message);'#13#10 +
    '      System.ExitCode := EXIT_ERRORS;'#13#10 +
    '    end;'#13#10 +
    '  end;'#13#10 +
    'end.'#13#10;

  /// <summary>
  ///   Source of a new DUnitX test unit: one [TestFixture] class, registered with <c>TDUnitX.RegisterTestFixture</c>
  ///   in the initialization section.
  /// </summary>
  /// <remarks>
  ///   Format arguments: 0 - unit name; 1 - fixture class name; 2 - Setup/TearDown methods, interface
  ///   (<see cref="SSetupTearDownIntf" /> or empty); 3 - sample methods, interface (<see cref="SSampleMethodsIntf" /> or
  ///   empty); 4 - Setup/TearDown methods, implementation (<see cref="SSetupTearDownImpl" /> or empty); 5 - sample
  ///   methods, implementation (<see cref="SSampleMethodsImpl" /> or empty).
  /// </remarks>
  STestUnit         ='unit %0:s;'#13#10 +
    #13#10 +
    'interface'#13#10 +
    #13#10 +
    'uses'#13#10 +
    '  DUnitX.TestFramework;'#13#10 +
    #13#10 +
    'type'#13#10 +
    '  [TestFixture]'#13#10 +
    '  %1:s = class'#13#10 +
    '  public'#13#10 +
    '%2:s%3:s' +
    '  end;'#13#10 +
    #13#10 +
    'implementation'#13#10 +
    '%4:s%5:s' +
    #13#10 +
    'initialization'#13#10 +
    '  TDUnitX.RegisterTestFixture(%1:s);'#13#10 +
    #13#10 +
    'end.'#13#10;

  /// <summary>
  ///   Interface declarations of the fixture's [Setup] and [TearDown] methods, inserted as argument 2 of
  ///   <see cref="STestUnit" />. Takes no format arguments.
  /// </summary>
  SSetupTearDownIntf =
    '    [Setup]'#13#10 +
    '    procedure Setup;'#13#10 +
    '    [TearDown]'#13#10 +
    '    procedure TearDown;'#13#10;

  /// <summary>
  ///   Empty implementations of the fixture's Setup and TearDown methods, inserted as argument 4 of
  ///   <see cref="STestUnit" />.
  /// </summary>
  /// <remarks>
  ///   Format arguments: 0 - fixture class name.
  /// </remarks>
  SSetupTearDownImpl =
    #13#10 +
    'procedure %0:s.Setup;'#13#10 +
    'begin'#13#10 +
    'end;'#13#10 +
    #13#10 +
    'procedure %0:s.TearDown;'#13#10 +
    'begin'#13#10 +
    'end;'#13#10;

  /// <summary>
  ///   Interface declarations of two sample tests - a plain [Test] and one fed by two [TestCase] attributes - inserted
  ///   as argument 3 of <see cref="STestUnit" />. Takes no format arguments.
  /// </summary>
  SSampleMethodsIntf =
    '    // Sample Methods'#13#10 +
    '    // Simple single Test'#13#10 +
    '    [Test]'#13#10 +
    '    procedure Test1;'#13#10 +
    '    // Test with TestCase Attribute to supply parameters.'#13#10 +
    '    [Test]'#13#10 +
    '    [TestCase(''TestA'',''1,2'')]'#13#10 +
    '    [TestCase(''TestB'',''3,4'')]'#13#10 +
    '    procedure Test2(const AValue1 : Integer;const AValue2 : Integer);'#13#10;

  /// <summary>
  ///   Empty implementations of the two sample tests, inserted as argument 5 of <see cref="STestUnit" />.
  /// </summary>
  /// <remarks>
  ///   Format arguments: 0 - fixture class name.
  /// </remarks>
  //TODO: Show Examples of calling Assert
  SSampleMethodsImpl =
    #13#10 +
    'procedure %0:s.Test1;'#13#10 +
    'begin'#13#10 +
    'end;'#13#10 +
    #13#10 +
    'procedure %0:s.Test2(const AValue1 : Integer;const AValue2 : Integer);'#13#10 +
    'begin'#13#10 +
    'end;'#13#10;

  /// <summary>Fixture class name the wizard forms offer by default.</summary>
  SDefaultClassName = 'TMyTestObject';

  /// <summary>
  ///   Message the wizard forms show when the entered fixture class name fails <see cref="IsValidFixtureClassName" />.
  /// </summary>
  /// <remarks>
  ///   Format arguments: 0 - the rejected class name.
  /// </remarks>
  SInvalidFixtureClassName = '''%0:s'' is not a valid TestFixture class name.'#13#10#13#10 +
    'Enter a Delphi identifier (a letter or underscore, then letters, digits or underscores) that is not a reserved word ' +
    'and does not hide a name the generated unit uses (TDUnitX, Integer, TestAttribute, TestCaseAttribute, ' +
    'SetupAttribute, TearDownAttribute).';

/// <summary>
///   Checks whether a name can be used as the generated fixture's class name.
/// </summary>
/// <param name="AName">
///   The candidate class name, as typed in the wizard.
/// </param>
/// <returns>
///   True when <paramref name="AName" /> is a valid identifier, not a reserved word, and not a name the generated unit
///   refers to unqualified (declaring it would hide the framework's or System's own); the comparisons ignore case.
/// </returns>
function IsValidFixtureClassName(const AName : string) : Boolean;

implementation

uses
  System.SysUtils;

const
  // Delphi reserved words (directives such as "private" or "message" are legal identifiers).
  CReservedWords : array[0..64] of string = (
    'and', 'array', 'as', 'asm', 'begin', 'case', 'class', 'const', 'constructor', 'destructor',
    'dispinterface', 'div', 'do', 'downto', 'else', 'end', 'except', 'exports', 'file', 'finalization',
    'finally', 'for', 'function', 'goto', 'if', 'implementation', 'in', 'inherited', 'initialization', 'inline',
    'interface', 'is', 'label', 'library', 'mod', 'nil', 'not', 'object', 'of', 'or',
    'packed', 'procedure', 'program', 'property', 'raise', 'record', 'repeat', 'resourcestring', 'set', 'shl',
    'shr', 'string', 'then', 'threadvar', 'to', 'try', 'type', 'unit', 'until', 'uses',
    'var', 'while', 'with', 'xor', 'out');

  // Names the generated unit uses unqualified. A fixture class of that name hides the original: TDUnitX breaks the
  // RegisterTestFixture call (E2003), an *Attribute name breaks the matching attribute (E2010), and Integer turns
  // the sample Test2 parameters into the fixture class, so its TestCase values cannot be converted at run time.
  CHiddenNames : array[0..5] of string = (
    'TDUnitX', 'Integer', 'TestAttribute', 'TestCaseAttribute', 'SetupAttribute', 'TearDownAttribute');

function IsValidFixtureClassName(const AName : string) : Boolean;
var
  lWord : string;
begin
  result := IsValidIdent(AName, False);
  if result then
  begin
    for lWord in CReservedWords do
      if SameText(AName, lWord) then
        Exit(False);
    for lWord in CHiddenNames do
      if SameText(AName, lWord) then
        Exit(False);
  end;
end;

end.

