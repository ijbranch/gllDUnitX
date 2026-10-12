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

unit DUnitX.Expert.NewUnitWizardEx;

interface

{$I DUnitX.inc}

uses
  ToolsApi,
  PlatformConst
  ;

type
  TDUnitXNewUnitWizard = class
  public
    class procedure RegisterDUnitXNewUnitWizard(const APersonality : string);
  end;

implementation

uses
  DUnitX.Expert.Forms.NewUnitWizard,
  DUnitX.Expert.CodeGen.NewTestUnit,
  Vcl.Controls,
  Vcl.Dialogs,
  Vcl.Forms,
  WinApi.Windows,
  System.SysUtils,
  ExpertsRepository;

resourcestring
  sNewTestUnitCaption = 'DUnitX Unit';
  sNewTestUnitHint = 'Create New DUnitX Test Unit';
  sNoActiveProject = 'Open or create the project the DUnitX test unit belongs to first: there is no active project to add it to.';

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
        Result := LoadIcon(HInstance, 'DUnitXNewUnitIcon');
      end,
      TArray<string>.Create(cWin32Platform, cWin64Platform),
      nil));
end;

end.

