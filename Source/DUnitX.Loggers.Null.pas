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

unit DUnitX.Loggers.Null;

interface

uses
  DUnitX.TestFramework;

type
  /// <summary>
  ///   Base class for loggers that need only some of the <c>ITestLogger</c> events: every event is implemented as a
  ///   virtual no-op, so a descendant overrides just the ones it cares about.
  /// </summary>
  TDUnitXNullLogger = class(TInterfacedObject, ITestLogger)
  protected
    /// <summary>Called before a test's setup runs. Does nothing here.</summary>
    /// <param name="threadId">The thread running the test.</param>
    /// <param name="Test">The test about to begin.</param>
    procedure OnBeginTest(const threadId : TThreadID; const Test : ITestInfo); virtual;
    /// <summary>Called after a fixture's setup method has run. Does nothing here.</summary>
    /// <param name="threadId">The thread running the fixture.</param>
    /// <param name="fixture">The fixture whose setup finished.</param>
    procedure OnEndSetupFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo); virtual;
    /// <summary>Called after a test's setup method has run. Does nothing here.</summary>
    /// <param name="threadId">The thread running the test.</param>
    /// <param name="Test">The test whose setup finished.</param>
    procedure OnEndSetupTest(const threadId : TThreadID; const Test : ITestInfo); virtual;
    /// <summary>Called after a fixture's teardown method has run. Does nothing here.</summary>
    /// <param name="threadId">The thread running the fixture.</param>
    /// <param name="fixture">The fixture whose teardown finished.</param>
    procedure OnEndTearDownFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo); virtual;
    /// <summary>Called after a test's teardown method has run. Does nothing here.</summary>
    /// <param name="threadId">The thread running the test.</param>
    /// <param name="Test">The test whose teardown finished.</param>
    procedure OnEndTeardownTest(const threadId : TThreadID; const Test : ITestInfo); virtual;
    /// <summary>Called when a test has finished, whatever its outcome. Does nothing here.</summary>
    /// <param name="threadId">The thread that ran the test.</param>
    /// <param name="Test">The result of the finished test.</param>
    procedure OnEndTest(const threadId : TThreadID; const Test : ITestResult); virtual;
    /// <summary>Called when every test in a fixture has finished. Does nothing here.</summary>
    /// <param name="threadId">The thread that ran the fixture.</param>
    /// <param name="results">The fixture's aggregated results.</param>
    procedure OnEndTestFixture(const threadId : TThreadID; const results : IFixtureResult); virtual;
    /// <summary>Called just before a test method itself executes. Does nothing here.</summary>
    /// <param name="threadId">The thread running the test.</param>
    /// <param name="Test">The test about to execute.</param>
    procedure OnExecuteTest(const threadId : TThreadID; const Test : ITestInfo); virtual;
    /// <summary>Called when a test or the framework writes a log message. Does nothing here.</summary>
    /// <param name="logType">The severity of the message.</param>
    /// <param name="msg">The message text.</param>
    procedure OnLog(const logType : TLogLevel; const msg : string); virtual;
    /// <summary>Called before a fixture's setup method runs. Does nothing here.</summary>
    /// <param name="threadId">The thread running the fixture.</param>
    /// <param name="fixture">The fixture being set up.</param>
    procedure OnSetupFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo); virtual;
    /// <summary>Called before a test's setup method runs. Does nothing here.</summary>
    /// <param name="threadId">The thread running the test.</param>
    /// <param name="Test">The test being set up.</param>
    procedure OnSetupTest(const threadId : TThreadID; const Test : ITestInfo); virtual;
    /// <summary>Called when a fixture starts, before its setup. Does nothing here.</summary>
    /// <param name="threadId">The thread running the fixture.</param>
    /// <param name="fixture">The fixture starting.</param>
    procedure OnStartTestFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo); virtual;
    /// <summary>Called before a fixture's teardown method runs. Does nothing here.</summary>
    /// <param name="threadId">The thread running the fixture.</param>
    /// <param name="fixture">The fixture being torn down.</param>
    procedure OnTearDownFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo); virtual;
    /// <summary>Called before a test's teardown method runs. Does nothing here.</summary>
    /// <param name="threadId">The thread running the test.</param>
    /// <param name="Test">The test being torn down.</param>
    procedure OnTeardownTest(const threadId : TThreadID; const Test : ITestInfo); virtual;
    /// <summary>Called when a test raised an unexpected exception. Does nothing here.</summary>
    /// <param name="threadId">The thread that ran the test.</param>
    /// <param name="Error">The error result, with the exception details.</param>
    procedure OnTestError(const threadId : TThreadID; const Error : ITestError); virtual;
    /// <summary>Called when a test failed an assertion. Does nothing here.</summary>
    /// <param name="threadId">The thread that ran the test.</param>
    /// <param name="Failure">The failure result, with the assertion message.</param>
    procedure OnTestFailure(const threadId : TThreadID; const Failure : ITestError); virtual;
    /// <summary>Called when a test passed its assertions but leaked memory. Does nothing here.</summary>
    /// <param name="threadId">The thread that ran the test.</param>
    /// <param name="Test">The leaking test's result.</param>
    procedure OnTestMemoryLeak(const threadId : TThreadID; const Test : ITestResult); virtual;
    /// <summary>Called when a test was ignored. Does nothing here.</summary>
    /// <param name="threadId">The thread that would have run the test.</param>
    /// <param name="AIgnored">The ignored test's result, carrying the reason.</param>
    procedure OnTestIgnored(const threadId : TThreadID; const AIgnored : ITestResult); virtual;
    /// <summary>Called when a test passed. Does nothing here.</summary>
    /// <param name="threadId">The thread that ran the test.</param>
    /// <param name="Test">The passing test's result.</param>
    procedure OnTestSuccess(const threadId : TThreadID; const Test : ITestResult); virtual;
    /// <summary>Called once when the whole run has finished. Does nothing here.</summary>
    /// <param name="RunResults">The results of the whole run.</param>
    procedure OnTestingEnds(const RunResults : IRunResults); virtual;
    /// <summary>Called once before the first fixture runs. Does nothing here.</summary>
    /// <param name="threadId">The thread starting the run.</param>
    /// <param name="testCount">The total number of tests found.</param>
    /// <param name="testActiveCount">The number of tests that will actually run (after filtering and ignores).</param>
    procedure OnTestingStarts(const threadId : TThreadID; testCount, testActiveCount : Cardinal); virtual;
  end;

