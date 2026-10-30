(* GITLAK Software
  ***************************************************************************

    Copyright (C) 2026 Ian Branch (GITLAK Software).

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

  ***************************************************************************

  This code Unit is a GITLAK addition to the gllDUnitX fork ( not upstream ).

  ***************************************************************************

  Author(s) :
  Ian Branch - GITLAK Software.

  ***************************************************************************
  File last update : 2026-10-31 09:30:00 (UTC+11:00 DST)
  ***************************************************************************
*)

/// <summary>
///   Confirms the measured pass's leak reports by re-running the tests it flagged: a leak counts only if it repeats on
///   two re-runs; one clean re-run clears it.
/// </summary>
/// <remarks>
///   <para>
///     <b>Why.</b> The leak monitor measures the whole process, so an allocation another thread makes on its own
///     schedule ( the RTL pool's monitor thread, an OmniThreadLibrary worker parking for its next job ) is charged to
///     whichever test is running at that moment.  Measured 2026-10-22: 34 to 206 bytes, on different tests in each
///     full run, every one clean when run alone.  A real leak is deterministic and repeats; that noise almost never
///     lands on the same test three times running ( Ian, 2026-10-22, option 1 of three: confirm, keep digging, or a byte threshold,
///     which would hide real small leaks ).
///   </para>
///   <para>
///     <b>Nothing is hidden.</b> Every flagged test is listed on the console, confirmed or not, with its bytes.  An
///     unconfirmed one is rewritten in the NUnit XML as a success whose message keeps the original report, so
///     GITLAKMCP's <c>test_run</c>, which counts every failing test case, sees only confirmed leaks.
///   </para>
/// </remarks>
unit GllDUnitX.LeakConfirm;

interface

uses
  System.SysUtils, DUnitX.TestFramework;

/// <summary>
///   Re-runs every test <paramref name="AResults"/> reports as leaking, measured again, up to twice, prints the outcome, and
///   rewrites the leaks that did not repeat in <paramref name="AXmlFile"/> as successes that keep their message.
/// </summary>
/// <param name="AResults">The measured pass's results.</param>
/// <param name="AXmlFile">The NUnit XML file the measured pass wrote.</param>
/// <param name="ANewRunner">Creates each re-run's runner with the suite's own settings ( <c>FailsOnNoAsserts</c>, its
/// loggers ), so a test is judged on a re-run exactly as in the measured pass.</param>
/// <returns>The number of confirmed leaks ( 0 when nothing was flagged ).</returns>
/// <remarks>
///   Call after the measured pass, with the leak monitor still registered.  <c>TDUnitX.Options.Run</c>,
///   <c>RunListFile</c> and <c>TDUnitX.Filter</c> are restored afterwards.  A flagged test that fails, errors or is
///   ignored on a re-run is not cleared by it: only a passing re-run clears it.
/// </remarks>
function ConfirmLeaks( const AResults: IRunResults; const AXmlFile: string;
  const ANewRunner: TFunc<ITestRunner> ): Integer;

implementation

uses
  Winapi.Windows, System.Classes, System.Generics.Collections,
  DUnitX.FilterBuilder;

/// <summary>Collects the full names and messages of the tests a run reports as leaking.</summary>
/// <param name="AResults">The run's results.</param>
/// <returns>Full test name to the leak message.</returns>
function LeakedTests( const AResults: IRunResults ): TDictionary<string, string>;
begin
  Result            := TDictionary<string, string>.Create;
  for var lResult in AResults.GetAllTestResults do
    if lResult.ResultType = TTestResultType.MemoryLeak then
      Result.AddOrSetValue( lResult.Test.FullName, lResult.Message );
end;

