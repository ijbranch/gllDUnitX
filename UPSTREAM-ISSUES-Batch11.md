# DUnitX upstream: batch 11 (posted 2026-11-02)

The three small fixes from the list on [#398](https://github.com/VSoftTechnologies/DUnitX/issues/398#issuecomment-6567841508), to which Vincent replied (2026-11-02 03:15 UTC): "happy for all of the above to be addressed."  Built on `master` @ `97d8c35` (#546), one branch each in its own worktree, pushed to [`ijbranch/gllDUnitX`](https://github.com/ijbranch/gllDUnitX).

**Posted 2026-11-02 14:50 +11** (Ian: "Approved to publish"): one issue and one PR per defect, each PR body saying "From the #398 list" (not "Fixes #398", which would close the report).  GitHub showed all three as clean merges.

| # | Defect | Issue | PR | Branch | Head | Merged |
|---|---|---|---|---|---|---|
| 1 | JUnit logger: suite name loses the first `.Name`, not the trailing one; `<failure>` body repeats the message instead of the stack trace | [#547](https://github.com/VSoftTechnologies/DUnitX/issues/547) | [#550](https://github.com/VSoftTechnologies/DUnitX/pull/550) | `fix/junit-suite-name-failure-body` | `4642fdf` | |
| 2 | `[TestCase]` 'abc' still becomes 0 for `Int64` / `UInt64` (and `NativeInt` / `NativeUInt` on Win64), following #522 | [#548](https://github.com/VSoftTechnologies/DUnitX/issues/548) | [#551](https://github.com/VSoftTechnologies/DUnitX/pull/551) | `fix/testcase-int64-values` | `9fffd31` | |
| 3 | NUnit and JUnit XML write the exe path into attributes unescaped | [#549](https://github.com/VSoftTechnologies/DUnitX/issues/549) | [#552](https://github.com/VSoftTechnologies/DUnitX/pull/552) | `fix/xml-escape-exe-name` | `86d0146` | |

## How this batch was built

- **Test first.**  #1: two tests in `DUnitX.Tests.Loggers.XML.JUnit` fail on `master` on their own assertions (the suite was written `MyTests.TFoo` for `My.TFooTests`) and pass with the fix; reverting either half fails only its test.  #2: two tests beside #522's in `DUnitX.Tests.Utils` fail on `master` and pass in Win64 and Win32 Debug; 11 mutations, all killed (one survived at first: '' for `UInt64`, so an assertion was added).  #3: no test is possible (the name comes from `ParamStr(0)` and testing it would need a new seam); proved by running the test exe from a folder named `a&b'c`: before the fix `xml.etree` failed at the raw `&`, after it the file parses and the attribute reads back as the real path.
- **Combined.**  Every pair merges cleanly; all three merged on `97d8c35` build with only upstream's existing H2675 / W1000, and the suite gives 510 passed, 9 ignored (506 + the four new tests).
- **Reviews** (a fresh subagent per PR): #1 and #3 found nothing.  #2: 4 findings, 2 fixed (a negative hex value whose sign `TryStrToInt64` flips, '-$FFFFFFFFFFFFFFFF' read as +1; a tab skipped as leading space, which `Val` does not do), 2 declined ('-0' refused for `UInt64` while `Cardinal` and `Int64` accept it; the same negative-hex flaw in #522's `ConvStr2Int`, out of scope).
- **`BREAKINGCHANGES.md`**: #1 adds a section (a CI server that keys history by suite name sees a corrected suite as new); #2 adds a bullet under #522's.  Both name their issue numbers, filled in after the issues were created.
- #2 does not use `TryStrToUInt64` (not in every supported RTL); a small decimal parser reads a `UInt64` above `High(Int64)`, and the old `{$IFDEF DELPHI_XE6_UP}` `StrToUInt64Def` branch is gone.  A `UInt64` subrange above `High(Int64)` does not compile (E2011), so the unsigned path only ever sees full-width types.
- #3 also escapes category names in the JUnit `WriteCategoryNodes`, to match the NUnit logger; nothing calls it at present, which the PR says.

## This fork

This fork fixed all three defects in October.  PR #551 is stricter than this fork's `ConvStr2Ord` (`Source\DUnitX.Utils.pas`) in two edge cases, which this fork still accepts: a hex value with bit 63 set in an `Int64` subrange ('$FFFFFFFFFFFFFFFF' becomes -1 and passes the range check, where #522's rule refuses hex in a subrange that does not cover the full width), and a negative hex value, which `TryStrToInt64` sign-flips ('-$FFFFFFFFFFFFFFFF' becomes +1).  Port with tests when #551 merges.

## Not sent

- `ConvStr2Int` (#522) reads '-$FFFFFFFFFFFFFFFF' as 1 for an `Integer` parameter: a candidate for a later batch.
- The rest of the #398 list (behaviour changes, runner changes, IDE expert) follows in later batches.
