# gllDUnitXTests

The DUnitX framework's own test suite (`DUnitXTest_D13.dproj`, runner target `gllDUnitXTests`).  Its change record is
`CHANGELOG.md` beside this file.

## Ignored tests: all deliberate

A run reports **9 ignored** tests.  None of them pins a defect: each exists to prove that DUnitX itself honours
`[Ignore]` or `[RepeatTest(0)]`, and each body fails (or raises) if it is ever run, so a runner that stops honouring
the attribute turns the suite red.  `verify_change` warns on any ignored test; for this suite the warning is expected
while the list below is exactly what the run reports.

| Unit | Test | Why it is ignored |
|---|---|---|
| `DUnitX.Tests.Example.pas` | `IgnoreMe` | Proves an `[Ignore]`d test is reported as ignored and never run. |
| `DUnitX.Tests.Example.pas` | `IgnoreMeAnyway` | The same for a published test without `[Test]`. |
| `DUnitX.Tests.IgnoreFixture.pas` | `Test_A`, `Test_B` | A whole fixture under `[Ignore]`: every method raises, so the suite stays green only if the fixture is skipped. |
| `DUnitX.Tests.IgnoreFixture.pas` | `IgnoredTest_A`, `IgnoredTest_B` | Individually ignored tests in a fixture whose setup and teardown must then not run. |
| `DUnitX.Tests.TestFixture.pas` | `TestTimeout` | Would prove `[MaxTime(100)]` times out a 150 ms test, but a timeout fails the test itself; `TRunnerBehaviourTests.MaxTimeOverrunIsCaughtWhateverTheTiming` proves it through a private runner instead. |
| `DUnitX.Tests.TestFixture.pas` | `IgnoreMeWhenRepeatIsZero`, `IgnoreMeAnyWayWhenRepeatIsZero` | Prove `[RepeatTest(0)]` reports the test as ignored ("Repeat set to 0. Test ignored.") rather than running it. |

Adding, removing or renaming one of these: update this table in the same change, so the count a run reports always
matches it.