/// <summary>Re-runs exactly the named tests, measured, on a runner configured as the measured pass's was.</summary>
/// <param name="ANames">The full names of the tests to run.</param>
/// <param name="ANewRunner">Creates the runner; see <see cref="ConfirmLeaks"/>.</param>
/// <returns>The full names the re-run did NOT clear: still leaking, failed, errored, ignored or not run at all; empty
/// for an empty <paramref name="ANames"/>, which runs nothing.</returns>
function RerunAndCollectUncleared( const ANames: TArray<string>; const ANewRunner: TFunc<ITestRunner> ): TList<string>;
begin
  Result            := TList<string>.Create;
  // An empty run list would build NO name filter, and the whole suite would run again, measured, for nothing
  if Length( ANames ) = 0 then Exit;

  var lSavedRun     := TDUnitX.Options.Run.Text;
  var lSavedRunList := TDUnitX.Options.RunListFile;
  var lSavedFilter  := TDUnitX.Filter;
  try
    TDUnitX.Options.Run.Clear;
    TDUnitX.Options.Run.AddStrings( ANames );
    TDUnitX.Options.RunListFile := ''; // a --runlist file would add its whole list to every re-run
    // DUnitX builds its filter once, in CheckCommandLine, so changing Options.Run alone does nothing: until this was
    // rebuilt each "re-run" ran the whole suite again ( measured 2026-10-22: about 2.5 minutes each under GITLAKMCP )
    TDUnitX.Filter  := TDUnitXFilterBuilder.BuildFilter( TDUnitX.Options );

    // The suite's own settings: a hard-coded FailsOnNoAsserts = True failed every re-run of an assert-free test in a
    // suite that allows them, and so confirmed any leak flagged on one ( review, 2026-10-22 )
    var lRunner     := ANewRunner;
    var lRerun      := lRunner.Execute;

    var lClean      := TList<string>.Create;
    try
      for var lResult in lRerun.GetAllTestResults do
        // Only a pass clears: an ignored test measured nothing
        if lResult.ResultType = TTestResultType.Pass then
          lClean.Add( lResult.Test.FullName );

      for var sName in ANames do
        if not lClean.Contains( sName ) then
          Result.Add( sName );
    finally
      lClean.Free;
    end;
  finally
    TDUnitX.Options.Run.Text := lSavedRun;
    TDUnitX.Options.RunListFile := lSavedRunList;
    TDUnitX.Filter  := lSavedFilter;
  end;
end;

/// <summary>The value of an attribute on one XML line, or '' when the line has no such attribute.</summary>
/// <param name="ALine">One line of DUnitX's NUnit XML.</param>
/// <param name="AName">The attribute name, e.g. <c>result</c>.</param>
/// <returns>The value between the quotes.</returns>
function AttrValue( const ALine, AName: string ): string;
begin
  Result            := '';
  var iStart        := Pos( ' ' + AName + '="', ALine );
  if iStart = 0 then Exit;
  Inc( iStart, Length( AName ) + 3 );
  var iEnd          := Pos( '"', ALine, iStart );
  if iEnd > 0 then Result := Copy( ALine, iStart, iEnd - iStart );
end;

