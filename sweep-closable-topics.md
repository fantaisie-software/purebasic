# IDE bug sweep: forum topics that can be closed

Not meant to be merged: this file only exists so the list can be reviewed on GitHub. The first list (fixed topics) was tagged [Done] already.

## Obsolete or fixed since the first list

- https://www.purebasic.fr/english/viewtopic.php?t=55109 (Form Designer toolbar offset: designer and runtime match on Linux, Windows code adds `ToolBarHeight()` to the Y)
- https://www.purebasic.fr/english/viewtopic.php?t=63085 (the Max property label is shown for ProgressBar and similar gadgets)
- https://www.purebasic.fr/english/viewtopic.php?t=66270 (typing the Turkish İ inserts it correctly and keeps the line; Fred also said fixed)

## Not a bug

- https://www.purebasic.fr/english/viewtopic.php?t=47316 (blank area above the list is GTK3's combo popup placement; entries are correct)
- https://www.purebasic.fr/english/viewtopic.php?t=57058 (GTK theme issue on the user's side, solved by the user)
- https://www.purebasic.fr/english/viewtopic.php?t=61213 (Form Designer menu/toolbar/statusbar ids, answered in the thread)

## Not reproducible on current devel

- https://www.purebasic.fr/english/viewtopic.php?t=48951 (48px custom toolbar icons, layout fine (Linux GTK3))
- https://www.purebasic.fr/english/viewtopic.php?t=50397 (Variable Viewer > Add to Watchlist on a local variable works (Linux))
- https://www.purebasic.fr/english/viewtopic.php?t=51380 (no steps; Fred could not reproduce either)
- https://www.purebasic.fr/english/viewtopic.php?t=52263 (standalone debugger keeps its moved position after Preferences OK (Linux; the 2012 report was probably Windows))
- https://www.purebasic.fr/english/viewtopic.php?t=53597 (quit hang on Windows, nobody else could reproduce)
- https://www.purebasic.fr/english/viewtopic.php?t=54610 (panel items add/delete in the Form Designer, no error, no crash (Linux))
- https://www.purebasic.fr/english/viewtopic.php?t=60854 (200k string in the Variable Viewer, stepping is fine (Linux))
- https://www.purebasic.fr/english/viewtopic.php?t=62093 (disabling the history: dialog closes and the IDE stays responsive; Fred could not reproduce the project slowdown either)
- https://www.purebasic.fr/english/viewtopic.php?t=63135 (rebuilt form (splitter on a panel tab) reopens correctly; the original zip is gone)
- https://www.purebasic.fr/english/viewtopic.php?t=65386 (Explorer tool home folder expands fine, valgrind clean (Linux, French locale))
- https://www.purebasic.fr/english/viewtopic.php?t=71457 (Ctrl+double-click to go to a procedure leaves no selection (Linux))
- https://www.purebasic.fr/english/viewtopic.php?t=71491 (RunOnce: the file goes to the running IDE, which stays responsive (Linux, PR #460))
- https://www.purebasic.fr/english/viewtopic.php?t=71532 (project from the thread: AutoComplete edits, compile, 6x undo/redo consistent (Linux))
- https://www.purebasic.fr/english/viewtopic.php?t=73171 (AutoComplete stuck, sporadic; AutoComplete focus fixes merged in #465)
- https://www.purebasic.fr/english/viewtopic.php?t=83861 (narrow IDE window: width unchanged, status bar text ellipsized (Linux GTK3))
- https://www.purebasic.fr/english/viewtopic.php?t=88228 (project with `<log show="0"/>` opens, no crash (Linux))

## Too vague (no steps, images gone, sporadic old crashes)

- https://www.purebasic.fr/english/viewtopic.php?t=55309 (random old crash)
- https://www.purebasic.fr/english/viewtopic.php?t=53643 (procedure panel colors, images gone)
- https://www.purebasic.fr/english/viewtopic.php?t=60766 (random colors)
- https://www.purebasic.fr/english/viewtopic.php?t=66142 (Form Designer font background color, images gone)
- https://www.purebasic.fr/english/viewtopic.php?t=71918 (sporadic old crash, Fred could not reproduce)
- https://www.purebasic.fr/english/viewtopic.php?t=72655 (sporadic GTK2 rbtree assert)
- https://www.purebasic.fr/english/viewtopic.php?t=81204 (procedure list sometimes empty)
- https://www.purebasic.fr/english/viewtopic.php?t=89345 (IDE slow plus an error message, image only)

## Not included on purpose

- Not reproducible on Linux, Windows check still pending: 87520 (Find in Files opens a second tab), 65309 (Library Viewer XML nodes).
- Now fixed by PRs instead: 65294 (#488), 65656 (#489).
- Feature requests (37332, 45662, 55881, 56552, 56967, 59948, 60162, 64634): your call whether to close or move them.
