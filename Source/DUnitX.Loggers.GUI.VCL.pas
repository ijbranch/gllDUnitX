{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2017 Vincent Parrett                              }
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
  WM_LOAD_TESTS     = WM_USER + 123;

type
  TTestNode = class(TTreeNode)
  private
    FIsFixtureNode : boolean;
  public
    property IsFixtureNode : boolean read FIsFixtureNode;
    procedure InvertState;
    class function ToWeight(const ImageIndex : integer) : integer;
    class function ToImageIndex(const Weight : integer) : integer;
  end;

  TResultNode = class(TTreeNode)
  public
    //The test's full name, not its node: the test tree is rebuilt whenever the filter changes.
    TestFullName : string;
    IsComparable : boolean;
    Expected : string;
    Actual : string;
    Format : TDUnitXComparableFormatClass;

    procedure AfterConstruction; override;
  end;

  TGUIVCLTestRunner = class(TForm, ITestLogger)
    ActionManager : TActionManager;
    ActionImages : TImageList;
    actRunSelected : TAction;
    actRun : TAction;
    pnlFilter : TPanel;
    lblFilter : TLabel;
    StateImages : TImageList;
    ResultImages : TImageList;
    pnlClient : TPanel;
    tbrTests : TActionToolBar;
    actTestsSelectAll : TAction;
    actTestsUnselectAll : TAction;
    splMain : TSplitter;
    pnlTests : TPanel;
    tvwTests : TTreeView;
    pnlResults : TPanel;
    tbrResults : TActionToolBar;
    actCompare : TAction;
    pgeResults : TPageControl;
    tabStructured : TTabSheet;
    tvwResults : TTreeView;
    stsMain : TStatusBar;
    popResults : TPopupActionBar;
    itmComparePop : TMenuItem;
    popTests : TPopupActionBar;
    RunAll1 : TMenuItem;
    RunAll2 : TMenuItem;
    actTestsInvert : TAction;
    pnlTestsTop : TPanel;
    lblTestsHeader : TLabel;
    pnlResultsTop : TPanel;
    lblResultsHeader : TLabel;
    actResultsExpandAll : TAction;
    actResultsCollapseAll : TAction;
    tabText : TTabSheet;
    rchText : TRichEdit;
    pnlText : TPanel;
    actFindInText : TAction;
    itmFindInText : TMenuItem;
    N1 : TMenuItem;
    actFindInStructured : TAction;
    itmFindInStructured : TMenuItem;
    imgTests : TImage;
    imgResults : TImage;
    edtFilter : TButtonedEdit;
    actCopyActual : TAction;
    actCopyExpected : TAction;
    N2 : TMenuItem;
    itmCopyExpected : TMenuItem;
    itmCopyActual : TMenuItem;
    pgResults : TProgressBar;
    txtStatus : TLabel;
    pnlSummary : TPanel;
    lblIgnored : TLabel;
    lblPassed : TLabel;
    txtPassed : TLabel;
    txtIgnored : TLabel;
    lblFailed : TLabel;
    txtFailed : TLabel;
    lblErrored : TLabel;
    txtErrored : TLabel;
    lblMemLeak : TLabel;
    txtMemLeak : TLabel;
    lblWarnings : TLabel;
    txtWarnings : TLabel;
    procedure actTestsUnselectAllExecute(Sender : TObject);
    procedure actCompareExecute(Sender : TObject);
    procedure actCopyActualExecute(Sender : TObject);
    procedure actCopyExpectedExecute(Sender : TObject);
    procedure actResultsCollapseAllExecute(Sender : TObject);
    procedure actResultsExpandAllExecute(Sender : TObject);
    procedure FormDestroy(Sender : TObject);
    procedure actRunExecute(Sender : TObject);
    procedure actRunSelectedExecute(Sender : TObject);
    procedure actFindInTextExecute(Sender : TObject);
    procedure actFindInStructuredExecute(Sender : TObject);
    procedure actTestsInvertExecute(Sender : TObject);
    procedure actTestsSelectAllExecute(Sender : TObject);
    procedure edtFilterRightButtonClick(Sender : TObject);
    procedure edtFilterKeyPress(Sender : TObject; var Key : Char);
    procedure FormCreate(Sender : TObject);
    procedure FormKeyDown(Sender : TObject; var Key : Word; Shift : TShiftState);
    procedure FormShow(Sender : TObject);
    procedure tvwTestsCreateNodeClass(Sender : TCustomTreeView; var NodeClass : TTreeNodeClass);
    procedure tvwTestsKeyPress(Sender : TObject; var Key : Char);
    procedure tvwTestsMouseDown(Sender : TObject; Button : TMouseButton; Shift : TShiftState; X, Y : Integer);
    procedure tvwResultsChange(Sender : TObject; Node : TTreeNode);
    procedure tvwResultsCreateNodeClass(Sender : TCustomTreeView; var NodeClass : TTreeNodeClass);
    procedure FormClose(Sender : TObject; var Action : TCloseAction);
    procedure FormCloseQuery(Sender : TObject; var CanClose : Boolean);
    procedure tvwTestsCustomDrawItem(Sender : TCustomTreeView; Node : TTreeNode;
      State : TCustomDrawState; var DefaultDraw : Boolean);
    procedure tvwTestsChange(Sender : TObject; Node : TTreeNode);
  private type
  TTreeViewIterateProc = reference to procedure(const Node : TTreeNode; var Stop : boolean);
  private
    FFixtureList : ITestFixtureList;
    FTestBookmarkList : TTestBookmarkList;
    FRootNodes : array[TTestResultType] of TTreeNode;
    FTestNodes : TDictionary<string, TTreeNode>;
    FRunning : boolean;
    FFixtureCount : integer;
    FCommandLineFilter : ITestFilter;
    FRunFixtures : ITestFixtureList;
    FStopRequested : boolean;
    FCloseRequested : boolean;
    FLoadPosted : boolean;
    FWarningCount : integer;
    FDuplicateCount : integer;
    FFirstDuplicate : string;
    FUncheckedTests : TStringList;
    FTempFiles : TStringList;

    procedure LoadTests;
    procedure BuildTestTreeNode(const FixtureList : ITestFixtureList;
      const ParentNode : TTreeNode);
    procedure ClearResults;
    procedure RunExecute(const Filter : ITestFilter; const TestCount : integer);
    procedure StopRun;
    procedure ApplyResultsToTests;
    procedure AddResultDisplayError(const TestName, Msg : string);
    procedure CaptureCheckedState;
    function SettingsFileName : string;
    procedure ReadSettings;
    procedure WriteSettings;
    procedure Invert;
    procedure SelectAll;
    procedure UnselectAll;
    function NeedRunner : ITestRunner;
    function GetNodeByTestFullName(const TestFullName : string) : TTreeNode;
    function IterateTestNodes(const Proc : TTreeViewIterateProc) : boolean;
    procedure SetNodeTestResult(const Node : TTreeNode; const ImageIndex : integer);
    procedure ProcessTestResult(const Test : ITestResult);
    procedure ProcessMessagesForNode(const ResultNode : TResultNode; const Test : ITestResult);
    procedure UpdateFormActions;
    function GetSelectedResultsNode : TResultNode;
    function GetComparableResultsNode : TResultNode;
    function GetRootNode(const nodeType : TTestResultType) : TTreeNode;
    procedure UpdateGUIForComplete(const RunResults : IRunResults);
    procedure UpdateRootNodeCaption(const nodeType : TTestResultType);
    procedure UpdateGUIForRun(const TestCount : integer);
    procedure UpdateGUIForProgress(const CurrTestCount : integer; const CurrTestName : string);
  protected
    procedure OnBeginTest(const threadId : TThreadID; const Test : ITestInfo);
    procedure OnEndSetupFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
    procedure OnEndSetupTest(const threadId : TThreadID; const Test : ITestInfo);
    procedure OnEndTearDownFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
    procedure OnEndTeardownTest(const threadId : TThreadID; const Test : ITestInfo);
    procedure OnEndTest(const threadId : TThreadID; const Test : ITestResult);
    procedure OnEndTestFixture(const threadId : TThreadID; const results : IFixtureResult);
    procedure OnExecuteTest(const threadId : TThreadID; const Test : ITestInfo);
    procedure OnLog(const logType : TLogLevel; const msg : string);
    procedure OnSetupFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
    procedure OnSetupTest(const threadId : TThreadID; const Test : ITestInfo);
    procedure OnStartTestFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
    procedure OnTearDownFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
    procedure OnTeardownTest(const threadId : TThreadID; const Test : ITestInfo);
    procedure OnTestError(const threadId : TThreadID; const Error : ITestError);
    procedure OnTestFailure(const threadId : TThreadID; const Failure : ITestError);
    procedure OnTestSuccess(const threadId : TThreadID; const Test : ITestResult);
    procedure OnTestMemoryLeak(const threadId : TThreadID; const Test : ITestResult);
    procedure OnTestIgnored(const threadId : TThreadID; const Ignored : ITestResult);
    procedure OnTestingEnds(const RunResults : IRunResults);
    procedure OnTestingStarts(const threadId : TThreadID; testCount, testActiveCount : Cardinal);

    procedure WMLoadTests(var message : TMessage); message WM_LOAD_TESTS;
  end;

