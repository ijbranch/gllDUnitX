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

unit DUnitX.Tests.Loggers.GUI.VCL;

interface

{$I DUnitX.inc}

uses
  DUnitX.TestFramework,
  DUnitX.Loggers.GUI.VCL;

type
  /// <summary>
  ///   Drives the VCL GUI runner's form directly, without showing it: results are fed through its
  ///   <c>ITestLogger</c> and its event handlers are called as the VCL would call them.
  /// </summary>
  [TestFixture]
  TGUIVCLRunnerTests = class
  private
    /// <summary>The runner's form, created hidden for each test.</summary>
    FForm : TGUIVCLTestRunner;
    /// <summary>The application title before the form set its own; restored after each test.</summary>
    FSavedTitle : string;
  public
    /// <summary>Saves the application title, then creates the form, hidden and unowned.</summary>
    [Setup]
    procedure Setup;
    /// <summary>Frees the form and restores the application title it changed.</summary>
    [TearDown]
    procedure TearDown;
    /// <summary>
    ///   Proves that a test passed with <c>Assert.Pass( 'message' )</c> shows its message under its result
    ///   (upstream #590): the runner used to file every pass straight under its result with no message node, so
    ///   the message was lost.
    /// </summary>
    [Test]
    procedure PassWithMessage_ShowsTheMessage;
    /// <summary>
    ///   Guards the #590 fix against going too far: a plain pass must still add nothing under its result.  It
    ///   passes with or without the fix; it fails only if a message node is added for an empty message.
    /// </summary>
    [Test]
    procedure PassWithoutMessage_AddsNoChild;
    /// <summary>
    ///   Proves that Ctrl+A in the filter box selects its whole text and swallows the key (upstream #589):
    ///   without runtime themes the edit control ignores Ctrl+A, and our test project has no manifest.
    /// </summary>
    [Test]
    procedure FilterCtrlA_SelectsAllText;
    /// <summary>
    ///   Proves that widening the results panel, as a splitter drag does, never widens the window (upstream #588):
    ///   a minimum width on the client-aligned tests panel made the VCL grow the form instead.
    /// </summary>
    [Test]
    procedure WideResultsPanel_DoesNotWidenTheWindow;
    /// <summary>
    ///   Proves that shrinking the window narrows the results pane so the tests pane keeps the splitter's
    ///   300-pixel minimum (upstream #588's <c>FormResize</c>): without it the tests pane is squeezed instead.
    /// </summary>
    [Test]
    procedure ShrinkingTheWindow_NarrowsTheResultsPane;
  end;

implementation

uses
  System.SysUtils,
  System.Generics.Collections,
  Vcl.Forms,
  System.TimeSpan,
  Vcl.ComCtrls,
  DUnitX.WeakReference,
  DUnitX.TestResult;

type
  //The least ITestInfo the form reads: it shows a result under its test's full name.  A test result keeps a weak
  //reference to its test, so the class must be a TWeakReferencedObject.
  TFakeTestInfo = class(TWeakReferencedObject, ITestInfo)
  private
    FFullName : string;
  public
    constructor Create(const AFullName : string);
    function GetName : string;
    function GetFullName : string;
    function GetMethodName : string;
    function GetCategories : TList<string>;
    function GetActive : boolean;
    function GetTestFixture : ITestFixtureInfo;
    function GetTestStartTime : TDateTime;
    function GetTestEndTime : TDateTime;
    function GetTestDuration : TTimeSpan;
    function GetEnabled : boolean;
    procedure SetEnabled(const value : boolean);
  end;

const
  cTestName = 'Fake.Fixture.Test';

constructor TFakeTestInfo.Create(const AFullName : string);
begin
  inherited Create;
  FFullName := AFullName;
end;

function TFakeTestInfo.GetActive : boolean;
begin
  Result := True;
end;

function TFakeTestInfo.GetCategories : TList<string>;
begin
  Result := nil;
end;

function TFakeTestInfo.GetEnabled : boolean;
begin
  Result := True;
end;

function TFakeTestInfo.GetFullName : string;
begin
  Result := FFullName;
end;

function TFakeTestInfo.GetMethodName : string;
begin
  Result := FFullName;
end;

function TFakeTestInfo.GetName : string;
begin
  Result := FFullName;
end;

function TFakeTestInfo.GetTestDuration : TTimeSpan;
begin
  Result := TTimeSpan.Zero;
end;

function TFakeTestInfo.GetTestEndTime : TDateTime;
begin
  Result := 0;
end;

function TFakeTestInfo.GetTestFixture : ITestFixtureInfo;
begin
  Result := nil;
