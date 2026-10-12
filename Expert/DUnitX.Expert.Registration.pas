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

unit DUnitX.Expert.Registration;

interface

{$I DUnitX.inc}

//Note: "Register" method name is case sensitive.
procedure Register;

implementation

uses
  ToolsApi,
  DUnitX.Expert.ProjectWizardEx,
  DUnitX.Expert.NewUnitWizardEx;

procedure Register;
begin
  // Delphi personality only: C++Builder is out of scope for this fork.
  TDUnitXNewProjectWizard.RegisterDUnitXProjectWizard(sDelphiPersonality);
  TDUnitXNewUnitWizard.RegisterDUnitXNewUnitWizard(sDelphiPersonality);
end;

end.