var
  GUIVCLTestRunner : TGUIVCLTestRunner;

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
    Clipboard.AsText := ResultNode.Actual;
end;

procedure TGUIVCLTestRunner.actCopyExpectedExecute(Sender : TObject);
var
  ResultNode : TResultNode;
begin
  ResultNode := GetComparableResultsNode;
  if ResultNode <> nil then
    Clipboard.AsText := ResultNode.Expected;
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
  FTempFiles.Free;
  FUncheckedTests.Free;
  FTestBookmarkList.Free;
  FTestNodes.Free;
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
end;

procedure TGUIVCLTestRunner.actTestsSelectAllExecute(Sender : TObject);
begin
  SelectAll;
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

  Self.Caption := Format(SApplicationName, [ExtractFileName(ParamStr(0))]);
  Application.Title := Self.Caption;

  txtStatus.Caption := SGUIStatusIdle;
  txtStatus.Visible := True;
  pnlSummary.Visible := False;

  pgeResults.ActivePageIndex := 0;
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
  //Empty
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
begin
  TestName := '';
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
        AddResultDisplayError(TestName, E.Message);
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
    StatusText := StatusText + '    ' + Format(SGUIDuplicateTestNames, [FDuplicateCount, FFirstDuplicate]);
  stsMain.Panels[0].Text := StatusText;

  UpdateFormActions;
