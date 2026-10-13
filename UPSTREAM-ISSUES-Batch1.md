# DUnitX upstream: batch 1 (issues and PRs posted)

Six issues and their PRs, drafted 2026-10-12 against `master` @ `1bdc297`, all posted 2026-10-12. Issue bodies
are as below plus "Split out of #398" and the one-line environment caveat; PR bodies are as below plus the caveat.
Branches are in the worktree `D:\gllDUnitX-upstream` (remote `dunitx-fork`) and are pushed to the public GitHub fork
[`ijbranch/DUnitX`](https://github.com/ijbranch/DUnitX), created for these PRs (a cross-repo PR cannot come from a
standalone repo such as `ijbranch/gllDUnitX`). Each branch has a commit with the failing test, then the fix (branch 6
has no unit test; see its notes). "Allow edits by maintainers" is on for every PR.

**Outcome (2026-10-13):** upstream merged all six, plus #411, on 2026-10-13 (`upstream/master` @ `6af7aeb`). Each
merge put the next PR into conflict; what that taught us is applied in
[UPSTREAM-ISSUES-Batch2.md](UPSTREAM-ISSUES-Batch2.md). The seven merged branches (these six and
`feature/bitmask-exit-codes`) were deleted from `ijbranch/DUnitX` and the worktree the same day; the PRs keep their
commits, and `ijbranch/DUnitX` `master` was fast-forwarded to `6af7aeb`.

