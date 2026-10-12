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

unit DUnitX.Expert.Forms.NewProjectWizard;

interface

{$I DUnitX.inc}

uses
  WinAPI.Windows,
  WinAPI.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  VCL.Graphics,
  VCL.Controls,
  VCL.Forms,
  VCL.Dialogs,
  VCL.StdCtrls,
  Vcl.ExtCtrls,
  DUnitX.Expert.CodeGen.NewTestProject;

type
  /// <summary>
  ///   Options dialog of the "DUnitX Project" wizard: project-group handling, leak reporting and the optional first
  ///   test unit. Read the choices through the read-only properties after a modal result of mrOk.
  /// </summary>
  TfrmDunitXNewProject = class(TForm)
    /// <summary>Group box holding the test unit options.</summary>
    gbTestUnitOpt : TGroupBox;
    /// <summary>Accepts the options (mrOk), subject to the class-name check in FormCloseQuery.</summary>
    btnOK : TButton;
    /// <summary>Abandons the wizard.</summary>
    btnCancel : TButton;
    /// <summary>Generate [Setup] and [TearDown] methods in the test unit.</summary>
    chkCreateSetupTearDown : TCheckBox;
    /// <summary>Generate the sample test methods in the test unit.</summary>
    chkCreateSampleMethods : TCheckBox;
    /// <summary>Create a first test unit; enables or disables the test unit options.</summary>
    chkCreateTestUnit : TCheckBox;
    /// <summary>Add the project to the open project group instead of closing it first.</summary>
    chkAddToProjectGroup : TCheckBox;
    /// <summary>Fixture class name; blank means <c>SDefaultClassName</c>, shown as the text hint.</summary>
    edtClassName : TEdit;
    /// <summary>Caption of the fixture class name box.</summary>
    lblClassName : TLabel;
    /// <summary>Leak-reporting choice; item order matches <see cref="TReportLeakOptions" />.</summary>
    rgReportLeakOptions : TRadioGroup;
    /// <summary>
    ///   Enables the test unit options only while "create test unit" is ticked.
    /// </summary>
    /// <param name="Sender">
    ///   The check box that was clicked.
    /// </param>
    procedure chkCreateTestUnitClick(Sender : TObject);
    /// <summary>
    ///   Shows the default fixture class name as the class name box's text hint.
    /// </summary>
    /// <param name="Sender">
    ///   The form.
    /// </param>
    procedure FormCreate(Sender : TObject);
    /// <summary>
    ///   Refuses OK, with an error message, while a test unit is wanted and the class name would generate a unit that
    ///   does not compile (see <c>IsValidFixtureClassName</c>).
    /// </summary>
    /// <param name="Sender">
    ///   The form.
    /// </param>
    /// <param name="CanClose">
    ///   Set to False to keep the dialog open.
    /// </param>
    procedure FormCloseQuery(Sender : TObject; var CanClose : Boolean);
  private
    { Private declarations }
    /// <summary>
    ///   Read accessor for <see cref="AddToProjectGroup" />.
    /// </summary>
    /// <returns>
    ///   True when "add to project group" is ticked.
    /// </returns>
    function GetAddToProjectGroup : boolean;
    /// <summary>
    ///   Read accessor for <see cref="CreateSampleMethods" />.
    /// </summary>
    /// <returns>
    ///   True when "create sample methods" is ticked.
    /// </returns>
    function GetCreateSampleMethods : boolean;
    /// <summary>
    ///   Read accessor for <see cref="CreateSetupTearDownMethods" />.
    /// </summary>
    /// <returns>
    ///   True when "create Setup/TearDown methods" is ticked.
    /// </returns>
    function GetCreateSetupTearDownMethods : boolean;
    /// <summary>
    ///   Read accessor for <see cref="CreateTestUnit" />.
    /// </summary>
    /// <returns>
    ///   True when "create test unit" is ticked.
    /// </returns>
    function GetCreateTestUnit : boolean;
    /// <summary>
    ///   Read accessor for <see cref="TestFixtureClassName" />.
    /// </summary>
    /// <returns>
    ///   The trimmed class name, or <c>SDefaultClassName</c> when the box is blank.
    /// </returns>
    function GetTestFixtureClassName : string;
    /// <summary>
    ///   Read accessor for <see cref="ReportLeakOption" />.
    /// </summary>
    /// <returns>
    ///   The selected option; rloFastMM5 when the radio group's index is out of range (e.g. nothing selected).
    /// </returns>
    function GetReportLeakOption : TReportLeakOptions;
  public
    { Public declarations }
    /// <summary>Fixture class name for the test unit: trimmed text, or <c>SDefaultClassName</c> when blank.</summary>
    property TestFixtureClassName : string read GetTestFixtureClassName;
    /// <summary>True to generate [Setup] and [TearDown] methods in the test unit.</summary>
    property CreateSetupTearDownMethods : boolean read GetCreateSetupTearDownMethods;
    /// <summary>True to generate the sample test methods in the test unit.</summary>
    property CreateSampleMethods : boolean read GetCreateSampleMethods;
    /// <summary>True to create a first test unit in the new project.</summary>
    property CreateTestUnit : boolean read GetCreateTestUnit;
    /// <summary>True to add the project to the open project group rather than closing the group first.</summary>
    property AddToProjectGroup : boolean read GetAddToProjectGroup;
    /// <summary>Leak reporting to wire into the generated project; rloFastMM5 when nothing valid is selected.</summary>
    property ReportLeakOption : TReportLeakOptions read GetReportLeakOption;
  end;

