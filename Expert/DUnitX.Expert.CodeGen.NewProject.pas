{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2013 Vincent Parrett                              }
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

unit DUnitX.Expert.CodeGen.NewProject;

interface

{$I DUnitX.inc}

uses
  PlatformAPI,
  ToolsAPI;

// IOTAProjectCreator still requires GetOptionFileName, NewDefaultModule and NewOptionSource, which
// Embarcadero has deprecated. Implementing them is not optional, so W1000 is silenced for these class
// declarations only (the compiler reports it at each class header and when it closes the section).
{$WARN SYMBOL_DEPRECATED OFF}
type
  TNewProject = class abstract(TNotifierObject, IOTACreator, IOTAProjectCreator, IOTAProjectCreator80)
  protected
    //IOTACreator
    function GetCreatorType : string; virtual;
    function GetExisting : Boolean;
    function GetFileSystem : string;
    function GetOwner : IOTAModule;
    function GetUnnamed : Boolean;
    // IOTAProjectCreator
    function GetFileName : string;
    function GetOptionFileName : string; deprecated;
    function GetShowSource : Boolean;
    procedure NewDefaultModule; deprecated;
    function NewOptionSource(const ProjectName : string) : IOTAFile; deprecated;
    procedure NewProjectResource(const Project : IOTAProject);
    function NewProjectSource(const ProjectName : string) : IOTAFile; virtual; abstract; // MUST OVERRIDE!
    // IOTAProjectCreator80
    function GetProjectPersonality : string; virtual;
    procedure NewDefaultProjectModule(const Project : IOTAProject);
  private
    procedure SetFileName(const Value : string);
  protected
    FFileName : string;
  public
    property FileName : string read GetFileName write SetFileName;
  end;

  // Delphi personality only (inherited GetProjectPersonality); Win32 and Win64 only.
  TNewProjectEx = class(TNewProject, IOTAProjectCreator160)
  protected
    // IOTAProjectCreator160
    function GetPlatforms : TArray<string>;
    function GetFrameworkType : string;
    function GetPreferredPlatform : string;
    procedure SetInitialOptions(const NewProject : IOTAProject);
  end;

implementation
{$WARN SYMBOL_DEPRECATED DEFAULT}

uses
  System.SysUtils;

{ TNewProject }

function TNewProject.GetCreatorType : string;
begin
  result := sConsole;                   // May want to change this in the future, at least making method virtual
end;

function TNewProject.GetExisting : Boolean;
begin
  result := false;
end;

function TNewProject.GetFileName : string;
begin
  result := FFileName;
end;

function TNewProject.GetFileSystem : string;
begin
  result := '';
end;

function TNewProject.GetOptionFileName : string;
begin
  result := '';
end;

function TNewProject.GetOwner : IOTAModule;
begin
  result := (BorlandIDEServices as IOTAModuleServices).MainProjectGroup;
end;

function TNewProject.GetProjectPersonality : string;
begin
  result := sDelphiPersonality;
end;

function TNewProject.GetShowSource : Boolean;
begin
  result := false;
end;

function TNewProject.GetUnnamed : Boolean;
begin
  result := true;
end;

procedure TNewProject.NewDefaultModule;
begin
end;

procedure TNewProject.NewDefaultProjectModule(const Project : IOTAProject);
begin
end;

function TNewProject.NewOptionSource(const ProjectName : string) : IOTAFile;
begin
  result := nil;
end;

procedure TNewProject.NewProjectResource(const Project : IOTAProject);
begin
end;

procedure TNewProject.SetFileName(const Value : string);
begin
  FFileName := Value;
end;

function TNewProjectEx.GetFrameworkType : string;
begin
  Result := '';
end;

function TNewProjectEx.GetPlatforms : TArray<string>;
begin
  Result := TArray<string>.Create(cWin32Platform, cWin64Platform);
end;

function TNewProjectEx.GetPreferredPlatform : string;
begin
  Result := '';
end;

procedure TNewProjectEx.SetInitialOptions(const NewProject : IOTAProject);
var
  Platforms : IOTAProjectPlatforms;
  PlatformName : string;
begin
  // GetPlatforms only declares what the project may target; the IDE still enables just its default
  // platform (Win64 on the 64-bit IDE), so enable both Windows platforms explicitly.
  if Supports(NewProject, IOTAProjectPlatforms, Platforms) then
    for PlatformName in GetPlatforms do
    begin
      Platforms.Supported[PlatformName] := True;
      Platforms.Enabled[PlatformName] := True;
    end;
end;

end.

