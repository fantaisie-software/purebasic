# AGENTS.md

This file provides guidance to AI coding agents (Claude Code, etc.) when working with code in this repository.

## Related AGENTS.md files

This repo (`GitHub/purebasic-dev`) sits alongside two other trees under the
same SVN root (`<SvnRoot>` = the parent of `GitHub/`, e.g.
`C:\PureBasic\Svn\v6.50\`), each with its own `AGENTS.md` covering the
closed-source parts of PureBasic that aren't in this open-source repo:

- `<SvnRoot>\Libraries\AGENTS.md` — the standard-library command
  implementations (`Math`, `String`, `Json`, …) and their build/test/remote
  compile-check workflow.
- `<SvnRoot>\Compiler\AGENTS.md` — the compiler (`pbcompiler`/`sbcompiler`)
  source, codegen backends, and its own build/test workflow.

Always consult the `<SvnRoot>\Libraries\AGENTS.md` as it explain how to retrieve bug from forum, how to connect to remote boxes etc.
Consult those when a task touches the compiler backend or standard-library
commands rather than the IDE/debugger/dialog-manager/docs covered here.

## What this repository is

This is the **PureBasic OpenSource Projects** repo: the open-sourced parts of PureBasic (and, in places, SpiderBasic), a native-code BASIC compiler/IDE for Windows, Linux and macOS. The compiler backend itself is *not* here — this repo contains the **IDE**, the **debugger**, the **dialog manager**, supporting tools, and the **documentation sources**. Building anything requires a pre-existing PureBasic installation (the compiler `pbcompiler`/`pbcompilerc` and the runtime libs), since the IDE/debugger/tools are themselves written in PureBasic and compiled by it.

All source is written in **PureBasic** (`.pb`, `.pbi`, `.pbf`) — think of it as classic Basic/Pascal-like syntax with `Procedure`/`EndProcedure`, `XIncludeFile`/`IncludeFile`, `CompilerIf`/`CompilerEndIf` for conditional compilation, structures, and macros.

## Branching

- `devel` is the default/baseline branch — all contributions and PRs target `devel`.
- `master` is maintainer-only, used for tagged releases; never PR against it.
- Never commit directly to a local `devel`/`master` checkout — work happens on topic branches cut from `devel` (see CONTRIBUTING.md for the full fork/rebase workflow if asked to prepare a PR).

## Building

A dedicated PureBasic install (not "Program Files", no spaces/special chars in the path) is required as the build target — compiling **overwrites `PureBasic.exe`/`PureBasic.app` in that install** with the freshly built IDE, so never point this at someone's primary install unless asked. `config.json` in the repo root holds `PureBasicPath` (and `HhcPath` for CHM docs) used by the VS Code tasks in `.vscode/tasks.json`.

- **Always use the official `make`-based build** (Windows via GnuWin/Unix tools, or native on Linux/macOS) — this is the default, even on Windows:
  ```
  cd PureBasicIDE && make                 # or `make debug` for a debug build
  ```
  On the local Windows dev machine, all `PB_*` build env vars (`PB_LIBRARIES`,
  `PB_BUILDTARGET`, `PB_WINDOWS`, `PUREBASIC_HOME`, …) are already pre-set as
  permanent system/user environment variables outside the repo, so a bare
  `make` in `PureBasicIDE` (or `PureBasicDebugger`) works directly — there is
  **no need to run `BuildEnv.cmd` first** there (running it launches a nested
  interactive shell and can fail if the compiler isn't where it expects). Only
  run the setup scripts on a machine that doesn't already have that ambient
  environment:
  ```
  BuildEnv.cmd <PureBasicInstallPath>     # Windows, sets env + PATH
  ./BuildEnv.sh  <PureBasicInstallPath>   # Linux/macOS
  ```
  On Linux, GTK3 is the default subsystem; set `PB_GTK=2` for GTK2 or `PB_QT=1` for Qt before running `BuildEnv.sh`. See `BUILD.md` for macOS `.app` bundle prep details. This produces the IDE at `<SvnRoot>\Build\PureBasic_x64\PureBasic.exe` (the path already used for manual/UI testing below), not at whatever `config.json`'s `PureBasicPath` points to.

- **Windows quick build (`MakeWindows.cmd`, no Unix tools needed) — do not use unless explicitly asked.** The maintainer wants `make` used on Windows too, not this script:
  ```
  cd PureBasicIDE
  MakeWindows.cmd <PureBasicInstallPath>
  ```
  Same pattern works in `PureBasicDebugger`. This script and the makefile must be kept in sync — if you touch one, mirror the change in the other (there's an explicit comment to this effect in `MakeWindows.cmd`).

- **Documentation** (English/German/French sources under `Documentation/<Lang>/*.txt`, built via DocMaker which ships with a PureBasic install):
  ```
  cd Documentation
  HTML-BUILD.bat en|de|fr|all     # HTML preview build
  CHM-BUILD.bat  en|de|fr|all     # CHM build (needs HhcPath / HTML Help Workshop)
  ```
  `Documentation/English/makefile` also exposes `make doc` / `make console` targets that shell out to `DocMaker.exe`/`pbdocmakerconsole`.

There is no unit test suite; "testing" a change generally means building the IDE/debugger and exercising it manually, or (for docs) rebuilding and inspecting the generated HTML/CHM output.

## Running the IDE for manual/UI testing

To launch a freshly-built IDE against a specific source file without touching the user's real config/session:

```
<SvnRoot>\Build\PureBasic_x64\PureBasic.exe /PORTABLE <path-to-file.pb>
```

(`<SvnRoot>` is the parent of `GitHub\`, e.g. `C:\PureBasic\Svn\v6.50\`.)

- **Launch from PowerShell, not Git Bash** — Git Bash's MSYS path-conversion mangles a leading `/PORTABLE` into a bogus Windows path (e.g. `...\C:\Program Files\Git\PORTABLE`), which makes the IDE fail to load the source file. Use `Start-Process -FilePath ... -ArgumentList "/PORTABLE", "<path>"` instead.
- **Quitting cleanly (avoids the "previous session ended improperly" recovery dialog on next launch):** don't force-kill the process. If you made throwaway edits to the test file (e.g. while reproducing an editor bug), press **Ctrl+Z repeatedly first to undo them back to the unmodified state**, then **Ctrl+Q** to quit — this does a clean shutdown. Force-killing (`Stop-Process -Force`) works but leaves a "session ended improperly" prompt that steals focus on the next launch and must be dismissed (click "Non"/"No") before automating further keystrokes.
- Driving the UI (SendKeys, screenshots, window-handle focus tricks) is inherently timing-sensitive — poll for the expected window/dialog to actually appear (e.g. via `EnumWindows` for the "Find/Replace" title) rather than using a fixed sleep before typing into it, otherwise keystrokes can race the dialog and land in the source editor instead.

## Keyboard shortcuts (Windows/Linux defaults)

These are the **default** bindings from `PureBasicIDE/ShortcutManagement.pb` (`CompilerIf #CompileLinux | #CompileWindows` branch — Linux shares the same defaults as Windows; macOS differs, see the file's `CompilerElse` branch). Users can rebind everything via Preferences ▸ Shortcuts, so treat this as the out-of-the-box mapping, not a guarantee of what's active. Consult this instead of screenshotting the Edit/File/etc. menus to find a shortcut.

**File** — New `Ctrl+N` · Open `Ctrl+O` · Save `Ctrl+S` · Close `Ctrl+W`

**Edit** — Undo `Ctrl+Z` · Redo `Ctrl+Y` · Cut `Ctrl+X` · Copy `Ctrl+C` · Paste `Ctrl+V` · Paste as comment `Ctrl+Shift+V` · Insert comments `Ctrl+B` · Remove comments `Ctrl+Shift+B` · Format indentation `Ctrl+I` · Select All `Ctrl+A` · Goto `Ctrl+G` · Goto matching keyword `Ctrl+K` · Goto recent line `Ctrl+L` · Toggle current fold `F4` · Toggle all folds `Ctrl+F4` · Add/remove marker `Ctrl+F2` · Jump to marker `F2` · Find/Replace `Ctrl+F` · **Find Next `F3`** · **Find Previous `Shift+F3`** · Find in Files `Ctrl+Shift+F` · Replace `Ctrl+H`

**Project** — New Project `Ctrl+Shift+N` · Open Project `Ctrl+Shift+O` · Close Project `Ctrl+Shift+W` · Add Project File `Ctrl+Shift+A` · Remove Project File `Ctrl+Shift+R`

**Compiler** — Compile/Run `F5` · Run (already-compiled exe) `Shift+F5`

**Debugger** — Stop `F6` · Continue `F7` · Step `F8` · Step (into, alt) `Ctrl+F8` · Step Over `F10` · Step Out `F11` · Breakpoint `F9`

**Tools** — Visual Designer `Alt+V` · Structure Viewer `Alt+S` · ASCII Table `Alt+A` · Explorer `Alt+X` (Variable Viewer/Color Picker have no default — they'd collide with the above)

**Help** — Help `F1`

**Editor-only (no menu, "Shortcuts" language group)** — Next/Previous opened file `Ctrl+Tab` / `Ctrl+Shift+Tab` · Shift comment right/left `Ctrl+E` / `Ctrl+Shift+E` · Select/Deselect block `Ctrl+M` / `Ctrl+Shift+M` · Move line(s) up/down `Ctrl+Shift+Up` / `Ctrl+Shift+Down` · Duplicate selection `Ctrl+D` · Upper/Lower/Invert case `Ctrl+Shift+U` / `Ctrl+Shift+L` / `Ctrl+Shift+X` · Zoom in/out/default `Ctrl+=` / `Ctrl+-` / `Ctrl+0` · AutoComplete `Ctrl+Space` (confirm `Tab`, abort `Esc`) · Update procedure list `F12`

**Reserved by the OS (never assignable on Windows)** — `Ctrl+Alt+Delete`, `Alt+Tab`, `Alt+F4`

Not in this table (bound outside the customizable shortcut system, e.g. native OS menu accelerators): **Quit** (`Ctrl+Q` in practice, see above).

## Code style — enforced, not optional

- **`.editorconfig` governs everything** and is checked in CI (`validate.sh`, using `eclint`) — run `bash validate.sh` before committing if you're touching more than trivial content. Key rules: PureBasic files (`.pb`/`.pbi`/`.pbf`) are UTF-8 **with BOM**, indentation is spaces; C files use 2-space indent; makefiles keep tabs/LF as-is.
- **Never let the PureBasic IDE save settings into source files.** If a `.pb` file starts accumulating a trailing `; IDE Options = ...` comment block, strip it — `validate.sh` fails the build if any file contains one. Per-directory `project.cfg` / per-file `*.pb.cfg` are fine and gitignored.
- PureBasic source formatting is normalized via the IDE's own "Edit ▸ Format indentation" (Ctrl+I) — that's the project's de facto linter for `.pb` files (EditorConfig doesn't cover PB indentation style).

## Architecture

- **`PureBasicIDE/`** — the IDE itself. `PureBasic.pb` is the single entry point: essentially everything (IDE logic, the embedded debugger GUI, dialog manager, form designer) is pulled in from there via `XIncludeFile`, by design, to avoid tracking include dependencies per-file. Reading `PureBasic.pb` top-to-bottom is the fastest way to see how the pieces fit together. `dialogs/*.xml` are GUI layouts compiled by the DialogManager's `DialogCompiler` into generated `.pb` files under `Build/` at build time — don't hand-edit generated dialog `.pb` files, edit the `.xml` and rebuild.
- **`PureBasicDebugger/`** — the standalone/embedded debugger engine (communication with the debugged process via named pipes on Windows/Unix, variable/memory/library viewers, profiler, purifier). Shared by the IDE (embedded) and as a standalone executable.
- **`DialogManager/`** — a declarative dialog/GUI layout system (`Object_*.pb` per widget type: Window, Gadget, Box, Panel, Splitter, etc.) used by both the IDE and its `DialogCompiler` tool to turn XML dialog definitions into PureBasic source.
- **`CollectLanguage/`** — a small standalone tool that scans/updates the IDE's `.catalog` translation files (`Documentation/Catalogs/*.catalog`) for editor/debugger/compiler string tables.
- **`Residents/`** — OS/target-specific "resident" include files (constants, structures, external declarations) that back PureBasic's built-in libraries; split by platform (`Windows/`, `Linux/`, `MacOS/`, `JavaScript/` for SpiderBasic) plus shared `Common.pb`. These mirror internals of the (closed-source) compiler and must stay structurally in sync with it.
- **`Documentation/`** — the actual PureBasic/SpiderBasic reference manual sources, one `.txt` (DocMaker markup, not plain text) per library/topic per language (`English/`, `German/`, `French/`), plus `Catalogs/` (i18n string tables) and `DocumentationOutput/`/`Build/` (generated, not source). `AsciiDoc/` holds separate longer-form guides (SDK, DLL importer, etc.) in real AsciiDoc format.
- **`PureBasicConfigPath.pb`** — shared helper resolving the per-OS PureBasic config directory; included from multiple tools.

## Licensing note

Dual-licensed GPLv3 / Fantaisie Software License (see `LICENSE`, `LICENSE-FANTAISIE`); by convention every contributed change grants Fantaisie Software rights to the contribution — don't add alternate license headers to files.
