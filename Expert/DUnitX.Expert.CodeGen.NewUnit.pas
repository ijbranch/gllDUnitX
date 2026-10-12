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

unit DUnitX.Expert.CodeGen.NewUnit;

interface

uses
  ToolsAPI;

type

  /// <summary>
  ///   Open Tools API module creator for a new, unnamed, form-less unit. It generates no source itself; descendants
  ///   override <see cref="NewImplSource" />.
  /// </summary>
  TNewUnit = class(TNotifierObject, IOTACreator, IOTAModuleCreator)
  protected
    //Specific to class
    /// <summary>Form name reported to the IDE; empty for a form-less unit.</summary>
    FFormName : string;
    /// <summary>Implementation (.pas) file name reported to the IDE; empty lets the IDE name the unit.</summary>
    FImplFileName : string;
    /// <summary>Interface file name reported to the IDE; empty for a Delphi unit.</summary>
    FIntfFileName : string;
    /// <summary>Ancestor form name reported to the IDE; empty when there is no ancestor form.</summary>
    FAncestorName : string;
    /// <summary>
    ///   Write accessor for <see cref="AncestorName" />.
    /// </summary>
    /// <param name="Value">
    ///   The new ancestor form name.
    /// </param>
    procedure SetAncestorName(const Value : string); virtual;
    /// <summary>
    ///   Write accessor for <see cref="FormName" />.
    /// </summary>
    /// <param name="Value">
    ///   The new form name.
    /// </param>
    procedure SetFormName(const Value : string); virtual;
    /// <summary>
    ///   Write accessor for <see cref="ImplFileName" />.
    /// </summary>
    /// <param name="Value">
    ///   The new implementation file name.
    /// </param>
    procedure SetImplFileName(const Value : string); virtual;
    /// <summary>
    ///   Write accessor for <see cref="IntfFileName" />.
    /// </summary>
    /// <param name="Value">
    ///   The new interface file name.
    /// </param>
    procedure SetIntfFileName(const Value : string); virtual;
    // IOTACreator
    /// <summary>
    ///   Tells the IDE what kind of module to create (IOTACreator).
    /// </summary>
    /// <returns>
    ///   Always <c>sUnit</c>; virtual so a descendant can create another kind.
    /// </returns>
    function GetCreatorType : string; virtual;
    /// <summary>
    ///   Tells the IDE whether the module already exists on disk (IOTACreator).
    /// </summary>
    /// <returns>
    ///   Always False - the unit is new.
    /// </returns>
    function GetExisting : Boolean;
    /// <summary>
    ///   Names the IDE file system the unit lives in (IOTACreator).
    /// </summary>
    /// <returns>
    ///   Always an empty string, meaning the default file system.
    /// </returns>
    function GetFileSystem : string;
    /// <summary>
    ///   Gives the module that owns the new unit (IOTACreator).
    /// </summary>
    /// <returns>
    ///   Always nil; the caller sets the owner (the wizards add the unit to the active project).
    /// </returns>
    function GetOwner : IOTAModule;
    /// <summary>
    ///   Tells the IDE whether the unit is unnamed and must be named on first save (IOTACreator).
    /// </summary>
    /// <returns>
    ///   Always True.
    /// </returns>
    function GetUnnamed : Boolean;
    // IOTAModuleCreator
    /// <summary>
    ///   Read accessor for <see cref="AncestorName" /> (IOTAModuleCreator).
    /// </summary>
    /// <returns>
    ///   The ancestor form name.
    /// </returns>
    function GetAncestorName : string;
    /// <summary>
    ///   Read accessor for <see cref="ImplFileName" /> (IOTAModuleCreator).
    /// </summary>
    /// <returns>
    ///   The implementation file name; empty lets the IDE choose.
    /// </returns>
    function GetImplFileName : string;
    /// <summary>
    ///   Read accessor for <see cref="IntfFileName" /> (IOTAModuleCreator).
    /// </summary>
    /// <returns>
    ///   The interface file name.
    /// </returns>
    function GetIntfFileName : string;
    /// <summary>
    ///   Read accessor for <see cref="FormName" /> (IOTAModuleCreator).
    /// </summary>
    /// <returns>
    ///   The form name.
    /// </returns>
    function GetFormName : string;
    /// <summary>
    ///   Tells the IDE whether the module's form becomes the application main form (IOTAModuleCreator).
    /// </summary>
    /// <returns>
    ///   Always False.
    /// </returns>
    function GetMainForm : Boolean;
    /// <summary>
    ///   Tells the IDE whether to show the module's form after creation (IOTAModuleCreator).
    /// </summary>
    /// <returns>
    ///   Always False.
    /// </returns>
    function GetShowForm : Boolean;
    /// <summary>
    ///   Tells the IDE whether to open the unit's source in the editor after creation (IOTAModuleCreator).
    /// </summary>
    /// <returns>
    ///   Always True.
    /// </returns>
    function GetShowSource : Boolean;
    /// <summary>
    ///   Supplies the form (.dfm) file for the new module (IOTAModuleCreator).
    /// </summary>
    /// <param name="FormIdent">
    ///   Form name the IDE supplies.
    /// </param>
    /// <param name="AncestorIdent">
    ///   Ancestor form name the IDE supplies.
    /// </param>
    /// <returns>
    ///   nil here - no form file.
    /// </returns>
    function NewFormFile(const FormIdent, AncestorIdent : string) : IOTAFile; virtual;
    /// <summary>
    ///   Supplies the implementation (.pas) source for the new module (IOTAModuleCreator).
    /// </summary>
    /// <param name="ModuleIdent">
    ///   Unit name the IDE supplies.
    /// </param>
    /// <param name="FormIdent">
    ///   Form name the IDE supplies.
    /// </param>
    /// <param name="AncestorIdent">
    ///   Ancestor form name the IDE supplies.
    /// </param>
    /// <returns>
    ///   nil here, so the IDE uses its default; descendants return the generated source.
    /// </returns>
    function NewImplSource(const ModuleIdent, FormIdent, AncestorIdent : string) : IOTAFile; virtual;
    /// <summary>
    ///   Supplies the separate interface source for the new module (IOTAModuleCreator); unused by Delphi units.
    /// </summary>
    /// <param name="ModuleIdent">
    ///   Unit name the IDE supplies.
    /// </param>
    /// <param name="FormIdent">
    ///   Form name the IDE supplies.
    /// </param>
    /// <param name="AncestorIdent">
    ///   Ancestor form name the IDE supplies.
    /// </param>
    /// <returns>
    ///   nil here - no interface file.
    /// </returns>
    function NewIntfSource(const ModuleIdent, FormIdent, AncestorIdent : string) : IOTAFile; virtual;
    /// <summary>
    ///   Called by the IDE after the module's form has been created (IOTAModuleCreator); does nothing here.
    /// </summary>
    /// <param name="FormEditor">
    ///   Editor of the newly created form.
    /// </param>
    procedure FormCreated(const FormEditor : IOTAFormEditor); virtual;
  public
    /// <summary>Form name reported to the IDE; empty for a form-less unit.</summary>
    property FormName : string read GetFormName write SetFormName;
    /// <summary>Implementation (.pas) file name reported to the IDE; empty lets the IDE name the unit.</summary>
    property ImplFileName : string read GetImplFileName write SetImplFileName;
    /// <summary>Interface file name reported to the IDE; empty for a Delphi unit.</summary>
    property IntfFileName : string read GetIntfFileName write SetIntfFileName;
    /// <summary>Ancestor form name reported to the IDE; empty when there is no ancestor form.</summary>
    property AncestorName : string read GetAncestorName write SetAncestorName;
  end;

