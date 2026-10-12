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

unit DUnitX.Expert.ProjectWizardEx;

interface

{$I DUnitX.inc}

uses
  ToolsApi,
  PlatformConst
  ;

type
  /// <summary>
  ///   Registers the File &gt; New &gt; Other "DUnitX Project" gallery item, which creates a console test project and,
  ///   optionally, its first test unit.
  /// </summary>
  TDUnitXNewProjectWizard = class
  public
    /// <summary>
    ///   Registers the new-test-project wizard with the IDE's object repository for one personality, Win32 and Win64.
    /// </summary>
    /// <param name="APersonality">
    ///   IDE personality the gallery item appears under (e.g. <c>sDelphiPersonality</c>).
    /// </param>
    /// <remarks>
    ///   The wizard shows <c>TfrmDunitXNewProject</c>, closes the open project group unless asked to add to it (and
    ///   abandons if the user cancels that), creates the project through <c>TTestProjectFile</c>, sets its base unit
    ///   search path to <c>$(DUnitX)</c> and warns when the DUnitX environment variable does not name the DUnitX Source
    ///   folder, then optionally adds a test unit through <c>TNewTestUnit</c>. Every exception inside the wizard is
    ///   shown with <c>Application.ShowException</c> rather than allowed to escape into the IDE.
    /// </remarks>
    class procedure RegisterDUnitXProjectWizard(const APersonality : string);
  end;

implementation

uses
  DccStrs,
  Vcl.Controls,
  Vcl.Dialogs,
  Vcl.Forms,
  WinApi.Windows,
  System.SysUtils,
  DUnitX.Expert.Forms.NewProjectWizard,
  DUnitX.Expert.CodeGen.NewTestProject,
  DUnitX.Expert.CodeGen.NewTestUnit,
  ExpertsRepository;

resourcestring
  sNewTestProjectCaption = 'DUnitX Project';
  sNewTestProjectHint = 'Create New DUnitX Test Project';
  sNoNewProject = 'The new DUnitX project could not be located after it was created, so the $(DUnitX) unit search path ' +
    'was not set and no test unit was added. Check the project group and set them by hand.';
  sNoTestUnit = 'The DUnitX test unit could not be created, so the new project has no test unit. Add one with ' +
    'File > New > Other > DUnitX Unit.';
  // 0 - Folder the DUnitX environment variable names, or blank
  sNoDUnitXVariable = 'The new project''s unit search path is $(DUnitX), but the IDE environment variable DUnitX ' +
    '(''%0:s'') does not name a folder containing DUnitX.TestFramework.pas, so the project may not compile.'#13#10#13#10 +
    'Set DUnitX to the DUnitX Source folder in Tools > Options > IDE > Environment Variables, or put that folder ' +
    'on the project''s search path.';
  sNoProjectOptions = 'The project options of the new DUnitX project are not available, so the $(DUnitX) unit search ' +
    'path was not set. Add $(DUnitX) to the project''s unit search path by hand.';

  { TDUnitXNewProjectWizard }

class procedure TDUnitXNewProjectWizard.RegisterDUnitXProjectWizard(const APersonality : string);
begin
  RegisterPackageWizard(TExpertsRepositoryProjectWizardWithProc.Create(APersonality,
      sNewTestProjectHint, sNewTestProjectCaption, 'DunitX.Wizard.NewProjectWizard', // do not localize
      'DUnitX', 'DUnitX Team - https://github.com/VSoftTechnologies/DUnitX', // do not localize
      procedure
      var
        WizardForm : TfrmDunitXNewProject;
        ModuleServices : IOTAModuleServices;
        Project : IOTAProject;
        Configs : IOTAProjectOptionsConfigurations;
        TestUnit : IOTAModule;
        DUnitXFolder : string;
      begin
        // Nothing may escape into the IDE: report any failure instead.
        try
          WizardForm := TfrmDunitXNewProject.Create(Application);
          try
            if WizardForm.ShowModal <> mrOk then
              Exit;
            ModuleServices := (BorlandIDEServices as IOTAModuleServices);
            // CloseAll returns False when the user cancels its save prompt: abandon the wizard rather than
            // adding the new project to the group the user meant to close.
            if not WizardForm.AddToProjectGroup and not ModuleServices.CloseAll then
              Exit;
            // Create Project Source. No fallback to the active project: that may be one the user already had, whose
            // search path would then be overwritten and which would gain the test unit.
            if not Supports(ModuleServices.CreateModule(TTestProjectFile.Create(WizardForm.ReportLeakOption)),
              IOTAProject, Project) then
            begin
              MessageDlg(sNoNewProject, mtWarning, [mbOK], 0);
              Exit;
            end;
            // The project is new, so its base unit search path is empty and is replaced outright.
            if Supports(Project.ProjectOptions, IOTAProjectOptionsConfigurations, Configs) then
            begin
              Configs.BaseConfiguration.SetValue(sUnitSearchPath, '$(DUnitX)');
              // $(DUnitX) resolves only when the DUnitX variable is set (an IDE environment variable override is
              // applied to the IDE's own process environment, as is a Windows one).
              DUnitXFolder := GetEnvironmentVariable('DUnitX');
              if (DUnitXFolder = '') or not FileExists(IncludeTrailingPathDelimiter(DUnitXFolder) + 'DUnitX.TestFramework.pas') then
                MessageDlg(Format(sNoDUnitXVariable, [DUnitXFolder]), mtWarning, [mbOK], 0);
            end
            else
              MessageDlg(sNoProjectOptions, mtWarning, [mbOK], 0);
            // Create Test Unit
            if WizardForm.CreateTestUnit then
            begin
              TestUnit := ModuleServices.CreateModule(
                TNewTestUnit.Create(WizardForm.CreateSetupTearDownMethods,
                  WizardForm.CreateSampleMethods,
                  WizardForm.TestFixtureClassName));
              if TestUnit <> nil then
                Project.AddFile(TestUnit.FileName, true)
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
        Result := LoadIcon(HInstance, 'DUnitXNewProjectIcon');
      end,
      TArray<string>.Create(cWin32Platform, cWin64Platform),
      nil));
end;

end.

