# gllDUnitX — User's Guide

How to build and run a test suite with gllDUnitX, in the order you will need it. For the member tables, the fork's divergence from upstream and the traps that make a test pass when it should fail, see [Help.md](Help.md).

---

## 1. Getting it into a project

There are two ways, and they are not equivalent.

**From source (what the estate does).** Put this repository's `Source` folder on the test project's **own** unit search path:

```xml
<DCC_UnitSearchPath>..\..\gllDUnitX\Source;$(DCC_UnitSearchPath)</DCC_UnitSearchPath>
<DCC_DcuOutput>.\$(Platform)\$(Config)</DCC_DcuOutput>
```

**The `DCC_DcuOutput` line is not housekeeping.** With no DCU output directory the compiler writes each `.dcu` beside the `.pas` it compiled, so one build drops the whole DUnitX set into `Source\` — and the next build for the other platform reads them and dies with `F2048 Bad unit format: ... Expected version: 37.0, Windows Unicode(x86) Found version: 37.0, Windows Unicode(x64)`. A project that sets one is immune, because the compiler then prefers its own output folder and rebuilds from source.

Naming `Source` explicitly also settles *which* DUnitX you get. RAD Studio 13 ships its own copy as DCUs, and on this machine that copy sits earlier on the Win64 library path than the `$(DUNITX)` entry — so a project that stays silent links Embarcadero's DUnitX, not this fork, and `Assert.Ignore` will not compile. See Help.md §2.

**From the package.** Build `packages\RAD Studio 13.0\VSoft.DUnitXWinR.dproj` in all four modes (Win32 + Win64 × Debug + Release), Debug first and Release last, then add `VSoft.DUnitXWinR` to the project's `DCC_UsePackage`. Release output lands in the shared `Bpl\$(Platform)` / `Dcp\$(Platform)` folders; Debug is diverted to a `$(Config)` subfolder so a Debug build cannot replace the installed Release package.

**The IDE expert** is optional: build and install `Expert\DUnitX_IDE_Expert_D13Florence.dproj` from the **64-bit** IDE (`bin64\bds.exe`) and the File ▸ New gallery gains **DUnitX Project** and **DUnitX Unit**. The `LiveTemplates\` folder holds nine matching code templates (`create-testfixture`, `create-testproc`, `register-testfixture` and the rest); `Install.bat` copies the `.xml` files into `%USERPROFILE%\Documents\Embarcadero\Studio\code_templates\DUnitX\`.

---

## 2. The smallest suite that works

Two files. The fixture:

```pascal
unit MyFixture;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TMathFixture = class
  public
    [Test]
    procedure AddingTwoNumbers;
  end;

implementation

procedure TMathFixture.AddingTwoNumbers;
begin
  Assert.AreEqual( 4, 2 + 2, 'two and two' );
end;

initialization
  TDUnitX.RegisterTestFixture( TMathFixture );

end.
```

and the mainline:

```pascal
program MyTests;

{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}

uses
  System.SysUtils,
  DUnitX.TestFramework,
  DUnitX.Init,
  DUnitX.Loggers.Console,
  DUnitX.Loggers.XML.NUnit,
  MyFixture in 'MyFixture.pas';

var
  Runner  : ITestRunner;
  Results : IRunResults;
begin
  try
    TDUnitX.CheckCommandLine;

    Runner                   := TDUnitX.CreateRunner;
    Runner.UseRTTI           := True;
    Runner.FailsOnNoAsserts  := True;
    Assert.IgnoreCaseDefault := False;

    if TDUnitX.Options.ConsoleMode <> TDunitXConsoleMode.Off then
      Runner.AddLogger( TDUnitXConsoleLogger.Create( TDUnitX.Options.ConsoleMode = TDunitXConsoleMode.Quiet ) );
    Runner.AddLogger( TDUnitXXMLNUnitFileLogger.Create( TDUnitX.Options.XMLOutputFile ) );

    Results := Runner.Execute;
    if not Results.AllPassed then
      System.ExitCode := EXIT_ERRORS;
  except
    on E : Exception do
    begin
      System.Writeln( E.ClassName, ': ', E.Message );
      System.ExitCode := EXIT_ERRORS;
    end;
  end;
