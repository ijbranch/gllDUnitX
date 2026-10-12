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

unit DUnitX.FixtureBuilder;

interface

uses
  DUnitX.Extensibility;

type
  /// <summary>
  ///   Default fixture builder: resolves the registered IFixtureProvider and acts as its context, collecting every
  ///   fixture the provider creates into a single top-level fixture list.
  /// </summary>
  TDUnitXFixtureBuilder = class(TInterfacedObject, IFixtureBuilder, IFixtureProviderContext)
  private
    /// <summary>True when fixtures are to be discovered through RTTI rather than only from explicit registrations.</summary>
    FUseRtti : boolean;
    /// <summary>The top-level fixture list that CreateFixture adds to and BuildFixtureList returns.</summary>
    FFixtureList : ITestFixtureList;
  protected
    /// <summary>
    ///   Tells the fixture provider whether RTTI discovery was requested.
    /// </summary>
    /// <returns>
    ///   The useRtti value passed to the constructor.
    /// </returns>
    function GetUseRtti : boolean;
    /// <summary>
    ///   Creates a top-level fixture for a test class and adds it to the fixture list being built.
    /// </summary>
    /// <param name="AFixtureClass">
    ///   The test class the fixture wraps; its unit name becomes the fixture's unit name.
    /// </param>
    /// <param name="AName">
    ///   The fixture's name.
    /// </param>
    /// <param name="ACategory">
    ///   The fixture's category list, as a comma-separated string.
    /// </param>
    /// <returns>
    ///   The new fixture, already added to the list.
    /// </returns>
    function CreateFixture(const AFixtureClass : TClass; const AName : string; const ACategory : string) : ITestFixture; overload;
    /// <summary>
    ///   Resolves the registered fixture provider and has it populate the fixture list through this context.
    /// </summary>
    /// <returns>
    ///   The populated top-level fixture list.
    /// </returns>
    /// <exception cref="ETestFrameworkException">
    ///   Raised when no IFixtureProvider is registered with the service locator.
    /// </exception>
    function BuildFixtureList : ITestFixtureList;

  public
    /// <summary>
    ///   Creates the builder with an empty fixture list.
    /// </summary>
    /// <param name="useRtti">
    ///   True to have the provider discover fixtures through RTTI.
    /// </param>
    constructor Create(useRtti : boolean);
  end;

implementation

uses
  DUnitX.Exceptions,
  DUnitX.ServiceLocator,
  DUnitX.TestFixture,
  DUnitX.ResStrs;

{ TDUnitXFixtureBuilder }

function TDUnitXFixtureBuilder.BuildFixtureList : ITestFixtureList;
var
  provider : IFixtureProvider;
begin
  result := FFixtureList;

  provider := TDUnitXServiceLocator.DefaultContainer.Resolve<IFixtureProvider>();
  if provider = nil then
    raise ETestFrameworkException.Create(SNoFixtureProvider);

  provider.Execute(Self);

end;

constructor TDUnitXFixtureBuilder.Create(useRtti : boolean);
begin
  FUseRtti := useRtti;
  FFixtureList := TTestFixtureList.Create;
end;

function TDUnitXFixtureBuilder.CreateFixture(const AFixtureClass : TClass; const AName, ACategory : string) : ITestFixture;
begin
  result := TDUnitXTestFixture.Create(AName, ACategory, AFixtureClass, AFixtureClass.UnitName);
  FFixtureList.Add(Result);
end;

function TDUnitXFixtureBuilder.GetUseRtti : boolean;
begin
  result := FUseRtti;
end;
end.

