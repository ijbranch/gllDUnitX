{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2012 Vincent Parrett                              }
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

unit DUnitX.Tests.MemoryLeaks;

interface

uses
  DUnitX.TestFramework;

type
{$M+}
  /// <summary>
  ///   Fixture marked [IgnoreMemoryLeaks]: its tests deliberately leak, to demonstrate that the fixture-level
  ///   setting suppresses leak reports and that a test-level attribute overrides it. The tests always pass; what
  ///   differs is whether a leak-reporting monitor flags them.
  /// </summary>
  [TestFixture]
  [IgnoreMemoryLeaks]
  TTestsNoMemoryLeaksReported = class
  published
    /// <summary>
    ///   Leaks 1024 bytes under the fixture's [IgnoreMemoryLeaks]; demonstrates the leak is not reported.
    /// </summary>
    [Test]
    procedure No_Reporting_Of_Memory_Leaks;
    /// <summary>
    ///   Leaks 512 bytes with [IgnoreMemoryLeaks(False)] on the test; demonstrates the test-level setting overrides
    ///   the fixture's, so the leak is reported.
    /// </summary>
    [Test]
    [IgnoreMemoryLeaks(False)]
    procedure Override_Reporting_Of_Memory_Leaks;
  end;

  /// <summary>
  ///   Fixture marked [IgnoreMemoryLeaks(False)], which reports all leaks - the same as not specifying the attribute
  ///   at all. Its tests deliberately leak and always pass.
  /// </summary>
  [TestFixture]
  [IgnoreMemoryLeaks(False)]
  TTestsMemoryLeaksReported = class
  published
    /// <summary>
    ///   Leaks 256 bytes with [IgnoreMemoryLeaks(True)] on the test; demonstrates the test-level setting suppresses
    ///   the report the fixture would otherwise make.
    /// </summary>
    [Test]
    [IgnoreMemoryLeaks(True)]
    procedure Override_No_Reporting_Of_Memory_Leaks;

    /// <summary>
    ///   Leaks 128 bytes with no test-level attribute; demonstrates the test inherits the fixture's setting, so the
    ///   leak is reported.
    /// </summary>
    [Test]
    procedure Reporting_Of_Memory_Leaks;
  end;

implementation

{ TTestsNoMemoryLeaksReported }

procedure TTestsNoMemoryLeaksReported.No_Reporting_Of_Memory_Leaks;
begin
  AllocMem(1024);
  Assert.Pass;
end;

procedure TTestsNoMemoryLeaksReported.Override_Reporting_Of_Memory_Leaks;
begin
  AllocMem(512);
  Assert.Pass;
end;

{ TTestsMemoryLeaksReported }

procedure TTestsMemoryLeaksReported.Override_No_Reporting_Of_Memory_Leaks;
begin
  AllocMem(256);
  Assert.Pass;
end;

procedure TTestsMemoryLeaksReported.Reporting_Of_Memory_Leaks;
begin
  AllocMem(128);
  Assert.Pass;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestsNoMemoryLeaksReported);
  TDUnitX.RegisterTestFixture(TTestsMemoryLeaksReported);

end.

