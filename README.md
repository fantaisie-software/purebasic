# PureBasic OpenSource Projects

[![GPLv3][GPL badge]][GPL License]&nbsp;
[![Fantaisie Software License][Fantaisie badge]][Fantaisie License]
[![Build Status](https://travis-ci.com/fantaisie-software/purebasic.svg?branch=master)](https://travis-ci.com/fantaisie-software/purebasic)

- `Repository:` https://github.com/fantaisie-software/purebasic
- `Vanity URL:` https://git.io/purebasic

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
- [Contributing](#contributing)
- [Credits](#credits)
    - [Monokai Theme](#monokai-theme)
    - [Silk Icon Set](#silk-icon-set)
- [Acknowledgements](#acknowledgements)
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

# Contributing

- [`CONTRIBUTING.md`][CONTRIBUTING.md]

This is an open source project open to users' contributions.
Contributions are not limited to code programming, there are many ways in which you can help this project grow, and some of them don't even require using [Git].

Contents submissions to the repository should be made using [Git] and [GitHub], and pull requests should be submitted to the [`devel` branch][devel] (pull requests to `master` branch will not be accepted).

To learn more on how to contribute to the project, read our _[Contributors' Guidelines]_.
The Guidelines present an introduction to the project and it's goals, providing detailed instructions on the different ways you can contribute — including tips and useful links on how to start using [Git] and [GitHub].

# Credits

The list of third party components used in this project, with due credits to their authors and license terms.
More details can be found inside the folder of each asset.

## Monokai Theme

- [`PureBasicIDE/Preferences.pb`][MonokaiTheme]

The PureBasic IDE uses the Monokai color scheme, created by [Wimer Hazenberg].

    Monokai, copyright by Wimer Hazenberg (https://monokai.nl)

The Monokai scheme is free to use provided that the above copyright notice and link to the author website are included in any work using the scheme.

## Silk Icon Set

- [`PureBasicIDE/data/SilkTheme/`][SilkTheme]

The __Silk Icon Theme__ included with PureBasic and SpiderBasic IDEs is based on [Mark James]'s __[Silk icon set 1.3]__, released under [CC-BY-2.5].
Some icons were slightly modified by [Timo «Freak» Harter].

# Acknowledgements

Our gratitude goes out to all those who helped us improve PureBasic and SpiderBasic in the course of time.
The list is quite long, and we refer you to the Acknowledgements section of the [PureBasic][AcknPB] and [SpiderBasic][AcknSB] documentation for more details.

Here follows a list of people who contributed to the assets found in this repository.
The list is still in the making and incomplete, and we apologise for any temporary omissions.

- __[ChrisRfr]__ — for having prepared the _ad hoc_ package with all the required GNU dependencies for building the IDE under Windows.
- __[Danilo Krahn]__ — For his huge work on the editor and on the core commands set, and the tons of nice suggestions about code optimization and size reduction.
- __Fabien Laboureur__ — for designing the [SpiderBasic logo].
- __[Gaetan Dupont-Panon]__ — For the wonderful new visual designer, which really rocks on Windows, Linux and OS X!
- __[Gary «Kale» Willoughby]__ — for designing the [default theme] of the PureBasic IDE.
- __[Timo «Freak» Harter]__ — for the IDE, the Debugger, many commands and great ideas. PureBasic wouldn't be the same without him!


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

<!-- PureBasic and SpiderBasic documentation -->

[AcknPB]: https://www.purebasic.com/documentation/mainguide/greats.html "Read the Acknowledgements section of PureBasic documentation"
[AcknSB]: https://www.spiderbasic.com/documentation/mainguide/greats.html "Read the Acknowledgements section of SpiderBasic documentation"

<!-- 3rd party links and licenses -->

[CC-BY-2.5]: https://creativecommons.org/licenses/by/2.5/ "Creative Commons Attribution 2.5 Generic"
[Git]: https://git-scm.com "Visit Git website"
[GitHub]: https://github.com/ "Visit GitHub main page"
[Silk icon set 1.3]: http://www.famfamfam.com/lab/icons/silk/ "Visit the Silk Icons page at www.famfamfam.com"

<!-- references -->

[GitHub Guides]: https://guides.github.com "Go to GitHub Guides"
[Contributors' Guidelines]: ./CONTRIBUTING.md "Read the Contributors' Guidelines to this project"

<!-- badges -->

[GPL badge]: https://img.shields.io/badge/License-GPLv3-blue
[Fantaisie badge]: https://img.shields.io/badge/License-Fantaisie%20Software-blue

<!-- repo links -->

[create a pull request]: https://help.github.com/en/desktop/contributing-to-projects/creating-a-pull-request "Learn how to create pull requests"
[open an Issue]: https://github.com/fantaisie-software/purebasic/issues/new "Open an Issue and talk to us!"
[ZIP Archive]: https://github.com/tajmone/purebasic/archive/master.zip "Download a ZIP file of this project (without Git contents)"
[devel]: https://github.com/fantaisie-software/purebasic/tree/devel "View the 'devel' branch"

<!-- x-refs -->

[Fork on GitHub]: #forking-on-github "Jump to document sections"

<!-- project files -->

[GPL License]: ./LICENSE "The GNU General Public License v3"
[Fantaisie License]: ./LICENSE-FANTAISIE "The Fantaisie Software License"
[CONTRIBUTING.md]: ./CONTRIBUTING.md "Contributors' Guidelines"
[MonokaiTheme]: ./PureBasicIDE/Preferences.pb#L5621 "View the source file containing the Monokai color scheme"

<!-- project folders -->

[default theme]: ./PureBasicIDE/data/DefaultTheme/ "Navigate to the Default Theme folder"
[SilkTheme]: ./PureBasicIDE/data/SilkTheme/ "Navigate to the Silk Icon Theme folder"
[SpiderBasic logo]: ./PureBasicIDE/data/SpiderBasic/ "Navigate to the SpiderBasic logo folder"

<!-- people -->

[ChrisRfr]: https://github.com/ChrisRfr "View @ChrisRfr's GitHub profile"
[Danilo Krahn]: https://github.com/D-a-n-i-l-o "View Danilo Krahn's GitHub profile"
[Gaetan Dupont-Panon]: https://www.purebasic.fr/english/memberlist.php?mode=viewprofile&u=186 "Visit Gaetan Dupont-Panon's profile on the PureBasic Forums"
[Gary «Kale» Willoughby]: https://www.purebasic.fr/english/memberlist.php?mode=viewprofile&u=34 "Visit Gary «Kale» Willoughby's profile on the PureBasic Forums"
[Mark James]: https://twitter.com/markjames "Visit Mark James's profile on Twitter"
[Timo «Freak» Harter]: https://github.com/t-harter "View Timo «Freak» Harter's GitHub profile"
[Wimer Hazenberg]: https://www.monokai.nl/ "Visit Wimer Hazenberg's website"

<!-- EOF -->
