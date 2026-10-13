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
- Never commit directly to a local `devel`/`master` checkout — work happens on topic branches cut from `devel` (see CONTRIBUTING.md for the full fork/rebase workflow, which is written for outside contributors working from a personal fork).
- **Pull before starting each task** with a rebase (`git checkout devel && git pull --rebase`), so the reproduction, the fix and the new branch are based on the current `devel` — PRs get merged while you work. If the user's local uncommitted changes (e.g. `PureBasicIDE.pbp`) block the rebase, use `git fetch origin && git merge --ff-only origin/devel` instead (equivalent, as local `devel` has no own commits) — never stash them. Rebuild the IDE after pulling before testing anything.

## Creating a Pull Request

`origin` in this checkout is the upstream repo itself
(`fantaisie-software/purebasic`), not a personal fork — the maintainer's `gh`
account has direct push rights, so CONTRIBUTING.md's fork-based flow (steps 1-4:
fork, clone the fork, add an `upstream` remote) does not apply here. Push
straight to `origin` and open the PR from there:

1. **Confirm `gh` is available and authenticated** — `gh auth status`. If `gh`
   is reported as not found even though it's installed, the terminal's `PATH`
   was captured before `gh` was added to it; ask the maintainer to relaunch
   VS Code/the terminal rather than trying to work around it.
2. **Branch from `origin/devel`**, not from whatever branch happens to be
   checked out — an existing checked-out branch may already carry an
   unrelated fix/PR of its own, and mixing a new, unrelated change into it
   pollutes that PR. `git fetch origin devel` then
   `git checkout -b <topic-branch-name> origin/devel`.
3. **If the working tree already has unrelated uncommitted changes** (common
   in this repo — see the `## Building` warning about generated files ending
   up tracked), do not carry them onto the new branch. Move only the files
   this task actually touched with a pathspec'd stash:
   `git stash push -u -m "<description>" -- <file1> <file2> …`, then
   `git checkout -b <topic-branch-name> origin/devel`, then `git stash pop`.
   Confirm with `git status` that only the intended files are
   staged/modified before committing — never `git add -A` in this repo.
4. **Commit** only the relevant files (`git add <file> <file> …`, not `-A`),
   with a message explaining the *why*, referencing the forum/issue URL if
   there is one.
5. **Push and open the PR**:
   ```
   git push -u origin <topic-branch-name>
   gh pr create --base devel --head <topic-branch-name> --title "…" --body-file <path-to-body.md>
   ```
   Always pass the PR body via `--body-file` (a temp file written first),
   never inline via a bash heredoc — a body containing nested backticks/code
   fences and parentheses (near-unavoidable when the description quotes code
   or file names) can break heredoc quoting and abort the command.
   **Include before/after screenshots** in the PR body whenever the bug is
   visible (the user asked for it). `gh` can't attach images, so they are
   hosted on the orphan branch `pr-screenshots` of origin: crop them to the
   relevant window (no other apps, no session/terminal content), name them
   `<PR#>-before.png` / `<PR#>-after.png`, commit them from a separate temp
   repo in the scratchpad (`git init` + `checkout --orphan pr-screenshots`,
   fetch the existing branch first so earlier images are kept) and push, then
   link `https://raw.githubusercontent.com/fantaisie-software/purebasic/pr-screenshots/<file>`
   in a `**Screenshots:**` section above the footer.
   When editing an existing PR body with `gh pr edit --body-file`, always check
   the file is non-empty and contains the full text first: an empty file wipes
   the description (recoverable via the GraphQL `userContentEdits` history).
   To add images to the `pr-screenshots` checkout in the scratchpad, run `git fetch origin pr-screenshots && git reset --keep origin/pr-screenshots`, then add the files, commit and `git push origin HEAD:pr-screenshots`. The PR number is only known after `gh pr create`. So write the body with a `PRNUM` placeholder, then replace it, upload the images, and update the body with `gh pr edit --body-file`.
6. Report the PR URL from the `gh pr create` output back to the user.
7. `git checkout -q devel` afterwards, so the next task starts from `devel`.

