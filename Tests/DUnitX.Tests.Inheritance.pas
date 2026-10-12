{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2017 Vincent Parrett                              }
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

unit DUnitX.Tests.Inheritance;

interface

{$I ..\Source\DUnitX.inc}

uses
  DUnitX.TestFramework;

type
{$M+}
  /// <summary>
  ///   Base fixture class, not registered itself, whose [Test] and [TearDownFixture] methods must be inherited by
  ///   the registered descendant.
  /// </summary>
  TMyBaseTestClass = class
  private
    /// <summary>Marker set by the constructors ('base' or 'derived') and cleared by fixture teardown.</summary>
    FBlah : string;
  protected
    /// <summary>
    ///   Virtual hook the inherited test calls, so the descendant's override is what runs.
    /// </summary>
    /// <returns>
    ///   'base'.
    /// </returns>
    function GetSomething : string; virtual;
  public
    /// <summary>
    ///   Virtual constructor the runner calls through the registered descendant's class reference.
    /// </summary>
    constructor Create; virtual;
    /// <summary>
    ///   Empty destructor.
    /// </summary>
    destructor Destroy; override;

    /// <summary>
    ///   Inherited fixture teardown; clears the marker.
    /// </summary>
    [TearDownFixture]
    procedure TearDownFixture;

    /// <summary>
    ///   Proves a [Test] declared in a base class is discovered and run on a registered descendant: the instance was
    ///   built through the descendant's virtual constructor (the marker is 'derived') and virtual dispatch reaches the
    ///   descendant's override (it returns 'derived', not the base's 'base').
    /// </summary>
    [Test]
    procedure TestInBase;
  end;

  /// <summary>
  ///   Registered fixture that declares no tests of its own; its tests all come from TMyBaseTestClass.
  /// </summary>
  TMyDerivedTest = class(TMyBaseTestClass)
  protected
    /// <summary>
    ///   Override reached from the inherited test, which checks its result.
    /// </summary>
    /// <returns>
    ///   'derived'.
    /// </returns>
    function GetSomething : string; override;
  public
    /// <summary>
    ///   Calls the inherited constructor, then sets the marker to 'derived'.
    /// </summary>
    constructor Create; override;
    /// <summary>
    ///   Empty destructor.
    /// </summary>
    destructor Destroy; override;
  end;

implementation

constructor TMyBaseTestClass.Create;
begin
  FBlah := 'base';
end;

destructor TMyBaseTestClass.Destroy;
begin
  //Empty
  inherited;
end;

function TMyBaseTestClass.GetSomething : string;
begin
  Result := 'base';
end;

procedure TMyBaseTestClass.TearDownFixture;
begin
  FBlah := '';
end;

procedure TMyBaseTestClass.TestInBase;
begin
  Assert.AreEqual('derived', FBlah, False, 'the fixture was not built through the descendant''s constructor');
  Assert.AreEqual('derived', GetSomething, False, 'virtual dispatch did not reach the descendant''s override');
end;

constructor TMyDerivedTest.Create;
begin
  inherited;
  FBlah := 'derived';
end;

destructor TMyDerivedTest.Destroy;
begin
  //Empty
  inherited;
end;

function TMyDerivedTest.GetSomething : string;
begin
  Result := 'derived';
end;

initialization
  TDUnitX.RegisterTestFixture(TMyDerivedTest);

end.

