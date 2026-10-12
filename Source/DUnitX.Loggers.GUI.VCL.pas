{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2017 Vincent Parrett                              }
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

// gllDUnitX: this VCL GUI runner has been fixed and updated in this fork (2026-10-12, see CHANGELOG.md).
// It is not maintained upstream, which recommends the TestInsight IDE plug-in instead; whether to use
// TestInsight or this runner is the user's choice.
unit DUnitX.Loggers.GUI.VCL;

interface

{$I DUnitX.inc}

// Be aware that editing this in the higher versions of RAD Studio (10 Seattle for sure)
// results in the form designer continuously adding units to the uses that are
// already there.  I have been unable to find a workaround short of editing the
// file outside of the IDE...  The units are: System.ImageList and System.Actions

uses
{$IFDEF USE_NS}
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.UITypes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ActnList,
  Vcl.StdActns,
  Vcl.ActnCtrls,
  Vcl.ToolWin,
  Vcl.ActnMan,
  Vcl.ActnMenus,
  Vcl.ImgList,
  Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  Vcl.Menus,
  Vcl.ActnPopup,
  System.Generics.Defaults,
  System.Generics.Collections,
  System.IniFiles,
  System.Actions,                       //IDE keeps adding this at the end even if it's in the infdef'd section. make sure it's not there when committing!
{$ELSE}
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  ActnList,
  StdActns,
  ActnCtrls,
  ToolWin,
  ActnMan,
  ActnMenus,
  ImgList,
  PlatformDefaultStyleActnCtrls,
  ExtCtrls,
  ComCtrls,
  StdCtrls,
  Menus,
  ActnPopup,
  Generics.Defaults,
  Generics.Collections,
  IniFiles,
{$ENDIF}
  DUnitX.TestFrameWork,
  DUnitX.Extensibility,
  DUnitX.Filters,
  DUnitX.InternalInterfaces,
  DUnitX.ResStrs,
  DUnitX.ComparableFormat,
  DUnitX.ComparableFormat.Xml,
  DUnitX.ComparableFormat.Csv,
  DUnitX.Loggers.GUI.VCL.RichEdit, System.ImageList;

const
  /// <summary>Posted by <c>FormShow</c> so the tests are loaded once the window has appeared.</summary>
  WM_LOAD_TESTS     = WM_USER + 123;