end;

procedure TGUIVCLTestRunner.RunExecute(const Filter : ITestFilter; const TestCount : integer);
var
  Runner : ITestRunner;
begin
  FRunning := true;
  FStopRequested := False;
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
  Node := tvwResults.Items.AddChild(GetRootNode(TTestResultType.Error), Format(SGUIResultDisplayError, [TestName, Msg]));
  Node.ImageIndex := cTestResultImageMap[TTestResultType.Error];
  Node.SelectedIndex := Node.ImageIndex;
  UpdateRootNodeCaption(TTestResultType.Error);
end;

procedure TGUIVCLTestRunner.CaptureCheckedState;
begin
  IterateTestNodes(
    procedure(const Node : TTreeNode; var Stop : boolean)
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
    end);
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
  Node.ImageIndex := ImageIndex;
  Node.SelectedIndex := ImageIndex;

  NewWeight := TTestNode.ToWeight(ImageIndex);

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
  LoadTests;
end;

procedure TGUIVCLTestRunner.ClearResults;
var
  i : TTestResultType;
  Node : TTreeNode;
begin
  for i := Low(TTestResultType) to High(TTestResultType) do
    FRootNodes[i] := nil;

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
      LoadTests;
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
begin
  IterateTestNodes(
    procedure(const Node : TTreeNode; var Stop : boolean)
    begin
      Node.StateIndex := cTestNodeStateChecked;
    end);
end;

procedure TGUIVCLTestRunner.tvwTestsMouseDown(Sender : TObject; Button : TMouseButton; Shift : TShiftState; X, Y : Integer);
var
  HitTestRes : THitTests;
  HitNode : TTreeNode;
begin
  //The checked tests are being run; they cannot change meanwhile.
  if FRunning then
    Exit;
  //Right-click selection and the popup menu are the tree's own (RightClickSelect, PopupMenu).
  HitTestRes := tvwTests.GetHitTestInfoAt(X, Y);
  if htOnStateIcon in HitTestRes then
  begin
    HitNode := tvwTests.GetNodeAt(X, Y);
    if HitNode <> nil then
      TTestNode(HitNode).InvertState;
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
      TTestNode(tvwTests.Selected).InvertState;
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
begin
  IterateTestNodes(
    procedure(const Node : TTreeNode; var Stop : boolean)
    begin
      Node.StateIndex := cTestNodeStateUnchecked;
    end);
end;

procedure TGUIVCLTestRunner.UpdateFormActions;
begin
  //Re-filtering rebuilds the test tree, which a running suite reports into.
  if FRunning and edtFilter.Focused and tvwTests.CanFocus then
    tvwTests.SetFocus;
  edtFilter.Enabled := not FRunning;

  actRun.Enabled := (not FRunning) and
    ((tvwTests.Items.Count - FFixtureCount) > 0);

  actRunSelected.Enabled := (not FRunning) and (tvwTests.Selected <> nil)
    and (not TTestNode(tvwTests.Selected).IsFixtureNode);

  actTestsSelectAll.Enabled := actRun.Enabled;
  actTestsUnselectAll.Enabled := actRun.Enabled;
  actTestsInvert.Enabled := actRun.Enabled;

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
  LoadTests;
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

  TFile.WriteAllText(Result, Contents);
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

