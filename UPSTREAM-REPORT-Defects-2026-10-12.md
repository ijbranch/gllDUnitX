# DUnitX: defect report from a review of the framework, GUI runner and IDE expert

**To:** the DUnitX maintainers (VSoft Technologies)
**From:** Ian Branch (GITLAK Software), maintainer of a DUnitX fork
**Date:** 2026-10-12
**Against:** upstream `master` @ `1bdc297` (2026-10-09). All line numbers below are upstream's, at that commit.

---

## Summary

We reviewed the whole of `Source\`, the VCL GUI runner and the IDE expert. Every defect listed here is
**present in upstream `master`**: we checked each one against `1bdc297`, not only against our fork.

How each finding was established:

- **Reproduced** means we called the real `DUnitX.Assert.pas` / `DUnitX.Utils.pas` from a small probe program
  (Win64, and Win32 where it matters) and saw the result at run time.
- **Traced** means we followed the code path line by line but did not run it.

### Our environment, and what that means for these findings

We work in **Delphi 13 Florence (RAD Studio 37.0), VCL only, targeting Win32 and Win64 on Windows 11**.
Our fork removed the non-Windows units, FMX runners and pre-Delphi-13 project files. The review should
be read with that in mind:

- **What we ran:** the probes were compiled with the Delphi 13 compilers (dcc64, and dcc32 where noted) against
  the Delphi 13 RTL. Behaviour that depends on the RTL, such as `Compare_R8` / `Compare_R10` returning 0 for NaN
  (1.3), was observed on that RTL only.
- **What we did not build or run:** older Delphi versions, C++Builder, FMX, macOS, Linux, iOS and Android.
  Code inside `{$IFDEF}` branches for those targets was read, not compiled. Where a finding depends on which
  branch is active, the row says so. For example, 1.9 is in the non-`NEXTGEN` path; the `NEXTGEN` path uses
  `string.IndexOfAny` instead, and we did not test it.
- **What we did not drive:** the VCL GUI runner (section 4) and the IDE expert (section 5) were traced through
  the source, not exercised interactively.
- **Line numbers:** taken from `git show upstream/master:<file>` at `1bdc297`, not from our fork, whose files
  have moved.

A defect may therefore show up differently, or not at all, on a compiler, RTL or platform we do not use.

The findings are ordered by what matters most for a test framework: **a test that passes, or a run that goes
green, when it should fail**. Each one is a local fix. We are happy to send any of them as pull requests
with a failing test first, if that would help.

Section 6 lists fixes we already carry in our fork, which you may want to take.

---

## 1. A test passes, or a run goes green, when it should fail

| # | Where (upstream line) | Defect | Evidence |
|---|---|---|---|
| 1.1 | `DUnitX.Assert.pas:877` `Assert.IsEmpty(Variant)` | The condition is inverted. The code is `if VarIsEmpty(value) or VarIsNull(value) then FailFmt(SVarNotEmpty...)`. So `IsEmpty(Unassigned)` **fails** and `IsEmpty('abc')` **passes**. `IsNotEmpty(Variant)` (`:943`) fails only on Unassigned, so `IsNotEmpty(Null)` passes. No test covers either method. | Reproduced |
| 1.2 | `DUnitX.Assert.pas:1184` `Assert.WillNotRaiseDescendant(TTestMethod...)` | Forwards to `Assert.WillNotRaise`, which matches the exact class, instead of to `WillNotRaiseDescendant`. A method that raises a *descendant* of the named class passes. The `TProc` overload is correct. | Reproduced |
| 1.3 | `DUnitX.Assert.pas:438/453` `AreEqual<T>`, `:617` `AreNotEqual<T>`, `:708/724` `Contains<T>`, `:743/757` `DoesNotContain<T>` | These compare with `TComparer<T>.Default`. For `Double`/`Extended` the RTL's `Compare_R8` / `Compare_R10` return 0 when either value is NaN. So `AreEqual<Double>(NaN, 1.0)` **passes** and `Contains<Double>([1.0], NaN)` **passes**. The non-generic `AreEqual(Double...)` overloads are correct, because `SameValue` returns False for NaN. Fix: use `TEqualityComparer<T>.Default.Equals`, whose `Equals_R8` uses `=`. | Reproduced (Win32 and Win64) |
| 1.4 | `DUnitX.Assert.pas:1219` `WillRaise`, `:1263` `WillRaiseAny` (also `WillRaiseDescendant`, `WillRaiseWithMessage`) | These catch `on E : Exception`, which includes DUnitX's own `ETestFailure` / `ETestPass` / `ETestIgnored`. Results: `Assert.WillRaiseAny(procedure begin Assert.AreEqual(1, 2) end)` **passes**; `WillRaise(procedure begin Assert.Pass end)` passes; an `Assert.Ignore` inside is swallowed. `[WillRaise(Exception, exDescendant)]` on a test method has the same effect: a failing assert in the body counts as "raised as expected" (`DUnitX.Test.pas:439`). Fix: re-raise `ETestFrameworkException` descendants unless the caller named one explicitly. | Reproduced |
| 1.5 | `DUnitX.FixtureProvider.pas:474, 490, 505`; `DUnitX.TestFixture.pas:594` `AddTestCase`; `DUnitX.Test.pas:383` `TDUnitXTestCase.Execute` | **`[WillRaise]` is silently dropped on any method that also has `[TestCase]` / `[TestCaseProvider]`.** `AddTestCase` has no expected-exception parameter and always creates a plain `TDUnitXTestCase`. With `[Test][TestCase('neg','-1')][WillRaise(EArgumentException)]`, if the code under test stops raising, the test still passes. `[MaxTime]` is dropped from test cases in the same way. | Traced |
| 1.6 | `DUnitX.Utils.pas:1231` `ConvStr2Int`, `:1212` `ConvStr2Float`, `:1124` `ConvStr2Enum`, `:1160` `Str2DateTimeValue` (and siblings); `DUnitX.Test.pas:348` `TDUnitXTestCase.Create` | **Bad `[TestCase]` data silently becomes 0.** The converters return True with a default value when the string does not parse, and `TDUnitXTestCase.Create` leaves an empty `TValue` when `TryConvert` fails. Too few values also become defaults, and extra values are dropped. Observed: `'abc'` → Integer 0; `'1.5x'` → Double 0; `'1,000'` → Double 1.0; `'300'` → Byte 44; `'Bogus'` → enum ordinal −1; `'notadate'` → 30/12/1899. Two further problems: `ConvStr2Float` uses an uninitialised `TFormatSettings` local with only `DecimalSeparator` set, and the date converters try the machine locale first, so `'01/02/2020'` is a different date on UK and US machines. Fix: return False when parsing fails (with `TFormatSettings.Invariant`), and raise from `TDUnitXTestCase.Create` when the value count differs from the parameter count or a conversion fails, so the case reports an Error. | Reproduced |
| 1.7 | `DUnitX.DUnitCompatibility.pas:272` `CheckEqualsString` (and the WideString variants); `:354` `CheckNotEqualsString` / `CheckNotEquals(string)` | These hard-code `ignoreCase = True`. DUnit's string checks are case-sensitive, so every suite converted from DUnit silently loses case checking, and `Assert.IgnoreCaseDefault := False` does not reach these methods. In the other direction, `CheckNotEquals('abc', 'ABC')` wrongly **fails**. | Traced |
| 1.8 | `DUnitX.DUnitCompatibility.pas:447` `CheckInherits` | Arguments reversed. DUnit checks `actual.InheritsFrom(expected)`, but this calls `Assert.InheritsFrom(expected, actual)`, whose parameters are `(descendant, parent)`. So a correct DUnit check fails, and a reversed one passes. | Traced |
| 1.9 | `DUnitX.CategoryExpression.pas:120` `IndexOfAny` (the non-NEXTGEN path) | `while i < Max` over a 1-based string never examines the last character. `--exclude:(Slow\|Integration)` tokenises as `Slow` OR `Integration)`, so `Integration` tests are **not** excluded. No existing test has an operator in the final position. | Traced |
| 1.10 | `Expert/DUnitX.Expert.CodeGen.Templates.pas:109`; `Tests/DUnitXTestProject.dpr:88` | **The generated test project exits with code 0 when the run aborts.** `except on E: Exception do System.Writeln(...)` never sets `ExitCode`. Exceptions that reach it include: `ENoTestsRegistered` (the classic missing `{$STRONGLINKTYPES ON}`), a fixture constructor that raises (see 2.3), a raising test-case provider, the FastMM5 monitor's "must be first" check, and any logger failure. CI sees success, with no tests run. Fix: `System.ExitCode := EXIT_ERRORS;` in the handler. Every project created from the wizard inherits this. | Traced |
| 1.11 | `DUnitX.RunResults.pas:133` `GetAllPassed` | A run that executes **zero** tests reports all-passed and exits 0. A typo in `--run` / `--include` goes green. Consider failing, or adding an option to fail, when no tests ran. | Traced |
| 1.12 | `DUnitX.FixtureProvider.pas:353` (`[RepeatTest]` child fixture) | The child fixture copies the parent's Setup/TearDown **at the moment the repeat method is processed**. `GetMethods` returns the class's own methods before inherited ones, so `[Setup]`/`[TearDown]` declared in a base fixture class (or after the method) are nil in the child: every repetition runs **without Setup or TearDown**. With `[RepeatTest]` plus `[TestCase]`, Setup is bound to the parent instance while the test runs on the child's own instance. Child fixtures also run when the parent's `[SetupFixture]` failed. | Traced |

## 2. Wrong results, wrong counts, or a broken run

| # | Where | Defect | Evidence |
|---|---|---|---|
| 2.1 | `DUnitX.TestRunner.pas:744` `ExecuteTearDownFixtureMethod` → `:944` `InvalidateTestsInFixture` | When `[TearDownFixture]` raises, every test in the fixture, all of which have **already run and been recorded**, is reported again with `Loggers_BeginTest` / `EndTest` and recorded a second time as an Error. `TestCount` is inflated and the XML contains duplicate test cases. In the VCL GUI the duplicate begin-test aborts the run (see 4.1). | Traced |
| 2.2 | `DUnitX.TestFixture.pas:247` `ExecuteFixtureTearDown` | When the teardown is the destructor, `FFixtureInstance.Free; FFixtureInstance := nil;`. If the destructor raises, the field is never nilled, and `TDUnitXTestFixture.Destroy` frees the half-destroyed object **again**. Fix: `FreeAndNil`. | Traced |
| 2.3 | `DUnitX.TestFixture.pas:230` (`InternalInitFixtureInstance(true)` in the constructor) | Fixture instances are constructed while the fixture list is being built, outside per-fixture error handling. One raising fixture constructor aborts the **whole** run before `TestingStarts`, and then exits 0 via 1.10. All fixtures are constructed even under `--run:OneTest`. Separately, a parameterless constructor anywhere below `TObject` sets `FIgnoreFixtureSetup`, which **silently disables `[SetupFixture]`** in that fixture and every descendant. | Traced |
| 2.4 | `DUnitX.Test.pas:439` `FRaiseContext := context` with `DUnitX.FixtureResult.pas` (`FFixture` held strongly) | A reference cycle runs RunResults → FixtureResult → Fixture → tests → `TDUnitXExceptionTest` → context. Any run that executes a `[WillRaise]` test leaks the results, the fixtures and the fixture instances. User destructors of those fixtures never run. Fix: clear `FRaiseContext` after `Execute`. | Traced |
| 2.5 | `DUnitX.TestRunner.pas:760` `ExecuteTest` (`PostTest` at `:781`) | False memory-leak reports: (a) `Assert.Pass` — the `ETestPass` object is still alive when `PostTest` measures; (b) `Log` / `WriteLn` / `Status` in a test grow the runner's message lists inside the measured window; (c) the check is `<> 0`, so a test that frees earlier memory is reported as "−N bytes leaked". | Traced |
| 2.6 | `DUnitX.TestRunner.pas:805` `ExecuteTests` | TearDown runs after a failed Setup (NUnit skips it), and a TearDown error **replaces** the Setup or test failure message. The result still fails, but the diagnosis is lost. | Traced |
| 2.7 | `DUnitX.FixtureResult.pas:226` `GetHasFailures`, used by `DUnitX.Loggers.XML.NUnit.pas:233/241` | `HasFailures` counts failures only. A fixture whose tests all **errored** (or leaked) is written as `result="Success" success="True"`. The header `failures` / `errors` attributes also leave out `MemoryLeakCount`, while each leaked test is written as `result="Failure"` (and as `<error>` in JUnit). So a leak-only run has a header saying `failures="0" errors="0"`. `GetNamespace` returns `FName`, and `RollUpResults` ignores leak counts. | Traced |
| 2.8 | `DUnitX.FixtureProvider.pas:245` `GenerateTests` | A method-level `[Category]` **replaces** the fixture's category instead of adding to it, so `--exclude:Integration` still runs `[Category('Slow')]` methods inside an `[Category('Integration')]` fixture. This may be intended, but it is surprising and not documented. | Traced |
| 2.9 | `DUnitX.TestDataProvider.pas` `GetProvider`; `DUnitX.FixtureProvider.pas` | A misnamed or unregistered `[TestCaseProvider]` silently produces **zero** tests. | Traced |

## 3. Assertion messages and robustness

| # | Where | Defect | Evidence |
|---|---|---|---|
| 3.1 | `DUnitX.Assert.pas:1148` `WillNotRaiseAny` | The user's message is concatenated **into the Format string** (`SUnexpectedException + AddLineBreak(msg)`). `'coverage 100%'` prints as "coverage 100". A `%s` or `%d` in the message raises `EConvertError`, which replaces the real failure. | Reproduced |
| 3.2 | `DUnitX.Assert.pas:1194/1209` `WillNotRaiseDescendant` / `WillNotRaiseWithMessage` | A nil `exceptionClass` gives an access violation (`exceptionClass.ClassName`) instead of a readable failure. | Reproduced |
| 3.3 | `DUnitX.Assert.pas:699` `AreSame(TObject)` (and `AreNotSame`) | Uses `expected.Equals(actual)`, which is not an identity check, so an overridden `Equals` changes the result. A nil `expected` gives an access violation. | Reproduced |
| 3.4 | `DUnitX.Assert.pas:531` `AreEqual(Double, tolerance)` (and the `Extended` / `AreNotEqual` siblings) | In `SameValue`, Inf − Inf is NaN, so `AreEqual(Inf, Inf)` **fails** ("Expected [INF] but got [INF]") and `AreNotEqual(Inf, Inf)` **passes**. A negative tolerance makes `AreEqual(1, 1, -0.5)` fail and `AreNotEqual` pass. Fix: treat `expected = actual` as equal before calling `SameValue` (NaN = NaN is still False), and reject `tolerance < 0`. | Reproduced |
| 3.5 | `DUnitX.Assert.pas:554` `AreEqual(Currency)`; `:1429/1434` `DoesNotContain(string)`; `AreEqual(Cardinal)` | Wrong failure messages: `AreEqual(Currency)` says "Expected [1] **equals** actual [2]"; `DoesNotContain` says "[abc] does not contain [b]" when it does; `AreEqual(Cardinal)` prints `High(Cardinal)` as −1. `WillNotRaise` / `WillNotRaiseDescendant` name the *expected* class rather than the class that was raised. | Reproduced |
| 3.6 | `DUnitX.Assert.pas:1550/1587` `AreEqual(TStrings, TStrings)` | Fails when both arguments are the same instance (`IsTrue(expected <> actual)`), and a duplicate entry in `ignoreLines` raises `EListError`. | Reproduced |
| 3.7 | `DUnitX.Assert.pas:1412` `Contains(string)` | Empty substring: `Contains('abc', '')` fails and `DoesNotContain('abc', '')` passes, while `StartsWith` / `EndsWith` reject an empty substring explicitly. The family is inconsistent. | Reproduced |
| 3.8 | `Assert.AreEqual(10, 12, 5)` | With integer literals, overload resolution picks the `Double`-with-tolerance overload, so this **passes**. Worth a note in the documentation, if nothing else. | Reproduced |
| 3.9 | `DUnitX.Utils.XML.pas:46` `IsValidXMLChar` | Treats form feed (`$0C`) as legal. XML 1.0 forbids it, so a message containing one produces ill-formed XML. The exe path and category names are written into XML attributes without `EscapeForXML`. | Traced |
| 3.10 | `DUnitX.Loggers.XML.JUnit.pas:225` | `FormatDateTime('yyyy-MM-dd"T"hh:nn:ss')` leaves `:` unquoted, so the locale's time separator is used and the timestamp is not ISO 8601 everywhere. NUnit quotes it correctly. NUnit's assembly `time` attribute holds a clock time where a duration belongs. | Traced |
| 3.11 | `DUnitX.OptionsDefinition.pas:92` | `--dontshowignored` ignores its value: `-dsi:false` turns it **on**. | Traced |
| 3.12 | ~~`DUnitX.StackTrace.EurekaLog7.pas:89` `PointerToLocationInfo`~~ | **Withdrawn (2026-10-12): not a defect.** The `Result := ''` is in the `{$ELSE}` branch of `{$IFDEF USE_EUREKALOG7}`, after the real assignment; MadExcept3/4/5 have the same shape. We misread it. | n/a |

## 4. VCL GUI runner (`DUnitX.Loggers.GUI.VCL.pas`, `...GUI.VCL.RichEdit.pas`)

Every logger callback arrives on the main thread, so there is no cross-thread VCL access. The hazards are
re-entrancy through `Application.ProcessMessages`, and state that is not reset.

| # | Where | Defect | Evidence |
|---|---|---|---|
| 4.1 | `GUI.VCL.pas:866` `RunExecute` | `FRunning := False` and `UpdateFormActions` sit **after** the `try/finally`. Any exception during a run leaves Run, Run Selected, Select All, Unselect All and Invert disabled until restart, and the status stuck at "Running". Exceptions that reach here include: the `GetNodeByTestFullName` "Could not find node" raise, the two `Exception.Create`s in `ProcessTestResult`, a raising fixture constructor, and 4.2. | Traced |
| 4.2 | `GUI.VCL.RichEdit.pas:119` `OnBeginTest` | `FTestBookmarkList.Add(Test.FullName, ...)` is `TDictionary.Add`. Any repeated begin-test raises `EListError` and aborts the run. 2.1 causes one on every `[TearDownFixture]` failure, and duplicate test names cause one too. Fix: `AddOrSetValue`. | Traced |
| 4.3 | `GUI.VCL.pas:1034` `edtFilterKeyPress` (and `edtFilterRightButtonClick`) | The filter box stays enabled during a run. Pressing Enter in it calls `LoadTests` re-entrantly, which frees every tree node and clears the node and bookmark maps under the running suite. The next `OnEndTest` raises, and then 4.1 follows. After a run, re-filtering also leaves `TResultNode.TestNode` pointing at freed nodes. | Traced |
| 4.4 | `GUI.VCL.pas:476` `actRunExecute` | **Runs tests that are not checked.** The selection is passed as a `TNameFilter`, whose `Match` does `StartsText(name, test.Fixture.FullName)`. A checked test whose full name is a text prefix of a fixture name enables that whole fixture. `[RepeatTest]` child fixtures are named `<Fixture>.<Method>`: checking `Test` runs all repeats of the unchecked `TestLoad`, and the progress bar overruns. The GUI needs an exact-match filter. | Traced |
| 4.5 | `GUI.VCL.pas:572` `FormClose` | Closing during a run does not stop it: every remaining test still runs. There is no Stop action. `FormClose` also writes the INI beside the exe with no error handling, so a read-only folder makes the window **impossible to close**. Reads use `TIniFile` and writes use `TMemIniFile` (ANSI), so non-ASCII test names do not round-trip, and test names containing `=` corrupt the INI keys. | Traced |
| 4.6 | `GUI.VCL.pas:1023` `ClearResults` | Clears the results tree but not the test-tree icons. After a partial run, tests that did not run keep last run's pass/fail icon, and a fixture can stay red after its failing test now passes. | Traced |
| 4.7 | `GUI.VCL.RichEdit.pas:421/426` | Output is appended with `SelText` at the **current caret**. Clicking in the log during a run moves the caret, so later output is inserted mid-document and every bookmark line number is wrong. Fix: set `SelStart := GetTextLen` before each write. | Traced |
| 4.8 | `GUI.VCL.pas:1228` `UpdateGUIForComplete` | The GUI forces `FailsOnNoAsserts := True` and files "no assertions" results under a Warning root, but the summary "Failed" count still includes them. The memory-leak root caption (`STestsWithLeak`) has no `%d`, so its count is dropped. | Traced |
| 4.9 | `GUI.VCL.pas:1153` `tvwTestsKeyPress` | Space with no selected node (empty tree, or a filter that matches nothing) gives an access violation: `TTestNode(tvwTests.Selected).InvertState` has no nil check. | Traced |
| 4.10 | `GUI.VCL.pas:1128/1187` | `Mouse.CursorPos.X/Y` is posted through `WPARAM` / `LPARAM`. On Win64 a negative X (a monitor to the left of the primary) goes through an unsigned 64-bit value, and with `{$R+}` in the consuming project this raises `ERangeError`. Simpler: assign `PopupMenu` to the trees, which also makes Shift+F10 and the Apps key work. | Traced |
| 4.11 | `GUI.VCL.pas:1363–1381` (Beyond Compare lookup) | In a Win64 process `IsWow64` is False, so only `%ProgramFiles%` is searched, and a 32-bit Beyond Compare in `Program Files (x86)` is never found. `CreateProcessAndWait` blocks the UI, the `CreateProcess` result is ignored, and the first temp file leaks if the second `MakeTempFile` raises. | Traced |
| 4.12 | `GUI.VCL.pas:1143` `tvwTestsCustomDrawItem` | Forces `clWindowText` without checking `cdsSelected`, so a selected fixture node is black on the highlight colour. | Traced |

## 5. IDE expert

| # | Where | Defect | Evidence |
|---|---|---|---|
| 5.1 | `Expert/DUnitX.Expert.CodeGen.NewTestProject.pas:44, 82, 88, 93` | **Misspelt conditional:** tests `DELPHI_SEATTLE_UP`, but `DUnitX.inc` defines `DELPHIX_SEATTLE_UP`, the spelling every other expert unit uses. So `TTestProjectFile` always derives from `TNewProject`, never `TNewProjectEx`. `IOTAProjectCreator160` is not implemented, the personality argument is discarded, and `GetProjectPersonality` always returns Delphi: the C++Builder gallery entry produces a Delphi `.dpr`. When fixing the spelling, note that `TNewProjectEx.GetPlatforms` would then start advertising every platform. | Traced |
| 5.2 | `Expert/DUnitX.Expert.ProjectWizardEx.pas:98` | The `Boolean` result of `IOTAModuleServices.CloseAll` is discarded. If the user unticks "Add to existing project group" and then presses Cancel on the save prompt, the new project is still added to the existing group. | Traced |
| 5.3 | `Expert/DUnitX.Expert.ProjectWizardEx.pas:103` | `Project := GetActiveProject` is dereferenced (`Project.ProjectOptions as IOTAProjectOptionsConfigurations`) before the nil check further down. If `CreateModule` leaves no active project, an access violation (or `EIntfCastError`) escapes into the IDE. | Traced |
| 5.4 | `Expert/DUnitX.Expert.Forms.NewProjectWizard.pas:142` `GetTestFixtureClassName` (NewUnitWizard the same) | The fixture class name is only trimmed. `My Test`, `1Test`, `begin` or `T-X` generate a unit that does not compile. OK closes via `ModalResult`, so invalid input cannot be refused. Suggest `IsValidIdent` plus a reserved-word check in `OnCloseQuery`. | Traced |

## 6. Fixes we already carry, which you may want

These are in our fork with tests, and we can send any of them as a pull request.

- **`[MaxTime]` crashes the test thread on Win64** — `DUnitX.Timeout.pas:115`.
  - **Cause:** the watchdog rewrites the suspended thread's instruction pointer with `Ctx.Rip := Cardinal(@RaiseTimeOutException)`, which truncates a 64-bit code address.
  - **Our fix:** the watchdog no longer touches the test thread. It only records that the timeout expired, and the test is failed after its body returns.
  - **Before we send it:** our version still polls every 20 ms from a stopwatch started on the watchdog thread, so an overrun that ends between two polls can be missed. We plan to time the test on its own thread instead first.
- **The NUnit and JUnit file loggers raise `EInOutError: Unable to create directory []` when given a bare file name** — `ForceDirectories(ExtractFilePath(FileName))` with an empty path (`DUnitX.Loggers.XML.NUnit.pas:439`, and the JUnit equivalent). The runner dies before any test runs.
- **The FastMM4 leak monitor multiplied in 32 bits** and cast the overflowed product to `Int64` afterwards.
- **`TWeakReference<T>.Destroy`** gave up on `RemoveWeakRef` when it could not take the lock, but nilled its field anyway. The target object was left holding a pointer into memory that was about to be freed.
- **`TTestFixtureList.Sort`** freed a `TDelegatedComparer` that had already been implicitly converted to a reference-counted `IComparer`.
- **`TRttiPropertyExtension`** freed its patched virtual method tables before the instances that dispatch through them.
- **The service locator leaked the constructed object** whenever `Supports` failed.
- **`TValueHelper.IsUInt64`** tested `NativeInt`, the signed type that `IsInt64` already uses.
- **`Assert.Ignore(reason)`**, a run-time test skip, was proposed separately on 2026-09-09.

## 7. Status in our fork (updated 2026-10-12, after this report was filed)

We have since fixed these in `ijbranch/gllDUnitX`, each with a test that fails on the old code where the defect can be
unit-tested (52 new tests). The GUI runner and IDE expert changes were verified by build and, for the GUI, a smoke test.
Any of these can be offered as pull requests.

- **Fixed:** 1.1–1.12, 2.1–2.7, 2.9, 3.1–3.7, 3.9–3.11, 4.1–4.12, 5.1–5.4; also the timeout fix in section 6.
- **Not changed:** 2.8 (method `[Category]` replacing the fixture's) — we read it as your intent; changing it would alter
  test selection for every existing suite. 3.8 is documentation only.
- **Withdrawn:** 3.12 (see its row): not a defect.
- **Behaviour changes a suite can notice:** a run that executes no tests no longer counts as passed; `WillRaise`
  without a class no longer catches `ETestFailure` / `ETestPass` / `ETestIgnored`; bad `[TestCase]` data is an error;
  DUnit-compatibility string checks are case-sensitive; `[RepeatTest]` names are `Method-1-of-N`; TearDown is skipped
  after a failed Setup.

## 8. Further findings, posted to #398 on 2026-10-12

Found after filing; each confirmed in `master` @ `1bdc297` and fixed in our fork. Posted as a follow-up comment on
[#398](https://github.com/VSoftTechnologies/DUnitX/issues/398#issuecomment-6117424810), lettered A–G:

- **A.** The leak check adds up the setup, test and teardown phases, so memory freed in a gap between them is
  reported as leaked (a 1 MB connection buffer).
- **B.** `TDUnitXTestRunner.Log` keeps the caller's string, so a `Log` / `Status` message counts against the test.
- **C.** The FastMM5 monitor reads `AllocatedBytes` without `FastMM_ProcessAllPendingFrees`.
- **D.** `WillNotRaise` with a named class swallows a failing assertion; `WillNotRaiseAny` reports an inner
  `Assert.Pass` as an unexpected exception.
- **E.** `CheckEqualsBin` compares digit-truncated strings, so values differing above `digits` pass.
- **F.** `TDUnitXList<T>.ToArray` and the non-generic enumerator return nil.
- **G.** `TValueHelper.ToVarRec` / `ToVarRecs` return dangling or mis-sized pointers.

## 9. Upstream's response, and how the items are now being sent (2026-10-12)

Upstream responded on 2026-10-12: items are to be sent as **one issue per problem, then a PR with tests that show
it**, not as a long report. The **VCL GUI runner is not maintained upstream**, and TestInsight was suggested
instead. Consequences for this file:

- **Section 4 (GUI runner) will not be offered upstream.** The fixes stay fork-local.
- **TestInsight is not taken up:** it was removed from our IDE on purpose.
- **The remaining items go in small batches,** each as an issue plus a PR whose test fails on upstream `master`.
  The next batch waits until upstream has responded to the current one.

**Batch 1**, posted 2026-10-12 against `1bdc297`. Branches were rebuilt on `upstream/master` (not cherry-picked
from this fork) in the worktree `D:\gllDUnitX-upstream`, and pushed to the public GitHub fork
[`ijbranch/DUnitX`](https://github.com/ijbranch/DUnitX), which exists only to carry PRs. Detail and the exact
texts are in [UPSTREAM-ISSUES-Batch1.md](UPSTREAM-ISSUES-Batch1.md).

| Item | Issue | PR |
|---|---|---|
| 1.1 `Assert.IsEmpty(Variant)` inverted | [#399](https://github.com/VSoftTechnologies/DUnitX/issues/399) | [#405](https://github.com/VSoftTechnologies/DUnitX/pull/405) |
| 1.2 `WillNotRaiseDescendant(TTestMethod)` | [#400](https://github.com/VSoftTechnologies/DUnitX/issues/400) | [#406](https://github.com/VSoftTechnologies/DUnitX/pull/406) |
| 1.3 NaN in the generic compares | [#401](https://github.com/VSoftTechnologies/DUnitX/issues/401) | [#407](https://github.com/VSoftTechnologies/DUnitX/pull/407) |
| 1.4 `WillRaise*` swallow test outcomes | [#402](https://github.com/VSoftTechnologies/DUnitX/issues/402) | [#408](https://github.com/VSoftTechnologies/DUnitX/pull/408) |
| 1.9 category operator in last position | [#403](https://github.com/VSoftTechnologies/DUnitX/issues/403) | [#409](https://github.com/VSoftTechnologies/DUnitX/pull/409) |
| 1.10 runner exits 0 on abort | [#404](https://github.com/VSoftTechnologies/DUnitX/issues/404) | [#410](https://github.com/VSoftTechnologies/DUnitX/pull/410) |

**Status 2026-10-13:** upstream merged all seven PRs, #405-#411, the same day (`upstream/master` @ `6af7aeb`). Each
merge put the next PR into conflict, because they all add tests at the same place in `Tests\DUnitX.Tests.Assert.pas`;
the branches were merged with `upstream/master` and pushed (Vincent resolved #406's himself).

**Batch 2**, posted 2026-10-13 against `6af7aeb`, with the lessons of batch 1 applied first (every pair of branches
checked to merge cleanly, no `.dproj` or shared `uses` edits). Detail and the exact texts are in
[UPSTREAM-ISSUES-Batch2.md](UPSTREAM-ISSUES-Batch2.md).

| Item | Issue | PR |
|---|---|---|
| D `WillNotRaise*` swallow a failing assert | [#412](https://github.com/VSoftTechnologies/DUnitX/issues/412) | [#413](https://github.com/VSoftTechnologies/DUnitX/pull/413) |
| 3.3 `AreSame(TObject)` uses `Equals` | [#414](https://github.com/VSoftTechnologies/DUnitX/issues/414) | [#415](https://github.com/VSoftTechnologies/DUnitX/pull/415) |
| 1.8 `CheckInherits` reversed | [#416](https://github.com/VSoftTechnologies/DUnitX/issues/416) | [#417](https://github.com/VSoftTechnologies/DUnitX/pull/417) |
| E `CheckEqualsBin` ignores bits above `digits` | [#418](https://github.com/VSoftTechnologies/DUnitX/issues/418) | [#419](https://github.com/VSoftTechnologies/DUnitX/pull/419) |
| 1.7 DUnit string checks ignore case | [#420](https://github.com/VSoftTechnologies/DUnitX/issues/420) | [#421](https://github.com/VSoftTechnologies/DUnitX/pull/421) |
| Section 6: XML file loggers fail on a bare file name | [#422](https://github.com/VSoftTechnologies/DUnitX/issues/422) | [#423](https://github.com/VSoftTechnologies/DUnitX/pull/423) |

The upstream fixes are deliberately narrower than ours in two places. For 1.3, only float types switch to the
equality comparer, so class and Variant comparisons are unchanged. For 1.4, a test outcome is re-raised unless the
caller named a matching class other than `Exception`, which uses only the `fTestFailure` / `fTestPass` hooks that
`DUnitX.Assert.pas` already has.

**Outside the batches: [#372](https://github.com/VSoftTechnologies/DUnitX/issues/372) (bitmask exit codes) ->
[PR #411](https://github.com/VSoftTechnologies/DUnitX/pull/411)**, branch `feature/bitmask-exit-codes`, posted
2026-10-12 after a reviewer pointed at it from #404. It is someone else's feature request, which upstream had
indicated it would accept, so we sent it as goodwill. **It is deliberately NOT in this fork** (Ian, 2026-10-12): nothing
here would use it, and carrying it ourselves would add divergence for no benefit. **Upstream merged it on 2026-10-13,
and this fork still does not take it** (Ian, 2026-10-13): our runners set `EXIT_ERRORS` on any failure, error, leak or
abort, and every consumer here treats any non-zero exit as a failure. Any later merge from upstream into this fork
leaves #411 out (`DUnitX.TestFramework.pas`, `DUnitX.OptionsDefinition.pas`, the expert template,
`Tests\DUnitXTestProject.dpr`, `Tests\DUnitX.Tests.ExitCode.pas`). The branch has two commits because the shared `pre-commit` hook stripped upstream's
`DUnitXTest_D12.dproj` (the worktree shares this repo's `.git\hooks`); the net diff adds one `DCCReference` there.

---

*We have deliberately left out anything that is our fork's own policy, such as platform scope and pre-XE
conditionals. Everything above applies to upstream as it stands.*
