# DUnitX upstream: batch 12 (posted 2026-11-02)

The behaviour changes from the list on [#398](https://github.com/VSoftTechnologies/DUnitX/issues/398#issuecomment-6567841508), which Vincent agreed to ("happy for all of the above to be addressed"), for the 2.0.0 release.  Built on `master` @ `97d8c35`, one branch per defect in its own worktree, pushed to [`ijbranch/gllDUnitX`](https://github.com/ijbranch/gllDUnitX).

**Posted 2026-11-02 15:20 +11** (Ian: "Approved to publish"): five issues with PRs, one question issue, and a [comment on #398](https://github.com/VSoftTechnologies/DUnitX/issues/398#issuecomment-6568862373) listing them and correcting the fixture-order item.  GitHub showed all five PRs as clean merges.

| # | Defect | Issue | PR | Branch | Head | Merged |
|---|---|---|---|---|---|---|
| 1 | A misspelt or unregistered `[TestCaseProvider]` (or one with no cases) silently gives the method no tests (report 2.9) | [#553](https://github.com/VSoftTechnologies/DUnitX/issues/553) | [#559](https://github.com/VSoftTechnologies/DUnitX/pull/559) | `fix/testcaseprovider-unregistered` | `2eebcdc` | 2026-11-02 `98cc9c0` |
| 2 | A method's `[Category]` replaces the fixture's instead of adding to it (report 2.8) | [#554](https://github.com/VSoftTechnologies/DUnitX/issues/554) | [#560](https://github.com/VSoftTechnologies/DUnitX/pull/560) | `fix/method-category-adds-to-fixture` | `3f1438c` | 2026-11-02 `34c9c48` |
| 3 | `[SetupFixture]` runs when a filter leaves only ignored tests, and is skipped when only `[RepeatTest]` repetitions will run | [#555](https://github.com/VSoftTechnologies/DUnitX/issues/555) | [#561](https://github.com/VSoftTechnologies/DUnitX/pull/561) | `fix/setupfixture-all-ignored` | `089bcf2` | 2026-11-02 `cc247a9` |
| 4 | `--run` matches by text prefix (`Unit.TFoo` runs `Unit.TFooBar`) | [#556](https://github.com/VSoftTechnologies/DUnitX/issues/556) | [#562](https://github.com/VSoftTechnologies/DUnitX/pull/562) | `fix/run-exact-name-match` | `3a7ca8e` | 2026-11-02 `de7a7cd` |
| 5 | A bare argument is taken as the XML output file | [#557](https://github.com/VSoftTechnologies/DUnitX/issues/557) | [#563](https://github.com/VSoftTechnologies/DUnitX/pull/563) | `fix/bare-argument-not-xml-file` | `9dd3819` | 2026-11-02 `9c85dd5` |
| 6 | `Assert.IsType<T>` can never fail: remove, make it fail, or leave (question only) | [#558](https://github.com/VSoftTechnologies/DUnitX/issues/558) | - | - | - | |

**Outcome (2026-11-02):** all five merged by 15:31 +11, each unchanged (`git patch-id` equal to its branch); the distinct `BREAKINGCHANGES.md` anchors meant no PR ever went into conflict.  #558 answered: "Lets go with option 2" (always fail), sent as #566 in batch 13.

## How this batch was built

- **Test first, then mutation-proved**, each red on `97d8c35` on its own assertion: #1 three tests plus a success-path guard (4 mutants killed); #2 four tests (5 of 5 killed); #3 three red plus two regression guards (5 of 6 killed: the surviving one removes a `fixture.Ignored` check that provider-built fixtures make redundant, kept to match `HasActiveTests`); #4 three red plus a generic-fixture test added after review (all mutants killed); #5 one red plus a guard (3 killed).  No existing upstream test changed.
- **Reviews** (a fresh subagent per PR): #1 7 findings, 3 fixed, 4 declined; #2 6, 4 fixed, 2 declined; #3 6, 4 fixed, 2 declined; #4 8, 4 fixed, 4 declined; #5 8, 5 fixed, 3 declined.
- **`BREAKINGCHANGES.md`**: each PR adds a section, each before a DIFFERENT existing heading (not all at the end), so the five PRs and batch 11's #550/#551 merge with one another in any order.  Checked with `git merge-tree` on every pair of the eight open branches.
- **Combined:** all eight merged on `97d8c35` build with only upstream's existing H2675 / W1000, and the suite gives 529 passed, 9 ignored, serially and with `-m:4`.

## Decisions taken in the PRs

- #1: a registered provider that returns no cases for a method now errors too, as `[TestCaseSource]` already does ("returned no cases").  The part most likely to be questioned.
- #3: the premise on the #398 list was half wrong.  Upstream already skipped the fixture setup when every test was `[Ignore]`d (`HasActiveTests`); the PR fixes the two real gaps (filtered-out tests counted; repetitions run without setup) with a new `HasTestsToRun`.
- #4: a test's full name now also selects its cases (`Unit.TFoo.Test1` runs `Test1(1,2)`).  `--run:Unit.TFoo.Test1` already did not select a plain `Test10`; only a `[RepeatTest]` `Test10` (a child fixture) was caught.
- #5: Vincent added the unnamed option himself (`59c4e63`, 2014), so a bare argument ending in `.xml` still names the output file; anything else is a command-line error.  The PR offers to reject every bare argument instead.

## Not sent

- **Fixture order** ("fixtures run in memory-address order" on the #398 list) was wrong for upstream: `TDUnitXTestRunner.BuildFixtures` calls `FFixtureList.Sort`, which sorts by `FullName` with `CompareStr`, children too, since `c5deb79` (2020), so it was there at the report's base `1bdc297`.  Corrected on #398.  A test-only PR pinning the sort was offered by the agent and not sent.

## This fork

- #2: this fork deliberately kept upstream's replace behaviour for a method's `[Category]`.  If #560 merges, this fork differs from upstream until Ian decides whether to take it.
- The others: compare each merged PR with this fork's own behaviour when it lands, and port or record the difference.