end.
```

Five lines of that are load-bearing and easy to lose:

- **`DUnitX.Init` in the uses clause.** Its `initialization` assigns `Assert.TestFailure`, `Assert.TestPass` and `Assert.TestIgnored` the real exception classes and registers the fixture provider. Without it the first `Assert.Fail` raises from a nil class reference.
- **`{$STRONGLINKTYPES ON}`**, or the linker discards fixture classes nothing references and RTTI discovery finds them.
- **Both `[TestFixture]` and `RegisterTestFixture`.** They do not double up — the provider merges registered fixtures with `if not FFixtureClasses.ContainsKey(...)` — and leaving either one out loses tests silently. Never set `UseRTTI := False` to "stop tests running twice"; it does not, and it deletes every fixture that has no registration call.
- **`FailsOnNoAsserts := True`**, so a test that asserts nothing is a failure rather than a green line.
- **`Assert.IgnoreCaseDefault := False`**, so string comparisons mean what they look like. Section 5 explains why.

---

## 3. Fixtures: set-up, tear-down and categories

```pascal
type
  [TestFixture( 'Parser', 'Round-trips the pipe-separated rule file' )]
  TParserFixture = class
  private
    FParser : TRuleParser;
  public
    [SetupFixture]   procedure CreateOnce;
    [TearDownFixture] procedure DestroyOnce;
    [Setup]          procedure BeforeEachTest;
    [TearDown]       procedure AfterEachTest;

    [Test]
    [Category( 'fast' )]
    procedure BlankLinesAreSkipped;
  end;
```

Three things to know before you lay a hierarchy over this:

- **Do not `override` an attributed set-up method.** An `override` does not inherit the attribute, so the provider walks up, finds the *ancestor's* attributed method and binds its static code address. Your override never runs. Either re-apply the attribute to the override, or give it a new name and call the inherited method from it.
- **Do not descend one fixture from another.** RTTI returns inherited methods, so the descendant re-runs every ancestor `[Test]` under its own name. Share helper classes instead and copy the scaffolding.
- **A `published` method with no attributes is a test.** If you want a published helper, do not publish it.

Categories drive the `-i:` and `-e:` switches, so `MyTests.exe -e:slow` runs everything not marked `[Category('slow')]`.

---

## 4. One test, many inputs

```pascal
    [Test]
    [TestCase( 'Integers',  '2,2,4' )]
    [TestCase( 'Negatives', '-2,-2,-4' )]
    procedure Adding( const A, B, Expected : Integer );

    [Test]
    [AutoNameTestCase( '2|2|4', '|' )]
    procedure Multiplying( const A, B, Expected : Integer );
```

`[TestCase]` is `Create( ACaseName, AValues, ASeparator = ',', ATrimValues = False )` — **the first parameter is the case name**, the second is the value list. (Upstream's abandoned `dev` branch removes that first parameter; taking it would leave every existing `[TestCase]` in the estate compiling and meaning something else. See Help.md §1.) `[AutoNameTestCase]` drops the name and derives it from the values.

When the data does not belong in an attribute, implement a `TTestDataProviderBase` descendant, register it in that unit's `initialization` with `TestDataProviderManager.RegisterProvider( Name, TMyProvider )`, and point a test at it with `[TestCaseProvider( 'Name' )]`. `TestCaseProvider.md` at the repository root walks through the five methods it must supply.

`[RepeatTest( 5 )]` runs the same test five times; `[MaxTime( 250 )]` fails it if it took longer than 250 ms — but note that `[MaxTime]` is checked **after** the method returns and cannot interrupt a test that never does.

---

## 5. Asserting — and two defaults that will bite

The full member list is in Help.md §5. Two of them change what your tests mean:

**String comparisons ignore case by default.** `Assert.Create` sets `fIgnoreCaseDefault := True`, and `AreEqual`, `AreNotEqual`, `Contains`, `DoesNotContain`, `StartsWith`, `EndsWith` and `NoDiff` all forward it. A test whose subject *is* the casing cannot fail:

```pascal
Assert.AreEqual( 'McDonald', ProperCase( 'mcdonald' ) );          // green against 'Mcdonald'
Assert.AreEqual( 'McDonald', ProperCase( 'mcdonald' ), False );   // third argument is ignoreCase
```

Set `Assert.IgnoreCaseDefault := False` once in the mainline and the whole suite is strict by construction; a test that genuinely does not care then passes `True` explicitly. Do this on a new suite. On an existing one it turns currently-green tests red, so it is a change to make deliberately.

**"This must not raise" needs `WillNotRaiseAny`.** `Assert.WillNotRaise( proc, SomeClass )` tests `e.ClassType = exceptionClass`, so it catches a *descendant* and then does nothing at all — the test passes while the access violation it was written to catch happens on every run:

```pascal
// wrong: an EAccessViolation is caught and silently ignored
Assert.WillNotRaise( procedure begin Widget.Rebuild; end, Exception, 'rebuild' );

