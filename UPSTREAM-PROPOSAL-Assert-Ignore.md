# Proposal: `Assert.Ignore` - a run-time test skip for DUnitX

**To:** the DUnitX maintainers (VSoft Technologies)
**From:** Ian Branch (GITLAK Software), maintainer of a DUnitX fork
**Date:** 2026-09-09
**Against:** upstream `master` @ `a69a10b` (2026-08-24)

---

## Summary

DUnitX can skip a test at **compile** time, through the `[Ignore]` attribute. It cannot skip one at
**run** time. This proposes `Assert.Ignore(reason)` to close that.

The interesting part is that **almost all of the machinery is already in DUnitX and simply never
wired up**. What follows is mostly a description of your own dormant code, plus the small trigger it
was missing and one genuine defect found along the way.

I have implemented, tested and shipped this in my fork. I am offering it upstream because it uses
your existing design rather than working around it - and because if you take it, my fork stops
diverging here. Happy to submit it as a pull request in whatever shape you prefer.

---

## 1. The gap

A test whose **precondition can only be discovered at run time** - an external tool, a source tree,
a database, a network share - currently has three options, and all three are bad:

| Option | What the report says | Problem |
|---|---|---|
| `Assert.Pass` | **PASS** | Indistinguishable from a test that actually verified something. The gap is invisible on every later run. |
| Return early / no assertions | **PASS** (or a `FailsOnNoAsserts` error) | The same, but quieter. |
| `Assert.Fail` | **FAIL** | Conflates "the code is broken" with "I could not check". Sends the next person hunting a bug that is not there. |

`[Ignore]` is the right *concept*, but it is fixed at compile time, so it cannot express "skip only
when the thing I need turns out to be missing".

The case that prompted this: a parser regression test that reads real RTL source files from the
RAD Studio installation. If that source tree is absent, the test has not found a parser bug - it has
found that it could not look. `PASS` lies about that, `FAIL` misdirects. `Ignored` is exactly right,
and there was no way to say it.

## 2. The machinery is already in DUnitX

This was the surprise. Everything below is upstream code, present and correct today:

- `ETestIgnored` is declared in `DUnitX.Exceptions.pas` (line 50).
- `TDUnitXTestRunner.ExecuteTest` **already catches it**, in `DUnitX.TestRunner.pas` (line 851):
  `on e : ETestIgnored do ...`
- `TTestResultType.Ignored`, `IgnoredCount` and `OnTestIgnored` are fully plumbed through
  `ITestResults`, `ITestLogger` and **every** logger - console, text, GUI VCL, GUI RichEdit, NUnit
  XML, JUnit XML.
- The NUnit logger already emits `result="Ignored"` and `executed="False"` for it.

The only thing missing is that **nothing anywhere raises `ETestIgnored`**. A repository-wide search
finds exactly two references: the declaration, and the handler that catches it.

So this is less a new feature than connecting a wire that was left loose.

## 3. What the patch adds

Three small pieces, each mirroring an existing pattern rather than inventing one:

1. **`Assert.Ignore(const message : string = '')`** - raises `ETestIgnored`.
2. **`fTestIgnored` / `TestIgnored`** - mirrors the existing `fTestPass` / `TestPass` injection, so
   the exception class stays replaceable exactly as `TestPass` and `TestFailure` are.
3. **Registration** in both `InitAssert` procedures (`DUnitX.Init.pas` and
   `DUnitX.TestFramework.pas`), beside the existing two.

## 4. A defect it also fixes

This one is worth flagging in its own right, because it is a live bug in the existing handler rather
than anything to do with the new API.

The runner passes `test.IgnoreReason` into `ExecuteIgnoredResult`:

```pascal
on e : ETestIgnored do
  testResult := ExecuteIgnoredResult(context, threadId, test, test.IgnoreReason);
```

`test.IgnoreReason` is the **attribute's** reason. For a run-time ignore it is empty - the reason
lives in `e.Message`, which is discarded. So the skip is recorded but **the reason is silently
dropped**, and for a run-time skip the reason is most of the value.

The patch prefers `e.Message` and falls back to `IgnoreReason`, so attribute-driven ignores behave
exactly as they do now.

**Mutation-checked rather than assumed.** Reverting only that branch and re-running: the test is
still reported `result="Ignored"`, but the reason is absent from the NUnit XML entirely (grep count
0 against 1). It is load-bearing, not cosmetic.

## 5. Design decisions worth your review

- **`Ignore` deliberately does *not* call `DoAssert`.** Being skipped is not an assertion, and
  counting it as one would let a test satisfy `FailsOnNoAsserts` by doing nothing but skipping
  itself. Confirmed: an ignored test reports `asserts="0"`.
- **`Pass` is left exactly as it is.** The XML-doc on `Ignore` steers people away from using `Pass`
  to skip, since that is the failure mode this exists to prevent.
- **No new language or RTL features.** The patch is plain Object Pascal - no inline variables, no
  generics, no new dependencies - so it should compile on every compiler version you support, not
  only the ones my fork targets.

