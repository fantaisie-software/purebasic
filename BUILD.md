# Build Instructions

How to build the __[PureBasic OpenSource Projects]__.

The following description is an overview for Windows builds. For more detailed information, see also the following pages on the [project Wiki]:

- [Building on Windows]
- [Building on Linux]
- [Building on macOS]


# 1. Get the GNU Dependencies

The build scripts require some Unix utilities from the [GnuWin] project to be present on the system.

[ChrisRfr] has kindly prepared an _ad hoc_ package with all the required tools:

- [`UnixTools-4-Win.zip`][UnixTools-4-Win.zip]

Download the Zip archive, unpack it and add it to your [PATH]  (full instructions inside the Zip file).

# 2. Prepare a PureBasic directory

It is recommended to use a dedicated PureBasic installation for development and testing of the IDE. The build process actually overwrites the IDE in the used PureBasic installation so it is easy to break you IDE if you compile a version that does not work correctly. So install PureBasic in a directory separate from your usual PureBasic installation. The directory should not be a protected system directory (like Program Files) so the build process can write to it.

# 3. Setup the launch script

The `BuildEnv.cmd` script must be executed with the path to the PureBasic directory to use as an argument whenever you want to compile the IDE. The simplest way to set this up is to create a shortcut to the script and add the path argument as a parameter in the shortcut settings.

# 4. Launch the makefile

- Launch the `BuildEnv.cmd` with the PureBasic path argument
- Go to the [`PureBasicIDE`][PureBasicIDE] directory.
- Type: `make`.

If all is setup correctly, it should compile all the dependencies and the IDE.
A `Build` directory will be created with all temporary files in it.

Once you have successfully launched the `make` once, you can then use
PureBasic to open the "`PureBasicIDE.pbp`" project file and
run it from PureBasic itself (be sure to adjust the constants in 'Compilers Options.../Contants')

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

[UnixTools-4-Win.zip]: https://github.com/fantaisie-software/purebasic/wiki/UnixTools-4-Win.zip "Download the ZIP file with the GNU dependencies for Windows"

<!-- people -->

[ChrisRfr]: https://github.com/ChrisRfr "View @ChrisRfr's GitHub profile"


<!-- EOF -->
