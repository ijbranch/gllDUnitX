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

unit DUnitX.ServiceLocator;

{$I DUnitX.inc}

interface

uses
{$IFDEF USE_NS}
  System.Generics.Collections,
  System.TypInfo,
  System.Rtti,
  System.SysUtils;
{$ELSE}
  Generics.Collections,
  TypInfo,
  Rtti,
  SysUtils;
{$ENDIF}

type
  /// <summary>
  ///   Factory function that produces an instance of a specific interface type for the service locator.
  /// </summary>
  TActivatorDelegate<TInterface : IInterface> = reference to function : TInterface;
  /// <summary>
  ///   Untyped factory function the service locator stores for every registration.
  /// </summary>
  TActivatorDelegate = reference to function : IInterface;

  /// <summary>
  ///   A simple IoC container mapping interface types (optionally named) to factories or singletons. DUnitX uses the
  ///   default container internally; tests that need one should create their own instance.
  /// </summary>
  /// <remarks>
  ///   Does not do dependency injection; use the Spring for Delphi framework if that is needed.
  /// </remarks>
  TDUnitXServiceLocator = class
  private
    type
      /// <summary>
      ///   One container entry: the factory for a key and, for a singleton, the instance once created.
      /// </summary>
      TIoCRegistration = class
        /// <summary>The factory called on each resolve (for a singleton, a wrapper that caches Instance).</summary>
        ActivatorDelegate : TActivatorDelegate;
        /// <summary>The cached singleton instance; nil until first resolved, and always nil for non-singletons.</summary>
        Instance : IInterface;
        /// <summary>
        ///   Wraps a factory so that it is called once, under a monitor lock, and its result cached in Instance.
        /// </summary>
        /// <param name="delegate">
        ///   The underlying factory.
        /// </param>
        /// <returns>
        ///   A factory that always returns the one cached instance.
        /// </returns>
        function CreateSingletonActivator(const delegate : TActivatorDelegate) : TActivatorDelegate;
        /// <summary>
        ///   Sets the entry's factory, wrapping it as a singleton activator when requested.
        /// </summary>
        /// <param name="delegate">
        ///   The factory; may be nil, in which case resolving the entry raises.
        /// </param>
        /// <param name="singleton">
        ///   True to cache the first instance created and return it on every resolve.
        /// </param>
        procedure Initialize(const delegate : TActivatorDelegate; singleton : Boolean);
      end;
  private
    /// <summary>Backing field for RaiseIfNotFound.</summary>
    FRaiseIfNotFound : boolean;
    /// <summary>Registrations keyed by lower-case interface name, plus '_' and the registration name when one is given; owns its values.</summary>
    FContainerInfo : TDictionary<string, TIoCRegistration>;
    /// <summary>The lazily created default container, freed by ClassDestroy.</summary>
    class var FDefault : TDUnitXServiceLocator;
  protected
    /// <summary>
    ///   Builds the dictionary key for an interface type and optional registration name.
    /// </summary>
    /// <param name="typeInfo">
    ///   The interface's type information.
    /// </param>
    /// <param name="AName">
    ///   The registration name; empty for the unnamed registration.
    /// </param>
    /// <returns>
    ///   The lower-cased type name, suffixed with '_' and AName when a name is given.
    /// </returns>
    function GetInterfaceKey(const typeInfo : PTypeInfo; const AName : string = '') : string;
    /// <summary>
    ///   Looks up a registration and calls its factory.
    /// </summary>
    /// <param name="typeInfo">
    ///   The interface's type information.
    /// </param>
    /// <param name="AName">
    ///   The registration name; empty for the unnamed registration.
    /// </param>
    /// <returns>
    ///   The instance, or nil when nothing is registered (or the factory returns nil) and RaiseIfNotFound is False.
    /// </returns>
    /// <exception cref="EServiceLocatorResolutionException">
    ///   Raised when the registration has a nil factory; and, when RaiseIfNotFound is True, when nothing is registered
    ///   or the factory returns nil.
    /// </exception>
    function InternalResolve(const typeInfo : PTypeInfo; const AName : string = '') : IInterface;
    /// <summary>
    ///   Adds a registration, or replaces the factory of an existing one that has not yet produced a singleton.
    /// </summary>
    /// <param name="typeInfo">
    ///   The interface's type information.
    /// </param>
    /// <param name="singleton">
    ///   True to cache and reuse the first instance created.
    /// </param>
    /// <param name="delegate">
    ///   The factory.
    /// </param>
    /// <param name="name">
    ///   The registration name; empty for the unnamed registration.
    /// </param>
    /// <exception cref="EServiceLocatorRegistrationException">
    ///   Raised when the key is already registered as a singleton whose instance has been created.
    /// </exception>
    procedure InternalRegisterType(const typeInfo : PTypeInfo; const singleton : boolean; const delegate : TActivatorDelegate; const name : string = '');
  public
    /// <summary>
    ///   Creates an empty container with RaiseIfNotFound off.
    /// </summary>
    constructor Create;
    /// <summary>
    ///   Frees the container and every registration in it.
    /// </summary>
    destructor Destroy; override;
    /// <summary>
    ///   Frees the default container when the unit finalises.
    /// </summary>
    class destructor ClassDestroy;
    /// <summary>
    ///   The process-wide container DUnitX uses internally, created thread-safely on first use.
    /// </summary>
    /// <returns>
    ///   The default container.
    /// </returns>
    class function DefaultContainer : TDUnitXServiceLocator;

    /// <summary>
    ///   Registers a class as the (non-singleton) implementation of an interface; each resolve creates a new instance
    ///   through its parameterless constructor.
    /// </summary>
    /// <param name="name">
    ///   The registration name; empty for the unnamed registration.
    /// </param>
    /// <exception cref="EServiceLocatorRegistrationException">
    ///   Raised when the key already holds a singleton that has been instantiated.
    /// </exception>
    procedure RegisterType<TInterface : IInterface; TImplementation : class>(const name : string = ''); overload;
    /// <summary>
    ///   Registers a class as the implementation of an interface, optionally as a singleton.
    /// </summary>
    /// <param name="singleton">
    ///   True to create one instance on first resolve and return it thereafter.
    /// </param>
    /// <param name="name">
    ///   The registration name; empty for the unnamed registration.
    /// </param>
    /// <exception cref="EServiceLocatorRegistrationException">
    ///   Raised when the key already holds a singleton that has been instantiated.
    /// </exception>
    procedure RegisterType<TInterface : IInterface; TImplementation : class>(const singleton : boolean; const name : string = ''); overload;

    /// <summary>
    ///   Registers a factory function as the (non-singleton) source of an interface.
    /// </summary>
    /// <param name="delegate">
    ///   The factory called on each resolve.
    /// </param>
    /// <param name="name">
    ///   The registration name; empty for the unnamed registration.
    /// </param>
    /// <exception cref="EServiceLocatorRegistrationException">
    ///   Raised when the key already holds a singleton that has been instantiated.
    /// </exception>
    procedure RegisterType<TInterface : IInterface>(const delegate : TActivatorDelegate<TInterface>; const name : string = ''); overload;
    /// <summary>
    ///   Registers a factory function as the source of an interface, optionally as a singleton.
    /// </summary>
    /// <param name="singleton">
    ///   True to call the factory once and return its result on every resolve.
    /// </param>
    /// <param name="delegate">
    ///   The factory.
    /// </param>
    /// <param name="name">
    ///   The registration name; empty for the unnamed registration.
    /// </param>
    /// <exception cref="EServiceLocatorRegistrationException">
    ///   Raised when the key already holds a singleton that has been instantiated.
    /// </exception>
    procedure RegisterType<TInterface : IInterface>(const singleton : boolean; const delegate : TActivatorDelegate<TInterface>; const name : string = '');
      overload;

    /// <summary>
    ///   Registers an existing instance as a singleton. Use the name parameter when more than one instance implements
    ///   the same interface.
    /// </summary>
    /// <param name="instance">
    ///   The instance every resolve returns.
    /// </param>
    /// <param name="name">
    ///   The registration name; empty for the unnamed registration.
    /// </param>
    /// <exception cref="EServiceLocatorRegistrationException">
    ///   Raised when the key already holds a singleton that has been instantiated.
    /// </exception>
    procedure RegisterSingleton<TInterface : IInterface>(const instance : TInterface; const name : string = '');

    /// <summary>
    ///   Resolves an interface from its registration.
    /// </summary>
    /// <param name="name">
    ///   The registration name; empty for the unnamed registration.
    /// </param>
    /// <returns>
    ///   The instance, or nil when nothing is registered and RaiseIfNotFound is False.
    /// </returns>
    /// <exception cref="EServiceLocatorResolutionException">
    ///   Raised when the registration has no factory; and, when RaiseIfNotFound is True, when nothing is registered,
    ///   the factory returns nil, or a registered class does not implement the interface.
    /// </exception>
    function Resolve<TInterface : IInterface>(const name : string = '') : TInterface;

    /// <summary>
    ///   Tests whether an unnamed registration exists for an interface.
    /// </summary>
    /// <returns>
    ///   True when T has an unnamed registration; named registrations are not considered.
    /// </returns>
    function HasService<T : IInterface> : boolean;

    /// <summary>
    ///   Removes every registration. Intended for testing only.
    /// </summary>
    procedure Clear;

    /// <summary>
    ///   When True, resolving an unregistered interface (or one whose factory yields nil) raises
    ///   EServiceLocatorResolutionException instead of returning nil. Class registrations capture the value current
    ///   at the time they are registered.
    /// </summary>
    property RaiseIfNotFound : boolean read FRaiseIfNotFound write FRaiseIfNotFound;
  end;

  /// <summary>
  ///   Base class of every exception the service locator raises.
  /// </summary>
  EServiceLocatorException = class(Exception);
  /// <summary>
  ///   Raised when a registration would replace a singleton that has already been instantiated.
  /// </summary>
  EServiceLocatorRegistrationException = class(EServiceLocatorException);
  /// <summary>
  ///   Raised when an interface cannot be resolved: no registration, no factory, no instance, or a registered class
  ///   that does not implement the interface.
  /// </summary>
  EServiceLocatorResolutionException = class(EServiceLocatorException);

  /// <summary>
  ///   Creates objects from a class reference through RTTI so that the class's own parameterless constructor runs.
  /// </summary>
  /// <remarks>
  ///   Makes sure virtual constructors are called correctly: just using a class reference will not call the overridden
  ///   constructor. See http://stackoverflow.com/questions/791069/how-can-i-create-an-delphi-object-from-a-class-reference-and-ensure-constructor
  /// </remarks>
  TClassActivator = class
  private
    class var
      /// <summary>Shared RTTI context, kept alive for the life of the process so RTTI objects stay valid.</summary>
      FRttiCtx : TRttiContext;
    /// <summary>
    ///   Creates the shared RTTI context when the unit initialises.
    /// </summary>
    class constructor Create;
  public
    /// <summary>
    ///   Creates an instance of a class and returns it as IInterface.
    /// </summary>
    /// <param name="AClass">
    ///   The class to instantiate; it must have a parameterless constructor.
    /// </param>
    /// <returns>
    ///   The new instance, or nil when the class has no parameterless constructor or does not implement IInterface.
    /// </returns>
    class function CreateInstance(const AClass : TClass) : IInterface;
    /// <summary>
    ///   Builds a factory that calls the class's first parameterless constructor and queries the result for an
    ///   interface. An instance that does not support the interface is freed.
    /// </summary>
    /// <param name="AClass">
    ///   The class to instantiate.
    /// </param>
    /// <param name="typeInfo">
    ///   The interface the instance is queried for.
    /// </param>
    /// <param name="raiseOnError">
    ///   True for the factory to raise when the instance does not implement the interface; False to return nil.
    /// </param>
    /// <returns>
    ///   The factory, or nil when the class has no parameterless constructor.
    /// </returns>
    class function CreateActivatorDelegate(const AClass : TClass; typeInfo : PTypeInfo; raiseOnError : Boolean) : TActivatorDelegate;
  end;

