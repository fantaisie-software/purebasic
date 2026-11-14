# Unit tests of the IDE and the debugger

The tests run with **PureUnit 1.5 or newer**, which comes with PureBasic (`SDK/PureUnit`, see its
`Readme.txt` and [the PureUnit manual](../../AsciiDoc/PureUnit-Help.asciidoc)). They are in two folders:

- `PureBasicIDE/UnitTests/`: the IDE code (source scanner, highlighting, find/replace, algorithms...)
- `PureBasicDebugger/UnitTests/`: the debugger engine, driving real programs compiled with the debugger

## Running the tests

With the build environment set up (see [BUILD.md](../../BUILD.md)), in `PureBasicIDE` and in
`PureBasicDebugger`:

```
make test
```

`make test` in `PureBasicIDE` first builds the generated files the IDE code needs (`Build/<processor>/BuildInfo.pb`,
the themes...), but not the IDE itself: the installed IDE is not touched. On Linux, the tests use the subsystem
of the IDE (`PB_GTK=2`, `PB_QT=1`) and run in a virtual display (`xvfb-run`) when it is installed.

A single test file can also be run directly, with more output:

```
cd PureBasicIDE/UnitTests
pureunit -v SourceParser.pb
```

or opened in the IDE and run with the debugger: `Assert()` then stops in the debugger on a failure (the
`PureUnitOptions(MainCode)` files need the main code to run, which is the case from the IDE).

Nothing of the user's PureBasic configuration is read or written: the tests use temporary directories.

## Writing tests

Each test is a `ProcedureUnit` without parameters, which checks results with `Assert()`, `AssertString()` and
`Fail()` (see the PureUnit manual). PureUnit runs the tests of a file in a **random order**, and restarts the
program after a failed test: each test must set up what it needs.

Add a test with every bug fix when the code can be tested: it must fail before the fix and pass after it. Put
the URL of the bug report or PR above the test.

There are three kinds of test files, from the lightest to the most complete.

### 1. Self-contained code (`Algorithms.pb`)

For code that needs only declarations (structures, constants): include `CompilerFlags.pb`, `Common.pb` and the
file to test. No `PureUnitOptions()` is needed. Such a file compiles in a fraction of a second.

### 2. The whole IDE (`SourceParser.pb`, `FindReplace.pb`)

For the rest of the IDE code: the whole IDE is compiled in the test, without starting it, and initialized like
the IDE does at startup, with the default preferences:

```
PureUnitOptions(MainCode, ThreadOnly)
XIncludeFile "TestEnvironment.pbi"

ProcedureUnit MyTest()
  ...
EndProcedureUnit
```

- `MainCode` runs the main code of the IDE files (`Global` values, `NewList`, `Dim`...) before the tests. By
  default, PureUnit never runs the main code of a test file.
- `ThreadOnly`, as the IDE is compiled in thread mode.
- `TestEnvironment.pbi` includes `PureBasicIncludes.pb` (all the IDE files, also included by `PureBasic.pb`),
  defines the procedures of `PureBasic.pb`, and runs the startup steps that the tests need.
  `WriteTestSource()` writes a source file in its temporary directory.
- A `MessageRequester()` opened by the IDE code fails the test: it would block the tests forever.
- No window of the IDE is created: test the code below the user interface (`ScanFile()` instead of the
  procedure browser, `IsWholeWordMatch()` instead of the Find window...).

Such a file takes a few seconds to compile, so group the tests of an area in one file.

### 3. The debugger engine (`PureBasicDebugger/UnitTests/DebuggerEngine.pb`)

`DebuggerTestHost.pbi` hosts the debugger engine (`DebuggerIncludes.pb`), like the IDE and the standalone
debugger do, and records what it reports:

```
PureUnitOptions(MainCode)
XIncludeFile "DebuggerTestHost.pbi"

ProcedureUnit MyTest()
  Assert(RunDebugged(BuildTarget("DebugOutput")))  ; Targets/DebugOutput.pb, compiled with the debugger
  AssertString(DebugOutput(), "Hello|7|...")
EndProcedureUnit
```

`RunDebugged()` runs the program until it ends. A runtime error stops it (see `Errors()`), and breakpoints set
in `BreakPoints()` before the run are reported in `Stops()`. In the target programs, mark the lines a test
needs with a `; @Name` comment and get their number with `TargetLine()`, instead of writing line numbers.

## Limits

- PureUnit compiles the tests without the debugger, so a test does not catch an array index out of bounds
  or other debugger checks in the tested code.
- The user interface itself (layout, DPI scaling, events) is not tested.