type
  /// <summary>
  ///   Node of the test tree: a fixture or a test, with a tick box (its state image) and a result icon. Ticking or
  ///   unticking a node applies to all its children and keeps its parents' ticks consistent.
  /// </summary>
  TTestNode = class(TTreeNode)
  private
    /// <summary>True when the node is a fixture rather than a test.</summary>
    FIsFixtureNode : boolean;
  public
    /// <summary>True when the node is a fixture rather than a test.</summary>
    property IsFixtureNode : boolean read FIsFixtureNode;
    /// <summary>
    ///   Toggles the node's tick and sets every descendant to match. Ticking also ticks each unticked ancestor;
    ///   unticking unticks each ancestor that is left with no ticked child.
    /// </summary>
    procedure InvertState;
    /// <summary>
    ///   Ranks a result icon by severity so that the worst result of a test, or of a fixture's tests, wins.
    /// </summary>
    /// <param name="ImageIndex">A result image index: -1 not run, 0 ignored, 1 pass, 3 warning; anything else is an error.</param>
    /// <returns>The severity: -1 not run, 0 ignored, 1 pass, 2 warning, 3 failure or error.</returns>
    class function ToWeight(const ImageIndex : integer) : integer;
    /// <summary>Converts a severity from <c>ToWeight</c> back to the result image index that shows it.</summary>
    /// <param name="Weight">The severity: -1 not run, 0 ignored, 1 pass, 2 warning; anything else is an error.</param>
    /// <returns>The result image index.</returns>
    class function ToImageIndex(const Weight : integer) : integer;
  end;

  /// <summary>
  ///   Node of the results tree: a test's result, its message, or a log line. A comparable failure also carries the
  ///   expected and actual text, so they can be copied or opened in Beyond Compare.
  /// </summary>
  TResultNode = class(TTreeNode)
  public
    /// <summary>
    ///   The full name of the test the result belongs to, or empty for a root, message or log node. A name rather than
    ///   a node reference, because the test tree is rebuilt whenever the filter changes.
    /// </summary>
    TestFullName : string;
    /// <summary>True when the result carries expected and actual values that can be compared.</summary>
    IsComparable : boolean;
    /// <summary>The expected value of a comparable failure.</summary>
    Expected : string;
    /// <summary>The actual value of a comparable failure.</summary>
    Actual : string;
    /// <summary>The format of the compared values (XML, CSV, ...), which picks the temporary files' extension.</summary>
    Format : TDUnitXComparableFormatClass;

    /// <summary>Initialises the node as not comparable.</summary>
    procedure AfterConstruction; override;
  end;

  /// <summary>
  ///   The VCL GUI test runner form, itself a test logger: lists the tests in a tickable tree (filterable by name and
  ///   by the command line), runs the ticked or the selected test, and shows the results as a structured tree and as
  ///   a coloured text log. A run can be stopped (Esc) after the current test; ticks are remembered per user between
  ///   sessions. Tests that make no assertions are failed by the runner and shown as warnings.
  /// </summary>
  TGUIVCLTestRunner = class(TForm, ITestLogger)
    /// <summary>Holds the form's actions and the layout of its action toolbars.</summary>
    ActionManager : TActionManager;
    /// <summary>Images for the actions' toolbar buttons and menu items.</summary>
    ActionImages : TImageList;
    /// <summary>Runs the test selected in the test tree.</summary>
    actRunSelected : TAction;
    /// <summary>Runs every ticked test (F9).</summary>
    actRun : TAction;
    /// <summary>Panel holding the test name filter.</summary>
    pnlFilter : TPanel;
    /// <summary>Caption of the test name filter.</summary>
    lblFilter : TLabel;
    /// <summary>Tick box images for the test tree's state icons.</summary>
    StateImages : TImageList;
    /// <summary>Result icons (pass, failure, ignored, warning, comparable, log levels) for both trees.</summary>
    ResultImages : TImageList;
    /// <summary>Panel holding the tests and results panes.</summary>
    pnlClient : TPanel;
    /// <summary>Toolbar of the tests pane (run, select, invert).</summary>
    tbrTests : TActionToolBar;
    /// <summary>Ticks every test.</summary>
    actTestsSelectAll : TAction;
    /// <summary>Unticks every test.</summary>
    actTestsUnselectAll : TAction;
    /// <summary>Splitter between the tests and results panes.</summary>
    splMain : TSplitter;
    /// <summary>The tests pane.</summary>
    pnlTests : TPanel;
    /// <summary>Tree of fixtures and tests, with tick boxes and result icons.</summary>
    tvwTests : TTreeView;
    /// <summary>The results pane.</summary>
    pnlResults : TPanel;
    /// <summary>Toolbar of the results pane (compare, expand, collapse).</summary>
    tbrResults : TActionToolBar;
    /// <summary>Opens the selected comparable failure's expected and actual values in Beyond Compare.</summary>
    actCompare : TAction;
    /// <summary>Pages for the structured and text views of the results.</summary>
    pgeResults : TPageControl;
    /// <summary>Page holding the structured results tree.</summary>
    tabStructured : TTabSheet;
    /// <summary>Results grouped by outcome, with each test's message and log lines.</summary>
    tvwResults : TTreeView;
    /// <summary>Status bar showing the load status, notices and warnings.</summary>
    stsMain : TStatusBar;
    /// <summary>Context menu of the results tree.</summary>
    popResults : TPopupActionBar;
    /// <summary>Results context menu item for <c>actCompare</c>.</summary>
    itmComparePop : TMenuItem;
    /// <summary>Context menu of the test tree.</summary>
    popTests : TPopupActionBar;
    /// <summary>Test context menu item for <c>actRunSelected</c>.</summary>
    RunAll1 : TMenuItem;
    /// <summary>Test context menu item for <c>actRun</c>.</summary>
    RunAll2 : TMenuItem;
    /// <summary>Inverts the tick on every test.</summary>
    actTestsInvert : TAction;
    /// <summary>Header panel of the tests pane.</summary>
    pnlTestsTop : TPanel;
    /// <summary>Heading of the tests pane.</summary>
    lblTestsHeader : TLabel;
    /// <summary>Header panel of the results pane.</summary>
    pnlResultsTop : TPanel;
    /// <summary>Heading of the results pane.</summary>
    lblResultsHeader : TLabel;
    /// <summary>Expands every node of the results tree.</summary>
    actResultsExpandAll : TAction;
    /// <summary>Collapses every node of the results tree.</summary>
    actResultsCollapseAll : TAction;
    /// <summary>Page holding the text log.</summary>
    tabText : TTabSheet;
    /// <summary>Coloured text log written by <c>TDUnitXGUIVCLRichEditLogger</c>.</summary>
    rchText : TRichEdit;
    /// <summary>Panel framing the text log.</summary>
    pnlText : TPanel;
    /// <summary>Scrolls the text log to the selected test's output.</summary>
    actFindInText : TAction;
    /// <summary>Test context menu item for <c>actFindInText</c>.</summary>
    itmFindInText : TMenuItem;
    /// <summary>Separator in the test context menu.</summary>
    N1 : TMenuItem;
    /// <summary>Selects the selected test's entry in the results tree.</summary>
    actFindInStructured : TAction;
    /// <summary>Test context menu item for <c>actFindInStructured</c>.</summary>
    itmFindInStructured : TMenuItem;
    /// <summary>Icon in the tests pane header.</summary>
    imgTests : TImage;
    /// <summary>Icon in the results pane header.</summary>
    imgResults : TImage;
    /// <summary>Test name filter: Enter applies it, the right button clears it.</summary>
    edtFilter : TButtonedEdit;
    /// <summary>Copies the selected comparable failure's actual value to the clipboard.</summary>
    actCopyActual : TAction;
    /// <summary>Copies the selected comparable failure's expected value to the clipboard.</summary>
    actCopyExpected : TAction;
    /// <summary>Separator in the results context menu.</summary>
    N2 : TMenuItem;
    /// <summary>Results context menu item for <c>actCopyExpected</c>.</summary>
    itmCopyExpected : TMenuItem;
    /// <summary>Results context menu item for <c>actCopyActual</c>.</summary>
    itmCopyActual : TMenuItem;
    /// <summary>Progress of the current run, in tests begun.</summary>
    pgResults : TProgressBar;
    /// <summary>Status of the current run (idle, running N of M, stopping, closing).</summary>
    txtStatus : TLabel;
    /// <summary>Panel of result counts shown after a run, in place of the status.</summary>
    pnlSummary : TPanel;
    /// <summary>Caption of the ignored count.</summary>
    lblIgnored : TLabel;
    /// <summary>Caption of the passed count.</summary>
    lblPassed : TLabel;
    /// <summary>Number of tests passed.</summary>
    txtPassed : TLabel;
    /// <summary>Number of tests ignored.</summary>
    txtIgnored : TLabel;
    /// <summary>Caption of the failed count.</summary>
    lblFailed : TLabel;
    /// <summary>Number of tests failed, not counting no-assertion warnings.</summary>
    txtFailed : TLabel;
    /// <summary>Caption of the errored count.</summary>
    lblErrored : TLabel;
    /// <summary>Number of tests that raised an unexpected exception.</summary>
    txtErrored : TLabel;
    /// <summary>Caption of the memory leak count.</summary>
    lblMemLeak : TLabel;
    /// <summary>Number of tests that leaked memory.</summary>
    txtMemLeak : TLabel;
    /// <summary>Caption of the warning count.</summary>
    lblWarnings : TLabel;
    /// <summary>Number of tests that made no assertions.</summary>
    txtWarnings : TLabel;
    /// <summary>Unticks every test and refreshes the actions.</summary>
    /// <param name="Sender">The action.</param>
    procedure actTestsUnselectAllExecute(Sender : TObject);
    /// <summary>
    ///   Writes the selected comparable failure's expected and actual values to temporary files and opens them in
    ///   Beyond Compare without waiting; the files are deleted when the form is destroyed (or at once if it fails to
    ///   start).
    /// </summary>
    /// <param name="Sender">The action.</param>
    procedure actCompareExecute(Sender : TObject);
    /// <summary>Copies the selected comparable failure's actual value; a busy clipboard is reported in the status bar.</summary>
    /// <param name="Sender">The action.</param>
    procedure actCopyActualExecute(Sender : TObject);
    /// <summary>Copies the selected comparable failure's expected value; a busy clipboard is reported in the status bar.</summary>
    /// <param name="Sender">The action.</param>
    procedure actCopyExpectedExecute(Sender : TObject);
    /// <summary>Collapses the whole results tree.</summary>
    /// <param name="Sender">The action.</param>
    procedure actResultsCollapseAllExecute(Sender : TObject);
    /// <summary>Expands the whole results tree.</summary>
    /// <param name="Sender">The action.</param>
    procedure actResultsExpandAllExecute(Sender : TObject);
    /// <summary>Deletes the comparison temporary files and frees the form's lists and maps (before the trees).</summary>
    /// <param name="Sender">The form.</param>
    procedure FormDestroy(Sender : TObject);
    /// <summary>Runs every ticked test, selected by exact full name.</summary>
    /// <param name="Sender">The action.</param>
    procedure actRunExecute(Sender : TObject);
    /// <summary>Runs the test selected in the test tree.</summary>
    /// <param name="Sender">The action.</param>
    procedure actRunSelectedExecute(Sender : TObject);
    /// <summary>Shows the text log scrolled to the selected test's output, or says none was found.</summary>
    /// <param name="Sender">The action.</param>
    procedure actFindInTextExecute(Sender : TObject);
    /// <summary>Shows the results tree with the selected test's result selected and expanded, or says none was found.</summary>
    /// <param name="Sender">The action.</param>
    procedure actFindInStructuredExecute(Sender : TObject);
    /// <summary>Inverts the tick on every test and refreshes the actions.</summary>
    /// <param name="Sender">The action.</param>
    procedure actTestsInvertExecute(Sender : TObject);
    /// <summary>Ticks every test and refreshes the actions.</summary>
    /// <param name="Sender">The action.</param>
    procedure actTestsSelectAllExecute(Sender : TObject);
    /// <summary>Clears the filter and reloads the test tree; ignored during a run.</summary>
    /// <param name="Sender">The filter edit.</param>
    procedure edtFilterRightButtonClick(Sender : TObject);
    /// <summary>On Enter, applies the filter by reloading the test tree (not during a run) and swallows the key.</summary>
    /// <param name="Sender">The filter edit.</param>
    /// <param name="Key">The key pressed; set to #0 when it is Enter.</param>
    procedure edtFilterKeyPress(Sender : TObject; var Key : Char);
    /// <summary>
    ///   Sizes the form to the monitor's work area, creates the lists and maps, takes the command-line filter, reads
    ///   the remembered ticks and arranges for the trees to be rebuilt rather than restored if their windows are
    ///   recreated.
    /// </summary>
    /// <param name="Sender">The form.</param>
    procedure FormCreate(Sender : TObject);
    /// <summary>F9 runs the ticked tests; Esc stops a run after the current test.</summary>
    /// <param name="Sender">The form.</param>
    /// <param name="Key">The key pressed; cleared when Esc stops a run.</param>
    /// <param name="Shift">The modifier keys held.</param>
    procedure FormKeyDown(Sender : TObject; var Key : Word; Shift : TShiftState);
    /// <summary>Splits the panes evenly and, the first time only, posts <c>WM_LOAD_TESTS</c> to load the tests.</summary>
    /// <param name="Sender">The form.</param>
    procedure FormShow(Sender : TObject);
    /// <summary>Makes the test tree create <c>TTestNode</c> nodes.</summary>
    /// <param name="Sender">The test tree.</param>
    /// <param name="NodeClass">Set to <c>TTestNode</c>.</param>
    procedure tvwTestsCreateNodeClass(Sender : TCustomTreeView; var NodeClass : TTreeNodeClass);
    /// <summary>Space toggles the selected node's tick (not during a run).</summary>
    /// <param name="Sender">The test tree.</param>
    /// <param name="Key">The key pressed; set to #0 when it is a space.</param>
    procedure tvwTestsKeyPress(Sender : TObject; var Key : Char);
    /// <summary>A left click on a tick box toggles it (not during a run, and not on a double-click's second press).</summary>
    /// <param name="Sender">The test tree.</param>
    /// <param name="Button">The mouse button pressed.</param>
    /// <param name="Shift">The modifier keys and click state.</param>
    /// <param name="X">The horizontal position of the click, in client coordinates.</param>
    /// <param name="Y">The vertical position of the click, in client coordinates.</param>
    procedure tvwTestsMouseDown(Sender : TObject; Button : TMouseButton; Shift : TShiftState; X, Y : Integer);
    /// <summary>Refreshes the actions when the selected result changes.</summary>
    /// <param name="Sender">The results tree.</param>
    /// <param name="Node">The newly selected node.</param>
    procedure tvwResultsChange(Sender : TObject; Node : TTreeNode);
    /// <summary>Makes the results tree create <c>TResultNode</c> nodes.</summary>
    /// <param name="Sender">The results tree.</param>
    /// <param name="NodeClass">Set to <c>TResultNode</c>.</param>
    procedure tvwResultsCreateNodeClass(Sender : TCustomTreeView; var NodeClass : TTreeNodeClass);
    /// <summary>Saves the remembered ticks.</summary>
    /// <param name="Sender">The form.</param>
    /// <param name="Action">How the form closes; left unchanged.</param>
    procedure FormClose(Sender : TObject; var Action : TCloseAction);
    /// <summary>
    ///   Refuses to close mid-run; instead stops the run, and the form closes once the current test has finished.
    /// </summary>
    /// <param name="Sender">The form.</param>
    /// <param name="CanClose">Set to False while a run is in progress.</param>
    procedure FormCloseQuery(Sender : TObject; var CanClose : Boolean);
    /// <summary>Draws fixture nodes in bold, in the window text colour unless selected.</summary>
    /// <param name="Sender">The test tree.</param>
    /// <param name="Node">The node being drawn.</param>
    /// <param name="State">The node's drawing state.</param>
    /// <param name="DefaultDraw">Left True so the tree draws the node itself.</param>
    procedure tvwTestsCustomDrawItem(Sender : TCustomTreeView; Node : TTreeNode;
      State : TCustomDrawState; var DefaultDraw : Boolean);
    /// <summary>Refreshes the actions when the selected test changes.</summary>
    /// <param name="Sender">The test tree.</param>
    /// <param name="Node">The newly selected node.</param>
    procedure tvwTestsChange(Sender : TObject; Node : TTreeNode);
  private type
  /// <summary>Callback for the tree iterators: called once per node; set <c>Stop</c> to end the iteration.</summary>
  TTreeViewIterateProc = reference to procedure(const Node : TTreeNode; var Stop : boolean);
  private
    /// <summary>Every fixture in the executable, as last built for the test tree.</summary>
    FFixtureList : ITestFixtureList;
    /// <summary>Line in the text log where each test's output begins, by full name; filled by the rich edit logger.</summary>
    FTestBookmarkList : TTestBookmarkList;
    /// <summary>The results tree's root node for each outcome, or nil until a result of that outcome arrives.</summary>
    FRootNodes : array[TTestResultType] of TTreeNode;
    /// <summary>Test tree nodes by full name (tests and the first fixture of each name).</summary>
    FTestNodes : TDictionary<string, TTreeNode>;
    /// <summary>True while a run is in progress.</summary>
    FRunning : boolean;
    /// <summary>Number of fixture nodes in the test tree, so the test count excludes them.</summary>
    FFixtureCount : integer;
    /// <summary>The filter from the command line (<c>--run</c>, <c>--include</c>, <c>--exclude</c>), restored after each run.</summary>
    FCommandLineFilter : ITestFilter;
    /// <summary>The fixtures of the run in progress, so that <c>StopRun</c> can disable the tests not yet run.</summary>
    FRunFixtures : ITestFixtureList;
    /// <summary>True once the user has asked to stop the current run.</summary>
    FStopRequested : boolean;
    /// <summary>True once the user has asked to close the form mid-run; it closes when the run ends.</summary>
    FCloseRequested : boolean;
    /// <summary>True once <c>WM_LOAD_TESTS</c> has been posted, so the tests load only on the first show.</summary>
    FLoadPosted : boolean;
    /// <summary>Number of tests in this run failed only for making no assertions.</summary>
    FWarningCount : integer;
    /// <summary>Number of tests left out of the tree because another test has the same full name.</summary>
    FDuplicateCount : integer;
    /// <summary>The first duplicated full name, for the status bar.</summary>
    FFirstDuplicate : string;
    /// <summary>Full names of the tests the user has unticked; sorted, case-sensitive and saved between sessions.</summary>
    FUncheckedTests : TStringList;
    /// <summary>Temporary comparison files handed to Beyond Compare, deleted when the form is destroyed.</summary>
    FTempFiles : TStringList;
    /// <summary>Results tree root for results that could not be displayed, or nil.</summary>
    FDisplayErrorRoot : TTreeNode;
    /// <summary>Status bar text from the last test load (count found, duplicates, or the load error).</summary>
    FLoadStatus : string;
    /// <summary>A transient notice appended to the status bar (run stopped, clipboard busy, results lost).</summary>
    FNotice : string;
    /// <summary>Fires after a tree's window was recreated, to rebuild the test tree once no run is in progress.</summary>
    FRebuildTimer : TTimer;
    /// <summary>True when the test tree's nodes were discarded by a window recreation and must be rebuilt.</summary>
    FTestsTreeLost : boolean;
    /// <summary>True when the results tree's nodes were discarded by a window recreation.</summary>
    FResultsTreeLost : boolean;

    /// <summary>
    ///   Rebuilds the test tree from the fixtures, keeping the user's ticks and re-applying the shown results, and
    ///   updates the status text.
    /// </summary>
    procedure LoadTests;
    /// <summary>Calls <c>LoadTests</c>, showing any exception in the status bar and a dialog instead of raising it.</summary>
    procedure TryLoadTests;
    /// <summary>
    ///   Drops every reference to a node being deleted from either tree; when the deletion comes from a window
    ///   recreation, remembers the tick and starts the rebuild timer.
    /// </summary>
    /// <param name="Sender">The tree the node belongs to.</param>
    /// <param name="Node">The node being deleted.</param>
    procedure TreeDeletion(Sender : TObject; Node : TTreeNode);
    /// <summary>Once no run is in progress, rebuilds the test tree and reports lost results after a window recreation.</summary>
    /// <param name="Sender">The rebuild timer.</param>
    procedure RebuildTimerTimer(Sender : TObject);
    /// <summary>Records a test node's tick in <c>FUncheckedTests</c>; fixture nodes are skipped.</summary>
    /// <param name="Node">The test tree node.</param>
    procedure RememberCheckedState(const Node : TTreeNode);
    /// <summary>
    ///   Removes from <c>FUncheckedTests</c> the names of tests no longer in the executable, so deleted or renamed tests
    ///   are not remembered for ever. Does nothing until the fixtures have been built.
    /// </summary>
    procedure PruneUncheckedTests;
    /// <summary>Reports whether any test (not fixture) node is ticked.</summary>
    /// <returns>True when at least one test is ticked.</returns>
    function AnyTestChecked : boolean;
    /// <summary>Shows a transient notice in the status bar.</summary>
    /// <param name="Text">The notice.</param>
    procedure ShowNotice(const Text : string);
    /// <summary>
    ///   Adds fixture and test nodes under a parent for every enabled test the command-line and name filters let
    ///   through, recursing into child fixtures. Fixtures with no such test are omitted; a test whose full name is
    ///   already listed is counted as a duplicate and left out.
    /// </summary>
    /// <param name="FixtureList">The fixtures to add.</param>
    /// <param name="ParentNode">The node to add them under, or nil for the top level.</param>
    procedure BuildTestTreeNode(const FixtureList : ITestFixtureList;
      const ParentNode : TTreeNode);
    /// <summary>Empties the results tree and resets every test's icon to "not run".</summary>
    procedure ClearResults;
    /// <summary>
    ///   Runs the tests a filter selects, with the GUI's loggers, then restores the command-line filter and the form
    ///   whatever happened, and closes the form if that was asked for mid-run.
    /// </summary>
    /// <param name="Filter">Selects the tests to run.</param>
    /// <param name="TestCount">The expected number of tests, for the progress bar.</param>
    procedure RunExecute(const Filter : ITestFilter; const TestCount : integer);
    /// <summary>
    ///   Stops the run after the current test by disabling every fixture and test not yet run; fixtures already
    ///   started still tear down. Does nothing when no run is in progress or a stop was already asked for.
    /// </summary>
    procedure StopRun;
    /// <summary>Shows the result of each result-tree entry on the matching test node, after the test tree is rebuilt.</summary>
    procedure ApplyResultsToTests;
    /// <summary>Lists a result that could not be displayed under a root of its own, with the reason.</summary>
    /// <param name="TestName">The full name of the test, if it was known.</param>
    /// <param name="Msg">The message of the exception that prevented display.</param>
    procedure AddResultDisplayError(const TestName, Msg : string);
    /// <summary>Records every test node's tick in <c>FUncheckedTests</c>.</summary>
    procedure CaptureCheckedState;
    /// <summary>
    ///   Returns the per-user settings file: <c>%LOCALAPPDATA%\DUnitX\&lt;exe name&gt;.ini</c> (the home folder when
    ///   LOCALAPPDATA is not set), since the executable's folder may be read-only.
    /// </summary>
    /// <returns>The full path of the settings file.</returns>
    function SettingsFileName : string;
    /// <summary>
    ///   Reads the unticked test names from the settings file, or from the older settings beside the executable;
    ///   unreadable settings just lose the remembered ticks.
    /// </summary>
    procedure ReadSettings;
    /// <summary>
    ///   Captures and prunes the ticks and writes the unticked test names to the settings file; a failure to save is
    ///   ignored so it cannot stop the form closing.
    /// </summary>
    procedure WriteSettings;
    /// <summary>Inverts the tick on every test node.</summary>
    procedure Invert;
    /// <summary>Ticks every node in the test tree.</summary>
    procedure SelectAll;
    /// <summary>Unticks every node in the test tree.</summary>
    procedure UnselectAll;
    /// <summary>
    ///   Creates a test runner logging to this form and to a rich edit logger on the text page, set to fail tests that
    ///   make no assertions.
    /// </summary>
    /// <returns>The new runner.</returns>
    function NeedRunner : ITestRunner;
    /// <summary>Finds the test tree node for a test's full name.</summary>
    /// <param name="TestFullName">The test's full name.</param>
    /// <returns>The node, or nil when the test is not listed (filtered out, or a fixture teardown failure).</returns>
    function GetNodeByTestFullName(const TestFullName : string) : TTreeNode;
    /// <summary>Calls a procedure for each node in <c>FTestNodes</c> until it sets <c>Stop</c>.</summary>
    /// <param name="Proc">The procedure to call; must be assigned.</param>
    /// <returns>True when the procedure stopped the iteration.</returns>
    function IterateTestNodes(const Proc : TTreeViewIterateProc) : boolean;
    /// <summary>
    ///   Shows a result on a test node unless it already shows a worse one, and propagates the worst result of each
    ///   fixture's children up to its ancestors.
    /// </summary>
    /// <param name="Node">The test tree node.</param>
    /// <param name="ImageIndex">The result image index to show.</param>
    procedure SetNodeTestResult(const Node : TTreeNode; const ImageIndex : integer);
    /// <summary>
    ///   Adds a finished test's result to the results tree under its outcome's root (a no-assertion failure as a
    ///   warning), with its message and log lines, and marks the test node. A result that cannot be displayed is
    ///   listed as such instead of raising, which would abort the run.
    /// </summary>
    /// <param name="Test">The finished test's result.</param>
    procedure ProcessTestResult(const Test : ITestResult);
    /// <summary>
    ///   Adds a result's message (for anything but a pass) and its log messages as child nodes of its result node.
    /// </summary>
    /// <param name="ResultNode">The result's node.</param>
    /// <param name="Test">The test's result.</param>
    procedure ProcessMessagesForNode(const ResultNode : TResultNode; const Test : ITestResult);
    /// <summary>Enables or disables the actions and the filter for the current state, and rewrites the status bar.</summary>
    procedure UpdateFormActions;
    /// <summary>Returns the results tree's selected node.</summary>
    /// <returns>The selected node, or nil when none is selected.</returns>
    function GetSelectedResultsNode : TResultNode;
    /// <summary>Returns the result entry (level 1) of the selected results node, if it is comparable.</summary>
    /// <returns>The comparable result node, or nil.</returns>
    function GetComparableResultsNode : TResultNode;
    /// <summary>Returns the results tree's root for an outcome, creating it on first use (passes last, others first).</summary>
    /// <param name="nodeType">The outcome.</param>
    /// <returns>The root node.</returns>
    function GetRootNode(const nodeType : TTestResultType) : TTreeNode;
    /// <summary>Shows the run's counts in the summary panel and, after a stopped run, a notice saying so.</summary>
    /// <param name="RunResults">The results of the whole run.</param>
    procedure UpdateGUIForComplete(const RunResults : IRunResults);
    /// <summary>Sets an outcome root's caption to its label and child count.</summary>
    /// <param name="nodeType">The outcome.</param>
    procedure UpdateRootNodeCaption(const nodeType : TTestResultType);
    /// <summary>Shows the progress bar and status for a new run.</summary>
    /// <param name="TestCount">The expected number of tests.</param>
    procedure UpdateGUIForRun(const TestCount : integer);
    /// <summary>Moves the progress bar (growing its maximum if needed) and updates the status text.</summary>
    /// <param name="CurrTestCount">The number of tests begun so far.</param>
    /// <param name="CurrTestName">The full name of the test now running, or empty.</param>
    procedure UpdateGUIForProgress(const CurrTestCount : integer; const CurrTestName : string);
  protected
    /// <summary>Advances the progress bar to the test and keeps the form responsive.</summary>
    /// <param name="threadId">The thread running the test.</param>
    /// <param name="Test">The test about to begin.</param>
    procedure OnBeginTest(const threadId : TThreadID; const Test : ITestInfo);
    /// <summary>Called after a fixture's setup. Does nothing.</summary>
    /// <param name="threadId">The thread running the fixture.</param>
    /// <param name="fixture">The fixture whose setup finished.</param>
    procedure OnEndSetupFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
    /// <summary>Called after a test's setup. Does nothing.</summary>
    /// <param name="threadId">The thread running the test.</param>
    /// <param name="Test">The test whose setup finished.</param>
    procedure OnEndSetupTest(const threadId : TThreadID; const Test : ITestInfo);
    /// <summary>Called after a fixture's teardown. Does nothing.</summary>
    /// <param name="threadId">The thread running the fixture.</param>
    /// <param name="fixture">The fixture whose teardown finished.</param>
    procedure OnEndTearDownFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
    /// <summary>Called after a test's teardown. Does nothing.</summary>
    /// <param name="threadId">The thread running the test.</param>
    /// <param name="Test">The test whose teardown finished.</param>
    procedure OnEndTeardownTest(const threadId : TThreadID; const Test : ITestInfo);
    /// <summary>Adds the finished test's result to the results tree and the test tree.</summary>
    /// <param name="threadId">The thread that ran the test.</param>
    /// <param name="Test">The finished test's result.</param>
    procedure OnEndTest(const threadId : TThreadID; const Test : ITestResult);
    /// <summary>Called when a fixture has finished. Does nothing.</summary>
    /// <param name="threadId">The thread that ran the fixture.</param>
    /// <param name="results">The fixture's aggregated results.</param>
    procedure OnEndTestFixture(const threadId : TThreadID; const results : IFixtureResult);
    /// <summary>Called before a test method executes. Does nothing.</summary>
    /// <param name="threadId">The thread running the test.</param>
    /// <param name="Test">The test about to execute.</param>
    procedure OnExecuteTest(const threadId : TThreadID; const Test : ITestInfo);
    /// <summary>Called for a log message. Does nothing: log lines are shown with each result.</summary>
    /// <param name="logType">The severity of the message.</param>
    /// <param name="msg">The message text.</param>
    procedure OnLog(const logType : TLogLevel; const msg : string);
    /// <summary>Called before a fixture's setup. Does nothing.</summary>
    /// <param name="threadId">The thread running the fixture.</param>
    /// <param name="fixture">The fixture being set up.</param>
    procedure OnSetupFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
    /// <summary>Called before a test's setup. Does nothing.</summary>
    /// <param name="threadId">The thread running the test.</param>
    /// <param name="Test">The test being set up.</param>
    procedure OnSetupTest(const threadId : TThreadID; const Test : ITestInfo);
    /// <summary>Called when a fixture starts. Does nothing.</summary>
    /// <param name="threadId">The thread running the fixture.</param>
    /// <param name="fixture">The fixture starting.</param>
    procedure OnStartTestFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
    /// <summary>Called before a fixture's teardown. Does nothing.</summary>
    /// <param name="threadId">The thread running the fixture.</param>
    /// <param name="fixture">The fixture being torn down.</param>
    procedure OnTearDownFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
    /// <summary>Called before a test's teardown. Does nothing.</summary>
    /// <param name="threadId">The thread running the test.</param>
    /// <param name="Test">The test being torn down.</param>
    procedure OnTeardownTest(const threadId : TThreadID; const Test : ITestInfo);
    /// <summary>Called when a test errors. Does nothing: the result arrives through <c>OnEndTest</c>.</summary>
    /// <param name="threadId">The thread that ran the test.</param>
    /// <param name="Error">The error result.</param>
    procedure OnTestError(const threadId : TThreadID; const Error : ITestError);
    /// <summary>Called when a test fails. Does nothing: the result arrives through <c>OnEndTest</c>.</summary>
    /// <param name="threadId">The thread that ran the test.</param>
    /// <param name="Failure">The failure result.</param>
    procedure OnTestFailure(const threadId : TThreadID; const Failure : ITestError);
    /// <summary>Called when a test passes. Does nothing: the result arrives through <c>OnEndTest</c>.</summary>
    /// <param name="threadId">The thread that ran the test.</param>
    /// <param name="Test">The passing test's result.</param>
    procedure OnTestSuccess(const threadId : TThreadID; const Test : ITestResult);
    /// <summary>Called when a test leaks. Does nothing: the result arrives through <c>OnEndTest</c>.</summary>
    /// <param name="threadId">The thread that ran the test.</param>
    /// <param name="Test">The leaking test's result.</param>
    procedure OnTestMemoryLeak(const threadId : TThreadID; const Test : ITestResult);
    /// <summary>Called when a test is ignored. Does nothing: the result arrives through <c>OnEndTest</c>.</summary>
    /// <param name="threadId">The thread that would have run the test.</param>
    /// <param name="Ignored">The ignored test's result.</param>
    procedure OnTestIgnored(const threadId : TThreadID; const Ignored : ITestResult);
    /// <summary>Shows the run's summary counts.</summary>
    /// <param name="RunResults">The results of the whole run.</param>
    procedure OnTestingEnds(const RunResults : IRunResults);
    /// <summary>
    ///   Sets the progress bar's maximum to the runner's count (the active count when ignored tests are hidden) and
    ///   resets it.
    /// </summary>
    /// <param name="threadId">The thread starting the run.</param>
    /// <param name="testCount">The total number of tests found.</param>
    /// <param name="testActiveCount">The number of tests that will actually run.</param>
    procedure OnTestingStarts(const threadId : TThreadID; testCount, testActiveCount : Cardinal);

    /// <summary>Loads the tests, after the form has first been shown.</summary>
    /// <param name="message">The <c>WM_LOAD_TESTS</c> message.</param>
    procedure WMLoadTests(var message : TMessage); message WM_LOAD_TESTS;
  end;

