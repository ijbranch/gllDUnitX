# DUnitX upstream: batch 8

Six issues and their PRs, built and posted 2026-10-15 against `master` @ `7c891c6` (after upstream merged all of
batch 7). Ian: "Prioritise the remaining then generate and send the next 6 PRs." Issue bodies end "Split out of
#398."; PR bodies are "Fixes #N." plus a short note plus the one-line caveat at the end of this file. Branches are in
the worktree `D:\gllDUnitX-upstream` (remote `dunitx-fork`), pushed to [`ijbranch/DUnitX`](https://github.com/ijbranch/DUnitX).
Each branch has a commit with the failing test, then the fix. "Allow edits by maintainers" is on for every PR.

| # | Report item | Severity | Issue | PR | Branch |
|---|---|---|---|---|---|
| 1 | Fork fix (2026-10-13): override of an attributed virtual method | 1: a test passes that should fail | [#488](https://github.com/VSoftTechnologies/DUnitX/issues/488) | [#489](https://github.com/VSoftTechnologies/DUnitX/pull/489) | `fix/virtual-override-binding` |
| 2 | 3.7 | 1: a test passes that should fail | [#490](https://github.com/VSoftTechnologies/DUnitX/issues/490) | [#491](https://github.com/VSoftTechnologies/DUnitX/pull/491) | `fix/contains-empty-substring` |
| 3 | Fork fix (2026-10-13): results carry another test's log | 2: wrong results | [#492](https://github.com/VSoftTechnologies/DUnitX/issues/492) | [#493](https://github.com/VSoftTechnologies/DUnitX/pull/493) | `fix/log-per-test` |
| 4 | Fork fix (2026-10-13): fixture with children reports only their time | 2: wrong results | [#494](https://github.com/VSoftTechnologies/DUnitX/issues/494) | [#495](https://github.com/VSoftTechnologies/DUnitX/pull/495) | `fix/fixture-duration-children` |
| 5 | Fork fix (2026-10-13): `@<file>` always failed | 2: a broken run | [#496](https://github.com/VSoftTechnologies/DUnitX/issues/496) | [#497](https://github.com/VSoftTechnologies/DUnitX/pull/497) | `fix/at-options-file` |
| 6 | Fork fix (2026-10-13): `WillRaise*` drops the caller's message | 4: lost diagnostics | [#498](https://github.com/VSoftTechnologies/DUnitX/issues/498) | [#499](https://github.com/VSoftTechnologies/DUnitX/pull/499) | `fix/willraise-keeps-message` |

## How this batch was chosen and built

- **Ranking.** Every item not yet sent was ranked: report sections 1-3, 5, 6 and 8, and the fixes this fork carries
  from its 2026-10-12 / 2026-10-13 reviews (from `CHANGELOG.md` `### Fixed`). Severity first, as in batch 7: (1) a
  test or run passes when it should fail; (2) wrong results or counts, or a broken run; (3) compile or crash defects;
  (4) lost diagnostics; (5) cosmetic or unreachable. Then feasibility: a small, self-contained PR whose test fails on
  `master` on its own assertion, with no behaviour that upstream's own tests assert. Each candidate was checked in
  upstream's source and tests first; three that looked like defects turned out not to be reachable upstream (rows 25
  to 27). One allowance was new: a test may generate a fixture's tests with the provider and run the bound methods
  directly, with no runner (#1).
- **The full ranked list**, top to bottom (**chosen** in bold):
  - **Severity 1: a test or run passes when it should fail**
    1. **Override of an attributed virtual method runs the ancestor's code (fork fix): chosen, #1.** Reproduced on
       `7c891c6`; the fix is a VMT lookup plus a duplicate check, and leaves `[TestCase]` tests (invoked through RTTI,
       which already dispatches virtually) unchanged. Batch 7 passed it over as a larger rework; this smaller fix
       does not need this fork's `ResolveFixtureMethods`.
    2. **3.7 `DoesNotContain( s, '' )` passes: chosen, #2.** Upstream has no test of `Contains` / `DoesNotContain`
       with an empty substring, and its `StartsWith` / `EndsWith` tests assert that an empty substring fails, as the
       fix makes these two, so it is not a behaviour change upstream relies on.
    3. `--run` name list: a trailing comma is kept, so `--run:Unit.TFoo,` selects nothing, and a one-character last
       name is dropped (`TTestNameParser` never examines the last character). Passed over: upstream's
       `SingleName2`, `SingleName4` and `TwoNames2` cases assert that the comma is kept. Those tests were ported from
       NUnit, whose expectation trims the comma, so this could be proposed with that evidence; `--failonnotests`
       already catches the empty run. The dropped one-character name can be fixed without touching those cases, but
       a test's full name is never one character.
    4. 2.9 a misnamed `[TestCaseProvider]` gives zero tests: a behaviour change; `--failonnotests` covers a run that
       selects nothing.
    5. 1.6 bad `[TestCase]` data silently converted: upstream's suite relies on it (batch 7).
    6. `Assert.IsType<T>` can never fail: a design question (always fail, or remove).
    7. `[MaxTime]` overrun that ends in `Assert.Pass` passes: on Win64 any overrun first hits the `[MaxTime]` crash
       (row 18).
    8. `--run` matching any fixture whose name starts with the text: changes which tests a filter selects.
    9. `WillNotRaise( proc, SomeClass )` swallowing another exception: upstream's tests assert it (batch 7).
    10. `CheckSame( TObject )`: the identity change upstream declined in #415.
    11. 2.3 (b) a parameterless constructor disables `[SetupFixture]`: upstream's design, asserted by its
        `TExampleFixture3` ("I should not be called!"); this fork keeps it too.
  - **Severity 2: wrong results or counts, or a broken run**
    12. **A result carries the previous failing test's log, and loses what Setup logged (fork fix): chosen, #3.**
    13. **A fixture with child fixtures reports only its children's time (fork fix): chosen, #4.** A fixture's
        `[RepeatTest]` methods are its children; namespaces still add up their children (#43), as before.
    14. **`@<file>` is an unknown option (fork fix): chosen, #5.**
    15. 2.3 (a) one raising fixture constructor aborts the run: rests on this fork's fixture-construction rework.
    16. A, B, 2.5 (a) / (b) false leak reports: need this fork's runner-allocation accounting (batch 6).
    17. C (FastMM5 monitor without `FastMM_ProcessAllPendingFrees`): upstream's test project does not run FastMM5.
    18. The Win64 `[MaxTime]` crash (section 6): upstream's own `TestMaxTime` is already red, but this fork's fix
        stops interrupting a test (it fails the test after the body returns), so a hung test is no longer stopped:
        a design decision for upstream, better raised as a question than sent as a PR.
    19. `[SetupFixture]` runs when none of the selected tests will execute: an edge case (selected tests all
        ignored), and this fork's fix also changes when a parent's fixture setup runs for `[RepeatTest]` children,
        the area of #116.
    20. Fixtures run in heap-address order (`ITestFixtureList.Sort` is the generic list's default interface
        comparer): sorting by name changes the run order every suite sees.
    21. A relative options-file name inside an options file is resolved against the current directory: arguably
        intended (it is how the command line resolves it), and it would change the routine #5 changes; a candidate
        for a later batch.
    22. A bare argument (without `--run:`) is taken as the XML file name, so `DUnitXTest.exe Unit.TFoo` writes the
        XML to `Unit.TFoo` and runs every test: this fork's fix (the name must end in `.xml`) is a behaviour change.
    23. 2.8 a method `[Category]` replacing the fixture's: a behaviour change, not changed in this fork either.
    24. `ITestFixtureInfo.Tests` misses tests added after it is first read: no path found upstream that adds tests
        after the list is read.
    25. `ITestFixtureInfo.ActiveTestCount` returns the total count: a documented `TODO` that nothing reads.
    26. "`IRunResults.Fixtures` always nil": not reachable upstream, `GetFixtures` is not part of `IRunResults`.
    27. `TNameFilter`'s array and `TStrings` overloads keep empty names (which match everything): not reachable from
        the command line, which uses the single-name `Add`.
  - **Severity 3: compile and crash defects**
    28. `ITest.FullName` access violation once the fixture has gone: no upstream path found where a test outlives
        its fixture.
    29. An options file that includes itself recurses to a stack overflow: cannot fail on its own assertion (this
        fork's test was not run red either).
    30. `TRttiMethodHelper.Format` reading `Args[0]` out of range, `TObjectHelper.GetType` undefined for nil: a red
        run would rest on undefined behaviour.
    31. A set-typed option reading past a 4-byte Integer: an over-read no test can observe reliably.
    32. 5.1 (misspelt `DELPHI_SEATTLE_UP`), 5.2 (`CloseAll` result discarded), 5.3 (`GetActiveProject` dereferenced
        unchecked), 5.4 (fixture names that generate a unit which does not compile): IDE expert code. DUnitX's test
        project cannot load `ToolsAPI`, so none can have a test that fails on master there. 5.4 has a seam (a pure
        name check in `DUnitX.Expert.CodeGen.Templates.pas`, as this fork has), but the test project would have to
        compile an expert unit, a project change; and 5.1's fix also switches `GetPlatforms` to every platform. Not
        offered, as in batch 7.
    33. `TWeakReference<T>.Destroy` and `TTestFixtureHelper.Log` races, and the FastMM4 monitor's 32-bit multiply:
        not testable in upstream's test project.
  - **Severity 4: lost diagnostics**
    34. **A `WillRaise*` failure for the wrong exception class drops the caller's message (fork fix): chosen, #6**,
        the highest remaining item that qualifies, and one every user of `WillRaise` meets.
    35. The text file logger's issue list loses issues whose test name has `=` or whose message is empty: a later
        batch (the logger is opt-in).
    36. A test error's message runs the result message and the exception message together, and a descendant of
        `ETestFailureStrCompare` is not comparable: a later batch.
    37. An unclosed `(` in `--include` / `--exclude` is accepted silently: a later batch.
    38. 3.8 `Assert.AreEqual( 10, 12, 5 )` picks the `Double` overload with a tolerance of 5, and passes correctly:
        not a code defect, documentation at most (report section 7).
  - **Severity 5: cosmetic or no behaviour**
    39. A console line as long as the window loses its line break; `IsCovariantTo` testing one argument twice (no
        behaviour change); `SameValue` on records and `TValueHelper.IsUInt64` (no callers); the
        `TTestFixtureList.Sort` comparer freed twice (a private method nothing calls).
  - **Not offered at all:** section 4 (VCL GUI runner, not maintained upstream), 3.12 (withdrawn), #415.
- **Re-validation, item by item:**
  1. **Still on the current tip:** `upstream/master` was fetched at the start and again immediately before posting:
     `7c891c6` both times. Every branch is two commits on `7c891c6`.
  2. **Not already reported, fixed or declined:** GitHub search of `repo:VSoftTechnologies/DUnitX`, issues and PRs,
     open and closed (`override`, `overridden`, `virtual`, `inherited setup`, `base class setup`, `TestFixture
     inheritance`, `DoesNotContain`, `Contains empty`, `empty substring`, `StartsWith empty`, `cannot be empty`,
     `Contains`, `Log setup`, `log messages`, `previous test log`, `LogMessages`, `Status Setup`, `duration`,
     `fixture time`, `RollUpResults`, `RepeatTest time`, `options file`, `parameter file`, `response file`, `@`,
     `InternalParseFile`, `WillRaise`, `WillRaise message`, `was expecting`, `CheckExceptionClass`), and a title
     check at posting. Only #398 matches. Related, not duplicates: #95 (2014: an overridden virtual TearDown of which
     only the base class's ran; a fix was pushed then), #22, #53, #226 (fixture inheritance), #286 and #43
     (fixture timings), #50 (`WillRaise` inheritance).
  3. **Reproduced independently of the tests:** a standalone program (`probe.dpr`, built with dcc64 against upstream
     `Source`, a real `TDUnitX.CreateRunner` and `TCommandLineParser`, no test-project code) on `7c891c6`:
     - Override: three results for two test methods; `RunsTheOverride` "the overridden base implementation ran";
       `OverriddenInPublished` twice, once running the base code and once without the overriding Setup.
     - 3.7: `DoesNotContain('abc', '')` **Pass**; `Contains('abc', '')` Failure "[abc] does not contain []".
     - Log: `TestOne`'s result has only "logged by TestOne" (not Setup's line); `TestTwo`'s Setup error carries
       "logged by TestOne|Test Failed : TestOne : TestOne fails|logged in setup|".
     - Duration: a fixture with a 300 ms test and a `[RepeatTest(2)]` method: 0 ms, and 0 ms for its namespace.
     - `@<file>`: "Unknown command line option" with a full path and with a bare name; `--options:` works.
     - `WillRaise`: "Method raised [EAbort] was expecting [EConvertError]. raised", without the caller's message.
     With all six merged the same program gives: two results, both Pass; both Failure "subString cannot be empty";
     "logged in setup|logged by TestOne|" and "logged in setup|"; 315 ms for the fixture and its namespace; no
     errors; the caller's message on a new line.
  4. **Red on master on its own assertion, green with the fix, nothing else changed:** upstream's suite has 357
     tests on `7c891c6`, and only `TestMaxTime` errors there (upstream's known Win64 `[MaxTime]` crash). Each
     branch's test commit alone fails on its own assertion, with only `TestMaxTime` erroring besides; each branch
     with its fix, and the six merged together (364 tests), pass with only `TestMaxTime` erroring. No new compiler
     warning or hint (upstream's one `W1000` in `DUnitX.Tests.DUnitCompatibility.pas` is unchanged). The red build of
     #6 died on its first run without writing its XML, then completed on the next run of the same binary: the rare
     whole-process `[MaxTime]` crash noted in batches 3 and 6. The merged binary completed three runs out of three.
     - #1: "Expected [TVirtualDerived.Setup,] but got [TVirtualBase.Setup,] the Setup that runs".
     - #2: "Method did not throw any exceptions." for both cases.
     - #3: "[logged by TestOne|Test Failed : TestOne : TestOne fails|logged in setup|] contains [logged by TestOne]".
     - #4: "the fixture's duration is 0 ms, its own tests took 100 ms".
     - #5: "Condition is True when False expected. Unknown command line option : @C:\...\DUnitX.Tests.At_Prefix_Options.txt".
     - #6: "[Method raised [EAbort] was expecting [EConvertError]. raised] does not contain [the caller's message]
       WillRaise".
  5. **Severity re-checked against the reproductions:** the override and 3.7 pass silently (confirmed); the log and
     the duration are wrong in every logger's output (confirmed); `@<file>` fails loudly, so it is ranked below the
     silent wrong results; the `WillRaise` message is lost, the failure itself is kept (confirmed).
  6. **No behaviour upstream's tests assert is changed:** upstream's whole suite passes on each branch. The changes a
     suite can notice are named in the PRs: an override that repeats `[Test]` is one test (it was two, one running the
     base code); an empty substring fails `Contains` / `DoesNotContain`; a passing result's message includes what its
     Setup logged; a fixture's duration includes its own tests.
- **Merge safety:** the tests are in `Inheritance`, `Assert` (#2 and #6, at places apart), `Framework`,
  `TestFixture` and `CommandLineParser`; the fixes in `FixtureProvider`, `Assert` (#2 in `Contains` /
  `DoesNotContain`, #6 in `CheckExceptionClass*` and its four callers, at places apart), `TestRunner`,
  `FixtureResult` and `CommandLine.Parser`. All 15 pairs pass `git merge-tree`. The committed blobs keep upstream's
  form (LF in the repository under `* text eol=crlf`, no BOM on any file changed).
- **Builds:** as in batch 7: MSBuild of `Tests\DUnitXTest_D12.dproj`, Win64 Debug, `/p:DCC_BuildAllUnits=true
  /p:DelphiMocks=D:\glldelphi-mocks\Source`, with `DCC_ExeOutput` / `DCC_DcuOutput` pointed at the session's
  scratchpad and `CI` defined. Byte-exact edits by script; the scripts (edits, build, NUnit-XML summary, probe,
  posting) were in that session's scratchpad only.
- **This fork already has all six fixes** (its 2026-10-12 / 2026-10-13 versions, some broader: `ResolveFixtureMethods`,
  `ClearLogMessages` with more call sites, the `@` file through the registered options-file option), so nothing in
  `gllDUnitX` changed.
- **Batch 7's branches** were deleted from `ijbranch/DUnitX` by Ian on 2026-10-15; the fork's `master` is at
  `7c891c6`.

---

## 1. An override of an attributed virtual method runs the ancestor's code instead

**Issue**

> `TDUnitXFixtureProvider.GenerateTests` binds each method to `TRttiMethod.CodeAddress`, the static address of the declaration it finds. An override does not inherit attributes, so with `[Setup] procedure Setup; virtual;` (or `[Test]`, `[TearDown]`, `[SetupFixture]`, `[TearDownFixture]`) in a base fixture class and `procedure Setup; override;` in the fixture, the attributed base declaration is found and the base code runs: the override never runs, and whatever it checks can never fail. An override declared in a `published` section is also added as a second test of the same name, beside the base declaration's, which runs the base code. Related: #95 (2014), an overridden virtual TearDown of which only the base class's ran.
>
> Split out of #398.

**PR**: Fix an override of an attributed virtual method running the ancestor's code

> Fixes #488. One test (red on master: the base class's Setup runs). A virtual method is now bound through the fixture class's virtual method table, so the attributed ancestor declaration runs the override. An override that is also a test in its own right (in a `published` section, or with `[Test]` repeated) is then the same code, so it is added once; an override that repeats `[Test]` was two tests, one running the base code. `[TestCase]` tests are unchanged: they are invoked through RTTI, which already dispatches virtually.

---

## 2. Contains and DoesNotContain accept an empty substring, unlike StartsWith and EndsWith

**Issue**

> `Assert.DoesNotContain('abc', '')` passes, and `Assert.Contains('abc', '')` fails with "[abc] does not contain []", although every string contains an empty string. `StartsWith` and `EndsWith` fail on an empty substring ("subString cannot be empty"), which catches a test whose expected text was left empty; `DoesNotContain` passes silently instead. The `TStrings` overloads forward to these two.
>
> Split out of #398.

**PR**: Fix Contains and DoesNotContain accepting an empty substring

> Fixes #490. One test with two cases (red on master: `DoesNotContain` does not fail). Both now fail with `SStrCannotBeEmpty`, as `StartsWith` and `EndsWith` do. No existing test passes an empty substring to either.

---

## 3. A test result carries the previous test's log and loses what its Setup logged

**Issue**

> The runner clears its log when `ExecuteTest` starts, which is after Setup has run, and after a test passes, but not after a failure. So what a `[Setup]` logs never reaches its test's result, and when a Setup fails after a failing test, its error result carries that test's log, including the runner's "Test Failed" line for it. The error results of `[SetupFixture]` and `[TearDownFixture]` carry the log of the last failing test in the same way.
>
> Split out of #398.

**PR**: Fix a result carrying the previous test's log and losing what Setup logged

> Fixes #492. One test (red on master: the second test's Setup error carries the first test's log). The log is now cleared before each test's Setup, and before `[SetupFixture]` and `[TearDownFixture]`, instead of when the test body starts (new private `ClearLogMessages`). The message of a passing result, which is the log text, now includes what its Setup logged.

---

## 4. The duration of a fixture with child fixtures leaves out its own tests

**Issue**

> `TDUnitXFixtureResult.RollUpResults` sets the duration of a fixture that has child fixtures to the sum of its children's, and its finish time to the latest of theirs. A fixture's `[RepeatTest]` methods are child fixtures, so a fixture with a 300 ms test and a `[RepeatTest(2)]` method is reported as taking 0 ms, in the NUnit and JUnit XML as well, and the namespaces above it add up the same shortfall. Related: #286, and #43 (namespaces should include the time of their children).
>
> Split out of #398.

**PR**: Fix the duration of a fixture with child fixtures leaving out its own tests

> Fixes #494. One test (red on master: 0 ms for a fixture whose own tests took 100 ms). Every fixture result now takes its duration and finish time from its own stopwatch, which starts with the fixture and stops after its children have rolled up: a namespace still includes the time of its children (#43), and a fixture with children now includes its own tests too. The local `Max`, no longer used, is removed.

---

## 5. @<file> on the command line is reported as an unknown option

**Issue**

> The parser strips a leading `@` from an argument, as it does `--`, `-` and `/`, but then looks the file name up as an option name, so `@options.txt` gives "Unknown command line option : @options.txt". With a full path the drive colon also splits the name into a key and a value. `--options:options.txt` works.
>
> Split out of #398.

**PR**: Fix @<file> on the command line never reading the options file

> Fixes #496. One test (red on master: unknown option). An argument that starts with `@` is read as an options file, its name taken whole. The file-exists check and the error handling move from the `--options` branch into `InternalParseFile`, which both now call; the messages are unchanged.

---

## 6. A WillRaise failure for the wrong exception class drops the caller's message

**Issue**

> When the method raises an exception of another class, `WillRaise`, `WillRaiseDescendant`, `WillRaiseWithMessage` and `WillRaiseWithMessageRegex` fail through `CheckExceptionClass` / `CheckExceptionClassDescendant`, which do not take the caller's `msg`. `Assert.WillRaise(proc, EConvertError, 'the context')`, with `proc` raising `EAbort.Create('raised')`, fails with "Method raised [EAbort] was expecting [EConvertError]. raised", without "the context". The message is shown only when nothing is raised.
>
> Split out of #398.

**PR**: Fix a WillRaise failure for the wrong exception class dropping the caller's message

> Fixes #498. One test (red on master), covering `WillRaise`, `WillRaiseDescendant` and `WillRaiseWithMessage`. The two private checks take the message and add it on a new line, as the failure for no exception does.

---

**One line at the end of each PR:**

> Tested with Delphi 13 only, Win64 Debug; not built for Win32, older compilers or non-Windows targets.
