# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- **Upstream outcome of batch 5 recorded** (2026-10-15) — `UPSTREAM-ISSUES-Batch5.md`,
  `UPSTREAM-REPORT-Defects-2026-10-12.md`. All six PRs merged on 2026-10-15: #453 (`8d91bcf`), #455 (`4273e0f`),
  #457 (`61f1d3e`), #459 (`1460934`), #461 (`1e95e6b`) and #463 (`3efb0eb`); `upstream/master` is now @ `4273e0f`; the fork's `master` was fast-forwarded to it and the six branches were deleted from `ijbranch/DUnitX` (each matched its squash commit by patch ID first).
  Nothing to bring into this fork: the merged commits are our own fixes, already here.
- **Upstream merge of #451 recorded** (2026-10-15) — `UPSTREAM-ISSUES-Batch4.md`, `UPSTREAM-ISSUES-Batch5.md`,
  `UPSTREAM-REPORT-Defects-2026-10-12.md`. The `ToVarRec` / `ToVarRecs` removal merged (`upstream/master` @
  `615be86`) and #450 closed; the fork's `master` was fast-forwarded and `remove/tovarrec` deleted. Nothing to bring
  into this fork: it keeps its own caller-held-storage version of G.
- **Fifth batch of upstream issues and pull requests** (2026-10-15) — `UPSTREAM-ISSUES-Batch5.md`,
  `UPSTREAM-REPORT-Defects-2026-10-12.md`, `Help.md`, `CONTRIBUTING.md`. Items 3.10 (rest), 2.7 (rest), 3.9 (rest),
  3.11, 2.2 and a JUnit `<testsuite>` count fix this fork already carries, filed as issues #452/#454/#456/#458/#460/#462
  with PRs #453/#455/#457/#459/#461/#463 on `upstream/master` @ `687af04`. The seven new tests fail on master on their
  own assertions; with the fixes everything passes and only `TestMaxTime` errors; all 21 pairs of the six branches and
  #451 merge cleanly, and each branch builds alone. 3.11 needed `RegisterOptions` in a unit interface after all, and
  it is now in the PR. **Why the JUnit swap:** the 2.7 note about `RollUpResults` and leak counts cannot be seen
  upstream (`IFixtureResult` has no leak count), so it is not sent.
- **Upstream outcome of batch 4, #429 and #450 recorded** (2026-10-15) — `UPSTREAM-ISSUES-Batch3.md`,
  `UPSTREAM-ISSUES-Batch4.md`, `UPSTREAM-REPORT-Defects-2026-10-12.md`. #429 and all six of batch 4 merged on
  2026-10-14 (`upstream/master` @ `687af04`); their branches were deleted from `ijbranch/DUnitX`. On #450 Vincent chose
  to remove `ToVarRec` / `ToVarRecs`, and PR #451 does that. This fork keeps its own caller-held-storage version.
  Nothing to bring into this fork: the merged commits are our own fixes, already here in equal or broader form.
- **Fourth batch of upstream issues and pull requests, and a question on G** (2026-10-14) —
  `UPSTREAM-ISSUES-Batch4.md`, `UPSTREAM-REPORT-Defects-2026-10-12.md`, `Help.md`, `CONTRIBUTING.md`. Items 3.2 with
  3.5 (part), 3.5 (part), 3.6 (rest), 3.10 (part) and 2.7 (two parts) filed as issues #438/#440/#442/#444/#446/#448
  with PRs #439/#441/#443/#445/#447/#449 on `upstream/master` @ `8ff5f0b`. The nine new or corrected tests fail on
  master on their own assertions; with the fixes 332 pass and only `TestMaxTime` errors; all 15 branch pairs merge
  cleanly and each branch builds alone. #439 also corrects two upstream tests that passed only on the access
  violation. Issue #450 asks Vincent to choose how G (`ToVarRec` / `ToVarRecs` dangling pointers) is fixed upstream,
  since a full fix is an API change. **Why the build note:** upstream's tests built with `DCC_BuildAllUnits` need
  `/p:DelphiMocks=D:\glldelphi-mocks\Source`; earlier builds had only worked off a stray `Delphi.Mocks.dcu`.
- **Upstream outcome of batch 3 recorded** (2026-10-14) — `UPSTREAM-ISSUES-Batch3.md`. #427, #431, #433, #435 and
  #437 merged (`upstream/master` @ `8ff5f0b`) and their branches were deleted from `ijbranch/DUnitX`. #429 stays open:
  Vincent said `IsInfinite` was not in XE2, the PR was reworked to compare with `Infinity`, and he then found that
  XE2 has it after all; the reworked version stands. Nothing to bring into this fork: the merged commits are our
  own fixes, already here in equal or broader form.
- **Third batch of upstream issues and pull requests** (2026-10-14) — `UPSTREAM-ISSUES-Batch3.md`,
  `UPSTREAM-REPORT-Defects-2026-10-12.md`. Items 3.1, 3.4, 3.5 (part), 3.6 (part), 3.9 (part) and F (part) filed as
  issues #426/#428/#430/#432/#434/#436 with PRs #427/#429/#431/#433/#435/#437, built on `upstream/master` @
  `a710952`. Each test failed on master on its own assertion; all 15 branch pairs merge cleanly, and the six together
  build and run with only upstream's known `TestMaxTime` error (337 tests). **Why these six:** upstream closed #415 over
  a behaviour change, so this batch takes only defects whose old behaviour is plainly wrong. 3.11 was swapped out
  because testing it would mean moving `RegisterOptions` into a unit interface. Before the batch, the three merged
  batch 2 / #425 branches were deleted from `ijbranch/DUnitX`. `Help.md` and `CONTRIBUTING.md` now point at the batch 3
  file, and `Help.md` notes that upstream `.pas` files must be edited byte-exact (the local hook would add a BOM).