var
  /// <summary>The runner form created by <c>Run</c>.</summary>
  GUIVCLTestRunner : TGUIVCLTestRunner;

/// <summary>
///   Entry point of a GUI test executable: checks the command line, then creates and shows the runner form and runs
///   the application until it closes.
/// </summary>
procedure Run;

implementation

{$R *.dfm}

uses
{$IFDEF USE_NS}
  System.IOUtils,
  System.StrUtils,
  System.Math,
  System.Win.Registry,
  Vcl.Clipbrd,
{$ELSE}
  IOUtils,
  StrUtils,
  Math,
  Registry,
  Clipbrd,
{$ENDIF}
  DUnitX.Exceptions;

const
  cTestNodeStateUnchecked = 1;
  cTestNodeStateChecked = 2;

  cTestResultImageMap : array[TTestResultType] of integer = (1, 2, 2, 0, 2, 3);

  cLogLevelImageMap : array[TLogLevel] of integer = (6, 7, 8);

  cRootNodeStrings  : array[TTestResultType] of string = (STestsPassed, STestsFailed, STestsErrored, STestsIgnored, STestsLeaked, STestsWarning);

  cTestSetup        = 'TestSetup';
  cUncheckedTests   = 'UncheckedTests';

  cStatusSeparator  = '    ';