implementation

uses
{$IFDEF USE_NS}
  System.SyncObjs,
{$ELSE}
  SyncObjs,
{$ENDIF}
  DUnitX.ResStrs;

{ TActivator }

class constructor TClassActivator.Create;
begin
  TClassActivator.FRttiCtx := TRttiContext.Create;
end;

class function TClassActivator.CreateInstance(const AClass : TClass) : IInterface;
var
  delegate : TActivatorDelegate;
begin
  Result := nil;

  delegate := CreateActivatorDelegate(AClass, TypeInfo(IInterface), False);
  if Assigned(delegate) then
    Result := delegate();
end;

class function TClassActivator.CreateActivatorDelegate(
  const AClass : TClass; typeInfo : PTypeInfo; raiseOnError : Boolean) : TActivatorDelegate;
var
  rType : TRttiType;
  method : TRttiMethod;
  guid : TGUID;
  ctor : function(InstanceOrVMT : Pointer; Alloc : ShortInt = 1) : Pointer; // constructor signature
begin
  Result := nil;

  rType := FRttiCtx.GetType(AClass);
  if rType is TRttiInstanceType then
    for method in TRttiInstanceType(rType).GetMethods do
      if method.IsConstructor and (Length(method.GetParameters) = 0) then
      begin
        guid := GetTypeData(typeInfo).Guid;
        ctor := method.CodeAddress;
        Result :=
          function : IInterface
            var
            obj : TObject;
          begin
            obj := ctor(AClass);
            // GetInterface, NOT Supports( TObject, ... ): Supports first takes a temporary IUnknown reference, and
            // when the query then fails, releasing that reference FREES a reference-counted object (count 0 -> 1
            // -> 0), so the Free below was a double free. GetInterface takes no temporary reference, so on failure
            // obj is untouched and nothing owns it (2026-10-15).
            if not obj.GetInterface(guid, Result) then
            begin
              // Nothing took ownership of obj - free it rather than leak.
              obj.Free;
              if raiseOnError then
                raise EServiceLocatorResolutionException.CreateFmt(SRegisteredImplementationError, [AClass.ClassName, typeInfo.Name]);
            end;
          end;
        Exit;
      end;