// right
Assert.WillNotRaiseAny( procedure begin Widget.Rebuild; end, 'rebuild' );
```

Passing no class at all is also safe — that path fails on anything.

The positive forms are the mirror image and behave as you would expect:

```pascal
Assert.WillRaise( procedure begin Parse( 'rubbish' ) end, EParseError );
Assert.WillRaiseDescendant( procedure begin Parse( 'rubbish' ) end, EParseError );
Assert.WillRaiseWithMessageRegex( procedure begin Parse( '' ) end, EParseError, 'line \d+' );
```

One Delphi 13 wrinkle: `TList<T>.Count` is a `NativeInt`. Since 2026-10-10 this fork has `Assert.AreEqual( Integer, Int64 )` and `( Int64, Integer )` on Win64 (upstream #397), so `Assert.AreEqual( 3, List.Count )` compiles; before that it failed with `E2532`, and the `Assert.AreEqual<NativeInt>( 3, List.Count )` form written to work around it is still valid.

---

## 6. Skipping a test honestly

Two mechanisms, and they answer different questions.

```pascal
    [Test]
    [Ignore( 'Blocked on the 4.1 headers' )]
    procedure NewCertificateErrorsAreReported;
```

`[Ignore]` is decided at compile time — the test is never run and is reported as ignored.

When the precondition can only be discovered by looking, use the fork-local run-time form:

```pascal
procedure TToolFixture.HeaderCheckIsConsistent;
begin
  if not TFile.Exists( FToolExe ) then
    Assert.Ignore( 'TaurusTLSHeaderCheck.exe has not been built' );
  ...
