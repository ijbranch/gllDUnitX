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

unit DUnitX.Expert.CodeGen.NewTestProject;

interface

{$I DUnitX.inc}

uses
  ToolsAPI,
  DUnitX.Expert.CodeGen.NewProject;

type
  /// <summary>
  ///   Memory-leak reporting to wire into a generated test project.
  /// </summary>
  TReportLeakOptions = (
    /// <summary>No leak reporting; the project uses no extra units.</summary>
    rloNone,
    /// <summary>Adds FastMM5 and DUnitX.MemoryLeakMonitor.FastMM5 to the project's uses clause.</summary>
    rloFastMM5
  );

  /// <summary>
  ///   Creator for a new DUnitX console test project, generating its .dpr from the <c>STestDPR</c> template.
  /// </summary>
  TTestProjectFile = class(TNewProjectEx)
  private
    /// <summary>Leak reporting chosen in the wizard; selects the extra uses entries in the .dpr.</summary>
    FReportLeakOptions : TReportLeakOptions;
  protected
    /// <summary>
    ///   Generates the test project's .dpr source from <c>STestDPR</c>.
    /// </summary>
    /// <param name="ProjectName">
    ///   Name the IDE has given the new project; becomes the <c>program</c> name.
    /// </param>
    /// <returns>
    ///   The generated project source.
    /// </returns>
    function NewProjectSource(const ProjectName : string) : IOTAFile; override;
  public
    /// <summary>
    ///   Creates the creator with an empty file name, so the IDE names the project ProjectN.
    /// </summary>
    /// <param name="ReportLeakOptions">
    ///   Leak reporting to wire into the generated project.
    /// </param>
    constructor Create(const ReportLeakOptions : TReportLeakOptions);
  end;

implementation

uses
  DUnitX.Expert.CodeGen.SourceFile,
  DunitX.Expert.CodeGen.Templates;

const
  REPORT_LEAK_DECLARATION : array[TReportLeakOptions] of string = ('', '  FastMM5,'#13#10'  DUnitX.MemoryLeakMonitor.FastMM5,'#13#10);

  { TProjectFile }

constructor TTestProjectFile.Create(const ReportLeakOptions : TReportLeakOptions);
begin
  //TODO: Figure out how to make this be TestProjectX where X is the next available.
  //Return Blank and the project will be 'ProjectX.dpr' where X is the next available number
  FFileName := '';
  FReportLeakOptions := ReportLeakOptions;
end;

function TTestProjectFile.NewProjectSource(const ProjectName : string) : IOTAFile;
begin
  result := TSourceFile.Create(STestDPR, [ProjectName, REPORT_LEAK_DECLARATION[FReportLeakOptions]]);
end;

end.

