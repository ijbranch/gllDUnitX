# DUnitX upstream: batch 14 (posted 2026-11-02)

The runner changes from the #398 list ("happy for all of the above to be addressed"), one PR at a time, each on the `master` of the day, pushed to [`ijbranch/gllDUnitX`](https://github.com/ijbranch/gllDUnitX).

| # | Defect | Issue | PR | Branch | Head | Merged |
|---|---|---|---|---|---|---|
| 1 | One fixture whose constructor raises aborts the whole run (report 2.3 (a)) | [#567](https://github.com/VSoftTechnologies/DUnitX/issues/567) | [#568](https://github.com/VSoftTechnologies/DUnitX/pull/568) | `fix/fixture-constructor-raises` | `fc8d29b` | |

## 1. A raising fixture constructor (posted 16:25 +11, Ian: "Approved to publish")

Built on `f5ab75a`.  The fixture keeps what its constructor raised (`AcquireExceptionObject`, with the address) and leaves the instance nil; `InitFixtureInstance` raises it once at run time (`raise ... at` the original address), and `ExecuteFixture` reports each of the fixture's tests that will run as an error with that exception (ignored for `ETestIgnored`), skipping its setup, tests and teardown.  `InternalInitFixtureInstance` also rebinds `[Setup]`, `[TearDown]`, `[SetupFixture]` and `[TearDownFixture]` to a new instance, as it already did the tests, so a GUI re-run after the constructor stops raising runs on the new instance.  The parallel path (`-m:x`) goes through the same `ExecuteFixture`.

- **Tests** (`TFixtureConstructorTests`, five): red on `f5ab75a` on their own assertions (the build raised `EFixtureConstructorFailed`); 536 passed, 9 ignored, serial and `-m:4`.  Nine mutants, all killed; two defensive lines (the `[SetupFixture]` rebind and guard) are unreachable while part (b) stands.
- **End to end:** with a raising fixture registered in the real test exe, before: exit 1, nothing ran, empty XML; after: exit 1, 535 passed, 9 ignored, 2 errors (that fixture's tests).  The report's "exits 0" no longer held: upstream's test project now sets `EXIT_ERRORS` in its `except`.
- **Review:** 8 findings, 6 fixed (all-ignored or filtered fixtures were errored; the error address; untested teardown rebinds; `BREAKINGCHANGES.md` for custom runners: `FixtureInstance` can be nil, `InitFixtureInstance` can raise; wording; an unused variable), 2 declined (`[RepeatTest]` child fixtures with a constructor that raises only sometimes; child fixtures bound to a freed parent instance after a GUI re-run, as on upstream today).
- **Left alone:** fixtures are still built eagerly, even under `--run:OneTest`; part (b), a parameterless constructor disabling `[SetupFixture]`.

## This fork

This fork contains a raising constructor in its own way (`ExecuteFixtures` catches `InitFixtureInstance`); compare with #568 when it merges.
