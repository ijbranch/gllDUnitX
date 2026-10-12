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

unit DUnitX.InternalInterfaces;

interface

{$I DUnitX.inc}

uses
{$IFDEF USE_NS}
  System.TimeSpan,
{$ELSE}
  TimeSpan,
{$ENDIF}
  DUnitX.Types,
  DUnitX.Generics,
  DUnitX.Extensibility,
  DUnitX.TestFrameWork;

type
  /// <summary>
  ///   Intended to let the runner store the outcome of a test on the test object itself.
  /// </summary>
  /// <remarks>
  ///   These internal interfaces mirror the Info classes in the framework but expose what the runner needs at run
  ///   time. <c>TDUnitXTest.SetResult</c>, the only implementation, is empty.
  /// </remarks>
  ISetTestResult = interface
    ['{B50D50E9-3609-40BF-847D-53B5BF19B5C7}']
    /// <summary>
    ///   Stores the result of the test's latest run on the test.
    /// </summary>
    /// <param name="value">
    ///   The result to store.
    /// </param>
    procedure SetResult(const value : ITestResult);
  end;

  /// <summary>
  ///   Collects fixture and test results during a run; passed to <c>ITestExecute.Execute</c> and implemented by
  ///   <c>TDUnitXRunResults</c>.
  /// </summary>
  ITestExecuteContext = interface
    ['{DE4ADB3F-3B5B-4B90-8659-0BFA578977CC}']
    /// <summary>
    ///   Adds a fixture's result object to the run's list of fixture results.
    /// </summary>
    /// <param name="fixtureResult">
    ///   The fixture result to record.
    /// </param>
    procedure RecordFixture(const fixtureResult : IFixtureResult);
    /// <summary>
    ///   Counts a test result in the run totals and attaches it to its fixture's result.
    /// </summary>
    /// <param name="fixtureResult">
    ///   The result of the fixture the test belongs to.
    /// </param>
    /// <param name="testResult">
    ///   The test's result.
    /// </param>
    procedure RecordResult(const fixtureResult : IFixtureResult; const testResult : ITestResult);
    /// <summary>
    ///   Finishes the run: stamps the finish time and duration and rolls up every recorded fixture result.
    /// </summary>
    procedure RollupResults;
  end;

  /// <summary>
  ///   Placeholder for per-fixture execution state; it declares no members and nothing implements it.
  /// </summary>
  ITestFixtureContext = interface
    ['{C3B85C73-1FE8-4558-8AB0-7E8075821D35}']
  end;

  /// <summary>
  ///   Runs a single test against its fixture instance; implemented by the framework's test objects.
  /// </summary>
  ITestExecute = interface
    ['{C59443A9-8C7D-46CE-83A1-E40309A1B384}']
    /// <summary>
    ///   Invokes the test method on the current fixture instance.
    /// </summary>
    /// <param name="context">
    ///   The run's result-collection context.
    /// </param>
    procedure Execute(const context : ITestExecuteContext);
    /// <summary>
    ///   Rebinds the test's method to a newly created fixture instance.
    /// </summary>
    /// <param name="fixtureInstance">
    ///   The fixture object the test method is to be called on.
    /// </param>
    procedure UpdateInstance(const fixtureInstance : TObject);
  end;

  /// <summary>
  ///   A test execution that is one case of a parameterised test.
  /// </summary>
  ITestCaseExecute = interface(ITestExecute)
    ['{49781E22-C127-4BED-A9D5-84F9AAACE96C}']
    /// <summary>
    ///   Gives the name of the test case.
    /// </summary>
    /// <returns>
    ///   The case name.
    /// </returns>
    function GetCaseName : string;
  end;

  /// <summary>
  ///   Builds up a fixture result during a run; implemented by <c>TDUnitXFixtureResult</c> alongside the read-only
  ///   <c>IFixtureResult</c>.
  /// </summary>
  IFixtureResultBuilder = interface
    ['{2604E655-349D-4379-9796-1C708CAD7307}']
    /// <summary>
    ///   Adds a test result to this fixture's result list.
    /// </summary>
    /// <param name="AResult">
    ///   The test result to add.
    /// </param>
    procedure AddTestResult(const AResult : ITestResult);
    /// <summary>
    ///   Adds the result of a nested fixture as a child of this one.
    /// </summary>
    /// <param name="AFixtureResult">
    ///   The child fixture result.
    /// </param>
    procedure AddChild(const AFixtureResult : IFixtureResult);
    /// <summary>
    ///   Totals the counts, durations and pass state of this fixture and its children.
    /// </summary>
    procedure RollUpResults;
    // function Combine(const AFixtureResult : IFixtureResult) : IFixtureResult;
    // function AreEqual(const AFixtureResult : IFixtureResult) : boolean;
  end;

implementation

end.