resourcestring
  SGUIStatusStopped = 'Run stopped: the results are for the tests that ran before it stopped';
  SGUINoTestsChecked = 'No tests are checked: tick the tests to run';
  SGUILoadTestsFailed = 'Could not load the tests: %s: %s';
  SGUIClipboardBusy = 'Could not copy to the clipboard: %s';
  SGUIResultsNotDisplayed = 'Results Not Displayed : %d';
  SGUIResultsLost = 'Results shown before the window was recreated were lost; run the tests again to see them';

type
  //can't return "array of string" on function (at least in XE)
  TStringArray = array of string;

  PathUtils = record
  public
    class function FindBeyondCompare : string; static;
    class function FindBeyondCompareInRegistry : string; static;
    class function GetProgramFiles : TStringArray; static;
    class function MakeTempFile(const Contents : string; const FileExtNoDot : string = '') : string; static;
    class function Launch(const CmdLine : string; out ErrorMsg : string) : boolean; static;
    class function Compare(const ExpFile, ActFile : string) : boolean; static;
  end;

  TTreeViewHelper = class helper for TTreeView
  public
    function IterateAll(const Proc : TGUIVCLTestRunner.TTreeViewIterateProc) : boolean;
    procedure DiscardNodesOnRecreate;
  end;

  TTreeNodeHelper = class helper for TTreeNode
  public
    function IterateAllChilds(const Proc : TGUIVCLTestRunner.TTreeViewIterateProc) : boolean;
    function IterateChilds(const Proc : TGUIVCLTestRunner.TTreeViewIterateProc) : boolean;
    function IterateParents(const Proc : TGUIVCLTestRunner.TTreeViewIterateProc) : boolean;
  end;

procedure Run;
begin
  TDUnitX.CheckCommandLine;

  Application.Initialize;
  Application.CreateForm(TGUIVCLTestRunner, GUIVCLTestRunner);
  Application.Run;
end;

procedure TGUIVCLTestRunner.actTestsUnselectAllExecute(Sender : TObject);
begin
  UnselectAll;
  UpdateFormActions;
end;

procedure TGUIVCLTestRunner.actCompareExecute(Sender : TObject);
var
  ResultNode : TResultNode;
  FileExt : string;
  ExpFile : string;
  ActFile : string;
  Launched : boolean;
begin
  ResultNode := GetComparableResultsNode;
  if ResultNode <> nil then
  begin
    if ResultNode.Format = TDUnitXComparableFormatXml then
      FileExt := 'xml'
    else if ResultNode.Format = TDUnitXComparableFormatCsv then
      FileExt := 'csv'
    else
      FileExt := '';

    ExpFile := '';
    ActFile := '';
    Launched := False;
    try
      //Save files
      ExpFile := PathUtils.MakeTempFile(ResultNode.Expected, FileExt);
      ActFile := PathUtils.MakeTempFile(ResultNode.Actual, FileExt);
      //Spawn BC. It is not waited for, so its files are deleted when the runner closes.
      Launched := PathUtils.Compare(ExpFile, ActFile);
    finally
      if Launched then
      begin
        FTempFiles.Add(ExpFile);
        FTempFiles.Add(ActFile);
      end
      else
      begin
        if ExpFile <> '' then
          DeleteFile(ExpFile);
        if ActFile <> '' then
          DeleteFile(ActFile);
      end;
    end;
  end;
end;

procedure TGUIVCLTestRunner.actCopyActualExecute(Sender : TObject);
var
  ResultNode : TResultNode;
begin
  ResultNode := GetComparableResultsNode;
  if ResultNode <> nil then
  try
    Clipboard.AsText := ResultNode.Actual;
  except
    //Another program holding the clipboard open is no reason for an error dialog.
    on E : EClipboardException do
      ShowNotice(Format(SGUIClipboardBusy, [E.Message]));
  end;
end;

procedure TGUIVCLTestRunner.actCopyExpectedExecute(Sender : TObject);
var
  ResultNode : TResultNode;
begin
  ResultNode := GetComparableResultsNode;
  if ResultNode <> nil then
  try
    Clipboard.AsText := ResultNode.Expected;
  except
    //Another program holding the clipboard open is no reason for an error dialog.
    on E : EClipboardException do
      ShowNotice(Format(SGUIClipboardBusy, [E.Message]));
  end;
end;

procedure TGUIVCLTestRunner.actResultsCollapseAllExecute(Sender : TObject);
begin
  tvwResults.FullCollapse;
end;

procedure TGUIVCLTestRunner.actResultsExpandAllExecute(Sender : TObject);
begin
  tvwResults.FullExpand;
end;

procedure TGUIVCLTestRunner.FormDestroy(Sender : TObject);
var
  TempFile : string;
begin
  for TempFile in FTempFiles do
    DeleteFile(TempFile);
  FreeAndNil(FTempFiles);
  FreeAndNil(FUncheckedTests);
  FreeAndNil(FTestBookmarkList);
  //The trees are freed after this, and TreeDeletion must then find no map to update.
  FreeAndNil(FTestNodes);
end;

function TGUIVCLTestRunner.GetComparableResultsNode : TResultNode;
var
  Selected : TResultNode;
begin
  Result := nil;

  Selected := GetSelectedResultsNode;
  if Selected <> nil then
  begin
    //The result is level 1; its message is level 2 and the message's log lines level 3.
    while Selected.Level > 1 do
      Selected := Selected.Parent as TResultNode;

    if Selected.IsComparable then
      Result := Selected;
  end;
end;

function TGUIVCLTestRunner.GetNodeByTestFullName(const TestFullName : string) : TTreeNode;
begin
  //A result can name a test that is not listed: filtered out, or a fixture teardown failure.
  if not FTestNodes.TryGetValue(TestFullName, Result) then
    Result := nil;
end;

function TGUIVCLTestRunner.GetRootNode(const nodeType : TTestResultType) : TTreeNode;
begin
  if FRootNodes[nodeType] = nil then
  begin
    if nodeType = TTestResultType.Pass then
      Result := tvwResults.Items.Add(nil, '')
    else
      Result := tvwResults.Items.AddFirst(nil, '');
    Result.ImageIndex := cTestResultImageMap[nodeType];
    Result.SelectedIndex := Result.ImageIndex;
    FRootNodes[nodeType] := Result;
  end;
  Result := FRootNodes[nodeType];
end;

function TGUIVCLTestRunner.GetSelectedResultsNode : TResultNode;
begin
  Result := nil;

  if tvwResults.Selected <> nil then
    Result := tvwResults.Selected as TResultNode;
end;

procedure TGUIVCLTestRunner.actRunExecute(Sender : TObject);
var
  StrList : TStringList;
  TestFilter : ITestFilter;
  TestCount : integer;
begin
  StrList := TStringList.Create;
  try
    IterateTestNodes(
      procedure(const Node : TTreeNode; var Stop : boolean)
      begin
        if (not TTestNode(Node).IsFixtureNode) and
          (Node.StateIndex = cTestNodeStateChecked) then
          StrList.Add(Node.Text);
      end);
    //Exact names: TNameFilter would also run every fixture whose name starts with a checked test's name.
    TestFilter := TFullNameFilter.Create(StrList);
    TestCount := StrList.Count;
  finally
    StrList.Free;
  end;

  RunExecute(TestFilter, TestCount);
end;

procedure TGUIVCLTestRunner.actRunSelectedExecute(Sender : TObject);
begin
  if tvwTests.Selected <> nil then
    RunExecute(TFullNameFilter.Create(tvwTests.Selected.Text), 1);
end;

procedure TGUIVCLTestRunner.actFindInTextExecute(Sender : TObject);
var
  LineNum : integer;
  Found : boolean;
begin
  Found := False;

  if tvwTests.Selected <> nil then
  begin
    pgeResults.ActivePage := tabText;
    if FTestBookmarkList.TryGetValue(tvwTests.Selected.Text, LineNum) then
    begin
      rchText.Perform(EM_LINESCROLL, 0, LineNum - rchText.Perform(EM_GETFIRSTVISIBLELINE, 0, 0));
      Found := True;
    end;
  end;

  if not Found then
    MessageDlg(SCouldNotFindResultsForTest, mtInformation, [mbOK], 0);
end;

procedure TGUIVCLTestRunner.actFindInStructuredExecute(Sender : TObject);
var
  Found : boolean;