implementation

{ TDUnitXNullLogger }

procedure TDUnitXNullLogger.OnBeginTest(const threadId : TThreadID; const Test : ITestInfo);
begin

end;

procedure TDUnitXNullLogger.OnEndSetupFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
begin

end;

procedure TDUnitXNullLogger.OnEndSetupTest(const threadId : TThreadID; const Test : ITestInfo);
begin

end;

procedure TDUnitXNullLogger.OnEndTearDownFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
begin

end;

procedure TDUnitXNullLogger.OnEndTeardownTest(const threadId : TThreadID; const Test : ITestInfo);
begin

end;

procedure TDUnitXNullLogger.OnEndTest(const threadId : TThreadID; const Test : ITestResult);
begin

end;

procedure TDUnitXNullLogger.OnEndTestFixture(const threadId : TThreadID; const results : IFixtureResult);
begin

end;

procedure TDUnitXNullLogger.OnExecuteTest(const threadId : TThreadID; const Test : ITestInfo);
begin

end;

procedure TDUnitXNullLogger.OnLog(const logType : TLogLevel; const msg : string);
begin

end;

procedure TDUnitXNullLogger.OnSetupFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
begin

end;

procedure TDUnitXNullLogger.OnSetupTest(const threadId : TThreadID; const Test : ITestInfo);
begin

end;

procedure TDUnitXNullLogger.OnStartTestFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
begin

end;

procedure TDUnitXNullLogger.OnTearDownFixture(const threadId : TThreadID; const fixture : ITestFixtureInfo);
begin

end;

procedure TDUnitXNullLogger.OnTeardownTest(const threadId : TThreadID; const Test : ITestInfo);
begin

end;

procedure TDUnitXNullLogger.OnTestError(const threadId : TThreadID; const Error : ITestError);
begin

end;

procedure TDUnitXNullLogger.OnTestFailure(const threadId : TThreadID; const Failure : ITestError);
begin

end;

procedure TDUnitXNullLogger.OnTestIgnored(const threadId : TThreadID; const AIgnored : ITestResult);
begin

end;

procedure TDUnitXNullLogger.OnTestingEnds(const RunResults : IRunResults);
begin

end;

procedure TDUnitXNullLogger.OnTestingStarts(const threadId : TThreadID; testCount, testActiveCount : Cardinal);
begin

end;

procedure TDUnitXNullLogger.OnTestMemoryLeak(const threadId : TThreadID; const Test : ITestResult);
begin

end;

procedure TDUnitXNullLogger.OnTestSuccess(const threadId : TThreadID; const Test : ITestResult);
begin

end;

end.