Editing tips:
- Preserve the UTF-8 BOM of `.pb`/`.pbi` files.
- Preserve the indentation that the IDE keeps on blank lines inside procedures: some edit tools strip it. Check `git diff` for spurious whitespace-only changes before committing.
- Keep each fix minimal and match the surrounding style.

## Sweeping the forum bug sections

When asked to sweep a forum section (e.g. "Bugs - IDE", https://www.purebasic.fr/english/viewforum.php?f=42):

- List all topics and process them in **ascending topic-id order**. Skip topics whose title starts with `[Done]`. Retrieving topics is described in `<SvnRoot>\Libraries\AGENTS.md`.
- For each topic, read the whole thread: later posts often contain the real repro, or say it was already fixed. Reproduce the bug on current `devel` before touching code. If it doesn't reproduce, record it as *not reproducible* (with the platform tested), not as fixed.
- For each real bug, do one branch and one PR, following the steps above, with before/after screenshots when the bug is visible. Put the topic URL in the commit message and the PR body.
- Platform-specific topics go to the matching box (Linux/macOS sections above). If a box is off, list the topic as pending, and don't guess a fix you can't test.
- Don't fix feature requests or design limitations. Collect anything that needs a decision (behaviour change, larger rework) for the maintainer.
- Report at the end, **always with the full clickable topic URL** `https://www.purebasic.fr/english/viewtopic.php?t=NNNNN` for every topic mentioned, grouped as:
  - PRs opened (with PR URLs);
  - not reproducible;
  - obsolete or already fixed;
  - too vague;
  - feature request or design limitation;
  - waiting on another platform;
  - decisions for the maintainer.
- After the round, rebuild the local Windows IDE from `devel`, so the installed build doesn't carry a topic branch's fix, and remove any remote worktrees or clones you created.

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
- **Clear the remembered open files before each launch:** the portable prefs (`<SvnRoot>\Build\PureBasic_x64\PureBasic.prefs`) reopen every file that was open at the last quit (`OpenedFile_N` lines under `[OpenedFiles]`). These pile up from test to test and make each startup slow. While the IDE is closed, delete the lines under `[OpenedFiles]` (keep the section header and the file's UTF-8 BOM), so the IDE only opens the file given on the command line. Do the same in `/tmp/pbtest/purebasic.prefs` on Linux.
- **Quitting cleanly (avoids the "previous session ended improperly" recovery dialog on next launch):** don't force-kill the process. If you made throwaway edits to the test file (e.g. while reproducing an editor bug), press **Ctrl+Z repeatedly first to undo them back to the unmodified state**, then quit with **File ▸ Quit** (keys: `Esc`, `Alt+F`, `Up`, `Enter` — Quit is the last item) — this does a clean shutdown. **There is no Quit shortcut on Windows/Linux** (`ShortcutManagement.pb` binds `"File", "Quit"` to 0), so Ctrl+Q does nothing. If the file is still modified, a "save it now?" dialog appears: answer **No** (`n`). Send `Esc` before typing into the IDE right after focusing it with an Alt-key trick, or the first character is eaten by the menu bar. Force-killing (`Stop-Process -Force`) works but leaves a "session ended improperly" prompt that steals focus on the next launch and must be dismissed (click "Non"/"No") before automating further keystrokes.
- To build the "before the fix" IDE for a comparison, don't juggle `git stash`:
  copy the fixed file to the scratchpad, write the original over it with
  `cmd /c "git show HEAD:PureBasicIDE/<File>.pb > PureBasicIDE\<File>.pb"`,
  run `make`, test, then copy the fixed file back. Close the IDE first
  (`make` fails while `PureBasic.exe` is running).
- Driving the UI (SendKeys, screenshots, window-handle focus tricks) is inherently timing-sensitive — poll for the expected window/dialog to actually appear (e.g. via `EnumWindows` for the "Find/Replace" title) rather than using a fixed sleep before typing into it, otherwise keystrokes can race the dialog and land in the source editor instead.
- **The dev machine runs a 4K display at 175% (168 DPI).** Screenshots taken with `CopyFromScreen` are in physical pixels, and the IDE's main window sits at about `-12,-12` (3864x2100). When you click with `SetCursorPos`/`mouse_event`, use physical pixels: a position read off a downscaled screenshot must be scaled back first. Many IDE bugs only show at this scaling, e.g. canvas-drawn widgets that compare unscaled gadget sizes with scaled pixel coordinates. Always ask whether a layout or hit-test bug is a missing `DesktopScaledX/Y()`.
- **SendKeys pitfalls:**
  - `SendKeys` can't produce Ctrl+Space (AutoComplete). Use `keybd_event` (VK_CONTROL down, VK_SPACE down/up, VK_CONTROL up) instead.
  - A minimized IDE window sits at `-32000,-32000` and ignores keys. Restore it with `ShowWindow(hwnd, 3)` before `SetForegroundWindow`.
  - A tool window or modal dialog that is still open (Memory Viewer, a requester) makes the File ▸ Quit keys go nowhere. Close it first, and if a "save?" or "session ended improperly" prompt appears, click its No/Non/Cancel/Annuler button by handle (`FindWindowEx` on the `Button` class).
  - Dialogs remember their last combo/option state across runs, so start the IDE fresh for each repro run, or press `Home` before the arrow keys in a combo.
- To screenshot a simulated condition (e.g. a different system colour) that you can't reproduce on the machine, a throwaway build that hard-codes the condition is fine for the PR images. Restore the touched file afterwards and never commit it.
- Write helper scripts (launch with prefs cleanup, clean quit, click/drag/right-click at physical coordinates, window move/resize, fetch a forum topic) once into the scratchpad and reuse them. PowerShell `Add-Type` class names are global per session, so give each helper class a unique name (e.g. `DragM`, not `M`), or the second script fails with "type already exists".

### Testing on Linux (remote box)

Linux-only IDE bugs are tested on **`fred@192.168.0.61`** (Ubuntu 24.04 x64, GTK3, live GNOME session on Xwayland). Connect with `plink -batch fred@192.168.0.61 '<cmd>'` and copy files with `pscp -batch -q` (Pageant auth, no password; if the connection fails the box is off — ask the maintainer to start it). The other boxes are listed in `<SvnRoot>\Libraries\AGENTS.md` §2.3.1.

- **Building:** the box has the tree at `~/svn/v6.50` and a clone of this repo at `~/svn/v6.50/GitHub/purebasic` (the maintainer's working copy — don't edit or switch branches there). Work in a throwaway clone: `git clone -q ~/svn/v6.50/GitHub/purebasic /tmp/pbide`, set its `origin` to the GitHub URL and fetch your branch, or `pscp` the changed files over. Build with `cd ~/svn/v6.50 && . ./start >/tmp/start.log 2>&1; cd /tmp/pbide/PureBasicIDE && make`. The IDE goes to `$PUREBASIC_HOME/compilers/purebasic` (`~/svn/v6.50/Build/purebasic`), and **overwriting that installed IDE is fine** — no separate install needed. Never pipe `. ./start` (the exports are lost in the subshell).
- **Settings:** `/PORTABLE` is Windows-only. Keep the user's `~/.purebasic` untouched by starting the IDE with `-p /tmp/pbtest/purebasic.prefs -t /tmp/pbtest/templates.prefs -a /tmp/pbtest/tools.prefs -H /tmp/pbtest/history.db`. A prefs file only exists after a clean quit (**File ▸ Quit**, e.g. `xdotool key alt+f Up Return` — there is no Quit shortcut); edit it with `sed` only while the IDE is closed, as it is rewritten on exit.
- **Display:** run GUI commands with `DISPLAY=:0`, `XAUTHORITY=$(ls /run/user/1000/.mutter-Xwaylandauth.* | head -1)` and `GDK_BACKEND=x11`, start the IDE with `nohup … &`, and drive it with `xdotool` (`key`, `type`, `mousemove X Y click 1`, `mousemove --window W x y`).
  - Several windows can share the IDE title (mutter frame windows): pick the one whose `xdotool getwindowpid` is the IDE's pid before `windowactivate`, or keys go nowhere.
  - **Don't use `xdotool windowclose`** on the IDE: it destroys the X window but leaves the process running. Quit with File ▸ Quit.
  - Send typing and a following shortcut (Ctrl+Space, a menu key) as separate steps with a short sleep; menus opened from a busy IDE can take seconds to paint.
- **Screenshots:** the Xwayland root window captures as solid black (rootless), so capture each X window instead: with Python `gi` (`GdkX11.X11Window.foreign_new_for_display(display, xid)` + `Gdk.pixbuf_get_from_window`), and paste every visible window of the process (`xdotool search --onlyvisible --pid <pid>`) at its `get_origin()` onto one PIL canvas — that also shows menus and popups. `scrot` captures black for the same reason.
- **Debugging:** `ptrace_scope` is 1, so `gdb -p` can't attach to a running IDE; start the program under `gdb` or `valgrind` instead (valgrind is installed and shows heap overflows directly).
- **Fixes in the closed-source libraries** (`<SvnRoot>\Libraries`, e.g. a Gadget bug found while testing): follow that tree's AGENTS.md — edit locally first, `pscp` to the same path under `~/svn/v6.50/Libraries`, build that library (setting `PB_BUILDTARGET` to a directory under `/tmp` keeps the objects out of the tree), test, then `svn revert -- <file>` on the box. Never run `svn` locally. Report the changed local file — it's not part of a GitHub PR.
- **Scripts over inline commands:** when you call `plink` from PowerShell, PowerShell expands `$(...)` and `$VAR` inside the command string before it reaches the box. Put anything non-trivial in a script under `/tmp/pbtest`, `pscp` it over and run it: an `env.sh` exporting DISPLAY/XAUTHORITY/GDK_BACKEND, a `run.sh` that clears `[OpenedFiles]` and starts the IDE, a `findwin.sh`, and a `shot.py` for the window capture.
- After a forced kill, the next launch shows the recovery prompt. Its **No** button is at about window-relative (168,135).
- Clean up afterwards: `pkill -x <name>` (exact name, never `pkill -f`) for anything you started, and remove your files under `/tmp`.

### Testing on macOS (remote box)

macOS-only IDE bugs are tested on **`fred@192.168.0.91`** (macOS 15, arm64, with the same `plink`/`pscp` access as Linux).

- **Shell:** the login shell is zsh, and `. ./start` fails under zsh (SetEnvironment). Always wrap the build in bash: `bash -c "cd ~/svn/v6.50 && . ./start >/tmp/start.log 2>&1; cd ~/pbwt/PureBasicIDE && make"`.
- **Building:** the maintainer's checkout `~/svn/v6.50/GitHub/purebasic` must stay untouched; it may be behind `devel`. Build from a worktree instead: `git -C ~/svn/v6.50/GitHub/purebasic worktree add --detach ~/pbwt origin/devel` after a fetch, then copy or check out your changes there. Remove it at the end with `git worktree remove ~/pbwt`. The built IDE is `~/svn/v6.50/Build/purebasic_arm64/PureBasic.app`.
- **Running:** use separate prefs, as on Linux: `open -n …/PureBasic.app --args -p /tmp/pbtest/purebasic.prefs -t /tmp/pbtest/templates.prefs -a /tmp/pbtest/tools.prefs -H /tmp/pbtest/history.db <file>`. Clear `[OpenedFiles]` first, using `sed -i ''` (BSD sed).
- **Driving the UI:** `osascript` with System Events works over SSH, because Accessibility is granted. Use it to list windows (`get {name, position, size} of windows of process "PureBasic"`) and to send keystrokes and menu clicks.
- **Screenshots: not working yet over SSH.** `screencapture` run from the SSH session captures only the desktop and menu bar, with no app windows, even after granting Screen Recording. On macOS 15 the session process is `/usr/libexec/sshd-session`, which needs its own Screen Recording grant. `launchctl asuser` is not permitted. Running `screencapture` through Terminal.app (`osascript … tell application "Terminal" to do script`) blocks on an automation consent prompt until someone answers it on the Mac. Until this works, test macOS bugs without screenshots, or ask the maintainer for one.

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

**Quit** has **no default shortcut** on Windows/Linux (Ctrl+Q does nothing) — use File ▸ Quit, see above.

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
