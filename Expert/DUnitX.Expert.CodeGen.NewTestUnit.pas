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

unit DUnitX.Expert.CodeGen.NewTestUnit;

interface

{$I DUnitX.inc}

uses
  ToolsApi,
  DunitX.Expert.CodeGen.NewUnit;

type
  /// <summary>
  ///   Creator for a new DUnitX test unit, generating its source from the <c>STestUnit</c> template with an optional
  ///   Setup/TearDown pair and sample test methods.
  /// </summary>
  TNewTestUnit = class(TNewUnit)
  protected
    /// <summary>True to generate [Setup] and [TearDown] methods in the fixture.</summary>
    FCreateSetupTearDown : Boolean;
    /// <summary>True to generate the sample [Test] methods in the fixture.</summary>
    FCreateSampleMethods : Boolean;
    /// <summary>Name of the generated fixture class; prefixed with T if it would equal the unit name.</summary>
    FTestFixtureClassName : string;
    /// <summary>
    ///   Generates the test unit's source from <c>STestUnit</c> and the optional Setup/TearDown and sample templates.
    /// </summary>
    /// <param name="ModuleIdent">
    ///   Unit name the IDE supplies; when blank the name is derived from the new module's file name.
    /// </param>
    /// <param name="FormIdent">
    ///   Form name the IDE supplies (unused - a test unit has no form).
    /// </param>
    /// <param name="AncestorIdent">
    ///   Ancestor form name the IDE supplies (unused).
    /// </param>
    /// <returns>
    ///   The generated unit source.
    /// </returns>
    /// <remarks>
    ///   A fixture class named like its unit would redeclare the unit identifier (E2004), and the wizard forms validate
    ///   the class name before the IDE names the unit, so such a name is given a T prefix here.
    /// </remarks>
    function NewImplSource(const ModuleIdent, FormIdent, AncestorIdent : string) : IOTAFile; override;
  public
    /// <summary>
    ///   Creates the creator for an unnamed test unit with the given fixture options.
    /// </summary>
    /// <param name="ACreateSetupTearDown">
    ///   True to generate [Setup] and [TearDown] methods.
    /// </param>
    /// <param name="ACreateSampleMethods">
    ///   True to generate the sample test methods.
    /// </param>
    /// <param name="ATestFixtureClassName">
    ///   Name of the fixture class; must not be empty (checked by an Assert).
    /// </param>
    constructor Create(const ACreateSetupTearDown : boolean; const ACreateSampleMethods : boolean; const ATestFixtureClassName : string);
  end;

implementation

uses
  System.SysUtils,
  DUnitX.Expert.CodeGen.Templates,
  DUnitX.Expert.CodeGen.SourceFile;

{ TNewTestUnit }

constructor TNewTestUnit.Create(const ACreateSetupTearDown : boolean; const ACreateSampleMethods : boolean; const ATestFixtureClassName :
  string);
begin
  Assert(Length(ATestFixtureClassName) > 0);
  FAncestorName := '';
  FFormName := '';
  FImplFileName := '';
  FIntfFileName := '';
  FTestFixtureClassName := ATestFixtureClassName;
  FCreateSetupTearDown := ACreateSetupTearDown;
  FCreateSampleMethods := ACreateSampleMethods;
end;

function TNewTestUnit.NewImplSource(const ModuleIdent, FormIdent, AncestorIdent : string) : IOTAFile;
var
  lSetupTearDownIntf : string;
  lSetupTearDownImpl : string;
  lSampleIntf : string;
  lSampleImpl : string;
  lUnitIdent, lFormName, lFileName : string;
begin
  // Use ModuleIdent when the IDE supplies it. It has been seen blank, so fall back to the method
  // mentioned by Marco Cantu:
  // http://stackoverflow.com/questions/4196412/how-do-you-retrieve-a-new-unit-name-from-delphis-open-tools-api
  // The unit name must match the file name (E1038), so it is taken from the file name rather than from the
  // identifier the IDE suggests alongside it.
  if ModuleIdent <> '' then
    lUnitIdent := ModuleIdent
  else
  begin
    lFileName := FImplFileName;
    if lFileName = '' then
      (BorlandIDEServices as IOTAModuleServices).GetNewModuleAndClassName('', lUnitIdent, lFormName, lFileName);
    if lFileName <> '' then
      lUnitIdent := ChangeFileExt(ExtractFileName(lFileName), '');
  end;

  // The wizard forms validate the class name before the IDE names the unit, so a fixture named like its unit can
  // only be caught here. Such a class redeclares the unit identifier (E2004); a T prefix, the usual Delphi type
  // prefix, can never equal the unit name it was derived from.
  if SameText(FTestFixtureClassName, lUnitIdent) then
    FTestFixtureClassName := 'T' + FTestFixtureClassName;

  if FCreateSetupTearDown then
  begin
    lSetupTearDownIntf := SSetupTearDownIntf;
    lSetupTearDownImpl := Format(SSetupTearDownImpl, [FTestFixtureClassName]);
  end
  else
  begin
    lSetupTearDownIntf := '';
    lSetupTearDownImpl := '';
  end;

  if FCreateSampleMethods then
  begin
    lSampleIntf := SSampleMethodsIntf;
    lSampleImpl := Format(SSampleMethodsImpl, [FTestFixtureClassName]);
  end
  else
  begin
    lSampleIntf := '';
    lSampleImpl := '';
  end;

  result := TSourceFile.Create(STestUnit, [lUnitIdent, FTestFixtureClassName, lSetupTearDownIntf,
      lSampleIntf, lSetupTearDownImpl, lSampleImpl]);

end;

end.

