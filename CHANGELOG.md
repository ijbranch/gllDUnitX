# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Reviewed and deliberately NOT taken from upstream, so they are not re-derived later

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

### Added

- `Assert.Ignore` — a RUNTIME test skip, reported as ignored rather than passed (2026-09-09) — `Source\DUnitX.Assert.pas`, `Source\DUnitX.Init.pas`, `Source\DUnitX.TestFramework.pas`, `Source\DUnitX.TestRunner.pas`, `Tests\DUnitX.Tests.Assert.pas`
  **Why:** DUnitX could only skip a test at COMPILE time, via the `[Ignore]` attribute. A test whose precondition can only be discovered by looking — an external tool, a source tree, a database — had no honest option. `Assert.Pass` reports PASS, which is indistinguishable from a test that verified something and hides the gap on every later run; doing nothing hides it more quietly still. This closes that.
  **Almost all of the machinery was already upstream and unused:** `ETestIgnored` was declared in `DUnitX.Exceptions.pas`, `TDUnitXTestRunner.ExecuteTest` already caught it, and `TTestResultType.Ignored`, `IgnoredCount` and `OnTestIgnored` were fully plumbed through every logger. Nothing anywhere raised it. The addition is the missing trigger — `Assert.Ignore`, with `fTestIgnored`/`TestIgnored` mirroring the existing `fTestPass`/`TestPass` injection so the exception class stays replaceable.
  **One real fix went with it, and it is load-bearing rather than cosmetic:** the runner passed `test.IgnoreReason` — the ATTRIBUTE's reason, which is empty for a runtime skip — into `ExecuteIgnoredResult`, so `Assert.Ignore('because X')` recorded the skip and silently dropped the reason. It now prefers `e.Message` and falls back to `IgnoreReason`. Mutation-checked: with that one branch reverted the test is still reported `result="Ignored"` but the reason is absent from the NUnit XML entirely.
  `Assert.Ignore` deliberately does NOT call `DoAssert` — being skipped is not an assertion, and counting it as one would let a test satisfy `FailsOnNoAsserts` by doing nothing but skipping itself. Verified: an ignored test reports `executed="False"`, `asserts="0"`.
  **Divergence note.** Absent from upstream `master` AND `dev` as of 2026-09-09, so this is fork-local and will conflict on a future merge that touches these four units. `upstream/dev` additionally DELETES the `on e : ETestIgnored do` handler this stands on — but dev's tip is 2025-05-05, some sixteen months older than master's, and it has never been merged into master, so the risk is remote. Worth offering upstream: it is small, it uses their own dormant plumbing, and taking it back would remove the divergence. A proposal addressed to the maintainers is drafted at [UPSTREAM-PROPOSAL-Assert-Ignore.md](UPSTREAM-PROPOSAL-Assert-Ignore.md), sent to the maintainers on 2026-09-09; no response yet. It carries the full diff, the mutation evidence, and a heads-up they would want regardless of whether they take the patch: `upstream/dev` deletes the `ETestIgnored` handler this stands on, so the run-time ignore path disappears if that branch ever lands as it stands.
  Covered by `Ignore_Throws_ETestIgnored_Exception` and `Ignore_Throws_ETestIgnored_Exception_With_Message`. Suite: 289 found, 280 passed, 9 ignored, 0 failed.

### Fixed

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

### Added

