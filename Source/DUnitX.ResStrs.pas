{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2017 Vincent Parrett & Contributors               }
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
{ Resource strings contributed by Embarcadero                               }
{***************************************************************************}

unit DUnitX.ResStrs;

interface

resourcestring
  /// <summary>Status text shown when a test run has finished.</summary>
  STestRunComplete  = 'Test Run Complete';

  /// <summary>Assert failure: Extended values differ. Args: expected, actual, message.</summary>
  SUnexpectedErrorExt = 'Expected [%g] but got [%g] %s';
  /// <summary>Assert error: a floating-point comparison was given a negative tolerance. Args: tolerance, message.</summary>
  SNegativeTolerance = 'tolerance [%g] cannot be negative %s';
  /// <summary>Assert failure: integer values differ. Args: expected, actual, message.</summary>
  SUnexpectedErrorInt = 'Expected [%d] but got [%d] %s';
  /// <summary>Assert failure: string values differ. Args: expected, actual, message.</summary>
  SUnexpectedErrorStr = 'Expected [%s] but got [%s] %s';
  /// <summary>Assert failure: Double values differ. Args: expected, actual, message.</summary>
  SUnexpectedErrorDbl = 'Expected [%g] but got [%g] %s';
  /// <summary>Assert failure: GUIDs differ. Args: expected, actual, message.</summary>
  SUnexpectedErrorGUID = 'Expected [%s] but got [%s] %s';
  /// <summary>Assert failure: stream contents differ. Arg: message.</summary>
  SUnexpectedErrorStream = 'Streams are not equal %s';
  /// <summary>Message of ETestFailureStrCompare: strings differ. Args: expected, actual, message.</summary>
  SNotEqualErrorStr = 'Expected [%s] but got [%s] %s';
  /// <summary>Assert failure prefix: two memory blocks differ.</summary>
  SMemoryValuesNotEqual = 'Memory values are not equal. ';
  /// <summary>Assert failure: a file expected to exist does not. Arg: file name.</summary>
  SFileDoesNotExist = 'File [%s] does not exist';
  /// <summary>Assert failure: a file expected not to exist does. Arg: file name.</summary>
  SFileDoesExist    = 'File [%s] does exist';
  /// <summary>Assert.AreNotEqual failure: Extended values are equal. Args: expected, actual, message.</summary>
  SEqualsErrorExt   = 'Expected [%g] equals actual [%g] %s';
  /// <summary>Assert.AreNotEqual failure: strings are equal. Args: expected, actual, message.</summary>
  SEqualsErrorStr   = 'Expected [%s] equals actual [%s] %s';
  /// <summary>Assert.AreNotEqual failure: integers are equal. Args: expected, actual, message.</summary>
  SEqualsErrorInt   = 'Expected [%d] equals actual [%d] %s';
  /// <summary>Assert.AreNotEqual failure: Double values are equal. Args: expected, actual, message.</summary>
  SEqualsErrorDbl   = 'Expected [%g] equals actual [%g] %s';
  /// <summary>Assert.AreNotSame failure: the two object references are the same. Args: expected, actual, message.</summary>
  SEqualsErrorObj   = 'Object [%s] equals object [%s] %s';
  /// <summary>Assert.AreNotEqual failure: GUIDs are equal. Args: expected, actual, message.</summary>
  SEqualsErrorGUID  = 'Expected [%s] equals actual [%s] %s';
  /// <summary>Assert.AreNotEqual failure: stream contents are equal. Arg: message.</summary>
  SEqualsErrorStream = 'Streams are equal %s';
  /// <summary>Assert.AreNotSame failure: the two interface references are the same. Arg: message.</summary>
  SEqualsErrorIntf  = 'references are the same. %s';
  /// <summary>Assert failure prefix: two memory blocks expected to differ are equal.</summary>
  SMemoryValuesEqual = 'Memory values are equal. ';
  /// <summary>Assert.AreSame failure: the two interface references differ. Arg: message.</summary>
  SNotEqualErrorIntf = 'references are Not the same. %s';
  /// <summary>Assert.AreSame failure: the two object references differ. Args: expected, actual, message.</summary>
  SNotEqualErrorObj = 'Object [%s] does not equal object [%s] %s';
  /// <summary>Assert failure: arrays have different lengths. Args: expected length, actual length, message.</summary>
  SArraysHaveDifferentLength = 'Arrays have different length. Expected [%d] but got [%d] %s';
  /// <summary>Assert failure: arrays differ at an element. Args: index, expected, actual, message.</summary>
  SArraysAreDifferent = 'Arrays are different at position [%d]. Expected [%s] but got [%s] %s';
  /// <summary>Assert.Contains failure: the list lacks the value. Args: value, message.</summary>
  SValueNotInList   = 'List does not contain value %s. %s';
  /// <summary>Assert.DoesNotContain failure: the list contains the value. Args: value, message.</summary>
  SValueInList      = 'List contains value %s. %s';
  /// <summary>Assert.Implements failure: the value does not implement the interface. Args: interface name, message.</summary>
  SIntfNotImplemented = 'value does not implement %s. %s';
  /// <summary>Assert.IsEmpty failure: the list has items. Arg: message.</summary>
  SListNotEmpty     = 'List is Not Empty. %s';
  /// <summary>Assert.IsEmpty failure: the string has characters. Arg: message.</summary>
  SStrNotEmpty      = 'String is Not Empty. %s';
  /// <summary>Assert.IsEmpty failure: the variant is not empty. Arg: message.</summary>
  SVarNotEmpty      = 'Variant is Not Empty. %s';
  /// <summary>Assert.IsFalse failure: the condition is True. Arg: message.</summary>
  SIsFalseError     = 'Condition is True when False expected. %s';
  /// <summary>Assert.IsNotEmpty failure: the list is empty. Arg: message.</summary>
  SListEmpty        = 'List is Empty when Not Empty expected. %s';
  /// <summary>Assert.IsNotEmpty failure: the string is empty. Arg: message.</summary>
  SStrEmpty         = 'String is Empty. %s';
  /// <summary>Assert.IsNotEmpty failure: the variant is empty. Arg: message.</summary>
  SVarEmpty         = 'Variant is Empty. %s';
  /// <summary>Assert.IsNotNull failure: the interface is nil. Arg: message.</summary>
  SIntfNil          = 'Interface is Nil when Not Nil expected. %s';
  /// <summary>Assert.IsNotNull failure: the pointer is nil. Arg: message.</summary>
  SPointerNil       = 'Pointer is Nil when Not Nil expected. %s';
  /// <summary>Assert.IsNotNull failure: the object is nil. Arg: message.</summary>
  SObjNil           = 'Object is Nil when Not Nil expected. %s';
  /// <summary>Assert.IsNotNull failure: the variant is Null. Arg: message.</summary>
  SVariantNull      = 'Variant is Null when Not Null expected. %s';
  /// <summary>Assert.IsNull failure: the variant is not Null. Arg: message.</summary>
  SVariantNotNull   = 'Variant is Not Null when Null expected. [%s]';
  /// <summary>Assert.IsNull failure: the interface is not nil. Arg: message.</summary>
  SIntfNotNil       = 'Interface is Not Nil when Nil expected. [%s]';
  /// <summary>Assert.IsNull failure: the object is not nil. Arg: message.</summary>
  SObjNotNil        = 'Object is Not Nil when Nil expected. [%s]';
  /// <summary>Assert.IsNull failure: the pointer is not nil. Arg: message.</summary>
  SPointerNotNil    = 'Pointer is Not Nil when Nil expected. [%s]';
  /// <summary>Assert.IsTrue failure: the condition is False. Arg: message.</summary>
  SIsTrueError      = 'Condition is False when True expected. [%s]';
  /// <summary>Command-line error: a category expression with a '(' and no matching ')'. Arg: the expression.</summary>
  SCategoryMissingParenthesis = 'Category expression "%s" has a "(" without its closing ")".';
  /// <summary>Command-line error: a bare argument that is not an .xml file name. Arg: the argument.</summary>
  SBareArgumentNotXmlFile = '"%s" is not an .xml file name. A bare argument names the XML output file; to run ' +
    'particular tests use --run:<name>.';
  /// <summary>Failure raised by Assert.IsType&lt;T&gt;, which can never fail, steering the caller to InheritsFrom or Implements.</summary>
  SIsTypeCannotCheck = 'Assert.IsType<T> compares a value with its own declared type, so it cannot fail and checks ' +
    'nothing. Use Assert.InheritsFrom or Assert.Implements.';
  /// <summary>WillNotRaise/WillNotRaiseAny failure: the method raised an Exception. Args: class, exception message (caller message appended).</summary>
  SUnexpectedException = 'Method raised [%s] was expecting not to raise Any exception. %s';
  /// <summary>Assert.WillNotRaiseAny failure for a raised object not derived from Exception. Arg: class (caller message appended).</summary>
  SUnexpectedExceptionAlt = 'Method raised [%s] was expecting not to raise Any exception.';
  /// <summary>Prefix for a failure naming the class of the exception a method raised.</summary>
  SMethodRaisedException = 'Method raised an exception of type : ';
  /// <summary>Assert.WillNotRaiseWithMessage failure: the forbidden exception and message were raised. Args: class, exception message, message.</summary>
  SMethodRaisedExceptionMessage = 'Exception [%s] was raised with message [%s]. %s';
  /// <summary>Assert.WillNotRaiseDescendant failure: forbidden class or a descendant was raised. Args: raised, forbidden, exception message, message.</summary>
  SMethodRaisedExceptionAlt = 'Method raised [%s] was expecting not to raise [%s] %s. %s';
  /// <summary>Assert.WillRaise failure: the method raised nothing.</summary>
  SNoException      = 'Method did not throw any exceptions.';
  /// <summary>Assert.WillRaiseWithMessage failure: the exception message differs. Args: class, actual message, expected message, message.</summary>
  SUnexpectedExceptionMessage = 'Exception [%s] was raised with message [%s] was expecting [%s] %s';
  /// <summary>Assert.WillRaise* failure: the wrong exception class was raised. Args: raised class, expected class, exception message.</summary>
  SCheckExceptionClassError = 'Method raised [%s] was expecting [%s]. %s';
  /// <summary>Assert.WillRaiseDescendant failure: the raised class is not a descendant. Args: raised class, expected base, exception message.</summary>
  SCheckExceptionClassDescError = 'Method raised [%s] was expecting a descendant of [%s]. %s';
  /// <summary>Assert.Contains failure: the string lacks the substring. Args: string, substring, message.</summary>
  SStrDoesNotContain = '[%s] does not contain [%s] %s';
  /// <summary>Assert.DoesNotContain failure: the string contains the substring. Args: string, substring, message.</summary>
  SStrContains      = '[%s] contains [%s] %s';
  /// <summary>Assert.EndsWith failure. Args: string, expected ending, message.</summary>
  SStrDoesNotEndWith = '[%s] does not end with [%s] %s';
  /// <summary>Assert.IsMatch failure: the string does not match the regular expression. Args: string, pattern, message.</summary>
  SStrDoesNotMatch  = '[%s] does not match [%s] %s';
  /// <summary>Assert error: an empty substring was passed to StartsWith/EndsWith.</summary>
  SStrCannotBeEmpty = 'subString cannot be empty';
  /// <summary>Assert.StartsWith failure. Args: string, expected start, message.</summary>
  SStrDoesNotStartWith = '[%s] does not start with [%s] %s';
  /// <summary>Failure prefix: two string lists have different line counts.</summary>
  SNumberOfStringsNotEqual = 'Number of strings is not equal';
  /// <summary>Failure prefix from the string diff: the first position at which two strings differ. Arg: position.</summary>
  SDiffAtPosition   = 'Difference at position %d';
  /// <summary>Assert.CheckExpectation failure: the expectation text is not empty, i.e. an expectation was not met. Args: expectation text, message.</summary>
  SCheckEmptyExpectation = 'Expectation not achieved [%s] %s';

  /// <summary>Command-line error: a boolean option was given a non-boolean value.</summary>
  SInvalidValueBool = 'Invalid value, not boolean';
  /// <summary>Command-line error: an option was registered with an unsupported value type.</summary>
  SInvalidOptionType = 'Invalid option type - only string, integer, float, boolean, enum and sets are supported';
  /// <summary>Command-line error prefix: an enumerated option was given an unknown value.</summary>
  SInvalidEnum      = 'Invalid enum value : ';
  /// <summary>Command-line error: an option has an invalid type.</summary>
  SInvalidOpt       = 'invalid option type';

  /// <summary>Command-line registration error: a named option was registered without a name.</summary>
  SNameRequired     = 'Name required - use RegisterUnamed to register unamed options';
  /// <summary>Command-line registration error: the option name is already registered. Arg: option name.</summary>
  SOptionAlreadyRegistered = 'Options : %s already registered';
  /// <summary>Command-line error prefix: an argument starts with an unrecognised option prefix.</summary>
  SUnknownOptionStart = 'Unknown option start : ';

  /// <summary>Command-line error: an option needs a :value but none was given. Arg: option name.</summary>
  SOptionExpectedValue = 'Option [%s] expected a following :value but none was found';
  /// <summary>Command-line error: the @parameter file is missing. Arg: file name.</summary>
  SParameterFileDoesNotExist = 'Parameter File [%s] does not exist';
  /// <summary>Command-line error prefix: reading an @parameter file failed. Arg: file name.</summary>
  SErrorParsingParameterFile = 'Error parsing parameter file [%s] : ';
  /// <summary>Command-line error prefix: assigning an option value failed. Args: option name, value.</summary>
  SErrorSettingOption = 'Error setting option : %s to %s : ';
  /// <summary>Command-line error prefix: an option name is not registered.</summary>
  SUnknownCommandLineOption = 'Unknown command line option : ';
  /// <summary>Command-line error: a required option is missing. Arg: option name.</summary>
  SOptionNotSpecified = 'Required option [%s] was not specified';

  /// <summary>Ignore reason recorded for a test whose Repeat count is 0.</summary>
  STestIgnoredRepeatSet = 'Repeat set to 0. Test ignored.';

  /// <summary>IoC error: the registered class does not implement the interface. Args: class, interface.</summary>
  SRegisteredImplementationError = 'The implementation registered (%s) does not implement %s';
  /// <summary>IoC error: an implementation with this type and name already exists. Args: type, name.</summary>
  SImplementationAlreadyRegistered = 'An implementation for type %s with name %s is already registered with IoC';
  /// <summary>IoC error: nothing is registered for the requested type. Arg: type.</summary>
  SNoImplementationRegistered = 'No implementation registered for type %s';
  /// <summary>IoC error: the activator delegate returned nil. Arg: type.</summary>
  SNoInstance       = 'The activator delegate failed to return an instance %s';
  /// <summary>IoC error: a registration has no activator delegate. Arg: type.</summary>
  SNoActivator      = 'The registration for %s has no activator';

  /// <summary>Error raised when no console writer is registered (DUnitX.Windows.Console not linked).</summary>
  SNoConsoleWriterClassRegistered =
    'No ConsoleWriter class is registered. You will need to include DUnitX.Windows.Console in your application';
  /// <summary>Console logger prefix written before a test runs.</summary>
  SExecutingTest    = 'Executing Test : ';
  /// <summary>Console logger prefix written before a fixture setup method runs.</summary>
  SRunningFixtureSetup = 'Running Fixture Setup Method : ';
  /// <summary>Console logger prefix written before a test's setup runs.</summary>
  SRunningSetup     = 'Running Setup for : ';
  /// <summary>Logger label prefix for a test name.</summary>
  STest             = 'Test : ';
  /// <summary>Logger label prefix for a fixture name.</summary>
  SFixture          = 'Fixture : ';
  /// <summary>Logger text for a successful step.</summary>
  SSuccess          = 'Success';
  /// <summary>Console logger prefix written before a fixture teardown method runs.</summary>
  SRunningFixtureTeardown = 'Running Fixture Teardown Method : ';
  /// <summary>Console logger prefix written before a test's teardown runs.</summary>
  SRunningTestTeardown = 'Running Teardown for Test : ';
  /// <summary>Console logger text written when the run is finished.</summary>
  SDoneTesting      = 'Done testing.';
  /// <summary>Summary line: number of tests found. Arg: count.</summary>
  STestsFound       = 'Tests Found   : %d';
  /// <summary>Summary line: number of tests ignored. Arg: count.</summary>
  STestsIgnored     = 'Tests Ignored : %d';
  /// <summary>Summary line: number of tests passed. Arg: count.</summary>
  STestsPassed      = 'Tests Passed  : %d';
  /// <summary>Summary line: number of tests that leaked memory. Arg: count.</summary>
  STestsLeaked      = 'Tests Leaked  : %d';
  /// <summary>Summary line: number of tests failed. Arg: count.</summary>
  STestsFailed      = 'Tests Failed  : %d';
  /// <summary>Summary line: number of tests that raised an unexpected error. Arg: count.</summary>
  STestsErrored     = 'Tests Errored : %d';
  /// <summary>Summary line: number of tests with warnings. Arg: count.</summary>
  STestsWarning     = 'Tests with Warnings : %d';
  /// <summary>Summary section heading for failed tests.</summary>
  SFailingTests     = 'Failing Tests';
  /// <summary>Summary label prefix for a failure or error message.</summary>
  SMessage          = '  Message: ';
  /// <summary>Summary section heading for errored tests.</summary>
  STestsWithErrors  = 'Tests With Errors';
  /// <summary>Summary section heading for tests that leaked memory.</summary>
  STestsWithLeak    = 'Tests With Memory Leak';
  /// <summary>Logger banner written at the start of a run. Arg: executable file name.</summary>
  SStartingTests    = 'DUnitX - [%s] - Starting Tests.';
  /// <summary>VCL GUI runner caption. Arg: executable file name.</summary>
  SApplicationName  = 'DUnitX - [%s]';

  /// <summary>Command-line usage heading. Arg: executable name.</summary>
  SUsage            = 'Usage : %s options';
  /// <summary>Command-line usage heading for the option list.</summary>
  SOptions          = ' Options :';
  /// <summary>Error: no test runner is associated with the current thread.</summary>
  SNoRunner         = 'No Runner found for current thread';

  /// <summary>Leak report: bytes leaked by setup/teardown. Arg: byte count.</summary>
  SSetupTeardownBytesLeaked = '%d bytes were leaked in the setup/teardown methods';
  /// <summary>Leak report: bytes leaked by the test method. Arg: byte count.</summary>
  STestBytesLeaked  = '%d bytes were leaked in the test method';
  /// <summary>Leak report: bytes leaked across setup, test and teardown. Arg: byte count.</summary>
  SSetupTestTeardownBytesLeaked = '%d bytes were leaked in the setup/test/teardown methods';
  /// <summary>Logger prefix for a passed test.</summary>
  STestPassed       = 'Test Passed : ';
  /// <summary>Logger prefix for a failed test.</summary>
  STestFailed       = 'Test Failed : ';
  /// <summary>Logger prefix for a test that raised an unexpected error.</summary>
  STestError        = 'Test Error : ';
  /// <summary>Logger prefix for an ignored test.</summary>
  STestIgnored      = 'Test Ignored : ';
  /// <summary>Logger prefix for a test that leaked memory.</summary>
  STestLeaked       = 'Test Leaked Memory : ';
  /// <summary>Error prefix: the OnEndSetup event handler raised.</summary>
  SOnEndSetupEventError = 'Error in OnEndSetupEvent : ';
  /// <summary>Error prefix: logging an error from the OnEndSetupTest event failed.</summary>
  SOnEndSetupTestLogError = 'unable to log error in OnEndSetupTest event : ';
  /// <summary>Message of ENoTestsRegistered: no fixtures were registered.</summary>
  SNoFixturesFound  = 'No Test Fixtures found';
  /// <summary>Error: a fixture setup method raised. Args: fixture, error.</summary>
  SFixtureSetupError = 'Error in Fixture Setup. Fixture: %s Error: %s';
  /// <summary>Logger text: the fixture is skipped after its setup failed.</summary>
  SSkippingFixture  = 'Skipping Fixture.';
  /// <summary>Error: a fixture teardown method raised. Args: fixture, error.</summary>
  SFixtureTeardownError = 'Error in Fixture TearDown. Fixture: %s Error: %s';
  /// <summary>Message of ENoAssertionsMade: the test made no assertions.</summary>
  SNoAssertions     = 'No assertions were made during the test';
  /// <summary>Error: a test does not support ITestExecute. Arg: test name.</summary>
  SITestExecuteNotSupported = '%s does not support ITestExecute';
  /// <summary>Error: a test case supplies the wrong number of values. Args: case name, value count, parameter count.</summary>
  STestCaseValueCount = 'Test case [%s] supplies %d value(s) but the method has %d parameter(s)';
  /// <summary>Command-line error: an @parameter file includes itself. Arg: file name.</summary>
  SParameterFileIncludesItself = 'Parameter File [%s] includes itself';
  /// <summary>Error: a test case value cannot be converted to the parameter type. Args: case, value, parameter, type, detail.</summary>
  STestCaseValueConvert = 'Test case [%s]: value [%s] cannot be converted to parameter [%s] of type %s%s';
  /// <summary>Error: a TestCaseProvider attribute names an unregistered provider. Args: provider name, method.</summary>
  SUnknownTestCaseProvider = 'Test case provider [%s] used by %s is not registered';
  /// <summary>Error: creating the fixture instance raised. Args: fixture, error.</summary>
  SFixtureCreateError = 'Error creating Fixture. Fixture: %s Error: %s';
  /// <summary>Warning: a [SetupFixture] method is not run because the fixture's parameterless constructor is its fixture setup. Args: method, fixture.</summary>
  SSetupFixtureNotRun = '[SetupFixture] %s of fixture %s is not run: the fixture''s parameterless constructor is its fixture setup';
  /// <summary>Suffix added when teardown also failed after a test failure. Arg: teardown error.</summary>
  STearDownAlsoFailed = 'TearDown also failed: %s';
  /// <summary>Summary text: no tests ran, so the run is not reported as passed.</summary>
  SNoTestsExecuted  = 'No tests were executed, so the run is not reported as passed.';

  /// <summary>Error: TWeakReference was used with an object not derived from TWeakReferencedObject.</summary>
  SWeakReferenceError = 'TWeakReference can only be used with objects derived from TWeakReferencedObject';

  /// <summary>Failure message of Assert.NotImplemented.</summary>
  SNotImplemented   = 'Not Implemented!';

  /// <summary>Message of ETimedOut: the test exceeded its time limit.</summary>
  SOperationTimedOut = 'Operation Timed Out';

  /// <summary>VCL GUI runner message: no results are held for the selected test.</summary>
  SCouldNotFindResultsForTest = 'Could not find results for test.';

  /// <summary>VCL GUI runner status: no run in progress.</summary>
  SGUIStatusIdle    = 'Idle';
  /// <summary>VCL GUI runner status during a run. Args: current test number, total tests.</summary>
  SGUIStatusRunning = 'Running (%d of %d), Esc to stop';
  /// <summary>VCL GUI runner status after the user asked to stop the run.</summary>
  SGUIStatusStopping = 'Stopping after the current test...';
  /// <summary>VCL GUI runner status after the user closed the form during a run.</summary>
  SGUIStatusClosing = 'Stopping after the current test, then closing...';
  /// <summary>VCL GUI runner error: a result could not be displayed. Args: test name, error.</summary>
  SGUIResultDisplayError = 'Could not display the result of %s: %s';
  /// <summary>VCL GUI runner warning: tests omitted because their full names duplicate another. Args: count, first name.</summary>
  SGUIDuplicateTestNames = '%d test(s) not listed because another test has the same full name, first: %s';
  /// <summary>VCL GUI runner error: Beyond Compare is not installed in any known location.</summary>
  SGUIBeyondCompareNotFound = 'Could not find Beyond Compare in any known path.';
  /// <summary>VCL GUI runner error: Beyond Compare could not be started. Args: path, error.</summary>
  SGUIBeyondCompareNotStarted = 'Could not start Beyond Compare (%s): %s';
  /// <summary>VCL GUI runner label for the expected text in a comparison.</summary>
  SGUICompareExpected = 'Expected';
  /// <summary>VCL GUI runner label for the actual text in a comparison.</summary>
  SGUICompareActual = 'Actual';

  /// <summary>Error: no fixture provider is registered.</summary>
  SNoFixtureProvider = 'No FixtureProvider registered';

implementation

end.