## 6. Verification

- **DUnitX's own suite:** 289 found, 280 passed, 9 ignored, 0 failed, 0 errored.
- **Two new tests** in `DUnitX.Tests.Assert.pas`, written to match the existing
  `Pass_Throws_ETestPass_Exception` pair exactly: `Ignore_Throws_ETestIgnored_Exception` and
  `Ignore_Throws_ETestIgnored_Exception_With_Message`.
- **End to end**, in a real consuming suite rather than a synthetic probe - an ignored test yields:

```xml
<test-case name="RealWorld_VclAxCtrls_IndexesPastTheWrappedParentList"
           executed="False" result="Ignored" time="0.000" asserts="0" >
  <reason>
    <message>
      <![CDATA[ the RAD Studio VCL source tree could not be located ... ]]>
    </message>
  </reason>
</test-case>
```

  with the reason carried through to the report, `ignored: 1` in the summary, and exit code `0`.
- The runtime package builds clean in all four modes (Win32/Win64 x Debug/Release) on
  **Delphi 13 (Florence), RAD Studio 37.0**.

## 7. A heads-up about the `dev` branch

Not part of the proposal, but you would want to know: **`upstream/dev` deletes the
`on e : ETestIgnored do` handler** from `ExecuteTest` altogether, as part of the parallel-fixture
rewrite. `master` still has it.

So if `dev` ever lands as it stands, the run-time ignore path disappears - including for anyone
already relying on `ETestIgnored` being caught. If this proposal is of interest, that handler is
worth preserving in whatever shape `dev` eventually takes.

(For context: `dev`'s tip is dated 2025-05-05, roughly sixteen months older than `master`'s, and it
is not an ancestor of `master`.)

## 8. Disclosure

This comes from a fork that has diverged from upstream in ways you would not want: it targets
Delphi 13 and Windows only (Win32/Win64), with support for earlier RAD Studio versions and non-Windows platforms
removed, and it renames the DPM package id so it cannot shadow yours in a feed.

**None of that is entangled with this patch.** The change below touches only `DUnitX.Assert.pas`,
`DUnitX.Init.pas`, `DUnitX.TestFramework.pas`, `DUnitX.TestRunner.pas` and the Assert test unit, and
depends on none of the fork's other changes.

## 9. The change

