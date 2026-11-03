# DUnitX upstream: batch 14 (posted 2026-11-02; item 8 on 2026-11-04)

The runner changes from the #398 list ("happy for all of the above to be addressed"), one PR at a time, each on the `master` of the day, pushed to [`ijbranch/gllDUnitX`](https://github.com/ijbranch/gllDUnitX).

| # | Defect | Issue | PR | Branch | Head | Merged |
|---|---|---|---|---|---|---|
| 1 | One fixture whose constructor raises aborts the whole run (report 2.3 (a)) | [#567](https://github.com/VSoftTechnologies/DUnitX/issues/567) | [#568](https://github.com/VSoftTechnologies/DUnitX/pull/568) | `fix/fixture-constructor-raises` | `fc8d29b` | 2026-11-02 `8224015` |
| 2 | False leak reports: `Assert.Pass`, `Log` / `Status`, memory freed between phases (report 2.5 (a), (b), A, B) | [#573](https://github.com/VSoftTechnologies/DUnitX/issues/573) | [#578](https://github.com/VSoftTechnologies/DUnitX/pull/578) | `fix/false-leak-reports` | `d5f32a3` | 2026-11-02 `2299609` |
| 3 | The D13 IDE expert does not compile for Win64 (found checking the expert items) | [#569](https://github.com/VSoftTechnologies/DUnitX/issues/569) | [#574](https://github.com/VSoftTechnologies/DUnitX/pull/574) | `fix/expert-d13-win64-build` | `8b04f75` | 2026-11-02 `7f1b3d8` |
| 4 | Misspelt `DELPHI_SEATTLE_UP`: the C++Builder gallery entry makes a Delphi project (report 5.1) | [#570](https://github.com/VSoftTechnologies/DUnitX/issues/570) | [#575](https://github.com/VSoftTechnologies/DUnitX/pull/575) | `fix/expert-seattle-conditional` | `e5ca9f3` | 2026-11-02 `52b429c` |
| 5 | Cancel on the save prompt still creates the project; nil active project (report 5.2, 5.3) | [#571](https://github.com/VSoftTechnologies/DUnitX/issues/571) | [#576](https://github.com/VSoftTechnologies/DUnitX/pull/576) | `fix/expert-cancel-save` | `078d681` | 2026-11-02 `a87c1c6` |
| 6 | Fixture class names that do not compile are accepted (report 5.4) | [#572](https://github.com/VSoftTechnologies/DUnitX/issues/572) | [#577](https://github.com/VSoftTechnologies/DUnitX/pull/577) | `fix/expert-fixture-name-ident` | `079f481` | 2026-11-02 `f4b9811` |
| 7 | `Assert.AreSame` / `AreNotSame(TObject)` call `Equals`, not identity (#414, re-offered; #415 was closed in batch 2) | [#414](https://github.com/VSoftTechnologies/DUnitX/issues/414) | [#579](https://github.com/VSoftTechnologies/DUnitX/pull/579) | `fix/aresame-identity-2` | `0521642` | 2026-11-02 `f3f9373` |
| 8 | The #453 NUnit logger test builds its expected `time` with the locale's decimal separator, so it fails on a German machine (reported by luebbe) | [#580](https://github.com/VSoftTechnologies/DUnitX/issues/580) | [#581](https://github.com/VSoftTechnologies/DUnitX/pull/581) | `fix/nunit-time-locale` | `242727d` | 2026-11-03 `8626022` |

## 1. A raising fixture constructor (posted 16:25 +11, Ian: "Approved to publish")

Built on `f5ab75a`.  The fixture keeps what its constructor raised (`AcquireExceptionObject`, with the address) and leaves the instance nil; `InitFixtureInstance` raises it once at run time (`raise ... at` the original address), and `ExecuteFixture` reports each of the fixture's tests that will run as an error with that exception (ignored for `ETestIgnored`), skipping its setup, tests and teardown.  `InternalInitFixtureInstance` also rebinds `[Setup]`, `[TearDown]`, `[SetupFixture]` and `[TearDownFixture]` to a new instance, as it already did the tests, so a GUI re-run after the constructor stops raising runs on the new instance.  The parallel path (`-m:x`) goes through the same `ExecuteFixture`.

- **Tests** (`TFixtureConstructorTests`, five): red on `f5ab75a` on their own assertions (the build raised `EFixtureConstructorFailed`); 536 passed, 9 ignored, serial and `-m:4`.  Nine mutants, all killed; two defensive lines (the `[SetupFixture]` rebind and guard) are unreachable while part (b) stands.
- **End to end:** with a raising fixture registered in the real test exe, before: exit 1, nothing ran, empty XML; after: exit 1, 535 passed, 9 ignored, 2 errors (that fixture's tests).  The report's "exits 0" no longer held: upstream's test project now sets `EXIT_ERRORS` in its `except`.
- **Review:** 8 findings, 6 fixed (all-ignored or filtered fixtures were errored; the error address; untested teardown rebinds; `BREAKINGCHANGES.md` for custom runners: `FixtureInstance` can be nil, `InitFixtureInstance` can raise; wording; an unused variable), 2 declined (`[RepeatTest]` child fixtures with a constructor that raises only sometimes; child fixtures bound to a freed parent instance after a GUI re-run, as on upstream today).
- **Left alone:** fixtures are still built eagerly, even under `--run:OneTest`; part (b), a parameterless constructor disabling `[SetupFixture]`.

**#568 merged 2026-11-02** as `8224015`, unchanged.

## 2. False leak reports (posted 16:58 +11, Ian: "Approved to publish")

Built on `8224015`, one commit per cause, each with a red-first test in `Tests/DUnitX.Tests.MemoryLeaks.pas` over a fake `IMemoryLeakMonitor`: a second monitor instance measures each test from the start of its setup to the end of its teardown, netting out the runner's own work (result, log, logger callbacks); `Log` keeps its own copy of the message; `ExecuteTest` handles `ETestPass` inside the measurement.  540 passed, 9 ignored; 15 mutants killed (11 on the fake monitor, 4 on the real allocator).  Real FastMM5: 13 false reports on the base, none after; a real 1000-byte `GetMem` is still reported.  Review: 10 findings, 8 fixed, 2 declined.  **The cost, put to Vincent as a question in the PR:** about 2.7x the leak-check time (FastMM5, 100,000 live blocks: 18-48 ms per test); default as sent, or behind an option.  Item C (FastMM5 pending frees) is not in it; 2.5 (c) was #485.

## 3-6. The IDE expert (posted 16:58 +11, Ian: "Approved to publish")

Built on `f5ab75a` (touch only `Expert\`; clean on `8224015` and with each other).  Upstream's D13 expert did not compile for Win64 (E2250: Delphi 13's glyph callback is `TFunc<UInt64>` on Win64, `TFunc<Cardinal>` on Win32), so #574 makes the callback `NativeUInt`; #575-#577 say they need it for Win64.  Builds were redirected (bpl, dcp, dcu, hpp, obj, bpi) away from the shared folders.

- **Checked by hand in the 64-bit IDE** (Ian drove, under a separate registry profile `-r DUnitXUpstream`, BEFORE = upstream + #574, AFTER = all four): Cancel on the save prompt created `Project17` BEFORE, nothing AFTER; `My Test` was accepted (`My Test = class`) BEFORE, and `My Test`, `1Test`, `begin`, `T-X` were refused AFTER while `TMyFixture` and an unticked Create Test Unit were accepted; a default DUnitX project AFTER is a Delphi `program` with Win64 only.
- **#575 is more than the spelling:** the now-live `TNewProjectEx` path needed its platform list filtered by `PlatformAvailable` and its C++ settings limited to C++ projects; the C++ result is reasoned, not seen (no C++Builder personality here).
- **Reviews:** one fresh subagent for all four: #574 none; #575 5 (3 fixed); #576 1 (fixed: the XE2-XE8 wizard had the same bugs); #577 5 (2 fixed).

**Outcome (2026-11-02):** #574-#578 all merged by 17:14, each unchanged (#577's patch-id differs only by context; its changed lines are identical).  Vincent did not answer #578's cost question, so upstream's default is the whole-test leak measurement.  Then a wrap-up on #398 ([comment](https://github.com/VSoftTechnologies/DUnitX/issues/398#issuecomment-6570636335), Ian asked): everything sent and merged, #414 the last.

## 7. `AreSame` identity, re-offered (posted 17:30 +11, Ian: "Approved to publish")

#414 was still open (batch 2's record said closed; corrected).  #415 had been closed after Vincent's "This is a behavior change - not sure about this"; with 2.0.0 collecting behaviour changes it went again on `2299609` with a `BREAKINGCHANGES.md` section.  The `TObject` overloads compare references; a nil shows as `nil` in the message instead of an access violation.  Seven tests red on `2299609`; four mutants killed; review 4 findings, all fixed (doc accuracy, a nil-message test).  Not changed, reported: the DUnit-compatibility `CheckSame(TObject)` goes through `AreEqual<TObject>` (so `Equals`), the same flaw; this fork fixed its own copy in October.

**#579 merged 2026-11-02** as `f3f9373` (tree identical to `0521642`); #414 closed with it.  Nothing to port: this fork has compared references since October.

## 8. NUnit `time` test and the locale (posted 2026-11-04 06:10 +11, Ian: "Approved to publish")

luebbe reported (#580) that our #453 test formatted the expected `time` attribute with the machine's settings, so a German locale expected `0,000` where the logger rightly writes `0.000`.  Test-only fix on `f3f9373`: the expected value is built with a `'.'` decimal separator.  Red with `','` forced as the separator, green after; 547 passed.  Review: no findings.

**#581 merged 2026-11-03** (21:30 UTC) as `8626022` (tree identical to `242727d`); #580 closed with it.  Nothing to port: this fork has no such test.

## This fork

Upstream's tests for #568 and #578 were ported here as guards on 2026-11-02 (`30a2871`): every case passes except the parallel one (no parallel runner here); porting #578's logger case found one real gap here, fixed test-first.  The constructor is still called twice here, once upstream (Help.md §10).  The expert's `TestFixtureAttribute` name came from #577 (`481d6b5`); #574-#576 were already here.
