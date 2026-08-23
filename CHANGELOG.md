# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Changed

- Scoped this fork to Delphi 13 (Florence) or later, 64 bit Windows only (2026-08-24) - `README.md`, `CONTRIBUTING.md`, `VSoft.DUnitX.dspec`
  **Why:** the fork exists to serve GITLAK's Win64-only Delphi 13 suite, so carrying fifteen RAD Studio versions and five non-Windows platforms was pure maintenance cost.
- Retargeted every surviving project to Win64 alone - `ProjectVersion` 20.5, `TargetedPlatforms` 2, default platform Win64, and all OSX/Win32/Linux/mobile configuration groups removed (2026-08-24) - `packages/RAD Studio 13.0/VSoft.DUnitXWinR.dproj`, `Expert/DUnitX_IDE_Expert_D13Florence.dproj`, `Examples/DUnitXExamples_D13.dproj`, `Tests/DUnitXTest_D13.dproj`
- `DUnitX.AutoDetect.Console` now resolves only `DUnitX.Windows.Console` and raises a compile-time error on any other platform (2026-08-24) - `Source/DUnitX.AutoDetect.Console.pas`
- Reworded the "no ConsoleWriter registered" message to name only `DUnitX.Windows.Console` (2026-08-24) - `Source/DUnitX.ResStrs.pas`
- Restricted the DPM spec to `delphi13.0` / `win64` and pointed its project and repository URLs at this fork (2026-08-24) - `VSoft.DUnitX.dspec`

### Added

- `Tests/DUnitXTest_D13.dproj`, derived from the former D12 test project (2026-08-24)
  **Why:** the tree had no Delphi 13 test project at all - the newest was D12.

### Fixed

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

- `Tests/DUnitXTest_D13.dproj` needs the `VSoft.DelphiMocks` DPM package restored before it will build.
