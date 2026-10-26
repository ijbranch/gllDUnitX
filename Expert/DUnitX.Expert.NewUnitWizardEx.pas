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

unit DUnitX.Expert.NewUnitWizardEx;

interface

{$I DUnitX.inc}

uses
  ToolsApi,
  PlatformConst
  ;

type
  /// <summary>
  ///   Registers the File &gt; New &gt; Other "DUnitX Unit" gallery item, which creates a test unit and adds it to the
  ///   active project.
  /// </summary>
  TDUnitXNewUnitWizard = class
  public
    /// <summary>
    ///   Registers the new-test-unit wizard with the IDE's object repository for one personality, Win32 and Win64.
    /// </summary>
    /// <param name="APersonality">
    ///   IDE personality the gallery item appears under (e.g. <c>sDelphiPersonality</c>).
    /// </param>
    /// <remarks>
    ///   The wizard refuses to run without an active project, shows <c>TfrmDunitXNewUnit</c>, creates the unit through
    ///   <c>TNewTestUnit</c>, adds it to the project and advises (without changing the project) when no search path
    ///   names DUnitX. Every exception inside the wizard is shown with <c>Application.ShowException</c> rather than
    ///   allowed to escape into the IDE.
    /// </remarks>
    class procedure RegisterDUnitXNewUnitWizard(const APersonality : string);
  end;

implementation

uses
  DUnitX.Expert.Forms.NewUnitWizard,
  DUnitX.Expert.CodeGen.NewTestUnit,
  Vcl.Controls,
  Vcl.Dialogs,
  Vcl.Forms,
  Winapi.Windows,
  System.SysUtils,
  System.Variants,
  DccStrs,
  ExpertsRepository;

resourcestring
  sNewTestUnitCaption = 'DUnitX Unit';
  sNewTestUnitHint = 'Create New DUnitX Test Unit';
  sNoActiveProject = 'Open or create the project the DUnitX test unit belongs to first: there is no active project to add it to.';
  sNoTestUnit = 'The DUnitX test unit could not be created, so nothing was added to the project.';
  sDUnitXNotOnPath = 'Neither the project''s unit search path nor the IDE library path mentions DUnitX, so the project ' +
    'may not find DUnitX.TestFramework. If it does not compile, add $(DUnitX) (or the DUnitX Source folder) to the ' +
    'project''s unit search path.';

// True when the project's unit search path or the IDE library path names DUnitX. A heuristic: a path can find DUnitX
// without naming it, so a False result only means the project may need the path.
function DUnitXMayBeVisible(const AProject : IOTAProject) : Boolean;
var
  Configs : IOTAProjectOptionsConfigurations;
  Services : IOTAServices;
begin
  if Supports(AProject.ProjectOptions, IOTAProjectOptionsConfigurations, Configs) and
    (Configs.ActiveConfiguration <> nil) and
    (Pos('DUNITX', UpperCase(Configs.ActiveConfiguration.GetValue(sUnitSearchPath, True))) > 0) then
    Exit(True);
  Result := Supports(BorlandIDEServices, IOTAServices, Services) and
    (Pos('DUNITX', UpperCase(VarToStr(Services.GetEnvironmentOptions.Values['LibraryPath']))) > 0);
end;

  { TDUnitXNewUnitWizard }

class procedure TDUnitXNewUnitWizard.RegisterDUnitXNewUnitWizard(const APersonality : string);
begin
  RegisterPackageWizard(TExpertsRepositoryProjectWizardWithProc.Create(APersonality,
      sNewTestUnitHint, sNewTestUnitCaption, 'DunitX.Wizard.NewUnitWizard', // do not localize
      'DUnitX', 'DUnitX Team - https://github.com/VSoftTechnologies/DUnitX', // do not localize
      procedure
      var
        WizardForm : TfrmDunitXNewUnit;
        ModuleServices : IOTAModuleServices;
        Project : IOTAProject;
        TestUnit : IOTAModule;
      begin
        // Nothing may escape into the IDE: report any failure instead.
        try
          // A test unit outside any project would be an orphan: say so instead of creating one.
          Project := GetActiveProject;
          if Project = nil then
          begin
            MessageDlg(sNoActiveProject, mtInformation, [mbOK], 0);
            Exit;
          end;
          WizardForm := TfrmDunitXNewUnit.Create(Application);
          try
            if WizardForm.ShowModal = mrOk then
            begin
              ModuleServices := (BorlandIDEServices as IOTAModuleServices);
              TestUnit := ModuleServices.CreateModule(
                TNewTestUnit.Create(WizardForm.CreateSetupTearDownMethods,
                  WizardForm.CreateSampleMethods,
                  WizardForm.TestFixtureClassName));
              if TestUnit <> nil then
              begin
                Project.AddFile(TestUnit.FileName, true);
                // Advice only: the project is the user's, so its options are left alone.
                if not DUnitXMayBeVisible(Project) then
                  MessageDlg(sDUnitXNotOnPath, mtInformation, [mbOK], 0);
              end
              else
                MessageDlg(sNoTestUnit, mtWarning, [mbOK], 0);
            end;
          finally
            WizardForm.Free;
          end;
        except
          on E : Exception do
            Application.ShowException(E);
        end;
      end,
      // Delphi 13 declares the glyph callback with the HICON returned by
      // LoadIcon: UInt64 on Win64, Cardinal on Win32. NativeUInt is a plain
      // alias for both, so it satisfies the generic on either platform - a
      // fixed UInt64 breaks the Win32 build with E2250.
      function : NativeUInt
      begin
        Result := LoadIcon(HInstance, 'DUnitXNewUnitIcon');
      end,
      TArray<string>.Create(cWin32Platform, cWin64Platform),
      nil));
end;

end.

