# DUnitX upstream: batch 3 (issues and PRs posted)

Six issues and their PRs, built and posted 2026-10-14 against `master` @ `a710952` (after upstream merged five of
batch 2 and #425). Issue bodies are as below plus "Split out of #398"; PR bodies are "Fixes #N." plus the text below
plus the one-line caveat at the end of this file. Branches are in the worktree `D:\gllDUnitX-upstream` (remote
`dunitx-fork`), pushed to [`ijbranch/DUnitX`](https://github.com/ijbranch/DUnitX). Each branch has a commit with the
failing test(s), then the fix. "Allow edits by maintainers" is on for every PR.

| # | Report item | Issue | PR | Branch |
|---|---|---|---|---|
| 1 | 3.1 | [#426](https://github.com/VSoftTechnologies/DUnitX/issues/426) | [#427](https://github.com/VSoftTechnologies/DUnitX/pull/427) | `fix/willnotraiseany-message-format` |
| 2 | 3.4 | [#428](https://github.com/VSoftTechnologies/DUnitX/issues/428) | [#429](https://github.com/VSoftTechnologies/DUnitX/pull/429) | `fix/areequal-float-infinity` |
| 3 | 3.5 | [#430](https://github.com/VSoftTechnologies/DUnitX/issues/430) | [#431](https://github.com/VSoftTechnologies/DUnitX/pull/431) | `fix/assert-failure-messages` |
| 4 | 3.6 | [#432](https://github.com/VSoftTechnologies/DUnitX/issues/432) | [#433](https://github.com/VSoftTechnologies/DUnitX/pull/433) | `fix/tstrings-repeated-ignored-line` |
| 5 | 3.9 | [#434](https://github.com/VSoftTechnologies/DUnitX/issues/434) | [#435](https://github.com/VSoftTechnologies/DUnitX/pull/435) | `fix/xml-form-feed` |
| 6 | F | [#436](https://github.com/VSoftTechnologies/DUnitX/issues/436) | [#437](https://github.com/VSoftTechnologies/DUnitX/pull/437) | `fix/dunitxlist-toarray` |

## Progress (2026-10-14)

- **Merged 2026-10-13 (21:18-21:25 UTC):** #427, #431, #433, #435, #437 (5 of 6); their issues are closed.
  Upstream `master` @ `8ff5f0b`; the fork's `master` fast-forwarded to it.
- **#429 (infinities): open, reworked.** Vincent: "This will not compile on XE2 - IsInfinite was introduced in
  XE3." Commit `b92e63c` replaces the four `IsInfinite` guards with `Abs(x) <> Infinity` (the `Infinity`
  constant predates XE2) and we replied on the PR. Delphi 13 Win64 Debug: 321 pass, 9 ignored, only
  `TestMaxTime` errors; with the guards removed both infinity tests fail. Upstream still supports XE2, so later
  batches must avoid post-XE2 RTL.
- **The five merged branches were deleted** from `ijbranch/DUnitX` and locally (2026-10-14); only
  `fix/areequal-float-infinity` (#429) remains.

## How this batch was chosen and built

- **No intended behaviour changes.** Upstream closed #415 (batch 2) after a behaviour-change reservation, so this
  batch takes only items where the old behaviour is plainly wrong: a crash, a wrong message, or a wrong answer.
  #2 changes results only for infinities.
- **3.11 (`--dontshowignored:false` turns the option on) was swapped out for 3.5.** It cannot be tested without
  moving `RegisterOptions` into the interface of `DUnitX.OptionsDefinition.pas` (the parser tests also clear the
  registry), an API change for a one-word fix. The non-generic enumerator half of item F is also left out: a
  `TObject` `Current` cannot return a `T`, so it is a design question, not a defect fix.
- **Merge safety, as for batch 2:** each PR puts its tests in a different place, no `.dproj` and no shared `uses`
  is touched, all 15 pairs pass `git merge-tree`, and all six merged onto master build and run: 337 tests, only
  `TestMaxTime` errors (upstream's known `[MaxTime]` crash on Win64).
- **Every red run is master plus the new tests, failing on its own assertion.** For #2 a mutation run also
  removed the infinity guards to prove the `AreEqual(Inf, -Inf)` assertion is needed: it then passed on
  `SameValue` alone.
- **Upstream files are edited by byte-exact script, not the Edit tool.** They are CRLF without a BOM, and the
  `ensure_crlf.py` hook would add a BOM to every `.pas` the Edit tool touches.
- **New fixtures use `public`, not `published`** (upstream's style; `published` without `{$M+}` gives W1055).
- **Upstream's `[MaxTime]` crash can take down the whole test process** (exit `0xC0000005`, no XML) on a rare run;
  a rerun completes. Seen once in the 17 runs made for this batch.
- **3.5 is sent only in part:** the `AreEqual(Currency)` and `DoesNotContain(string)` messages. `AreEqual(Cardinal)`
  printing `High(Cardinal)` as -1 and `WillNotRaise*` naming the expected class rather than the raised one stay for a
  later batch.

---

## 1. WillNotRaiseAny uses the message as a format string

**Issue**

> `WillNotRaiseAny` appends the caller's message to the format string (`FailFmt(SUnexpectedException + AddLineBreak(msg), ...)`), so `Assert.WillNotRaiseAny(..., 'coverage 100%')` reports "coverage 100", and a message containing `%s` or `%d` raises `EConvertError` instead of the real failure.

**PR**: Fix WillNotRaiseAny using the message as a format string

> Fixes #426. One test (red on master: the message ends "coverage 100"). The exception text is formatted first and the message appended afterwards.

---

## 2. AreEqual/AreNotEqual (Double, Extended) get infinities wrong

**Issue**

> The floating-point `AreEqual` / `AreNotEqual` overloads use `SameValue`. Inf - Inf is NaN, so `AreEqual(Inf, Inf)` fails ("Expected [INF] but got [INF]") and `AreNotEqual(Inf, Inf)` passes. The other way round, `SameValue`'s epsilon is infinite when both values are infinite, so `AreEqual(Infinity, NegInfinity)` passes.

**PR**: Fix AreEqual/AreNotEqual on infinities

> Fixes #428. Two tests, Double and Extended (red on master). Identical values are equal; otherwise an infinity equals nothing, and finite values still go through `SameValue`. NaN still equals nothing.

---

## 3. Wrong failure messages from AreEqual(Currency) and DoesNotContain(string)

**Issue**

> `AreEqual(Currency)` fails with "Expected [1] equals actual [2]" (it uses `SEqualsErrorExt`, the `AreNotEqual` message). `DoesNotContain(string)` fails with "[abc] does not contain [b]" when the problem is that it does (it uses `SStrDoesNotContain`, the `Contains` message).

**PR**: Fix the AreEqual(Currency) and DoesNotContain(string) failure messages

> Fixes #430. Two tests (red on master). `AreEqual(Currency)` now uses `SUnexpectedErrorExt` like the other `AreEqual` overloads; `DoesNotContain(string)` uses a new resource string, `SStrContains` ("[%s] contains [%s] %s"). Only the messages change.

---

## 4. AreEqual(TStrings, TStrings, ignoreLines) raises EListError for a repeated line number

**Issue**

> The `ignoreLines` are put in a `TDictionary` with `Add`, so `Assert.AreEqual(expected, actual, [2, 2])` raises `EListError: Duplicates not allowed` instead of comparing the lists.

**PR**: Fix AreEqual(TStrings) raising EListError for a repeated ignored line

> Fixes #432. One test (red on master with `EListError`); `Add` becomes `AddOrSetValue`.

---

## 5. IsValidXMLChar accepts form feed

**Issue**

> `IsValidXMLChar` (`DUnitX.Utils.XML.pas`) lists `$000C` as valid. XML 1.0 allows only tab, LF and CR below `$20`, so `EscapeForXML`, which the NUnit and JUnit loggers use, keeps a form feed in a test message and the XML output is not well-formed.

**PR**: Fix IsValidXMLChar accepting form feed

> Fixes #434. One test, in the until-now empty `DUnitX.Tests.Utils.XML.pas` (red on master). `$000C` is removed from the valid set, so `StripInvalidXML` replaces it with a space like the other control characters.

---

## 6. TDUnitXList<T>.ToArray returns nil

**Issue**

> `TDUnitXList<T>.ToArray` is a stub (`result := nil; //FList.ToArray<T>;`), so `IList<T>.ToArray` always returns an empty array.

**PR**: Fix TDUnitXList<T>.ToArray returning nil

> Fixes #436. One test (red on master: length 0). `ToArray` copies the items into the result with a plain loop.

---

**One line at the end of each PR:**

> Tested with Delphi 13 only, Win64 Debug; not built for Win32, older compilers or non-Windows targets.
