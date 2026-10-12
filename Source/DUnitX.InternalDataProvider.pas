unit DUnitX.InternalDataProvider;

interface

uses
  DUnitX.Types;

type
  /// <summary>
  ///   Supplies generated test cases for a test method marked with a <c>TestCaseProvider</c> attribute: how many cases
  ///   there are, what each is called, and the parameter values each one passes to the method.
  /// </summary>
  ITestDataProvider = interface
    ['{1BFC9318-AF52-41BB-82D4-58166429885A}']
    /// <summary>
    ///   Reports how many test cases the provider generates for a test method.
    /// </summary>
    /// <param name="methodName">
    ///   Name of the test method the cases are for.
    /// </param>
    /// <returns>
    ///   The number of cases; each is then requested by its zero-based case number.
    /// </returns>
    function GetCaseCount(const methodName : string) : integer;
    /// <summary>
    ///   Gives the display name of one generated test case.
    /// </summary>
    /// <param name="methodName">
    ///   Name of the test method the case belongs to.
    /// </param>
    /// <param name="caseNumber">
    ///   Zero-based index of the case, below <c>GetCaseCount</c>.
    /// </param>
    /// <returns>
    ///   The name shown for the case in results and loggers.
    /// </returns>
    function GetCaseName(const methodName : string; const caseNumber : integer) : string;
    /// <summary>
    ///   Gives the argument values one generated test case passes to the test method.
    /// </summary>
    /// <param name="methodName">
    ///   Name of the test method the case belongs to.
    /// </param>
    /// <param name="caseNumber">
    ///   Zero-based index of the case, below <c>GetCaseCount</c>.
    /// </param>
    /// <returns>
    ///   The arguments, in the order of the method's parameters.
    /// </returns>
    function GetCaseParams(const methodName : string; const caseNumber : integer) : TValuearray;
  end;

  /// <summary>
  ///   Abstract base for test-case providers. Descend from it, implement the three case methods, and register the
  ///   class with <c>TestDataProviderManager</c> so a <c>TestCaseProvider</c> attribute can name it.
  /// </summary>
  TTestDataProvider = class(TInterfacedObject, ITestDataProvider)
  public
    /// <summary>
    ///   Creates the provider; virtual so the framework can construct a registered descendant through its class
    ///   reference.
    /// </summary>
    constructor Create; virtual; abstract;
    /// <summary>
    ///   Reports how many test cases the provider generates for a test method.
    /// </summary>
    /// <param name="methodName">
    ///   Name of the test method the cases are for.
    /// </param>
    /// <returns>
    ///   The number of cases.
    /// </returns>
    function GetCaseCount(const methodName : string) : integer; virtual; abstract;
    /// <summary>
    ///   Gives the display name of one generated test case.
    /// </summary>
    /// <param name="methodName">
    ///   Name of the test method the case belongs to.
    /// </param>
    /// <param name="caseNumber">
    ///   Zero-based index of the case.
    /// </param>
    /// <returns>
    ///   The name shown for the case in results and loggers.
    /// </returns>
    function GetCaseName(const methodName : string; const caseNumber : integer) : string; virtual; abstract;
    /// <summary>
    ///   Gives the argument values one generated test case passes to the test method.
    /// </summary>
    /// <param name="methodName">
    ///   Name of the test method the case belongs to.
    /// </param>
    /// <param name="caseNumber">
    ///   Zero-based index of the case.
    /// </param>
    /// <returns>
    ///   The arguments, in the order of the method's parameters.
    /// </returns>
    function GetCaseParams(const methodName : string; const caseNumber : integer) : TValuearray; virtual; abstract;
  end;

  /// <summary>
  ///   Class reference used to register and construct test-case providers.
  /// </summary>
  TTestDataProviderClass = class of TTestDataProvider;

implementation

end.

