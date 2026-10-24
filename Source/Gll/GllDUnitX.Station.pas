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
  File last update : 2026-10-25 05:00:00 (UTC+11:00 DST)
  ***************************************************************************
*)

/// <summary>
///   Whether the test process runs on an interactive window station, and a guard that ignores a test which cannot
///   prove anything when it does not.
/// </summary>
/// <remarks>
///   <para>
///     GITLAKMCP's <c>test_run</c> starts a suite from a Windows service, so the suite inherits the service's
///     NON-interactive window station ( <c>Service-0x0-...$</c> ).  Its desktop window has no <c>WS_VISIBLE</c>, and
///     because <c>IsWindowVisible</c> walks the parent chain up to the desktop, every window there reports invisible:
///     <c>DisableTaskWindows</c> disables nothing, no window receives <c>WM_PAINT</c>, <c>PrintWindow</c> renders
///     blank, visual styles are off and there is one monitor.  Focus, activation, <c>PaintTo</c> and timer-driven
///     modal loops still work.  Measured 2026-10-25 by probes on a private station.
///   </para>
///   <para>
///     The cause is the STATION, not the session: a hidden, never-switched desktop on <c>WinSta0</c> behaves
///     normally.  So the test is the station's <c>WSF_VISIBLE</c> flag, not <c>ProcessIdToSessionId</c>, which the
///     three suites that guarded this before ( gllSpell, gllAutomationServer, StyledComponents ) each checked in
///     their own way.
///   </para>
///   <para>
///     A suite adds <c>gllDUnitX\Source\Gll</c> to its unit search path, as for <c>GllDUnitX.SuiteRunner</c>.
///   </para>
/// </remarks>
unit GllDUnitX.Station;

interface

/// <summary>
///   True when this process's window station is interactive ( its <c>WSF_VISIBLE</c> flag is set ), so windows can
///   be visible, painted and enabled or disabled as a desktop session would.
/// </summary>
/// <returns>
///   False only when the station is positively known to be non-interactive.  If the flags cannot be read the answer
///   is True, so a test that needs a desktop runs and fails loudly rather than being skipped without cause.
/// </returns>
function IsInteractiveStation: Boolean;

/// <summary>The window station this process runs on, for a message or a log line.</summary>
/// <returns>
///   The station name and whether it is interactive, e.g. <c>WinSta0 ( interactive )</c> or
///   <c>Service-0x0-6d6d2$ ( non-interactive )</c>; <c>unknown</c> parts when the station cannot be queried.
/// </returns>
function StationDescription: string;

/// <summary>
///   Ignores the calling test when the window station is not interactive, saying why, so the test is reported as
///   Ignored instead of passing without having looked or failing for the environment.
/// </summary>
/// <param name="ANeeds">
///   What the test needs that a non-interactive station cannot give, e.g. <c>'WM_PAINT delivery'</c>; it is named in
///   the ignore message.
/// </param>
procedure RequireInteractiveStation( const ANeeds: string );

implementation

uses
  Winapi.Windows, System.SysUtils, DUnitX.TestFramework;

/// <summary>Reads the <c>WSF_VISIBLE</c> flag of this process's window station.</summary>
/// <param name="AVisible">Receives True when the flag is set, and True when the call fails.</param>
/// <returns>True when the flags were read.</returns>
function TryStationVisible( out AVisible: Boolean ): Boolean;
var
  LFlags  : TUserObjectFlags;
  LNeeded : DWORD;
begin

  AVisible := True;
  LNeeded  := 0;
  var hStation := GetProcessWindowStation;
  Result := ( hStation <> 0 ) and GetUserObjectInformation( hStation, UOI_FLAGS, @LFlags, SizeOf( LFlags ), LNeeded );
  if Result then
    AVisible := ( LFlags.dwFlags and WSF_VISIBLE ) <> 0;

end;

function IsInteractiveStation: Boolean;
begin

  var bVisible: Boolean;
  Result := ( not TryStationVisible( bVisible ) ) or bVisible;

end;

function StationDescription: string;
var
  LName   : array[ 0..255 ] of Char;
  LNeeded : DWORD;
begin

  var sName := 'unknown';
  LNeeded := 0;
  var hStation := GetProcessWindowStation;
  if ( hStation <> 0 ) and GetUserObjectInformation( hStation, UOI_NAME, @LName, SizeOf( LName ), LNeeded ) then
    sName := LName;

  var bVisible: Boolean;
  if not TryStationVisible( bVisible ) then
    Result := sName + ' ( interactivity unknown )'
  else if bVisible then
    Result := sName + ' ( interactive )'
  else
    Result := sName + ' ( non-interactive )';

end;

procedure RequireInteractiveStation( const ANeeds: string );
begin

  if not IsInteractiveStation then
    Assert.Ignore( Format( 'Needs %s, which window station %s cannot give ( no visible windows, no WM_PAINT, ' +
      'one monitor, no visual styles ); GITLAKMCP test_run starts suites from its service.  Run the suite from a ' +
      'desktop session to include it.', [ ANeeds, StationDescription ] ) );

end;

end.
