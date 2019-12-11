# PureBasic OpenSource Projects

[![GPLv3][GPL badge]][GPL License]&nbsp;
[![Fantaisie Software License][Fantaisie badge]][Fantaisie License]
[![Build Status](https://travis-ci.com/fantaisie-software/purebasic.svg?branch=master)](https://travis-ci.com/fantaisie-software/purebasic)

- https://github.com/fantaisie-software/purebasic

Welcome to __PureBasic OpenSources Projects__, a central public repository to access all open sourced code of [PureBasic], a native code BASIC compiler for Windows, Linux and OS X.

[<kbd>Download as a ZIP Archive</kbd>][ZIP Archive]

-----

**Table of Contents**


<!-- MarkdownTOC autolink="true" bracket="round" autoanchor="false" lowercase="only_ascii" uri_encoding="true" levels="1,2,3,4" -->

- [Welcome](#welcome)
- [Download Instructions](#download-instructions)
    - [Downloading a ZIP Archive](#downloading-a-zip-archive)
    - [Cloning the Repository Locally via Git](#cloning-the-repository-locally-via-git)
    - [Forking on GitHub](#forking-on-github)
- [License](#license)
- [Links](#links)

<!-- /MarkdownTOC -->

-----

# Welcome

You can checkout the repository to easily add features you need, or just for curiosity!
If you think that your new code can bring benefits to the whole community, don't hesitate to [create a pull request], so we can test your code and include it in the main package.

Don't forget to read the [`BUILD.md`](./BUILD.md) document to learn how to get started.

If you have any questions, suggestions or need help, you can always [open an Issue] on this project.
If you're new to [Git] and GitHub, we suggest you take a look a the [GitHub Guides] which contain free tutorials, video guides and hands-on interactive exercises for beginners.

Happy hacking,

[The Fantaisie Software Team]

# Download Instructions

Depending on what you're planning to do, you can choose to obtain a copy of this project in three different ways:

1. [Download the project as a ZIP Archive][ZIP Archive]
2. Clone the repository locally
3. Fork the repository on GitHub

If you're planning to actively participate in the development of thePureBasic IDE, then you should [fork on GitHub].
If you don't know/have/use [Git], then just [download as a ZIP Archive][ZIP Archive].

For the differences between these three choices, and their implications, carry on reading.

## Downloading a ZIP Archive

If you're not planning to use [Git], and you're only interested in the PureBasic IDE contents, for your own personal use, then downloading a [ZIP Archive] might be the best choice for you.
You'll get a lighter version of the project, without any of the Git-specific contents, which is also going to be smaller in size.

[<kbd>Download as a ZIP Archive</kbd>][ZIP Archive]

Beware, this way you won't be able to update your local copy dynamically.
To get an updated version, you'll have to re-download the ZIP archive from scratch.

## Cloning the Repository Locally via Git

If you'd like to be able to keep your local copy of the project updated via a single shell command, but are not interested in contributing your changes back to the main project, then you might be better off installing [Git] and downloading the project from the shell/CMD via:

    git clone https://github.com/fantaisie-software/purebasic.git

Then, whenever you want to update your local copy, just open your shell/CMD in the project root and type:

    git pull

## Forking on GitHub

If you wish to join this project in full, and be able to contribute your changes back to the main (_upstream_) repository, then you should create a GitHub account and click on the <kbd>Fork</kbd> button that appears on the right side at beginning of this page (you need to be logged-in to see this option).

By forking this project you'll be creating your own copy (your _fork_) of this repository on GitHub, which remains connected to its parent project (the _upstream repository_) thus facilitating synchronizing contents changes between the two in a flawless manner.

After forking the repository, to download a local copy you should then clone _your_ fork of the repository (not this one) by typing in your shell/CMD:

    git clone https://github.com/<your GitHub username>/purebasic.git

where `<your GitHub username>` is whatever user name you registered your GitHub account with.


# License

- [`LICENSE`][GPL License] — GPLv3
- [`LICENSE-FANTAISIE`][Fantaisie License] — Fantaisie Software License

The contents of this project are Copyright (c) [Fantaisie Software].
All rights reserved.

The project is released to the public under dual license: the GPLv3 and Fantaisie Software licenses.

See the [`LICENSE`][GPL License] and [`LICENSE-FANTAISIE`][Fantaisie License] files in the project root for full license information.


```
                FANTAISIE SOFTWARE LICENSE
                Version 1, 26 November 2019

By contributing modifications or additions to these software, you grant
a perpetual right to Fantaisie Software to use, modify and distribute your
work in the PureBasic package.
```


# Links

- www.purebasic.com
- www.spiderbasic.com
- [PureBasic forums][PBF EN] (English)
- [PureBasic forums][PBF DE] (German)
- [PureBasic forums][PBF FR] (French)
- [PureBasic Team Blog]

<!-----------------------------------------------------------------------------
                               REFERENCE LINKS
------------------------------------------------------------------------------>

<!-- official links to PureBasic, SpiderBasic and Fantaisie Software -->

[The Fantaisie Software Team]: https://www.purebasic.com/support.php "More info about the Fantaisie Software Team"
[Fantaisie Software]: https://www.purebasic.com/support.php "Visit the Fantaisie Software info page at www.purebasic.com"
[PureBasic]: https://www.purebasic.com "Visit PureBasic website"
[PureBasic Team Blog]: https://www.purebasic.fr/blog/ "Random thoughts on PureBasic development"

[PBF EN]: https://www.purebasic.fr/english "PureBasic forum for English speakers"
[PBF DE]: https://www.purebasic.fr/german "PureBasic forum for German speakers"
[PBF FR]: https://www.purebasic.fr/french "PureBasic forum for French speakers"

<!-- 3r party websites -->

[Git]: https://git-scm.com "Visit Git website"

<!-- references -->

[create a pull request]: https://help.github.com/en/desktop/contributing-to-projects/creating-a-pull-request "Learn how to create pull requests"
[GitHub Guides]: https://guides.github.com "Go to GitHub Guides"

<!-- badges -->

[GPL badge]: https://img.shields.io/badge/License-GPLv3-blue
[Fantaisie badge]: https://img.shields.io/badge/License-Fantaisie%20Software-blue

<!-- repo links -->

[open an Issue]: https://github.com/fantaisie-software/purebasic/issues/new "Open an Issue and talk to us!"
[ZIP Archive]: https://github.com/tajmone/purebasic/archive/master.zip "Download a ZIP file of this project (without Git contents)"

<!-- x-refs -->

[Fork on GitHub]: #forking-on-github "Jump to document sections"

<!-- project files -->

[GPL License]: ./LICENSE "The GNU General Public License v3"
[Fantaisie License]: ./LICENSE-FANTAISIE "The Fantaisie Software License"

<!-- EOF -->