end;
```

`Assert.Ignore` raises `ETestIgnored`, which the runner already understood; the test is reported `result="Ignored"` with your reason, `executed="False"`, `asserts="0"`. It deliberately does **not** count as an assertion, so a test cannot satisfy `FailsOnNoAsserts` by skipping itself.

`Assert.Pass` exists too, and is the wrong answer here: it reports PASS, which is indistinguishable from a test that verified something, and hides the gap on every later run.

`Assert.Ignore` is in this fork only. A suite using it will not compile against RAD Studio's bundled DUnitX or against upstream.

---

## 7. Running the suite

```
MyTests.exe                                   verbose console, dunitx-results.xml beside the exe
MyTests.exe -xml:MyTests-results.xml          name the XML explicitly
MyTests.exe -cm:Quiet                         quiet console
MyTests.exe -r:TMathFixture.AddingTwoNumbers  one test
MyTests.exe -i:fast                           only the 'fast' category
MyTests.exe -e:slow -dsi                      everything but 'slow', hiding ignored tests
MyTests.exe -?                                usage
```

A switch may start `-`, `--`, `/` or `@`, and its value follows a `:`. The full list is in Help.md §8.

**Name the XML file.** The estate's `test_run` tool reads `<exeBase>-results.xml`; with the default `dunitx-results.xml` it reports ERROR and an all-zero summary even though the run was green.

The exit code is whatever your mainline sets — the example above uses `EXIT_ERRORS` (1) when `Results.AllPassed` is false. `IRunResults` also carries `TestCount`, `PassCount`, `FailureCount`, `ErrorCount`, `IgnoredCount`, `MemoryLeakCount` and `SuccessRate` if you want a richer summary.

Add loggers as you need them, in any combination:

```pascal
Runner.AddLogger( TDUnitXXMLJUnitFileLogger.Create( 'junit.xml' ) );   // DUnitX.Loggers.XML.JUnit
Runner.AddLogger( TDunitXTextFileLogger.Create( 'run.log' ) );         // DUnitX.Loggers.Text
```

NUnit XML suits Continua CI, JUnit XML suits GitLab CI. A VCL GUI runner exists in `DUnitX.Loggers.GUI.VCL` (`TGUIVCLTestRunner`, with a `Run` procedure) — it is not in the package, so add the unit to the project if you want it.

---

## 8. Converting an inherited DUnit suite

DUnit's source was removed from this RAD Studio installation deliberately; new and converted suites are DUnitX. A DUnit-shaped fixture does **not** have to be rewritten, because `DUnitX.DUnitCompatibility` supplies `TTestCase` and the whole `Check*` family.

1. Swap the uses clause to `DUnitX.TestFramework, DUnitX.DUnitCompatibility`.
2. `RegisterTest( TFoo.Suite )` becomes `TDUnitX.RegisterTestFixture( TFoo )`.
3. `Fail( ... )` becomes `Assert.Fail( ... )` — the compatibility layer has neither `RegisterTest` nor a bare `Fail`.
4. Replace the runner mainline with section 2's.
5. Add `{$M+}` immediately before the `type` block — after any `{$I *.inc}`, or it does not take. DUnit's `TTestCase` was a `TPersistent` and got published RTTI free; this one is a plain `TObject`.
6. Add `{$WARN SYMBOL_DEPRECATED OFF}`, because every compatibility `Check*` is marked deprecated.

Two things not to do:

- **Do not add your own `[Setup]` / `[TearDown]`** to a converted fixture. The compatibility `TTestCase` already carries them on `TestSetupMethod` / `TestTeardownMethod`, which call the virtual `SetUp` / `TearDown` you override. Adding your own gives the provider two candidates for one role.
- **Do not write a bare `Assert( cond, msg )`.** `Assert` is a *class* here and shadows `System.Assert`. Use `Assert.IsTrue( cond, msg )` — better anyway, since `System.Assert` compiles out under `{$ASSERTIONS OFF}`.

When checking a conversion, diff the **test names** old against new, not the totals.

---

## 9. Leak checking

**There is no leak checking until you install a monitor.** `TDUnitX` registers `DUnitX.MemoryLeakMonitor.Default` if nothing else has claimed `IMemoryLeakMonitor`, and that one is a dummy whose every measurement returns 0 — so `IRunResults.MemoryLeakCount` reads zero on a leaking suite and nothing says so.

To get a real one, add `DUnitX.MemoryLeakMonitor.FastMM5` to the project — it is not in the runtime package — with `FastMM5` as the **first** unit in the `.dpr`. The unit self-registers in its `initialization`, and raises *"You must add FastMM5.pas in your project as the first's unit in .dpr!"* if FastMM5 is not actually installed. Two cautions:

- **Do not also set `ReportMemoryLeaksOnShutdown := True`.** FastMM5's finalization puts the leak message box back when that flag is set, so a runner that clears `FastMM_MessageBoxEvents` and then sets the flag hangs forever on a modal dialog instead of failing — the exact failure the gate exists to catch, and it hangs CI.
- **FastMM5 never relocates a block on a shrinking `ReallocMem`**, so any regression that only appears when a block *moves* — stale interior pointers, `[Weak]` references — cannot reproduce in a suite that installs it. Put that kind of test in a suite running on the default allocator.

The older `DUnitX.MemoryLeakMonitor.FastMM4` is in the package but inert unless `USE_FASTMM4_LEAK_MONITOR` is defined in `DUnitX.MemoryLeaks.inc`, which it is not by default. It requires `FastMM4.pas` to be the first unit in the `.dpr`.

---

## 10. Practical notes

- **Mutation is the acceptance criterion, not green.** Break the product deliberately and confirm the intended test reddens *on its own assertion*. Both defaults in section 5 were found that way and could not have been found by reading.
- **Rebuild the library before mutation-testing a fix in it.** A test project links the library's DCUs, so mutating a library `.pas` and rebuilding only the test project silently tests the old binary — and "proves" the guard does not bite, which is exactly backwards.
- **A new fixture unit needs its `initialization` registration** in a suite that registers explicitly. Without it the unit compiles, links, and the class name is even findable in the exe, while the run stays at the old test count.
- **Working on this repository itself:** `Tests\DUnitXTest_D13.dproj` is the framework's own suite and additionally needs a sibling checkout of `glldelphi-mocks` at the commit pinned in `DEPENDENCIES.md` — only two logger test units use it. A drifting checkout shows up as a *compile* failure in those two units, not as a test failure.
- **Never let `.dcu` files accumulate in `Source\`.** Section 1 says why; they are build output that escaped a misconfigured consumer, and nothing should ever link against them.