| # | Issue | PR | Branch |
|---|---|---|---|
| 1 | [#399](https://github.com/VSoftTechnologies/DUnitX/issues/399) | [#405](https://github.com/VSoftTechnologies/DUnitX/pull/405) | `fix/isempty-variant` |
| 2 | [#400](https://github.com/VSoftTechnologies/DUnitX/issues/400) | [#406](https://github.com/VSoftTechnologies/DUnitX/pull/406) | `fix/willnotraisedescendant-method` |
| 3 | [#401](https://github.com/VSoftTechnologies/DUnitX/issues/401) | [#407](https://github.com/VSoftTechnologies/DUnitX/pull/407) | `fix/generic-compare-nan` |
| 4 | [#402](https://github.com/VSoftTechnologies/DUnitX/issues/402) | [#408](https://github.com/VSoftTechnologies/DUnitX/pull/408) | `fix/willraise-swallows-test-outcomes` |
| 5 | [#403](https://github.com/VSoftTechnologies/DUnitX/issues/403) | [#409](https://github.com/VSoftTechnologies/DUnitX/pull/409) | `fix/category-expression-last-char` |
| 6 | [#404](https://github.com/VSoftTechnologies/DUnitX/issues/404) | [#410](https://github.com/VSoftTechnologies/DUnitX/pull/410) | `fix/runner-exitcode-on-exception` |

Each PR text below already names its issue number.

---

## 1. `Assert.IsEmpty(Variant)` is inverted

Branch: `fix/isempty-variant`

**Issue**

> `Assert.IsEmpty(Unassigned)` and `Assert.IsEmpty(Null)` fail, and `Assert.IsEmpty('abc')` passes. The condition in
> `Assert.IsEmpty(Variant)` is missing a `not`. Separately, `IsNotEmpty(Null)` passes, which doesn't match `IsEmpty`
> treating Null as empty.

**PR**

> Fixes #399. Adds three tests (red on master), then the fix: `not` in `IsEmpty(Variant)`, and `IsNotEmpty(Variant)`
> also rejects Null.

---

## 2. `WillNotRaiseDescendant(TTestMethod)` only checks the exact class

Branch: `fix/willnotraisedescendant-method`

**Issue**

> The `TTestMethod` overload of `WillNotRaiseDescendant` forwards to `WillNotRaise`, not to `WillNotRaiseDescendant`,
> so a method that raises a *descendant* of the named class passes. The `TProc` overload is fine.

**PR**

> Fixes #400. One test (red on master), one-word fix.

---

## 3. `AreEqual<Double>(1.0, NaN)` passes

Branch: `fix/generic-compare-nan`

**Issue**

> `AreEqual<T>`, `AreNotEqual<T>`, `Contains<T>` and `DoesNotContain<T>` use `TComparer<T>.Default`, whose float
> compare returns 0 when either value is NaN. So `AreEqual<Double>(1.0, NaN)` and `Contains<Double>([1.0, 2.0], NaN)`
> pass, and `AreNotEqual<Double>(1.0, NaN)` fails. The non-generic `AreEqual(Double, ...)` overloads are fine.

**PR**

> Fixes #401. Three tests (red on master). The fix adds a private `ValuesEqual<T>` that uses
> `TEqualityComparer<T>` (`=`) for float types and keeps `TComparer<T>` for everything else. I didn't switch every
> type to `TEqualityComparer`, because for classes that calls `TObject.Equals`, which would change existing results.

---

## 4. `WillRaise*` swallow a failing assert inside the method

Branch: `fix/willraise-swallows-test-outcomes`

**Issue**

> `WillRaise`, `WillRaiseAny`, `WillRaiseDescendant` and `WillRaiseWithMessage(Regex)` catch every `Exception`,
> including the framework's own failure and pass exceptions. So this passes:
>
> ```pascal
> Assert.WillRaiseAny(procedure begin Assert.AreEqual(1, 2) end);
> ```
>
> The same applies to `[WillRaise(Exception, exDescendant)]` on a test method: a failing assert in the body counts as
> "raised as expected".

**PR**

> Fixes #402. Three tests (red on master). These methods now re-raise a failure/pass raised inside the method,
> unless the caller asked for it by naming a matching class other than `Exception` (e.g. `WillRaise(..., ETestFailure)`).
>
> **Behaviour change:** `WillRaise(proc)` with no class no longer passes when `proc` fails an assert. Two existing
> tests in `DUnitX.Tests.Assert` relied on that; they now name `ETestFailure`, like their sibling tests. User suites
> written that way will need the same change - your call whether that is acceptable.

---

## 5. A category operator in the last position is ignored

Branch: `fix/category-expression-last-char`

**Issue**

> `--exclude:(Slow|Integration)` doesn't exclude Integration tests: the second category is parsed as
> `Integration)`. `IndexOfAny` in `DUnitX.CategoryExpression.pas` (non-NEXTGEN path) loops `while i < Max` over a
> 1-based string, so the last character is never checked.

**PR**

> Fixes #403. One test (red on master: "Expected [Integration] but got [Integration)]"), `<` -> `<=`.

---

## 6. The console runner exits 0 when the run aborts

Branch: `fix/runner-exitcode-on-exception`

**Issue**

> The `except` handler in the wizard's project template (and in `Tests/DUnitXTestProject.dpr`) prints the exception
> but never sets `ExitCode`, so CI sees success with no tests run. Repro on master:
>
> ```
> DUnitXTestProject.exe -xml:out.xml
> EInOutError: Unable to create directory []      <- exit code 0
> ```
>
> Other exceptions that end up there: `ENoTestsRegistered` (missing `{$STRONGLINKTYPES ON}`), a fixture constructor
> or test case provider that raises.

**PR**

> Fixes #404. Sets `System.ExitCode := EXIT_ERRORS` in the handler, in the template and in `DUnitXTestProject.dpr`.
> No unit test (it's the program's main block); verified by the repro above going from exit 0 to exit 1. The 17
> example `.dpr` files and the D2010/XE test `.dpr`s have the same handler; happy to add them if you want.
>
> (Side note: the `EInOutError` itself is the NUnit/JUnit file logger calling `ForceDirectories('')` for a bare file
> name. Separate issue if you want it.)

---

## Our environment, and what that means for these PRs

We work in **Delphi 13 Florence (RAD Studio 37.0), VCL only, on Windows 11**. Read the results with that in mind:

- **What we ran:** `Tests\DUnitXTest_D12.dproj`, built with the Delphi 13 Win64 compiler against the Delphi 13
  RTL, Win64 Debug only. Each new test failed on master on its own assertion (not a compile error), and after the
  fix the full suite passes. Behaviour that depends on the RTL, such as `TComparer<Double>` returning 0 for NaN
  (#3), was observed on that RTL only.
- **What we did not build or run:** Win32, older Delphi versions, C++Builder, FMX, macOS, Linux, iOS and Android.
  Code inside `{$IFDEF}` branches for those targets was read, not compiled. #5 fixes the non-`NEXTGEN` path only;
  the `NEXTGEN` path uses `string.IndexOfAny` and was not tested. The fixes use nothing newer than the code beside
  them, and the existing `{$IFDEF DELPHI_XE_UP}` / `DELPHI_XE2_UP` guards are kept.
- **What we did not drive:** the IDE wizard (#6). The template change was compile-checked as a unit, not used to
  generate a project; the same change in `DUnitXTestProject.dpr` was verified by running it.
- **One error in every run, before and after:** `ExampleFixture1.TestMaxTime` (access violation), the Win64
  `[MaxTime]` defect in section 6 of the original report. It is unrelated to these changes.

A fix may therefore behave differently on a compiler, RTL or platform we do not use.

**One line to put at the end of each PR** (the paragraph above is too long for a PR description):

> Tested with Delphi 13 only, Win64 Debug; not built for Win32, older compilers or non-Windows targets.
