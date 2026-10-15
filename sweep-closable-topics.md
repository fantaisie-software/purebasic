# IDE bug sweep: forum topics that can be closed (second batch)

Not meant to be merged: this file only exists so the list can be reviewed on GitHub. The earlier lists were tagged [Done] already, so this one only has the topics handled since.

## Fixed (merged PR or fixed earlier)

- https://www.purebasic.fr/english/viewtopic.php?t=64480 (Form Designer shortcut with Ctrl+Shift lost its key, #485)
- https://www.purebasic.fr/english/viewtopic.php?t=64531 (Form Designer +/- shortcut keys gave invalid constants, #485)
- https://www.purebasic.fr/english/viewtopic.php?t=65656 (Issues Update button moved below the settings, #489)
- https://www.purebasic.fr/english/viewtopic.php?t=67621 (GIF/TGA/TIFF images in the Form Designer and the File Viewer, #486)
- https://www.purebasic.fr/english/viewtopic.php?t=70414 (negative status bar field width crashed the Form Designer, #487)
- https://www.purebasic.fr/english/viewtopic.php?t=79682 (adjacent submenus in the Form Designer, #449)
- https://www.purebasic.fr/english/viewtopic.php?t=79683 (submenu followed by a separator in the Form Designer, #449)
- https://www.purebasic.fr/english/viewtopic.php?t=81966 (Edit Tool Settings trigger combobox cut off with long translations, #491)
- https://www.purebasic.fr/english/viewtopic.php?t=82707 (lines left unstyled after MoveLineUp + Undo + Redo, #492)
- https://www.purebasic.fr/english/viewtopic.php?t=87066 (same bug as 82707: highlight boxes growing after undo, #492)
- https://www.purebasic.fr/english/viewtopic.php?t=85714 (Ctrl+I on a partial selection after a ";{" line, #429)
- https://www.purebasic.fr/english/viewtopic.php?t=88200 (project files list not scrolling: wrong FullRowSelect flag removed, #341)
- https://www.purebasic.fr/english/viewtopic.php?t=88705 ("String not found" priority in the Preferences issue list, #466)
- https://www.purebasic.fr/english/viewtopic.php?t=86356 (structure AutoComplete on the first "\", Fred replied "Fixed.")
- https://www.purebasic.fr/english/viewtopic.php?t=85553 (DebuggerWarning/DebuggerError with Unicode text, fixed in Libraries/Debugger/DebuggerFunctions)
- https://www.purebasic.fr/english/viewtopic.php?t=72387 (project file unloadable with an emoji in the computer name: Xml UTF-8 export, local Libraries/Xml fix in SVN)
- https://www.purebasic.fr/english/viewtopic.php?t=81751 (Variable Viewer never finishing on a 2M-element list: local Libraries/Debugger fix in SVN)
- https://www.purebasic.fr/english/viewtopic.php?t=89505 (Ctrl+C/V in the Form Designer properties: fixed by the PR from t=89458, confirmed by the reporter, and #458)
- https://www.purebasic.fr/english/viewtopic.php?t=89691 (Ctrl+F cut the last character after an emoji, #471)
- https://www.purebasic.fr/english/viewtopic.php?t=72657 (folder locked after F5 and closing the tab: the resident compiler stayed in the source folder, local Compiler/ExternalCommunication.c fix in SVN, tested on Windows 11)
- https://www.purebasic.fr/english/viewtopic.php?t=69771 (same as 72657)
- https://www.purebasic.fr/english/viewtopic.php?t=83765 (French messages: fixed by #493; the linker error is now an English message from the 6.50 linker)

## Obsolete

- https://www.purebasic.fr/english/viewtopic.php?t=69704 (Save As of a project file now relinks the source to the project)
- https://www.purebasic.fr/english/viewtopic.php?t=71209 (window position and size are stored; column widths are a feature request)
- https://www.purebasic.fr/english/viewtopic.php?t=72701 (;TODO/;FIXME highlight with CJK text works)
- https://www.purebasic.fr/english/viewtopic.php?t=73741 (several files changed on disk: one reload prompt after the other, all reloaded)
- https://www.purebasic.fr/english/viewtopic.php?t=76264 (help language follows the IDE language without a restart)
- https://www.purebasic.fr/english/viewtopic.php?t=80654 (Procedure Browser shows ;- markers with bullets correctly)
- https://www.purebasic.fr/english/viewtopic.php?t=82478 (inactive selection colors now follow the Selection colors)
- https://www.purebasic.fr/english/viewtopic.php?t=84624 ('=' in a gadget caption)
- https://www.purebasic.fr/english/viewtopic.php?t=85450 (EnableASM in a Module no longer stops the highlighting)
- https://www.purebasic.fr/english/viewtopic.php?t=87238 (Quick Help typos: none of the listed misspellings remain)
- https://www.purebasic.fr/english/viewtopic.php?t=89631 (Procedure Browser sort by name is correct on current devel)
- https://www.purebasic.fr/english/viewtopic.php?t=63430 (Form Designer fonts at high DPI are readable on Windows 11 at 200%)
- https://www.purebasic.fr/english/viewtopic.php?t=66951 (Windows 8 skin issues; the Form Designer is in tabs now)

