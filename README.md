gllDUnitX
=========

GITLAK Software's fork of [DUnitX](https://github.com/VSoftTechnologies/DUnitX), the unit-test framework for
Delphi that takes its ideas from DUnit and NUnit.

> **Scope.** This fork targets **Delphi 13 (Florence), Windows only - Win32 and Win64**, VCL. Support for
> earlier RAD Studio versions, OSX, Linux, Android and iOS has been removed; use
> [upstream DUnitX](https://github.com/VSoftTechnologies/DUnitX) if you need those.
>
> **Not affiliated with VSoft Technologies.** This is an independent fork; credit for DUnitX itself belongs to
> Vincent Parrett and its contributors - see *Licence* at the foot of this file.

What the fork adds or changes
=============================

* **`Assert.Ignore(reason)`** - a fork-local API that skips a test at RUN time and reports it as *ignored*
  rather than passed, for a precondition that can only be discovered by looking (an external tool, a source
  tree, a database, an interactive desktop). Upstream has only the compile-time `[Ignore]` attribute, and
  neither its `master` nor its `dev` branch has this, so code using it will not build against upstream DUnitX.
* **Defect fixes** across the framework, the VCL GUI runner and the IDE expert - several of them cases where
  a test passed, or a run reported success, when it should have failed. Each is in [CHANGELOG.md](CHANGELOG.md);
  those that apply upstream have been offered back as issues and pull requests (see
  `UPSTREAM-REPORT-Defects-2026-10-12.md`).
* **The VCL GUI runner** (`DUnitX.Loggers.GUI.VCL`) has been fixed and updated. It is not maintained upstream,
  which recommends the **TestInsight** IDE plug-in instead; whether to use TestInsight or this runner is your
  choice.
* **The DPM package id is `GITLAK.DUnitX`**, not `VSoft.DUnitX`, so it cannot shadow upstream in a package feed.

Features
========

* Any class can contain tests
* Attribute based testing
* An extensive Assert class
* Setup and TearDown per test method and per test fixture
* Console runner, and a VCL GUI runner
* XML logging
  * output compatible with NUnit (for CI servers such as [ContinuaCI](https://www.finalbuilder.com/continua-ci))
  * output compatible with JUnit (for [GitLab CI](https://docs.gitlab.com/ee/ci/unit_test_reports.html))
* Win32 and Win64
* Limited backwards compatibility with DUnit test classes
* An IDE [wizard](https://www.finalbuilder.com/Resources/Blogs/dunitx-has-a-wizard) for new test projects and
  units, and live templates for fixtures and tests
* API documented with XML doc comments

Installing
==========

There is no installer: RAD Studio ships its own DUnitX, and using this fork means replacing that copy by hand.
The steps are below; [Users Guide.md](Users%20Guide.md) §1 has the detail.

1. **Use the fork's source or package in your test projects** - one of:
   * add the repository's `Source` folder to the project's search path, **and give the project a DCU output
     directory that varies by platform and configuration**, for example
     `<DCC_DcuOutput>.\$(Platform)\$(Config)</DCC_DcuOutput>`; or
   * build `packages\RAD Studio 13.0\VSoft.DUnitXWinR.dproj` in all four modes (Win32 + Win64 x Debug +
     Release) and use it as a runtime package.

   Naming the fork explicitly matters: RAD Studio's bundled DUnitX DCUs are on the library path, and a project
   that does not say which DUnitX it wants can silently link the bundled one - at which point `Assert.Ignore`
   will not compile.
2. **Optionally, the IDE expert:** remove Embarcadero's unit-test expert (`DUnitXIDEExpert*.bpl`) from the
   installed packages, then build and install `Expert\DUnitX_IDE_Expert_D13Florence.dproj` from the 64-bit IDE
   (`bin64\bds.exe`). File > New gains **DUnitX Project** and **DUnitX Unit**.

   The project wizard writes `$(DUnitX)` into each new project's unit search path, so set the IDE environment
   variable `DUnitX` to this repository's `Source` folder (Tools > Options > IDE > Environment Variables, a
   user override); the wizard warns when it is not set. Its default leak-reporting option, **FastMM5**, puts
   `FastMM5` in the new project's `uses` clause, so `FastMM5.pas` (for example from gllFastMM5) must be on the
   project's search path or the library path; choose **None** otherwise.
3. **Optionally, the live templates:** `LiveTemplates\Install.bat` copies nine code templates
   (`create-testfixture`, `create-testproc`, ...) into the IDE's template folder.

**`Source\` must never contain `.dcu` files.** Without a DCU output directory the compiler writes each `.dcu`
beside the `.pas` it compiled, so one build drops the whole DUnitX set into `Source\` - and the next build for
the other platform reads them and dies with `F2048 Bad unit format`. If you find any there, delete them; they
are build output that escaped a misconfigured project, and `.gitignore` already covers them.

Building the tests
==================

`Tests\DUnitXTest_D13.dproj` needs a sibling checkout of
[glldelphi-mocks](https://github.com/ijbranch/glldelphi-mocks) at the commit pinned in
[DEPENDENCIES.md](DEPENDENCIES.md) (a public repository: GITLAK's fork of Delphi Mocks). The runtime library, IDE
expert and examples need nothing beyond RAD Studio.

Support
=======

This fork is maintained for GITLAK Software's own use and comes **without support**. For DUnitX in general, see
upstream's [Delphi Praxis forum](https://en.delphipraxis.net/forum/36-dunitx/) and
[repository](https://github.com/VSoftTechnologies/DUnitX).

Documentation
=============

* [Help.md](Help.md) - reference: fork scope, API, building, troubleshooting by symptom
* [Users Guide.md](Users%20Guide.md) - task-oriented walkthroughs with worked examples
* [CHANGELOG.md](CHANGELOG.md) - every change this fork has made, with the reason
* [DEPENDENCIES.md](DEPENDENCIES.md) - the pinned test-project dependency
* [TestCaseProvider.md](TestCaseProvider.md) - data-driven test cases
* `UPSTREAM-*.md` - what has been reported or proposed to upstream, and its status
* [UPSTREAM-NOT-TAKEN.md](UPSTREAM-NOT-TAKEN.md) - upstream changes reviewed and deliberately not taken, and why

Contributors
============

DUnitX: a [list of contributors](https://github.com/VSoftTechnologies/DUnitX/graphs/contributors) is on GitHub,
and their commits keep their authors in this fork's history. This fork: Ian Branch (GITLAK Software), working
with [Claude Code](https://claude.com/claude-code), Anthropic's AI coding assistant, which wrote much of the
fork's code, tests and documentation under his direction; commits it contributed to carry a
`Co-Authored-By: Claude` trailer.

Licence
=======

Apache License 2.0 - see [LICENSE.txt](LICENSE.txt).

DUnitX: Copyright (C) 2012+ Vincent Parrett and contributors - vincent@finalbuilder.com,
http://www.finalbuilder.com.

**This fork.** Changes made in gllDUnitX are Copyright (C) 2026 Ian Branch (GITLAK Software) and are licensed
under the same Apache License 2.0. They were developed with the assistance of Claude Code (Anthropic) - see
*Contributors*. Every source file this fork changed carries a
"Modified (C) 2026 Ian Branch (GITLAK Software) - gllDUnitX fork" line beneath its original copyright notice,
which is kept intact; per-change detail is in [CHANGELOG.md](CHANGELOG.md), and upstream commits taken into the
fork keep their original authors in the git history. gllDUnitX is an independent fork and is not affiliated with
or endorsed by VSoft Technologies; "DUnitX" refers to the upstream project it derives from.
