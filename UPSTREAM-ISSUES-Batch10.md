# DUnitX upstream: batch 10 (posted 2026-10-31; the date PR held back)

The rest of report item 1.6, "bad `[TestCase]` data silently converted", built 2026-10-31 on `master` @ `a88a849`, which includes PhilBarwood's [#517](https://github.com/VSoftTechnologies/DUnitX/pull/517) (`942958e`): a failed conversion is stored in `TDUnitXTestCase.FArgsError` and raised as `ETestFrameworkException` when the case runs, so only that case errors.  Every PR here feeds that mechanism.  Vincent's rule (#398, 2026-10-30) applies: where DUnitX's own tests relied on a bug, they are fixed in the same PR.

**Posted 2026-10-31** (Ian: "Yes", to posting all but the date PR): five issues and four PRs, one defect each, on `master` @ `a88a849` (re-fetched just before posting).  #1 is an issue only, a question for Vincent; #6 (`WillNotRaise`) is not part of 1.6 and is framed as a question with its PR ready.  The four PR branches were pushed to [`ijbranch/gllDUnitX`](https://github.com/ijbranch/gllDUnitX) (this repository, the renamed PR fork); each is a commit with the tests, then the fix; "Allow edits by maintainers" is on for every PR, and GitHub showed all four as clean merges.  PR bodies are the texts below with "Fixes #?" filled in and the caveat line "Tested with Delphi 13 only, Win64 and Win32 Debug; not built with older compilers or for non-Windows targets."  **#3, the date PR, is held back**: the final review found a regression (see *How this batch was built*), so it was not posted.  Announced on #398 the same day ([comment](https://github.com/VSoftTechnologies/DUnitX/issues/398#issuecomment-6535320221); Ian asked), saying the date part follows separately.

| # | Defect | Issue | PR | Branch | Test commit | Head |
|---|---|---|---|---|---|---|
| 1 | Too few values run with default values (issue only, no PR) | [#518](https://github.com/VSoftTechnologies/DUnitX/issues/518) | - | `fix/testcase-too-few-values` (kept, not pushed) | `19d4a10` | `a23d523` |
| 2 | Separator inside a value: extra values dropped | [#519](https://github.com/VSoftTechnologies/DUnitX/issues/519) | [#520](https://github.com/VSoftTechnologies/DUnitX/pull/520) | `fix/testcase-separator` | `eaddd2e` | `e916de6` |
| 3 | Dates depend on the locale, can be misread, and an unparseable date becomes 30/12/1899 | HELD | HELD | `fix/testcase-date-locale` (not pushed) | `6244257` | `ff04608` |
| 4 | Unparseable integer becomes 0; out-of-range is truncated | [#521](https://github.com/VSoftTechnologies/DUnitX/issues/521) | [#522](https://github.com/VSoftTechnologies/DUnitX/pull/522) | `fix/testcase-integer-parse` | `4af35be` | `60aa85d` |
| 5 | Unparseable float becomes 0 | [#523](https://github.com/VSoftTechnologies/DUnitX/issues/523) | [#524](https://github.com/VSoftTechnologies/DUnitX/pull/524) | `fix/testcase-float-parse` | `5863589` | `08c7d94` |
| 6 | `WillNotRaise` swallows an exception of another class | [#525](https://github.com/VSoftTechnologies/DUnitX/issues/525) | [#526](https://github.com/VSoftTechnologies/DUnitX/pull/526) | `fix/willnotraise-other-exception` | `2994fde` | `72e9e7e` |

## 1. Too few values (issue only)

**Issue:** A [TestCase] with fewer values than parameters runs with default values: should it error?

A `[TestCase]` with fewer values than the method has parameters still runs.  Each missing parameter gets an empty value (0, '', False or the first enum value), so a forgotten value runs with data nobody wrote and the test can pass.

    [TestCase('Missing', '1')]
    procedure Add(const a, b : Integer);   // runs with b = 0

But a trailing parameter with a default value is a legitimate pattern, and RTTI cannot see default values, so DUnitX cannot tell a forgotten value from one left to its default.  DUnitX's own suite has 14 such cases, all in `DUnitX.Tests.Assert`: three `NoDiff_Throws_No_Exception_When_Strings_Are_Equal` cases leave out the default `AIgnoreCase`, and eleven `NoDiff_Throws_ETestFailure_When_Strings_Are_NotEqual` cases give three values for four parameters, leaving out the default `AMessage`.  Making too few values an error would break every suite that relies on this.

Options, for you to choose:

1. Error the case (a breaking change: such suites would have to write every value).
2. Error the case unless it opts in, for example with an attribute or a `TestCaseAttribute` constructor flag that allows defaults.
3. Leave it as it is, and document that missing values take the type's empty value, not the parameter's default.

We have a branch ready for option 1 (the check in `TDUnitXTestCase.Create`, using the #517 mechanism, with the 14 upstream cases given their values explicitly), and can adapt it to option 2 if you prefer.

Split out of #398.

## 2. The separator inside a value

**Issue:** A [TestCase] value containing the separator is split, and the extra values are dropped

`[TestCase]` splits its values at the separator (',' by default), even inside a value.  The surplus values are silently dropped, so the test runs with a truncated value.  A case on a method with no parameters ignores its values the same way.

    [TestCase('Thousand', '1,000')]
    procedure Check(const text : string);   // runs with text = '1'

Expected: a `[TestCase]` with more values than parameters errors the case and points at the separator.  `[TestCase('Thousand', '1,000', '|')]` keeps the comma.

Split out of #398.

**PR:** Error a [TestCase] with more values than parameters

Fixes #?.  When `TDUnitXFixtureProvider.GenerateTests` adds a case from a `TestCaseAttribute` (including its descendants, such as `AutoNameTestCaseAttribute`) with more values than the method has parameters, it sets the case's error through a new read-write property, `TDUnitXTestCase.ArgsError`: "Too many values: 2 values for 1 parameter (does a value contain the separator?)".  Only that case errors when it runs (the #517 mechanism).  A trailing separator counts too: '1,2,' for two parameters is three values, and now errors.

The property is set after `AddTestCase`, where #517 has already recorded any conversion failure, so for such a case the too-many message replaces #517's conversion message: the extra value is the root cause, and a conversion failure usually follows from it.

Other sources are unaffected: `[TestCaseProvider]` / `ITestDataProvider` data, `TestCaseSource` data, and direct `CustomTestCaseAttribute` descendants other than `TestCaseAttribute` may still supply more values than a method takes, and `TDUnitXTestCase.Create` still keeps only as many as there are parameters.  A new test proves that a provider case and a source case with extra values still run.

Upstream tests changed because they relied on the bug: `SingleName6`, `SingleName7` and `SingleName8` in `DUnitX.Tests.TestNameParser` have commas inside their values (mentioned in #503), so the parser only ever saw the part before the first comma.  They now use a `|` separator.

Tested with Delphi 13 only, Win64 Debug, and Win32 Debug merged with the rest of the batch; not built with older compilers or for non-Windows targets.

## 3. Dates

**HELD, not posted.**  The final review (2026-10-31) found that the ISO 8601 step takes anything starting with a four-digit year and '-' and reads it loosely: the Korean `DateTimeToStr` output '2020-06-22 오후 6:36:00' (오후 = PM) reads as 06:36 instead of 18:36 (`a88a849` reads it correctly; dz-BT the same), and '2020-06-22 foo 18:36' is accepted.  The guarantee below that what the locale writes reads back is also untrue for day-first dates with a day of 12 or less (refused by design) and for two-digit-year locales.  To do: read ISO 8601 strictly (only its real forms), restate the guarantee, and review again.

**Issue:** [TestCase] dates depend on the machine's locale, can be misread, and one that does not parse becomes 30/12/1899

A `TDate`, `TDateTime` or `TTime` value is read in the machine's locale first, then as ISO 8601.  '01/02/2020' is 2 January on a US machine and 1 February on a UK one, and on a German machine it parses in neither, so it silently becomes 0: 30/12/1899 (or midnight, for a time).  The same happens to any value that parses in no format.

    [TestCase('Date', 'notadate')]
    procedure Check(const value : TDate);   // runs with 30/12/1899

A `TDateTime` can also be misread outright: on a Japanese or Chinese machine (year first), '22/06/2020' and '22/06/2020 10:30' become 20 June 2022 at 20:00, the last digits of the year taken for an hour; '22-06-2020' does the same on a Swedish machine, and '1-2-2020' becomes 20 February 2001 at 20:00.

Expected: a value that the machine's formats read differently, or misread, errors the case, instead of running with a date nobody wrote.

Split out of #398.

**PR:** Read a [TestCase] date only when its meaning is unambiguous, and error one that is not

Fixes #?.  #261 (2017) added ISO 8601 as a fallback after the locale so that test data reads the same on different machines, and #192 asked for the same; this goes further for the same reason.  `Str2DateValue` and `Str2DateTimeValue` now read:

1. ISO 8601 first, but only with a four-digit year ('2020-06-22', '2020-06-22T18:36:00.000Z', the time zone stripped as before).  '22-06-20' is no longer taken for ISO 8601, so it cannot become 20 June 2022 on a machine whose locale cannot read it.
2. Otherwise, with both `TFormatSettings.Invariant` and the locale.  If only one reads the value, or both read the same date, that date is used.  If they read different dates, the value is ambiguous and the case errors: '01/02/2020' errors on a UK machine and reads as 2 January on a US one.  For a `TDateTime`, a reading counts only when the text is a date, a time, or a date, a space and a time that read the same value on their own, so a year is never taken for an hour.
3. A value that neither reads errors the case, instead of becoming 30/12/1899.

`Str2TimeValue` applies the same rule with the invariant format and the locale (an ISO 8601 time reads the same in the invariant format), so '10.30' still reads in a Finnish locale.  The functions return False instead of a value, and `ConvStr2Float` passes that on (the #517 mechanism).

What is guaranteed: a four-digit-year ISO 8601 date reads the same on every machine; on any one machine, a value that the invariant format and the locale read as different dates is refused; and what the locale itself writes (`DateTimeToStr`, `DateToStr`, `TimeToStr`) reads back as the same value.  A value that only one format reads is still read by that one, so a value with a two-digit year can still mean different things on different machines: '20-06-22' as a `TDate` is 20 June 2022 on a Dutch machine and 22 June 2020 on a Swedish one.  Test data should use four-digit years, and ISO 8601 where it can.

What changes for existing data: a date that only the locale reads ('22/06/2020' on a UK machine, '22.06.2020' on a German one) reads as before; one that the locale and the invariant format read as different dates now errors; one that only the invariant format reads ('01/02/2020' on a German machine) is now 2 January instead of 30/12/1899; a `TDateTime` whose year was taken for an hour now errors; and a dash date with a two-digit year that the locale cannot read ('20-06-22' on a US machine) now errors instead of being taken for ISO 8601.  No upstream test changed; the existing EN-US, EN-GB and DE date, time and date-time cases all still pass.

Tested with Delphi 13 only, Win64 Debug and Win32 Debug, on its own and merged with the rest of the batch; not built with older compilers or for non-Windows targets.

## 4. Integers

**Issue:** A [TestCase] integer that does not parse becomes 0, and one too big for its type is truncated

'abc' for an `Integer` parameter runs with 0.  '300' for a `Byte` runs with 44, because `TValue.FromOrdinal` truncates, and '-1' for a `Cardinal` wraps.  (Colour types are parsed separately and keep their behaviour; see the PR.)  An unknown colour name for a `TColor` raises `EConvertError` from inside the conversion instead of giving a conversion failure.

    [TestCase('TooBig', '300')]
    procedure Check(const value : Byte);   // runs with 44

Expected: the case errors.

Split out of #398.

**PR:** Error a [TestCase] integer that does not parse or does not fit its type, reading hex as a bit pattern

Fixes #?.  `ConvStr2Int` parses with `TryStrToInt64` and checks the value against the type's range (unsigned for `otULong`) before `FromOrdinal`; it returns False otherwise, so the case errors (the #517 mechanism).

A decimal value is strictly range-checked: '300' for a `Byte`, '-1' for a `Cardinal` and '2147483648' for an `Integer` error.  A hex value ('$', '0x' or 'x' prefix, after an optional leading space or '+', as `StrToInt64` accepts) that fits the type's unsigned width is read as its bit pattern, as it is in code: '$FFFFFFFF' is the `Integer` -1 and '$FF' the `ShortInt` -1, while '$100' for a `Byte` errors.  The bit-pattern rule applies only to a type that covers its whole width: in a subrange such as -10..10, '$FF' is 255 and errors, and '$A' is 10.

Colour types keep their existing parsing: `TColor` and `TAlphaColor` values still go through `StringToColor` / `StringToAlphaColor`, which wrap to 32 bits, so they are not range-checked ('-1' for a `TAlphaColor` is still accepted, as `$FFFFFFFF`).  The only change for them is that an unknown colour name gives a failed conversion instead of raising `EConvertError` from inside it.

No upstream test changed; the `TColor` and `TAlphaColor` cases still pass.  `Int64` and `UInt64` parameters go through `ConvStr2Ord`, which is not changed here.

Tested with Delphi 13 only, Win64 Debug, and Win32 Debug merged with the rest of the batch; not built with older compilers or for non-Windows targets.

## 5. Floats

**Issue:** A [TestCase] float that does not parse becomes 0

'abc' or '1.5x' for a `Double` parameter runs with 0, because `ConvStr2Float` uses `StrToFloatDef(..., 0, ...)`.  The `TFormatSettings` it passes is an uninitialised local with only `DecimalSeparator` set.

    [TestCase('Typo', '1.5x')]
    procedure Check(const value : Double);   // runs with 0

Expected: the case errors.

Split out of #398.

**PR:** Error a [TestCase] float that does not parse, reading it with the invariant format

Fixes #?.  `ConvStr2Float` parses with `TryStrToFloat` and `TFormatSettings.Invariant`, and returns False when the value does not parse, so the case errors (the #517 mechanism).  The uninitialised local is gone.  No upstream test changed.

Out-of-range values are not caught ('1e39' for a `Single` becomes INF, and a `Currency` overflow wraps); that is out of scope here.

Tested with Delphi 13 only, Win64 Debug, and Win32 Debug merged with the rest of the batch; not built with older compilers or for non-Windows targets.

## Considered and not sent

- **Thousands separator** (`fix/testcase-thousands-comma`, kept locally): `ConvStr2Float` turns every comma into a point, so '1,000' reads as 1.0.  Refusing a comma followed by exactly three digits would also refuse correct decimal-comma data such as '3,142', which DUnitX has accepted since #108, so it was dropped.

## Re-validation

- `upstream/master` was still `a88a849` at 2026-10-31 08:53 +11.
- GitHub search, 20 queries (`TestCase` with date, locale, integer, float, convert, parameters, separator and comma; "too few", "too many values", `StrToFloatDef`, `StrToInt64Def`, `ConvStr2Float`, `ConvStr2Int`, `TryConvert`, `Str2DateTimeValue`, "decimal comma", "thousands", `FormatSettings`, "TestCase default value"), found no duplicate.  Related: #261 and #192 (ISO 8601 dates), #108 (the decimal comma for floats), #332 (`UInt64`, not addressed here).  The only open PR is #377, which is unrelated.
- A standalone probe (about 165 conversions, Win32 and Win64, five locales, against the `a88a849` sources) reproduced each defect.

## How this batch was built

- **Review rounds (2026-10-31):** too few values became an issue only (default parameters are invisible to RTTI, so the PR would be a breaking change); the separator check moved from `TDUnitXTestCase.Create` to the `[TestCase]` path of `GenerateTests`, so providers and sources keep their deliberate truncation; the date rule was rewritten (the earlier draft read the invariant format before the locale, so '01/02/2020' silently changed meaning on a UK machine, and its ISO 8601 step read '22-06-20' as 2022), and a second review added the `TDateTime` check against a year read as an hour; integers gained the hex rule, then hex after a space or '+', and the full-width condition for subranges; the thousands-separator PR was dropped.  The separator, date and integer branches were rebuilt as two new commits each.
- **Tests:** #2 is beside #517's test in `DUnitX.Tests.TestDataProvider` (generated with `GenerateTests`, as #517 does), and #3 to #5 test `TValue.TryConvert` in `DUnitX.Tests.Utils`, each at its own place in `TValueHelperTests`.  The date tests switch the locale with the fixture's existing `setFormatSettings`, whose Delphi 2010 branch gained the LCIDs of the new locales (nl-NL, fi-FI, ja-JP, zh-CN, sv-SE).  No `uses` line changed in the tests; `DUnitX.FixtureProvider` now uses `DUnitX.Test`.
- **Merging:** #3 and #4 both change `DUnitX.Utils` and `DUnitX.Tests.Utils`, and #3 and #5 both touch `ConvStr2Float`, on separate lines.  `git merge-tree` is clean for all 10 pairs of #2 to #6, so they can be merged in any order.
- **Red and green:** each branch has at least one test that fails on `a88a849` on its own assertion, and all its tests pass with the fix.  #2: the too-many test ("Method did not throw any exceptions.").  #3: 10 of its 30 cases ("Condition is True when False expected" for '01/02/2020' on EN-GB, '22/06/2020' on ja-JP and zh-CN, '22-06-2020' and '1-2-2020' on sv-SE, and 'notadate'; '01/02/2020' on DE read as 30/12/1899).  #4: 'abc' converted to `Integer` (the same test also asserts that '$FF' is refused for a -10..10 subrange).  #5: 'abc' converted to `Double`.  The other new tests pass on `a88a849` by design; they guard against a wrong fix:
  - #2, the provider and source test: against checking the count in `TDUnitXTestCase.Create`, which errors provider and source cases (the first draft).
  - #3, the EN-US '01/02/2020' cases: against refusing every value that both formats read.  The locale-only cases (EN-GB '22/06/2020', DE '22.06.2020', nl-NL '22-06-20', fi-FI '10.30') and the eight locale round trips: against dropping or over-tightening the locale read (the round trips also caught a Win32-only precision failure in the date-and-time check before it was committed).  nl-NL '22-06-20': against reading ISO 8601 first with a two-digit year (the second draft read it as 2022).  The ISO cases: against losing the ISO 8601 step.
  - #4, the hex test: against a strictly range-checked fix that refuses '$FFFFFFFF' for an `Integer` (the first draft), and against hex detection on the raw text (' $FFFFFFFF', '+$FFFFFFFF').
- **Combined:** the four merged onto `a88a849` built Win64 Debug (only upstream's own H2675 DelphiMocks DPM path and W1000 `CheckEqualsString`) and ran 412 pass, 9 ignored, 1 error (`ExampleFixture1.TestMaxTime`, the known Win64 `[MaxTime]` AV): the `a88a849` baseline (377 / 9 / 1) plus 35 new passing tests, with no other test changing result.  The same tree built Win32 Debug with dcc32 (the same two warnings only) and ran 411 pass, 9 ignored, 0 errors (the two `NativeInt` tests are Win64 only, and `TestMaxTime` passes on Win32).  Build output went to `D:\gllDUnitX-up-16-out` and `D:\gllDUnitX-up-16-out32`.
- **Final review (2026-10-31), all five branches:** `upstream/master` still `a88a849`.  All five merged built and ran Win64 413 pass, 9 ignored, 1 error and Win32 412 pass, 9 ignored, 0 errors: the baseline (Win64 377 / 9 / 1, Win32 376 / 9 / 0) plus 36 new passing tests, nothing else changed.  A round trip through all 248 Windows locales found the Korean date regression that held #3 back.  `WillNotRaise` re-raises the same exception object at the same address, keeps `Assert.Pass` / `Assert.Fail` inside the method working, and leaks nothing over 40,000 propagations.
- **As posted, without #3:** #2, #4, #5 and #6 merged onto `a88a849` (`7d13ec0`, a throwaway commit) built Win64 Debug (upstream's own H2675 and W1000 only) and ran 383 pass, 9 ignored, 1 error (`TestMaxTime`): the baseline plus the 6 new tests of those four branches.
- **Not in this batch:** `ConvStr2Ord` still converts 'abc' to 0 for `Int64` and `UInt64`, and for `NativeInt` on Win64.

## 6. WillNotRaise swallows an exception of another class

Posted as issue [#525](https://github.com/VSoftTechnologies/DUnitX/issues/525) and PR [#526](https://github.com/VSoftTechnologies/DUnitX/pull/526).  Branch `fix/willnotraise-other-exception` (`2994fde` test, `72e9e7e` fix, on `a88a849`).  Ian: "PR - Yes", 2026-10-31.

**Issue:** Should `Assert.WillNotRaise` hide an exception of a class it was not asked about?

With a class given, `WillNotRaise`, `WillNotRaiseDescendant` and `WillNotRaiseWithMessage` catch every exception, fail only on the one named, and silently discard the rest, so the assertion passes.

    Assert.WillNotRaise(procedure begin raise EAccessViolation.Create('boom'); end, EStreamError);   // passes

The same happens to a descendant of the class named for `WillNotRaise` (it matches exactly), and to `WillNotRaiseWithMessage` when the class or the message does not match.  Several of DUnitX's own tests assert this, so it may be deliberate.  We think an exception the assertion was not asked about should propagate, so the test reports an error instead of passing.  A PR is ready if you agree.

Split out of #398.

**PR:** Let WillNotRaise propagate an exception it was not asked about

Fixes #?.  In `WillNotRaise`, `WillNotRaiseDescendant` and `WillNotRaiseWithMessage` (the `TTestMethod` overloads delegate to them), an exception that does not match is re-raised; one that matches still fails the assertion, and a nil class still means any exception.  `WillNotRaiseAny` is unchanged.

Seven upstream tests asserted the swallowing, and now assert that the exception propagates, with its class and message: `WillNotRaise_With_ExactClass_Positive`, `WillNotRaise_With_DescendingClass_Positive`, and five `WillNotRaiseWithMessage_*_WillNotRaise` tests (nil class with another message, matching class with another message, and the three with a non-matching class).  Their names are kept.  One new test, `WillNotRaise_Method_With_Class_Lets_Another_Exception_Propagate`, covers the `TTestMethod` overload with a descendant of the class named.

Tested with Delphi 13 only, Win64 Debug; not built for Win32, older compilers or non-Windows targets.
