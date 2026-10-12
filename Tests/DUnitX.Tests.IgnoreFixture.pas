unit DUnitX.Tests.IgnoreFixture;

interface

uses
  DUnitX.TestFramework;

type
  /// <summary>
  ///   A whole fixture marked [Ignore]: every method raises, so the suite stays green only if the runner reports the
  ///   tests as ignored without calling any test, setup or teardown method.
  /// </summary>
  [TestFixture]
  [Ignore('Ignore complete Fixture.')]
  TIgnoredTest = class
  public
    /// <summary>
    ///   Per-test setup that must never run for an ignored fixture.
    /// </summary>
    /// <exception cref="Exception">
    ///   Always, so a call shows up as an error.
    /// </exception>
    [Setup]
    procedure Setup;
    /// <summary>
    ///   Fixture setup that must never run for an ignored fixture.
    /// </summary>
    /// <exception cref="Exception">
    ///   Always, so a call shows up as an error.
    /// </exception>
    [SetupFixture]
    procedure SetupFixture;
    /// <summary>
    ///   Per-test teardown that must never run for an ignored fixture.
    /// </summary>
    /// <exception cref="Exception">
    ///   Always, so a call shows up as an error.
    /// </exception>
    [Teardown]
    procedure Teardown;
    /// <summary>
    ///   Fixture teardown that must never run for an ignored fixture.
    /// </summary>
    /// <exception cref="Exception">
    ///   Always, so a call shows up as an error.
    /// </exception>
    [TeardownFixture]
    procedure TeardownFixture;
    /// <summary>
    ///   Proves a test in an ignored fixture is reported ignored, not run; it raises if called.
    /// </summary>
    /// <exception cref="Exception">
    ///   Always, so a call shows up as an error.
    /// </exception>
    [Test]
    procedure Test_A;
    /// <summary>
    ///   Second test in the ignored fixture, so the ignore covers more than the first test.
    /// </summary>
    /// <exception cref="Exception">
    ///   Always, so a call shows up as an error.
    /// </exception>
    [Test]
    procedure Test_B;
  end;

  /// <summary>
  ///   A fixture whose every test is [Ignore]d: proves the runner skips fixture and per-test setup and teardown when
  ///   no test in the fixture will actually run. Every method raises if called.
  /// </summary>
  [TestFixture]
  TNoActiveTests = class
  public
    /// <summary>
    ///   Per-test setup that must not run when all tests are ignored.
    /// </summary>
    /// <exception cref="Exception">
    ///   Always, so a call shows up as an error.
    /// </exception>
    [Setup]
    procedure Setup;
    /// <summary>
    ///   Fixture setup that must not run when no test is active.
    /// </summary>
    /// <exception cref="Exception">
    ///   Always, so a call shows up as an error.
    /// </exception>
    [SetupFixture]
    procedure SetupFixture;
    /// <summary>
    ///   Per-test teardown that must not run when all tests are ignored.
    /// </summary>
    /// <exception cref="Exception">
    ///   Always, so a call shows up as an error.
    /// </exception>
    [Teardown]
    procedure Teardown;
    /// <summary>
    ///   Fixture teardown that must not run when no test is active.
    /// </summary>
    /// <exception cref="Exception">
    ///   Always, so a call shows up as an error.
    /// </exception>
    [TeardownFixture]
    procedure TeardownFixture;
    /// <summary>
    ///   Proves an individually [Ignore]d test is not called; it raises if it is.
    /// </summary>
    /// <exception cref="Exception">
    ///   Always, so a call shows up as an error.
    /// </exception>
    [Test]
    [Ignore('Ignore Test.')]
    procedure IgnoredTest_A;
    /// <summary>
    ///   Second ignored test, so the fixture has no active test at all.
    /// </summary>
    /// <exception cref="Exception">
    ///   Always, so a call shows up as an error.
    /// </exception>
    [Test]
    [Ignore('Ignore Test.')]
    procedure IgnoredTest_B;
  end;

implementation

uses
  System.SysUtils;

{ TIgnoredTest }

procedure TIgnoredTest.Setup;
begin
  raise Exception.Create('Setup');
end;

procedure TIgnoredTest.SetupFixture;
begin
  raise Exception.Create('SetupFixture');
end;

procedure TIgnoredTest.Teardown;
begin
  raise Exception.Create('Teardown');
end;

procedure TIgnoredTest.TeardownFixture;
begin
  raise Exception.Create('TeardownFixture');
end;

procedure TIgnoredTest.Test_A;
begin
  raise Exception.Create('Test_A');
end;

procedure TIgnoredTest.Test_B;
begin
  raise Exception.Create('Test_B');
end;

{ TNoActiveTests }

procedure TNoActiveTests.IgnoredTest_A;
begin
  raise Exception.Create('IgnoredTest_A');
end;

procedure TNoActiveTests.IgnoredTest_B;
begin
  raise Exception.Create('IgnoredTest_B');
end;

procedure TNoActiveTests.Setup;
begin
  raise Exception.Create('Setup');
end;

procedure TNoActiveTests.SetupFixture;
begin
  raise Exception.Create('SetupFixture');
end;

procedure TNoActiveTests.Teardown;
begin
  raise Exception.Create('Teardown');
end;

procedure TNoActiveTests.TeardownFixture;
begin
  raise Exception.Create('TeardownFixture');
end;

initialization
  TDUnitX.RegisterTestFixture(TIgnoredTest);
  TDUnitX.RegisterTestFixture(TNoActiveTests);

end.