begin
  Found := False;

  if tvwTests.Selected <> nil then
  begin
    pgeResults.ActivePage := tabStructured;

    tvwResults.IterateAll
      (
      procedure(const Node : TTreeNode; var Stop : boolean)
      var
        ResultNode : TResultNode;
      begin
        ResultNode := Node as TResultNode;
        if (ResultNode.TestFullName <> '') and (ResultNode.TestFullName = tvwTests.Selected.Text) then
        begin
          tvwResults.Selected := ResultNode;
          tvwResults.Selected.Expand(True);
          Found := True;
          Stop := True;
        end;
      end
      );
  end;

  if not Found then
    MessageDlg(SCouldNotFindResultsForTest, mtInformation, [mbOK], 0);
end;

procedure TGUIVCLTestRunner.actTestsInvertExecute(Sender : TObject);
begin
  Invert;
  UpdateFormActions;
end;

procedure TGUIVCLTestRunner.actTestsSelectAllExecute(Sender : TObject);
begin
  SelectAll;
  UpdateFormActions;
end;

procedure TGUIVCLTestRunner.FormClose(Sender : TObject; var Action : TCloseAction);
begin
  WriteSettings;
end;

procedure TGUIVCLTestRunner.FormCloseQuery(Sender : TObject; var CanClose : Boolean);
begin
  CanClose := not FRunning;
  if FRunning then
  begin
    //Closing mid-run stops the run; the window closes once the current test has finished.
    FCloseRequested := True;
    StopRun;
    txtStatus.Caption := SGUIStatusClosing;
  end;
end;

procedure TGUIVCLTestRunner.FormCreate(Sender : TObject);
begin
  Width := Monitor.WorkareaRect.Width;
  Height := Monitor.WorkareaRect.Height;

  FTestBookmarkList := TTestBookmarkList.Create;
  FTestNodes := TDictionary<string, TTreeNode>.Create;
  FTempFiles := TStringList.Create;
  FUncheckedTests := TStringList.Create;
  FUncheckedTests.CaseSensitive := True;
  FUncheckedTests.Duplicates := dupIgnore;
  FUncheckedTests.Sorted := True;
  //The command line's --run / --include / --exclude decide which tests are listed.
  FCommandLineFilter := TDUnitX.Filter;
  ReadSettings;

  //A recreated tree window would otherwise re-read its nodes as new objects without their fields,
  //leaving FTestNodes and FRootNodes pointing at freed ones. Instead the nodes are deleted (TreeDeletion
  //drops every reference to them) and RebuildTimerTimer rebuilds the test tree.
  tvwTests.DiscardNodesOnRecreate;
  tvwResults.DiscardNodesOnRecreate;
  tvwTests.OnDeletion := TreeDeletion;
  tvwResults.OnDeletion := TreeDeletion;
  //A timer has a window of its own, so it still fires when the form's window is the one recreated.
  FRebuildTimer := TTimer.Create(Self);
  FRebuildTimer.Enabled := False;
  FRebuildTimer.Interval := 100;
  FRebuildTimer.OnTimer := RebuildTimerTimer;

  Self.Caption := Format(SApplicationName, [ExtractFileName(ParamStr(0))]);
  Application.Title := Self.Caption;

  txtStatus.Caption := SGUIStatusIdle;
  txtStatus.Visible := True;
  pnlSummary.Visible := False;

  pgeResults.ActivePageIndex := 0;
  //The actions are enabled in the form file; nothing can run until the tests have loaded.
  UpdateFormActions;
end;

function TGUIVCLTestRunner.NeedRunner : ITestRunner;
begin
  Result := TDUnitX.CreateRunner([Self, TDUnitXGUIVCLRichEditLogger.Create(rchText, FTestBookmarkList)]);
  Result.FailsOnNoAsserts := True;
end;

procedure TGUIVCLTestRunner.OnBeginTest(const threadId : TThreadID; const Test : ITestInfo);
begin
  UpdateGUIForProgress(pgResults.Position + 1, Test.FullName);
  Application.ProcessMessages;
end;

procedure TGUIVCLTestRunner.OnEndSetupFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
begin
  //Empty
end;

procedure TGUIVCLTestRunner.OnEndSetupTest(const threadId : TThreadID; const Test : ITestInfo);
begin
  //Empty
end;

procedure TGUIVCLTestRunner.OnEndTearDownFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
begin
  //Empty
end;

procedure TGUIVCLTestRunner.OnEndTeardownTest(const threadId : TThreadID; const Test : ITestInfo);
begin
  //Empty
end;

procedure TGUIVCLTestRunner.OnEndTest(const threadId : TThreadID; const Test : ITestResult);
begin
  ProcessTestResult(Test);
end;

procedure TGUIVCLTestRunner.OnEndTestFixture(const threadId : TThreadID; const results : IFixtureResult);
begin
  //Empty
end;

procedure TGUIVCLTestRunner.OnExecuteTest(const threadId : TThreadID; const Test : ITestInfo);
begin
  //Empty
end;

procedure TGUIVCLTestRunner.OnLog(const logType : TLogLevel; const msg : string);
begin
  //Empty
end;

procedure TGUIVCLTestRunner.OnSetupFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
begin
  //Empty
end;

procedure TGUIVCLTestRunner.OnSetupTest(const threadId : TThreadID; const Test : ITestInfo);
begin
  //Empty
end;

procedure TGUIVCLTestRunner.OnStartTestFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
begin
  //Empty
end;

procedure TGUIVCLTestRunner.OnTearDownFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
begin
  //Empty
end;

procedure TGUIVCLTestRunner.OnTeardownTest(const threadId : TThreadID; const Test : ITestInfo);
begin
  //Empty
end;

procedure TGUIVCLTestRunner.OnTestError(const threadId : TThreadID; const Error : ITestError);
begin
  //Empty
end;

procedure TGUIVCLTestRunner.OnTestFailure(const threadId : TThreadID; const Failure : ITestError);
begin
  //Empty
end;

procedure TGUIVCLTestRunner.OnTestIgnored(const threadId : TThreadID; const Ignored : ITestResult);
begin
  //Empty
end;

procedure TGUIVCLTestRunner.OnTestingEnds(const RunResults : IRunResults);
begin
  UpdateGUIForComplete(RunResults);
end;

procedure TGUIVCLTestRunner.OnTestingStarts(const threadId : TThreadID; testCount, testActiveCount : Cardinal);
begin
  //The runner's own count includes repeated and same-named tests, which the checked names do not.
  //Ignored tests are begun (and so counted by the progress bar) unless they are not shown.
  if TDUnitX.Options.DontShowIgnored then
    pgResults.Max := Integer(testActiveCount)
  else
    pgResults.Max := Integer(testCount);
  UpdateGUIForProgress(0, '');
end;

procedure TGUIVCLTestRunner.OnTestMemoryLeak(const threadId : TThreadID; const Test : ITestResult);
begin
  //Empty
end;

procedure TGUIVCLTestRunner.OnTestSuccess(const threadId : TThreadID; const Test : ITestResult);
begin
  //Empty
end;

procedure TGUIVCLTestRunner.ProcessMessagesForNode(const ResultNode : TResultNode; const Test : ITestResult);
var
  LogMessage : TLogMessage;
  LogMessageNode : TTreeNode;
  ParentNode : TTreeNode;
