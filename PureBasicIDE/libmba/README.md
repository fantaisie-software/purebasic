# libmba

C sources from the __[libmba]__ library by Michael B. Allen ([MIT License]).


-----

**Table of Contents**

<!-- MarkdownTOC autolink="true" bracket="round" autoanchor="false" lowercase="only_ascii" uri_encoding="true" levels="1,2,3" -->

- [Folder Contents](#folder-contents)
- [About Libmba](#about-libmba)
    - [File Changes and Notes](#file-changes-and-notes)
- [Project Usage](#project-usage)
    - [The Libmba Diff Algorithm](#the-libmba-diff-algorithm)
- [License](#license)

<!-- /MarkdownTOC -->

-----

# Folder Contents

- [`/mba/`](./mba/) — header files of libmba modules.
- [`Makefile`][Makefile] — used by the PureBasic IDE build chain.
- [`allocator.c`][allocator.c]
- [`bitset.c`][bitset.c]
- [`cfg.c`][cfg.c] — _unused_.
- [`csv.c`][csv.c]
- [`daemon.c`][daemon.c] — _unused_.
- [`dbug.c`][dbug.c]
- [`diff.c`][diff.c] — target libmba module used by the PureBasic IDE.
- [`eval.c`][eval.c]
- [`hashmap.c`][hashmap.c]
- [`hexdump.c`][hexdump.c]
- [`linkedlist.c`][linkedlist.c]
- [`misc.c`][misc.c]
- [`msgno.c`][msgno.c]
- [`path.c`][path.c]
- [`pool.c`][pool.c]
- [`shellout.c`][shellout.c] — _unused_.
- [`stack.c`][stack.c]
- [`suba.c`][suba.c]
- [`svcond.c`][svcond.c] — _unused_.
- [`svsem.c`][svsem.c] — _unused_.
- [`text.c`][text.c] — _unused_.
- [`time.c`][time.c]
- [`varray.c`][varray.c]

# About Libmba

Libmba is a library of generic C modules, created by Michael B. Allen.
From the __libmba__ home page:

> The libmba package is a collection of mostly independent C modules potentially useful to any project.
> There are the usual ADTs including a linkedlist, hashmap, pool, stack, and varray, a flexible memory allocator, CSV parser, path canonicalization routine, I18N text abstraction, configuration file module, portable semaphores, condition variables and more.
> The code is designed so that individual modules can be integrated into existing codebases rather than requiring the user to commit to the entire library.
> The code has no typedefs, few comments, and extensive man pages and HTML documentation.

The files in this directory tree were taken from __libmba v0.9.1__ (Apr 29, 2005).

## File Changes and Notes

The [`allocator.c`][allocator.c] module was tweaked to solve memory management problems under Windows.

The [`suba.c`][suba.c] differs slightly from the upstream version in a couple of places (LL 293–295, 326).

The [`cfg.c`][cfg.c] module fails to compile on OS X, and was excluded from the project.

# Project Usage

The project only requires the [`diff.c`][diff.c] module and its dependencies from __libmba__:

- [`allocator.c`][allocator.c]
- [`bitset.c`][bitset.c]
- [`csv.c`][csv.c]
- [`dbug.c`][dbug.c]
- [`diff.c`][diff.c]
- [`eval.c`][eval.c]
- [`hashmap.c`][hashmap.c]
- [`hexdump.c`][hexdump.c]
- [`linkedlist.c`][linkedlist.c]
- [`misc.c`][misc.c]
- [`msgno.c`][msgno.c]
- [`path.c`][path.c]
- [`pool.c`][pool.c]
- [`stack.c`][stack.c]
- [`suba.c`][suba.c]
- [`time.c`][time.c]
- [`varray.c`][varray.c]

which are compiled to a static library (`libmba.lib`/`libmba.a`).
The other __libmba__ modules are not used by this project.

The PureBasic IDE uses the diff algorithm from __libmba__ to track file changes for the session history in [`../EditHistory.pb`][EditHistory.pb] (LL 58–72):

```purebasic
;- Libmba stuff
;
CompilerIf #CompileWindows
  ImportC #BUILD_DIRECTORY + "libmba/libmba.lib"
  CompilerElse
    ImportC #BUILD_DIRECTORY + "libmba/libmba.a"
    CompilerEndIf

    diff.l(*a, aoff.l, n.l, *b, boff.l, m.l, *idx_fn, *cmp_fn, *context, dmax.l, *ses, *sn.LONG, *buf)

    varray_new(membsize, *al)
    varray_del.l(*va)
    varray_get(*va, idx)

  EndImport
```

## The Libmba Diff Algorithm

From the [__libmba__ _API Reference_ of the _diff_ module][diff API]:

> The _diff_(3m) module will compute the _shortest edit script_ (SES) of two sequences.
> This algorithm is perhaps best known as the one used in GNU _diff_(1) although GNU _diff_ employs additional optimizations specific to line oriented input such as source code files whereas this implementation is more generic.
> Formally, this implementation of the SES solution uses the dynamic programming algorithm described by Myers [1] with the Hirschberg linear space refinement.
> The objective is to compute the minimum set of edit operations necessary to transform a sequence A of length N into B of length M.
> This can be performed in O(N+M*D^2) expected time where D is the edit distance (number of elements deleted and inserted to transform A into B).
> Thus the algorithm is particularly fast and uses less space if the difference between sequences is small.
> The interface is generic such that sequences can be anything that can be indexed and compared with user supplied functions including arrays of structures, linked lists, arrays of pointers to strings in a file, etc.
>
> [1] E. Myers, "An _O_(_ND_) Difference Algorithm and Its Variations," [_Algorithmica_ 1, 2] (1986), 251-266.

The full article by [Eugene Myers] is available at this URL:

- http://xmailserver.org/diff2.pdf

For an in-depth explanation of Myers' diff algorithm, see [Nicholas Butler]'s two-parts tutorial and his free visual tool for tracking the algorithm step by step:

- [Myers' Diff Algorithm: The basic greedy algorithm]
- [Myers' Diff Algorithm: The linear space refinement]
- [`DiffTutorial_bin.zip`][bin.zip] — learning tool, Windows binary (24 kB).
- [`DiffTutorial_src.zip`][src.zip] — learning tool, C# sources (36 kB).

# License

The __[libmba]__ library is Copyright © by Michael B. Allen, released under the terms of the MIT License.

```
The MIT License

Copyright (c) 2001-2005 Michael B. Allen <mba2000 ioplex.com>

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
```



<!-----------------------------------------------------------------------------
                               REFERENCE LINKS
------------------------------------------------------------------------------>

[libmba]: http://www.ioplex.com/~miallen/libmba/ "Visit libmba home page"
[diff API]: http://www.ioplex.com/~miallen/libmba/dl/docs/ref/diff.html

<!-- Myers' diff algorithm -->

[_Algorithmica_ 1, 2]: https://link.springer.com/article/10.1007%2FBF01840446 "View Algorithmica, Volume 1, Issue 2 at Springer website"
[Myers' Diff Algorithm: The basic greedy algorithm]: http://simplygenius.net/Article/DiffTutorial1 "Read the first part of N.Butler's tutorial on Myers' diff algorithm"
[Myers' Diff Algorithm: The linear space refinement]: http://simplygenius.net/Article/DiffTutorial2 "Read the second part of N.Butler's tutorial on Myers' diff algorithm"
[bin.zip]: http://simplygenius.net/ArticleFiles/DiffTutorial/DiffTutorial_bin.zip "Free tool to visualize Myers' diff algorithm (executable)"
[src.zip]: http://simplygenius.net/ArticleFiles/DiffTutorial/DiffTutorial_src.zip "Free tool to visualize Myers' diff algorithm (C# sources)"
<!-- project files -->

[Makefile]: ./Makefile "View Make file"

[allocator.c]: ./allocator.c "View C source file"
[bitset.c]: ./bitset.c "View C source file"
[cfg.c]: ./cfg.c "View C source file"
[csv.c]: ./csv.c "View C source file"
[daemon.c]: ./daemon.c "View C source file"
[dbug.c]: ./dbug.c "View C source file"
[diff.c]: ./diff.c "View C source file"
[eval.c]: ./eval.c "View C source file"
[hashmap.c]: ./hashmap.c "View C source file"
[hexdump.c]: ./hexdump.c "View C source file"
[linkedlist.c]: ./linkedlist.c "View C source file"
[misc.c]: ./misc.c "View C source file"
[msgno.c]: ./msgno.c "View C source file"
[path.c]: ./path.c "View C source file"
[pool.c]: ./pool.c "View C source file"
[shellout.c]: ./shellout.c "View C source file"
[stack.c]: ./stack.c "View C source file"
[suba.c]: ./suba.c "View C source file"
[svcond.c]: ./svcond.c "View C source file"
[svsem.c]: ./svsem.c "View C source file"
[text.c]: ./text.c "View C source file"
[time.c]: ./time.c "View C source file"
[varray.c]: ./varray.c "View C source file"

[EditHistory.pb]: ../EditHistory.pb#L58 "View PureBasic source file"

<!-- xrefs -->

[MIT License]: #license "View full license text"

<!-- people -->

[Nicholas Butler]: https://www.codeproject.com/Members/Nicholas-Butler "Visit Nicholas Butler's profile on CodeProject.com"
[Eugene Myers]: https://en.wikipedia.org/wiki/Eugene_Myers "See the Wikipedia page on Eugene Wimberly Myers"

<!-- EOF -->
