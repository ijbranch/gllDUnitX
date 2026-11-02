# DUnitX upstream: batch 13 (posted 2026-11-02)

Two follow-ups, built on `master` @ `cc247a9` (every batch 11 and 12 PR merged), each in its own worktree, pushed to [`ijbranch/gllDUnitX`](https://github.com/ijbranch/gllDUnitX).

**Posted 2026-11-02 15:50 +11** (Ian: "Approved to publish"): GitHub showed both as clean merges.

| # | Defect | Issue | PR | Branch | Head | Merged |
|---|---|---|---|---|---|---|
| 1 | A 64-bit hex `[TestCase]` value converts to an `Integer` or smaller type (`ConvStr2Int` has the flaws #551 fixed for `Int64`) | [#564](https://github.com/VSoftTechnologies/DUnitX/issues/564) | [#565](https://github.com/VSoftTechnologies/DUnitX/pull/565) | `fix/testcase-integer-hex-64bit` | `c8e2a4b` | |
| 2 | `Assert.IsType<T>` always fails (option 2 of question #558, Vincent: "Lets go with option 2") | [#558](https://github.com/VSoftTechnologies/DUnitX/issues/558) | [#566](https://github.com/VSoftTechnologies/DUnitX/pull/566) | `fix/istype-always-fails` | `d8a6061` | |

## How this batch was built

- #1 ports this fork's `c01f413`: inside the `TryStrToInt64` branch only (not `TColor` / `TAlphaColor`), a hex value read as negative (bit 63 set) and a negated hex value that came out positive are refused.  Test `Hex_Integer_Wider_Than_The_Type_Or_Sign_Flipped_Does_Not_Convert`, red on `cc247a9` on its own assertion; 5 mutants killed.  Review: 5 findings, 2 fixed (a wrong "as for Int64" claim in the text; more spellings tested), 3 declined.  Found by the review of this fork's port of #551, so not on the #398 list.
- #2 ports this fork's `IsType<T>` (always fails), with two differences: the caller's `message` is included in the failure, as in upstream's other asserts, and the unused resourcestring `STypeError` is removed (documented in `BREAKINGCHANGES.md`).  The one upstream caller, the example `TMyExampleTests.TestTwo`, now uses `Assert.InheritsFrom`.  The test wraps its deliberate call in `{$WARN SYMBOL_DEPRECATED OFF}` / `ON`, upstream's own pattern in `DUnitX.Tests.DUnitCompatibility.pas`.  Red on `cc247a9`; 3 mutants killed.  Review: 4 findings, 3 fixed (the `Implements` advice names an interface reference; spacing; the example checks `TStrings`), 1 declined (keeping `STypeError`).
- `BREAKINGCHANGES.md`: each section sits before a different heading (#396 and #544), so the two merge in any order.  Combined on `cc247a9`: build with only upstream's existing H2675 / W1000, 531 passed, 9 ignored.

## This fork

- #1 is this fork's `c01f413`.  #2: this fork's `IsType<T>` drops the caller's message; take upstream's form when #566 merges.