begin
  if Test.ResultType = TTestResultType.Pass then
    ParentNode := ResultNode
  else
  begin
    ParentNode := ResultNode.Owner.AddChild(ResultNode, ReplaceStr(Test.Message, #13#10, ' '));
    ParentNode.ImageIndex := ResultNode.ImageIndex;
    ParentNode.SelectedIndex := ParentNode.ImageIndex;
  end;

  if Test.LogMessages <> nil then
  begin
    for LogMessage in Test.LogMessages do
    begin
      LogMessageNode := ResultNode.Owner.AddChild(ParentNode, LogMessage.Msg);
      LogMessageNode.ImageIndex := cLogLevelImageMap[LogMessage.Level];
      LogMessageNode.SelectedIndex := LogMessageNode.ImageIndex;
    end;
  end;
end;

procedure TGUIVCLTestRunner.ProcessTestResult(const Test : ITestResult);
var
  Error : ITestError;
  ParentNode : TTreeNode;
  ResultNode : TResultNode;
  TestNode : TTreeNode;
  TestName : string;
  testResult : TTestResultType;
  RootType : TTestResultType;
begin
  TestName := '';
  ResultNode := nil;
  tvwResults.Items.BeginUpdate;
  try
    //A result that cannot be displayed is reported in the tree; raising here would abort the whole run.
    try
      TestName := Test.Test.FullName;
      testResult := Test.ResultType;
      //The GUI makes the runner fail tests that make no assertions; they are filed and counted as warnings.
      if (testResult = TTestResultType.Failure) and (Test.Message = SNoAssertions) then
      begin
        testResult := TTestResultType.Warning;
        Inc(FWarningCount);
      end;

      ParentNode := GetRootNode(testResult);
      ResultNode := tvwResults.Items.AddChild(ParentNode, TestName) as TResultNode;
      ResultNode.TestFullName := TestName;
      ResultNode.ImageIndex := ParentNode.ImageIndex;
      ResultNode.SelectedIndex := ResultNode.ImageIndex;

      if (Test.QueryInterface(ITestError, Error) = 0) and Error.IsComparable then
      begin
        ResultNode.IsComparable := True;
        ResultNode.Expected := Error.Expected;
        ResultNode.Actual := Error.Actual;
        ResultNode.Format := Error.Format;
        ResultNode.ImageIndex := 9;
        ResultNode.SelectedIndex := ResultNode.ImageIndex;
      end;

      ProcessMessagesForNode(ResultNode, Test);
      TestNode := GetNodeByTestFullName(TestName);
      if TestNode <> nil then
        SetNodeTestResult(TestNode, ResultNode.ImageIndex);
      UpdateRootNodeCaption(testResult);
      //Expand a root only when it appears, so a root the user has collapsed stays collapsed.
      if ParentNode.Count = 1 then
        ParentNode.Expand(False);
      ResultNode.Expand(True);
    except
      on E : Exception do
      begin
        //Remove the half-built entry, and the root it alone made, so each root counts only what it shows.
        if ResultNode <> nil then
        begin
          ParentNode := ResultNode.Parent;
          ResultNode.Delete;
          if ParentNode.Count = 0 then
            ParentNode.Delete
          else
            for RootType := Low(TTestResultType) to High(TTestResultType) do
              if FRootNodes[RootType] = ParentNode then
                UpdateRootNodeCaption(RootType);
        end;
        AddResultDisplayError(TestName, E.Message);
      end;
    end;
  finally
    tvwResults.Items.EndUpdate;
  end;
  Application.ProcessMessages;
end;

procedure TGUIVCLTestRunner.LoadTests;
var
  Runner : ITestRunner;
  StatusText : string;
begin
  //Keep the user's ticks across a re-filter: the rebuilt tree reads them back.
  CaptureCheckedState;

  Runner := NeedRunner;

  FFixtureList := Runner.BuildFixtures as ITestFixtureList;

  tvwTests.Items.BeginUpdate;
  try
    tvwTests.Items.Clear;
    FTestNodes.Clear;
    FFixtureCount := 0;
    FDuplicateCount := 0;
    FFirstDuplicate := '';
    BuildTestTreeNode(FFixtureList, nil);

    if tvwTests.Items.Count > 0 then
    begin
      tvwTests.AlphaSort(True);
      tvwTests.Selected := tvwTests.Items[0];
      tvwTests.TopItem := tvwTests.Selected;
    end;
  finally
    tvwTests.Items.EndUpdate;
  end;

  //Results refer to tests by full name, so they survive the rebuild; show them on the new nodes.
  ApplyResultsToTests;

  StatusText := Format(STestsFound, [tvwTests.Items.Count - FFixtureCount]);
  if FDuplicateCount > 0 then
    StatusText := StatusText + cStatusSeparator + Format(SGUIDuplicateTestNames, [FDuplicateCount, FFirstDuplicate]);
  FLoadStatus := StatusText;

  //Also writes the status bar.
  UpdateFormActions;
end;

procedure TGUIVCLTestRunner.TryLoadTests;
begin
  try
    LoadTests;
  except
    //Shown rather than re-raised: the caller is a message or event handler, and the form stays usable.
    on E : Exception do
    begin
      FLoadStatus := Format(SGUILoadTestsFailed, [E.ClassName, E.Message]);
      UpdateFormActions;
      MessageDlg(FLoadStatus, mtError, [mbOK], 0);
    end;
  end;
end;

procedure TGUIVCLTestRunner.TreeDeletion(Sender : TObject; Node : TTreeNode);
var
  Mapped : TTreeNode;
  RootType : TTestResultType;
begin
  //The form frees its maps before its trees, whose nodes are then deleted.
  if (csDestroying in ComponentState) or (FTestNodes = nil) then
    Exit;

  if Sender = tvwTests then
  begin
    if csRecreating in tvwTests.ControlState then
    begin
      //The ticks live only on the nodes; keep them for the rebuilt tree.
      RememberCheckedState(Node);
      FTestsTreeLost := True;
    end;
    if FTestNodes.TryGetValue(Node.Text, Mapped) and (Mapped = Node) then
      FTestNodes.Remove(Node.Text);
  end
  else
  begin
    if csRecreating in tvwResults.ControlState then
      FResultsTreeLost := True;
    for RootType := Low(TTestResultType) to High(TTestResultType) do
      if FRootNodes[RootType] = Node then
        FRootNodes[RootType] := nil;
    if FDisplayErrorRoot = Node then
      FDisplayErrorRoot := nil;
  end;

  if FTestsTreeLost or FResultsTreeLost then
    FRebuildTimer.Enabled := True;
end;

procedure TGUIVCLTestRunner.RebuildTimerTimer(Sender : TObject);
begin
  //Rebuilding the test tree mid-run would free the nodes the running tests report to; wait for the run to end.
  if FRunning then
    Exit;
  FRebuildTimer.Enabled := False;

  if FResultsTreeLost then
  begin
    FResultsTreeLost := False;
    FNotice := SGUIResultsLost;
  end;

  if FTestsTreeLost then
  begin
    FTestsTreeLost := False;
    //The results tree still holds what it shows; LoadTests puts those results back on the tests.
    TryLoadTests;
  end
  else
    UpdateFormActions;
end;

procedure TGUIVCLTestRunner.RunExecute(const Filter : ITestFilter; const TestCount : integer);
var
  Runner : ITestRunner;
begin
  FRunning := true;
  FStopRequested := False;
  FNotice := '';
  UpdateFormActions;
  UpdateGUIForRun(TestCount);
  Screen.Cursor := crHourGlass;
  try
    ClearResults;
    //Make sure UI is up-to-date before entering test run
    Application.ProcessMessages;

    TDUnitX.Filter := Filter;
    Runner := NeedRunner;
    //Held so that StopRun can disable the tests that have not run yet.
    FRunFixtures := Runner.BuildFixtures as ITestFixtureList;
    Runner.Execute;

    if tvwResults.Items.Count > 0 then
      tvwResults.TopItem := tvwResults.Items[0];

    tvwTests.Invalidate;
  finally
    //Whatever happened, the form must be usable again.
    TDUnitX.Filter := FCommandLineFilter;
    FRunFixtures := nil;
    FRunning := False;
    Screen.Cursor := crDefault;
    if txtStatus.Visible then
      txtStatus.Caption := SGUIStatusIdle;
    UpdateFormActions;
  end;

  if FCloseRequested then
    Close;
end;

procedure TGUIVCLTestRunner.StopRun;

  procedure DisableTests(const Fixtures : ITestFixtureList);
  var
    Fixture : ITestFixture;
    Test : ITest;
  begin
    for Fixture in Fixtures do
    begin
      //A fixture not yet started is skipped whole; the running one has passed this check and still tears down.
      Fixture.Enabled := False;
      for Test in Fixture.Tests do
        Test.Enabled := False;
      if Fixture.HasChildFixtures then
        DisableTests(Fixture.Children);
    end;
  end;

begin
  if (not FRunning) or FStopRequested then
    Exit;
  FStopRequested := True;
  //The runner skips disabled tests and fixtures, so the run ends after the current test. Started fixtures still tear down.
  if FRunFixtures <> nil then
    DisableTests(FRunFixtures);
  txtStatus.Caption := SGUIStatusStopping;
end;

procedure TGUIVCLTestRunner.ApplyResultsToTests;
var
  Node : TTreeNode;
  TestNode : TTreeNode;
begin
  for Node in tvwResults.Items do
  begin
    if (Node.Level = 1) and (TResultNode(Node).TestFullName <> '') then
    begin
      TestNode := GetNodeByTestFullName(TResultNode(Node).TestFullName);
      if TestNode <> nil then
        SetNodeTestResult(TestNode, Node.ImageIndex);
    end;
  end;
end;

procedure TGUIVCLTestRunner.AddResultDisplayError(const TestName, Msg : string);
var
  Node : TTreeNode;
begin
  //A root of their own: these results are counted under their real type in the summary, so the Errored
  //root, which counts its children, must not count them too.
  if FDisplayErrorRoot = nil then
  begin
    FDisplayErrorRoot := tvwResults.Items.AddFirst(nil, '');
    FDisplayErrorRoot.ImageIndex := cTestResultImageMap[TTestResultType.Error];
    FDisplayErrorRoot.SelectedIndex := FDisplayErrorRoot.ImageIndex;
  end;
  Node := tvwResults.Items.AddChild(FDisplayErrorRoot, Format(SGUIResultDisplayError, [TestName, Msg]));
  Node.ImageIndex := cTestResultImageMap[TTestResultType.Error];
  Node.SelectedIndex := Node.ImageIndex;
  FDisplayErrorRoot.Text := Format(SGUIResultsNotDisplayed, [FDisplayErrorRoot.Count]);
  if FDisplayErrorRoot.Count = 1 then
    FDisplayErrorRoot.Expand(False);
end;

procedure TGUIVCLTestRunner.RememberCheckedState(const Node : TTreeNode);
var
  Index : integer;
begin
  if TTestNode(Node).IsFixtureNode then
    Exit;
  if Node.StateIndex = cTestNodeStateChecked then
  begin
    if FUncheckedTests.Find(Node.Text, Index) then
      FUncheckedTests.Delete(Index);
  end
  else
    FUncheckedTests.Add(Node.Text);
end;

procedure TGUIVCLTestRunner.CaptureCheckedState;
begin
  IterateTestNodes(
    procedure(const Node : TTreeNode; var Stop : boolean)
    begin
      RememberCheckedState(Node);
    end);
end;

procedure TGUIVCLTestRunner.PruneUncheckedTests;

  procedure AddTestNames(const Fixtures : ITestFixtureList; const Names : TStringList);
  var
    Fixture : ITestFixture;
    Test : ITest;
  begin
    for Fixture in Fixtures do
    begin
      if Fixture.Tests <> nil then
        for Test in Fixture.Tests do
          Names.Add(Test.FullName);
      if Fixture.HasChildFixtures then
        AddTestNames(Fixture.Children, Names);
    end;
  end;

var
  Names : TStringList;
  i : integer;
begin
  //Pruned against every test in the executable, not the tree, which lists only what the filters let through.
  //Without that list nothing is known to be gone.
  if FFixtureList = nil then
    Exit;
  Names := TStringList.Create;
  try
    Names.CaseSensitive := True;
    Names.Duplicates := dupIgnore;
    Names.Sorted := True;
    AddTestNames(FFixtureList, Names);
    for i := FUncheckedTests.Count - 1 downto 0 do
      if Names.IndexOf(FUncheckedTests[i]) < 0 then
        FUncheckedTests.Delete(i);
  finally
    Names.Free;
  end;
end;

function TGUIVCLTestRunner.SettingsFileName : string;
var
  Dir : string;
begin
  //Per user, not beside the exe, whose folder may be read-only.
  Dir := GetEnvironmentVariable('LOCALAPPDATA');
  if Dir = '' then
    Dir := TPath.GetHomePath;
  Result := TPath.Combine(TPath.Combine(Dir, 'DUnitX'), ChangeFileExt(ExtractFileName(ParamStr(0)), '.ini'));
end;

procedure TGUIVCLTestRunner.ReadSettings;
var
  IniFile : TMemIniFile;
  Lines : TStringList;
  OldFile : string;
  i : integer;
begin
  FUncheckedTests.Clear;
  Lines := TStringList.Create;
  try
    try
      if TFile.Exists(SettingsFileName) then
      begin
        IniFile := TMemIniFile.Create(SettingsFileName, TEncoding.UTF8);
        try
          //The names are values, not keys: a test name can contain '='.
          IniFile.ReadSectionValues(cUncheckedTests, Lines);
          for i := 0 to Lines.Count - 1 do
            FUncheckedTests.Add(Lines.ValueFromIndex[i]);
        finally
          IniFile.Free;
        end;
      end
      else
      begin
        //Settings used to be kept beside the exe, as one Boolean per test name.
        OldFile := ChangeFileExt(ParamStr(0), '.ini');
        if TFile.Exists(OldFile) then
        begin
          IniFile := TMemIniFile.Create(OldFile);
          try
            IniFile.ReadSection(cTestSetup, Lines);
            for i := 0 to Lines.Count - 1 do
              if not IniFile.ReadBool(cTestSetup, Lines[i], True) then
                FUncheckedTests.Add(Lines[i]);
          finally
            IniFile.Free;
          end;
        end;
      end;
    except
      //Unreadable settings only lose the remembered ticks.
      on EStreamError do
        FUncheckedTests.Clear;
      on EEncodingError do
        FUncheckedTests.Clear;
      on EIniFileException do
        FUncheckedTests.Clear;
      on EInOutError do
        FUncheckedTests.Clear;
    end;
  finally
    Lines.Free;
  end;
end;

procedure TGUIVCLTestRunner.WriteSettings;
var
  IniFile : TMemIniFile;
  i : integer;
begin
  CaptureCheckedState;
  //Names of tests since deleted or renamed would otherwise be kept for ever.
  PruneUncheckedTests;
  try
    ForceDirectories(ExtractFilePath(SettingsFileName));
    IniFile := TMemIniFile.Create(SettingsFileName, TEncoding.UTF8);
    try
      IniFile.EraseSection(cUncheckedTests);
      for i := 0 to FUncheckedTests.Count - 1 do
        IniFile.WriteString(cUncheckedTests, IntToStr(i + 1), FUncheckedTests[i]);
      IniFile.UpdateFile;
    finally
      IniFile.Free;
    end;
  except
    //Settings are a convenience: failing to save them must not stop the window closing.
    on EStreamError do
      ;
    on EEncodingError do
      ;
    on EIniFileException do
      ;
    on EInOutError do
      ;
  end;
end;

procedure TGUIVCLTestRunner.SetNodeTestResult(const Node : TTreeNode; const ImageIndex : integer);

var
  NewWeight : integer;
begin
  NewWeight := TTestNode.ToWeight(ImageIndex);
  //A test can have several results (a repeated or same-named test): the worst one shows, so a later
  //pass cannot turn a failed test green. ClearResults resets the icons, so a new run starts from 'not run'.
  if NewWeight < TTestNode.ToWeight(Node.ImageIndex) then
    Exit;

  Node.ImageIndex := ImageIndex;
  Node.SelectedIndex := ImageIndex;

  Node.IterateParents(
    procedure(const Node : TTreeNode; var Stop : boolean)
    var
      Weight : integer;
    begin
      Weight := TTestNode.ToWeight(Node.ImageIndex);
      if Weight = NewWeight then
        Stop := true
      else
      begin
        if NewWeight < Weight then
        begin
          Node.IterateChilds(
            procedure(const Node : TTreeNode; var Stop : boolean)
            var
              ChildWeight : integer;
            begin
              ChildWeight := TTestNode.ToWeight(Node.ImageIndex);
              if NewWeight < ChildWeight then
                NewWeight := ChildWeight;
            end);
          if Weight = NewWeight then
          begin
            Stop := true;
            Exit;
          end;
        end;
        Node.ImageIndex := TTestNode.ToImageIndex(NewWeight);
        Node.SelectedIndex := Node.ImageIndex;
      end;
    end);
end;

procedure TGUIVCLTestRunner.BuildTestTreeNode(const FixtureList : ITestFixtureList;
  const ParentNode : TTreeNode);

  function IsListed(const Test : ITest) : boolean;
  begin
    Result := Test.Enabled and
      ((FCommandLineFilter = nil) or FCommandLineFilter.Match(Test)) and
      ((edtFilter.Text = '') or ContainsText(Test.FullName, edtFilter.Text));
  end;

  function HasFilteredTests(Fixture : ITestFixture) : boolean;
  var
    Test : ITest;
  begin
    Result := false;
    if Fixture.Tests = nil then
      Exit;
    for Test in Fixture.Tests do
    begin
      if IsListed(Test) then
        Exit(true);
    end;
  end;

  function HasFilteredChildTests(Fixture : ITestFixture) : boolean;
  var
    Child : ITestFixture;
  begin
    Result := false;
    if Fixture.Children = nil then
      Exit;
    for Child in Fixture.Children do
    begin
      if HasFilteredTests(Child) then
        Exit(true);
      if HasFilteredChildTests(Child) then
        Exit(true);
    end;
  end;

var
  Fixture : ITestFixture;
  Test : ITest;
  TestNode : TTreeNode;
  FixtureNode : TTreeNode;
  HasTests : boolean;
  HasChildTests : boolean;
begin
  for Fixture in FixtureList do
  begin
    HasTests := HasFilteredTests(Fixture);
    HasChildTests := HasFilteredChildTests(Fixture);
    if (not HasTests) and (not HasChildTests) then
      continue;
    FixtureNode := tvwTests.Items.AddChild(ParentNode, Fixture.FullName);
    FTestNodes.TryAdd(Fixture.FullName, FixtureNode);
    FixtureNode.StateIndex := cTestNodeStateUnChecked;
    FixtureNode.ImageIndex := -1;
    FixtureNode.SelectedIndex := -1;
    inc(FFixtureCount);
    TTestNode(FixtureNode).FIsFixtureNode := true;

    if HasChildTests then
      BuildTestTreeNode(Fixture.Children, FixtureNode);

    for Test in Fixture.Tests do
    begin
      if not IsListed(Test) then
        continue;
      //The full name is what selects a test to run, so a second test with the same name cannot be listed.
      if FTestNodes.ContainsKey(Test.FullName) then
      begin
        Inc(FDuplicateCount);
        if FFirstDuplicate = '' then
          FFirstDuplicate := Test.FullName;
        continue;
      end;
      TestNode := tvwTests.Items.AddChild(FixtureNode, Test.FullName);
      FTestNodes.Add(Test.FullName, TestNode);
      TestNode.StateIndex := cTestNodeStateUnchecked;
      TestNode.ImageIndex := -1;
      TestNode.SelectedIndex := -1;
      if FUncheckedTests.IndexOf(Test.FullName) < 0 then
        TTestNode(TestNode).InvertState;
    end;
  end;
end;

procedure TGUIVCLTestRunner.edtFilterRightButtonClick(Sender : TObject);
begin
  //Rebuilding the tree mid-run would free the nodes the running tests report to.
  if FRunning then
    Exit;
  edtFilter.Clear;
  TryLoadTests;
end;

procedure TGUIVCLTestRunner.ClearResults;
var
  i : TTestResultType;
  Node : TTreeNode;
begin
  for i := Low(TTestResultType) to High(TTestResultType) do
    FRootNodes[i] := nil;
  FDisplayErrorRoot := nil;

  tvwResults.Items.Clear;
  FWarningCount := 0;
  //Back to 'not run', so a test this run skips does not keep the last run's icon.
  for Node in tvwTests.Items do
  begin
    Node.ImageIndex := -1;
    Node.SelectedIndex := -1;
  end;
  pgeResults.ActivePageIndex := 0;
end;

procedure TGUIVCLTestRunner.edtFilterKeyPress(Sender : TObject; var Key : Char);
begin
  if Key = #13 then
  begin
    if not FRunning then
      TryLoadTests;
    Key := #0;
  end;
end;

procedure TGUIVCLTestRunner.FormKeyDown(Sender : TObject; var Key : Word; Shift : TShiftState);
begin
  if (Key = VK_F9) and (Shift = []) then
  begin
    if actRun.Enabled then
      actRun.Execute;
  end
  else if (Key = VK_ESCAPE) and (Shift = []) and FRunning then
  begin
    StopRun;
    Key := 0;
  end;
end;

procedure TGUIVCLTestRunner.FormShow(Sender : TObject);
begin
  pnlResults.Width := (ClientWidth - splMain.Width) div 2;
  //Load once, after the window has appeared.
  if not FLoadPosted then
  begin
    FLoadPosted := True;
    PostMessage(Handle, WM_LOAD_TESTS, 0, 0);
  end;
end;

procedure TGUIVCLTestRunner.UpdateGUIForProgress(const CurrTestCount : integer; const CurrTestName : string);
begin
  //A fixture teardown failure is begun as a test of its own, beyond the runner's count; the position
  //is also the count of tests begun, so it must not be clamped.
  if CurrTestCount > pgResults.Max then
    pgResults.Max := CurrTestCount;
  pgResults.Position := CurrTestCount;
  if FCloseRequested then
    txtStatus.Caption := SGUIStatusClosing
  else if FStopRequested then
    txtStatus.Caption := SGUIStatusStopping
  else
  begin
    txtStatus.Caption := Format(SGUIStatusRunning, [pgResults.Position, pgResults.Max]);
    if CurrTestName <> '' then
      txtStatus.Caption := txtStatus.Caption + ' - ' + CurrTestName;
  end;
end;

procedure TGUIVCLTestRunner.UpdateGUIForRun(const TestCount : integer);
begin
  txtStatus.Visible := True;
  pnlSummary.Visible := False;
  pgResults.Max := TestCount;
  UpdateGUIForProgress(0, '');
end;

procedure TGUIVCLTestRunner.Invert;
begin
  IterateTestNodes(
    procedure(const Node : TTreeNode; var Stop : boolean)
    begin
      if not TTestNode(Node).IsFixtureNode then
        TTestNode(Node).InvertState;
    end);
end;

function TGUIVCLTestRunner.IterateTestNodes(const Proc : TTreeViewIterateProc) : boolean;
var
  Node : TTreeNode;
begin
  System.Assert(Assigned(Proc));

  Result := False;
  for Node in FTestNodes.Values do
  begin
    Proc(Node, Result);
    if Result then
      break;
  end;
end;

procedure TGUIVCLTestRunner.SelectAll;
var
  Node : TTreeNode;
begin
  //Every node: FTestNodes lacks a fixture whose full name another fixture already has.
  for Node in tvwTests.Items do
    Node.StateIndex := cTestNodeStateChecked;
end;

procedure TGUIVCLTestRunner.tvwTestsMouseDown(Sender : TObject; Button : TMouseButton; Shift : TShiftState; X, Y : Integer);
var
  HitTestRes : THitTests;
  HitNode : TTreeNode;
begin
  //The checked tests are being run; they cannot change meanwhile.
  if FRunning then
    Exit;
  //Right-click selection and the popup menu are the tree's own (RightClickSelect, PopupMenu). A double-click's
  //first press has already toggled the box; its second press must not toggle it back.
  if (Button <> mbLeft) or (ssDouble in Shift) then
    Exit;
  HitTestRes := tvwTests.GetHitTestInfoAt(X, Y);
  if htOnStateIcon in HitTestRes then
  begin
    HitNode := tvwTests.GetNodeAt(X, Y);
    if HitNode <> nil then
    begin
      TTestNode(HitNode).InvertState;
      UpdateFormActions;
    end;
  end;
end;

procedure TGUIVCLTestRunner.tvwTestsChange(Sender : TObject; Node : TTreeNode);
begin
  self.UpdateFormActions;
end;

procedure TGUIVCLTestRunner.tvwTestsCreateNodeClass(Sender : TCustomTreeView; var NodeClass : TTreeNodeClass);
begin
  NodeClass := TTestNode;
end;

procedure TGUIVCLTestRunner.tvwTestsCustomDrawItem(Sender : TCustomTreeView;
  Node : TTreeNode; State : TCustomDrawState; var DefaultDraw : Boolean);
begin
  if TTestNode(Node).IsFixtureNode then
  begin
    Sender.Canvas.Font.Style := Sender.Canvas.Font.Style + [fsBold];
    //A selected node keeps the highlight text colour.
    if not (cdsSelected in State) then
      Sender.Canvas.Font.Color := clWindowText;
  end;
end;

procedure TGUIVCLTestRunner.tvwTestsKeyPress(Sender : TObject; var Key : Char);
begin
  if Key = ' ' then
  begin
    if (not FRunning) and (tvwTests.Selected <> nil) then
    begin
      TTestNode(tvwTests.Selected).InvertState;
      UpdateFormActions;
    end;
    Key := #0;
  end;
end;

procedure TGUIVCLTestRunner.tvwResultsChange(Sender : TObject; Node : TTreeNode);
begin
  UpdateFormActions;
end;

procedure TGUIVCLTestRunner.tvwResultsCreateNodeClass(Sender : TCustomTreeView; var NodeClass : TTreeNodeClass);
begin
  NodeClass := TResultNode;
end;

procedure TGUIVCLTestRunner.UnselectAll;
var
  Node : TTreeNode;
begin
  //Every node: FTestNodes lacks a fixture whose full name another fixture already has.
  for Node in tvwTests.Items do
    Node.StateIndex := cTestNodeStateUnchecked;
end;

function TGUIVCLTestRunner.AnyTestChecked : boolean;
begin
  Result := IterateTestNodes(
    procedure(const Node : TTreeNode; var Stop : boolean)
    begin
      Stop := (not TTestNode(Node).IsFixtureNode) and (Node.StateIndex = cTestNodeStateChecked);
    end);
end;

procedure TGUIVCLTestRunner.ShowNotice(const Text : string);
begin
  FNotice := Text;
  UpdateFormActions;
end;

procedure TGUIVCLTestRunner.UpdateFormActions;
var
  HasTests : boolean;
  StatusText : string;
begin
  //A tree's selection can change as it is destroyed, after FormDestroy has freed FTestNodes.
  if csDestroying in ComponentState then
    Exit;
  //Re-filtering rebuilds the test tree, which a running suite reports into.
  if FRunning and edtFilter.Focused and tvwTests.CanFocus then
    tvwTests.SetFocus;
  edtFilter.Enabled := not FRunning;

  HasTests := (not FRunning) and ((tvwTests.Items.Count - FFixtureCount) > 0);
  //A run with nothing checked would run nothing, silently.
  actRun.Enabled := HasTests and AnyTestChecked;

  actRunSelected.Enabled := (not FRunning) and (tvwTests.Selected <> nil)
    and (not TTestNode(tvwTests.Selected).IsFixtureNode);

  actTestsSelectAll.Enabled := HasTests;
  actTestsUnselectAll.Enabled := HasTests;
  actTestsInvert.Enabled := HasTests;

  StatusText := FLoadStatus;
  if HasTests and (not actRun.Enabled) then
    StatusText := StatusText + cStatusSeparator + SGUINoTestsChecked;
  if FNotice <> '' then
    StatusText := StatusText + cStatusSeparator + FNotice;
  stsMain.Panels[0].Text := StatusText;

  actResultsExpandAll.Enabled := tvwResults.Items.Count > 0;
  actResultsCollapseAll.Enabled := actResultsExpandAll.Enabled;

  actFindInStructured.Enabled := actRunSelected.Enabled and
    actResultsExpandAll.Enabled;

  actFindInText.Enabled := actFindInStructured.Enabled;

  actCompare.Enabled := GetComparableResultsNode <> nil;

  actCopyActual.Enabled := actCompare.Enabled;
  actCopyExpected.Enabled := actCompare.Enabled;

end;

procedure TGUIVCLTestRunner.UpdateGUIForComplete(const RunResults : IRunResults);
begin
  txtPassed.Caption := IntToStr(RunResults.PassCount);
  txtIgnored.Caption := IntToStr(RunResults.IgnoredCount);
  //No-assertion failures are counted as warnings, not as failures.
  txtFailed.Caption := IntToStr(Max(0, RunResults.FailureCount - FWarningCount));
  txtWarnings.Caption := IntToStr(FWarningCount);
  txtErrored.Caption := IntToStr(RunResults.ErrorCount);
  txtMemLeak.Caption := IntToStr(RunResults.MemoryLeakCount);

  txtStatus.Visible := False;
  pnlSummary.Visible := True;
  //A stopped run's summary would otherwise read as a finished run's. RunExecute shows it in the status bar.
  if FStopRequested then
    FNotice := SGUIStatusStopped;
end;

procedure TGUIVCLTestRunner.UpdateRootNodeCaption(const nodeType : TTestResultType);
var
  node : TTreeNode;
begin
  node := FRootNodes[nodeType];

  if node = nil then
    exit;
  node.Text := Format(cRootNodeStrings[nodeType], [Node.Count]);
end;

procedure TGUIVCLTestRunner.WMLoadTests(var message : TMessage);
begin
  TryLoadTests;
end;

class function PathUtils.Compare(const ExpFile, ActFile : string) : boolean;
var
  BCPath : string;
  CmdLine : string;
  ErrorMsg : string;
begin
  Result := False;
  BCPath := FindBeyondCompare;
  if BCPath <> '' then
  begin
    CmdLine := Format('"%s" "%s" "%s" /lefttitle="%s" /righttitle="%s"', [BCPath, ExpFile, ActFile, SGUICompareExpected, SGUICompareActual]);
    Result := Launch(CmdLine, ErrorMsg);
    if not Result then
      MessageDlg(Format(SGUIBeyondCompareNotStarted, [BCPath, ErrorMsg]), mtError, [mbOK], 0);
  end
  else
    MessageDlg(SGUIBeyondCompareNotFound, mtError, [mbOK], 0);
end;

class function PathUtils.Launch(const CmdLine : string; out ErrorMsg : string) : boolean;
var
  StartupInfo : TStartupInfo;
  ProcessInfo : TProcessInformation;
  CmdBuf : string;
begin
  ErrorMsg := '';
  //CreateProcess may write to the command line, so it gets a buffer of its own.
  CmdBuf := CmdLine;
  UniqueString(CmdBuf);
  FillChar(StartupInfo, Sizeof(StartupInfo), #0);
  StartupInfo.cb := Sizeof(StartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := SW_SHOWNORMAL;
  Result := CreateProcess(nil, PChar(CmdBuf), nil, nil, False, CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil, nil, StartupInfo, ProcessInfo);
  if Result then
  begin
    //Not waited for: the comparison runs alongside the runner, whose UI stays live.
    CloseHandle(ProcessInfo.hProcess);
    CloseHandle(ProcessInfo.hThread);
  end
  else
    ErrorMsg := SysErrorMessage(GetLastError);
end;

class function PathUtils.FindBeyondCompare : string;
const
  BCPathList        : array[0..2] of string =
    (
    'Beyond Compare 5\BComp.exe',
    'Beyond Compare 4\BComp.exe',
    'Beyond Compare 3\BComp.exe'
    );
var
  BCPath : string;
  PFPath : string;
begin
  Result := FindBeyondCompareInRegistry;
  if Result <> '' then
    Exit;

  for PFPath in PathUtils.GetProgramFiles do
    for BCPath in BCPathList do
      if TFile.Exists(PFPath + BCPath) then
        Exit(PFPath + BCPath);
end;

class function PathUtils.FindBeyondCompareInRegistry : string;
const
  cBCKey = 'Software\Scooter Software\Beyond Compare';
  cRoots : array[0..1] of HKEY = (HKEY_CURRENT_USER, HKEY_LOCAL_MACHINE);
var
  Reg : TRegistry;
  Root : HKEY;
  ExePath : string;
begin
  Result := '';
  Reg := TRegistry.Create(KEY_READ);
  try
    for Root in cRoots do
    begin
      Reg.RootKey := Root;
      if Reg.OpenKeyReadOnly(cBCKey) then
      try
        //ExePath names BCompare.exe; BComp.exe, which takes the same arguments, sits beside it.
        if Reg.ValueExists('ExePath') and (Reg.GetDataType('ExePath') in [rdString, rdExpandString]) then
        begin
          ExePath := Reg.ReadString('ExePath');
          if TFile.Exists(ExtractFilePath(ExePath) + 'BComp.exe') then
            Exit(ExtractFilePath(ExePath) + 'BComp.exe');
          if TFile.Exists(ExePath) then
            Exit(ExePath);
        end;
      finally
        Reg.CloseKey;
      end;
    end;
  finally
    Reg.Free;
  end;
end;

class function PathUtils.GetProgramFiles : TStringArray;
const
  cVars : array[0..2] of string = ('ProgramW6432', 'ProgramFiles', 'ProgramFiles(x86)');
var
  VarName : string;
  Dir : string;
begin
  //Both Program Files folders, whichever bitness this process is: Beyond Compare may be 32- or 64-bit.
  Result := nil;
  for VarName in cVars do
  begin
    Dir := GetEnvironmentVariable(VarName);
    if Dir = '' then
      Continue;
    Dir := IncludeTrailingPathDelimiter(Dir);
    if not MatchText(Dir, Result) then
      Result := Result + [Dir];
  end;
end;

class function PathUtils.MakeTempFile(const Contents : string; const FileExtNoDot : string) : string;
var
  FileName : string;
begin
  FileName := TPath.GetTempFileName;
  Result := FileName;
  //If the rename fails, compare the file without its extension rather than lose it.
  if (FileExtNoDot <> '') and RenameFile(FileName, ChangeFileExt(FileName, '.' + FileExtNoDot)) then
    Result := ChangeFileExt(FileName, '.' + FileExtNoDot);

  try
    TFile.WriteAllText(Result, Contents);
  except
    //The caller never learns the name, so it cannot delete the file.
    DeleteFile(Result);
    raise;
  end;
end;

// TTreeViewHelper
//================
function TTreeViewHelper.IterateAll(const Proc : TGUIVCLTestRunner.TTreeViewIterateProc) : boolean;
var
  Node : TTreeNode;
begin
  System.Assert(Assigned(Proc));

  Result := False;
  for Node in Self.Items do
  begin
    Proc(Node, Result);
    if Result then
      break;
  end;
end;

procedure TTreeViewHelper.DiscardNodesOnRecreate;
begin
  //CreateWndRestores is protected; a helper may set it.
  Self.CreateWndRestores := False;
end;

// TTreeNodeHelper
//================
function TTreeNodeHelper.IterateAllChilds(const Proc : TGUIVCLTestRunner.TTreeViewIterateProc) : boolean;
var
  Child : TTreeNode;
begin
  System.Assert(Assigned(Proc));

  Result := False;
  Child := self.getFirstChild;
  while Child <> nil do
  begin
    Proc(Child, Result);
    if Result then
      break;
    Result := Child.IterateAllChilds(Proc);
    if Result then
      break;
    Child := self.GetNextChild(Child);
  end;
end;

function TTreeNodeHelper.IterateChilds(const Proc : TGUIVCLTestRunner.TTreeViewIterateProc) : boolean;
var
  Child : TTreeNode;
begin
  System.Assert(Assigned(Proc));

  Result := False;
  Child := self.getFirstChild;
  while Child <> nil do
  begin
    Proc(Child, Result);
    if Result then
      break;
    Child := self.GetNextChild(Child);
  end;
end;

function TTreeNodeHelper.IterateParents(const Proc : TGUIVCLTestRunner.TTreeViewIterateProc) : boolean;
var
  Parent : TTreeNode;
begin
  System.Assert(Assigned(Proc));
  Result := False;
  Parent := self.Parent;
  while Parent <> nil do
  begin
    Proc(Parent, Result);
    if Result then
      break;
    Parent := Parent.Parent;
  end;
end;

procedure TResultNode.AfterConstruction;
begin
  inherited;
  IsComparable := False;
end;

// TTestNode
//==========
procedure TTestNode.InvertState;
var
  Checked : boolean;
  NewStateIndex : integer;
begin
  Checked := not (StateIndex = cTestNodeStateChecked);
  if Checked then
    NewStateIndex := cTestNodeStateChecked
  else
    NewStateIndex := cTestNodeStateUnchecked;

  StateIndex := NewStateIndex;

  self.IterateAllChilds(
    procedure(const Node : TTreeNode; var Stop : boolean)
    begin
      Node.StateIndex := NewStateIndex;
    end);

  if Checked then
    self.IterateParents(
      procedure(const Node : TTreeNode; var Stop : boolean)
      begin
        if Node.StateIndex = cTestNodeStateChecked then
          Stop := true
        else
          Node.StateIndex := cTestNodeStateChecked;
      end)
  else
    self.IterateParents(
      procedure(const Node : TTreeNode; var Stop : boolean)
      begin
        if Node.IterateChilds(
          procedure(const Node : TTreeNode; var Stop : boolean)
          begin
            if Node.StateIndex = cTestNodeStateChecked then
              Stop := true;
          end) then
          Stop := true
        else
          Node.StateIndex := cTestNodeStateUnchecked
      end);
end;

class function TTestNode.ToWeight(const ImageIndex : integer) : integer;
begin
  case ImageIndex of
    -1 : Result := -1;                  // not run
    0 : Result := 0;                    // ignored
    1 : Result := 1;                    // pass
    3 : Result := 2;                    // warning
  else
    Result := 3;                        // Error
  end;
end;

class function TTestNode.ToImageIndex(const Weight : integer) : integer;
begin
  case Weight of
    -1 : Result := -1;                  // not run
    0 : Result := 0;                    // ignored
    1 : Result := 1;                    // pass
    2 : Result := 3;                    // warning
  else
    Result := 2;                        // Error
  end;
end;

end.