end;

{ TDUnitXServiceLocator }

function TDUnitXServiceLocator.HasService<T> : boolean;
begin
  Result := FContainerInfo.ContainsKey(GetInterfaceKey(TypeInfo(T)));
end;

procedure TDUnitXServiceLocator.RegisterType<TInterface, TImplementation>(const name : string);
begin
  InternalRegisterType(TypeInfo(TInterface), False,
    TClassActivator.CreateActivatorDelegate(TImplementation, TypeInfo(TInterface), FRaiseIfNotFound), name);
end;

procedure TDUnitXServiceLocator.RegisterType<TInterface, TImplementation>(const singleton : boolean; const name : string);
begin
  InternalRegisterType(TypeInfo(TInterface), singleton,
    TClassActivator.CreateActivatorDelegate(TImplementation, TypeInfo(TInterface), FRaiseIfNotFound), name);
end;

procedure TDUnitXServiceLocator.InternalRegisterType(const typeInfo : PTypeInfo; const singleton : boolean; const delegate : TActivatorDelegate; const name :
  string = '');
var
  key : string;
  rego : TIoCRegistration;
begin
  key := GetInterfaceKey(typeInfo, name);

  if not FContainerInfo.TryGetValue(key, rego) then
  begin
    rego := TIoCRegistration.Create;
    rego.Initialize(delegate, singleton);
    FContainerInfo.Add(key, rego);
  end
  else
  begin
    //cannot replace a singleton that has already been instantiated (Instance property is only used by singletons)
    if rego.Instance <> nil then
      raise EServiceLocatorRegistrationException.Create(Format(SImplementationAlreadyRegistered, [typeInfo.Name, name]));
    rego.Initialize(delegate, singleton);
  end;
