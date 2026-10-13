# DUnitX upstream: batch 4 (issues and PRs posted)

Six issues and their PRs, built and posted 2026-10-14 against `master` @ `8ff5f0b` (after upstream merged five of
batch 3). Issue bodies end "Split out of #398."; PR bodies are "Fixes #N." plus a short note plus the one-line
caveat at the end of this file. Branches are in the worktree `D:\gllDUnitX-upstream` (remote `dunitx-fork`),
pushed to [`ijbranch/DUnitX`](https://github.com/ijbranch/DUnitX). Each branch has a commit with the failing
test(s), then the fix. "Allow edits by maintainers" is on for every PR.

| # | Report item | Issue | PR | Branch |
|---|---|---|---|---|
| 1 | 3.2 + 3.5 (part) | [#438](https://github.com/VSoftTechnologies/DUnitX/issues/438) | [#439](https://github.com/VSoftTechnologies/DUnitX/pull/439) | `fix/willnotraise-nil-class` |
| 2 | 3.5 (part) | [#440](https://github.com/VSoftTechnologies/DUnitX/issues/440) | [#441](https://github.com/VSoftTechnologies/DUnitX/pull/441) | `fix/areequal-cardinal-message` |
| 3 | 3.6 (rest) | [#442](https://github.com/VSoftTechnologies/DUnitX/issues/442) | [#443](https://github.com/VSoftTechnologies/DUnitX/pull/443) | `fix/tstrings-same-instance` |
| 4 | 3.10 (part) | [#444](https://github.com/VSoftTechnologies/DUnitX/issues/444) | [#445](https://github.com/VSoftTechnologies/DUnitX/pull/445) | `fix/junit-timestamp-separator` |
| 5 | 2.7 (part) | [#446](https://github.com/VSoftTechnologies/DUnitX/issues/446) | [#447](https://github.com/VSoftTechnologies/DUnitX/pull/447) | `fix/nunit-errored-fixture-result` |
| 6 | 2.7 (part) | [#448](https://github.com/VSoftTechnologies/DUnitX/issues/448) | [#449](https://github.com/VSoftTechnologies/DUnitX/pull/449) | `fix/fixtureresult-namespace` |

## How this batch was chosen and built

- **Same rule as batch 3:** only defects where the old behaviour is plainly wrong (a crash, a wrong message,
  wrong output). G (`ToVarRec` dangling pointers) needs an API change and 2.2 (`FreeAndNil` on a raising
  destructor) cannot be tested reliably, so both stay for later.
- **#1 corrects two existing upstream tests.** `WillNotRaiseWithMessage_NilExceptionParam_NoExceptionMessage_WillRaise`
  and `..._MatchingExceptionMessage_WillRaise` used a bare `Assert.WillRaise`, which since #408 re-raises a test
  failure it did not ask for; they passed only on the access violation. They now expect `ETestFailure`.
- **2.7 went in two halves on purpose:** the NUnit logger now also checks `ErrorCount`, leaving `HasFailures`
  itself alone (changing what a public property counts is the kind of thing #415 was closed over). Leak counts in
  the headers stay for a later batch.
- **Merge safety:** each PR touches one source file and one test file; the three Assert PRs put their tests at
  different places; the two logger tests add `uses` entries only in their own test file; the namespace test
  constructs a real `TDUnitXTestFixture` in `DUnitX.Tests.TestFixture.pas` so it shares no file with #5. All 15
  pairs pass `git merge-tree`, and every branch builds alone.
- **Red / green:** master plus all the tests: the 9 new or corrected tests fail on their own assertions; with the
  fixes, 332 pass and only `TestMaxTime` errors (upstream's known `[MaxTime]` crash on Win64).
- **Building upstream's tests with `DCC_BuildAllUnits` needs `/p:DelphiMocks=D:\glldelphi-mocks\Source`**;
  without it the build only worked off a stray `Delphi.Mocks.dcu` in the Public `dcu\Win64\Debug` folder.
- **XE2:** upstream still supports it, so nothing here uses later RTL (the Cardinal fix casts to `Int64`).

---

## 1. WillNotRaiseDescendant / WillNotRaiseWithMessage raise an access violation when the exception class is nil

**Issue**

> exceptionClass defaults to nil, but when the method raises, both build their failure message from `exceptionClass.ClassName`, so `Assert.WillNotRaiseDescendant(proc)` or `Assert.WillNotRaiseWithMessage(proc)` ends in an access violation instead of a test failure. Also, when a descendant is raised, `WillNotRaiseDescendant` names the expected base class rather than the class that was raised.
>
> The two existing `WillNotRaiseWithMessage_NilExceptionParam_*_WillRaise` tests pass only because of the access violation: they use `Assert.WillRaise` with no class.

**PR**: Fix WillNotRaiseDescendant/WillNotRaiseWithMessage access violation on a nil exception class

> Fixes #438. Both now name the class that was raised (`e.ClassName`); with a nil class `WillNotRaiseDescendant` fails with the `WillNotRaiseAny` message. Two new tests (red on master), and the two existing nil-class tests now expect `ETestFailure` (on master they fail with the access violation). `SMethodRaisedExceptionAlt` is no longer used but is left in place.

---

## 2. AreEqual(Cardinal) prints values above High(Integer) as negative

**Issue**

> `AreEqual(Cardinal)` passes its values straight to `SUnexpectedErrorInt` (`%d`), so comparing `High(Cardinal)` with 0 reports "Expected [-1] but got [0]".

**PR**: Fix AreEqual(Cardinal) printing large values as negative

> Fixes #440. One test (red on master). The values are passed as Int64.

---

## 3. AreEqual(TStrings, TStrings) fails when both arguments are the same instance

**Issue**

> `AreEqual(TStrings, TStrings)` starts with `IsTrue(expected <> actual, message)`, so comparing a list with itself fails with "Condition is False when True expected".

**PR**: Fix AreEqual(TStrings) failing when both arguments are the same instance

> Fixes #442. One test (red on master). The same instance now passes; two nil arguments still fail as before.

---

## 4. JUnit timestamp uses the locale time separator

**Issue**

> The JUnit logger writes the testsuite `timestamp` with `FormatDateTime('yyyy-MM-dd"T"hh:nn:ss')`. An unquoted `:` is the locale's time separator, so with `TimeSeparator = '.'` it writes `2026-10-14T08.38.03`, which is not ISO 8601. The NUnit logger already quotes it.

**PR**: Fix JUnit timestamp using the locale time separator

> Fixes #444. One test that sets `FormatSettings.TimeSeparator := '.'` (red on master). The colons are quoted.

---

## 5. NUnit XML reports a fixture whose tests errored as result="Success"

**Issue**

> The NUnit logger sets the fixture's `result` and `success` from `HasFailures`, which counts failures only. A fixture whose tests raised (errors, not failures) is written `result="Success" success="True"`.

**PR**: Fix NUnit fixture result reporting Success when its tests errored

> Fixes #446. One test (red on master). The logger now also checks `ErrorCount`; `HasFailures` itself is unchanged.

---

## 6. IFixtureResult.Namespace returns the fixture name

**Issue**

> `TDUnitXFixtureResult.GetNamespace` returns `FName` instead of `FNameSpace`.

**PR**: Fix IFixtureResult.Namespace returning the fixture name

> Fixes #448. One test (red on master). Nothing in DUnitX itself reads it, so no output changes.

---

**One line at the end of each PR:**

> Tested with Delphi 13 only, Win64 Debug; not built for Win32, older compilers or non-Windows targets.
