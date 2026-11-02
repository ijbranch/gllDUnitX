unit DUnitX.SingleNameSpace;

interface

{$I DUnitX.inc}

uses
  DUnitX.TestFramework,
  DUnitX.WeakReference;

type
  /// <summary>
  ///   Fixture registered from a unit whose name has a single namespace segment, so the runner's fixture-tree
  ///   building is exercised for a shallow unit name as well as the usual multi-segment ones.
  /// </summary>
  TSingleNamespaceTest = class
  public
    /// <summary>
    ///   Proves a fixture from a single-segment namespace is discovered and run; it sleeps 50 ms first so the
    ///   loggers have a non-zero duration to report.
    /// </summary>
    [Test]
    procedure ATest;
  end;

implementation

uses
  System.Classes;

{ TSingleNamespaceTest }

procedure TSingleNamespaceTest.ATest;
begin
  TThread.Sleep(50);

  Assert.IsTrue(true);
end;

initialization
  TDUnitX.RegisterTestFixture(TSingleNamespaceTest);
end.

