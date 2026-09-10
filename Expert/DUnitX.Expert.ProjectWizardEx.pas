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
  VCL.Graphics,
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
        Config : IOTABuildConfiguration;
        TestUnit : IOTAModule;
      begin
        WizardForm := TfrmDunitXNewProject.Create(Application);
        try
          if WizardForm.ShowModal = mrOk then
          begin
            if not WizardForm.AddToProjectGroup then
            begin
              (BorlandIDEServices as IOTAModuleServices).CloseAll;
            end;
            ModuleServices := (BorlandIDEServices as IOTAModuleServices);
            // Create Project Source
            ModuleServices.CreateModule(TTestProjectFile.Create(APersonality, WizardForm.ReportLeakOption));
            Project := GetActiveProject;
            Config := (Project.ProjectOptions as IOTAProjectOptionsConfigurations).BaseConfiguration;
            Config.SetValue(sUnitSearchPath, '$(DUnitX)');
            // Create Test Unit
            if WizardForm.CreateTestUnit then
            begin
              TestUnit := ModuleServices.CreateModule(
                TNewTestUnit.Create(WizardForm.CreateSetupTearDownMethods,
                  WizardForm.CreateSampleMethods,
                  WizardForm.TestFixtureClasaName,
                  APersonality));
              if Project <> nil then
                Project.AddFile(TestUnit.FileName, true);
            end;
          end;
        finally
          WizardForm.Free;
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
      GetAllPlatforms,
      nil));
end;

end.

