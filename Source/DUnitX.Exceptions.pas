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

unit DUnitX.Exceptions;

interface

{$I DUnitX.inc}

uses
{$IFDEF USE_NS}
  System.SysUtils,
{$ELSE}
  SysUtils,
{$ENDIF}

  DUnitX.ComparableFormat;

type
  /// <summary>
  ///   Root of every exception the DUnitX framework itself raises.
  /// </summary>
  ETestFrameworkException = class(Exception);

  /// <summary>
  ///   Intended for framework code paths that have not been implemented; nothing in the framework currently raises it.
  /// </summary>
  ENotImplemented = class(ETestFrameworkException);

  /// <summary>
  ///   Base exception for any internal exceptions which cause the test to stop (failure, pass, time-out).
  /// </summary>
  /// <remarks>
  ///   Shadows <c>System.SysUtils.EAbort</c> inside units that use this one; it is not a silent exception.
  /// </remarks>
  EAbort = class(ETestFrameworkException);

  /// <summary>
  ///   Raised by <c>Assert.Ignore</c> to stop a test and record it as ignored rather than passed or failed.
  /// </summary>
  ETestIgnored = class(ETestFrameworkException);

  /// <summary>
  ///   Raised by a failing assertion (<c>Assert.Fail</c> and every <c>Assert.*</c> check); the runner records the test
  ///   as failed.
  /// </summary>
  ETestFailure = class(EAbort);

  /// <summary>
  ///   Assertion failure from a string comparison that carries the expected and actual text separately, so a logger can
  ///   show or diff them.
  /// </summary>
  ETestFailureStrCompare = class(ETestFailure)
  private
    /// <summary>The actual string that was compared.</summary>
    FActual : string;
    /// <summary>The expected string that was compared.</summary>
    FExpected : string;
    /// <summary>The caller's assertion message, without the expected/actual text.</summary>
    FMsg : string;
    /// <summary>Formatter class used to render the compared values, or nil.</summary>
    FFormat : TDUnitXComparableFormatClass;
  public
    /// <summary>The actual string that was compared.</summary>
    property Actual : string read FActual;
    /// <summary>The expected string that was compared.</summary>
    property Expected : string read FExpected;
    /// <summary>The caller's assertion message, without the expected/actual text.</summary>
    property Msg : string read FMsg;
    /// <summary>Formatter class used to render the compared values, or nil.</summary>
    property Format : TDUnitXComparableFormatClass read FFormat;

    /// <summary>
    ///   Creates the failure, storing the compared values and building the message from <c>SNotEqualErrorStr</c>.
    /// </summary>
    /// <param name="aExpected">
    ///   The expected string.
    /// </param>
    /// <param name="aActual">
    ///   The actual string.
    /// </param>
    /// <param name="aMessage">
    ///   The caller's assertion message.
    /// </param>
    /// <param name="aFormat">
    ///   Formatter class used to render the values, or nil.
    /// </param>
    constructor Create(const aExpected, aActual, aMessage : string; const aFormat : TDUnitXComparableFormatClass); reintroduce;
  end;

  /// <summary>
  ///   Raised by <c>Assert.Pass</c> to stop a test early and record it as passed.
  /// </summary>
  ETestPass = class(EAbort);
  /// <summary>
  ///   Raised when a test exceeds the time allowed by its MaxTime/time-out setting.
  /// </summary>
  ETimedOut = class(EAbort);
  /// <summary>
  ///   Raised by the runner when a test finishes without making any assertion and FailsOnNoAsserts is set.
  /// </summary>
  ENoAssertionsMade = class(ETestFailure);

  /// <summary>
  ///   Raised by the runner when no test fixtures have been registered.
  /// </summary>
  ENoTestsRegistered = class(ETestFrameworkException);
  /// <summary>
  ///   Raised when the command line, or a run-list file it names, is invalid.
  /// </summary>
  ECommandLineError = class(ETestFrameworkException);

implementation

uses
  DUnitX.ResStrs;

constructor ETestFailureStrCompare.Create(const aExpected, aActual, aMessage : string; const aFormat : TDUnitXComparableFormatClass);
begin
  FExpected := aExpected;
  FActual := aActual;
  FMsg := aMessage;
  FFormat := aFormat;
  inherited Create({$IFDEF USE_NS}System.{$ENDIF}SysUtils.Format(SNotEqualErrorStr, [aExpected, aActual, aMessage]));
end;

end.

