program DUnitXTest_D13;

{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}

uses
  SysUtils,
  DUnitX.TestFramework,
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  DunitX.Init,
  DUnitX.Tests.Assert in 'DUnitX.Tests.Assert.pas',
  DUnitX.Tests.DUnitCompatibility in 'DUnitX.Tests.DUnitCompatibility.pas',
  DUnitX.Tests.Example in 'DUnitX.Tests.Example.pas',
  DUnitX.Tests.Framework in 'DUnitX.Tests.Framework.pas',
  DUnitX.Tests.IoC in 'DUnitX.Tests.IoC.pas',
  DUnitX.Tests.TestFixture in 'DUnitX.Tests.TestFixture.pas',
  DUnitX.Tests.Utils.XML in 'DUnitX.Tests.Utils.XML.pas',
  DUnitX.Tests.WeakReference in 'DUnitX.Tests.WeakReference.pas',
  DUnitX.Tests.Loggers.XML.NUnit in 'DUnitX.Tests.Loggers.XML.NUnit.pas',
  DUnitX.SingleNameSpace in 'DUnitX.SingleNameSpace.pas',
  DUnitX.Tests.MemoryLeaks in 'DUnitX.Tests.MemoryLeaks.pas',
  DUnitX.Tests.CommandLineParser in 'DUnitX.Tests.CommandLineParser.pas',
  DUnitX.Tests.CategoryParser in 'DUnitX.Tests.CategoryParser.pas',
  DUnitX.Tests.TestNameParser in 'DUnitX.Tests.TestNameParser.pas',
  DUnitX.Tests.Inheritance in 'DUnitX.Tests.Inheritance.pas',
  DUnitX.Tests.ConsoleWriter.Base in 'DUnitX.Tests.ConsoleWriter.Base.pas',
  DUnitX.Tests.TestDataProvider in 'DUnitX.Tests.TestDataProvider.pas',
  DUnitX.Tests.IgnoreFixture in 'DUnitX.Tests.IgnoreFixture.pas',
  DUnitX.Tests.Utils in 'DUnitX.Tests.Utils.pas',
  DUnitX.Tests.Loggers.XML.JUnit in 'DUnitX.Tests.Loggers.XML.JUnit.pas';

// Named explicitly: this file is DUnitXTestProject.dpr, but the version resource is generated beside the .dproj as
// DUnitXTest_D13.res, so {$R *.res} would look for a DUnitXTestProject.res that does not exist.
{$R DUnitXTest_D13.res}

var
  runner: ITestRunner;
  results: IRunResults;
  logger: ITestLogger;
  nunitLogger : ITestLogger;
begin
  try
    //Check command line options, will exit if invalid
    TDUnitX.CheckCommandLine;
    //Create the test runner
    runner := TDUnitX.CreateRunner;
    //Tell the runner to use RTTI to find Fixtures
    runner.UseRTTI := True;
    //When true, Assertions must be made during tests;
    runner.FailsOnNoAsserts := False;

    //tell the runner how we will log things
    //Log to the console window if desired
    if TDUnitX.Options.ConsoleMode <> TDunitXConsoleMode.Off then
    begin
      logger := TDUnitXConsoleLogger.Create(TDUnitX.Options.ConsoleMode = TDunitXConsoleMode.Quiet);
      runner.AddLogger(logger);
    end;
    //Generate an NUnit compatible XML File
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);

    //Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    //Pause only when asked to (--exit:Pause); the default, Continue, lets unattended runs finish.
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
  except
    on E: Exception do
    begin
      //A run that dies before or during Execute must not report success.
      System.Writeln(E.ClassName, ': ', E.Message);
      System.ExitCode := EXIT_ERRORS;
    end;
  end;
end.