end;

function TFakeTestInfo.GetTestStartTime : TDateTime;
begin
  Result := 0;
end;

procedure TFakeTestInfo.SetEnabled(const value : boolean);
begin
  //Not used by the form.
end;

//The result node the form made for the test named ATestName, or nil.
function FindResultNode(const ATree : TTreeView; const ATestName : string) : TTreeNode;
var
  i : integer;
begin
  Result := nil;
  for i := 0 to ATree.Items.Count - 1 do
    if ATree.Items[i].Text = ATestName then
      Exit(ATree.Items[i]);
end;

//Feeds a passed result with AMessage to the form as the runner would at the end of a test.
procedure FeedPass(const AForm : TGUIVCLTestRunner; const AMessage : string);
var
  testInfo : ITestInfo;
  testResult : ITestResult;
begin
  //The result holds its test only weakly; this reference keeps the test alive while the form reads it.
  testInfo := TFakeTestInfo.Create(cTestName);
  testResult := TDUnitXTestResult.Create(testInfo, TTestResultType.Pass, AMessage);
  (AForm as ITestLogger).OnEndTest(0, testResult);
end;

{ TGUIVCLRunnerTests }

procedure TGUIVCLRunnerTests.Setup;
begin
  FSavedTitle := Application.Title;
  FForm := TGUIVCLTestRunner.Create(nil);
end;

procedure TGUIVCLRunnerTests.TearDown;
begin
  FreeAndNil(FForm);
  Application.Title := FSavedTitle;
end;

procedure TGUIVCLRunnerTests.PassWithMessage_ShowsTheMessage;
var
  resultNode : TTreeNode;
begin
  FeedPass(FForm, 'Passed on purpose');
  resultNode := FindResultNode(FForm.tvwResults, cTestName);
  Assert.IsNotNull(resultNode, 'no result node for the test');
  Assert.AreEqual(1, resultNode.Count, 'message nodes under the result');
  Assert.AreEqual('Passed on purpose', resultNode.Item[0].Text, False);
end;

procedure TGUIVCLRunnerTests.PassWithoutMessage_AddsNoChild;
var
  resultNode : TTreeNode;
begin
  FeedPass(FForm, '');
  resultNode := FindResultNode(FForm.tvwResults, cTestName);
  Assert.IsNotNull(resultNode, 'no result node for the test');
  Assert.AreEqual(0, resultNode.Count, 'nodes under a plain pass');
end;

procedure TGUIVCLRunnerTests.FilterCtrlA_SelectsAllText;
var
  key : Char;
begin
  FForm.edtFilter.HandleNeeded;
  FForm.edtFilter.Text := 'abc';
  FForm.edtFilter.SelStart := 3;
  key := #1;
  FForm.edtFilterKeyPress(FForm.edtFilter, key);
  Assert.AreEqual(3, FForm.edtFilter.SelLength, 'characters selected');
  Assert.AreEqual(0, Ord(key), 'Ctrl+A was not swallowed');
end;

procedure TGUIVCLRunnerTests.WideResultsPanel_DoesNotWidenTheWindow;
var
  formWidth : integer;
begin
  FForm.HandleNeeded;
  formWidth := FForm.Width;
  //Leave the tests panel 100 pixels, well under its 300-pixel minimum.
  FForm.pnlResults.Width := FForm.pnlClient.ClientWidth - FForm.splMain.Width - 100;
  //The VCL works out a window's minimum width from its children's constraints whenever the window is sized: the
  //results panel's width plus the splitter's plus the tests panel's minimum.  A pixel narrower must still be allowed.
  FForm.Width := formWidth - 1;
  Assert.AreEqual(formWidth - 1, FForm.Width, 'window width after widening the results panel');
end;

procedure TGUIVCLRunnerTests.ShrinkingTheWindow_NarrowsTheResultsPane;
begin
  FForm.HandleNeeded;
  //As wide as the splitter allows: the tests pane exactly at its 300-pixel minimum.
  FForm.pnlResults.Width := FForm.pnlClient.ClientWidth - FForm.splMain.Width - FForm.splMain.MinSize;
  FForm.Width := FForm.Width - 200;
  Assert.IsTrue(FForm.pnlResults.Width <= FForm.pnlClient.ClientWidth - FForm.splMain.Width - FForm.splMain.MinSize,
    Format('results pane %d wide leaves the tests pane under %d in a client %d wide',
    [FForm.pnlResults.Width, FForm.splMain.MinSize, FForm.pnlClient.ClientWidth]));
end;

initialization
  TDUnitX.RegisterTestFixture(TGUIVCLRunnerTests);

end.