- **Tips and Tricks** in `README.md` now requires a platform-varying DCU output directory on any project built against `Source\`, and states that `Source\` must never contain `.dcu` files (2026-09-05) — `README.md`, `CONTRIBUTING.md`
  **Why:** the surrounding instruction — "adjust your search paths to point to the repo\\Source folder" — is exactly what leads a consumer into the `F2048` failure recorded above, and it said nothing about DCU output. Documenting the requirement next to the instruction that creates the hazard is the durable half of that fix; deleting the files was only the immediate half.

### Changed

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

## [In-Service]

### Changed

- `upstream/master` is merged as far as `a69a10b` (2026-08-27). The commit had already been cherry-picked on 2026-08-26 (see Fixed), so the merge changes no file - it exists so the fork's position can be measured with `git merge-base` instead of by patch comparison, which does not recognise an adapted cherry-pick.

- **C++Builder output turned off** (2026-08-26). `DCC_CBuilderOutput` was `All`, so every build emitted `.hpp` / `.bpi` / `.a` / `.obj` files for a compiler that is **never in scope here** (standing rule: "I dont use C++ at all"). Across the estate that was 616 files and 90 MB of output nobody consumes, regenerated on every build; `gllSynEdit` alone accounted for 560. Now `None`. The `DCC_HppOutput` / `DCC_BpiOutput` / `DCC_ObjOutput` properties are left in place deliberately - they only say *where* such files would go, so with generation off they are inert, and removing them would enlarge the diff without changing behaviour. Verified: the affected packages rebuilt clean in every enabled mode, emitted no C++ artefacts, and rebuilt clean again after the existing ones were deleted (so nothing was load-bearing).

- The DPM package id is now `GITLAK.DUnitX`, not `VSoft.DUnitX`, so this fork cannot shadow upstream in a package feed. Description records the upstream baseline (0.5.1) and the Delphi 13 / Win64 scope; GITLAK Software added to `authors`, with Vincent Parrett's authorship and copyright retained as Apache-2.0 requires (2026-08-24) - `VSoft.DUnitX.dspec`

### Added

- `DEPENDENCIES.md`, pinning the exact Delphi.Mocks commit the test suite is verified against (`19ff97e`), with instructions to verify and move a checkout to it (2026-08-24)
  **Why:** upstream pinned `VSoft.DelphiMocks 0.2.2` through DPM; that pin was dropped when this fork switched to a sibling source checkout, leaving the coupling by path with no recorded version. Drift shows up as a *compile* failure in the two logger test units, which is easy to misread.
  `Build/Dependencies.txt` and the `CheckDelphiMocks` build guard now point at the fork and at `DEPENDENCIES.md` respectively - the dependency list still named upstream's GitHub repo.

> Libraries and packages are continuously deployed: changes below are live as soon as the package is rebuilt and installed - there is no separate release step, so no `[Unreleased]` backlog. Tagged version snapshots are listed beneath.

### Fixed

- Leak accounting read the wrong memory manager when the FastMM4 leak monitor was enabled (2026-08-26) - `Source\DUnitX.MemoryLeakMonitor.FastMM4.pas`, `Source\DUnitX.MemoryLeaks.inc`
  **Why:** `System.GetMemoryManagerState` walks the RTL's bundled FastMM, not a `FastMM4.pas` installed as the first unit - which is exactly the setup the leak monitor requires - so the small-block loop reported 0 or nonsense (upstream measured an RTL delta of 0 against a FastMM4 delta of 4140 for a 4096-byte allocation). Under `USE_FASTMM4_LEAK_MONITOR` the monitor now calls `FastMM4.GetMemoryManagerUsageSummary`, which reads FastMM4's own block lists; the RTL path is kept for the undefined case so the unit still compiles without FastMM4 on the search path. The define stays off by default. Cherry-picked from upstream `a69a10b` (Olaf Monien, #395); this fork's own `Int64` cast fix in the RTL branch is preserved inside the new `{$ELSE}`.
  **Note:** GITLAK code uses FastMM5 (`gllFastMM5`), so this affects only the opt-in FastMM4 monitor, not the default leak accounting.

- Corrected the Debug/Release package output split (2026-08-24)
  **Why:** the first attempt diverted both configurations to a `$(Config)` subfolder, which broke package loading - `$(BDSCOMMONDIR)\Bpl\$(Platform)` is on the machine `PATH` and is where a design package resolves the runtime packages it requires. Release now stays in the shared `Bpl`/`Dcp` folders and only Debug is diverted, which still stops a Debug build replacing the installed Release package.

### Changed

- Scoped this fork to Delphi 13 (Florence) or later, 64 bit Windows only (2026-08-24) - `README.md`, `CONTRIBUTING.md`, `VSoft.DUnitX.dspec`
  **Why:** the fork exists to serve GITLAK's Win64-only Delphi 13 suite, so carrying fifteen RAD Studio versions and five non-Windows platforms was pure maintenance cost.
- Retargeted every surviving project to Win64 alone - `ProjectVersion` 20.5, `TargetedPlatforms` 2, default platform Win64, and all OSX/Win32/Linux/mobile configuration groups removed (2026-08-24) - `packages/RAD Studio 13.0/VSoft.DUnitXWinR.dproj`, `Expert/DUnitX_IDE_Expert_D13Florence.dproj`, `Examples/DUnitXExamples_D13.dproj`, `Tests/DUnitXTest_D13.dproj`
- `DUnitX.AutoDetect.Console` now resolves only `DUnitX.Windows.Console` and raises a compile-time error on any other platform (2026-08-24) - `Source/DUnitX.AutoDetect.Console.pas`
- Reworded the "no ConsoleWriter registered" message to name only `DUnitX.Windows.Console` (2026-08-24) - `Source/DUnitX.ResStrs.pas`
- Collapsed the now-dead `USE_NS` and `DELPHI_XE103_UP` conditionals in the two IDE expert wizard units, keeping only the namespaced units, `PlatformConst` and `GetAllPlatforms` (2026-08-24) - `Expert/DUnitX.Expert.ProjectWizardEx.pas`, `Expert/DUnitX.Expert.NewUnitWizardEx.pas`
  **Why:** both were always true on Delphi 13, and their dead branches still named `cOSX32Platform`, `cAndroidPlatform` and other platforms this fork no longer targets.
- Restricted the DPM spec to `delphi13.0` / `win64` and pointed its project and repository URLs at this fork (2026-08-24) - `VSoft.DUnitX.dspec`

### Added

- `Tests/DUnitXTest_D13.dproj`, derived from the former D12 test project (2026-08-24)
  **Why:** the tree had no Delphi 13 test project at all - the newest was D12.

### Removed

- Dead weight surfaced by a full audit: `Build/TestAndBuild.fbp7` (a 1 MB FinalBuilder project referencing only deleted XE-era artefacts), the orphaned `Examples/DUnitX.Examples.UITest.*`, `Examples/DUnitX.Examples.AssertFailureCompare.pas`, `Examples/DUnitXExamples.rc/.rsb`, `Tests/DUnitX.Options.pas`, `Tests/DUnitXTest.mes`, `Source/DUNitX.Loggers.GUIX.vlb`, and the `*Ex`-superseded `Expert/DUnitX.Expert.NewUnitWizard.pas` and `Expert/DUnitX.Expert.ProjectWizard.pas` (2026-08-24)
- `Tests/DUnitX.Stacktrace.inc`, a divergent stale copy of the `Source` include missing the `USE_MADEXCEPT*` and `USE_EUREKALOG7` defines (2026-08-24)
  **Why:** only `Source/DUnitX.inc` includes it, so the Source copy always won - but the duplicate was a trap if include order ever changed.
- `docs/.gitattributes`, which forced `eol=lf` on a directory left empty (2026-08-24)

### Fixed

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

### Added

- A `CheckDelphiMocks` MSBuild target in `Tests/DUnitXTest_D13.dproj` that fails with an actionable message naming the required sibling clone, instead of a bare `F2613 Unit 'Delphi.Mocks' not found` (2026-08-24)

- The test project now resolves Delphi.Mocks from a sibling `glldelphi-mocks` source checkout via the existing `DelphiMocks` property, replacing the DPM package reference (2026-08-24) - `Tests/DUnitXTest_D13.dproj`
  **Why:** there is no DPM cache on the build machine, and the pinned `VSoft.DelphiMocks 0.2.2` had no verified `delphi13.0`/`win64` binding.
- Six count assertions in `DUnitX.Tests.CategoryParser.pas` failed to compile with E2532. Delphi 13 changed `TList<T>.Count` to `NativeInt`, so generic inference against an integer literal became ambiguous; the assertions are now explicitly `AreEqual<NativeInt>` (2026-08-24)
- The Delphi 13 IDE expert failed to compile with E2250 at `DUnitX.Expert.ProjectWizardEx.pas:132`. Delphi 13 declares the wizard glyph callback as `TFunc<UInt64>` rather than `TFunc<Cardinal>`, matching the 64 bit `HICON` that `LoadIcon` returns, so the `function : Cardinal` literals no longer matched any `Create` overload. Both anonymous glyph functions now return `UInt64` (2026-08-24) - `Expert/DUnitX.Expert.ProjectWizardEx.pas`, `Expert/DUnitX.Expert.NewUnitWizardEx.pas`
  **Why:** inherited from upstream - the D13 expert project had never been compiled against the Delphi 13 ToolsAPI.

### Removed

- The fourteen pre-D13 package folders under `packages/` (2026-08-24)
- All non-D13 test, example and IDE expert project files, and `Tests/TestProjects.groupproj` (2026-08-24)
- Non-Windows source units: `DUnitX.Linux.Console.pas`, `DUnitX.MacOS.Console.pas`, `DUnitX.Loggers.Console.FMX.pas`, `DUNitX.Loggers.MobileGUI.pas`, `DUNitX.Loggers.MobileGUI.fmx` (2026-08-24) - `Source`
- `Source/DUNitX.Loggers.GUIX.pas` and its `.fmx` form, the FireMonkey GUI runner (2026-08-24)
  **Why:** its only consumers were the deleted `DUnitXFiremonkeyGUI_*` projects, leaving it unreachable.
- The FMX pseudo-console feature and its documentation, upstream commit 731e335 (2026-08-24) - `docs/FMX-Pseudo-Console.md`, `README.md`
- The legacy `Build/Run-Dependend-Delphi-*.bat` launcher scripts (2026-08-24)

### Known Issues

### Known Issues

- `TRttiPropertyExtension` hard-codes virtual method table slot indices derived from an older `System.Rtti`. Delphi 13 inserted `TRttiPlaceMember` and `TRttiDataMember` into the hierarchy, so the map is very likely wrong. Nothing in DUnitX constructs one, so it is unreachable today; the code now carries a warning to re-verify every index before using it.
- Public members such as `ITestFixture.TestCount` still return `Integer` while the underlying `TList<T>.Count` is `NativeInt` in Delphi 13. The implicit narrowing is harmless at realistic test counts and widening the public API would be a breaking change. Note that an `Assert.AreEqual` overload taking `NativeInt` cannot be added on Win64, where `NativeInt` and `Int64` are the same type - use `Assert.AreEqual<NativeInt>` for collection counts.
