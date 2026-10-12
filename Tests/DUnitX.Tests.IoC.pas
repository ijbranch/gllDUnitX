{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2017 Vincent Parrett                              }
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

unit DUnitX.Tests.IoC;

{$I ..\Source\DUnitX.inc}

interface

uses
  DUnitX.TestFramework,
  DUnitX.ServiceLocator;

type
{$M+}
  /// <summary>
  ///   Service interface registered in the locator under several names and lifetimes.
  /// </summary>
  IFoo = interface
    ['{FA01B68C-0D64-4251-91C6-F38617A56B33}']
    /// <summary>
    ///   Writes 'Bar' to the console; a body for the interface, not used by the tests.
    /// </summary>
    procedure Bar;
  end;

{$M+}
  /// <summary>
  ///   Unused sample interface for a singleton service; declared but registered nowhere.
  /// </summary>
  ISingleton = interface
    ['{615BDB28-13D0-4CAF-B84A-3C77B479B9AE}']
    /// <summary>
    ///   Would report how many instances exist.
    /// </summary>
    /// <returns>
    ///   An instance count (no implementation exists).
    /// </returns>
    function HowMany : integer;
  end;

  /// <summary>
  ///   Tests for <c>TDUnitXServiceLocator</c>: activator and implementation-class registrations, singleton versus
  ///   per-resolve lifetimes, named registrations, and a nil activator.
  /// </summary>
  TDUnitX_IoCTests = class
  private
    /// <summary>Locator shared by the fixture's tests, populated once in Setup.</summary>
    FContainer : TDUnitXServiceLocator;
  public
    /// <summary>
    ///   Fixture setup: creates the locator and registers IFoo as an unnamed activator, a named implementation
    ///   ('test'), a named activator singleton ('activator_singleton') and a named implementation singleton
    ///   ('impl_singleton').
    /// </summary>
    [SetupFixture]
    procedure Setup;

    /// <summary>
    ///   Fixture teardown: frees the locator.
    /// </summary>
    [TearDownFixture]
    procedure TearDownFixture;

{$IFDEF DELPHI_XE_UP}
    /// <summary>
    ///   Proves a non-singleton implementation-class registration creates a new instance on every resolve.
    /// </summary>
    [Test]
    procedure Test_Implementation_Non_Singleton;

    /// <summary>
    ///   Proves a singleton implementation-class registration returns the same instance on every resolve.
    /// </summary>
    [Test]
    procedure Test_Implementation_Singleton;
{$ENDIF}

    /// <summary>
    ///   Proves a non-singleton activator registration creates a new instance on every resolve.
    /// </summary>
    [Test]
    procedure Test_Activator_Non_Singleton;

    /// <summary>
    ///   Proves a singleton activator registration returns the same instance on every resolve, and that a different
    ///   named singleton is a different instance.
    /// </summary>
    [Test]
    procedure Test_Activator_Singleton;

    /// <summary>
    ///   Proves that resolving a registration that has no activator (a nil delegate) raises a clear
    ///   EServiceLocatorResolutionException rather than an access violation.
    /// </summary>
    [Test]
    procedure Test_Nil_Activator_Raises_Resolution_Exception;
  end;

implementation

type
  TFoo = class(TInterfacedObject, IFoo)
  protected
    procedure Bar;
  end;

procedure TDUnitX_IoCTests.Setup;
begin
  FContainer := TDUnitXServiceLocator.Create;

  FContainer.RegisterType<IFoo>(
    function : IFoo
    begin
      result := TFoo.Create;
    end);

{$IFDEF DELPHI_XE_UP}
  //NOTE: DUnitX.ServiceLocator has details on why this is only available for XE up.
  FContainer.RegisterType<IFoo, TFoo>('test');
{$ENDIF}

  //singletons
  FContainer.RegisterType<IFoo>(true,
    function : IFoo
    begin
      result := TFoo.Create;
    end,
    'activator_singleton');

{$IFDEF DELPHI_XE_UP}
  //NOTE: DUnitX.ServiceLocator has details on why this is only available for XE up.
  FContainer.RegisterType<IFoo, TFoo>(true, 'impl_singleton');
{$ENDIF}
end;

procedure TDUnitX_IoCTests.TearDownFixture;
begin
  FContainer.Free;
end;

procedure TDUnitX_IoCTests.Test_Activator_Non_Singleton;
var
  foo1 : IFoo;
  foo2 : IFoo;
begin
  foo1 := FContainer.Resolve<IFoo>();
  foo2 := FContainer.Resolve<IFoo>();

  Assert.AreNotSame(foo1, foo2);
end;

procedure TDUnitX_IoCTests.Test_Activator_Singleton;
var
  foo1 : IFoo;
  foo2 : IFoo;
begin
  foo1 := FContainer.Resolve<IFoo>('activator_singleton');
  foo2 := FContainer.Resolve<IFoo>('activator_singleton');
  Assert.AreSame(foo1, foo2);

{$IFDEF DELPHI_XE_UP}
  //NOTE: DUnitX.ServiceLocator has details on why this is only available for XE up.
  foo1 := FContainer.Resolve<IFoo>('impl_singleton');
  Assert.AreNotSame(foo1, foo2);
{$ENDIF}
end;

{$IFDEF DELPHI_XE_UP}
//NOTE: DUnitX.ServiceLocator has details on why this is only available for XE up.
procedure TDUnitX_IoCTests.Test_Implementation_Non_Singleton;
var
  foo1 : IFoo;
  foo2 : IFoo;
begin
  foo1 := FContainer.Resolve<IFoo>('test');
  foo2 := FContainer.Resolve<IFoo>('test');
  Assert.AreNotSame(foo1, foo2);
end;

procedure TDUnitX_IoCTests.Test_Implementation_Singleton;
var
  foo1 : IFoo;
  foo2 : IFoo;
begin
  foo1 := FContainer.Resolve<IFoo>('impl_singleton');
  foo2 := FContainer.Resolve<IFoo>('impl_singleton');
  Assert.AreSame(foo1, foo2);
end;
{$ENDIF}

procedure TDUnitX_IoCTests.Test_Nil_Activator_Raises_Resolution_Exception;
var
  container : TDUnitXServiceLocator;
begin
  container := TDUnitXServiceLocator.Create;
  try
    container.RegisterType<IFoo>(TActivatorDelegate<IFoo>(nil), 'nil_activator');
    Assert.WillRaise(
      procedure
      begin
        container.Resolve<IFoo>('nil_activator');
      end, EServiceLocatorResolutionException);
  finally
    container.Free;
  end;
end;

procedure TFoo.Bar;
begin
  Write('Bar');
end;

initialization
  TDUnitX.RegisterTestFixture(TDUnitX_IoCTests);

end.

