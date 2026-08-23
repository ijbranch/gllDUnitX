# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

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
  **Why:** RAD Studio defaults `DCC_BplOutput` to `$(BDSCOMMONDIR)\Bpl\$(Platform)` and `DCC_DcpOutput` to `\Dcp\$(Platform)`, neither carrying `$(Config)`, so a Debug build silently replaced the installed Release package while `.dcu` output was already separated. Both now include `$(Config)`. The IDE registration was repointed at `Bpl\Win64\Release` accordingly.
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
