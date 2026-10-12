{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2017 Vincent Parrett & Contributors               }
{                                                                           }
{           vincent@finalbuilder.com                                        }
{           http://www.finalbuilder.com                                     }
{           This unit authored by Uwe Rupprecht                             }
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

unit DUnitX.TestDataProvider;

interface

{$I DUnitX.inc}

uses
{$IFDEF USE_NS}
  System.Classes,
  System.Generics.Collections,
{$ELSE}
  Classes,
  Generics.Collections,
{$ENDIF}
  DUnitX.Types,
  DUnitX.InternalDataProvider;

type
  /// <summary>
  ///   Global registry of test data provider classes, keyed by name, used by the [TestCaseProvider] attribute to create
  ///   the provider that supplies a test's cases.
  /// </summary>
  TestDataProviderManager = class
  private
    class var
      /// <summary>Registered provider classes, keyed by provider name.</summary>
      FList : TDictionary<string, TClass>;
  public
    /// <summary>
    ///   Creates the empty registry when the unit initialises.
    /// </summary>
    class constructor Create;
    /// <summary>
    ///   Frees the registry when the unit finalises.
    /// </summary>
    class destructor Destroy;

    /// <summary>
    ///   Registers a provider class under a name. A name that is already registered keeps its existing class.
    /// </summary>
    /// <param name="name">
    ///   The provider name that [TestCaseProvider] attributes refer to.
    /// </param>
    /// <param name="AClass">
    ///   The provider class to instantiate for that name.
    /// </param>
    class procedure RegisterProvider(const name : string; const AClass : TTestDataProviderClass);
    /// <summary>
    ///   Removes a provider registration; does nothing when the name is not registered.
    /// </summary>
    /// <param name="name">
    ///   The provider name to remove.
    /// </param>
    class procedure UnregisterProvider(const name : string);

    /// <summary>
    ///   Creates a new instance of the provider registered under a name.
    /// </summary>
    /// <param name="name">
    ///   The registered provider name.
    /// </param>
    /// <returns>
    ///   A new provider instance, or nil when the name is not registered.
    /// </returns>
    class function GetProvider(const name : string) : ITestDataProvider; overload;
    /// <summary>
    ///   Creates a new instance of a provider class, provided that class has been registered under some name.
    /// </summary>
    /// <param name="AClass">
    ///   The provider class.
    /// </param>
    /// <returns>
    ///   A new provider instance, or nil when the class is not registered.
    /// </returns>
    class function GetProvider(const AClass : TTestDataProviderClass) : ITestDataProvider; overload;
  end;

implementation

{ TestDataProviderManager }

class constructor TestDataProviderManager.Create;
begin
  FList := TDictionary<string, TClass>.Create;
end;

class destructor TestDataProviderManager.Destroy;
begin
  FList.Free;
end;

class function TestDataProviderManager.GetProvider(const AClass : TTestDataProviderClass) : ITestDataProvider;
var
  key : string;
begin
  result := nil;
  if (FList.ContainsValue(AClass)) then
  begin
    for key in flist.keys do
    begin
      if (flist[key] = AClass) then
      begin
        result := TTestDataProviderClass(flist[key]).Create;
        break;
      end;
    end;
  end;
end;

class function TestDataProviderManager.GetProvider(const name : string) : ITestDataProvider;
begin
  result := nil;
  if (FList.ContainsKey(name)) then
    result := TTestDataProviderClass(FList[name]).Create;
end;

class procedure TestDataProviderManager.RegisterProvider(const name : string; const AClass : TTestDataProviderClass);
begin
  if (not FList.ContainsKey(name)) then
    FList.add(name, AClass);
end;

class procedure TestDataProviderManager.UnregisterProvider(const name : string);
begin
  if (FList.ContainsKey(name)) then
    FList.Remove(Name);
end;

end.