implementation

uses
  DUnitX.Expert.CodeGen.Templates;

{$R *.dfm}

procedure TfrmDunitXNewProject.chkCreateTestUnitClick(Sender : TObject);
begin
  gbTestUnitOpt.Enabled := chkCreateTestUnit.Checked;
  chkCreateSetupTearDown.Enabled := chkCreateTestUnit.Checked;
  chkCreateSampleMethods.Enabled := chkCreateTestUnit.Checked;
  lblClassName.Enabled := chkCreateTestUnit.Checked;
  edtClassName.Enabled := chkCreateTestUnit.Checked;
end;

procedure TfrmDunitXNewProject.FormCloseQuery(Sender : TObject; var CanClose : Boolean);
begin
  // Refuse OK while the class name would generate a unit that does not compile.
  if (ModalResult = mrOk) and CreateTestUnit and not IsValidFixtureClassName(TestFixtureClassName) then
  begin
    MessageDlg(Format(SInvalidFixtureClassName, [TestFixtureClassName]), mtError, [mbOK], 0);
    edtClassName.SetFocus;
    CanClose := False;
  end;
end;

procedure TfrmDunitXNewProject.FormCreate(Sender : TObject);
begin
  edtClassName.TextHint := SDefaultClassName;
end;

function TfrmDunitXNewProject.GetAddToProjectGroup : boolean;
begin
  result := chkAddToProjectGroup.Checked;
end;

function TfrmDunitXNewProject.GetCreateSampleMethods : boolean;
begin
  result := chkCreateSampleMethods.Checked;
end;

function TfrmDunitXNewProject.GetCreateSetupTearDownMethods : boolean;
begin
  result := chkCreateSetupTearDown.Checked;
end;

function TfrmDunitXNewProject.GetCreateTestUnit : boolean;
begin
  result := chkCreateTestUnit.Checked;
end;

function TfrmDunitXNewProject.GetReportLeakOption : TReportLeakOptions;
begin
  if (rgReportLeakOptions.ItemIndex < Ord(Low(TReportLeakOptions))) or (rgReportLeakOptions.ItemIndex > Ord(High(TReportLeakOptions))) then
    Result := rloFastMM5
  else
    Result := TReportLeakOptions(rgReportLeakOptions.ItemIndex);
end;

function TfrmDunitXNewProject.GetTestFixtureClassName : string;
begin
  if Trim(edtClassName.Text) = '' then
    result := SDefaultClassName
  else
    result := Trim(edtClassName.Text);
end;

end.

