# Dependencies

## Delphi.Mocks — required by the test project only

`Tests\DUnitXTest_D13.dproj` compiles two units against Delphi.Mocks:
`DUnitX.Tests.Loggers.XML.NUnit.pas` and `DUnitX.Tests.Loggers.XML.JUnit.pas`, which use
`TMock<T>` to fabricate result graphs for the XML loggers. Nothing in `Source\` depends on it — the
DUnitX runtime library itself has no Delphi.Mocks reference, and neither does the IDE expert or the
examples.

### Pinned version

| | |
|---|---|
| Repository | `https://github.com/ijbranch/glldelphi-mocks` |
| Branch | `main` |
| **Commit** | **`59683d371bd8f99c8e623b36119e3e9834d64460`** |
| Short | `59683d3` |
| Dated | 2026-10-08 |
| Subject | Adopt D13 not in / is not; IfThen -> if expression; simplify boolean assignments |

This is the commit the suite was last verified green against (2026-10-12, Debug): **Win64 297 tests found,
288 passed, 9 ignored; Win32 295 found, 286 passed, 9 ignored; 0 failed, 0 errored, 0 leaked on both**
(the two Win64-only tests are the `CPU64BITS` Integer / Int64 overloads).

Upstream DUnitX pinned `VSoft.DelphiMocks 0.2.2` through a DPM `PackageReference`. That pin was
removed when this fork switched to consuming Delphi.Mocks from a sibling source checkout, because
there is no DPM cache on the build machine and 0.2.2 had no verified `delphi13.0` / `win64` binding.
This file replaces it: the coupling is by path, so the version has to be recorded rather than
resolved.

### How it is located

`Tests\DUnitXTest_D13.dproj` defines:

```xml
<DelphiMocks Condition="'$(DelphiMocks)'==''">..\..\glldelphi-mocks\Source</DelphiMocks>
```

so by default the two repositories must sit side by side:

```
<parent>\gllDUnitX
<parent>\glldelphi-mocks
```

Override the `DelphiMocks` property or an environment variable of the same name to put it elsewhere.
A `CheckDelphiMocks` MSBuild target fails the build with an actionable message if it is missing,
rather than letting the compiler emit a bare `F2613 Unit 'Delphi.Mocks' not found`.

### Verifying the checkout matches the pin

```
git -C ..\glldelphi-mocks rev-parse HEAD
```

Compare against the commit above. To move to that exact commit:

```
git -C ..\glldelphi-mocks fetch origin
git -C ..\glldelphi-mocks checkout 59683d371bd8f99c8e623b36119e3e9834d64460
```

### When the pin should change

Update the commit above whenever the test suite is re-verified against a newer Delphi.Mocks, and say
so in `CHANGELOG.md`. A drifting checkout shows up as a **compile** failure in the two logger test
units, not a test failure, so it is easy to misread — check this file first.

Delphi.Mocks itself has known defects recorded in that repository's `CHANGELOG.md` under
**Known Issues**; they do not affect the units DUnitX consumes.
