{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2015 Vincent Parrett & Contributors               }
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
  TDUnitXNewProjectWizard = class
  public
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
            // Create Project Source
            if not Supports(ModuleServices.CreateModule(TTestProjectFile.Create(WizardForm.ReportLeakOption)),
              IOTAProject, Project) then
              Project := GetActiveProject;
            if Project = nil then
            begin
              MessageDlg(sNoNewProject, mtWarning, [mbOK], 0);
              Exit;
            end;
            if Supports(Project.ProjectOptions, IOTAProjectOptionsConfigurations, Configs) then
              Configs.BaseConfiguration.SetValue(sUnitSearchPath, '$(DUnitX)')
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
                Project.AddFile(TestUnit.FileName, true);
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

