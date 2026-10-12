unit NonNamespacedExample;

interface

uses
  DUnitX.TestFramework;

type
 {$M+}
  /// <summary>
  ///   Example fixture in a unit whose name has no dotted namespace, showing such units are discovered and named
  ///   correctly.
  /// </summary>
  [TestFixture]
  TNonNamespaceTest = class
  public
    /// <summary>
    ///   Always passes through Assert.Pass; proves a fixture from a non-namespaced unit is registered and run.
    /// </summary>
    [Test]
    procedure PassingTest;
  end;

implementation


{ TNonNamespaceTest }

procedure TNonNamespaceTest.PassingTest;
begin
   Assert.Pass;
end;


initialization
  TDUnitX.RegisterTestFixture(TNonNamespaceTest);
end.
