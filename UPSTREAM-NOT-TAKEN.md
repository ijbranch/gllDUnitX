# Upstream changes reviewed and deliberately not taken

Moved from `CHANGELOG.md` on 2026-10-13: these record decisions not to change anything, so they are not
changelog entries. Keep them so the same reviews are not re-derived later.

## Reviewed and deliberately NOT taken from upstream, so they are not re-derived later

- **GitHub-wide survey 2026-10-12: no DUnitX anywhere is newer or more complete than this fork.**
  `upstream/master` is fully in (its tip `1bdc297`, #397, is our `cf2248c`). Of upstream's 217 forks, 29 are ahead
  of master; already here in equivalent form: bero (help-screen leak), luebbe (`IsSameDate` / `IsSameTime` /
  `IsSameDateTime`), henriquewerlang (`DUnitX.Banner.pas` uses), ArneSaathoffORGADATA #263
  (`DUnitX.TestDataProvider.pas` include), gskoczylas (runtime ignore), LiaHombrinkORGADATA #244 (`[Ignore]` on a
  whole fixture: `fixture.Ignored` in `DUnitX.FixtureProvider.pas`, tested by `Tests/DUnitX.Tests.IgnoreFixture.pas`;
  an earlier version of this entry wrongly said it was missing). NOT taken: bernd5 (virtual
  `DoCreateFixture`, an extension hook with no consumer), TASC-Git / celeburdi (VCL GUI runner tweaks; celeburdi's
  2018 rewrite conflicts), fabiorizzuto (NaN `IsNan` check — unnecessary, proved by the NaN tests under Added in `CHANGELOG.md`). The
  rest are pre-XE2 compatibility, FMX, path edits or merge noise. The 17 non-fork repos named DUnitX and the 6
  vendored copies found by code search are tutorials, demos or stale snapshots (latest 2017).

- **Upstream swept 2026-09-18: `upstream/dev` reviewed, nothing taken.** This fork is **0 commits
  behind `upstream/master`** (tip `a69a10b`, 2026-08-24). `dev`'s tip `f40670c` is **2025-05-05** -
  fifteen months OLDER than master and 45 commits behind it, never merged.
  - `01b2dc5` "BREAKING Changes" - **REFUSED, and this is the dangerous one.** It removes the
    first parameter of `TestCaseAttribute.Create`. Every one of the estate's **143
    `[TestCase('Name','a,b')]` sites would still COMPILE** and silently mean something else - the
    name becomes the value and the values become the separator. A silent-miscompile migration,
    not a drop-in. It also rewrites 167 lines of `DUnitX.FixtureProvider.pas` including
    `GenerateTests`, which carries the `FFixtureClasses.ContainsKey` dedupe that lets RTTI
    discovery and explicit `RegisterTestFixture` coexist - the very mechanism the estate rule
    "keep BOTH discovery mechanisms" depends on.
  - `055e7a8` (parallel fixture running), `7350c5d` (no-asserts across threads) and `f40670c`
    (tail-end tidy) - REFUSED. A 2025 feature on a branch 45 commits behind master, rewriting
    runner and logger units that master has since changed; `7350c5d` only has an effect GIVEN
    `055e7a8`, and `f40670c` touches `TParallel` code that does not exist here.
  - **Assertion semantics and exit codes are untouched by all four** - nothing goes near
    `DUnitX.Assert.pas`, and `git diff HEAD...upstream/dev -- Source/` has zero `ExitCode` hits.
  - **Correction to an earlier note in this file:** it said `dev` DELETES the `ETestIgnored`
    handler. `dev` never had it - `24c353b` ("Allow the test to be ignored at runtime") is
    master-only. The outcome of taking `dev`'s runner would be the same (no handler, so
    `Assert.Ignore` loses its footing) but the wording implied a deliberate removal.
  **Condition to reopen:** upstream merges `dev` into `master`. Re-triage against the merged
  result, and budget a mechanical sweep of all 143 `[TestCase(` sites FIRST.
