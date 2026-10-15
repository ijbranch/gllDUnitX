# DUnitX upstream: batch 6 (posted 2026-10-15)

Six issues and their PRs, built and posted 2026-10-15 against `master` @ `4273e0f` (after upstream merged all of
batch 5). Issue bodies end "Split out of #398."; PR bodies are "Fixes #N." plus a short note plus the one-line
caveat at the end of this file. Branches are in the worktree `D:\gllDUnitX-upstream` (remote `dunitx-fork`),
pushed to [`ijbranch/DUnitX`](https://github.com/ijbranch/DUnitX). Each branch has a commit with the failing
test, then the fix. "Allow edits by maintainers" is on for every PR.

| # | Report item | Issue | PR | Branch |
|---|---|---|---|---|
| 1 | F (rest) | [#464](https://github.com/VSoftTechnologies/DUnitX/issues/464) | [#465](https://github.com/VSoftTechnologies/DUnitX/pull/465) | `fix/list-nongeneric-enumerator` |
| 2 | 2.4 | [#466](https://github.com/VSoftTechnologies/DUnitX/issues/466) | [#467](https://github.com/VSoftTechnologies/DUnitX/pull/467) | `fix/willraise-context-cycle` |
| 3 | fork fix, not in the report | [#468](https://github.com/VSoftTechnologies/DUnitX/issues/468) | [#469](https://github.com/VSoftTechnologies/DUnitX/pull/469) | `fix/checkis-nil` |
| 4 | fork fix, not in the report | [#470](https://github.com/VSoftTechnologies/DUnitX/issues/470) | [#471](https://github.com/VSoftTechnologies/DUnitX/pull/471) | `fix/cdata-escape` |
| 5 | fork fix, not in the report | [#472](https://github.com/VSoftTechnologies/DUnitX/issues/472) | [#473](https://github.com/VSoftTechnologies/DUnitX/pull/473) | `fix/arrayhelper-delete` |
| 6 | fork fix, not in the report | [#474](https://github.com/VSoftTechnologies/DUnitX/issues/474) | [#475](https://github.com/VSoftTechnologies/DUnitX/pull/475) | `fix/valuehelper-tostring-nil` |

## How this batch was chosen and built

- **Same rule as batches 3 to 5:** only defects whose old behaviour is plainly wrong, each testable without the IDE
  or a second runner, and small.
- **Dropped from the shortlist, with the reason:**
  - **2.6 (TearDown error replacing the test's message) and 2.5 (a) (`Assert.Pass`'s `ETestPass` still alive at
    `PostTest`):** both sit inside `TDUnitXTestRunner.ExecuteTests` / `ExecuteTest`, so a test needs a runner of its
    own. Upstream's suite has no runner-level tests, and a second runner on the test's thread raises a duplicate key
    in `FActiveRunners`. 2.5 (a) is not small either: the pass message is still allocated when `PostTest` measures.
  - **B (`Log` keeping the caller's string) and A (phase sum counting memory freed in a gap):** need a runner too,
    and this fork's fixes rest on its runner-allocation accounting (`BeginRunnerAllocation` and the whole-span
    monitor); a copy of the string alone would still be counted, and a whole-span measure alone would start
    counting the runner's own allocations between phases.
  - **C (FastMM5 monitor without `FastMM_ProcessAllPendingFrees`):** cannot be tested in upstream's test project,
    which does not run under FastMM5.
  - **2.8 (method `[Category]` replacing the fixture's):** a behaviour change (it alters test selection), and this
    fork does not change it either (report §7).
- **Reserves taken instead:** 2.4, then four fixes this fork already carries from its 2026-10-13 review (#3-#6).
  Considered and not sent: `TValueHelper.IsUInt64` (correct but never called; kept in reserve), the
  `TTestFixtureList.Sort` comparer and the FastMM4 monitor (not reliably testable here), and the service-locator
  leak (see the next point).
- **The service-locator leak (report §6) is not sent, and this fork's own fix is wrong:** `Supports(obj, guid,
  Result)` on a `TInterfacedObject` with a reference count of 0 frees the object itself when it fails (the RTL takes
  and releases an `IUnknown`), so the fork's `obj.Free` after a failed `Supports` frees it a second time. Only a
  class without `IUnknown` leaks. Not changed here (this batch does not touch the fork's `Source`).
- **#1 adds `TypInfo` to the implementation `uses` of `DUnitX.Generics`** for the class check in the non-generic
  `Current`; `GetTypeKind` would need XE7.
- **#2's test drives the real path:** `ITestFixture.AddTest` with an expected exception creates the
  `TDUnitXExceptionTest`, and a spy context records its own destruction.
- **Merge safety:** three PRs add tests to `Tests\DUnitX.Tests.Utils.pas` (#1 in `TDUnitXListTests`, #5 as a new
  fixture at the top with its registration first, #6 in `TValueHelperTests`), at places at least two unchanged lines
  apart; #5 and #6 also both change `Source\DUnitX.Utils.pas`, about 1,100 lines apart. All 15 pairs pass
  `git merge-tree`; every branch builds and runs alone, and the six merged together build and run.
- **Red / green:** master plus all six tests: each fails on its own assertion (`WillRaise` and `WillNotRaiseAny`
  report the access violations of #3 and #6 as failures); with the fixes all pass, and only `TestMaxTime` errors
  (upstream's known `[MaxTime]` crash on Win64). The red run's NUnit XML shows #4's own defect: the message
  "Expected [a]]>b]" is written as "Expected [a]>b]". The first two runs of #1's build (`-cm:Quiet`) died with
  an access violation and wrote no XML; the same binary then completed four times (two verbose, two quiet), as did
  every other build, so this is taken to be the rare whole-process `[MaxTime]` crash noted in batch 3. The scripts
  (byte-exact edits, the build, the NUnit-XML summary, the posting) were in that session's scratchpad only.

---

## 1. TDUnitXList non-generic enumerator is nil

**Issue**

> `TDUnitXList<T>` implements the non-generic `IEnumerable`, but `GetNonGenEnumerator` returns nil, so `(list as IEnumerable).GetEnumerator` is nil and enumerating through it is an access violation. The enumerator's non-generic `Current` (`TDUnitXIEnumerator<T>.GetCurrent`) also always returns nil, even when `T` is a class. The `ToArray` half of this was #436.
>
> Split out of #398.

**PR**: Fix TDUnitXList non-generic enumerator returning nil

> Fixes #464. One test (red on master). `GetNonGenEnumerator` returns the same enumerator as `GetEnumerator`, and its non-generic `Current` returns the item when `T` is a class (nil otherwise, as it can only yield a `TObject`). The class check uses `TypInfo`, added to the implementation `uses`, rather than `GetTypeKind`, for XE2.

---

## 2. A [WillRaise] test keeps its execute context alive

**Issue**

> `TDUnitXExceptionTest.Execute` stores the context in `FRaiseContext` so that `RaiseMethod` can pass it on, and clears it only in the destructor. The context is the run results, which hold the fixture results, the fixtures and their tests, so this makes a reference cycle: after a run with any `[WillRaise]` test, the results, the fixtures and the fixture instances are never freed, and the fixtures' destructors never run.
>
> Split out of #398.

**PR**: Fix a [WillRaise] test keeping its context after Execute

> Fixes #466. One test (red on master: the context is still alive after `Execute`). `FRaiseContext` is cleared in a `finally` once the method has run.

---

## 3. CheckIs raises an access violation for a nil object

**Issue**

> The DUnit-compatible `TTestCase.CheckIs(AObject, AClass)` calls `Assert.InheritsFrom(AObject.ClassType, AClass, msg)`, so a nil `AObject` is an access violation instead of a failed check. DUnit fails `CheckIs` when the object is nil.
>
> Split out of #398.

**PR**: Fix CheckIs raising an access violation for a nil object

> Fixes #468. One test (red on master). `CheckIs` now fails through `Assert.IsNotNull` before checking the class.

---

## 4. CDATA escaping changes the text and can end the section early

**Issue**

> `EscapeForXML(value, False, True)`, which the NUnit and JUnit loggers use for messages and stack traces inside `<![CDATA[ ... ]]>`, replaces `]]>` with `]>`. That changes the text (`a]]>b` is reported as `a]>b`), and `]]]>` becomes `]]>`, which ends the CDATA section early: the rest of the message lands outside it and the XML is ill-formed.
>
> Split out of #398.

**PR**: Fix CDATA escaping changing the text and ending the section early

> Fixes #470. One test (red on master). `]]>` is now split across two adjacent sections (`]]]]><![CDATA[>`), which an XML parser reads back as the original text; the `NEXTGEN` branch gets the same change.

---

## 5. TArrayHelper.Delete cannot delete index 0 and reads past the end

**Issue**

> `TArrayHelper.Delete<T>(source, index, count)` only acts when `index >= 1`, so the first element of a (zero-based) `TArray<T>` cannot be deleted: the call does nothing. When it does act, the loop that moves the tail runs `Length - index` times starting at `index + count`, so it reads `count` elements past the end of the array before `SetLength` truncates it.
>
> Split out of #398.

**PR**: Fix TArrayHelper.Delete ignoring index 0 and reading past the end

> Fixes #472. One test (red on master: deleting index 0 leaves the array unchanged). Any index from 0 to `Length - 1` is accepted, `count` is clamped to the elements left, and only the elements after the deleted ones are moved. DUnitX's own call, which deletes the last fixture-namespace element, behaves as before.

---

## 6. TValueHelper.ToString raises an access violation for a nil object or interface

**Issue**

> The class function `TValue.ToString(Value)` in `DUnitX.Utils` formats an object as `ClassName($address)` and an interface as `ClassName($address) as IName`. For a nil object or interface it calls `ClassName` on nil, which is an access violation. It is reached through `TValue.ToString(array of TValue)` and `TRttiMethodHelper.Format`.
>
> Split out of #398.

**PR**: Fix TValueHelper.ToString raising an access violation for nil

> Fixes #474. One test (red on master). A nil object or interface now formats as `nil`.

---

**One line at the end of each PR:**

> Tested with Delphi 13 only, Win64 Debug; not built for Win32, older compilers or non-Windows targets.
