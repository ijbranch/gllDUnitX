# DUnitX upstream: batch 2 (issues and PRs posted)

Six issues and their PRs, built and posted 2026-10-13 against `master` @ `6af7aeb` (after upstream merged all of batch 1,
#405-#411). Issue bodies are as below plus "Split out of #398"; PR bodies are as below plus the one-line caveat at
the end of this file. Branches are in the worktree `D:\gllDUnitX-upstream` (remote `dunitx-fork`), pushed to
[`ijbranch/DUnitX`](https://github.com/ijbranch/DUnitX). Each branch has a commit with the failing test(s), then the
fix. "Allow edits by maintainers" is on for every PR.

| # | Report item | Issue | PR | Branch |
|---|---|---|---|---|
| 1 | D | [#412](https://github.com/VSoftTechnologies/DUnitX/issues/412) | [#413](https://github.com/VSoftTechnologies/DUnitX/pull/413) | `fix/willnotraise-swallows-test-outcomes` |
| 2 | 3.3 | [#414](https://github.com/VSoftTechnologies/DUnitX/issues/414) | [#415](https://github.com/VSoftTechnologies/DUnitX/pull/415) | `fix/aresame-identity` |
| 3 | 1.8 | [#416](https://github.com/VSoftTechnologies/DUnitX/issues/416) | [#417](https://github.com/VSoftTechnologies/DUnitX/pull/417) | `fix/dunit-checkinherits-reversed` |
| 4 | E | [#418](https://github.com/VSoftTechnologies/DUnitX/issues/418) | [#419](https://github.com/VSoftTechnologies/DUnitX/pull/419) | `fix/dunit-checkequalsbin-digits` |
| 5 | 1.7 | [#420](https://github.com/VSoftTechnologies/DUnitX/issues/420) | [#421](https://github.com/VSoftTechnologies/DUnitX/pull/421) | `fix/dunit-string-checks-case` |
| 6 | section 6 (side note on #410) | [#422](https://github.com/VSoftTechnologies/DUnitX/issues/422) | [#423](https://github.com/VSoftTechnologies/DUnitX/pull/423) | `fix/xml-file-logger-bare-file-name` |

## Outcome (2026-10-13)

- **Merged:** #413, #419, #417, #421, #423 (5 of 6). Upstream `master` @ `fa41545` after the last of them.
- **Not taken:** #415 (`AreSame` identity) and its issue #414, closed unmerged without comment after Vincent raised a
  behaviour-change reservation and we replied. gllDUnitX keeps the fix.
- **Follow-up regression, fixed:** [#424](https://github.com/VSoftTechnologies/DUnitX/issues/424) (luebbe): batch 1's
  #407 `ValuesEqual<T>` raised an AV for a type without RTTI (`TypeInfo` nil, e.g. an enum with explicit ordinals).
  Fixed by [#425](https://github.com/VSoftTechnologies/DUnitX/pull/425) (nil guard plus test), merged; upstream
  `master` @ `a710952`. gllDUnitX was never affected: its `AreEqual<T>` uses `TEqualityComparer` directly.
- `ijbranch/DUnitX` `master` fast-forwarded to `a710952`; the merged branches were deleted from it on 2026-10-14.

## What batch 1 taught us, and what changed for this batch

- **Every merge put the next PR into conflict.** All six batch 1 PRs added their tests at the end of
  `TTestsAssert`, so each merge conflicted with the rest (#406-#408 needed fixing twice; Vincent fixed #406
  himself). This batch puts each PR's tests next to the related existing tests, at a different place in each file,
  and every pair of branches was checked to merge cleanly (`git merge-tree`, all 15 pairs), as were all six together.
  The combined tree was built and run: 330 tests, 0 failures.
- **No `.dproj` changes.** The shared `pre-commit` hook strips upstream's `DUnitXTest_D12.dproj` whenever it is staged,
  so this batch adds no test unit (new tests go into existing units) and touches no `.dproj`.
- **No shared `uses` edits.** Three PRs add tests to `DUnitX.Tests.DUnitCompatibility.pas`; adding
  `DUnitX.Exceptions` to its `uses` in each would conflict, so the tests name the failure class as
  `Assert.TestFailure` instead.
- **Builds on what upstream already took.** #1 reuses `IsUnrequestedTestOutcome`, added by #408, rather than a new
  mechanism.
- **Exact-class traps in our own tests.** `Assert.WillRaise` matches the class exactly; a string compare raises
  `ETestFailureStrCompare`, so tests that expect a failed check use `WillRaiseDescendant`.
- **Only claim what was run.** The batch 1 comment that `TestMaxTime` also fails "on master" was inferred. This time
  every red run is master's source plus the new tests, and `TestMaxTime` errors in all of them, so it is observed.
- **Short texts.** Upstream merged batch 1 within a day of the short versions; the texts stay at that length.

---

## 1. `WillNotRaise*` swallow a failing assert inside the method

**Issue**

> Same problem as #402, in the `WillNotRaise` family. With a class named, a failing assert inside the method raises
> `ETestFailure`, which doesn't match the class, so it is swallowed and this passes:
>
> ```pascal
> Assert.WillNotRaise(procedure begin Assert.Fail('x') end, EStreamError);
> ```
>
> `WillNotRaiseDescendant` and `WillNotRaiseWithMessage` do the same. `WillNotRaiseAny` reports an inner
> `Assert.Pass` as "Method raised [ETestPass]".

**PR**

> Fixes #412. Four tests (red on master). Each method now re-raises a failure or pass from inside the method,
> using `IsUnrequestedTestOutcome` from #408, so naming `ETestFailure` explicitly still behaves as before.

---

## 2. `Assert.AreSame(TObject)` uses `Equals`, not identity

**Issue**

> `AreSame(expected, actual : TObject)` and `AreNotSame` call `expected.Equals(actual)`. For a class that overrides
> `Equals`, two different instances count as the same object, so `AreSame` passes and `AreNotSame` fails. The
> `IInterface` overloads already compare identity.

**PR**

> Fixes #414. Two tests (red on master) with a class whose `Equals` always returns True. The fix compares the
> references.

---

## 3. `CheckInherits` has its arguments reversed

**Issue**

> DUnit's `CheckInherits(expected, actual)` checks `actual.InheritsFrom(expected)`. The compatibility version calls
> `Assert.InheritsFrom(expected, actual)`, whose parameters are (descendant, parent). So `CheckInherits(TObject,
> TTestCase)` fails and `CheckInherits(TTestCase, TObject)` passes.

**PR**

> Fixes #416. Two tests (red on master); the arguments are swapped.

---

## 4. `CheckEqualsBin` passes values that differ above `digits`

**Issue**

> `CheckEqualsBin` compares `IntToBin(expected, digits)` with `IntToBin(actual, digits)`, so
> `CheckEqualsBin($100, $000, '', 8)` passes. In DUnit, `digits` only sets the display width.
> `CheckNotEqualsBin` already compares the values.

**PR**

> Fixes #418. One test (red on master). When the values differ but their `digits`-wide strings are equal, the
> comparison uses all 32 bits, so it fails and the message shows the difference.

---

## 5. The DUnit compatibility string checks ignore case

**Issue**

> `CheckEquals(string)`, `CheckEqualsString`, `CheckNotEquals(string)`, `CheckNotEqualsString` and the WideString
> variants compare case-insensitively. DUnit's string checks are case-sensitive, so a converted DUnit suite silently
> loses its case checks: `CheckEquals('abc', 'ABC')` passes, and `CheckNotEquals('abc', 'ABC')` fails.

**PR**

> Fixes #420. Three tests (red on master); the eight methods now pass `ignoreCase = false`.
>
> **Behaviour change:** a suite that relied on these being case-insensitive will see new failures - your call
> whether that is acceptable.

---

## 6. The NUnit and JUnit file loggers fail on a bare file name

**Issue**

> `TDUnitXXMLNUnitFileLogger.Create('results.xml')` (and the JUnit one) calls `ForceDirectories('')` for a file name
> with no directory part, which raises `EInOutError: Unable to create directory`. So `-xml:results.xml` aborts the
> run before any test runs (this is the exception in #404's repro).

**PR**

> Fixes #422. One test per logger (red on master with `EInOutError`); `ForceDirectories` is skipped when there is
> no directory part. The tests create the file in `%TEMP%` and delete it.

---

**One line at the end of each PR:**

> Tested with Delphi 13 only, Win64 Debug; not built for Win32, older compilers or non-Windows targets.
