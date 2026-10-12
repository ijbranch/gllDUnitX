{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2013 Vincent Parrett                              }
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
  /// <summary>
  ///   Abstract Open Tools API project creator: answers the IDE's IOTACreator / IOTAProjectCreator questions with
  ///   defaults for a new, unnamed Delphi console project. Descendants supply the project source.
  /// </summary>
  TNewProject = class abstract(TNotifierObject, IOTACreator, IOTAProjectCreator, IOTAProjectCreator80)
  protected
    //IOTACreator
    /// <summary>
    ///   Tells the IDE what kind of project to create (IOTACreator).
    /// </summary>
    /// <returns>
    ///   Always <c>sConsole</c>; virtual so a descendant can create another kind.
    /// </returns>
    function GetCreatorType : string; virtual;
    /// <summary>
    ///   Tells the IDE whether the project already exists on disk (IOTACreator).
    /// </summary>
    /// <returns>
    ///   Always False - the project is new.
    /// </returns>
    function GetExisting : Boolean;
    /// <summary>
    ///   Names the IDE file system the project lives in (IOTACreator).
    /// </summary>
    /// <returns>
    ///   Always an empty string, meaning the default file system.
    /// </returns>
    function GetFileSystem : string;
    /// <summary>
    ///   Gives the module that owns the new project (IOTACreator).
    /// </summary>
    /// <returns>
    ///   The IDE's main project group.
    /// </returns>
    function GetOwner : IOTAModule;
    /// <summary>
    ///   Tells the IDE whether the project is unnamed and must be named on first save (IOTACreator).
    /// </summary>
    /// <returns>
    ///   Always True.
    /// </returns>
    function GetUnnamed : Boolean;
    // IOTAProjectCreator
    /// <summary>
    ///   Read accessor for <see cref="FileName" /> (IOTAProjectCreator).
    /// </summary>
    /// <returns>
    ///   The project file name; empty lets the IDE choose the next free ProjectN name.
    /// </returns>
    function GetFileName : string;
    /// <summary>
    ///   Deprecated IOTAProjectCreator member the interface still requires.
    /// </summary>
    /// <returns>
    ///   Always an empty string - no separate options file.
    /// </returns>
    function GetOptionFileName : string; deprecated;
    /// <summary>
    ///   Tells the IDE whether to open the project source in the editor after creation (IOTAProjectCreator).
    /// </summary>
    /// <returns>
    ///   Always False.
    /// </returns>
    function GetShowSource : Boolean;
    /// <summary>
    ///   Deprecated IOTAProjectCreator member the interface still requires; does nothing.
    /// </summary>
    procedure NewDefaultModule; deprecated;
    /// <summary>
    ///   Deprecated IOTAProjectCreator member the interface still requires.
    /// </summary>
    /// <param name="ProjectName">
    ///   Name of the project being created (unused).
    /// </param>
    /// <returns>
    ///   Always nil - no options source is generated.
    /// </returns>
    function NewOptionSource(const ProjectName : string) : IOTAFile; deprecated;
    /// <summary>
    ///   Called by the IDE to create the project's resource; does nothing, so the IDE default applies.
    /// </summary>
    /// <param name="Project">
    ///   The project just created (unused).
    /// </param>
    procedure NewProjectResource(const Project : IOTAProject);
    /// <summary>
    ///   Supplies the project (.dpr) source. Abstract: every descendant MUST override it.
    /// </summary>
    /// <param name="ProjectName">
    ///   Name the IDE has given the new project.
    /// </param>
    /// <returns>
    ///   The generated project source.
    /// </returns>
    function NewProjectSource(const ProjectName : string) : IOTAFile; virtual; abstract; // MUST OVERRIDE!
    // IOTAProjectCreator80
    /// <summary>
    ///   Names the IDE personality the project belongs to (IOTAProjectCreator80).
    /// </summary>
    /// <returns>
    ///   <c>sDelphiPersonality</c>; virtual so a descendant can change it.
    /// </returns>
    function GetProjectPersonality : string; virtual;
    /// <summary>
    ///   Called by the IDE to add a default module to the new project; does nothing, so no unit is added.
    /// </summary>
    /// <param name="Project">
    ///   The project just created (unused).
    /// </param>
    procedure NewDefaultProjectModule(const Project : IOTAProject);
  private
    /// <summary>
    ///   Write accessor for <see cref="FileName" />.
    /// </summary>
    /// <param name="Value">
    ///   The new project file name.
    /// </param>
    procedure SetFileName(const Value : string);
  protected
    /// <summary>Project file name returned to the IDE; empty means let the IDE choose.</summary>
    FFileName : string;
  public
    /// <summary>
    ///   Project file name the creator reports to the IDE; empty lets the IDE pick the next free ProjectN name.
    /// </summary>
    property FileName : string read GetFileName write SetFileName;
  end;

  /// <summary>
  ///   Project creator that also implements IOTAProjectCreator160 so the new project declares, and enables, both
  ///   Windows platforms.
  /// </summary>
  /// <remarks>
  ///   Delphi personality only (inherited GetProjectPersonality); Win32 and Win64 only.
  /// </remarks>
  TNewProjectEx = class(TNewProject, IOTAProjectCreator160)
  protected
    // IOTAProjectCreator160
    /// <summary>
    ///   Declares the platforms the new project may target (IOTAProjectCreator160).
    /// </summary>
    /// <returns>
    ///   Win32 and Win64.
    /// </returns>
    function GetPlatforms : TArray<string>;
    /// <summary>
    ///   Names the framework of the new project (IOTAProjectCreator160).
    /// </summary>
    /// <returns>
    ///   Always an empty string - no VCL/FMX framework, since the project is a console application.
    /// </returns>
    function GetFrameworkType : string;
    /// <summary>
    ///   Names the platform the IDE should make active (IOTAProjectCreator160).
    /// </summary>
    /// <returns>
    ///   Always an empty string, leaving the choice to the IDE.
    /// </returns>
    function GetPreferredPlatform : string;
    /// <summary>
    ///   Marks every platform from <see cref="GetPlatforms" /> as supported and enabled on the new project.
    /// </summary>
    /// <param name="NewProject">
    ///   The project just created.
    /// </param>
    /// <remarks>
    ///   GetPlatforms only declares what the project may target; the IDE still enables just its default platform
    ///   (Win64 on the 64-bit IDE), so both Windows platforms are enabled explicitly here.
    /// </remarks>
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

