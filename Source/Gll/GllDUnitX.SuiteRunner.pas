(* GITLAK Software
  ***************************************************************************

    © 2026 Ian Branch (GITLAK Software). All rights reserved.

    This Delphi Code Library, including all code, proprietary algorithms, and
    associated intellectual property and confidential information, is the
    exclusive property of Ian Branch (GITLAK Software).

    A licence is granted to the purchaser for the exclusive purpose of ongoing
    maintenance and internal development only.

    Compiled applications developed using elements of this code library may be
    freely distributed.

    Any reproduction, distribution, or use, in whole or in part, by any other
    party is strictly prohibited without the express written permission of the
    Author.

    Complete development history is retained & maintained in my Private GitHub
    Repository.

    THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED.
    IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DAMAGES ARISING IN CONNECTION
    WITH THE USE OF THIS SOFTWARE.

  ***************************************************************************

  This code Unit is a GITLAK addition to the gllDUnitX fork ( not upstream ).

  ***************************************************************************

  Author(s) :
  Ian Branch - GITLAK Software.

  ***************************************************************************
  File last update : 2026-10-22 13:30:00 (UTC+11:00 DST)
  ***************************************************************************
*)

/// <summary>
///   The GITLAK way to run a DUnitX suite, in one call: a warm-up pass, the measured pass with per-test leak checking,
///   a confirm step for flagged leaks, and the canonical exit code.
/// </summary>
/// <remarks>
///   <para>
///     A leak is memory that GROWS when the same work is repeated; a cache a unit builds on first use and keeps for
///     the process ( a time-zone list, a glyph cache, RTTI, a thread pool ) does not.  So the suite runs once
///     unmeasured to build every such cache, and the leak monitor watches the second run.  A test failing in the
///     warm-up is listed and counted in the exit code: a bug that shows only on first use is still a bug.
///   </para>
///   <para>
///     The monitor measures the whole process, so another thread's allocation can land on whichever test is running.
///     A flagged test is re-run up to twice, and one passing re-run clears it ( Ian, 2026-10-22: "Keep the current
///     rule"; an intermittent report means the memory belongs to something else ).  Every flagged test is listed on
///     the console either way.
///   </para>
///   <para>
///     The test exe must name FastMM5 as its FIRST unit, and add <c>gllDUnitX\Source\Gll</c> to its unit search
///     path.  Built and measured in GITLAKLibTests on 2026-10-22 ( 149 tests flagged at first; real defects found in
///     the library, ReportBuilder, the Delphi RTL and FastMM5 ).
///   </para>
/// </remarks>
unit GllDUnitX.SuiteRunner;

interface

uses
  System.SysUtils, DUnitX.TestFramework;

type
  /// <summary>How <see cref="RunGllSuite"/> runs a suite.</summary>
  TGllSuiteOptions = record
    /// <summary>Passed to every runner: True makes a test that asserts nothing a failure.</summary>
    FailsOnNoAsserts: Boolean;
    /// <summary>
    ///   The NUnit XML file to write.  Empty: DUnitX's <c>--xml</c> path when it includes a folder, otherwise
    ///   <c>&lt;exe folder&gt;\&lt;exe name&gt;-results.xml</c>, where GITLAKMCP's <c>test_run</c> looks.
    /// </summary>
    XmlFile: string;
    /// <summary>
    ///   Called for every runner after it is created ( the warm-up, the measured pass and the confirm step's re-runs ),
    ///   to add a suite's own loggers.  May be nil.
    /// </summary>
    ConfigureRunner: TProc<ITestRunner>;
    /// <summary>The defaults: <c>FailsOnNoAsserts</c> True, the conventional XML file, no extra configuration.</summary>
    /// <returns>The default options.</returns>
    class function Defaults: TGllSuiteOptions; static;
  end;

/// <summary>
///   Runs the suite: turns FastMM5's message boxes off ( a dialog would hang an unattended run ), checks the command
///   line, pins the RTL thread pool, runs the warm-up pass, registers the FastMM5
///   leak monitor, runs the measured pass with the console and NUnit XML loggers, confirms the leaks it flagged, and
///   prints the warm-up failures and any settle-limit hits.
/// </summary>
/// <param name="AOptions">How to run it; see <see cref="TGllSuiteOptions"/>.</param>
/// <returns>
///   The GITLAK canonical exit code, also stored in <c>System.ExitCode</c>: 0 when everything passed; n = measured
///   failures + errors + warm-up failures + confirmed leaks, clamped to 249; 250 when the run found no tests; 251 for
///   a command-line error.
/// </returns>
/// <remarks>
///   Register any extra settle checks ( <c>GllDUnitX.LeakMonitor.RegisterSettleCheck</c> ) and pin any other thread
///   pool before calling.  Any other exception propagates to the caller, which should report it and exit 251.
/// </remarks>
function RunGllSuite( const AOptions: TGllSuiteOptions ): Integer;

implementation

