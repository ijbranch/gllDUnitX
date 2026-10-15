# DUnitX upstream: batch 7 (all six merged 2026-10-15)

Six issues and their PRs, built and posted 2026-10-15 against `master` @ `59a9ab5` (after upstream merged all of
batch 6). Issue bodies end "Split out of #398."; PR bodies are "Fixes #N." plus a short note plus the one-line
caveat at the end of this file. Branches are in the worktree `D:\gllDUnitX-upstream` (remote `dunitx-fork`),
pushed to [`ijbranch/DUnitX`](https://github.com/ijbranch/DUnitX). Each branch has a commit with the failing
test, then the fix. "Allow edits by maintainers" is on for every PR.

| # | Report item | Severity | Issue | PR | Branch | Merged |
|---|---|---|---|---|---|---|
| 1 | 1.5 | 1: a test passes that should fail | [#476](https://github.com/VSoftTechnologies/DUnitX/issues/476) | [#477](https://github.com/VSoftTechnologies/DUnitX/pull/477) | `fix/testcase-willraise` | 2026-10-15 `5c193a3` |
| 2 | 1.12 | 1: repetitions run without Setup / TearDown | [#478](https://github.com/VSoftTechnologies/DUnitX/issues/478) | [#479](https://github.com/VSoftTechnologies/DUnitX/pull/479) | `fix/repeattest-setup` | 2026-10-15 `70cee9c` |
| 3 | 1.11 (opt-in) | 1: a run goes green with nothing tested | [#480](https://github.com/VSoftTechnologies/DUnitX/issues/480) | [#481](https://github.com/VSoftTechnologies/DUnitX/pull/481) | `fix/fail-on-no-tests` | 2026-10-15 `23d56c5` |
| 4 | 2.1 | 2: wrong counts | [#482](https://github.com/VSoftTechnologies/DUnitX/issues/482) | [#483](https://github.com/VSoftTechnologies/DUnitX/pull/483) | `fix/teardownfixture-reported-once` | 2026-10-15 `05cc7d8` |
| 5 | 2.5 (c) | 2: false leak report | [#484](https://github.com/VSoftTechnologies/DUnitX/issues/484) | [#485](https://github.com/VSoftTechnologies/DUnitX/pull/485) | `fix/leak-check-net-growth` | 2026-10-15 `7c891c6` |
| 6 | 2.6 | 3: lost diagnostics | [#486](https://github.com/VSoftTechnologies/DUnitX/issues/486) | [#487](https://github.com/VSoftTechnologies/DUnitX/pull/487) | `fix/teardown-keeps-failure` | 2026-10-15 `87f3307` |

## How this batch was chosen and built

- **Ranking.** Every unsent defect (report sections 1-3, 6 and 8, and the fixes this fork carries from its
  2026-10-13 review) was ranked by what it does to a suite: (1) a test passes or a run goes green when it should
  fail; (2) wrong results or counts, or a broken run; (3) lost diagnostics; (4) wrong messages and robustness;
  (5) cosmetic. The six highest that could be sent small, with a test that fails on master on its own assertion,
  were taken. Two allowances were new in this batch: a test may run a fixture through a `TDUnitXTestRunner` of its
  own on a thread of its own (a second runner on the test's thread collides in `FActiveRunners`), and a fix that
  would change existing behaviour is sent as an opt-in with the default unchanged (#3).
- **Passed over, highest severity first:**
  - **Severity 1:**
    - **2.9** (a misnamed `[TestCaseProvider]` gives zero tests): the fix makes such a method an error, a behaviour
      change, and needs a new error-test class; #3's option catches the case where the whole run selects nothing.
    - **1.6** (bad `[TestCase]` data silently converted): a behaviour change that upstream's own suite relies on
      (this fork had to correct 14 of its cases and the `SingleName` cases when it made the change).
    - **`WillNotRaise( proc, SomeClass )` swallowing a different exception** (this fork's 2026-10-13 fix): upstream's
      own tests assert the swallowing (`WillNotRaiseWithMessage_NonMatchingExceptionParam_*_WillNotRaise`), so it is
      upstream's design; there is no sensible opt-in.
    - **`CheckSame( TObject )` passing for two different objects:** reproduced on master (`AreEqual<TObject>` calls
      `Equals`), but an identity check is the change upstream declined in #415.
    - **`Assert.IsType<T>` can never fail:** the only fixes (always fail, or remove it) change every caller; a design
      question, not a small PR.
    - **An override of an attributed virtual method runs the ancestor's code:** this fork's fix
      (`ResolveFixtureMethods`) is a larger rework; binding through the VMT alone would make an override that repeats
      `[Test]` run the same code twice.
  - **Severity 2:**
    - **2.3** (one raising fixture constructor aborts the run) and **the Win64 `[MaxTime]` crash** (section 6): this
      fork's fixes rest on its larger fixture-construction and test-timing changes.
    - **A, B and 2.5 (a) / (b)** (false leak reports from phase sums, `Log`, `Assert.Pass`): need this fork's
      runner-allocation accounting, as in batch 6.
    - **`--run` matching any fixture whose name starts with the text:** changes which tests a filter selects (the
      reason 2.8 is not sent either).
  - **Not offered at all:** section 4 (VCL GUI runner, not maintained upstream), 5.x (IDE expert, no test possible),
    3.12 (withdrawn), C (needs FastMM5 in upstream's test project), 2.8 (this fork does not change it either).
- **Re-validation (Ian: "Re-validate the DUnitX issues before raising the PRs"), item by item:**
  1. **Still on the current tip:** `upstream/master` was fetched at the start, after batch 6's last merges, and
     again immediately before posting: `59a9ab5` both times. Every defect below was reproduced on `59a9ab5`.
  2. **Not already reported, fixed or declined:** GitHub search of `repo:VSoftTechnologies/DUnitX`, issues and PRs,
     open and closed, by keyword and by routine (`WillRaise TestCase`, `TestCaseProvider`, `AddTestCase`,
     `RepeatTest`, `RepeatTest Setup`, `no tests`, `zero tests`, `AllPassed`, `exit code tests`, `failonnotests`,
     `TearDownFixture`, `ExecuteTearDownFixtureMethod`, `InvalidateTestsInFixture`, `CheckMemoryAllocations`,
     `bytes were leaked`, `leaked`, `TearDown exception`, `TearDown error message`, and more). Only #398 itself
     matches. Related, not duplicates: #96 (fixed: repetitions had no Setup at all; its copy is what #2 moves),
     #116 and #315 (`[SetupFixture]` with `[RepeatTest]`), #346 (closed: the same double reporting for
     `[SetupFixture]`), #206 (the `[WillRaise]` leak, which batch 6's #467 fixed). No title duplicates at posting.
  3. **Reproduced independently of the tests:** a standalone program (`probe.dpr`, built with dcc64 against
     upstream `Source`, real `TDUnitX.CreateRunner`, no test-project code) on `59a9ab5`:
     - 1.5: `[TestCase] [WillRaise(EAbort)]` with an empty body is **Pass**; one that raises `EAbort` is **Error**.
     - 1.12: `[RepeatTest(2)]` with the `[Setup]` in a base class, and with it declared after the method: all four
       repetitions fail "Setup did not run".
     - 1.11: `--run:` naming nothing: `TestCount=0`, `AllPassed=True`, `ExitCodeFor=0`, exit code 0.
     - 2.1: two passing tests and a raising `[TearDownFixture]`: four results (PassesOne and PassesTwo each Pass and
       Error), `TestCount` 4.
     - 2.5 (c): a second program under FastMM5 with upstream's `DUnitX.MemoryLeakMonitor.FastMM5`: a test that
       frees a 1 MB buffer allocated in `[SetupFixture]` is **MemoryLeak** "-1048530 bytes were leaked in the test
       method".
     - 2.6: `Assert.Fail('the real failure')` plus a raising `[TearDown]`: **Error** "teardown failed".
     With all six fixes merged the same programs give: Failure / Pass; all repetitions Pass; exit 0 by default and 1
     with `--failonnotests`; two passes and one `TearDownFixture` Error (also through the console, NUnit and JUnit
     loggers); Pass; Failure "the real failure".
  4. **Red on master on its own assertion, green with the fix, nothing else changed:** upstream's suite has 348
     tests on `59a9ab5` (each red build ran 348 plus its own new tests), and only `TestMaxTime` errors there
     (upstream's known Win64 `[MaxTime]` crash). Each branch's test commit
     alone fails on its own assertion (below), with only `TestMaxTime` erroring besides; each branch with its fix,
     and the six merged together (357 tests), pass with only `TestMaxTime` erroring. No new compiler warning or hint
     (upstream's one `W1000` in `DUnitX.Tests.DUnitCompatibility.pas` is unchanged).
     - #1: "Method did not throw any exceptions. CaseDoesNotRaise.Zero does not raise the expected exception".
     - #2: "Expected [Setup] but got []" for both cases.
     - #3: "Unknown command line option : --failonnotests" (the default-unchanged assertion before it passes).
     - #4: "Expected [3] but got [4]". A mutation of the fix that did not keep the new teardown tests alive failed
       the test's name check (`(no test)`): a result holds its test weakly. The first probe run of the fix found
       this (an access violation reading the result's test), which is why the runner now keeps them.
     - #5: "the test freed 64 bytes allocated before it: -64 bytes were leaked in the test method".
     - #6: "[the TearDown error] does not contain [the test failure]" and "... [the Setup error]".
  5. **Severity re-checked against the reproductions:** 1.5 passes silently (confirmed); 1.12 shows as false
     failures when Setup is needed and passes silently only when the checks sit in TearDown, so it is ranked below
     1.5; 1.11 goes green with nothing run (confirmed); 2.1 inflates the counts (confirmed); 2.5 (c) is a false
     failure (confirmed with a real monitor); 2.6 keeps the result failing but loses the message, location and type,
     and turns a Failure into an Error (confirmed).
  6. **Opt-in default unchanged:** #3's test asserts `ExitCodeFor` of a run with no tests is `EXIT_OK` before the
     option is parsed; the option defaults to off, `AllPassed` is not touched, and the probe exits 0 without it.
- **Merge safety:** each PR puts its test in a different test unit (`TestDataProvider`, `Inheritance`,
  `CommandLineParser`, `TestFixture`, `MemoryLeaks`, `Framework`, the last previously empty), so no two share a
  test file; #4, #5 and #6 all change `Source\DUnitX.TestRunner.pas`, at places far apart. All 15 pairs pass
  `git merge-tree`. The committed blobs keep upstream's form (LF in the repository under `* text eol=crlf`, BOM only
  on `DUnitX.TestFramework.pas`, as before).
- **Builds:** MSBuild of `Tests\DUnitXTest_D12.dproj`, Win64 Debug, `/p:DCC_BuildAllUnits=true
  /p:DelphiMocks=D:\glldelphi-mocks\Source`, with `DCC_ExeOutput` / `DCC_DcuOutput` pointed at the session's
  scratchpad, so nothing was written to the Public `dcu` / `bin` folders, and `CI` defined so the runner does not
  pause. The scripts (byte-exact edits, the build, the NUnit-XML summary, the probes, the posting) were in that
  session's scratchpad only.
- **Batch 6's branches:** each of the six branches on `ijbranch/DUnitX` has the same patch ID as its squash merge
  commit (#465 `e4f55e9`, #467 `59a9ab5`, #469 `09510e2`, #471 `70aedc8`, #473 `abbd0cf`, #475 `fd6621b`); they are
  left for Ian to delete. The fork's `master` was fast-forwarded to `59a9ab5`.

---

## 1. [WillRaise] is ignored on [TestCase] and [TestCaseProvider] methods

**Issue**

> `TDUnitXFixtureProvider.GenerateTests` reads `[WillRaise]` but passes it only to `AddTest`. `ITestFixture.AddTestCase` has no expected-exception parameter and always creates a plain `TDUnitXTestCase`, so on a method that also has `[TestCase]` or `[TestCaseProvider]` the attribute is silently dropped. If the code under test stops raising, every case passes: `[Test] [TestCase('Zero', '0')] [WillRaise(EAbort)] procedure M(const value : integer);` with an empty body is reported as passed. A case that does raise as expected is reported as an error. `[MaxTime]` is dropped from test cases in the same way.
>
> Split out of #398.

**PR**: Fix [WillRaise] being dropped from [TestCase] and [TestCaseProvider] tests

> Fixes #476. One test (red on master: a case that does not raise passes). `AddTestCase` takes the expected exception and its inheritance, defaulted so existing callers compile unchanged, and `TDUnitXTestCase.Execute` checks them as `TDUnitXExceptionTest` does. `[MaxTime]` on test cases is left as it is, since applying it there would bring the Win64 `[MaxTime]` crash (#398) to test cases. An implementation of `ITestFixture` outside DUnitX would need the new `AddTestCase` signature.

---

## 2. [RepeatTest] repetitions run without a Setup or TearDown declared in a base class or after the method

**Issue**

> The repetitions of a `[RepeatTest(n)]` method are the tests of a child fixture, which copies the fixture's Setup and TearDown when `GenerateTests` reaches the method (the copy added for #96). `GetMethods` returns the class's own methods before inherited ones, so a `[Setup]` or `[TearDown]` declared in a base fixture class, or declared after the repeated method, has not been seen yet: every repetition runs without Setup and TearDown, while the fixture's other tests have them, and checks made in TearDown never run.
>
> Split out of #398.

**PR**: Fix [RepeatTest] repetitions missing a Setup or TearDown found after the method

> Fixes #478. One test with two cases, a base-class Setup and a Setup declared after the method (red on master: the child fixture has no Setup). The repeat child fixtures are given the fixture's Setup and TearDown once all its methods have been seen.

---

## 3. A run in which no test executes exits 0

**Issue**

> A run in which no test executes, for example because a `--run` or `--include` value has a typo, or because every selected test is ignored, reports `AllPassed` and exits 0, so CI goes green with nothing tested. Changing the default would break runs that legitimately select nothing, so this asks for an opt-in, like `--failonignored`.
>
> Split out of #398.

**PR**: Add --failonnotests: a run in which no test executes gives a non zero exit code

> Fixes #480. Adds `--failonnotests` (`-fnt`, `TDUnitX.Options.FailOnNoTests`), off by default: when no test executed (`TestCount - IgnoredCount = 0`), `ExitCodeFor` returns `EXIT_ERRORS` in Simple mode and adds the new `EXIT_BIT_NO_TESTS` ($20) in Bitmask mode. Without the option nothing changes, which the test checks first; `AllPassed` is unchanged. One test (red on master: the option is unknown).

---

## 4. A [TearDownFixture] failure reports every test of the fixture a second time

**Issue**

> When `[TearDownFixture]` (or a destructor teardown) raises, `ExecuteTearDownFixtureMethod` calls `InvalidateTestsInFixture`, which reports every test of the fixture again, with `BeginTest` / `EndTest` and a second result, an Error, although they have all run and been recorded. A fixture with two passing tests gives four results: two passes and two errors for the same two tests. `TestCount` is inflated and the XML lists each test twice. It is the double reporting that #346 described for `[SetupFixture]`.
>
> Split out of #398.

**PR**: Fix a [TearDownFixture] failure re-reporting every test of the fixture

> Fixes #482. One test (red on master: four results for two tests). The failure is now recorded once, as an Error result in the fixture's results named after the teardown method (`TearDownFixture`, or `Destroy` for a destructor). A result holds its test weakly, so the runner keeps these tests for its lifetime. Checked with the console, NUnit and JUnit loggers.

---

## 5. Memory freed by a test is reported as a negative leak

**Issue**

> `TDUnitXTestRunner.CheckMemoryAllocations` treats any non-zero sum of the setup, test and teardown growth as a leak, so a test that frees memory allocated before it ran fails as a leak of a negative size. With the FastMM5 monitor, a test that frees a 1 MB buffer allocated in `[SetupFixture]` is reported as "-1048530 bytes were leaked in the test method".
>
> Split out of #398.

**PR**: Fix memory freed by a test being reported as a negative leak

> Fixes #484. One test (red on master), with a monitor that reports fixed growth for each phase. Only net growth, a sum above zero, is a leak; the test also checks that net growth is still reported.

---

## 6. A TearDown error replaces the Setup or test failure

**Issue**

> When a test fails and its `[TearDown]` then raises, `ExecuteTests` replaces the test's result with the TearDown error, so the failure being diagnosed (its message, location and type) is lost: a test that fails with `Assert.Fail('the real failure')` is reported as an Error with only the TearDown's message. A failed Setup's error is replaced in the same way.
>
> Split out of #398.

**PR**: Fix a TearDown error replacing the Setup or test failure

> Fixes #486. Two tests (red on master); a third checks that a passing test whose TearDown raises still reports the TearDown error. When Setup or the test has already failed, that result is kept and the TearDown error is logged (new resource string `STearDownErrorAfterFailure`). TearDown still runs after a failed Setup, as before.

---

**One line at the end of each PR:**

> Tested with Delphi 13 only, Win64 Debug; not built for Win32, older compilers or non-Windows targets.