```diff
diff --git a/Source/DUnitX.Assert.pas b/Source/DUnitX.Assert.pas
index 736c86e..b5a45c9 100644
--- a/Source/DUnitX.Assert.pas
+++ b/Source/DUnitX.Assert.pas
@@ -55,6 +55,7 @@ type
     class var fOnAssert : TProc;
     class var fTestFailure : ExceptClass;
     class var fTestPass : ExceptClass;
+    class var fTestIgnored : ExceptClass;
     class procedure CheckExceptionClass(E : Exception; const exceptionClass : ExceptClass);
     class procedure CheckExceptionClassDescendant(E : Exception; const exceptionClass : ExceptClass);
   protected
@@ -63,6 +64,22 @@ type
     class procedure DoAssert; inline;
   public
     class procedure Pass(const message : string = '');
+    ///  <summary>
+    ///    Stops the test and reports it as IGNORED - neither passed nor
+    ///    failed - carrying message as the reason.
+    ///  </summary>
+    ///  <remarks>
+    ///    For a test whose PRECONDITION is absent at run time: an external
+    ///    tool, a source tree, a database. Prefer the [Ignore] attribute
+    ///    when the condition is known at compile time; this is for when it
+    ///    can only be discovered by looking.
+    ///
+    ///    Do NOT reach for Pass() to skip a test. A skipped test that
+    ///    reports PASS is indistinguishable from one that verified
+    ///    something, so the gap it leaves is invisible on every later run.
+    ///    That is the whole reason this exists.
+    ///  </remarks>
+    class procedure Ignore(const message : string = '');
     class procedure Fail(const message : string = ''; const errorAddrs : pointer = nil);
     class procedure FailFmt(const message : string; const args : array of const; const errorAddrs : pointer = nil);
 
@@ -289,6 +306,7 @@ type
     class property OnAssert : TProc read fOnAssert write fOnAssert;
     class property TestFailure : ExceptClass read fTestFailure write fTestFailure;
     class property TestPass : ExceptClass read fTestPass write fTestPass;
+    class property TestIgnored : ExceptClass read fTestIgnored write fTestIgnored;
     class property IgnoreCaseDefault : boolean read fIgnoreCaseDefault write fIgnoreCaseDefault;
 
     class constructor Create;
@@ -767,6 +785,14 @@ begin
   raise fTestPass.Create(message);
 end;
 
+class procedure Assert.Ignore(const message : string);
+begin
+  //  Deliberately does NOT call DoAssert. Being skipped is not an
+  //  assertion, and counting it as one would let a test satisfy
+  //  FailsOnNoAsserts by doing nothing but skipping itself.
+  raise fTestIgnored.Create(message);
+end;
+
 class procedure Assert.StartsWith(const subString, theString, message : string);
 begin
   Assert.StartsWith(subString, theString, fIgnoreCaseDefault, message);
diff --git a/Source/DUnitX.Init.pas b/Source/DUnitX.Init.pas
index e1a6425..95e1d81 100644
--- a/Source/DUnitX.Init.pas
+++ b/Source/DUnitX.Init.pas
@@ -58,6 +58,7 @@ procedure InitAssert;
 begin
   DUnitX.TestFramework.Assert.TestFailure := ETestFailure;
   DUnitX.TestFramework.Assert.TestPass := ETestPass;
+  DUnitX.TestFramework.Assert.TestIgnored := ETestIgnored;
 end;
 
 initialization
diff --git a/Source/DUnitX.TestFramework.pas b/Source/DUnitX.TestFramework.pas
index 7a8e72e..a7ab502 100644
--- a/Source/DUnitX.TestFramework.pas
+++ b/Source/DUnitX.TestFramework.pas
@@ -920,6 +920,7 @@ procedure InitAssert;
 begin
   Assert.TestFailure := ETestFailure;
   Assert.TestPass := ETestPass;
+  Assert.TestIgnored := ETestIgnored;
 end;
 
 {$IFNDEF DELPHI_XE3}
diff --git a/Source/DUnitX.TestRunner.pas b/Source/DUnitX.TestRunner.pas
index 6d21fe6..f5ab6c6 100644
--- a/Source/DUnitX.TestRunner.pas
+++ b/Source/DUnitX.TestRunner.pas
@@ -849,7 +849,14 @@ begin
       except
         //Handle the results which are raised in the test.
         on e : ETestIgnored do
-          testResult := ExecuteIgnoredResult(context, threadId, test, test.IgnoreReason);
+          //  A RUNTIME ignore carries its own reason; the attribute's
+          //  IgnoreReason is empty for it. Preferring e.Message is what
+          //  makes Assert.Ignore('...') report anything at all - without
+          //  this the skip is recorded but the reason is silently dropped.
+          if e.Message <> '' then
+            testResult := ExecuteIgnoredResult(context, threadId, test, e.Message)
+          else
+            testResult := ExecuteIgnoredResult(context, threadId, test, test.IgnoreReason);
         on e : ETestPass do
           testResult := ExecuteSuccessfulResult(context, threadId, test, e.Message, FLogMessagesEx);
         on e : ETestFailure do
diff --git a/Tests/DUnitX.Tests.Assert.pas b/Tests/DUnitX.Tests.Assert.pas
index 1c90b85..9611ed3 100644
--- a/Tests/DUnitX.Tests.Assert.pas
+++ b/Tests/DUnitX.Tests.Assert.pas
@@ -44,6 +44,12 @@ type
     [Test]
     procedure Pass_Throws_ETestPass_Exception_With_Message;
 
+    [Test]
+    procedure Ignore_Throws_ETestIgnored_Exception;
+
+    [Test]
+    procedure Ignore_Throws_ETestIgnored_Exception_With_Message;
+
     [Test]
     procedure Fail_Throws_ETestFailure_Exception;
 
@@ -552,6 +558,33 @@ begin
     end, ETestPass, EXPECTED_EXCEPTION_MSG);
 end;
 
+//  Assert.Ignore is the runtime counterpart of the [Ignore] attribute: it
+//  stops a test whose PRECONDITION turned out to be absent and reports it
+//  as ignored rather than passed. Without it the only ways to skip are
+//  Assert.Pass, which lies, and doing nothing, which lies more quietly.
+procedure TTestsAssert.Ignore_Throws_ETestIgnored_Exception;
+begin
+  Assert.WillRaise(
+    procedure
+    begin
+      Assert.Ignore;
+    end, ETestIgnored);
+end;
+
+//  The message is the REASON the test was skipped, and it must survive to
+//  the runner - a skip whose reason is dropped is nearly as unhelpful as
+//  no skip at all.
+procedure TTestsAssert.Ignore_Throws_ETestIgnored_Exception_With_Message;
+const
+  EXPECTED_EXCEPTION_MSG = 'Ignoring Message';
+begin
+  Assert.WillRaise(
+    procedure
+    begin
+      Assert.Ignore(EXPECTED_EXCEPTION_MSG);
+    end, ETestIgnored, EXPECTED_EXCEPTION_MSG);
+end;
+
 procedure TTestsAssert.Test_Implements_Will_Fail_If_Not_Implemented;
 var
   obj : IInterface;
```

---

## Offer

Happy to open this as a pull request against `master`, adjust the naming or the XML-doc wording to
your house style, drop the comment blocks if they are heavier than you like, or split the run-time
`IgnoreReason` fix out as a separate PR, since it stands on its own.

If you would rather not take it, that is entirely fine - the `dev` branch note in section 7 is worth
having either way.

- Ian Branch