uses
  FastMM5, DUnitX.Loggers.Console, DUnitX.Loggers.Xml.NUnit, DUnitX.Exceptions,
  GllDUnitX.LeakMonitor, GllDUnitX.LeakConfirm;

class function TGllSuiteOptions.Defaults: TGllSuiteOptions;
begin
  Result            := Default( TGllSuiteOptions );
  Result.FailsOnNoAsserts := True;
end;

/// <summary>The XML file the measured pass writes, by the rule <c>TGllSuiteOptions.XmlFile</c> describes.</summary>
/// <param name="AOptions">The suite's options.</param>
/// <returns>A folder-qualified path.</returns>
function ResolveXmlFile( const AOptions: TGllSuiteOptions ): string;
begin
  Result            := AOptions.XmlFile;
  if Result = '' then Result := TDUnitX.Options.XMLOutputFile;
  // A bare file name would land in the CURRENT folder, not beside the exe where test_run looks
  if ( Result = '' ) or ( ExtractFilePath( Result ) = '' ) then
    Result          := IncludeTrailingPathDelimiter( ExtractFilePath( ParamStr( 0 ) ) ) +
      ChangeFileExt( ExtractFileName( ParamStr( 0 ) ), '' ) + '-results.xml';
end;

/// <summary>Creates a runner with the suite's settings and its own loggers.</summary>
/// <param name="AOptions">The suite's options.</param>
/// <returns>The runner.</returns>
function NewRunner( const AOptions: TGllSuiteOptions ): ITestRunner;
begin
  Result            := TDUnitX.CreateRunner;
  Result.UseRTTI    := True;
  Result.FailsOnNoAsserts := AOptions.FailsOnNoAsserts;
  if Assigned( AOptions.ConfigureRunner ) then AOptions.ConfigureRunner( Result );
end;

function RunGllSuite( const AOptions: TGllSuiteOptions ): Integer;
begin
  // A FastMM5 message box ( a leak summary, a corrupted block ) would HANG an unattended run with no output, which
  // reads as a stuck test.  Its file and debug-output reporting are left as the suite configured them.
  FastMM_MessageBoxEvents := [ ];

  // DUnitX's own options, --run:<names> above all ( GITLAKMCP's test_run passes its filter that way ).  An option
  // DUnitX does not know is a caller error: report it rather than run a suite nobody asked for.
  try
    TDUnitX.CheckCommandLine;
  except
    on E: ECommandLineError do
    begin
      System.Writeln( 'Command-line error: ' + E.Message );
      System.ExitCode := 251;
      Exit( 251 );
    end;
  end;

  // Warm-up pass: unmeasured, silent apart from its summary
  StartSharedThreadPools;
  var iWarmFailures: Integer;
  begin
    var lWarmRunner := NewRunner( AOptions );
    var lWarmResults := lWarmRunner.Execute;
    iWarmFailures   := lWarmResults.FailureCount + lWarmResults.ErrorCount;
    System.Writeln( Format( 'Warm-up pass  : %d tests, %d failed or errored', [ lWarmResults.TestCount, iWarmFailures ] ) );
    for var lResult in lWarmResults.GetAllTestResults do
      if lResult.ResultType in [ TTestResultType.Failure, TTestResultType.Error ] then
        System.Writeln( '  warm-up ' + lResult.Test.FullName + ': ' + lResult.Message );
    lWarmResults    := nil;
    lWarmRunner     := nil;
  end;

  // Measured pass
  RegisterFastMM5LeakMonitor;
  var sXmlFile      := ResolveXmlFile( AOptions );
  var lResults: IRunResults;
  begin
    var lRunner     := NewRunner( AOptions );
    lRunner.AddLogger( TDUnitXConsoleLogger.Create( True ) );
    lRunner.AddLogger( TDUnitXXMLNUnitFileLogger.Create( sXmlFile ) );
    lResults        := lRunner.Execute;
    // The runner holds the XML logger, which keeps the file open until both are released; ConfirmLeaks rewrites it
    lRunner         := nil;
  end;

  var iConfirmedLeaks := ConfirmLeaks( lResults, sXmlFile,
    function: ITestRunner
    begin
      Result        := NewRunner( AOptions );
    end );

  if lResults.TestCount = 0 then
    Result          := 250
  else if ( lResults.FailureCount + lResults.ErrorCount + iWarmFailures + iConfirmedLeaks ) > 249 then
    Result          := 249 // clamp, so a large count cannot impersonate the 250 / 251 sentinels
  else
    // A confirmed leak is a failing test case in the XML too, so it counts here as well
    Result          := lResults.FailureCount + lResults.ErrorCount + iWarmFailures + iConfirmedLeaks;
  System.ExitCode   := Result;

  // A measurement that waited out the settle limit measured work still in progress, and cost 2 s: say so
  if SettleLimitHits > 0 then
    System.Writeln( Format( 'Settle limit  : %d measurement(s) waited %d ms with work still pending',
      [ SettleLimitHits, SETTLE_LIMIT_MS ] ) );
end;

end.