## Not a bug

- https://www.purebasic.fr/english/viewtopic.php?t=65782 (AutoComplete through a macro: the macro was the cause)
- https://www.purebasic.fr/english/viewtopic.php?t=82329 ('Add Timestamp' is for the Debug Output window, the error log has its own timestamps)
- https://www.purebasic.fr/english/viewtopic.php?t=86351 (Preferences window on a 1366x768 screen at 125%: Fred, Enter applies the settings)
- https://www.purebasic.fr/english/viewtopic.php?t=87991 (new sources are UTF-8 with BOM; files opened without a BOM keep their encoding)
- https://www.purebasic.fr/english/viewtopic.php?t=88686 (Syntax Check shows the compile progress window briefly, like a compile)
- https://www.purebasic.fr/english/viewtopic.php?t=87810 (the font Script setting doesn't matter: the editor is UTF-8, Central European text displays with the default font)
- https://www.purebasic.fr/english/viewtopic.php?t=83367 (only when debugging the IDE itself; the release build is fine)

## Not reproducible on current devel

- https://www.purebasic.fr/english/viewtopic.php?t=67517 (nested and trailing submenus survive design/code round trips)
- https://www.purebasic.fr/english/viewtopic.php?t=71983 (dark tools panel color kept after run and tab switch)
- https://www.purebasic.fr/english/viewtopic.php?t=74404 (reload after an external change always works)
- https://www.purebasic.fr/english/viewtopic.php?t=80566 (copy/paste of a Procedure line then undo)
- https://www.purebasic.fr/english/viewtopic.php?t=82108 (OnError checkbox follows the selected target)
- https://www.purebasic.fr/english/viewtopic.php?t=82444 (Find window position: reporter's cause was a stale position from an 8K monitor)
- https://www.purebasic.fr/english/viewtopic.php?t=85240 (status bar call tip for interface methods)
- https://www.purebasic.fr/english/viewtopic.php?t=88430 (unsaved source run with F5 works on Windows 11)
- https://www.purebasic.fr/english/viewtopic.php?t=87955 (Form properties are clickable right away on Windows 11)
- https://www.purebasic.fr/english/viewtopic.php?t=88533 (selecting text in the About window then OK: no crash on Linux and Windows 11)
- https://www.purebasic.fr/english/viewtopic.php?t=79633 (property cell in edit mode + F5 + typing: no crash on Linux and Windows 11)
- https://www.purebasic.fr/english/viewtopic.php?t=65309 (Library Viewer shows all XML nodes of the sample on Linux and Windows 11)
- https://www.purebasic.fr/english/viewtopic.php?t=82493 (the IDE gets the focus back after the Variable Viewer was used, Windows 11)
- https://www.purebasic.fr/english/viewtopic.php?t=87520 (Find in Files result opens the already open tab, Linux and Windows 11)

## Too vague (no steps, image gone, sporadic old crashes)

- https://www.purebasic.fr/english/viewtopic.php?t=66867
- https://www.purebasic.fr/english/viewtopic.php?t=67726
- https://www.purebasic.fr/english/viewtopic.php?t=72750
- https://www.purebasic.fr/english/viewtopic.php?t=73215
- https://www.purebasic.fr/english/viewtopic.php?t=79492
- https://www.purebasic.fr/english/viewtopic.php?t=82893
- https://www.purebasic.fr/english/viewtopic.php?t=83564
- https://www.purebasic.fr/english/viewtopic.php?t=84373
- https://www.purebasic.fr/english/viewtopic.php?t=86288 (title "HiDPI" and one image, now an "unavailable" placeholder)

## Not included on purpose

- Open PRs: 85884 (#495), 86395 (#496), 86810 (#497), 87302 (#498), 88325 (#499), 88326 (#500), 88959 (#468), 89414 (#502), 65191 (#420), 66473 (#421), 85913 (#503), 82386 (#504).
- Still to check on Windows or macOS, decisions for the maintainer, and feature requests (listed in the sweep report).
