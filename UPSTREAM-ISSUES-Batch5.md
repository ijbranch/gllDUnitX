# DUnitX upstream: batch 5 (all six merged 2026-10-15)

Six issues and their PRs, built and posted 2026-10-15 against `master` @ `687af04` (after upstream merged #429 and
all of batch 4). Issue bodies end "Split out of #398."; PR bodies are "Fixes #N." plus a short note plus the one-line
caveat at the end of this file. Branches are in the worktree `D:\gllDUnitX-upstream` (remote `dunitx-fork`),
pushed to [`ijbranch/DUnitX`](https://github.com/ijbranch/DUnitX). Each branch has a commit with the failing
test(s), then the fix. "Allow edits by maintainers" is on for every PR.

| # | Report item | Issue | PR | Branch | Merged |
|---|---|---|---|---|---|
| 1 | 3.10 (rest) | [#452](https://github.com/VSoftTechnologies/DUnitX/issues/452) | [#453](https://github.com/VSoftTechnologies/DUnitX/pull/453) | `fix/nunit-assembly-time` | 2026-10-15 `8d91bcf` |
| 2 | 2.7 (rest) | [#454](https://github.com/VSoftTechnologies/DUnitX/issues/454) | [#455](https://github.com/VSoftTechnologies/DUnitX/pull/455) | `fix/xml-header-leak-counts` | 2026-10-15 `4273e0f` |
| 3 | fork fix, not in the report | [#456](https://github.com/VSoftTechnologies/DUnitX/issues/456) | [#457](https://github.com/VSoftTechnologies/DUnitX/pull/457) | `fix/junit-testsuite-counts` | 2026-10-15 `61f1d3e` |
| 4 | 3.9 (rest) | [#458](https://github.com/VSoftTechnologies/DUnitX/issues/458) | [#459](https://github.com/VSoftTechnologies/DUnitX/pull/459) | `fix/nunit-category-escape` | 2026-10-15 `1460934` |
| 5 | 3.11 | [#460](https://github.com/VSoftTechnologies/DUnitX/issues/460) | [#461](https://github.com/VSoftTechnologies/DUnitX/pull/461) | `fix/dontshowignored-value` | 2026-10-15 `1e95e6b` |
| 6 | 2.2 | [#462](https://github.com/VSoftTechnologies/DUnitX/issues/462) | [#463](https://github.com/VSoftTechnologies/DUnitX/pull/463) | `fix/raising-destructor-teardown` | 2026-10-15 `3efb0eb` |

Sent the same day, outside the batch: [PR #451](https://github.com/VSoftTechnologies/DUnitX/pull/451) removes
`ToVarRec` / `ToVarRecs` (G), as Vincent chose on #450. It merged on 2026-10-15 (`615be86`).

## How this batch was chosen and built

- **Same rule as batches 3 and 4:** only defects whose old behaviour is plainly wrong, each testable without the IDE
  or a second runner. Left for later: 1.5, 1.12 and 2.1 (this fork's fixes depend on its own second-runner and
  fixture-construction changes, so they are not small upstream PRs), 1.6, 1.11, 3.7 and 2.9 (each changes what a
  suite sees), 5.1-5.4 (IDE expert, no test possible), A-C and 2.3-2.6.
- **Dropped while building:** the 2.7 note "`RollUpResults` ignores leak counts" is invisible upstream, because
  `IFixtureResult` has no leak count. Its slot went to #3, a JUnit fix this fork already carries.
- **Kept small:** 3.9's exe-path half is not sent (`ParamStr(0)` cannot be set from a test), and the 3.10 fix
  changes one line, so it does not overlap the header-count fix.
- **#5 adds `RegisterOptions` to the interface of `DUnitX.OptionsDefinition`.** The parser tests clear the option
  registry in Setup and TearDown, so the test cannot rely on the options registered at start-up.
- **#6's test frees the leaked instance itself.** A destructor that raises leaves the object's memory allocated;
  with the fix the instance is released by `FreeInstance` in the test, and on master the second destructor run frees it.
- **Merge safety:** the three NUnit tests and the two JUnit tests sit at different places in their files; the new
  tests use only `uses` entries already there (from #445 and #447), except #5, which adds one in its own test file.
  All 21 pairs of the six branches and #451 pass `git merge-tree`; every branch builds and runs alone.
- **Red / green:** master plus all the tests: the 7 new tests fail on their own assertions; with the fixes
  everything passes and only `TestMaxTime` errors (upstream's known `[MaxTime]` crash on Win64). The scripts
  (byte-exact edits, the build, the NUnit-XML summary) were in that session's scratchpad only.

---

## 1. NUnit XML: the assembly test-suite time attribute holds the start time

**Issue**

> The NUnit logger writes the Assembly `<test-suite>` `time` attribute from the same `sTime` as the `<test-results>` header, `FormatDateTime('hh":"nn":"ss', StartTime)`, so it holds the clock time the run started (`time="11:27:15"`). On a test-suite element `time` is the duration in seconds, which is how the fixture and test-case elements already write it.

**PR**: Fix NUnit assembly time attribute holding the start time

> Fixes #452. One test (red on master). The assembly suite now writes the run's duration in seconds, formatted as the fixtures are; the `<test-results>` header keeps its date and time.

---

## 2. NUnit and JUnit header counts leave out leaked tests

**Issue**

> A test that leaks memory is written as `result="Failure"` by the NUnit logger and as `<error>` by the JUnit logger, but the header counts leave it out: the NUnit `<test-results>` `failures` is `FailureCount` and the JUnit `<testsuites>` `errors` is `ErrorCount`. A run whose only problem is a leak has `failures="0" errors="0"` in the header, with a failed test case below it.

**PR**: Fix NUnit and JUnit header counts leaving out leaked tests

> Fixes #454. Two tests (red on master), one per logger. `MemoryLeakCount` is added to the NUnit header's `failures` and to the JUnit header's `errors`, matching how each logger writes the leaked test case.

---

## 3. JUnit testsuite errors/failures/disabled do not match its test cases

**Issue**

> For each `<testsuite>` the JUnit logger takes `tests` from the fixture's own `TestResults.Count`, but `errors`, `failures` and `disabled` from `ErrorCount`, `FailureCount` and `IgnoredCount`. Those leave out leaked tests, which are written as `<error>`, so a suite with one leaked test says `errors="0"`; and they are rolled up from child fixtures, which the logger writes as suites of their own.

**PR**: Fix JUnit testsuite counts not matching its test cases

> Fixes #456. One test (red on master), for the leaked test. The three counts are now taken from the suite's own test cases, as `tests` already is.

---

## 4. NUnit logger writes category names unescaped

**Issue**

> `WriteCategoryNodes` writes `<category name="%s" />` with the raw category name, so a category such as `Slow & Steady` produces ill-formed XML.

**PR**: Fix NUnit logger writing category names unescaped

> Fixes #458. One test (red on master). The name goes through `EscapeForXML`.

---

## 5. --dontshowignored ignores its value

**Issue**

> The option is registered with `HasValue := false`, but it can still be given a value, and its handler sets `TDUnitX.Options.DontShowIgnored := true` whatever the value is. So `--dontshowignored:false` (or `-dsi:false`) turns it on.

**PR**: Fix --dontshowignored ignoring its value

> Fixes #460. The handler now uses its value; `--dontshowignored` on its own still turns it on. One test (red on master) covers both. The parser tests clear the option registry, so the test registers the options itself: `RegisterOptions` is now declared in the interface of `DUnitX.OptionsDefinition`.

---

## 6. Fixture teardown destructor runs again when it raises

**Issue**

> When a fixture's destructor is used as its teardown, `ExecuteFixtureTearDown` does `FFixtureInstance.Free; FFixtureInstance := nil;`. If the destructor raises, the field is not cleared, and `TDUnitXTestFixture.Destroy` frees the instance again, running the destructor a second time on a half-destroyed object.

**PR**: Fix a raising destructor teardown being run again

> Fixes #462. One test (red on master: the destructor runs twice). `FreeAndNil` clears the field before freeing.

---

**One line at the end of each PR:**

> Tested with Delphi 13 only, Win64 Debug; not built for Win32, older compilers or non-Windows targets.
