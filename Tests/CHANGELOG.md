# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

> The change record of the `gllDUnitXTests` test suite (`Tests`).  Kept beside the suite since
> 2026-10-25 (Ian: "every test suite should have its own change log"); test-only entries recorded before that in
> the repository's `CHANGELOG.md` were moved here the same day.  Product changes, including those that change a
> product unit together with its tests, stay in the repository's `CHANGELOG.md`.

## [In-Service]

### Added

- (2026-10-26) **`README.md`: the suite's 9 ignored tests are listed, each with why** — `README.md`, `DUnitX.Tests.TestFixture.pas`.  All nine prove DUnitX honours `[Ignore]` or `[RepeatTest(0)]`; none pins a defect.  `TestTimeout`, the one with a blank reason in run reports, now carries its reason in the `[Ignore]` attribute.  **Why:** `verify_change` warns on every ignored test ("check each is listed in the suite README"); Ian asked for that check, 2026-10-26.
- (2026-10-25) **This change log** — `CHANGELOG.md`.  The suite's own record, per the estate rule that every test
  suite has one; test-only history moved in from `..\CHANGELOG.md` ( 9 entries ).
- (2026-10-12) **NaN tests for `Assert.AreEqual` / `AreNotEqual` on `Double` and `Extended`** —
  `Tests/DUnitX.Tests.Assert.pas`. Six tests: `AreEqual` must fail with NaN as either argument, and `AreNotEqual`
  must pass when one value is NaN. Prompted by the fork survey below (fabiorizzuto's 2018 fork adds an explicit
  `IsNan` check). **Result: no defect** — `System.Math.SameValue` already returns `False` for NaN, so all six pass on
  Win32 (x87 `Extended`) and Win64 with `Source/` unchanged. Mutation-proved: forcing the four `SameValue` sites in
  `Source/DUnitX.Assert.pas` to never fail / always fail turned all six red. The same run showed these are the
  ONLY tests of `AreNotEqual( Double / Extended )` raising: no older test failed under that mutation.
- (2026-08-24) `Tests/DUnitXTest_D13.dproj`, derived from the former D12 test project
  **Why:** the tree had no Delphi 13 test project at all - the newest was D12.
- (2026-08-24) A `CheckDelphiMocks` MSBuild target in `Tests/DUnitXTest_D13.dproj` that fails with an actionable message naming the required sibling clone, instead of a bare `F2613 Unit 'Delphi.Mocks' not found`
- (2026-08-24) The test project now resolves Delphi.Mocks from a sibling `glldelphi-mocks` source checkout via the existing `DelphiMocks` property, replacing the DPM package reference - `Tests/DUnitXTest_D13.dproj`
  **Why:** there is no DPM cache on the build machine, and the pinned `VSoft.DelphiMocks 0.2.2` had no verified `delphi13.0`/`win64` binding.
- (2026-08-24) Six count assertions in `DUnitX.Tests.CategoryParser.pas` failed to compile with E2532. Delphi 13 changed `TList<T>.Count` to `NativeInt`, so generic inference against an integer literal became ambiguous; the assertions are now explicitly `AreEqual<NativeInt>`

### Changed

- (2026-10-26) **Unit-scope names in every `uses` clause** — `Tests/DUnitX.SingleNameSpace.pas`, `Tests/DUnitX.Tests.CommandLineParser.pas`, `Tests/DUnitX.Tests.TestFixture.pas`, `Tests/DUnitX.Tests.TestNameParser.pas`, `Tests/DUnitX.Tests.Utils.pas`, `Tests/DUnitXTestProject.dpr`.  8 bare RTL/VCL unit names in `uses` clauses given their unit-scope names, 1 partly-scoped name (`Generics.Collections`) completed, 1 scoped name respelt as the unit declares itself; generated code is byte-identical in every mode built.  **Why:** Ian, 2026-10-26: "all the gll* forks are our own code because they have all been modified to suite our needs/preferences/standards".  Divergence from upstream: a later upstream merge conflicts wherever upstream edits a converted `uses` line; resolve by taking upstream's change and keeping the scoped spelling.

