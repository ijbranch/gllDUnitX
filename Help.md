# gllDUnitX — Help & Reference

Reference documentation for gllDUnitX, GITLAK's fork of the DUnitX test framework (Delphi 13 / RAD Studio 37.0, VCL, Win32 + Win64). Every unit-test suite in this estate runs on DUnitX, so what this file records about assertion defaults and fixture discovery decides whether those suites can fail at all. Task-oriented walkthroughs are in [Users Guide](Users%20Guide.md); installation, upstream tracking and the Delphi.Mocks pin in `README.md` and `DEPENDENCIES.md`; the change record — including what was refused from upstream and why — in `CHANGELOG.md`.

---

## 1. Scope of this fork

Upstream is [VSoftTechnologies/DUnitX](https://github.com/VSoftTechnologies/DUnitX), wired up as the `upstream` remote and genuinely merged, so `git merge-base` works here.

**Taken away, permanently.** These are not disabled, they are deleted, and a merge that reinstates them is a regression:

| Removed | Detail |
|---|---|
| Every RAD Studio before Delphi 13 | Fourteen package folders under `packages\`, and all non-D13 test, example and IDE-expert projects |
| Non-Windows platforms | `DUnitX.Linux.Console.pas`, `DUnitX.MacOS.Console.pas`, `DUnitX.Loggers.Console.FMX.pas`, `DUNitX.Loggers.MobileGUI.*`; `DUnitX.AutoDetect.Console` now simply uses `DUnitX.Windows.Console` (it has no platform guard: on another platform the Windows unit itself fails to compile) |
| FireMonkey | `DUNitX.Loggers.GUIX.pas` and its `.fmx`, whose only consumers were the deleted FMX GUI projects |
| C++Builder output | `DCC_CBuilderOutput` is `None` on every project |

**Added here and nowhere upstream.** `Assert.Ignore( reason )` — a **run-time** test skip, reported as *ignored* rather than passed. Upstream has only the compile-time `[Ignore]` attribute. Almost all the plumbing was already upstream and dormant (`ETestIgnored`, `TTestResultType.Ignored`, `IgnoredCount`, `OnTestIgnored`, and the runner's own `on e : ETestIgnored` handler); what was missing was anything that raised it. A proposal carrying the diff and the mutation evidence went to the maintainers on 2026-09-09.

This is **fork-local divergence that will conflict** on any future merge touching `DUnitX.Assert.pas`, `DUnitX.Init.pas`, `DUnitX.TestFramework.pas` or `DUnitX.TestRunner.pas`. It is also the sharpest tell for §3 below: code calling `Assert.Ignore` does not compile against any other DUnitX.

**Fixed here, against upstream.** Each of these is a behaviour difference a merge must not undo:

| Fix | What it was |
|---|---|
| `[MaxTime]` | The watchdog suspended the test thread and rewrote its instruction pointer (`Ctx.Rip := Cardinal(@RaiseTimeOutException)`) — a 32-bit truncation of a 64-bit code address, always unmapped on Delphi 13, so the thread faulted on resume. Elapsed time is now **observed and reported after the test method returns** |
| `TWeakReference<T>.Destroy` | Abandoned `RemoveWeakRef` when it could not take the lock but nilled its field anyway, leaving the target writing through a pointer into memory about to be freed |
| `TTestFixtureList.Sort` | Freed a `TDelegatedComparer` that had been implicitly converted to a ref-counted `IComparer` |
| `TRttiPropertyExtension` | Freed its patched virtual method tables before the instances dispatching through them |
| `TDUnitXServiceLocator` | Leaked the constructed object whenever `Supports` failed — silent by default |
| `TValueHelper.IsUInt64` | Tested `NativeInt`, the signed type `IsInt64` already used |
| FastMM4 leak monitor | Multiplied in 32 bits and cast the overflowed product to `Int64` afterwards; also read the RTL's bundled FastMM rather than an installed `FastMM4.pas` |
| `DUnitX.Loggers.GUI.VCL.pas` | `System.Actions` listed twice — `E2004 Identifier redeclared`. The file's own comment warns that the IDE re-adds it; check that trailing line before committing this unit |

**Deliberately NOT taken from upstream.** `upstream/dev` has never been merged into `master` and its tip is fifteen months *older*. All four of its commits are refused; one is dangerous rather than merely unwanted:

- `01b2dc5` removes the first parameter of `TestCaseAttribute.Create`. Every `[TestCase('Name','a,b')]` in the estate would still **compile** and silently mean something else — the name becomes the value and the values become the separator. It also rewrites `GenerateTests` in `DUnitX.FixtureProvider.pas`, including the `FFixtureClasses.ContainsKey` de-duplication that lets RTTI discovery and explicit registration coexist (§3).
- `055e7a8`, `7350c5d`, `f40670c` — parallel fixture running and its riders, against runner and logger units `master` has since changed.

**Deliberately NOT changed.** The assertion defaults in §3 are upstream's, not ours, and they are left alone. `fIgnoreCaseDefault := True` dates from upstream's 2020 repo re-org, and `WillNotRaise`'s exact-class test is upstream's too. They are not "fixed" here because a suite opts out of them in one line in its own runner, and changing them globally would turn currently-green suites across the estate red in a single commit — a decision to take on purpose, not a side effect of a documentation pass.

**Other fork facts.** The DPM package id is `GITLAK.DUnitX`, not `VSoft.DUnitX`, so this fork cannot shadow upstream in a package feed. The test project consumes Delphi.Mocks from a sibling `glldelphi-mocks` source checkout pinned by commit in `DEPENDENCIES.md`, not from DPM.

---

## 2. Which DUnitX are you actually compiling against?

RAD Studio 13 ships its own DUnitX, as compiled DCUs in `lib\win64\release` (59 of them), and the two differ:

- **`Assert.Ignore` does not exist in the bundled copy.** Compiling against it alone gives `E2003 Undeclared identifier: 'Ignore'`. The symbols `TestIgnored`/`fTestIgnored` appear in this fork's compiled `DUnitX.Assert.dcu` and in the bundled one they do not — which makes them a reliable way to tell the two apart.
- None of §1's fixes are in the bundled copy, `[MaxTime]` included.

**The library path looks as though the bundled copy should win, and it does not.** On this machine `$(BDSLIB)\$(Platform)\release` sits at index 4 of the Win64 library path while `$(DUNITX)` (`D:\gllDUnitX\Source`) sits at index 14 — so path order alone predicts Embarcadero's copy. **Measured on 2026-09-18, that prediction is wrong.** Test executables built by the normal pipeline all carry the fork-only symbol:

| test executable | links |
|---|---|
| `gllStaticCodeAnalyser` `TestProject.exe` | this fork |
| `gllDelphiRefactoringLight` tests | this fork |
| `gllMarkDown4D` tests (repo retired 2026-10-01) | this fork |

The last of those was rebuilt from scratch with no stray `.dcu` anywhere in `Source`, and still linked this fork. The likely mechanism: the compiler looks in the project's own DCU output folder before the library path, and once a project had compiled this fork from `Source`, its own copies of the fork's DCUs won from then on.

**Since 2026-10-12 the arrangement is explicit, and the paragraph above is history.** On both platforms the package's Release DCU folder (`$(GLLDUNITX_RAD_STUDIO_13_0_WI)\Release`, `..._WI_2\Release` for Win32) is the **first** Search Path entry, ahead of `$(BDSLIB)`, and `Source` (`$(DUNITX)`) is on **neither** platform's Search Path. Win32 was already that way (see `standards\ide-environment.md`); Win64 had `$(DUNITX)` instead, and removing it alone exposed the bundled copy (`E2003 'Ignore'` in GITLAKLib's tests). The 3,486 copies of the fork's DCUs left in 79 consumer output folders by the old arrangement were deleted the same day, so every consumer now links the package's DCUs and never compiles DUnitX itself. The Debug DCU Path already listed the package's Debug folder first. Backups of the two registry keys and of `EnvOptions.proj` are in that session's scratchpad.

**How to check any binary rather than assume:** `grep -a TestIgnored <test>.exe`. A hit means this fork; nothing means the bundled copy.

**`D:\gllDUnitX` is the only DUnitX on C:, D: and E:** (Ian, 2026-10-12). On that day RAD Studio's bundled DUnitX (67 files under `Studio\37.0\lib`) was moved to `%PUBLIC%\Documents\Embarcadero\Studio\37.0\_bundled_DUnitX_removed_2026-10-12`. The other copies were deleted:

- a full upstream clone that a TMS tool's test run had left in `gllTMSSmartSetup\tmstest\tmp-run`;
- a GetIt temp extraction;
- a vendored FMX unit in `OmniThreadLibrary-NG`;
- an orphan `VSoft.DUnitXWinR170.bpl`;
- every leftover fork DCU in consumer and archive folders.

`D:\Tools\Check-DUnitXSingleSet.ps1` enforces the rule and exits 1 on any DUnitX source, bundled `lib` file or foreign DUnitX package outside this repo. **Run it after every RAD Studio update, patch or repair**, which writes the bundled files back into `lib`; move them aside again.

**A project that needs a unit the package does not contain** (`DUnitX.Loggers.GUI.VCL`, `DUnitX.MemoryLeakMonitor.FastMM5`, the `DUnitX.StackTrace.*` units) must name `<repo>\Source` in its own `DCC_UnitSearchPath` and have a platform-varying `DCC_DcuOutput` — read §7 first. It then compiles those units, and the rest of DUnitX, from source. `gllStaticCodeAnalyser`'s test project does this.

---

## 3. Behaviours that will surprise you

Every one of these makes a test *pass* when you expected it to fail, or removes a test without saying so. They are the reason this file exists.

### `Assert.AreEqual( string, string )` ignores case

`Assert.Create` sets `fIgnoreCaseDefault := True`, and the two-argument string overload forwards it. `StartsWith`, `EndsWith`, `Contains`, `DoesNotContain` and `AreNotEqual` take the same default. `NoDiff` is the exception: its form without `ignoreCase` passes `False`, so it is case-sensitive. Nothing at the call site says so, so **a test whose subject is the casing cannot fail** — `ProperCase`, `Initials`, identifier casing in generated SQL, month-name lookups.

```pascal
Assert.AreEqual( 'McDonald', ProperCase( 'mcdonald' ) );          // passes against 'Mcdonald'
Assert.AreEqual( 'McDonald', ProperCase( 'mcdonald' ), False );   // the third argument is ignoreCase
```

Or make the whole suite strict, once, in the runner mainline — `Assert.IgnoreCaseDefault := False` — after which a test that genuinely does not care must pass `True` explicitly.

### `Assert.WillNotRaise( proc, SomeClass )` swallows a descendant

The body tests `if e.ClassType = exceptionClass then Fail` — an `=` on `ClassType`, not `is`. So `Assert.WillNotRaise( proc, Exception, 'msg' )` catches an `EAccessViolation` in its own `except` and then does **nothing**: the test passes while the fault it was written to detect happens on every run.

```pascal
Assert.WillNotRaiseAny( procedure begin DoTheThing; end, 'must not blow up' );
```

`WillNotRaiseAny` is almost always what was meant. Passing **no** class is also safe — that takes the `else` branch and fails on anything. `WillNotRaiseDescendant` exists for the narrower case (both its overloads match descendants since the 2026-10-12 fix; before it, the `TTestMethod` overload matched the exact class only). The whole `WillNotRaise*` family now lets `Assert.Pass`, `Assert.Ignore` and `Assert.Fail` inside the method through as the test's outcome. Before that, `WillNotRaiseAny` reported an inner `Assert.Pass` as "raised ETestPass", and with a named class an inner `Assert.Fail` was swallowed so the test passed.

### `WillRaise` no longer catches DUnitX's own assertion outcomes (fork change, 2026-10-12)

`WillRaise`, `WillRaiseAny`, `WillRaiseDescendant`, `WillRaiseWithMessage` and `WillRaiseWithMessageRegex` used to catch `on E : Exception`, which includes the exceptions DUnitX itself raises for a failed assertion, `Assert.Pass` and `Assert.Ignore`. So `Assert.WillRaiseAny( procedure begin Assert.AreEqual( 1, 2 ) end )` **passed**. They now re-raise `ETestFailure`, `ETestPass` and `ETestIgnored` (anything descending from `Assert.TestFailure` / `TestPass` / `TestIgnored`) unless you asked for one of them. To test that an inner assertion fails, name the class:

```pascal
Assert.WillRaise( procedure begin Assert.AreEqual( 1, 2 ) end, ETestFailure );
```

A suite that relied on the old behaviour (a class-less `WillRaise` around a failing assertion) now fails at that line; that failure is the fix working.

### Smaller `Assert` behaviours worth knowing

- **Integer literals and tolerance.** `Assert.AreEqual( 10, 12, 5 )` resolves to the `Double`-with-tolerance overload and **passes**. Write `Assert.AreEqual<Integer>( 10, 12 )` or use typed variables when you mean an exact integer comparison.
- **Empty substring.** `Contains` / `DoesNotContain( string )` fail on an empty substring, as `StartsWith` / `EndsWith` always did.
- **Tolerance.** A negative tolerance fails the assertion. `AreEqual( Inf, Inf )` passes and `AreEqual( Inf, -Inf )` fails; NaN is never equal to anything, including in the generic `AreEqual<Double>` / `Contains<Double>` overloads.
- **`AreSame` / `AreNotSame( TObject )`** compare references (`=`), not `Equals`.
- **`IsEmpty( Variant )`** passes for Unassigned and Null only; `IsNotEmpty` fails for both.

### Turning RTTI discovery off deletes tests

Fixtures reach the runner two ways: `[TestFixture]` found by RTTI, and `TDUnitX.RegisterTestFixture` called by hand. **Keep both.** They do not double up — `TDUnitXFixtureProvider.GenerateTests` merges the registered fixtures with `if not FFixtureClasses.ContainsKey( pair.Key )`, so a fixture that arrives by both routes is added once.

Setting `Runner.UseRTTI := False` therefore does not prevent a double run; it silently drops every fixture that carries `[TestFixture]` but has no registration call. The run still reports success. The ratio of registration calls to fixtures is the tell — count the test *names* on both sides before touching the flag.

Note the matching requirement on the `.dpr`: `{$STRONGLINKTYPES ON}`, or RTTI discovery cannot see classes nothing references.

### A `published` method with no attributes is a test

After the attribute checks, `GenerateTests` adds any `mvPublished` method as a test. Useful for DUnit compatibility; surprising if you made a helper published.

### Overriding an attributed `[Setup]` method silently does not run it

An `override` does not inherit the attribute. The provider walks up the hierarchy, finds the *ancestor's* attributed method, and binds it with `meth.Code := method.CodeAddress` — a static code address, not a virtual dispatch. Your override never executes. Either re-apply the attribute to the override, or give the override a new name and call the inherited method from it. Same for `[TearDown]`, `[SetupFixture]`, `[TearDownFixture]`.

### Descending one fixture from another re-runs the ancestor's tests

`GetMethods` returns inherited methods, so the descendant runs every ancestor `[Test]` again under its own name — inflating the count and reporting one failure twice. Share *helpers*, not fixture ancestry.

### Collection counts: `Assert.AreEqual( 3, List.Count )` compiles since 2026-10-10

Delphi 13 made `TList<T>.Count` a `NativeInt`, so on Win64 an `Integer` on one side and an `Int64` on the other matched no overload, fell through to `AreEqual<T>`, and generic inference failed with `E2532`. Since 2026-10-10 (upstream `1bdc297`, #397) `Assert.AreEqual( Integer, Int64 )` and `( Int64, Integer )` exist under `{$IFDEF CPU64BITS}`, so the plain form compiles on both platforms. An overload taking `NativeInt` itself still cannot be added (on Win64 it is the same type as `Int64`); the mixed pair is the fix. The older workaround, `Assert.AreEqual<NativeInt>( 3, List.Count )`, still compiles and need not be changed.

### NaN never equals anything — no `IsNan` guard needed

`Assert.AreEqual` on `Double`/`Extended` fails if either value is NaN, whatever the tolerance, and `AreNotEqual` passes. Both go through `System.Math.SameValue`, which returns `False` for NaN on Win32 (x87 `Extended`) and Win64 alike. Proved by six tests in `Tests\DUnitX.Tests.Assert.pas` (2026-10-12); a 2018 fork's extra `IsNan` check was surveyed and is unnecessary. To assert that a result *is* NaN, use `Assert.IsTrue( IsNan( Value ) )` — `AreEqual( NaN, Value )` always fails.

### `[MaxTime]` cannot interrupt a test that never returns

By design here (see §1): it is an assertion about elapsed time, checked once the method returns. Since 2026-10-12 the body is timed by a stopwatch started on the test's own thread immediately before the method, with no watchdog thread, so an overrun of any size is caught (the earlier watchdog polled every 20 ms and could miss one). `[MaxTime]` also applies to `[TestCase]` / `[TestCaseProvider]` cases and to `[WillRaise]` tests, where it used to be dropped.

### Runner behaviours changed on 2026-10-12 (fork fixes, offered upstream in #398)

**Checked against the estate the same day:** all 28 other registered suites, plus GITLAKLib's, were rebuilt against these changes. Every one linked this fork (`grep -a TestIgnored`) and built with no hints or warnings. Only gllTaurusTLS needed changes: seven of its `[TestCase]` values had never converted (a stray space before an enum name, and fields in the wrong order), so those cases had always run with the wrong arguments. They are now errors, and their data was fixed.

- **A run that executes no tests is not a pass.** If the filters match nothing, or every test is ignored, `IRunResults.AllPassed` is `False`, a warning is logged, and a runner that maps `AllPassed` to `EXIT_ERRORS` exits non-zero.
- **`[WillRaise]` works on test cases.** It used to be silently dropped on any method that also had `[TestCase]` or `[TestCaseProvider]`.
- **TearDown is skipped when Setup fails**, as in DUnit and NUnit. When a test fails and its TearDown also fails, the test's failure stays the main message and "TearDown also failed: ..." is appended.
- **A failing `[TearDownFixture]` is one extra error result**, named after the teardown method (`Destroy` when the destructor is the teardown). The fixture's tests are no longer reported a second time.
- **A fixture whose constructor raises errors only its own tests**; the rest of the run continues. Fixtures are still constructed when the fixture list is built, not lazily (see §10).
- **A parameterless constructor still replaces `[SetupFixture]`** (upstream behaviour), but a warning now names the `[SetupFixture]` method that will not run.
- **An unregistered `[TestCaseProvider]` name is an error** for that method instead of producing no tests.
- **`[RepeatTest]` repeats are tests of the fixture itself**, so they get the fixture's Setup/TearDown (including ones declared in a base class) and do not run after a failed `[SetupFixture]`. Their names lost one segment: `Unit.TFixture.Method.Method-1-of-3` is now `Unit.TFixture.Method-1-of-3`. No suite on D: or E: used `[RepeatTest]` when this changed.
- **Memory-leak checks report only real growth.** Negative deltas are no longer "leaks"; the `ETestPass` raised by `Assert.Pass` and the memory kept by `Log` / `Status` calls are not counted.

---

## 4. Public surface

The runtime package is `packages\RAD Studio 13.0\VSoft.DUnitXWinR.dpk` (`requires rtl` only). The units a consumer names:

| Unit | What you take from it |
|---|---|
| `DUnitX.TestFramework` | The one to `use`. Re-exports `Assert`, and declares `TDUnitX`, `ITestRunner`, `IRunResults`, `ITestLogger`, `TDUnitXOptions`, `EXIT_ERRORS`, and re-exports `DUnitX.Attributes` |
| `DUnitX.Init` | Optional on Delphi 13. Its `initialization` wires `Assert.TestFailure`/`TestPass`/`TestIgnored` to the real exception classes and registers the fixture provider, but `DUnitX.TestFramework`'s own `initialization` already does both on every compiler except XE3 (`{$IFNDEF DELPHI_XE3}`), so listing it is harmless and redundant |
| `DUnitX.Loggers.Console` | `TDUnitXConsoleLogger.Create( quietMode : boolean = False )` |
| `DUnitX.Loggers.XML.NUnit` | `TDUnitXXMLNUnitFileLogger.Create( AFilename : string = '' )` — empty means `dunitx-results.xml` beside the exe; a bare file name means the current folder (it raised `EInOutError` before this fork's 2026-09-29 fix, and still does upstream). `TDUnitXXMLNUnitLogger` takes a stream |
| `DUnitX.Loggers.XML.JUnit` | `TDUnitXXMLJUnitFileLogger` / `TDUnitXXMLJUnitLogger`, same shape |
| `DUnitX.Loggers.XML.xUnit` | **Empty** — an upstream placeholder with no declarations; there is no xUnit logger |
| `DUnitX.Loggers.Text` | `TDunitXTextFileLogger.Create( fileName, overwrite, encoding )` |
| `DUnitX.Loggers.Null` | `TDUnitXNullLogger` — a do-nothing `ITestLogger`; the text, NUnit and JUnit loggers descend from it (the console logger implements `ITestLogger` directly). Descend from it to implement your own |
| `DUnitX.DUnitCompatibility` | `TTestCase` with the whole `Check*` family (all marked `deprecated`) — see the guide's conversion section |
| `DUnitX.Assert.Ex` | `Assert.AreEqual( expected, actual, compformat )` for CSV/XML comparable formats; raises `ETestFailureStrCompare` |
| `DUnitX.TestDataProvider` | `TTestDataProviderBase` + `TestDataProviderManager.RegisterProvider` for `[TestCaseProvider]` (see `TestCaseProvider.md`) |
| `DUnitX.MemoryLeakMonitor.FastMM5` | FastMM5 leak monitor. **Not in the package's `contains` clause** — add the unit to the project, with `FastMM5` first in the `.dpr` |
| `DUnitX.MemoryLeakMonitor.FastMM4` | The FastMM4 monitor, off unless `USE_FASTMM4_LEAK_MONITOR` is defined in `DUnitX.MemoryLeaks.inc` |
| `DUnitX.StackTrace.EurekaLog7` / `.JCL` / `.MadExcept3..5` | Optional stack-trace providers, selected in `DUnitX.Stacktrace.inc` |

`DUnitX.Loggers.GUI.VCL` (`TGUIVCLTestRunner`, with a `Run` procedure; its behaviour is in the Users Guide) and the FastMM5/stack-trace units are **not** in the package `contains` clause and are compiled into the consuming project.

`DUnitX.Filters` gained `TFullNameFilter` on 2026-10-12: it selects tests by exact, case-sensitive full name. `TNameFilter` (what `--run` uses) matches a name as a prefix of a fixture's or test's full name, so it suits command lines but not an exact selection.

---

## 5. The `Assert` class

`Assert` as seen through `DUnitX.TestFramework` is `class( DUnitX.Assert.Ex.Assert )`, itself descended from `DUnitX.Assert.Assert`. Every member is a `class procedure`, so there is nothing to create. The trailing `message : string = ''` is omitted below.

| Group | Members |
|---|---|
| Outcome | `Pass`, **`Ignore`** (fork-local, §1), `Fail( msg, errorAddrs )`, `FailFmt`, `NotImplemented` |
| Equality | `AreEqual` for `string` (with optional `ignoreCase`), `Double`/`Extended` (with optional `tolerance`), `Currency`, `Integer`, `Int64`, `Cardinal`, `word`, `boolean`, `TGUID`, `TClass`, `TStream`, `TStrings` (with an `ignoreLines` array), `TArray<T>`, and generic `AreEqual<T>`; `AreEqualMemory`; the whole `AreNotEqual` mirror set |
| Identity | `AreSame` / `AreNotSame` for `TObject` and `IInterface` |
| Nil and emptiness | `IsNull` / `IsNotNull` (`TObject`, `Pointer`, `IInterface`, `Variant`); `IsEmpty` / `IsNotEmpty` (`string`, `Variant`, `TStrings`, `TList`, `IInterfaceList`, `IEnumerable<T>`) |
| Truth | `IsTrue`, `IsFalse` |
| Membership | `Contains<T>` / `DoesNotContain<T>` over `IEnumerable<T>` and open arrays; `Contains` / `DoesNotContain` over a `string` or a `TStrings`; `StartsWith`, `EndsWith`, `IsMatch( regexPattern, theString )`, `NoDiff` |
| Types | `InheritsFrom( descendant, parent )`, `Implements<T>( value ) : T`, `IsType<T>` (*deprecated — "istype is useless"*) |
| Dates | `IsSameDate`, `IsSameTime`, `IsSameDateTime` |
| Exceptions | `WillRaise`, `WillRaiseDescendant`, `WillRaiseAny`, `WillRaiseWithMessage`, `WillRaiseWithMessageRegex`; `WillNotRaise`, `WillNotRaiseDescendant`, **`WillNotRaiseAny`**, `WillNotRaiseWithMessage`. Each takes either a `TTestLocalMethod` (an anonymous `procedure`) or a `TTestMethod` |
| Class properties | `IgnoreCaseDefault` (§3), `OnAssert`, `TestFailure`, `TestPass`, `TestIgnored` — the last three are the exception classes `DUnitX.Init` injects, and are replaceable |

`Assert.Ignore` deliberately does **not** count as an assertion, so a test cannot satisfy `FailsOnNoAsserts` by skipping itself; an ignored test reports `executed="False"`, `asserts="0"`.

---

## 6. Attributes

Declared in `DUnitX.Attributes`, re-exported by `DUnitX.TestFramework`.

| Attribute | Signature and meaning |
|---|---|
| `[TestFixture]` | `Create`, `Create( AName )`, `Create( AName, ADescription )` |
| `[Test]` | `Create`, or `Create( AEnabled : boolean )` to disable one without deleting it |
| `[TestCase]` | `Create( ACaseName, AValues : string; ASeparator : string = ','; ATrimValues : boolean = False )` — **the case name is the first parameter**; see §1 on why that matters |
| `[AutoNameTestCase]` | `Create( AValues; ASeparator = ','; ATrimValues = False )` — name derived from the values |
| `[TestCaseProvider]` | `Create( providerName : string )` or `Create( AClass : TTestDataProviderClass )`. A name that is not registered is reported as an error |
| `[Setup]` / `[TearDown]` | Per test method |
| `[SetupFixture]` / `[TearDownFixture]` | Per fixture. Only the first method found is used |
| `[Category]` | `Create( ACategory : string )` — drives `-i:` / `-e:` filtering |
| `[Ignore]` | `Create( AReason : string = '' )` — compile-time skip. For a run-time one see `Assert.Ignore` |
| `[MaxTime]` | `Create( AMaxTime : Cardinal )` milliseconds; §3 |
| `[RepeatTest]` | `Create( ACount : Cardinal )` — repeats are named `Method-1-of-N` (§3) |
| `[WillRaise]` | `Create( AExpectedException : ExceptClass; AInheritance : TExceptionInheritance = exExact )`. Also honoured on `[TestCase]` / `[TestCaseProvider]` methods |
| `[TestInOwnThread]` | **Declared but not implemented** — upstream's own note |

---

## 7. Building

Four projects, all `ProjectVersion` 20.5, all declaring `Win32` and `Win64` with `TargetedPlatforms` 3:

| Project | What it is |
|---|---|
| `packages\RAD Studio 13.0\VSoft.DUnitXWinR.dproj` | The runtime package. `{$RUNONLY}`, `{$LIBSUFFIX AUTO}` |
| `Expert\DUnitX_IDE_Expert_D13Florence.dproj` | The IDE expert: New Test Project and New Test Unit wizards. `{$DESIGNONLY}`, `requires rtl, designide, ExpertsCreators`. Delphi personality only (the C++Builder registrations were removed 2026-10-12); new projects target Win32 and Win64 only. Both wizards refuse a fixture class name that is not a valid Delphi identifier or is a reserved word. The generated `.dpr` is a plain console runner (no TestInsight), offers FastMM5 leak checking (selected by default), and exits with `EXIT_ERRORS` when tests fail or the run aborts with an exception |
| `Tests\DUnitXTest_D13.dproj` | The framework's own suite. Needs the sibling `glldelphi-mocks` checkout |
| `Examples\DUnitXExamples_D13.dproj` | Compiles the `Source` units directly rather than linking the package |

**Packages build in all four modes** — Win32 + Win64 × Debug + Release. Both package projects carry the estate output standard:

```xml
<!-- Base group -->
<DCC_BplOutput>$(BDSCOMMONDIR)\Bpl\$(Platform)\$(Config)</DCC_BplOutput>
<DCC_DcpOutput>$(BDSCOMMONDIR)\Dcp\$(Platform)\$(Config)</DCC_DcpOutput>
<!-- Release config group -->
<DCC_BplOutput>$(BDSCOMMONDIR)\Bpl\$(Platform)</DCC_BplOutput>
<DCC_DcpOutput>$(BDSCOMMONDIR)\Dcp\$(Platform)</DCC_DcpOutput>
```

One plain value per group, never `Condition=` lines in Base: the IDE re-saves the `.dproj` on an in-IDE build and keeps one value per property per group, so the conditional form loses the Release paths. Release stays in the shared platform folder, because that is what is on `PATH` and where dependent packages resolve their `requires`; only Debug is diverted. Build Debug first and Release last. All four projects set `<DCC_DcuOutput>.\$(Platform)\$(Config)</DCC_DcuOutput>`, and no platform group overrides it.

The two exe projects build **project-local on both platforms**: `Tests\<Platform>\<Config>\DUnitXTestProject.exe` and `Examples\<Platform>\<Config>\DUnitXExamples_D13.exe`, DCUs alongside. Until 2026-10-12 their Win64 groups sent exe and DCUs to the shared `Studio\37.0\bin` / `dcu` folders; do not reintroduce that, because the test project compiles `Source\` itself and its DCUs there would shadow the library for anything with that folder on its path. All four projects carry version info with build auto-increment on Win64 (the runtime package from `0.5.1`, upstream's latest tag; the expert and both exes from `1.0.0`); Delphi bumps `VerInfo_Build` only inside the `Cfg_N_Win64` groups, so do not delete them. The Tests `.dpr` links `{$R DUnitXTest_D13.res}` by name: its file name (`DUnitXTestProject.dpr`) differs from the project's, so `{$R *.res}` would miss the generated resource.

### `Source\` must never contain `.dcu` files

Until 2026-10-12 `Source` was on the Win64 library path as `$(DUNITX)`, so every consumer compiled against it; it is now on neither platform's library path (§2), which removes the route by which builds with no DCU output directory kept writing here. A project that names `Source` in its own search path can still do it. A project built against it with **no** `DCC_DcuOutput` drops its DCUs beside the `.pas` files, and the next build for the other platform reads them and dies with `F2048 Bad unit format ... Expected version: 37.0, Windows Unicode(x86) Found version: 37.0, Windows Unicode(x64)`. A project that sets a DCU output directory is immune, because the compiler then prefers its own output folder and rebuilds from source.

Forty-four such strays were cleared on 2026-09-05; the folder had forty-four again on 2026-09-18, and thirty-nine Win64 DCUs again on 2026-10-12 (all stamped 2026-10-08 10:10, during an estate-wide exe build sweep). Three recurrences mean cleaning is not the fix: the producer is a build run with no DCU output directory, and the sweep that runs such builds is the place to fix it. They are untracked and `.gitignore`d, so nothing tracked changes — delete them and give whatever produced them a platform-varying `DCC_DcuOutput`. `D:\Tools\Check-DcuCollisions.ps1` does **not** catch this shape: it looks for folders shared between the Win32 and Win64 library paths, and `Source` was on the Win64 path only.

---

## 8. Command-line switches

Parsed by `TDUnitX.CheckCommandLine`, which exits on an invalid option. A switch may start `-`, `--`, `/` or `@`, and takes its value after a `:`.

| Long | Short | Effect |
|---|---|---|
| `options` | `opt` | Read further options from a file: one option per line; lines are trimmed, and blank lines and lines starting `#` or `;` are skipped. A file that includes itself (directly or through another file) is reported as an error |
| `xmlfile` | `xml` | XML output path. Default `dunitx-results.xml` beside the exe |
| `run` | `r` | Tests to run, comma separated; may be repeated |
| `runlist` | `rl` | File listing the tests to run |
| `include` | `i` | Categories to include |
| `exclude` | `e` | Categories to exclude |
| `dontshowignored` | `dsi` | Suppress ignored tests in the output. Takes an optional boolean: `-dsi:false` turns it off (before 2026-10-12 any value turned it on) |
| `loglevel` | `l` | `Information`, `Warning`, `Error` |
| `consolemode` | `cm` | `Off`, `Quiet`, `Verbose` (default) |
| `exitbehavior` | `exit` | `Continue` (default) or `Pause` |
| `hidebanner` | `b` | Hide the licence banner |
| `h` | `?` | Usage |

**The estate's `test_run` tool reads `<exeBase>-results.xml`**, so pass `-xml:MyTests-results.xml` (or set `TDUnitX.Options.XMLOutputFile`) or the run reports ERROR with an all-zero summary.

---

## 9. Troubleshooting

| Symptom | Cause / fix |
|---|---|
| `E2003 Undeclared identifier: 'Ignore'` on `Assert.Ignore` | You are compiling against RAD Studio's bundled DUnitX, not this fork. Put `<repo>\Source` on the project's own unit search path — §2 |
| `F2048 Bad unit format ... Windows Unicode(x86) / (x64)` | `.dcu` files in `Source\`. Delete them and set `<DCC_DcuOutput>.\$(Platform)\$(Config)</DCC_DcuOutput>` on the consuming project — §7 |
| `E2004 Identifier redeclared: 'System.Actions'` then `F2063 Could not compile used unit` | The IDE re-added `System.Actions` on the trailing line of `DUnitX.Loggers.GUI.VCL.pas`, exactly as the comment beside it warns. Remove it; `System.ImageList` beside it is listed once and stays |
| `E2532` on `Assert.AreEqual( 3, List.Count )` | Linking a DUnitX older than 2026-10-10 (the bundled one, or stale DCUs), which lacks the `Integer`/`Int64` overloads. Rebuild against this fork's `Source`, or write `Assert.AreEqual<NativeInt>` — §3 |
| `F2613 Unit 'Delphi.Mocks' not found`, or the `CheckDelphiMocks` build message | The test project only. Clone `glldelphi-mocks` as a sibling at the commit pinned in `DEPENDENCIES.md`, or set the `DelphiMocks` property |
| Fewer tests run than you wrote, exit code 0 | `Runner.UseRTTI := False` dropped the `[TestFixture]`-only fixtures — §3 |
| A test that should crash reports green | `Assert.WillNotRaise( proc, SomeClass )` swallowed a descendant. Use `WillNotRaiseAny` — §3 |
| A casing test cannot be made to fail | `Assert.IgnoreCaseDefault` is `True` — §3 |
| The runner prints its summary then waits forever | Something asked for `Pause`, either `-exit:Pause` on the command line or a mainline that assigns `TDUnitX.Options.ExitBehavior := Pause`. The default is `Continue`. This repo's own `Tests\DUnitXTestProject.dpr` forced `Pause` (outside a `CI` build) until 2026-10-12; it now only honours the option, as the wizard template does |
| `H2675 Directory not found: ...\Source\DUnit\src` | Residue in a DUnit-era project. That folder does not exist; remove the entry. It is not a sign that DUnit needs restoring |
| Your `[Setup]` override never runs | The attribute is not inherited — §3 |

---

## 10. Known issues

- `TRttiPropertyExtension` hard-codes virtual method table slot indices derived from an older `System.Rtti`. Delphi 13 inserted `TRttiPlaceMember` and `TRttiDataMember` into the hierarchy, so the map is very likely wrong. Nothing in DUnitX constructs one, so it is unreachable today; the code carries a warning to re-verify every index before using it.
- Public members such as `ITestFixture.TestCount` return `Integer` while the underlying `TList<T>.Count` is `NativeInt`. The narrowing is harmless at realistic test counts and widening the public API would be breaking.
- `DUnitX.inc` still carries the compiler-version ladder back to Delphi 2010. It is inert on Delphi 13 and has not been resolved away.
- **Fixtures are constructed eagerly**, when the fixture list is built, even under `-r:` for a single test. A raising constructor is now contained to its own fixture, but lazy construction (build with a nil instance and construct in `ExecuteFixtures` only when a fixture has enabled tests) is deferred.
- **A method-level `[Category]` replaces the fixture's category** rather than adding to it, so `-e:Integration` still runs a `[Category('Slow')]` method inside an `[Category('Integration')]` fixture. This is upstream's intent and changing it would change test selection in every suite, so it is left as is.
- **`FailsOnNoAsserts` counts assertions per thread**: asserts made on another thread do not count. Durations use `Now()`, so a clock change can skew them.
- **The command-line parser does not enforce `AllowMultiple`**: a repeated option takes the last value. Enforcing it would reject an options file combined with command-line overrides.

---

## 11. Licence

Apache 2.0, Copyright (C) 2012+ Vincent Parrett — see `LICENSE.txt`. Upstream authorship and copyright are retained throughout; GITLAK's changes are recorded in `CHANGELOG.md`.