end;

procedure TDUnitXServiceLocator.RegisterType<TInterface>(const delegate : TActivatorDelegate<TInterface>; const name : string);
var
  internalDelegate : TActivatorDelegate;
begin
  TActivatorDelegate<TInterface>(internalDelegate) := delegate;
  InternalRegisterType(TypeInfo(TInterface), False, internalDelegate, name);
end;

class destructor TDUnitXServiceLocator.ClassDestroy;
begin
  FDefault.Free;
end;

procedure TDUnitXServiceLocator.Clear;
begin
  FContainerInfo.Clear;
end;

constructor TDUnitXServiceLocator.Create;
begin
  FContainerInfo := TObjectDictionary<string, TIoCRegistration>.Create([doOwnsValues]);
  FRaiseIfNotFound := False;
end;

class function TDUnitXServiceLocator.DefaultContainer : TDUnitXServiceLocator;
var
  container : TDUnitXServiceLocator;
begin
  if FDefault = nil then
  begin
    container := TDUnitXServiceLocator.Create;
    //Another thread may have created it first; keep that one.
    if TInterlocked.CompareExchange<TDUnitXServiceLocator>(FDefault, container, nil) <> nil then
      container.Free;
  end;

  Result := FDefault;
end;

destructor TDUnitXServiceLocator.Destroy;
begin
  FContainerInfo.Free;
  inherited;
