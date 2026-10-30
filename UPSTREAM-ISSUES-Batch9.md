# DUnitX upstream: batch 9 (all seven merged 2026-10-31)

Seven issues and their PRs, built and posted 2026-10-31 against `master` @ `c2f8aae` (batch 8 plus #501 and
upstream's own "ignore incomming doc stuff").  Ian: "Prepare and send the unsent ones."  Prompted by Vincent on #398
(2026-10-30): "Yes I would accept a PR for the enum case.  As for holding back fixes because DUnitX's tests rely on a
bug, that would suggest the tests need fixing/replacing."  Issue bodies end "Split out of #398."; PR bodies are
"Fixes #N." plus a short note plus the one-line caveat used since batch 1.  Branches were built in their own
worktrees (since removed), pushed to [`ijbranch/DUnitX`](https://github.com/ijbranch/DUnitX).  Each branch has a
commit with the failing test, then the fix.  "Allow edits by maintainers" is on for every PR.

| # | Report item | Issue | PR | Branch | Head | Merged |
|---|---|---|---|---|---|---|
| 1 | `--run` trailing comma kept (changes `SingleName` / `TwoNames` expectations) | [#502](https://github.com/VSoftTechnologies/DUnitX/issues/502) | [#503](https://github.com/VSoftTechnologies/DUnitX/pull/503) | `fix/run-trailing-comma` | `841ca79` | 2026-10-31 `4c08da8` |
| 2 | `--run` drops a one-character last name | [#504](https://github.com/VSoftTechnologies/DUnitX/issues/504) | [#505](https://github.com/VSoftTechnologies/DUnitX/pull/505) | `fix/run-last-char-name` | `c7f359a` | 2026-10-31 `0f1dcb2` |
| 3 | Nested options file resolved against the current directory | [#506](https://github.com/VSoftTechnologies/DUnitX/issues/506) | [#507](https://github.com/VSoftTechnologies/DUnitX/pull/507) | `fix/nested-options-file-path` | `f8cb12d` | 2026-10-31 `a88a849` |
| 4 | Unclosed `(` in `--include` / `--exclude` accepted | [#508](https://github.com/VSoftTechnologies/DUnitX/issues/508) | [#509](https://github.com/VSoftTechnologies/DUnitX/pull/509) | `fix/filter-unclosed-paren` | `f924ddc` | 2026-10-31 `4e91891` |
| 5 | Text logger issue list loses names with `=` and empty messages | [#510](https://github.com/VSoftTechnologies/DUnitX/issues/510) | [#511](https://github.com/VSoftTechnologies/DUnitX/pull/511) | `fix/textlogger-issue-list` | `9e96c74` | 2026-10-31 `759e77a` |
| 6 | Test error runs result and exception messages together | [#512](https://github.com/VSoftTechnologies/DUnitX/issues/512) | [#513](https://github.com/VSoftTechnologies/DUnitX/pull/513) | `fix/error-message-separator` | `188ec6b` | 2026-10-31 `c3d4347` |
| 7 | `ETestFailureStrCompare` descendant not comparable | [#514](https://github.com/VSoftTechnologies/DUnitX/issues/514) | [#515](https://github.com/VSoftTechnologies/DUnitX/pull/515) | `fix/strcompare-descendant` | `7db9be8` | 2026-10-31 `4b252f0` |

**Outcome (2026-10-31):** Vincent merged all seven the same day, 20:22 to 20:29 UTC, each squashed onto `master`, which is now @ `a88a849`; the seven issues are closed as completed.  PhilBarwood's enum-only 1.6 PR, [#517](https://github.com/VSoftTechnologies/DUnitX/pull/517) (issue #516), was merged just before them as `942958e`, so the rest of 1.6, held back for it, can now be built on it.  On 2026-10-31 (Ian: "Yes", to deleting the merged branches) all seven branches were deleted from the fork and locally, after checking each PR's `merged_at` and that each branch tip still equalled its PR's head.  The fork has since been renamed `ijbranch/gllDUnitX` and holds this repository (see `Help.md`); GitHub redirects the `ijbranch/DUnitX` links above.

## How this batch was built

- **Chosen:** the five "plain defects" of the 2026-10-15 summary on #398, plus the `--run` trailing comma, which
  Vincent's reply unblocked.  The summary's third defect line (test error message; descendant comparability) went as
  two PRs: independent one-line changes in `TDUnitXTestError.Create`.
- **Held back: the rest of 1.6** (too few `[TestCase]` values, the comma separator, the date locale).  PhilBarwood
  offered an enum-only 1.6 PR, which Vincent accepted; both changes need `TDUnitXTestCase.Create` to raise on a
  failed conversion, so ours goes after Phil's PR is in, built on it.
- **Not sent, still waiting on Vincent's choice:** section 2 of the summary (behaviour changes other than the
  trailing comma), section 3 (the `[MaxTime]` design question), sections 4 and 5.
- **Found on the way (#503):** `[TestCase]` splits its value at commas, so upstream's `SingleName2` and `SingleName4`
  never passed a trailing comma to the parser; they now use a `|` separator.  `SingleName6` to `8` have commas inside
  their values too and may not test what they claim; mentioned in the PR, left alone.
- **#513 is low value:** upstream's runner always passes the exception's message, so the run-together text appears
  only for code that creates a `TDUnitXTestError` itself.  The issue says so and invites closing it.
- **`uses`:** #509, #511, #513 and #515 add implementation-section `uses` lines to test units (a qualified name
  still needs the unit); no existing `uses` line changed.
- **Checks:** each branch red on its own assertion on `master` + test commit, green after the fix.  `git merge-tree`
  clean for every pair within each group; all seven merged onto `c2f8aae` with no conflict, built Win64 Debug (only
  upstream's own H2675 DelphiMocks DPM path and W1000 `CheckEqualsString`) and ran: 376 pass, 9 ignored, 1 error
  (`ExampleFixture1.TestMaxTime`, the known Win64 `[MaxTime]` AV), the baseline plus the seven new tests.  Build
  output was redirected per worktree (`DCC_DcuOutput` / `DCC_ExeOutput`), so nothing was written to the Public
  `Studio\37.0` `dcu` / `bin` folders.  Each group's diffs had a fresh-subagent review: #507 / #509 returned five
  low findings, all declined (e.g. `/x.txt` counts as relative; `()` is now an error, said in #509); the others none.
- **A self-including options file** still recurses without limit, as before (summary section 5).

Announced on #398 the same day ([comment](https://github.com/VSoftTechnologies/DUnitX/issues/398#issuecomment-6531715361)), saying the rest of 1.6 follows Phil's PR.  Ian: "Post a comment to Vincent as you suggest."

Caveat line on every PR: "Tested with Delphi 13 only, Win64 Debug; not built for Win32, older compilers or
non-Windows targets."