implementation

{ TUnitCreator }

procedure TNewUnit.FormCreated(const FormEditor : IOTAFormEditor);
begin
end;

function TNewUnit.GetAncestorName : string;
begin
  Result := FAncestorName;
end;

function TNewUnit.GetCreatorType : string;
begin
  result := sUnit;
end;

function TNewUnit.GetExisting : Boolean;
begin
  result := false;
end;

function TNewUnit.GetFileSystem : string;
begin
  result := '';
end;

function TNewUnit.GetFormName : string;
begin
  result := FFormName;
end;

function TNewUnit.GetImplFileName : string;
begin
  result := FImplFileName;
end;

function TNewUnit.GetIntfFileName : string;
begin
  Result := FIntfFileName;
end;

function TNewUnit.GetMainForm : Boolean;
begin
  result := false;
end;

function TNewUnit.GetOwner : IOTAModule;
begin
  result := nil;
end;

function TNewUnit.GetShowForm : Boolean;
begin
  result := False;
end;

function TNewUnit.GetShowSource : Boolean;
begin
  result := True;
end;

function TNewUnit.GetUnnamed : Boolean;
begin
  result := true;
end;

function TNewUnit.NewFormFile(const FormIdent,
  AncestorIdent : string) : IOTAFile;
begin
  result := nil;
end;

function TNewUnit.NewImplSource(const ModuleIdent, FormIdent,
  AncestorIdent : string) : IOTAFile;
begin
  Result := nil;
end;

function TNewUnit.NewIntfSource(const ModuleIdent, FormIdent,
  AncestorIdent : string) : IOTAFile;
begin
  result := nil;
end;

procedure TNewUnit.SetAncestorName(const Value : string);
begin
  FAncestorName := Value;
end;

procedure TNewUnit.SetFormName(const Value : string);
begin
  FFormName := Value;
end;

procedure TNewUnit.SetImplFileName(const Value : string);
begin
  FImplFileName := Value;
end;

procedure TNewUnit.SetIntfFileName(const Value : string);
begin
  FIntfFileName := Value;
end;

end.

