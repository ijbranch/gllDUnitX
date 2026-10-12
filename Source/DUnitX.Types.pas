{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2017 Vincent Parrett & Contributors               }
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
{ This unit is contains ideas borrowed largely from NUnit                   }
{ Copyright � 2012-2014 Charlie Poole                                       }
{ License  : http://nunit.org/index.php?p=vsTestAdapterLicense&r=2.6.3      }
{                                                                           }
{***************************************************************************}

unit DUnitX.Types;

{$I DUnitX.inc}

interface

uses
{$IFDEF USE_NS}
  System.Rtti;
{$ELSE}
  Rtti;
{$ENDIF}

type
{$IFDEF SUPPORTS_TARRAY}
  /// <summary>
  ///   Dynamic array of RTTI values; used for the argument lists that test cases pass to parameterised test methods.
  /// </summary>
  TValueArray = TArray<TValue>;
{$ELSE}
  /// <summary>
  ///   Dynamic array of RTTI values; used for the argument lists that test cases pass to parameterised test methods.
  /// </summary>
  TValueArray = array of TValue;
{$ENDIF}

  /// <summary>
  ///   How an expected exception class declared on a test (WillRaise attribute) is matched against the exception the
  ///   test actually raised.
  /// </summary>
  TExceptionInheritance = (
    /// <summary>The raised exception's class must be exactly the expected class.</summary>
    exExact,
    /// <summary>The raised exception may be the expected class or any descendant of it.</summary>
    exDescendant
  );

implementation

end.

