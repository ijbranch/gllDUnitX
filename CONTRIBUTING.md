## Contributing ##

gllDUnitX is maintained for GITLAK Software's own use and comes **without support**; it does not take pull
requests.

* **A fix to DUnitX itself belongs upstream**, in [VSoftTechnologies/DUnitX](https://github.com/VSoftTechnologies/DUnitX).
  Upstream takes one issue per problem, then a pull request with a test that fails on its `master`. This fork
  sends its own upstream-relevant fixes that way; their status is in `UPSTREAM-REPORT-Defects-2026-10-12.md`,
  `UPSTREAM-ISSUES-Batch1.md`, `UPSTREAM-ISSUES-Batch2.md` and `UPSTREAM-ISSUES-Batch3.md`.
* **Something specific to this fork** (its scope, `Assert.Ignore`, the VCL GUI runner as fixed here) can be raised
  as an issue on this repository, as a report; there is no commitment to act on it.

## Building and testing the fork itself ##

* Delphi 13 (Florence) or later, Windows only - Win32 and Win64.
* The test project (`Tests\DUnitXTest_D13.dproj`) also needs
  [glldelphi-mocks](https://github.com/ijbranch/glldelphi-mocks), checked out as a sibling of this repository at
  the commit pinned in [DEPENDENCIES.md](DEPENDENCIES.md). It is GITLAK's own fork of Delphi-Mocks - not upstream
  [VSoftTechnologies/Delphi-Mocks](https://github.com/VSoftTechnologies/Delphi-Mocks), and not the DPM package
  upstream pinned - and, like this repository, it is public. The runtime library, IDE expert and examples need
  nothing beyond RAD Studio.
* Any project you build against `Source\` needs its own platform-varying DCU output directory - see
  **Installing** in [README.md](README.md) for why.

## Feedback ##

DUnitX in general is discussed on upstream's [Delphi Praxis forum](https://en.delphipraxis.net/forum/36-dunitx/).
