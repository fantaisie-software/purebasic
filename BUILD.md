# Build Instructions

How to build the __[PureBasic OpenSource Projects]__.

Currently, the only supported toolchain is that for the Windows OS (this will change soon), therefore these instructions only cover building the PureBasic IDE for Windows.

That said, you can try to compile on Linux/OSX as the makefile contains all the required info to do so.

For more detailed information, see also the following pages on the [project Wiki]:

- [Building on Windows]
- [Building on Linux]
- [Building on macOS]


# 1. Get the GNU Dependencies

The build scripts require some Unix utilities from the [GnuWin] project to be present on the system.

[ChrisRfr] has kindly prepared an _ad hoc_ package with all the required tools:

- [`UnixTools-4-Win.zip`][UnixTools-4-Win.zip]

Download the Zip archive, unpack it and add it to your [PATH]  (full instructions inside the Zip file).

# 2. Install VisualStudio C++ 2013 Community Edition

The project contains some C source code which requires Visual Studio to compile.
The recommended version is VS 2013, which is also available as _Community Edition_ for free:

- [MS Visual Studio 2013 download page]

You could also try using a more recent version, but we use the 2013 version here.

# 3. Install the Windows Platform SDK

We use an old SDK version (7.0) but a newer version might also work.

- [Windows SDK for Windows 7 download page]

# 4. Tune the launch script

Create a copy of the `Window-x64.cmd` or `Window-x86.cmd` script and edit it:

- Set `PUREBASIC_HOME` to a working PureBasic installation.
- Check all the other paths to see if they match your local system.


# 5. Launch the makefile

- Double-click on `Window-x64.cmd`.
- Go to the [`PureBasicIDE`][PureBasicIDE] directory.
- Type: `make`.

If all is setup correctly, it should compile all the dependencies and the IDE.
A `Build` directory will be created with all temporary files in it.

Once you have successfully launched the `make` once, you can then use
PureBasic to open the "`PureBasicIDE.pbp`" project file and
run it from PureBasic itself (be sure to adjust the constants in 'Compilers Options.../Contants')

- The `#BUILD_DIRECTORY` constant must point to the `Build/x64/ide/` folder created before by the execution of `make`.

Don't hesitate to [drop a word] to improve this build guide, as right now it's very slim!

Have fun hacking,

[The Fantaisie Software Team]

<!-----------------------------------------------------------------------------
                               REFERENCE LINKS
------------------------------------------------------------------------------>

[drop a word]: https://github.com/fantaisie-software/purebasic/issues/new "Open an Issue and talk to us!"

[The Fantaisie Software Team]: https://www.purebasic.com/support.php "More info about the Fantaisie Software Team"
[PureBasic OpenSource Projects]: https://github.com/fantaisie-software/purebasic

<!-- repo files and folders -->

[PureBasicIDE]: ./PureBasicIDE/ "Navigate to the 'PureBasicIDE/' folder"

<!-- 3rd party websites -->

[GnuWin]: http://gnuwin32.sourceforge.net/ "Visit the website of the GnuWin project at SourceForge"


<!-- references -->

[PATH]: https://en.wikipedia.org/wiki/PATH_(variable) "See Wikipedia page on 'PATH (variable)'"

<!-- Wiki Links -->


[project Wiki]: https://github.com/fantaisie-software/purebasic/wiki/ "Visit the PureBasic OpenSource Projects Wiki"

[Building on Windows]: https://github.com/fantaisie-software/purebasic/wiki/Building-on-Windows "Wiki page on building the PureBasic IDE under Windows"
[Building on Linux]: https://github.com/fantaisie-software/purebasic/wiki/Building-on-Linux "Wiki page on building the PureBasic IDE under Linux"
[Building on macOS]: https://github.com/fantaisie-software/purebasic/wiki/Building-on-macOS "Wiki page on building the PureBasic IDE under macOS"

<!-- download links -->

[MS Visual Studio 2013 download page]: https://visualstudio.microsoft.com/vs/older-downloads/#visual-studio-2013-and-other-products "Go to the download page of MSVS 2013"
[Windows SDK for Windows 7 download page]: https://www.microsoft.com/en-us/download/details.aspx?id=8279
[UnixTools-4-Win.zip]: https://github.com/fantaisie-software/purebasic/wiki/UnixTools-4-Win.zip "Download the ZIP file with the GNU dependencies for Windows"

<!-- people -->

[ChrisRfr]: https://github.com/ChrisRfr "View @ChrisRfr's GitHub profile"


<!-- EOF -->