### Fixed

- (2026-10-13) **Weak tests made real, and a test for every fix of this review** — `Tests/DUnitX.Tests.Assert.pas`, `Tests/DUnitX.Tests.CommandLineParser.pas`, `Tests/DUnitX.Tests.Inheritance.pas`, `Tests/DUnitX.Tests.CategoryParser.pas`, `Tests/DUnitX.Tests.DUnitCompatibility.pas`, `Tests/DUnitX.Tests.TestFixture.pas`, `Tests/DUnitX.Tests.Loggers.XML.JUnit.pas`, `Tests/DUnitX.Tests.Loggers.XML.NUnit.pas`, `Tests/DUnitX.Tests.UtilsHelpers.pas`, `Tests/DUnitXTestProject.dpr`, `Tests/DUnitXTest_D13.dproj`. Tests that could not fail: `AreEqualMemory_Throws_ETestFailure_When_Pointers_Are_NotEqual` was only `Assert.Pass`; `AreEqual_GUID_Throws_No_Exception_When_Values_Are_Equal` called `AreNotEqual`; the `Fail` / `Pass` / `Ignore` `..._With_Message` tests and `WillNotRaise_With_ExactClass_Negative` never compared the message; `Will_Raise_On_Registering_Duplicate_Options` never reached its short-name case (now three cases, each from an empty registry); `TestInBase` passed through `Assert.Pass` without checking the override; the category-parser string asserts ignored case and had expected and actual reversed. The never-run `OnTestWarning_Adds_Warnings_To_Be_Written_Out_On_Next_Success` tests (JUnit, NUnit) are removed: with `[Test]` added they failed, because they test a warning callback that `ITestLogger` does not have. New tests for the second round of fixes, each proved by reverting its fix: `Nested_Relative_Options_File_Resolves_Against_Its_Parent_Folder`, `UnclosedParenthesisRaises`, `CheckIs_Nil_Object_Fails`, `WillRaise_Family_Wrong_Class_Failure_Includes_Caller_Message`, `RunResultsListTheRunFixtures`, `FixtureTestInfoListFollowsAddedTests`, `NameFilterListDropsEmptyAndDuplicateNames`, `TestErrorSeparatesMessagesAndAcceptsStrCompareDescendants`, and twelve `DUnitX.Tests.UtilsHelpers` tests for the `DUnitX.Utils` fixes; the seven `WillNotRaise*` tests that asserted the old swallowing now assert that the other exception propagates.
- (2026-10-12) **The self-test runner forced `Pause` and exited 0 when the run crashed** — `Tests/DUnitXTestProject.dpr`.
  Outside a `CI` build it assigned `ExitBehavior := Pause` after every run, overriding `--exit:continue`, so an
  unattended run waited for Enter; and its `except` handler printed the exception without setting `ExitCode`, so a run
  that died before or inside `Execute` reported success. It now pauses only when asked and sets `EXIT_ERRORS` in the
  handler, matching the wizard template; the dead `TESTINSIGHT` branches are gone. The suite is now a `test_run` target
  (`gllDUnitXTests` in `D:\GITLAKMCP\settings.ini`): 349 found, 340 passed, 9 ignored, 0 failed on Win64; 347 / 338 / 9
  / 0 on Win32 (the two `Int64` overload tests are 64-bit only).
- (2026-10-10) **The self-test project reported W1000 `Symbol 'CheckEqualsString' is deprecated`** —
  `Tests/DUnitX.Tests.DUnitCompatibility.pas`. The test exercises the DUnit compatibility layer on purpose, and the
  file already wraps its other deprecated calls (`CheckTrue`, `CheckNotNull`) in `{$WARN SYMBOL_DEPRECATED OFF}` /
  `ON`; `Test_TestName`'s `CheckEqualsString` was the one call left outside. Wrapped the same way, scoped to that
  one line (upstream has the same gap).
- (2026-08-24) `Tests/DUnitXTestProject.dpr` still declared `program DUnitXTest_D12;`