/// <summary>
///   Undoes DUnitX's <c>EscapeForXML</c> on an attribute value, so a name read from the XML compares equal to the
///   <c>FullName</c> it was written from.  Until 2026-10-22 a test named with <c>&amp; &lt; &gt; " '</c> never matched,
///   so its unconfirmed leak stayed a failure in the XML while the exit code left it out.
/// </summary>
/// <param name="AValue">The attribute value as written.</param>
/// <returns>The original text.</returns>
function XmlUnescape( const AValue: string ): string;
begin
  // &amp; last, so an escaped "&amp;lt;" reads back as "&lt;", not "<"
  Result            := AValue.Replace( '&lt;', '<' ).Replace( '&gt;', '>' ).Replace( '&quot;', '"' )
    .Replace( '&#39;', '''' ).Replace( '&apos;', '''' ).Replace( '&amp;', '&' );
end;

/// <summary>Replaces an attribute's value on one XML line; the line is returned unchanged if it has no such attribute.</summary>
/// <param name="ALine">One line of DUnitX's NUnit XML.</param>
/// <param name="AName">The attribute name.</param>
/// <param name="AValue">The new value.</param>
/// <returns>The line with the value replaced.</returns>
function SetAttr( const ALine, AName, AValue: string ): string;
begin
  Result            := ALine;
  var iStart        := Pos( ' ' + AName + '="', ALine );
  if iStart = 0 then Exit;
  Inc( iStart, Length( AName ) + 3 );
  var iEnd          := Pos( '"', ALine, iStart );
  if iEnd > 0 then Result := Copy( ALine, 1, iStart - 1 ) + AValue + Copy( ALine, iEnd, MaxInt );
end;

type
  /// <summary>One open <c>test-suite</c> while the XML is walked.</summary>
  TSuiteFrame = record
    /// <summary>The suite's name, part of every enclosed case's full name unless it is the assembly.</summary>
    Name: string;
    /// <summary>True for <c>type="Assembly"</c>, whose name is not part of a test's full name.</summary>
    IsAssembly: Boolean;
    /// <summary>True for <c>type="Fixture"</c>: the suite whose name, with the case's, ends the test's full name.</summary>
    IsFixture: Boolean;
    /// <summary>Index of the suite's own line, so its result can be set once its contents are known.</summary>
    LineIndex: Integer;
    /// <summary>True once a case or suite inside it still fails or errors.</summary>
    Failing: Boolean;
    /// <summary>True once a case inside it was rewritten; only then may its own result be changed.</summary>
    Rewrote: Boolean;
  end;

/// <summary>
///   Finds the unconfirmed leak a test case in the XML belongs to.  The XML does not spell a test's full name the way
///   DUnitX's <c>FullName</c> does: for the unit <c>TestGll.AsyncGuard</c> its namespace suite is just <c>TestGll</c>.
///   So a case matches a full name that ENDS with its fixture and case names and STARTS with its outermost namespace.
/// </summary>
/// <param name="AUnconfirmed">Full name to the original leak message.</param>
/// <param name="AFlagged">Every flagged test's full name, confirmed or not: a case must match exactly one of these, so a
/// confirmed leak in a same-named fixture can never be taken for an unconfirmed one.</param>
/// <param name="AStack">The suites enclosing the case, outermost first.</param>
/// <param name="ACaseName">The case's <c>name</c> attribute.</param>
/// <param name="AMessage">The leak message of the match.</param>
/// <returns>True when exactly one unconfirmed leak matches; an ambiguous match is not rewritten ( the safe direction ).</returns>
function FindUnconfirmed( const AUnconfirmed, AFlagged: TDictionary<string, string>;
  const AStack: TList<TSuiteFrame>; const ACaseName: string; out AMessage: string ): Boolean;
begin
  Result            := False;
  var sFixture      := '';
  var sNamespace    := '';
  for var k := AStack.Count - 1 downto 0 do
    if AStack[ k ].IsFixture and ( sFixture = '' ) then sFixture := AStack[ k ].Name;
  for var k := 0 to AStack.Count - 1 do
    if not AStack[ k ].IsAssembly then
    begin
      sNamespace    := AStack[ k ].Name;
      Break;
    end;
  if ( sFixture = '' ) or ( ACaseName = '' ) then Exit;

  var sTail         := '.' + sFixture + '.' + ACaseName;
  var iMatches      := 0;
  var sMatch        := '';
  for var sName in AFlagged.Keys do
    if sName.EndsWith( sTail ) and ( ( sNamespace = '' ) or sName.StartsWith( sNamespace + '.' ) ) then
    begin
      Inc( iMatches );
      sMatch        := sName;
    end;
  Result            := ( iMatches = 1 ) and AUnconfirmed.TryGetValue( sMatch, AMessage );
end;

/// <summary>
///   Rewrites the unconfirmed leaks in DUnitX's NUnit XML as successes, line by line, keeping DUnitX's layout: each
///   such <c>test-case</c> line becomes <c>result="Success"</c>, its <c>failure</c> block becomes a <c>reason</c>
///   block keeping the original message, every suite's result is set from what it now contains, and the root's
///   <c>failures</c> count is lowered to match.
/// </summary>
/// <param name="AXmlFile">The NUnit XML file.</param>
/// <param name="AUnconfirmed">Full name to the original leak message, for the leaks that did not repeat.</param>
/// <param name="AFlagged">Every flagged test, confirmed or not; see <c>FindUnconfirmed</c>.</param>
/// <returns>The number of test cases rewritten.</returns>
/// <remarks>
///   Line by line, not through an XML DOM, because GITLAKMCP's <c>test_run</c> parses this file by lines in the layout
///   DUnitX writes: a DOM saved it on one line, and <c>test_run</c> then found no <c>test-results</c> root
///   ( 2026-10-22 ).  A case is rewritten only when its <c>failure</c> block is a leak report ( "were leaked" ), so a
///   genuine assertion failure is never turned into a success; only that block is replaced, and only a suite that
///   contained a rewritten case may change its own result.  The file is written beside the original and swapped in.
/// </remarks>
function RewriteXml( const AXmlFile: string; const AUnconfirmed, AFlagged: TDictionary<string, string> ): Integer;
begin
  Result            := 0;
  var lLines        := TStringList.Create;
  var lStack        := TList<TSuiteFrame>.Create;
  try
    lLines.LoadFromFile( AXmlFile, TEncoding.UTF8 );
    var iRoot       := -1;
    var i           := 0;

    while i < lLines.Count do
    begin
      var sTrim     := lLines[ i ].Trim;

      if sTrim.StartsWith( '<test-results ' ) then
        iRoot       := i

      else if sTrim.StartsWith( '<test-suite ' ) and not sTrim.EndsWith( '/>' ) then
      begin
        var rFrame: TSuiteFrame;
        rFrame.Name := XmlUnescape( AttrValue( sTrim, 'name' ) );
        rFrame.IsAssembly := SameText( AttrValue( sTrim, 'type' ), 'Assembly' );
        rFrame.IsFixture := SameText( AttrValue( sTrim, 'type' ), 'Fixture' );
        rFrame.LineIndex := i;
        rFrame.Failing := False;
        rFrame.Rewrote := False;
        lStack.Add( rFrame );
      end

      else if sTrim.StartsWith( '</test-suite>' ) and ( lStack.Count > 0 ) then
      begin
        var rFrame  := lStack.Last;
        lStack.Delete( lStack.Count - 1 );
        var sSuite  := lLines[ rFrame.LineIndex ];
        // Only a suite this rewrite touched may flip: one that failed for a reason with no test-case line of its
        // own ( a fixture-level error ) keeps its result
        if rFrame.Rewrote and ( not rFrame.Failing ) and SameText( AttrValue( sSuite, 'result' ), 'Failure' ) then
          lLines[ rFrame.LineIndex ] := SetAttr( SetAttr( sSuite, 'result', 'Success' ), 'success', 'True' );
        if lStack.Count > 0 then
        begin
          var rParent := lStack.Last;
          rParent.Failing := rParent.Failing or rFrame.Failing;
          rParent.Rewrote := rParent.Rewrote or rFrame.Rewrote;
          lStack[ lStack.Count - 1 ] := rParent;
        end;
      end

      else if sTrim.StartsWith( '<test-case ' ) then
      begin
        var sResult := AttrValue( sTrim, 'result' );
        var bFailing := SameText( sResult, 'Failure' ) or SameText( sResult, 'Error' );

        // The block runs to the case's closing line; a self-closing case has none
        var iClose  := -1;
        if not sTrim.EndsWith( '/>' ) then
          for var j := i + 1 to lLines.Count - 1 do
            if lLines[ j ].Trim.StartsWith( '</test-case>' ) then
            begin
              iClose := j;
              Break;
            end;

        var sMessage: string;
        if SameText( sResult, 'Failure' ) and ( iClose > i )
          and FindUnconfirmed( AUnconfirmed, AFlagged, lStack, XmlUnescape( AttrValue( sTrim, 'name' ) ), sMessage ) then
        begin
          var sBlock := '';
          for var j := i + 1 to iClose - 1 do sBlock := sBlock + lLines[ j ];

          // Only the failure block is replaced: anything else in the case ( a categories block ) is kept
          var iFailOpen := -1;
          var iFailClose := -1;
          for var j := i + 1 to iClose - 1 do
            if lLines[ j ].Trim.StartsWith( '<failure>' ) and ( iFailOpen < 0 ) then
              iFailOpen := j
            else if lLines[ j ].Trim.StartsWith( '</failure>' ) and ( iFailOpen >= 0 ) then
            begin
              iFailClose := j;
              Break;
            end;

          if sBlock.Contains( 'were leaked' ) and ( iFailOpen > i ) and ( iFailClose > iFailOpen ) then
          begin
            var sIndent := Copy( lLines[ iFailOpen ], 1, Length( lLines[ iFailOpen ] ) -
              Length( lLines[ iFailOpen ].TrimLeft ) );
            lLines[ i ] := SetAttr( SetAttr( lLines[ i ], 'result', 'Success' ), 'success', 'True' );
            for var j := iFailClose downto iFailOpen do lLines.Delete( j );
            // ']]>' would end the CDATA section early
            var sNote   := ( 'Leak report not repeated on a re-run ( another thread''s allocation ): ' +
              sMessage.Trim ).Replace( ']]>', ']] >' );
            lLines.Insert( iFailOpen, sIndent + '<reason>' );
            lLines.Insert( iFailOpen + 1, sIndent + '  <message>' );
            lLines.Insert( iFailOpen + 2, sIndent + '    <![CDATA[ ' + sNote + ' ]]>' );
            lLines.Insert( iFailOpen + 3, sIndent + '  </message>' );
            lLines.Insert( iFailOpen + 4, sIndent + '</reason>' );
            iClose  := iClose - ( iFailClose - iFailOpen + 1 ) + 5;
            bFailing := False;
            Inc( Result );
            if lStack.Count > 0 then
            begin
              var rFrame := lStack.Last;
              rFrame.Rewrote := True;
              lStack[ lStack.Count - 1 ] := rFrame;
            end;
          end;
        end;

        if bFailing and ( lStack.Count > 0 ) then
        begin
          var rFrame := lStack.Last;
          rFrame.Failing := True;
          lStack[ lStack.Count - 1 ] := rFrame;
        end;

        if iClose > i then i := iClose;
      end;

      Inc( i );
    end;

    if ( Result > 0 ) and ( iRoot >= 0 ) then
    begin
      var iFailures := StrToIntDef( AttrValue( lLines[ iRoot ], 'failures' ), -1 );
      if iFailures >= Result then
        lLines[ iRoot ] := SetAttr( lLines[ iRoot ], 'failures', IntToStr( iFailures - Result ) )
      else
        System.Writeln( Format( 'Leak confirm  : the XML root says failures="%d", below the %d rewritten; left as it was',
          [ iFailures, Result ] ) );
    end;

    // Written beside it and swapped in, so a failed write ( a full disk ) never leaves a truncated results file
    if Result > 0 then
    begin
      var sTemp     := AXmlFile + '.tmp';
      try
        lLines.SaveToFile( sTemp, TEncoding.UTF8 );
        if not MoveFileEx( PChar( sTemp ), PChar( AXmlFile ), MOVEFILE_REPLACE_EXISTING or MOVEFILE_WRITE_THROUGH ) then
          RaiseLastOSError;
      except
        // A half-written temporary file must not be left beside the results
        System.SysUtils.DeleteFile( sTemp );
        raise;
      end;
    end;
  finally
    lStack.Free;
    lLines.Free;
  end;
end;

function ConfirmLeaks( const AResults: IRunResults; const AXmlFile: string;
  const ANewRunner: TFunc<ITestRunner> ): Integer;
begin
  Result            := 0;
  var lFlagged      := LeakedTests( AResults );
  try
    if lFlagged.Count = 0 then
    begin
      System.Writeln( 'Leak confirm  : no leaks flagged' );
      Exit;
    end;

    // Up to two re-runs, and one clean re-run clears a test: a real leak repeats every time, while another thread's
    // allocation landed on the same test twice running in one measured full run ( 2026-10-22, the concurrent
    // TParallel.For test: clean in two of three runs alone ).
    var lFirst      := RerunAndCollectUncleared( lFlagged.Keys.ToArray, ANewRunner );
    var lUncleared: TList<string>;
    try
      lUncleared    := RerunAndCollectUncleared( lFirst.ToArray, ANewRunner );
    finally
      lFirst.Free;
    end;
    var lUnconfirmed := TDictionary<string, string>.Create;
    try
      for var lPair in lFlagged do
        if lUncleared.Contains( lPair.Key ) then
        begin
          Inc( Result );
          System.Writeln( '  leak confirmed on two re-runs: ' + lPair.Key + ': ' + lPair.Value.Trim );
        end
        else
        begin
          lUnconfirmed.Add( lPair.Key, lPair.Value );
          System.Writeln( '  leak NOT repeated on a re-run ( another thread''s allocation ): ' + lPair.Key + ': ' +
            lPair.Value.Trim );
        end;

      var iRewritten := 0;
      if ( lUnconfirmed.Count > 0 ) and FileExists( AXmlFile ) then
        try
          iRewritten := RewriteXml( AXmlFile, lUnconfirmed, lFlagged );
        except
          // The safe direction: the XML keeps every flagged leak as a failure, so test_run still reports it
          on E: Exception do
            System.Writeln( 'Leak confirm  : could not rewrite the XML, every flagged leak still counts: ' +
              E.ClassName + ': ' + E.Message );
        end;

      System.Writeln( Format( 'Leak confirm  : %d flagged, %d confirmed, %d not repeated ( %d rewritten in the XML )',
        [ lFlagged.Count, Result, lUnconfirmed.Count, iRewritten ] ) );
    finally
      lUnconfirmed.Free;
      lUncleared.Free;
    end;
  finally
    lFlagged.Free;
  end;
end;

end.