end;

function TDUnitXServiceLocator.GetInterfaceKey(const typeInfo : PTypeInfo; const AName : string) : string;
begin
  //By default the key is the interface name unless otherwise found.
  Result := GetTypeName(typeInfo);

  if AName <> '' then
    Result := Result + '_' + AName;

  //All keys are stored in lower case form.
  Result := LowerCase(Result);
end;

function TDUnitXServiceLocator.InternalResolve(const typeInfo : PTypeInfo; const AName : string) : IInterface;
var
  key : string;
  registration : TIoCRegistration;
begin
  Result := nil;

  key := GetInterfaceKey(typeInfo, AName);

  if not FContainerInfo.TryGetValue(key, registration) then
  begin
    if FRaiseIfNotFound then
      raise EServiceLocatorResolutionException.CreateFmt(SNoImplementationRegistered, [typeInfo.Name])
        //If we are not meant to raise exceptions, then handle the registration not being set.
    else
      Exit;
  end;

  //Registered with a nil delegate: report it rather than calling nil.
  if not Assigned(registration.ActivatorDelegate) then
    raise EServiceLocatorResolutionException.CreateFmt(SNoActivator, [typeInfo.Name]);

  Result := registration.ActivatorDelegate();
  if Result = nil then
    if FRaiseIfNotFound then
      raise EServiceLocatorResolutionException.CreateFmt(SNoInstance, [typeInfo.Name]);
end;

procedure TDUnitXServiceLocator.RegisterSingleton<TInterface>(const instance : TInterface; const name : string);
begin
  InternalRegisterType(TypeInfo(TInterface), True,
    function : IInterface
    begin
      Result := instance;
    end, name);
end;

procedure TDUnitXServiceLocator.RegisterType<TInterface>(const singleton : boolean; const delegate : TActivatorDelegate<TInterface>; const name : string);
var
  internalDelegate : TActivatorDelegate;
begin
  TActivatorDelegate<TInterface>(internalDelegate) := delegate;
  InternalRegisterType(TypeInfo(TInterface), singleton, internalDelegate, name);
end;

function TDUnitXServiceLocator.Resolve<TInterface>(const name : string = '') : TInterface;
begin
  IInterface(Result) := InternalResolve(TypeInfo(TInterface), name);
end;

{ TDUnitXServiceLocator.TIoCRegistration }

procedure TDUnitXServiceLocator.TIoCRegistration.Initialize(
  const delegate : TActivatorDelegate; singleton : Boolean);
begin
  if Assigned(delegate) and singleton then
    ActivatorDelegate := CreateSingletonActivator(delegate)
  else
    ActivatorDelegate := delegate;
end;

function TDUnitXServiceLocator.TIoCRegistration.CreateSingletonActivator(
  const delegate : TActivatorDelegate) : TActivatorDelegate;
begin
  Result :=
    function : IInterface
    begin
      if not Assigned(Instance) then
      begin
        MonitorEnter(Self);
        try
          if not Assigned(Instance) then
            Instance := delegate();
        finally
          MonitorExit(Self);
        end;
      end;
      Result := Instance;
    end;
end;

end.

