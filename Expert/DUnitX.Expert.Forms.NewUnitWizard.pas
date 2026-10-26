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

unit DUnitX.Expert.Forms.NewUnitWizard;

interface

{$I DUnitX.inc}

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls;

type
  /// <summary>
  ///   Options dialog of the "DUnitX Unit" wizard: fixture class name and which methods to generate. Read the choices
  ///   through the read-only properties after a modal result of mrOk.
  /// </summary>
  TfrmDunitXNewUnit = class(TForm)
    /// <summary>Group box holding the test unit options.</summary>
    GroupBox1 : TGroupBox;
    /// <summary>Accepts the options (mrOk), subject to the class-name check in FormCloseQuery.</summary>
    btnOK : TButton;
    /// <summary>Abandons the wizard.</summary>
    btnCancel : TButton;
    /// <summary>Caption of the fixture class name box.</summary>
    lblClassName : TLabel;
    /// <summary>Fixture class name; blank means <c>SDefaultClassName</c>, shown as the text hint.</summary>
    edtClassName : TEdit;
    /// <summary>Generate [Setup] and [TearDown] methods.</summary>
    chkCreateSetupTearDown : TCheckBox;
    /// <summary>Generate the sample test methods.</summary>
    chkCreateSampleMethods : TCheckBox;
    /// <summary>
    ///   Shows the default fixture class name as the class name box's text hint.
    /// </summary>
    /// <param name="Sender">
    ///   The form.
    /// </param>
    procedure FormCreate(Sender : TObject);
    /// <summary>
    ///   Refuses OK, with an error message, while the class name would generate a unit that does not compile (see
    ///   <c>IsValidFixtureClassName</c>).
    /// </summary>
    /// <param name="Sender">
    ///   The form.
    /// </param>
    /// <param name="CanClose">
    ///   Set to False to keep the dialog open.
    /// </param>
    procedure FormCloseQuery(Sender : TObject; var CanClose : Boolean);
  private
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
    ///   Read accessor for <see cref="TestFixtureClassName" />.
    /// </summary>
    /// <returns>
    ///   The trimmed class name, or <c>SDefaultClassName</c> when the box is blank.
    /// </returns>
    function GetTestFixtureClassName : string;
    { Private declarations }
  public
    { Public declarations }
    /// <summary>Fixture class name for the test unit: trimmed text, or <c>SDefaultClassName</c> when blank.</summary>
    property TestFixtureClassName : string read GetTestFixtureClassName;
    /// <summary>True to generate [Setup] and [TearDown] methods.</summary>
    property CreateSetupTearDownMethods : boolean read GetCreateSetupTearDownMethods;
    /// <summary>True to generate the sample test methods.</summary>
    property CreateSampleMethods : boolean read GetCreateSampleMethods;

  end;

implementation

uses
  DUnitX.Expert.CodeGen.Templates;

{$R *.dfm}

{ TfrmDunitXNewUnit }

procedure TfrmDunitXNewUnit.FormCloseQuery(Sender : TObject; var CanClose : Boolean);
begin
  // Refuse OK while the class name would generate a unit that does not compile.
  if (ModalResult = mrOk) and not IsValidFixtureClassName(TestFixtureClassName) then
  begin
    MessageDlg(Format(SInvalidFixtureClassName, [TestFixtureClassName]), mtError, [mbOK], 0);
    edtClassName.SetFocus;
    CanClose := False;
  end;
end;

procedure TfrmDunitXNewUnit.FormCreate(Sender : TObject);
begin
  edtClassName.TextHint := SDefaultClassName;
end;

function TfrmDunitXNewUnit.GetCreateSampleMethods : boolean;
begin
  result := chkCreateSampleMethods.Checked;
end;

function TfrmDunitXNewUnit.GetCreateSetupTearDownMethods : boolean;
begin
  result := chkCreateSetupTearDown.Checked;
end;

function TfrmDunitXNewUnit.GetTestFixtureClassName : string;
begin
  if Trim(edtClassName.Text) = '' then
    result := SDefaultClassName
  else
    result := Trim(edtClassName.Text);
end;

end.