- **Upstream outcome of batch 2 and of #425 recorded** (2026-10-14) — `UPSTREAM-ISSUES-Batch2.md`. Five of six merged
  (#413, #417, #419, #421, #423); #415 (`AreSame` identity) closed unmerged, so that fix stays here only. #425, our fix
  for the #424 regression (#407's `ValuesEqual<T>` AV on a type without RTTI), merged; `upstream/master` @ `a710952`.
  Nothing to bring into this fork: its `AreEqual<T>` uses `TEqualityComparer` directly and never had the defect.
- **Second batch of upstream issues and pull requests** (2026-10-13) — `UPSTREAM-ISSUES-Batch2.md`,
  `UPSTREAM-REPORT-Defects-2026-10-12.md`. Six items (D, 3.3, 1.8, E, 1.7 and the XML file loggers' bare-file-name
  crash) filed as issues #412/#414/#416/#418/#420/#422 with PRs #413/#415/#417/#419/#421/#423, built on
  `upstream/master` @ `6af7aeb`. Each PR has a test that failed on master on its own assertion, and the six together
  build and run clean (330 tests, 0 failures). **Why the changed method:** in batch 1 every merge put the next PR
  into conflict, because all six added their tests at the same place; this batch places each PR's tests beside the
  related existing ones, edits no `.dproj` (the shared `pre-commit` hook strips upstream's) and no shared `uses`
  clause, and every pair of branches was checked to merge cleanly before posting. The lessons are listed in the
  batch file.
- **Note: this fork does not take upstream #372 / PR #411 (bitmask exit codes)** (2026-10-13) —
  `UPSTREAM-REPORT-Defects-2026-10-12.md`. Upstream merged all seven PRs, #405-#411, on 2026-10-13 (`upstream/master`
  @ `6af7aeb`); #406, #407 and #408 first needed their conflicts with the earlier merges fixed. #411
  stays out of this fork: our runners set `EXIT_ERRORS` on any failure, error, leak or abort, and every consumer here
  treats any non-zero exit as a failure. **Why:** carrying it adds divergence for no benefit; any later merge from
  upstream leaves #411's changes to `DUnitX.TestFramework.pas`, `DUnitX.OptionsDefinition.pas`, the expert template and
  `Tests\DUnitXTestProject.dpr` (and its `Tests\DUnitX.Tests.ExitCode.pas`) out.
- **`ITestFixtureList.SortByName` and `CheckXmlOutputFileArgument`** (2026-10-13) — `Source/DUnitX.Extensibility.pas`, `Source/DUnitX.OptionsDefinition.pas`. The first sorts a fixture list by full name at every level (see Fixed); the second checks the bare command-line argument (see Fixed).
- **Attribution: every changed source file says so, and the README credits both sides** (2026-10-13) - 58 source files (53 `.pas` given a notice line under their original copyright; 3 test units and 2 `.dpr` that never had a header given one), `README.md`, `VSoft.DUnitX.dspec`. Each file this fork changed now carries "Modified (C) 2026 Ian Branch (GITLAK Software) - gllDUnitX fork" beneath its upstream copyright notice, which is kept intact; the headerless five credit "DUnitX, by Vincent Parrett & Contributors" without inventing a copyright year. `DUnitX.Timeout.pas` already carried its own line. The README's licence section now states that the fork's changes are (C) 2026 GITLAK Software under the same Apache 2.0, that upstream commits keep their authors in the history, and that the fork is not affiliated with or endorsed by VSoft Technologies; it also says plainly that the test project's `glldelphi-mocks` dependency is a private repository. The DPM spec's description no longer says "64 bit Windows only" (Win32 returned on 2026-09-10). **Why:** Apache 2.0 §4(b) requires a prominent change notice on each modified file before distribution, and only 1 of 57 changed units had one - so readers could not tell this fork's work from upstream's, and the upstream copyright stood alone on code its authors did not write. Done ahead of any decision to make the repository public; harmless while it is private.

- **First batch of upstream issues and pull requests** (2026-10-12) — `UPSTREAM-ISSUES-Batch1.md`,
  `UPSTREAM-REPORT-Defects-2026-10-12.md`. Upstream's process, given in reply to #398, is one issue per problem, each
  followed by a PR with a test that shows it; the VCL GUI runner is not maintained upstream, so its fixes (report
  section 4) stay fork-local. Six items (1.1, 1.2, 1.3, 1.4, 1.9, 1.10) were filed as issues #399-#404, with PRs
  #405-#410. Each PR branch was rebuilt on `upstream/master` @ `1bdc297` rather than cherry-picked. Five have a test
  that failed on master on its own assertion before the fix; 1.10 is in the program's main block and was verified by
  exit code. Branches live in the worktree `D:\gllDUnitX-upstream` (remote `dunitx-fork`) and on the public GitHub
  fork `ijbranch/DUnitX`, which exists only to carry PRs. Report section 9 records the response and the batch.
  **Why small batches:** upstream takes items one at a time rather than as a long report, and each PR has to be
  re-derived against upstream's tree.
- **Defect report addressed to the upstream maintainers** (2026-10-12) — `UPSTREAM-REPORT-Defects-2026-10-12.md`.
  A review of `Source\`, the VCL GUI runner and the IDE expert: 49 defects, each confirmed present in
  `upstream/master` @ `1bdc297` and cited by upstream line number (13 reproduced with probe programs, 36 traced),
  plus 8 fixes this fork already carries that are offered back. The worst make a test pass, or a run report
  success, when it should fail. States our environment (Delphi 13, VCL, Win32/Win64) and what was not built or run.
  Filed as [VSoftTechnologies/DUnitX#398](https://github.com/VSoftTechnologies/DUnitX/issues/398) on 2026-10-12;
  upstream responded the same day with its submission process (see the batch entry above). Issues specific to the fork were reported separately in the same review and are not in this
  file. **Later the same day:** item 3.12 was found to be a false positive and is marked withdrawn, and every other item
  was fixed in this fork (see Fixed and Changed) except 2.8, deliberately left as upstream intends; each fix is a
  divergence until upstream takes it. The file carries a per-item fork status. Two follow-up comments were posted on
  #398: one withdrawing 3.12 and offering the fixes as pull requests, and one with seven further defects found
  afterwards (file section 8: leak-check false positives, `WillNotRaise*`, `CheckEqualsBin`, `ToArray`, `ToVarRec`).
- **NaN tests for `Assert.AreEqual` / `AreNotEqual` on `Double` and `Extended`** (2026-10-12) —
  `Tests/DUnitX.Tests.Assert.pas`. Six tests: `AreEqual` must fail with NaN as either argument, and `AreNotEqual`
  must pass when one value is NaN. Prompted by the fork survey below (fabiorizzuto's 2018 fork adds an explicit
  `IsNan` check). **Result: no defect** — `System.Math.SameValue` already returns `False` for NaN, so all six pass on
  Win32 (x87 `Extended`) and Win64 with `Source/` unchanged. Mutation-proved: forcing the four `SameValue` sites in
  `Source/DUnitX.Assert.pas` to never fail / always fail turned all six red. The same run showed these are the
  ONLY tests of `AreNotEqual( Double / Extended )` raising: no older test failed under that mutation.
- **`Assert.AreEqual( Integer, Int64 )` and `( Int64, Integer )` overloads on 64-bit** (2026-10-10) —
  `Source/DUnitX.Assert.pas`, `Tests/DUnitX.Tests.Assert.pas`. Upstream `1bdc297` (#397), cherry-picked with `-x`.
  **Why:** on Win64 `Count`/`Length` are `NativeInt`, so `Assert.AreEqual( 1, List.Count )` mixes `Integer` and
  `Int64`, overload resolution falls through to `AreEqual<T>`, and inference fails with E2532. The estate worked
  around it by writing `AreEqual<NativeInt>` (see the 2026-08-24 CategoryParser entry); upstream's overloads are the
  better fix and the workaround stays valid. Under `{$IFDEF CPU64BITS}`, so Win32 is unchanged. Mutation-checked: with
  the two overloads removed, the two new tests fail to compile with E2532. Suite 289 -> 291 found, 282 passed,
  9 ignored, 0 failed. Upstream `master` is now reviewed to `1bdc297` (2026-10-09).
- `Assert.Ignore` — a RUNTIME test skip, reported as ignored rather than passed (2026-09-09) — `Source\DUnitX.Assert.pas`, `Source\DUnitX.Init.pas`, `Source\DUnitX.TestFramework.pas`, `Source\DUnitX.TestRunner.pas`, `Tests\DUnitX.Tests.Assert.pas`
  **Why:** DUnitX could only skip a test at COMPILE time, via the `[Ignore]` attribute. A test whose precondition can only be discovered by looking — an external tool, a source tree, a database — had no honest option. `Assert.Pass` reports PASS, which is indistinguishable from a test that verified something and hides the gap on every later run; doing nothing hides it more quietly still. This closes that.
  **Almost all of the machinery was already upstream and unused:** `ETestIgnored` was declared in `DUnitX.Exceptions.pas`, `TDUnitXTestRunner.ExecuteTest` already caught it, and `TTestResultType.Ignored`, `IgnoredCount` and `OnTestIgnored` were fully plumbed through every logger. Nothing anywhere raised it. The addition is the missing trigger — `Assert.Ignore`, with `fTestIgnored`/`TestIgnored` mirroring the existing `fTestPass`/`TestPass` injection so the exception class stays replaceable.
  **One real fix went with it, and it is load-bearing rather than cosmetic:** the runner passed `test.IgnoreReason` — the ATTRIBUTE's reason, which is empty for a runtime skip — into `ExecuteIgnoredResult`, so `Assert.Ignore('because X')` recorded the skip and silently dropped the reason. It now prefers `e.Message` and falls back to `IgnoreReason`. Mutation-checked: with that one branch reverted the test is still reported `result="Ignored"` but the reason is absent from the NUnit XML entirely.
  `Assert.Ignore` deliberately does NOT call `DoAssert` — being skipped is not an assertion, and counting it as one would let a test satisfy `FailsOnNoAsserts` by doing nothing but skipping itself. Verified: an ignored test reports `executed="False"`, `asserts="0"`.
  **Divergence note.** Absent from upstream `master` AND `dev` as of 2026-09-09, so this is fork-local and will conflict on a future merge that touches these four units. `upstream/dev` additionally DELETES the `on e : ETestIgnored do` handler this stands on — but dev's tip is 2025-05-05, some sixteen months older than master's, and it has never been merged into master, so the risk is remote. Worth offering upstream: it is small, it uses their own dormant plumbing, and taking it back would remove the divergence. A proposal addressed to the maintainers is drafted at [UPSTREAM-PROPOSAL-Assert-Ignore.md](UPSTREAM-PROPOSAL-Assert-Ignore.md), sent to the maintainers on 2026-09-09; no response yet. It carries the full diff, the mutation evidence, and a heads-up they would want regardless of whether they take the patch: `upstream/dev` deletes the `ETestIgnored` handler this stands on, so the run-time ignore path disappears if that branch ever lands as it stands.
  Covered by `Ignore_Throws_ETestIgnored_Exception` and `Ignore_Throws_ETestIgnored_Exception_With_Message`. Suite: 289 found, 280 passed, 9 ignored, 0 failed.

- **Tips and Tricks** in `README.md` now requires a platform-varying DCU output directory on any project built against `Source\`, and states that `Source\` must never contain `.dcu` files (2026-09-05) — `README.md`, `CONTRIBUTING.md`
  **Why:** the surrounding instruction — "adjust your search paths to point to the repo\\Source folder" — is exactly what leads a consumer into the `F2048` failure recorded above, and it said nothing about DCU output. Documenting the requirement next to the instruction that creates the hazard is the durable half of that fix; deleting the files was only the immediate half.

- `DEPENDENCIES.md`, pinning the exact Delphi.Mocks commit the test suite is verified against (`19ff97e`), with instructions to verify and move a checkout to it (2026-08-24)
  **Why:** upstream pinned `VSoft.DelphiMocks 0.2.2` through DPM; that pin was dropped when this fork switched to a sibling source checkout, leaving the coupling by path with no recorded version. Drift shows up as a *compile* failure in the two logger test units, which is easy to misread.
  `Build/Dependencies.txt` and the `CheckDelphiMocks` build guard now point at the fork and at `DEPENDENCIES.md` respectively - the dependency list still named upstream's GitHub repo.

- `Tests/DUnitXTest_D13.dproj`, derived from the former D12 test project (2026-08-24)
  **Why:** the tree had no Delphi 13 test project at all - the newest was D12.

- A `CheckDelphiMocks` MSBuild target in `Tests/DUnitXTest_D13.dproj` that fails with an actionable message naming the required sibling clone, instead of a bare `F2613 Unit 'Delphi.Mocks' not found` (2026-08-24)

- The test project now resolves Delphi.Mocks from a sibling `glldelphi-mocks` source checkout via the existing `DelphiMocks` property, replacing the DPM package reference (2026-08-24) - `Tests/DUnitXTest_D13.dproj`
  **Why:** there is no DPM cache on the build machine, and the pinned `VSoft.DelphiMocks 0.2.2` had no verified `delphi13.0`/`win64` binding.
- Six count assertions in `DUnitX.Tests.CategoryParser.pas` failed to compile with E2532. Delphi 13 changed `TList<T>.Count` to `NativeInt`, so generic inference against an integer literal became ambiguous; the assertions are now explicitly `AreEqual<NativeInt>` (2026-08-24)
- The Delphi 13 IDE expert failed to compile with E2250 at `DUnitX.Expert.ProjectWizardEx.pas:132`. Delphi 13 declares the wizard glyph callback as `TFunc<UInt64>` rather than `TFunc<Cardinal>`, matching the 64 bit `HICON` that `LoadIcon` returns, so the `function : Cardinal` literals no longer matched any `Create` overload. Both anonymous glyph functions now return `UInt64` (2026-08-24) - `Expert/DUnitX.Expert.ProjectWizardEx.pas`, `Expert/DUnitX.Expert.NewUnitWizardEx.pas`
  **Why:** inherited from upstream - the D13 expert project had never been compiled against the Delphi 13 ToolsAPI.

### Changed

- **Help.md: the single-DUnitX check now skips the two known copies** (2026-10-13) — `Help.md`. Records that `D:/Tools/Check-DUnitXSingleSet.ps1` skips the upstream-PR worktree and the TaurusTLS submodule that gllTMSSmartSetup's clone test recreates, counting them on an INFO line (Ian, 2026-10-13: "make the check script skip those two folders").
- **Help.md section 2 and section 10 re-checked against the machine** (2026-10-13) — `Help.md`. Confirmed: no DUnitX file in RAD Studio's `lib` (all 67 in the moved-aside folder); the package Release folder first on both Search Paths, `$(DUNITX)` on neither; a Win32 build still strips `VS_VERSION_INFO` from the Tests and Examples `.res` and a Win64 build restores it. Corrected: the Win64 Debug DCU Path has the package Debug folder second (after gllFastMM5), not first; the .res size is no longer quoted as exactly 588 bytes. Recorded: `Check-DUnitXSingleSet.ps1` exits 1 on three source copies - the upstream-PR worktree `D:\gllDUnitX-upstream`, a TaurusTLS submodule that every gllTMSSmartSetup clone test recreates, and a session scratchpad.
- **Docs brought in line with the 2026-10-13 fixes** (2026-10-13) — `README.md`, `Help.md`, `Users Guide.md`, `TestCaseProvider.md`, `UPSTREAM-NOT-TAKEN.md`. Override, `WillNotRaise`, `IsType`, `--run`, `@file`, `[TestCase]` conversion and IDE-expert behaviour now described as they are; the troubleshooting rows for the old override and `WillNotRaise` behaviour apply to a DUnitX older than 2026-10-13. Corrected while checking: the provider base class is `TTestDataProvider` in `DUnitX.InternalDataProvider` (the docs named a `TTestDataProviderBase` that never existed, and `GetCaseAmount` for `GetCaseCount`), and the *Users Guide* `-r:` example omitted the unit name, so it could never match. The README lists `UPSTREAM-NOT-TAKEN.md`.
- **`glldelphi-mocks` pin moved to `da3ece2`** (2026-10-13) — `DEPENDENCIES.md`. The test project was re-verified against the published Delphi.Mocks rework: Win64 Release 388 found, 379 passed, 9 ignored; Win32 Release 386 found, 377 passed, 9 ignored; 0 failed, 0 errored, 0 leaked on both. The pin was `59683d3` (2026-10-08).
- **Full DocInsight commenting** (2026-10-13) — every `.pas` under `Source/`, `Tests/`, `Expert/` and `Examples/`. Every interface-section declaration (types, constants, resource strings, fields of every visibility, methods, properties, routines) has a `///` DocInsight block with `<param>` per parameter, `<returns>` on every function and `<exception cref>` where a routine deliberately raises (`ETestFailure` / `ETestPass` / `ETestIgnored` throughout `Assert`). Existing `//` explanations, including fork-history notes, were converted rather than duplicated; every `[Test]` says what it proves, the runner fixtures declared in `DUnitX.Tests.TestFixture.pas`'s implementation section included. Comments only, apart from the separately listed fixes. **Why:** Ian, 2026-10-13: "implement full docinsight commenting". Divergence from upstream in every unit.
- **`DUnitX.Utils.XML` comment corrected** (2026-10-13) — `Source/DUnitX.Utils.XML.pas`. It said an existing `&amp;` was not re-escaped; it is (to `&amp;amp;`), which is correct escaping.
- **`TIoCRegistration.Initialize` no longer calls `inherited Create`** (2026-10-13) — `Source/DUnitX.ServiceLocator.pas`. Calling the constructor as a method on an existing instance did nothing.
- **Housekeeping from the 2026-10-13 review** (2026-10-13) — `VSoft.DUnitX.dspec`, `.gitignore`, `Build/Dependencies.txt`, `LiveTemplates/Install.Readme.txt`, `LiveTemplates/Install.bat`, `packages/RAD Studio 13.0/VSoft.DUnitXWinR.dproj`, `Help.md`, `CHANGELOG.md`. The DPM spec's `targetPlatforms` now lists `win32` as well as `win64`, as its description says. `.gitignore` ignores `__history`/`__recovery` at any depth (it relied on the global ignore file; `/Test/__history` was a typo for `Tests`) and drops the OSX32 leftovers. `Dependencies.txt` no longer points at Bitbucket and Google Code. The live-template readme and installer name `Documents\Embarcadero\Studio\code_templates` and RAD Studio 13. `Bde` is gone from the runtime package's `DCC_Namespace`. `Help.md` no longer says every project sets `DCC_CBuilderOutput`. This file's duplicate `### Changed` heading is merged, and its two non-standard sections moved out: *Reviewed and deliberately NOT taken from upstream* to `UPSTREAM-NOT-TAKEN.md`, *Known Issues* to `Help.md` §10.
- **The wizards now warn when DUnitX may not be found** (2026-10-13) — `Expert/DUnitX.Expert.ProjectWizardEx.pas`, `Expert/DUnitX.Expert.NewUnitWizardEx.pas`, `README.md`. The project wizard warns when the `DUnitX` environment variable does not name a folder containing `DUnitX.TestFramework.pas`. The unit wizard advises when neither the project's search path nor the library path mentions DUnitX; it does not change the project. The README documents the variable and the FastMM5 requirement of the default leak option.
- **The wizards open with the class-name field focused** (2026-10-13) — `Expert/DUnitX.Expert.Forms.NewProjectWizard.dfm`, `Expert/DUnitX.Expert.Forms.NewUnitWizard.dfm`.
- **The design-only package no longer builds implicitly** (2026-10-13) — `Expert/DUnitX_IDE_Expert_D13Florence.dpk`. `{$IMPLICITBUILD OFF}`.
- **`glldelphi-mocks` is public, so the test project builds anywhere** (2026-10-13) — `README.md`, `CONTRIBUTING.md`. Ian, 2026-10-13: "make glldelphi-mocks public too". The test project's dependency went public the same day as this repository, after the same checks (credentials, licences, Apache §4(b) change notices on its 21 changed files, a fork README); the two docs that said it was private and that outsiders could not build the tests now say it is public. The test project builds against it unchanged: 346 passed, 9 ignored.
- **`CONTRIBUTING.md` rewritten; Claude Code credited** (2026-10-13) — `CONTRIBUTING.md`, `README.md`. `CONTRIBUTING.md` was upstream's guide with its link repointed here, so it invited pull requests to a fork that takes none and comes without support; it now says so, sends fixes to DUnitX itself upstream (one issue per problem, then a PR with a failing test), and states the build prerequisites, including that `glldelphi-mocks` is private. Its pointer to the README's former "Tips and Tricks" now names *Installing*. The README credits **Claude Code** (Anthropic's AI coding assistant) under *Contributors* and in the licence paragraph, as having written much of the fork's code, tests and documentation under Ian Branch's direction (Ian, 2026-10-13: "Our Attribution should include Claude Code"); 51 of the fork's 55 commits carry its `Co-Authored-By: Claude` trailer. Copyright stays with Ian Branch (GITLAK Software).
- **README rewritten for the fork as it now is** (2026-10-13) — `README.md`. Titled gllDUnitX rather than "DUnitX Overview", and no longer calls a 2012 framework "new". New sections: *What the fork adds or changes* (`Assert.Ignore`, the defect fixes and where they went upstream, the VCL GUI runner, the `GITLAK.DUnitX` package id); *Installing* (states there is no installer and gives the three steps - source path with a per-platform DCU folder or the runtime package, the optional IDE expert, the optional live templates - plus the bundled-DUnitX shadowing trap); *Building the tests* (the private `glldelphi-mocks`); *Support* (none - pointers to upstream's forum and repository). Upstream's long-stale "Planned Features" list is gone: the GUI runner it listed exists here, and the other items were upstream ideas, not this fork's plans. *Documentation* now lists `CHANGELOG.md`, `DEPENDENCIES.md`, `TestCaseProvider.md` and the `UPSTREAM-*.md` files. The licence and attribution text is unchanged in substance, and *Contributors* names the fork's maintainer beside upstream's list.
- **The VCL GUI runner: fixed here, not maintained upstream, TestInsight the user's choice** (2026-10-13) — `Source/DUnitX.Loggers.GUI.VCL.pas` (comment only), `README.md`, `Help.md`, `Users Guide.md`. Each now says the runner has been fixed and updated in this fork, that upstream does not maintain it and recommends the TestInsight IDE plug-in instead, and that which to use is the user's choice - the fork recommends neither (Ian, 2026-10-13: "We will leave it for the User to decide if they will use testinsight"). The README's feature line no longer reads "this fork does not use TestInsight", which described the estate rather than the fork. The unit compiles clean in a scratch program (it is in no project here).
- **Docs: remarks about the upstream maintainer removed; upstream's process kept as process** (2026-10-13) — `Help.md`, `CHANGELOG.md`, `UPSTREAM-ISSUES-Batch1.md`, `UPSTREAM-REPORT-Defects-2026-10-12.md`. Ian, 2026-10-13: "remove 4" - the fourth of the internal-detail items reviewed ahead of a possible publication. What the maintainer wanted, said, does not use, or found too long is gone; what the workflow needs stays, stated as upstream's process: one issue per problem with a PR whose test fails on `upstream/master`, the VCL GUI runner not maintained upstream (so its fixes stay here), and batches sent one at a time. The formal "To: the DUnitX maintainers" headers of the two reports stay. The other three items - local paths, GITLAKMCP references, quoted rules - are kept deliberately.
- **The IDE expert is Delphi-only, Win32/Win64-only and D13-only** (2026-10-12) — `Expert/DUnitX.Expert.Registration.pas`, `Expert/DUnitX.Expert.CodeGen.Templates.pas`, `Expert/DUnitX.Expert.CodeGen.NewTestUnit.pas`, `Expert/DUnitX.Expert.CodeGen.NewUnit.pas`, `Expert/DUnitX.Expert.CodeGen.NewProject.pas`, `Expert/DUnitX.Expert.CodeGen.NewTestProject.pas`, `Expert/DUnitX.Expert.CodeGen.SourceFile.pas`, `Expert/DUnitX.Expert.ProjectWizardEx.pas`, `Expert/DUnitX.Expert.NewUnitWizardEx.pas`, `Expert/DUnitX.Expert.Forms.NewProjectWizard.pas`, `Expert/DUnitX.Expert.Forms.NewUnitWizard.pas`. Removed: the `sCBuilderPersonality` gallery registrations, the C++ templates (`STestCBPROJ`, `STestCPPUnit`, `SSetupTearDownCPP*`, `SSampleMethodsCPP*`), the never-used C++-only `TNewTestUnitEx`, the personality plumbing (`TNewUnit.Personality`, `TNewProjectEx.Personality`, the personality overload of `TTestProjectFile.Create`), the `{$ELSE}` branch in `Register` naming units that no longer exist, the `USE_NS`/`DELPHI_XE2_UP`/`DELPHIX_SEATTLE_UP` conditionals, unused `Vcl.Dialogs`/`Vcl.Graphics` uses and the unused global form variables `frmDunitXNewProject`/`frmDunitXNewUnit`. Both gallery entries now filter on `[cWin32Platform, cWin64Platform]` instead of `GetAllPlatforms`. **Why:** C++Builder and non-Windows platforms are out of scope for this estate. Divergence from upstream.
- **The generated test project `.dpr` is a plain console runner with no TestInsight blocks** (2026-10-12) — `Expert/DUnitX.Expert.CodeGen.Templates.pas`. Removed the `{$IFDEF CI}{$UNDEF TESTINSIGHT}`, `{$IFDEF TESTINSIGHT}` uses/var/mainline sections and the `{$IFNDEF CI}` guard around the pause; the runner still honours `--exit` (it pauses only for `--exit:Pause`; the default is `Continue`). **Why:** TestInsight was deliberately removed from the IDE. Divergence from upstream.
- **`{$WARN SYMBOL_DEPRECATED OFF}` is no longer unit-wide in the expert** (2026-10-12) — `Expert/DUnitX.Expert.CodeGen.NewProject.pas`, `Expert/DUnitX.Expert.CodeGen.NewUnit.pas`. In `NewUnit` it suppressed nothing and is gone. In `NewProject` it now covers only the interface `type` section (OFF before `type`, DEFAULT after `implementation`): the compiler reports W1000 for the deprecated `IOTAProjectCreator` methods `GetOptionFileName`/`NewDefaultModule`/`NewOptionSource` at each class header and again at `implementation`, and implementing them is mandatory. Verified: without it, nine W1000; with it, zero in all four modes.
- **The New Test Project wizard offers FastMM5 only, and selects it by default** (2026-10-12) —
  `Expert/DUnitX.Expert.CodeGen.NewTestProject.pas`, `Expert/DUnitX.Expert.Forms.NewProjectWizard.pas`,
  `Expert/DUnitX.Expert.Forms.NewProjectWizard.dfm`. The "Report Leak Options" group was None / FastMM 4 /
  FastMM 5, defaulting to None. **Why:** FastMM4 is not on this estate's library path (gllFastMM5 is the standard), so
  the FastMM 4 choice generated a project that did not compile. `rloFastMM4` is removed from `TReportLeakOptions`, the
  group is now None / FastMM 5 with FastMM 5 selected, and `GetReportLeakOption` range-checks `ItemIndex` instead of
  casting it blind (it falls back to FastMM5). **Divergence from upstream**, which keeps all three choices; the
  `DUnitX.MemoryLeakMonitor.FastMM4` unit itself is untouched. Built clean in all four modes.
- **Build auto-increment switched on for the runtime package and the IDE expert** (2026-10-12) —
  `packages/RAD Studio 13.0/VSoft.DUnitXWinR.dproj`, `packages/RAD Studio 13.0/VSoft.DUnitXWinR.res`,
  `Expert/DUnitX_IDE_Expert_D13Florence.dproj`, `Expert/DUnitX_IDE_Expert_D13Florence.res`. Same shape as
  `GITLAKLib.dproj`: version info on both platforms, `VerInfo_AutoIncVersion` in `Base_Win64` and the `Cfg_N_Win64`
  groups. The package had no platform groups at all (all six added) and no version info; it starts at `0.5.1`,
  upstream's latest tag `v0.5.1`. The expert already had version info at `1.0.0` and gained the four config-platform
  groups. Both `.dpk` files already link `{$R *.res}`. Built in all four modes, runtime before design-time, Release
  last, zero diagnostics; all eight BPLs carry version info and `VerInfo_Build` moved. **Why:** the estate rule that
  our libraries and packages auto-increment; approved for this upstream fork by Ian (2026-10-12).
- **Build auto-increment switched on for the test and example exes, which also had no version resource at all**
  (2026-10-12) — `Tests/DUnitXTest_D13.dproj`, `Tests/DUnitXTestProject.dpr`, `Tests/DUnitXTest_D13.res`,
  `Examples/DUnitXExamples_D13.dproj`, `Examples/DUnitXExamples_D13.dpr`, `Examples/DUnitXExamples_D13.res`.
  `VerInfo_IncludeVerInfo` / `VerInfo_AutoIncVersion` set in `Base_Win64` and both `Cfg_N_Win64` groups (the Tests
  project lacked those groups; Delphi writes `VerInfo_Build` only into a config-and-platform group). Neither `.dpr`
  linked a resource: the Examples one now has `{$R *.res}`; the Tests one names `{$R DUnitXTest_D13.res}` explicitly,
  because the file is `DUnitXTestProject.dpr` while the resource is generated beside the `.dproj`. Verified: both
  Win64 exes now report `1.0.0.1` / their project name, and `VerInfo_Build` moves on each build. Win64 only.
- **Delphi.Mocks pin moved to `59683d3` (2026-10-08) and the recorded green counts refreshed** (2026-10-12) —
  `DEPENDENCIES.md`. The sibling `glldelphi-mocks` checkout had moved 13 commits past the old pin `2c3a51f` (a
  descendant on `main`, not a divergence), and the suite was re-verified against it: Win64 297 found / 288 passed /
  9 ignored, Win32 295 / 286 / 9, 0 failed, errored or leaked. The branch name was also wrong (`master` -> `main`).
  `Help.md` gains a NaN note under the assertion gotchas.
- **D13 language features adopted** (2026-10-08) - `Source/DUnitX.CommandLine.OptionDef.pas`, `Source/DUnitX.Loggers.GUI.VCL.pas`, `Source/DUnitX.RunResults.pas`. 2 `not ( X in S )` / `not ( X is T )` rewritten as `X not in S` / `X is not T` (generated code byte-identical: every project that built before was rebuilt and compared); 1 `IfThen(...)` call replaced by the `if ... then ... else` expression, which evaluates only the branch it picks. **Divergence accepted:** upstream was reviewed first (nothing pending was lost), and Ian's ruling for the gll* forks is that they "are our forks now", to be made "as correct as possible/practical"; these lines will need re-applying or resolving in any later upstream port.
- Documentation brought level with the D13 / Win32+Win64 / no-C++Builder / no-non-Windows
  state (2026-09-10) — `CONTRIBUTING.md`, `README.md`, `UPSTREAM-PROPOSAL-Assert-Ignore.md`
  Stale supported-version ranges, per-IDE folder paths, C++Builder offers, non-Windows
  platform claims and Win64-only/Win32-only statements corrected against the current tree.
  Dated reports and upstream-authored prose were left as history.

- Non-Windows conditional compilation resolved away in 4 source files — 11 constructs (2026-09-10)
  `{$IFDEF POSIX|LINUX|ANDROID|IOS|MACOS|OSX|UNIX}` blocks were dropped and
  `{$IFDEF MSWINDOWS|WINDOWS}` blocks collapsed to their Windows branch, keeping exactly
  what a Win32/Win64 compile keeps. Conditions that are not constant across both our
  platforms (`WIN32`, `WIN64`, `CPUX64`, compound `{$IF}`) were left untouched, as were
  files whose directive nesting is unbalanced by design (JEDI-style includes).
  **Why:** the dead branches could never be reached here and only misled the reader.

- Project platforms normalised to Win32 + Win64 only in 4 `.dproj` files (2026-09-10)
  Non-Windows targets (`Android`, `Android64`, `iOS*`, `OSX*`, `Linux64`) and the
  `Win64x` / `WinARM64EC` variants were removed together with their `Base_<Plat>` and
  `Cfg_N_<Plat>` property groups, `<Deployment>` platform nodes and `<ProjectRoot>`
  entries; a deactivated `Win32` or `Win64` was switched on.
  **Why:** standing suite rule — every gll* project is Delphi 13, Win32 + Win64, nothing
  else, so the four-mode package sweep is always possible.

- Codeberg is no longer used: every repository URL points at GitHub again (2026-09-05) — `Build/Dependencies.txt`, `CONTRIBUTING.md`, `DEPENDENCIES.md`, `README.md`, `Tests/DUnitXTest_D13.dproj`, `VSoft.DUnitX.dspec`
  **Why:** hosting consolidated back on GitHub, so `https://codeberg.org/GITLAK-forks/gllDUnitX` becomes `https://github.com/ijbranch/gllDUnitX` and `https://codeberg.org/GITLAK-forks/glldelphi-mocks` becomes `https://github.com/ijbranch/glldelphi-mocks`. That includes the `CheckDelphiMocks` build-guard message in `Tests/DUnitXTest_D13.dproj`, which tells the reader where to clone from. The stale `codeberg` git remote was removed from the working checkout; `origin` is the GitHub URL and is the only remote to push to.

- Repository moved to the `GITLAK-forks` Codeberg organisation: the documentation references were updated to match. **Why:** the `GITLAK` account had reached Codeberg's hard limit of 100 repositories, and an organisation carries its own allowance (2026-09-03) — `Build/Dependencies.txt`, `CONTRIBUTING.md`, `DEPENDENCIES.md`, `README.md`, `Tests/DUnitXTest_D13.dproj`, `VSoft.DUnitX.dspec`
  **Superseded 2026-09-05** by the entry above; Codeberg is no longer used at all. This entry also claimed that "`origin` is now `https://codeberg.org/GITLAK-forks/gllDUnitX.git`", which was never true of the working checkout — `origin` remained the GitHub URL throughout and Codeberg was only ever a second remote named `codeberg`. The documentation was updated; the remote was not.

- `upstream/master` is merged as far as `a69a10b` (2026-08-27). The commit had already been cherry-picked on 2026-08-26 (see Fixed), so the merge changes no file - it exists so the fork's position can be measured with `git merge-base` instead of by patch comparison, which does not recognise an adapted cherry-pick.

- **C++Builder output turned off** (2026-08-26). `DCC_CBuilderOutput` was `All`, so every build emitted `.hpp` / `.bpi` / `.a` / `.obj` files for a compiler that is **never in scope here** (standing rule: "I dont use C++ at all"). Across the estate that was 616 files and 90 MB of output nobody consumes, regenerated on every build; `gllSynEdit` alone accounted for 560. Now `None`. The `DCC_HppOutput` / `DCC_BpiOutput` / `DCC_ObjOutput` properties are left in place deliberately - they only say *where* such files would go, so with generation off they are inert, and removing them would enlarge the diff without changing behaviour. Verified: the affected packages rebuilt clean in every enabled mode, emitted no C++ artefacts, and rebuilt clean again after the existing ones were deleted (so nothing was load-bearing).

- The DPM package id is now `GITLAK.DUnitX`, not `VSoft.DUnitX`, so this fork cannot shadow upstream in a package feed. Description records the upstream baseline (0.5.1) and the Delphi 13 / Win64 scope; GITLAK Software added to `authors`, with Vincent Parrett's authorship and copyright retained as Apache-2.0 requires (2026-08-24) - `VSoft.DUnitX.dspec`

- Scoped this fork to Delphi 13 (Florence) or later, 64 bit Windows only (2026-08-24) - `README.md`, `CONTRIBUTING.md`, `VSoft.DUnitX.dspec`
  **Why:** the fork exists to serve GITLAK's Win64-only Delphi 13 suite, so carrying fifteen RAD Studio versions and five non-Windows platforms was pure maintenance cost.
- Retargeted every surviving project to Win64 alone - `ProjectVersion` 20.5, `TargetedPlatforms` 2, default platform Win64, and all OSX/Win32/Linux/mobile configuration groups removed (2026-08-24) - `packages/RAD Studio 13.0/VSoft.DUnitXWinR.dproj`, `Expert/DUnitX_IDE_Expert_D13Florence.dproj`, `Examples/DUnitXExamples_D13.dproj`, `Tests/DUnitXTest_D13.dproj`
- `DUnitX.AutoDetect.Console` now resolves only `DUnitX.Windows.Console` and raises a compile-time error on any other platform (2026-08-24) - `Source/DUnitX.AutoDetect.Console.pas`
  **Correction (2026-10-12):** the unit has no platform guard; it simply uses `DUnitX.Windows.Console`, which itself fails to compile elsewhere. `Help.md` was corrected the same day.
- Reworded the "no ConsoleWriter registered" message to name only `DUnitX.Windows.Console` (2026-08-24) - `Source/DUnitX.ResStrs.pas`
- Collapsed the now-dead `USE_NS` and `DELPHI_XE103_UP` conditionals in the two IDE expert wizard units, keeping only the namespaced units, `PlatformConst` and `GetAllPlatforms` (2026-08-24) - `Expert/DUnitX.Expert.ProjectWizardEx.pas`, `Expert/DUnitX.Expert.NewUnitWizardEx.pas`
  **Why:** both were always true on Delphi 13, and their dead branches still named `cOSX32Platform`, `cAndroidPlatform` and other platforms this fork no longer targets.
- Restricted the DPM spec to `delphi13.0` / `win64` and pointed its project and repository URLs at this fork (2026-08-24) - `VSoft.DUnitX.dspec`

### Removed

- **Unused resource strings** (2026-10-13) — `Source/DUnitX.ResStrs.pas`. `SFileUnexpectedErrorCreation` and `SRunning` had no users.
- **Dead code found in the 2026-10-13 review** (2026-10-13) — `Source/DUnitX.TestRunner.pas`, `Source/DUnitX.TestFixture.pas`, `Source/DUnitX.FixtureResult.pas`, `Source/DUnitX.ResStrs.pas`. `TDUnitXTestRunner.RTTIDiscoverFixtureClasses` with its `FFixtureClasses` and class `FRttiContext` (the fixture provider does the discovery), the empty `AddStatus`, `TDUnitXTestFixture.CreateTestFromMethod` / `CreateTestFromTestCase` (never called), `TDUnitXFixtureResult.FAllPassed` (never read), and the `STypeError` string.
- Dead weight surfaced by a full audit: `Build/TestAndBuild.fbp7` (a 1 MB FinalBuilder project referencing only deleted XE-era artefacts), the orphaned `Examples/DUnitX.Examples.UITest.*`, `Examples/DUnitX.Examples.AssertFailureCompare.pas`, `Examples/DUnitXExamples.rc/.rsb`, `Tests/DUnitX.Options.pas`, `Tests/DUnitXTest.mes`, `Source/DUNitX.Loggers.GUIX.vlb`, and the `*Ex`-superseded `Expert/DUnitX.Expert.NewUnitWizard.pas` and `Expert/DUnitX.Expert.ProjectWizard.pas` (2026-08-24)
- `Tests/DUnitX.Stacktrace.inc`, a divergent stale copy of the `Source` include missing the `USE_MADEXCEPT*` and `USE_EUREKALOG7` defines (2026-08-24)
  **Why:** only `Source/DUnitX.inc` includes it, so the Source copy always won - but the duplicate was a trap if include order ever changed.
- `docs/.gitattributes`, which forced `eol=lf` on a directory left empty (2026-08-24)

- The fourteen pre-D13 package folders under `packages/` (2026-08-24)
- All non-D13 test, example and IDE expert project files, and `Tests/TestProjects.groupproj` (2026-08-24)
- Non-Windows source units: `DUnitX.Linux.Console.pas`, `DUnitX.MacOS.Console.pas`, `DUnitX.Loggers.Console.FMX.pas`, `DUNitX.Loggers.MobileGUI.pas`, `DUNitX.Loggers.MobileGUI.fmx` (2026-08-24) - `Source`
- `Source/DUNitX.Loggers.GUIX.pas` and its `.fmx` form, the FireMonkey GUI runner (2026-08-24)
  **Why:** its only consumers were the deleted `DUnitXFiremonkeyGUI_*` projects, leaving it unreachable.
- The FMX pseudo-console feature and its documentation, upstream commit 731e335 (2026-08-24) - `docs/FMX-Pseudo-Console.md`, `README.md`
- The legacy `Build/Run-Dependend-Delphi-*.bat` launcher scripts (2026-08-24)

### Fixed

- **Weak tests made real, and a test for every fix of this review** (2026-10-13) — `Tests/DUnitX.Tests.Assert.pas`, `Tests/DUnitX.Tests.CommandLineParser.pas`, `Tests/DUnitX.Tests.Inheritance.pas`, `Tests/DUnitX.Tests.CategoryParser.pas`, `Tests/DUnitX.Tests.DUnitCompatibility.pas`, `Tests/DUnitX.Tests.TestFixture.pas`, `Tests/DUnitX.Tests.Loggers.XML.JUnit.pas`, `Tests/DUnitX.Tests.Loggers.XML.NUnit.pas`, `Tests/DUnitX.Tests.UtilsHelpers.pas`, `Tests/DUnitXTestProject.dpr`, `Tests/DUnitXTest_D13.dproj`. Tests that could not fail: `AreEqualMemory_Throws_ETestFailure_When_Pointers_Are_NotEqual` was only `Assert.Pass`; `AreEqual_GUID_Throws_No_Exception_When_Values_Are_Equal` called `AreNotEqual`; the `Fail` / `Pass` / `Ignore` `..._With_Message` tests and `WillNotRaise_With_ExactClass_Negative` never compared the message; `Will_Raise_On_Registering_Duplicate_Options` never reached its short-name case (now three cases, each from an empty registry); `TestInBase` passed through `Assert.Pass` without checking the override; the category-parser string asserts ignored case and had expected and actual reversed. The never-run `OnTestWarning_Adds_Warnings_To_Be_Written_Out_On_Next_Success` tests (JUnit, NUnit) are removed: with `[Test]` added they failed, because they test a warning callback that `ITestLogger` does not have. New tests for the second round of fixes, each proved by reverting its fix: `Nested_Relative_Options_File_Resolves_Against_Its_Parent_Folder`, `UnclosedParenthesisRaises`, `CheckIs_Nil_Object_Fails`, `WillRaise_Family_Wrong_Class_Failure_Includes_Caller_Message`, `RunResultsListTheRunFixtures`, `FixtureTestInfoListFollowsAddedTests`, `NameFilterListDropsEmptyAndDuplicateNames`, `TestErrorSeparatesMessagesAndAcceptsStrCompareDescendants`, and twelve `DUnitX.Tests.UtilsHelpers` tests for the `DUnitX.Utils` fixes; the seven `WillNotRaise*` tests that asserted the old swallowing now assert that the other exception propagates.
- **`Assert.WillNotRaise( proc, SomeClass )` passed when the method raised a different exception** (2026-10-13) — `Source/DUnitX.Assert.pas`, `Tests/DUnitX.Tests.Assert.pas`, `Help.md`. With a class given, `WillNotRaise`, `WillNotRaiseDescendant` and `WillNotRaiseWithMessage` caught any other exception (a descendant included, for `WillNotRaise`) and did nothing, so the test passed while the fault happened. That exception now propagates, so the test is reported as an error; the asserted class still fails the assertion. The seven tests that asserted the swallowing were updated. **Why:** a test passed that should not have. The estate's own guidance already steered to `WillNotRaiseAny`, and no suite in it passes a class.
- **A `WillRaise*` failure for the wrong exception class dropped the caller's message** (2026-10-13) — `Source/DUnitX.Assert.pas`, `Tests/DUnitX.Tests.Assert.pas`. `CheckExceptionClass` / `CheckExceptionClassDescendant` now take the message and append it.
- **`CheckIs( nil, ... )` was an access violation instead of a failure** (2026-10-13) — `Source/DUnitX.DUnitCompatibility.pas`, `Tests/DUnitX.Tests.DUnitCompatibility.pas`. A nil object now fails the check, as in DUnit.
- **A `--include` / `--exclude` expression with an unclosed `(` was silently accepted** (2026-10-13) — `Source/DUnitX.CategoryExpression.pas`, `Source/DUnitX.ResStrs.pas`, `Tests/DUnitX.Tests.CategoryParser.pas`. It now raises `ECommandLineError` (`SCategoryMissingParenthesis`). The unit's grammar comment, which listed `&` as an operator the parser does not have, was rewritten from the code.
- **A relative options-file name inside an options file was resolved against the current directory** (2026-10-13) — `Source/DUnitX.CommandLine.Parser.pas`, `Tests/DUnitX.Tests.CommandLineParser.pas`. It now resolves against the including file's folder.
- **A set-typed command-line option read past the end of a 4-byte Integer** (2026-10-13) — `Source/DUnitX.CommandLine.OptionDef.pas`. `Invoke` cast the `StringToSet` Integer to `T` (up to 32 bytes); the bits are now copied into a set-sized, zeroed buffer and passed to `TValue.Make`.
- **`IRunResults.Fixtures` was always nil** (2026-10-13) — `Source/DUnitX.RunResults.pas`, `Tests/DUnitX.Tests.TestFixture.pas`. The field it returned was never assigned; it now lists the fixture of each recorded fixture result.
- **`ITestFixtureInfo.Tests` missed tests added after it was first read** (2026-10-13) — `Source/DUnitX.TestFixture.pas`, `Tests/DUnitX.Tests.TestFixture.pas`. The cached list is rebuilt when the fixture's test count has changed (the provider adds error tests to `Tests` directly).
- **`TNameFilter` stored empty and duplicate names from a list** (2026-10-13) — `Source/DUnitX.Filters.pas`, `Tests/DUnitX.Tests.TestFixture.pas`. Only the single-name `Add` dropped them; the array and `TStrings` overloads now go through it (`--run:a,,b`).
- **`ITest.FullName` was an access violation once the test's fixture had gone** (2026-10-13) — `Source/DUnitX.Test.pas`. The fixture is held weakly and a result can outlive it; the name is now the test's own name in that case.
- **A test error's message ran the result message and the exception message together, and a descendant of `ETestFailureStrCompare` was not comparable** (2026-10-13) — `Source/DUnitX.TestResult.pas`, `Tests/DUnitX.Tests.TestFixture.pas`. They are separated by a line break, and `IsComparable` uses `is`.
- **A fixture with child fixtures reported only its children's time** (2026-10-13) — `Source/DUnitX.FixtureResult.pas`. `RollUpResults` summed the children's durations, leaving out the fixture's own tests; every fixture now takes its stopwatch, which spans both.
- **`TArrayHelper.Delete` could not remove the first element and read past the end of the array** (2026-10-13) — `Source/DUnitX.Utils.pas`, `Tests/DUnitX.Tests.UtilsHelpers.pas`. Index 0 is now accepted, the count is clamped before use, and the tail copy stays within the array. Red test `Delete_IndexZero_RemovesFirstElement`.
- **`SameValue` reported equal records, sets and other same-typed values as different** (2026-10-13) — `Source/DUnitX.Utils.pas`, `Tests/DUnitX.Tests.UtilsHelpers.pas`. It compared the addresses of each TValue's own data copy; it now compares the raw data byte for byte (managed fields compare by reference). Its only caller, `TValueHelper.Equals( TArray<TValue> )`, has no callers; `Assert.AreEqual` uses `System.Math.SameValue`. Red test `SameValue_EqualRecords_AreSame`.
- **`TObjectHelper.GetType` returned an undefined value for a nil instance** (2026-10-13) — `Source/DUnitX.Utils.pas`, `Tests/DUnitX.Tests.UtilsHelpers.pas`. `TryGetType` now sets its out parameter to nil first. Red test `GetType_NilInstance_ReturnsNil`.
- **`TValueHelper.ToString` raised an access violation on a nil object or interface** (2026-10-13) — `Source/DUnitX.Utils.pas`, `Tests/DUnitX.Tests.UtilsHelpers.pas`. Such values now format as `nil`. Red tests `ToString_NilObject_ReturnsNil`, `ToString_NilInterface_ReturnsNil`.
- **`TRttiMethodHelper.Format` read `Args[0]` out of range when `SkipSelf` was False and no arguments were passed** (2026-10-13) — `Source/DUnitX.Utils.pas`, `Tests/DUnitX.Tests.UtilsHelpers.pas`. An empty argument list now gives empty parentheses.
- **`TRttiTypeHelper.IsCovariantTo` tested the same generic argument twice for being an interface** (2026-10-13) — `Source/DUnitX.Utils.pas`, `Tests/DUnitX.Tests.UtilsHelpers.pas`. The second test now checks the target's argument; no behaviour change, because `InheritsFrom` already implied it.
- **Two slips in the examples** (2026-10-13) — `Examples/DUnitX.Examples.General.pas`. `TExampleFixture2.TearDownFixture` passed expected and actual to `AreEqual` the wrong way round, and `TestOne` logged "TestOnce".
- **Corrupted characters in upstream comments** (2026-10-13) — `Source/DUnitX.TestNameParser.pas`, `Source/DUnitX.Attributes.pas`. The NUnit copyright line had U+FFFD where a copyright sign was (now `(C)`), and twelve summaries in `DUnitX.Attributes.pas` had it where non-breaking spaces were (now plain spaces).
- **An override of an attributed virtual method never ran; the ancestor's code ran instead** (2026-10-13) — `Source/DUnitX.FixtureProvider.pas`, `Tests/DUnitX.Tests.TestFixture.pas`. `GenerateTests` bound the ancestor's attributed `[Setup]`, `[TearDown]`, `[SetupFixture]`, `[TearDownFixture]` or `[Test]` by its static code address, so an override that did not repeat the attribute never executed (its assertions silently never ran), and a test overridden in a `published` section was two tests, one running the base code. The new `ResolveFixtureMethods` takes each virtual method once, at its most derived declaration, with the attributes of the nearest declaration that has any, and binds it through the fixture class's virtual method table. Red test `OverridesOfAttributedMethodsRunOnce` (two results, base code ran). **Why:** a test passed that should have failed. `Help.md` §3 documented the old behaviour; it now documents the fix.
- **`CheckSame( TObject )` passed for two different objects** (2026-10-13) — `Source/DUnitX.DUnitCompatibility.pas`, `Tests/DUnitX.Tests.DUnitCompatibility.pas`. It called `Assert.AreEqual<TObject>`, which since the #398 item 1.3 fix compares with `Equals`; DUnit's `CheckSame` is an identity check. It now calls `Assert.AreSame`. Red test `CheckSame_Object_Compares_Identity`.
- **`[MaxTime]` did not catch a test that overran and then called `Assert.Pass`** (2026-10-13) — `Source/DUnitX.Test.pas`, `Tests/DUnitX.Tests.TestFixture.pas`. The `ETestPass` skipped the timeout check; `TDUnitXTest.Execute` now checks the timeout before re-raising it, and sets `ITest.TimedOut`, which nothing had ever set. Red test `MaxTimeOverrunEndingInAssertPassFails`.
- **`[SetupFixture]` ran when none of the fixture's tests would execute, and on a GUI re-run could run on a freed instance** (2026-10-13) — `Source/DUnitX.TestFixture.pas`, `Source/DUnitX.TestRunner.pas`, `Tests/DUnitX.Tests.TestFixture.pas`. `GetHasActiveTests` ignored `Enabled`, while the instance is created only when `HasTests` (which counts enabled tests) is true; so a fixture whose selected tests were all ignored still ran its fixture setup, and a parent fixture whose own tests were all deselected ran its setup without its instance being created. It now counts tests that are enabled and not ignored, and `ExecuteFixtures` reads it once per fixture, so a stopped GUI run (which disables the remaining tests) still runs the `[TearDownFixture]` that pairs with a setup that ran. Red test `SetupFixtureSkippedWhenNoTestWillExecute`.
- **`--run` matched any fixture whose name started with the given text** (2026-10-13) — `Source/DUnitX.Filters.pas`, `Tests/DUnitX.Tests.TestFixture.pas`. `TNameFilter.Match` used a bare `StartsText`, so `--run:Unit.TCustomer` also ran `Unit.TCustomerOrder`. A name now matches only at a `.` boundary (a namespace, fixture, test, or a method's test cases). Red test `NameFilterMatchesWholeNameSegments`; `FullNameFilterMatchesOnlyTheExactTest`'s precondition asserted the old prefix match and now asserts the opposite.
- **Results carried another test's log, and lost what Setup logged** (2026-10-13) — `Source/DUnitX.TestRunner.pas`, `Tests/DUnitX.Tests.TestFixture.pas`. The log was cleared when the test body started and after a pass, but not after a failure, so a Setup, `[SetupFixture]` or `[TearDownFixture]` error carried the previous failing test's log, and Setup's own output was discarded. The new `ClearLogMessages` runs before each test's Setup, before each fixture, and before `[TearDownFixture]`. Red test `ResultsCarryOnlyTheirOwnLog`.
- **Memory a logger kept in its per-test callbacks was reported as the test's leak** (2026-10-13) — `Source/DUnitX.TestRunner.pas`, `Tests/DUnitX.Tests.TestFixture.pas`. The whole-span leak measurement (2026-10-12) put `OnEndSetupTest`, `OnExecuteTest` and `OnTeardownTest` inside the span. They are now runner allocation, counted only when they grow (memory a logger frees is the test's own memory going), and runner-allocation brackets nest, so a logger that logs is measured once. Red test `LoggerStateIsNotATestLeak`.
- **Fixtures ran in heap-address order** (2026-10-13) — `Source/DUnitX.Extensibility.pas`, `Source/DUnitX.TestRunner.pas`, `Tests/DUnitX.Tests.TestFixture.pas`. `BuildFixtures` called `ITestFixtureList.Sort`, which is the generic list's default comparer (interface pointers); the name sort was a private method nothing reached. `SortByName` sorts by full name at every level. Test `FixtureListSortsByNameAtEveryLevel`, proved by mutation (`C B A` with the default sort).
- **A `[TestCase]` value such as `'1,000'` silently became 1.0** (2026-10-13) — `Source/DUnitX.Utils.pas`, `Tests/DUnitX.Tests.Utils.pas`. The decimal comma (`'2,5'`, tested in a German locale) is kept, but a single comma before exactly three digits after a whole number not starting with 0 is a thousands group in one locale and a decimal in another, so it is now a conversion error. No suite in the estate uses a comma decimal in `[TestCase]` data (searched D: and E:). Completes #398 item 1.6.
- **An ordinal or float value converted to a smaller ordinal type was truncated** (2026-10-13) — `Source/DUnitX.Utils.pas`, `Tests/DUnitX.Tests.Utils.pas`. `ConvOrd2Ord` and `ConvFloat2Ord` had no range check, and when a converter refused, `TValue.TryConvert` fell back to the RTL's `TryCast`, which truncates (a `[TestCaseProvider]` Integer 300 for a `Byte` parameter became 44). The new `OrdinalFitsType` checks the range, `ConvFloat2Ord` refuses a value outside Int64 instead of raising from `Trunc`, and the `TryCast` fallback is skipped between numeric types. Red test `TryConvert_Ordinal_Fails_When_Out_Of_Range`.
- **XML CDATA escaping changed the text and could end the section early** (2026-10-13) — `Source/DUnitX.Utils.XML.pas`, `Tests/DUnitX.Tests.Utils.XML.pas`. `]]>` became `]>`, and `]]]>` became `]]>`, closing the CDATA section in the NUnit and JUnit output. It is now split across two adjacent sections, which a parser reads back as the original. Red test `EscapeForXML_CDATA_Round_Trips`.
- **`Assert.IsType<T>` could never fail** (2026-10-13) — `Source/DUnitX.Assert.pas`, `Source/DUnitX.ResStrs.pas`, `Tests/DUnitX.Tests.Assert.pas`. A value of type T is always of type T, so a test relying on it passed whatever it checked. The deprecated method now fails with `SIsTypeCannotCheck`, naming `InheritsFrom` / `Implements`; nothing in the estate calls it (the estate builds with no W1000). Test `IsType_Fails_Because_It_Cannot_Check`, proved by mutation.
- **`@<file>` on the command line always failed** (2026-10-13) — `Source/DUnitX.CommandLine.Parser.pas`, `Tests/DUnitX.Tests.CommandLineParser.pas`. The parser stripped the `@` and then looked the file name up as an option name. It now reads the file through the registered options-file option, taking the name whole so a drive colon does not split it. Test `At_Prefix_Reads_An_Options_File`.
- **A test name given without `--run:` overwrote a file of that name and ran every test** (2026-10-13) — `Source/DUnitX.OptionsDefinition.pas`, `Source/DUnitX.ResStrs.pas`, `Tests/DUnitX.Tests.CommandLineParser.pas`. The bare argument names the XML output file; it must now end in `.xml` (`CheckXmlOutputFileArgument`), and anything else is a parse error. Test `Bare_Argument_Must_Name_An_XML_File`.
- **JUnit `<testsuite>` counts were rolled up from child fixtures while `tests` was not** (2026-10-13) — `Source/DUnitX.Loggers.XML.JUnit.pas`. `disabled`, `errors` and `failures` are now counted from the suite's own results, as `tests` is.
- **A console line longer than the window lost its line break** (2026-10-13) — `Source/DUnitX.Windows.Console.pas`. `InternalWriteLn` dropped the CRLF whenever the line was at least the console width, so the next line ran on; only a line that exactly fills its last row moves the cursor itself.
- **`TWeakReference<T>.Destroy` could lock a target freed by another thread** (2026-10-13) — `Source/DUnitX.WeakReference.pas`. It read `FData` and then entered the target's own monitor. All weak-reference bookkeeping now uses one lock (`TWeakReferencedObject.FWeakReferenceLock`), under which a non-nil target is alive. It is a critical section that is never deleted: a first version freed a lock object in the class destructor, and a VCL GUI runner then failed with a runtime error at exit, because `Vcl.Forms` finalizes later and frees the form, whose weak references used the freed lock (found running the GUI runner, both platforms; the console test project cannot show it); `Destroy` no longer takes an interface reference (which could revive a target whose count had reached zero), and `Data` does not return a target that has started destroying.
- **`TTestFixtureHelper.Log` read the runner registry without its lock** (2026-10-13) — `Source/DUnitX.TestFramework.pas`. It now calls `TDUnitXTestRunner.GetActiveRunner`.
- **The RTTI discovery's `TPersistent` filter never took effect** (2026-10-13) — `Source/DUnitX.FixtureProvider.pas`. It asked whether the `TRttiType` object descended from `TPersistent`. Removed rather than corrected: a working filter would silently drop `[TestFixture]` classes that descend from `TComponent`.
- **`ITestFixtureInfo.ActiveTestCount` returned the total count** (2026-10-13) — `Source/DUnitX.TestFixture.pas`. It now counts tests that are enabled and not ignored.
- **A test with several results showed the last one, so a pass after an error turned a failed test green** (2026-10-13) — `Source/DUnitX.Loggers.GUI.VCL.pas`. `SetNodeTestResult` now keeps the most severe result. **Why:** repeated and same-named tests report more than once.
- **Recreating a tree's window left the runner pointing at freed tree nodes** (2026-10-13) — `Source/DUnitX.Loggers.GUI.VCL.pas`. The trees no longer restore their nodes when the window is recreated (`CreateWndRestores := False` via `TTreeViewHelper.DiscardNodesOnRecreate`). `OnDeletion` drops every reference to a deleted node and keeps the test ticks, and a timer rebuilds the test tree once no run is in progress. **Why:** the restored nodes were new objects without the runner's own fields.
- **The Text tab counted tests with no assertions as failures** (2026-10-13) — `Source/DUnitX.Loggers.GUI.VCL.RichEdit.pas`. They are now counted and listed as warnings, matching the structured summary.
- **Runner GUI usability fixes** (2026-10-13) — `Source/DUnitX.Loggers.GUI.VCL.pas`, `Source/DUnitX.Loggers.GUI.VCL.dfm`. Only a single left click toggles a checkbox. Actions are correct from start-up, and a failed test load is shown instead of leaving Run enabled. The progress bar uses the runner's own count, Run is disabled when nothing is ticked, and a stopped run says so. Results that cannot be displayed have their own root, so they no longer inflate the Errored count, and a half-built result node is removed. Select All / Unselect All reach fixtures with duplicate names, a failed temp-file write deletes its file, and a busy clipboard is reported in the status bar. Tree hints show, and the saved list of unticked tests drops tests that no longer exist.
- **The project wizard could take over an existing project** (2026-10-13) — `Expert/DUnitX.Expert.ProjectWizardEx.pas`. When the IDE did not hand back the new project, the wizard fell back to the active project, replaced its unit search path with `$(DUnitX)` and added the test unit to it. It now warns and stops.
- **Wizard failures were silent** (2026-10-13) — `Expert/DUnitX.Expert.ProjectWizardEx.pas`, `Expert/DUnitX.Expert.NewUnitWizardEx.pas`. When the test unit could not be created, nothing was reported; both wizards now say so.
- **Fixture names that broke the generated unit were accepted** (2026-10-13) — `Expert/DUnitX.Expert.CodeGen.Templates.pas`. `TDUnitX` (E2003), `TestAttribute`/`TestCaseAttribute`/`SetupAttribute`/`TearDownAttribute` (E2010) and `Integer` (the sample `Test2` errors at run time) are now rejected. **Why:** the generated unit uses these names unqualified, and a fixture class of the same name hides them.
- **A fixture named like its unit did not compile (E2004)** (2026-10-13) — `Expert/DUnitX.Expert.CodeGen.NewTestUnit.pas`. Such a class now gets a `T` prefix. **Why:** the forms validate before the IDE names the unit, so the clash can only be caught during generation.
- **The fallback unit name could differ from the file name (E1038)** (2026-10-13) — `Expert/DUnitX.Expert.CodeGen.NewTestUnit.pas`. It is now derived from the unit's file name.
- **Generated test projects had no `{$R *.res}`** (2026-10-13) — `Expert/DUnitX.Expert.CodeGen.Templates.pas`. Version information and icon were never linked. Added, matching Embarcadero's console template.
- **Win32 builds of the expert never bumped their build number** (2026-10-13) — `Expert/DUnitX_IDE_Expert_D13Florence.dproj`. The Win32 Debug and Release groups now carry `VerInfo_AutoIncVersion`, `VerInfo_Build` and `VerInfo_Keys`, as the Win64 groups do.
- **The leak check reported memory freed between test phases as leaked, and the FastMM5 monitor read pending frees
  as allocated** (2026-10-12) — `Source/DUnitX.TestRunner.pas`, `Source/DUnitX.MemoryLeakMonitor.FastMM5.pas`,
  `Tests/DUnitX.Tests.TestFixture.pas`. Found by triaging GITLAKLib's suite with the per-test FastMM5 monitor: a test
  whose 1 MB connection buffer was freed after `PostTest` but before `PreTearDown` was reported as a 1,053,179-byte
  leak (test +1,053,765, gap -1,053,313, teardown -6,156), because the runner summed the three phases and never measured
  the gaps between them. The runner now resolves a second monitor instance that measures the whole span, from the
  start of setup (or the test) to the end of teardown (or the test), and that span is the leak figure; the per-phase
  figures only choose the message wording. Runner memory created in the span is discounted as before: the pass result
  and its log text, and the clearing of a previous test's log lists. A monitor registered as a singleton falls back to
  the old sum. No interface changed, so the Default, FastMM4 and third-party monitors work unchanged. The FastMM5
  monitor now calls `FastMM_ProcessAllPendingFrees` before every reading. **A third false positive found while
  verifying:** `Log` / `Status` stored the caller's string by reference, so a message the test built was counted as the
  test's leak (510 bytes per `Status` call in the check below); `Log` now keeps its own copy, made inside the runner
  measurement. Red test `LeakCheckIgnoresMemoryFreedBetweenPhases` (setup and test allocations freed in the gaps,
  1500 bytes reported before the fix; a real 32-byte leak must still be reported as exactly 32). The FastMM5 parts are
  not testable in the self-test exe (default monitor); verified with a scratch FastMM5 console runner, Win32 and Win64:
  a 1 MB buffer freed between test and teardown, `Status` logging and `Assert.Pass` pass, a 1000-byte `GetMem` is
  still reported. Suite 355 found, 346 passed, 9 ignored, 0 failed (Win64); 353/344/9/0 (Win32). Fork divergence, not
  in issue #398.
- **The New DUnitX Project wizard created Win64-only projects** (2026-10-12) —
  `Expert/DUnitX.Expert.CodeGen.NewProject.pas`. Found by driving the rebuilt expert in the IDE: `GetPlatforms` declared
  Win32 and Win64, but the IDE still enabled only its default platform. `TNewProjectEx.SetInitialOptions` now marks both
  Windows platforms supported and enabled through `IOTAProjectPlatforms`. Re-verified in the IDE: a new project lists
  Windows 32-bit and Windows 64-bit. The same IDE run confirmed the rest of today's expert changes: no load errors, no
  C++Builder entries, FastMM 5 selected by default, `begin` and `1Test` refused as class names, and a generated `.dpr`
  with no TestInsight that sets `EXIT_ERRORS` on failure or crash.
- **Other DUnitX sets on this machine could be compiled or linked instead of this fork** (2026-10-12) — `Help.md` §2,
  `D:\Tools\Check-DUnitXSingleSet.ps1` (GITLAKTools). Rule (Ian, 2026-10-12): `D:\gllDUnitX` is the only DUnitX on
  C:, D: and E:. RAD Studio's bundled DUnitX (67 files in `Studio\37.0\lib`, written by its install/update, without
  `Assert.Ignore` or any fork fix) was moved to `_bundled_DUnitX_removed_2026-10-12` by an elevated script; deleted: an
  upstream clone left by a TMS tool test run (`gllTMSSmartSetup\tmstest\tmp-run`, git-ignored), a GetIt temp
  extraction, a vendored FMX unit in `OmniThreadLibrary-NG`, an orphan `VSoft.DUnitXWinR170.bpl`, the earlier
  moved-aside stray DCUs, and every leftover fork DCU in temp, third-party and archive build folders. The new check
  exits 1 on any DUnitX source, bundled `lib` file or foreign DUnitX package outside this repo (proved with a decoy);
  run it after every RAD Studio update. The sweep that kept writing stray DCUs into `Source` built projects with only
  an exe-output override; `D:\Tools\Check-DcuCollisions.ps1` now also fails a project with no `DCC_DcuOutput`.
- **`CheckEqualsBin` passed values that differed above the requested digits** (2026-10-12) —
  `Source/DUnitX.DUnitCompatibility.pas`, `Tests/DUnitX.Tests.DUnitCompatibility.pas`. It compared the digit-truncated
  binary strings, so `CheckEqualsBin($1A5, $A5, '', 8)` passed. As in DUnit it now compares the values and uses
  `digits` only for the display, widening it to 32 when the difference lies above the requested digits so the failure
  does not show two equal strings. Red test `CheckEqualsBin_Compares_Values_Not_Digits` (red seen). Issue #398.
  Divergence from upstream (offered back in VSoftTechnologies/DUnitX#398).
- **The `WillNotRaise` family turned `Assert.Pass` / `Assert.Ignore` inside the method into a failure, and swallowed
  `Assert.Fail`** (2026-10-12) — `Source/DUnitX.Assert.pas`, `Tests/DUnitX.Tests.Assert.pas`. `WillNotRaiseAny` and
  `WillNotRaise` / `WillNotRaiseDescendant` / `WillNotRaiseWithMessage` with a nil class reported "Method raised
  [ETestPass]"; with a named class they silently swallowed an inner `ETestFailure`, so the test passed. They now
  re-raise DUnitX's own outcome exceptions through `IsUnrequestedTestOutcome`, as the `WillRaise` family already does
  (unless that exception class was the one named). Red test `WillNotRaise_Family_Passes_Test_Outcomes_Through` (red
  seen). Issue #398. Divergence from upstream (offered back in VSoftTechnologies/DUnitX#398).
- **`TValueHelper.ToVarRec` / `ToVarRecs` returned dangling or misread pointers** (2026-10-12) —
  `Source/DUnitX.Utils.pas`, `Tests/DUnitX.Tests.Utils.pas`. `vtExtended` pointed at a `Single` / `Double`'s own bytes
  (read as a 10-byte `Extended` on Win32, and as 8 bytes over a 4-byte `Single` on Win64), strings and objects pointed
  at a temporary string freed on return, and `tkInt64` (like any other unhandled kind) left the result uninitialised.
  A `TVarRec` cannot own memory, so the API changed: `ToVarRec(var AStorage : TValue)` and
  `ToVarRecs(const Values; out AStorage : TArray<TValue>)` point every pointer into caller-held storage (floats are
  widened to `Extended` there, strings and `ToObject.ToString` stored as `string`); `tkInt64` and `tkWChar` are
  handled, and an unsupported kind raises `EInvalidCast`. **Breaking** for any external caller of the parameterless
  forms (none in DUnitX or the indexed estate; they were unsafe to call). Red test `ToVarRec_Reads_Back_The_Value`
  (red seen on the `Int64` VType). Issue #398. Divergence from upstream (offered back in VSoftTechnologies/DUnitX#398).
- **`TDUnitXList<T>.ToArray` returned nil and its non-generic `IEnumerable` enumerator was nil** (2026-10-12) —
  `Source/DUnitX.Generics.pas`, `Tests/DUnitX.Tests.Utils.pas`. `ToArray` now returns the items;
  `GetNonGenEnumerator` returns a real enumerator whose `Current` yields the item when `T` is a class (nil otherwise,
  since the non-generic `IEnumerator` can only yield objects). Red tests `ToArray_Returns_The_Items` and
  `NonGeneric_Enumerator_Yields_Objects` (new `TDUnitXList` fixture; both red seen). Issue #398. Divergence from
  upstream (offered back in VSoftTechnologies/DUnitX#398).
- **Consumers resolved DUnitX through `Source` on the Win64 library path, or would have got RAD Studio's bundled
  copy without it** (2026-10-12) — IDE library path (`HKCU\...\BDS\37.0\Library\Win64` / `Win32` `Search Path`,
  `%APPDATA%\Embarcadero\BDS\37.0\EnvOptions.proj`), `Help.md` §2 and §7. Win64 listed `$(DUNITX)` (`Source`) ahead
  of the package's Release DCU folder, so every consumer compiled DUnitX from source (the route by which stray DCUs
  kept reaching `Source`). Removing it alone exposed the bundled DUnitX DCUs in `$(BDSLIB)\$(Platform)\release`, which
  sit earlier in the path and lack `Assert.Ignore` (`E2003` in GITLAKLib's tests). Now, on both platforms, the
  package's Release DCU folder is the first Search Path entry and `Source` is on neither (Win32 already omitted it by
  design, 2026-10-02). The 3,486 fork DCUs that the old arrangement had compiled into 79 consumer output folders, which
  the compiler searches before the library path, were deleted. Verified with GITLAKLibTests (clean build compiles no
  DUnitX unit, links the fork per `grep -a TestIgnored`, 2697 found / 2692 passed / 5 ignored / 0 failed). Registry
  keys and `EnvOptions.proj` were backed up first.
- **The self-test runner forced `Pause` and exited 0 when the run crashed** (2026-10-12) — `Tests/DUnitXTestProject.dpr`.
  Outside a `CI` build it assigned `ExitBehavior := Pause` after every run, overriding `--exit:continue`, so an
  unattended run waited for Enter; and its `except` handler printed the exception without setting `ExitCode`, so a run
  that died before or inside `Execute` reported success. It now pauses only when asked and sets `EXIT_ERRORS` in the
  handler, matching the wizard template; the dead `TESTINSIGHT` branches are gone. The suite is now a `test_run` target
  (`gllDUnitXTests` in `D:\GITLAKMCP\settings.ini`): 349 found, 340 passed, 9 ignored, 0 failed on Win64; 347 / 338 / 9
  / 0 on Win32 (the two `Int64` overload tests are 64-bit only).
- **Project-file leftovers** (2026-10-12) — `Examples/DUnitXExamples_D13.dproj`, `Tests/DUnitXTest_D13.dproj`,
  `Expert/DUnitX_IDE_Expert_D13Florence.dproj`. Removed stale `DeployFile` entries (a D11 Alexandria exe under
  `Studio\22.0`, and iOS-simulator / OSX dylibs that the platform-strip hook does not catch), the expert's
  `UnitTesting` pointer at `C:\dev\DUnitX\...\DUnitX_IDE_Expert_XE5Tests.dproj`, and set the legacy
  `<VersionInfo Name="AutoIncBuild">` to `True` in all three to match `VerInfo_AutoIncVersion`.
- **Documentation said things the code does not do** (2026-10-12) — `Help.md`, `Users Guide.md`, `README.md`.
  `DUnitX.Init` was called mandatory (`DUnitX.TestFramework`'s own initialisation does the same work on Delphi 13, so it
  is optional); `NoDiff` was said to follow the ignore-case default (its short form is case-sensitive);
  `DUnitX.Loggers.XML.xUnit` was described as an xUnit logger (the unit is empty); `TDUnitXNullLogger` was called the base
  of every logger (the console logger is not); `AutoDetect.Console` was said to carry a platform guard; README pointed at
  TestInsight. All corrected, and both documents now describe today's behaviour changes. `README.md` also had five
  LF-only lines; it is CRLF throughout.
- **Thirty-nine stale Win64 `.dcu` files in `Source\`** (2026-10-12), all stamped 2026-10-08 10:10, during an
  estate-wide exe build sweep. `Source` is on the Win64 library path as `$(DUNITX)`, ahead of the package's Release DCU
  folder, so they could shadow the library. Moved to
  `%PUBLIC%\Documents\Embarcadero\Studio\37.0\_stale_gllDUnitX_Source_DCUs_2026-10-12`; every project rebuilt clean
  without them. This is the third recurrence (see Known Issues).
- **VCL GUI runner: smaller display defects** (2026-10-12) — `Source/DUnitX.Loggers.GUI.VCL.pas`, `Source/DUnitX.Loggers.GUI.VCL.dfm`, `Source/DUnitX.Loggers.GUI.VCL.RichEdit.pas`, `Source/DUnitX.ResStrs.pas`. The summary's Failed count included the no-assertion results the GUI files as warnings; they now have their own Warnings count, and the memory-leak root shows its count (`STestsLeaked`, which has a `%d`). Space with no selected test node raised an access violation. A selected fixture node was drawn black on the highlight colour. Compare / Copy Expected / Copy Actual ignored a selected log line (level 3). A failed fixture setup left the text log indented for the rest of the run (the indent is now restored per fixture). Each result reset the results tree's scroll position and re-expanded roots the user had collapsed. Fixture setup now starts once from `FormShow` instead of `Loaded`, the window is sized to its own monitor, a test whose full name duplicates another's is reported in the status bar instead of being listed with an icon that never updates, `--run` / `--include` / `--exclude` now decide which tests are listed (the GUI used to overwrite `TDUnitX.Filter`), and the hard-coded English messages moved to `DUnitX.ResStrs`. DFM: removed the design-time sample nodes, the `rchLog` placeholder text, seven orphan `ActionBars` entries and `tvwResults.StateImages`; the duplicate Alt+F accelerator is now Alt+T (Find Result in Text). Dead members `cTestNodeStatePartialChecked`, `TResultNode.Messages` / `LogMessages` and `FLastResult` removed. Issue #398 items 4.8, 4.9, 4.12 and audit findings. GUI-only, so verified by a build (Win32 and Win64, zero hints and warnings) and a smoke run of a scratch GUI project, not by unit tests. Divergence from upstream (offered back in VSoftTechnologies/DUnitX#398).
- **VCL GUI runner: right-click popups and Beyond Compare** (2026-10-12) — `Source/DUnitX.Loggers.GUI.VCL.pas`, `Source/DUnitX.Loggers.GUI.VCL.dfm`. The popups were shown by posting `Mouse.CursorPos` through `WPARAM` / `LPARAM`, which on Win64 turns a negative X (a monitor left of the primary) into a huge unsigned value; the trees now own their `PopupMenu`, which also makes Shift+F10 and the Apps key work. Beyond Compare was only searched for in the process's own Program Files (a 32-bit install was never found from a Win64 runner); it is now found from its registry `ExePath` or in both Program Files folders. Compare no longer blocks the UI until Beyond Compare exits, reports a failed `CreateProcess`, no longer leaks the first temp file when the second cannot be written, and checks `RenameFile`. Issue #398 items 4.10, 4.11. Verified by build only (not exercised in the smoke run). Divergence from upstream (offered back in VSoftTechnologies/DUnitX#398).
- **VCL GUI runner: closing during a run, and its settings file** (2026-10-12) — `Source/DUnitX.Loggers.GUI.VCL.pas`, `Source/DUnitX.Loggers.GUI.VCL.dfm`, `Source/DUnitX.ResStrs.pas`. Closing the window mid-run did not stop the run, and there was no way to stop one. Esc now stops a run after the current test (the GUI disables the tests and fixtures that have not started, which the runner already skips, so no further fixture setup runs; fixtures already started still tear down), and closing mid-run does the same and then closes, with no dialog. `FormClose` wrote the INI beside the exe with no error handling, so a read-only folder made the window impossible to close; settings now go to `%LOCALAPPDATA%\DUnitX\<exe name>.ini` (read once from the old file beside the exe if no new one exists), file errors are absorbed, one `TMemIniFile` in UTF-8 reads and writes them, and test names are stored as values (`[UncheckedTests]`, `N=<full name>`) so a name containing `=` round-trips. Ticks also survive a re-filter, which used to re-read stale INI values. Issue #398 item 4.5. Smoke run: an unchecked test read from the new file was not run, and the window closed and rewrote the file. Divergence from upstream (offered back in VSoftTechnologies/DUnitX#398).
- **VCL GUI runner: Run ran tests that were not checked, and the GUI could be broken mid-run** (2026-10-12) — `Source/DUnitX.Filters.pas`, `Source/DUnitX.Loggers.GUI.VCL.pas`, `Source/DUnitX.Loggers.GUI.VCL.RichEdit.pas`, `Tests/DUnitX.Tests.TestFixture.pas`. Run and Run Selected passed the checked names as a `TNameFilter`, which also runs every test of any fixture whose full name starts with a checked name; they now use the new `TFullNameFilter`, which matches exact, case-sensitive full names only, since test case names can differ only in case (red test `FullNameFilterMatchesOnlyTheExactTest`, red seen for both the prefix and the case assertion). `RunExecute` reset `FRunning` and the actions after its `try` / `finally`, so any exception left Run disabled and the status at "Running" until restart; that now happens in the `finally`, and `ProcessTestResult` reports a result it cannot display as an Error node instead of raising (it used to raise for a result whose test had no node, such as a fixture teardown failure). The rich-edit logger used `TDictionary.Add` for bookmarks, so a test beginning twice aborted the run (now `AddOrSetValue`), and appended at the caret, so clicking in the log mid-run scrambled the output and bookmarks (it now appends at the end). The filter box stayed live during a run, and Enter in it rebuilt the test tree under the running suite; it is disabled while running, as are check-box toggling by mouse and Space. Results now refer to tests by full name instead of a `TTreeNode` that a re-filter freed, and their icons are re-applied to the rebuilt tree; Clear resets the test icons to "not run" so skipped tests no longer show last run's result. Issue #398 items 4.1, 4.2, 4.3, 4.4, 4.6, 4.7. The filter is unit-tested; the GUI changes are verified by build and a smoke run. Divergence from upstream (offered back in VSoftTechnologies/DUnitX#398).
- **Projects generated by the New Test Project wizard exited with code 0 when the run aborted** (2026-10-12) — `Expert/DUnitX.Expert.CodeGen.Templates.pas`. The generated `.dpr`'s `except` handler only wrote the message, so `ENoTestsRegistered` (missing `{$STRONGLINKTYPES ON}`), a raising fixture constructor or a failing logger looked like success to CI. The handler now also sets `System.ExitCode := EXIT_ERRORS`. Divergence from upstream (offered back in VSoftTechnologies/DUnitX#398). Issue #398 item 1.10. Not unit-testable (generated source); verified by four-mode package build.
- **The New Test Project wizard never used `TNewProjectEx`** (2026-10-12) — `Expert/DUnitX.Expert.CodeGen.NewTestProject.pas`, `Expert/DUnitX.Expert.CodeGen.NewProject.pas`. `TTestProjectFile` tested the misspelt `DELPHI_SEATTLE_UP` (`DUnitX.inc` defines `DELPHIX_SEATTLE_UP`), so it always derived from `TNewProject` and `IOTAProjectCreator160` was never implemented. It now derives from `TNewProjectEx` unconditionally, whose `GetPlatforms` returns exactly Win32 and Win64 (it would otherwise have started advertising macOS, Android and iOS), whose personality is Delphi only, and whose `SetInitialOptions` no longer writes the C++Builder options `UsingDelphiRTL`/`ILINK_LinkwithDUnitXRuntime`. Divergence from upstream (offered back in #398). Issue #398 item 5.1. Verified by build only (IDE expert).
- **The New Test Project wizard added the project to the group the user had chosen to close** (2026-10-12) — `Expert/DUnitX.Expert.ProjectWizardEx.pas`. The `Boolean` result of `IOTAModuleServices.CloseAll` was discarded, so pressing Cancel on its save prompt still went on to create the project in the existing group. The wizard now stops when `CloseAll` returns `False`. Divergence from upstream (offered back in #398). Issue #398 item 5.2. Verified by build only.
- **The New Test Project wizard could raise an access violation into the IDE** (2026-10-12) — `Expert/DUnitX.Expert.ProjectWizardEx.pas`, `Expert/DUnitX.Expert.NewUnitWizardEx.pas`. `GetActiveProject` was dereferenced (`Project.ProjectOptions as IOTAProjectOptionsConfigurations`) before its nil check. The project is now taken from `CreateModule` via `Supports(..., IOTAProject, ...)` (falling back to `GetActiveProject`), the options via `Supports`; when either is missing the user is told what was not set up instead. Both wizard procs are wrapped so no exception reaches the IDE (`Application.ShowException`). Divergence from upstream (offered back in #398). Issue #398 item 5.3. Verified by build only.
- **Both wizards accepted a fixture class name that generates a unit which does not compile** (2026-10-12) — `Expert/DUnitX.Expert.Forms.NewProjectWizard.pas`, `Expert/DUnitX.Expert.Forms.NewProjectWizard.dfm`, `Expert/DUnitX.Expert.Forms.NewUnitWizard.pas`, `Expert/DUnitX.Expert.Forms.NewUnitWizard.dfm`, `Expert/DUnitX.Expert.CodeGen.Templates.pas`. Names such as `My Test`, `1Test`, `begin` or `T-X` were only trimmed. A new `OnCloseQuery` keeps the dialog open with a message unless the name passes `IsValidFixtureClassName` (`IsValidIdent` plus a Delphi reserved-word check); the project wizard checks only when "Create Test Unit" is ticked. Divergence from upstream (offered back in #398). Issue #398 item 5.4. Verified by build only.
- **The New Test Unit wizard silently created an orphan unit when no project was open** (2026-10-12) — `Expert/DUnitX.Expert.NewUnitWizardEx.pas`. It now says there is no active project and stops before showing its dialog. Divergence from upstream.
- **The generated test unit ignored the `ModuleIdent` the IDE supplied** (2026-10-12) — `Expert/DUnitX.Expert.CodeGen.NewTestUnit.pas`. `NewImplSource` always asked `GetNewModuleAndClassName` for a fresh name; it now uses `ModuleIdent` when non-empty and keeps that call as the fallback for when it is blank. Divergence from upstream.
- **Wizard dialog layout nits** (2026-10-12) — `Expert/DUnitX.Expert.Forms.NewProjectWizard.dfm`, `Expert/DUnitX.Expert.Forms.NewProjectWizard.pas`, `Expert/DUnitX.Expert.Forms.NewUnitWizard.dfm`. "Report Leak Options" now stretches with the form (`akRight`); `Constraints.MinHeight` (370 / 202, was 145) stops OK/Cancel overlapping the option group when the dialog is shrunk; unticking "Create Test Unit" now also greys the class-name label. Divergence from upstream.
- **Misnamed identifiers in the expert** (2026-10-12) — `Expert/DUnitX.Expert.Forms.NewProjectWizard.pas`, `Expert/DUnitX.Expert.Forms.NewUnitWizard.pas`, `Expert/DUnitX.Expert.CodeGen.NewTestUnit.pas`, `Expert/DUnitX.Expert.NewUnitWizardEx.pas`, `Expert/DUnitX.Expert.ProjectWizardEx.pas`. `TestFixtureClasaName` → `TestFixtureClassName`, `FTestFixureClassName`/`ATestFixureClassName` → `...Fixture...`, and the unit wizard's hint resource `sNewTestProjectHint` → `sNewTestUnitHint`. Divergence from upstream.

- **A run in which no test executed reported all passed, and an unregistered `[TestCaseProvider]` silently produced no
  tests** (2026-10-12) — `Source/DUnitX.RunResults.pas`, `Source/DUnitX.TestRunner.pas`,
  `Source/DUnitX.FixtureProvider.pas`, `Source/DUnitX.Test.pas`, `Source/DUnitX.ResStrs.pas`,
  `Tests/DUnitX.Tests.TestFixture.pas`. `AllPassed` is now False when no non-ignored test ran (a `--run` / `--include`
  typo, or every test ignored), and `Execute` logs the warning "No tests were executed, so the run is not reported as
  passed." A provider that is not registered now gives one error test for the method (new `TDUnitXErrorTest`), naming
  the provider. **Estate-visible:** a run whose filter matches nothing, or whose tests are all ignored, now exits with
  `EXIT_ERRORS` (GITLAKLib's runner already treated 0 tests as exit 250). Red tests
  `RunWithNoExecutedTestsIsNotAllPassed`, `UnregisteredTestCaseProviderIsAnError`. Divergence from upstream, offered
  back in VSoftTechnologies/DUnitX#398 items 1.11 and 2.9.
- **False memory-leak reports** (2026-10-12) — `Source/DUnitX.TestRunner.pas`, `Tests/DUnitX.Tests.TestFixture.pas`.
  (a) `Assert.Pass` was measured while its `ETestPass` object was still alive: `ExecuteTest` now handles `ETestPass`
  itself, so `PostTest` measures after the object is released (its message is copied, and the copy discounted);
  (b) `Log` / `WriteLn` / `Status` in a test grew the runner's message lists inside the measured window: a second
  monitor instance now measures what each `Log` call keeps (lists and loggers), and the leak check subtracts it (with
  a singleton monitor registration nothing is subtracted, as before); (c) the check was `<> 0`, so a test that freed
  earlier memory was reported as "-64 bytes leaked": only net growth is now a leak, and the message reports the net
  figure. Red test `LeakCheckCountsOnlyTheTestsOwnGrowth` (a simulated-allocation monitor; all three cases seen red,
  a real leak still reported). Divergence from upstream, offered back in #398 item 2.5.
- **TearDown ran after a failed Setup, and its error replaced the test's own failure** (2026-10-12) —
  `Source/DUnitX.TestRunner.pas`, `Source/DUnitX.ResStrs.pas`, `Tests/DUnitX.Tests.TestFixture.pas`. TearDown is now
  skipped when Setup fails (as in DUnit and NUnit), so the Setup error is reported. When a test fails and its TearDown
  then fails, the result keeps the test's failure (type, location, expected / actual) and appends "TearDown also
  failed: ..." to its message; a TearDown failure after a pass is still the result. Red tests
  `TearDownIsSkippedAfterSetupFails`, `TearDownErrorDoesNotHideTestFailure`. Divergence from upstream, offered back in
  #398 item 2.6.
- **Fixture setup and teardown failures: duplicated tests, a double free, a run aborted by one constructor, and stale
  bindings on a re-run** (2026-10-12) — `Source/DUnitX.TestRunner.pas`, `Source/DUnitX.TestFixture.pas`,
  `Source/DUnitX.FixtureProvider.pas`, `Source/DUnitX.ResStrs.pas`, `Tests/DUnitX.Tests.TestFixture.pas`. A failing
  `[TearDownFixture]` re-reported every already-recorded test as an error; it is now recorded once, as an error result
  named after the teardown method (`TearDownFixture`, or `Destroy` for a destructor). A raising destructor teardown
  was freed again by the fixture's `Destroy`; `ExecuteFixtureTearDown` now uses `FreeAndNil`. A fixture constructor
  that raised while the fixtures were built aborted the whole run before `TestingStarts`; the fixture is now built
  without an instance, the runner constructs it again and reports the constructor's error against that fixture's
  tests, and the rest of the run continues. After a `[SetupFixture]` failure an `[Ignore]`d test is reported as
  ignored, not as an error. A re-run after the instance was freed (the GUI runner) left Setup / TearDown /
  SetupFixture / TearDownFixture bound to the freed instance; `InitFixtureInstance` now rebinds them. A parameterless
  constructor still takes the place of `[SetupFixture]` (upstream's documented behaviour, asserted by
  `TExampleFixture3`), but the runner now logs a warning naming the method that is not run, and a constructor marked
  `[SetupFixture]` is never called as a method. Red tests `TearDownFixtureFailureIsReportedOnce`,
  `RaisingDestructorIsNotFreedTwice`, `RaisingConstructorErrorsOnlyItsFixture`,
  `AfterSetupFixtureFailsNothingRunsAndIgnoredStayIgnored`, `RerunBindsSetupToTheNewInstance`,
  `SuppressedSetupFixtureIsReported`. Constructing fixtures lazily (only those that will run) is not done. Divergence
  from upstream, offered back in #398 items 2.1, 2.2 and 2.3.
- **`[RepeatTest]` repetitions ran without a base class's Setup / TearDown, on the wrong instance, and after a failed
  `[SetupFixture]`** (2026-10-12) — `Source/DUnitX.FixtureProvider.pas`, `Tests/DUnitX.Tests.TestFixture.pas`.
  Repetitions were put in a child fixture whose Setup / TearDown were copied when the method was reached, before a
  base class's `[Setup]` had been seen; test cases ran on the child's own instance while Setup ran on the parent's;
  and the child ran even when the parent's `[SetupFixture]` failed. The repetitions are now tests of the fixture
  itself. **Estate-visible:** a repeated test's full name loses the extra method segment, e.g.
  `Unit.TFixture.Method.Method-1-of-3` is now `Unit.TFixture.Method-1-of-3`. Red tests
  `RepeatedTestsRunWithTheirSetupOnTheirInstance`, `AfterSetupFixtureFailsNothingRunsAndIgnoredStayIgnored`.
  Divergence from upstream, offered back in #398 item 1.12.
- **`[WillRaise]` and `[MaxTime]` were dropped from `[TestCase]` / `[TestCaseProvider]` methods, a `[WillRaise]` test
  leaked the whole run, and `[MaxTime]` missed overruns between watchdog polls** (2026-10-12) — `Source/DUnitX.Test.pas`,
  `Source/DUnitX.TestFixture.pas`, `Source/DUnitX.Extensibility.pas`, `Source/DUnitX.FixtureProvider.pas`,
  `Source/DUnitX.Timeout.pas`, `Tests/DUnitX.Tests.TestFixture.pas`. `ITestFixture.AddTestCase` takes the max time,
  expected exception and inheritance (defaulted, so callers compile unchanged), and each case enforces them; a
  published method without `[Test]` keeps its `[WillRaise]` too. `TDUnitXExceptionTest` kept the execute context (the
  run results, which hold the fixture, which holds the test): that cycle leaked the results, the fixtures and their
  instances. It now keeps nothing, and the expected-exception check runs inside the timed body (new virtual
  `TDUnitXTest.ExecuteMethod`), so `[MaxTime]` also applies to a test that raises as expected. Fork only: the
  `[MaxTime]` watchdog thread polled every 20 ms from its own start, so an overrun ending between polls passed; the
  body is now timed on its own thread with a `TStopwatch` started immediately before the method, and an overrun is
  elapsed time *greater than* `MaxTime`. A `[WillRaise(Exception, exDescendant)]` test whose body fails an assertion
  is reported as a failure (already true since the `WillRaise` change below; now covered). Red tests
  `TestCasesKeepWillRaiseAndMaxTime`, `ExceptionTestDoesNotKeepTheRunResultsAlive`,
  `MaxTimeOverrunIsCaughtWhateverTheTiming`; `FailingAssertInWillRaiseTestIsAFailure` passed before the fix.
  Divergence from upstream, offered back in #398 items 1.5 and 2.4.
- **A second runner on a thread raised `EListError` and unregistered the first; `SuccessRate` was 0 or 100; a nil
  activator gave an access violation** (2026-10-12) — `Source/DUnitX.TestRunner.pas`, `Source/DUnitX.TestFramework.pas`,
  `Source/DUnitX.RunResults.pas`, `Source/DUnitX.ServiceLocator.pas`, `Source/DUnitX.ResStrs.pas`,
  `Tests/DUnitX.Tests.TestFixture.pas`, `Tests/DUnitX.Tests.IoC.pas`. A runner created while another is active on the
  same thread now stands in for it and restores it when destroyed (only its own entry is ever removed), and the
  registry is read under its lock. `SuccessRate` truncated before multiplying. Resolving a registration made with a
  nil delegate raises `EServiceLocatorResolutionException`, and `DefaultContainer` is created race-free. Ignored tests
  are logged at Information, not Error. Red tests `SecondRunnerOnAThreadStandsInAndRestoresTheFirst`,
  `SuccessRateIsAPercentage`, `Test_Nil_Activator_Raises_Resolution_Exception`. Divergence from upstream, offered
  back in #398.
- **Bad `[TestCase]` data silently became 0 / defaults, and a wrong value count was ignored** (2026-10-12) —
  `Source/DUnitX.Utils.pas`, `Source/DUnitX.Test.pas`, `Source/DUnitX.ResStrs.pas`, `Tests/DUnitX.Tests.Utils.pas`,
  `Tests/DUnitX.Tests.TestFixture.pas`, `Tests/DUnitX.Tests.TestNameParser.pas`, `Tests/DUnitX.Tests.Assert.pas`.
  The string converters returned True with a default when parsing failed (`'abc'` -> Integer 0, `'300'` -> Byte 44,
  `'Bogus'` -> enum ordinal -1, `'notadate'` -> 30/12/1899). They now return False, range-check before `FromOrdinal`,
  reject an unknown enum or set element (an unknown set element used to raise and abort the run), and copy only as many
  bytes as the set occupies. `ConvStr2Float` parsed with an uninitialised `TFormatSettings`; it now uses
  `TFormatSettings.Invariant`. Dates and times now try ISO 8601, then the invariant culture, then the machine locale,
  so a value that parses under ISO / invariant has the same meaning on every machine. `TDUnitXTestCase` records a value
  count that differs from the parameter count, or a value that does not convert, and `Execute` raises
  `EArgumentException` naming the case, parameter, value and type, so that case alone reports an Error; a single
  parameter given `''` still receives an empty string. **Estate-visible:** (1) a test case that relied on a missing
  trailing value becoming empty / 0 / False (RTTI cannot honour a parameter's default value) now errors and must supply
  the value: 14 cases in `Tests/DUnitX.Tests.Assert.pas` did; (2) extra values hidden by the default `,` separator now
  error: the `SingleName` cases in `Tests/DUnitX.Tests.TestNameParser.pas` had been silently truncated at their commas
  and now use `'|'`; (3) a numeric date such as `'01/02/2020'` is now read month-first (invariant) on every machine,
  where a UK machine read it as 1 February. Red tests `TryConvert_Fails_For_Values_That_Do_Not_Parse`,
  `TryConvert_Date_Meaning_Does_Not_Depend_On_Locale`, `WhenATestCaseValueIsInvalidTheCaseErrors`. Divergence from
  upstream, offered back in VSoftTechnologies/DUnitX#398 item 1.6.
- **DUnit compatibility checks did not behave like DUnit** (2026-10-12) — `Source/DUnitX.DUnitCompatibility.pas`,
  `Tests/DUnitX.Tests.DUnitCompatibility.pas`. `CheckEqualsString`, `CheckEquals(UnicodeString | WideString)`,
  `CheckEqualsWideString`, `CheckNotEquals(string | WideString)`, `CheckNotEqualsString` and
  `CheckNotEqualsWideString` ignored case (DUnit's are case-sensitive); they now pass `ignoreCase = False` explicitly,
  so `Assert.IgnoreCaseDefault` no longer reaches them. `CheckInherits` passed its arguments reversed. `CheckException`
  matched the exact class (DUnit accepts a descendant) and, with a nil class, swallowed any exception (DUnit lets it
  through); it now calls `WillRaiseDescendant`, or the method itself when no class is named. `CheckSame(IUnknown)`
  compared the interface pointers passed, so two interfaces of one object differed; it now compares the
  `as IInterface` identities. The pre-XE2 branch of `CheckNotEqualsBin` was inverted (dead code on D13).
  **Estate-visible:** converted DUnit suites now check string case. Red test `Checks_Have_DUnit_Semantics`.
  Divergence from upstream, offered back in #398 items 1.7 and 1.8.
- **`--include` / `--exclude` ignored an operator in the last position** (2026-10-12) —
  `Source/DUnitX.CategoryExpression.pas`, `Tests/DUnitX.Tests.CategoryParser.pas`. `IndexOfAny` and `SkipWhiteSpace`
  stopped one character short, so `(Slow|Integration)` tokenised as `Integration)` and Integration tests were not
  excluded. Red test `OperatorInLastPositionIsRecognised`. Divergence from upstream, offered back in #398 item 1.9.
- **`--run` dropped a one-character last name and kept a trailing comma** (2026-10-12) —
  `Source/DUnitX.TestNameParser.pas`, `Tests/DUnitX.Tests.TestNameParser.pas`. `'Ab,C'` gave only `Ab`, `'A'` gave
  nothing, and `'Name,'` gave `Name,`; the loops now examine the last character. Red tests `SingleName.SingleName10`,
  `TwoNames.TwoNames2`, `TwoNames.TwoNames5`. Divergence from upstream, offered back in #398.
- **XML reports: form feed passed as legal, attributes unescaped, inconsistent counts and a locale-dependent
  timestamp** (2026-10-12) — `Source/DUnitX.Utils.XML.pas`, `Source/DUnitX.Loggers.XML.NUnit.pas`,
  `Source/DUnitX.Loggers.XML.JUnit.pas`, `Source/DUnitX.FixtureResult.pas`, `Tests/DUnitX.Tests.Utils.XML.pas`,
  `Tests/DUnitX.Tests.Loggers.XML.NUnit.pas`, `Tests/DUnitX.Tests.Loggers.XML.JUnit.pas`. `IsValidXMLChar` rejects
  `#$0C`; the exe path and category names are escaped; `HasFailures` now counts errors and leaks, so a fixture whose
  tests all errored is no longer written `result="Success"`; the NUnit header counts leaks as failures, and JUnit's
  header and `<testsuite>` count them as errors, matching how each leaked test is written; the NUnit assembly `time`
  is the run's duration in seconds; the JUnit timestamp quotes `:` (ISO 8601 whatever the time separator); a JUnit
  `<failure>` body carries the stack trace (the message stays in the attribute); the suite name strips the trailing
  `.Name` rather than its first occurrence; `IFixtureResult.Namespace` returned the name; `RollUpResults` ignored leak
  counts. Red tests `IsValidXMLChar_Rejects_Characters_XML_Forbids`,
  `OnTestingEnds_Reports_Errors_And_Leaks_Consistently`, `OnTestingEnds_Reports_Leaks_Timestamp_And_Stack_Trace`.
  Divergence from upstream, offered back in #398 items 2.7, 3.9 and 3.10.
- **The text logger's issue list lost issues** (2026-10-12) — `Source/DUnitX.Loggers.Text.pas`,
  `Tests/DUnitX.Tests.Loggers.XML.NUnit.pas`. It stored `Values[FullName] := Message`, so an empty message deleted the
  entry and a `=` in a test name split it; it is now a list of name / message pairs. Red test
  `Issue_List_Keeps_Names_With_Equals_And_Empty_Messages`. Divergence from upstream, offered back in #398.
- **Command-line options: `--dontshowignored:false` turned it on, float options used the locale, and an options file
  could include itself for ever** (2026-10-12) — `Source/DUnitX.OptionsDefinition.pas`,
  `Source/DUnitX.CommandLine.OptionDef.pas`, `Source/DUnitX.CommandLine.Parser.pas`, `Source/DUnitX.ResStrs.pas`,
  `Tests/DUnitX.Tests.CommandLineParser.pas`. `--dontshowignored` now honours its value; float options parse with
  `TFormatSettings.Invariant`; an options file already being parsed is reported ("Parameter File [x] includes
  itself") instead of recursing to a stack overflow; options-file lines are trimmed, and blank, `#` and `;` lines are
  skipped. Red tests `Options_File_Lines_Are_Trimmed_And_Comments_Skipped`, `Float_Option_Uses_Invariant_Format`;
  `Options_File_Including_Itself_Reports_An_Error` was not run red (on the old code it overflows the stack).
  `--dontshowignored` is verified by build only (its registration is private to its unit). Divergence from upstream,
  offered back in #398 item 3.11.
- **Two assertion messages were literals** (2026-10-12) — `Source/DUnitX.Assert.pas`, `Source/DUnitX.ResStrs.pas`.
  The "contains" and negative-tolerance messages added for #398 items 3.4 and 3.7 are now the resourcestrings
  `SStrContains` and `SNegativeTolerance`.
- **`Assert.IsEmpty(Variant)` was inverted, and `IsNotEmpty(Variant)` passed for Null** (2026-10-12) —
  `Source/DUnitX.Assert.pas`, `Tests/DUnitX.Tests.Assert.pas`. `IsEmpty('abc')` passed and `IsEmpty(Unassigned)`
  failed; now `IsEmpty` fails unless the value is Unassigned or Null, and `IsNotEmpty` fails on both. Red tests
  `IsEmpty_Variant_Fails_Only_When_Value_Is_Assigned`, `IsNotEmpty_Variant_Fails_When_Value_Is_Null`. Divergence from
  upstream, offered back in VSoftTechnologies/DUnitX#398 item 1.1.
- **`WillNotRaiseDescendant(TTestMethod)` passed when a descendant was raised** (2026-10-12) —
  `Source/DUnitX.Assert.pas`, `Tests/DUnitX.Tests.Assert.pas`. It forwarded to the exact-match `WillNotRaise`; it now
  forwards to the `TProc` `WillNotRaiseDescendant`. Red test `WillNotRaiseDescendant_Method_Fails_When_Descendant_Raised`.
  Divergence from upstream, offered back in #398 item 1.2.
- **`AreEqual<Double>(NaN, 1.0)` and `Contains<Double>([1.0], NaN)` passed** (2026-10-12) — `Source/DUnitX.Assert.pas`,
  `Tests/DUnitX.Tests.Assert.pas`. `AreEqual<T>`, `AreEqual<T>(TArray)`, `AreNotEqual<T>`, `Contains<T>` and
  `DoesNotContain<T>` compared with `TComparer<T>.Default`, whose `Double` / `Extended` compare returns 0 for NaN; they
  now use `TEqualityComparer<T>.Default.Equals`. Side effect: for a class type `T` the equality comparer calls the
  object's `Equals`, so an overridden `Equals` is now honoured (it was pointer comparison). Red tests
  `AreEqual_T_Double_Fails_When_One_Value_Is_NaN`, `Contains_T_Double_Does_Not_Match_NaN`. Divergence from upstream,
  offered back in #398 item 1.3.
- **`WillRaise`, `WillRaiseAny`, `WillRaiseDescendant`, `WillRaiseWithMessage` and `WillRaiseWithMessageRegex`
  swallowed a failed assertion (and `Assert.Pass` / `Assert.Ignore`) inside the method as "the expected exception"**
  (2026-10-12) — `Source/DUnitX.Assert.pas`, `Tests/DUnitX.Tests.Assert.pas`. `WillRaiseAny(procedure begin
  Assert.AreEqual(1, 2) end)` passed. They now re-raise an exception that is (or descends from) `Assert.TestFailure`,
  `TestPass` or `TestIgnored`, unless the caller's `exceptionClass` is itself a DUnitX framework exception
  (`ETestFrameworkException` descendant), so `WillRaise(..., ETestFailure)` still works. Deliberately keyed to the
  three outcome classes rather than all of `ETestFrameworkException`, keeping the unit framework-neutral and leaving a
  plain DUnitX `EAbort` catchable. Four existing tests (`WillNotRaiseWithMessage_*_WillRaise`) relied on a class-less
  `WillRaise` catching the inner failure; they now name `ETestFailure`. **Estate-visible:** any suite that wraps a
  failing assertion in a class-less `WillRaise` now fails and must name `ETestFailure`. Red tests
  `WillRaise_Family_Does_Not_Swallow_A_Failed_Assertion`, `WillRaise_Family_Does_Not_Swallow_Pass_Or_Ignore`.
  Divergence from upstream, offered back in #398 item 1.4.
- **Assertion robustness and messages** (2026-10-12) — `Source/DUnitX.Assert.pas`, `Tests/DUnitX.Tests.Assert.pas`.
  Divergence from upstream, offered back in #398 items 3.1-3.7:
  - 3.1: `WillNotRaiseAny` put the user message into the format string (`'100%'` lost its `%`, `'%s'` raised
    `EConvertError`); it is now an argument. `WillNotRaise(nil)` and `WillNotRaiseDescendant(nil)` now include the
    user message too. Red test `WillNotRaise_User_Message_Is_Not_A_Format_String`.
  - 3.2: a nil `exceptionClass` in `WillNotRaiseDescendant` / `WillNotRaiseWithMessage` gave an access violation; nil
    now means "any exception", as in `WillNotRaise`, and the message names the raised class. Red test
    `WillNotRaise_Nil_Class_Fails_Readably`.
  - 3.3: `AreSame` / `AreNotSame(TObject)` used `Equals` (overridable, AV on nil); now identity `=` with nil-safe text.
    Red test `AreSame_Object_Compares_Identity`.
  - 3.4: `AreEqual` / `AreNotEqual(Double|Extended, tolerance)` failed `Inf = Inf` (Inf - Inf is NaN) and passed
    `Inf = -Inf` (`SameValue` derives an infinite epsilon); `expected = actual` is now checked first and infinities
    equal only themselves. A negative tolerance now fails with "tolerance [x] cannot be negative" (as `StartsWith`
    fails on an empty substring). NaN is still unequal. Red tests `AreEqual_Double_Infinity_And_Negative_Tolerance`,
    `AreEqual_Extended_Infinity_And_Negative_Tolerance`.
  - 3.5: `AreEqual(Currency)` said "equals"; `DoesNotContain(string)` said "does not contain" when it did;
    `AreEqual(Cardinal)` printed `High(Cardinal)` as -1; `WillNotRaiseDescendant` named the expected class, not the
    one raised. Red test `Failure_Messages_Describe_The_Failure`.
  - 3.6: `AreEqual(TStrings)` failed for the same instance and raised `EListError` on a duplicate `ignoreLines` entry.
    Red test `AreEqual_TStrings_Same_Instance_And_Duplicate_IgnoreLines`.
  - 3.7: `Contains` / `DoesNotContain(string)` with an empty substring now fail with "subString cannot be empty", as
    `StartsWith` / `EndsWith` do (`DoesNotContain('abc', '')` used to pass). Red test
    `Contains_And_DoesNotContain_Reject_Empty_SubString`.
  - Also: `WillRaiseWithMessage`, `WillRaiseWithMessageRegex` and `CheckExpectation` now pass `ReturnAddress`, and a
    leftover `if True then` is gone from `InheritsFrom`.
- **`AreEqual(TStream)` / `AreNotEqual(TStream)` moved both streams' positions, failed for the same instance, and
  looped for ever on a stream whose `Read` returns 0 short of its `Size`** (2026-10-12) — `Source/DUnitX.Assert.pas`,
  `Tests/DUnitX.Tests.Assert.pas`. `StreamsEqual` now compares only the bytes actually read, treats a stalled read as
  unequal, short-circuits the same instance and restores both positions. Tests
  `AreEqual_Stream_Restores_Positions_And_Accepts_Same_Instance` (red seen) and
  `AreEqual_Stream_Fails_When_Read_Returns_Nothing` (red not run: on the old code it hangs). Divergence from upstream.
- **The test and example projects wrote their Win64 output to shared machine folders; Win32 stayed
  project-local** (2026-10-12) — `Tests/DUnitXTest_D13.dproj`, `Examples/DUnitXExamples_D13.dproj`. Each
  `Base_Win64` group overrode `DCC_ExeOutput` / `DCC_DcuOutput` (plus inert `DCC_BplOutput` / `DCC_DcpOutput`) with
  `$(BDSCOMMONDIR)\bin|dcu|dcp\$(Platform)\$(Config)`, so the Win64 exe landed in
  `Public\Documents\Embarcadero\Studio\37.0\bin\Win64\<Config>` and DCUs of `Source\` and Delphi.Mocks in the shared
  `dcu\Win64\<Config>` — the shape that shadows a library machine-wide if that folder is ever on a library path (it is
  not today). The overrides are removed, so both platforms inherit Base's `.\$(Platform)\$(Config)`. The 96 stale files
  left in the shared folders were moved to `Studio\37.0\_stale_gllDUnitX_2026-10-12` first and, once the rebuilds below had
  passed without them, deleted with the folder the same day (101 files including the orphans below); clean rebuilds
  (Tests Win64 Debug/Release, Win32 Debug; Examples Win64 Debug) write nothing there and the suite stays 297 / 288 / 0.
  The same folder also received five orphans of a package name this fork no longer builds — `VSoft.DUnitXR.bpl` /
  `.dcp` (root Win32 copies of 2026-04-19, `Win64` copies of 2026-05-23) and a `.rsm`: no project on `D:` or `E:`
  builds or `requires` it and the IDE did not load it, but a stale root `.dcp` can shadow the platform one on Win32.
  The runtime package and the test project rebuild clean without them.
  `Help.md` §7 now states the exe locations and version-resource arrangement, and its output-standard snippet is
  corrected to the per-config form adopted 2026-10-07 (it still showed the superseded `Condition=` lines).
- **The examples project reported W1000 `Symbol 'IsType' is deprecated`** (2026-10-12) —
  `Examples/DUnitX.Examples.General.pas`. Hidden until now because the shared DCU folder above held an up-to-date DCU,
  so the unit never recompiled. `TestTwo` now uses `Assert.InheritsFrom`, the replacement the deprecation names, and
  frees its list in a `try..finally`.
- **The self-test project reported W1000 `Symbol 'CheckEqualsString' is deprecated`** (2026-10-10) —
  `Tests/DUnitX.Tests.DUnitCompatibility.pas`. The test exercises the DUnit compatibility layer on purpose, and the
  file already wraps its other deprecated calls (`CheckTrue`, `CheckNotNull`) in `{$WARN SYMBOL_DEPRECATED OFF}` /
  `ON`; `Test_TestName`'s `CheckEqualsString` was the one call left outside. Wrapped the same way, scoped to that
  one line (upstream has the same gap).
- **A full rebuild of `VSoft.DUnitXWinR` reported W1002 `GetMemoryManagerState is specific to a platform`**
  (2026-10-07) — `Source/DUnitX.MemoryLeakMonitor.FastMM4.pas`. Found by the estate package sweep, which builds with
  `DCC_BuildAllUnits`. `System.GetMemoryManagerState` is marked `platform`; it is the RTL memory manager's own API and
  there is no non-platform equivalent, and this fork targets Windows only, so the warning carries no information here.
  `SYMBOL_PLATFORM` is switched off for that one routine (the non-`USE_FASTMM4_LEAK_MONITOR` branch of
  `GetMemoryAllocated`) and restored with `DEFAULT`, so the project setting applies everywhere else (Ian, 2026-10-07).
- **An in-IDE build re-saved the package `.dproj` without its Release output paths** (2026-10-07) —
  `Expert/DUnitX_IDE_Expert_D13Florence.dproj`, `packages/RAD Studio 13.0/VSoft.DUnitXWinR.dproj`. The output standard
  was two `Condition`-ed `DCC_BplOutput` / `DCC_DcpOutput` lines in the Base group, and the IDE keeps one value per
  property per group when it re-saves the project on a build, so it wrote back only the active config's: a committed
  re-save sent Release builds to the root `Bpl` / `Dcp` folders. Now one plain value per group, the form the IDE
  writes itself: Base `$(BDSCOMMONDIR)\Bpl\$(Platform)\$(Config)` (and `Dcp`), overridden in the Release config group
  by `$(BDSCOMMONDIR)\Bpl\$(Platform)`. Same output; built in all four modes with the `dcc` `-LE`/`-LN` paths checked
  per mode.
- **The NUnit and JUnit XML loggers raised `EInOutError: Unable to create directory []` when given a bare
  file name** (2026-09-29) - `Source/DUnitX.Loggers.XML.NUnit.pas`, `Source/DUnitX.Loggers.XML.JUnit.pas`.
  Both call `ForceDirectories( ExtractFilePath( FileName ) )`, and `ExtractFilePath` of a bare name is
  `''`, for which `ForceDirectories` raises. The exception fires in the logger's constructor, so the
  runner dies before a single test runs. Found in `E:\DBiStoreTests`, whose runner passed
  `'DBiStoreTests-results.xml'`. The directory is now created only when there is one; a bare name means
  the current folder. **Upstream has the same code** (checked against `upstream/master`), so this is a
  deliberate divergence worth offering back.

- `TargetedPlatforms` brought into line with the `<Platforms>` block in 6 `.dproj` (2026-09-10)
  The earlier platform sweep removed the non-Windows `<Platform>` entries but left the
  `<TargetedPlatforms>` bitmask untouched, so projects still advertised targets they no
  longer declared — values such as `1048579` and `135171` encode Android/Linux/iOS, and
  several Win32+Win64 projects still read `2` (Win64 only) or `1` (Win32 only).
  Now `3` for Win32+Win64, `2` where only Win64 is declared.
  **Why:** the mask is what the IDE reads for the Project Manager's platform list, so a
  stale one puts dead platforms back in front of the reader.

IDE expert now compiles on Win32 as well as Win64 (2026-09-10) — `DUnitX.Expert.ProjectWizardEx.pas`, `DUnitX.Expert.NewUnitWizardEx.pas`, `DUnitX_IDE_Expert_D13Florence.dproj`
  The glyph callback was hard-typed `TFunc<UInt64>`, which matches the 64 bit `HICON` on
  Win64 but not the 32 bit one on Win32, so the Win32 build failed `E2250`; it is now
  `NativeUInt`, a plain alias for both. The project also declared `Win32` in `<Platforms>`
  while carrying only `Base_Win64` property groups, so `Windows` would not resolve
  (`F2613`) — a matching `Base_Win32` group was added.
  **Why:** the gll* estate is Win32 + Win64 on Delphi 13; a package that builds on only one
  of the two cannot complete the four-mode sweep.

- The GUI logger would not compile: `System.Actions` was listed twice in its `uses` clause (2026-09-07) — `Source\DUnitX.Loggers.GUI.VCL.pas`
  **Why:** the unit appears inside the `{$IFDEF}`'d block AND again on the trailing line, so a build that takes that branch dies with `E2004 Identifier redeclared: 'System.Actions'` and every consumer that links the GUI logger fails with it — `F2063 Could not compile used unit`. Found because it blocked the `gllSpell` integration suite outright.
  **This is a known, self-inflicted hazard and the file says so:** the comment beside the `{$IFDEF}`'d entry reads *"IDE keeps adding this at the end even if it's in the ifdef'd section. make sure it's not there when committing!"*. The IDE had re-added it and the addition was committed. The fix is exactly what that comment prescribes — remove the trailing `System.Actions`; `System.ImageList` beside it is listed only once and stays.
  **How to apply:** check that trailing line before committing this unit, whatever else the change was.

- Cleared 44 stale Win64 `.dcu` files that were sitting beside their sources in `Source\` (2026-09-05) — `Source\`
  **Why:** `Source\` is on the Win64 library search path as `$(DUNITX)` **and** is the unit search path every consumer uses (`..\Source` within this repository, `..\..\gllDUnitX\Source` from `gllAutoGetIt`). Compiled output in that folder is live ammunition for `F2048 Bad unit format`. Reproduced against a copy of the folder: a Win32 consumer compiled with no DCU output directory dies on `Expected version: 37.0, Windows Unicode(x86) Found version: 37.0, Windows Unicode(x64)`; the same consumer given a `-NU` output directory compiles clean, because the compiler then prefers its own output folder and rebuilds from source.
  **Scope, stated precisely:** this was latent, not live. All four projects here already set a platform-split `DCC_DcuOutput`, so none of them produced those files and none of them consumed them — a consumer-style build with no DCU output did, and every correctly configured project is immune. The files were untracked and `.gitignore`d, so no tracked content changes; the exposure was to whoever next built a non-Win64 target with `Source` on the path.
  **How to apply:** never let compiled output accumulate beside `.pas` files in a folder that is on a library or unit search path. `D:\Tools\Check-DcuCollisions.ps1` does **not** catch this shape — it flags folders shared between the Win32 and Win64 library paths, and `Source` is on the Win64 path only, so it reported this repository clean.
  **Verified afterwards:** the runtime package (Debug and Release), the IDE expert and the test project all rebuild clean; the suite runs 287 tests, 278 passed / 9 ignored / 0 failed / 0 leaked; a cold rebuild of the `gllAutoGetIt` consumer passes 33/33; and `Source\` stayed free of `.dcu` throughout.
  **Note:** Win32 is not merely unbuilt for `VSoft.DUnitXWinR.dproj` — `TargetedPlatforms` is `2` and the project carries no Win32 property groups at all, so the four-mode package rule reduces to two modes here.

- The `Delphi-Mocks` dependency in `CONTRIBUTING.md` pointed at upstream `VSoftTechnologies/Delphi-Mocks` (2026-09-05) — `CONTRIBUTING.md`
  **Why:** the test suite has consumed our own `glldelphi-mocks` fork from a sibling source checkout since 2026-08-24, pinned by commit in `DEPENDENCIES.md`. `CONTRIBUTING.md` still sent a contributor to upstream, which is the wrong repository and carries no pinned commit.

- Leak accounting read the wrong memory manager when the FastMM4 leak monitor was enabled (2026-08-26) - `Source\DUnitX.MemoryLeakMonitor.FastMM4.pas`, `Source\DUnitX.MemoryLeaks.inc`
  **Why:** `System.GetMemoryManagerState` walks the RTL's bundled FastMM, not a `FastMM4.pas` installed as the first unit - which is exactly the setup the leak monitor requires - so the small-block loop reported 0 or nonsense (upstream measured an RTL delta of 0 against a FastMM4 delta of 4140 for a 4096-byte allocation). Under `USE_FASTMM4_LEAK_MONITOR` the monitor now calls `FastMM4.GetMemoryManagerUsageSummary`, which reads FastMM4's own block lists; the RTL path is kept for the undefined case so the unit still compiles without FastMM4 on the search path. The define stays off by default. Cherry-picked from upstream `a69a10b` (Olaf Monien, #395); this fork's own `Int64` cast fix in the RTL branch is preserved inside the new `{$ELSE}`.
  **Note:** GITLAK code uses FastMM5 (`gllFastMM5`), so this affects only the opt-in FastMM4 monitor, not the default leak accounting.

- Corrected the Debug/Release package output split (2026-08-24)
  **Why:** the first attempt diverted both configurations to a `$(Config)` subfolder, which broke package loading - `$(BDSCOMMONDIR)\Bpl\$(Platform)` is on the machine `PATH` and is where a design package resolves the runtime packages it requires. Release now stays in the shared `Bpl`/`Dcp` folders and only Debug is diverted, which still stops a Debug build replacing the installed Release package.

- Debug and Release package artefacts no longer overwrite each other (2026-08-24) - `Expert/DUnitX_IDE_Expert_D13Florence.dproj`, `packages/RAD Studio 13.0/VSoft.DUnitXWinR.dproj`
  **Why:** RAD Studio defaults `DCC_BplOutput` to `$(BDSCOMMONDIR)\Bpl\$(Platform)` and `DCC_DcpOutput` to `\Dcp\$(Platform)`, neither carrying `$(Config)`, so a Debug build silently replaced the installed Release package while `.dcu` output was already separated. **Debug only** now goes to a `$(Config)` subfolder; Release stays in the shared `Bpl`/`Dcp` folders, which are on `PATH` and are how dependent packages resolve their `requires`. See the follow-up entry above - an initial attempt that moved Release as well broke package loading.
- `.rc`, `.res` and `.dres` are no longer ignored, and the six project resource files are now committed (2026-08-24) - `.gitignore`, `Expert/DUnitX_IDE_Expert_D13Florence.res`, `Expert/DUnitX_IDE_Expert_D13Florence.dres`, `Expert/DUnitX_IDE_Expert_D13FlorenceResource.rc`, `packages/RAD Studio 13.0/VSoft.DUnitXWinR.res`, `Tests/DUnitXTest_D13.res`, `Examples/DUnitXExamples_D13.res`
  **Why:** two `.dpk` files pull these in with `{$R *.res}` and `{$R *.dres}`, so a clean clone depended on the IDE recreating them. GITLAK policy is to commit `.res` as project metadata. Build output copies remain excluded by the output-folder rules.
- `[MaxTime]` crashed the test thread instead of failing the test (2026-08-24) - `Source/DUnitX.Timeout.pas`, `Source/DUnitX.Test.pas`, `Tests/DUnitX.Tests.Example.pas`
  **Why:** the watchdog suspended the test thread and rewrote its instruction pointer to jump into a raise, via `Ctx.Rip := Cardinal(@RaiseTimeOutException)`. That truncates a 64 bit code address, and Delphi 13 links with a preferred base above 4GB, so the pointer was always unmapped and the thread faulted on resume. Correcting the cast would not have been enough: an injected frame pushes no return address and has no unwind-table entry, and x64 SEH is table driven, so the raise could not have unwound either. `[MaxTime]` is an assertion about elapsed time, so it is now observed and reported once the test method returns - correct on every platform, though it cannot interrupt a test that never returns. The watchdog is also stopped before the duration is computed, so a late expiry can no longer be blamed on the next test.
- `TTestFixtureList.Sort` freed a `TDelegatedComparer` that had been implicitly converted to a refcounted `IComparer`; it is now held as the interface and not freed (2026-08-24) - `Source/DUnitX.Extensibility.pas`
  **Why:** it survived only because `const` interface parameters skip reference counting - accidental safety that breaks the moment the callee stores the reference.
- `TWeakReference<T>.Destroy` abandoned `RemoveWeakRef` when it could not take the lock but nilled its field anyway, leaving the target holding a pointer into memory about to be freed, which it wrote through during its own destruction. It now blocks, matching `RemoveWeakRef` itself (2026-08-24) - `Source/DUnitX.WeakReference.pas`
- `TRttiPropertyExtension` freed its patched virtual method tables before the instances that dispatch through them (2026-08-24) - `Source/DUnitX.Utils.pas`
- The service locator leaked the constructed object whenever `Supports` failed, which is silent by default (2026-08-24) - `Source/DUnitX.ServiceLocator.pas`
- `TValueHelper.IsUInt64` tested `NativeInt`, the signed type already used by `IsInt64` (2026-08-24) - `Source/DUnitX.Utils.pas`
- The FastMM4 leak monitor multiplied in 32 bits and cast the overflowed product to `Int64` afterwards (2026-08-24) - `Source/DUnitX.MemoryLeakMonitor.FastMM4.pas`

- Removed machine-specific unit search paths from `Examples/DUnitXExamples_D13.dproj`: a personal absolute `C:\delphi\DelphiMocks`, an undefined `$(DPMSearch)`, and upstream's `..\..\Delphi-Mocks` folder name (2026-08-24)
- `Tests/DUnitXTestProject.dpr` still declared `program DUnitXTest_D12;` (2026-08-24)
- `VSoft.DUnitX.dspec` shipped `./source/*.pas` without `*.dfm`, so a consumer using `DUnitX.Loggers.GUI.VCL` would fail on its `{$R *.dfm}` (2026-08-24)
- `.gitignore` did not cover `Expert/Win64/` or `packages/RAD Studio 13.0/Win64/`; they were masked only by this machine's global ignore file, so build output would appear untracked elsewhere (2026-08-24)
- `CONTRIBUTING.md` and `Build/Dependencies.txt` still pointed at the upstream GitHub repository (2026-08-24)
