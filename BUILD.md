# Build Instructions

How to build the __[PureBasic OpenSource Projects]__.

## Precondition: A PureBasic installation

To compile and test the tools in this repository you need a PureBasic installation. This installation is used both for compilation as well as for testing which is why the compiled IDE and debugger are directly copied into that PureBasic installation for direct testing (this will overwrite the original IDE).

It is therefore recommended to set aside a dedicated PureBasic directory for development with this repository. You can just copy your regular installation to a new directory for this. There is no need to install anything.

The following conditions should be met for this:

- You need write permissions to the PureBasic directory (do not use "Program Files" or similar)
- You should avoid spaces or special characters in the Path to that directory to avoid any trouble with the build scripts

## Building on Windows (quick & easy method)

To compile the IDE, open a command shell and run the `MakeWindows.cmd` script from within the [`PureBasicIDE`][PureBasicIDE] directory and provide the full path to your PureBasic installation as the parameter:
```
MakeWindows.cmd <YourPureBasicPath>
```

The same can be done in the [`PureBasicDebugger`][PureBasicDebugger] directory. Other directories do not have a such a quick & easy scripts. See below for the setup of the full build environment.

## Building on Windows (official method)

The official way to build is using the makefiles. This requires some Unix utilities from the [GnuWin] project to be present on the system.

[ChrisRfr] has kindly prepared an _ad hoc_ package with all the required tools:

- [`UnixTools-4-Win.zip`][UnixTools-4-Win.zip]

Download the Zip archive, unpack it and add it to your [PATH]  (full instructions inside the Zip file).

Run the `BuildEnv.cmd` script from the main directory with your PureBasic installation as a parameter:
```
BuildEnv.cmd <YourPureBasicPath>
```

In the opened command shell, navigate to the [`PureBasicIDE`][PureBasicIDE] directory and type `make`. To create a debug version, type `make debug`.

## Building on Linux

Make sure you have build tools such as `make` installed in your distribution.

Run the `BuildEnv.sh` script from the main directory with your PureBasic installation as parameter:
```
./BuildEnv.sh <YourPureBasicPath>
```

Alternatively, you can source the script into your `.bashrc` file to automatically setup the build environment whenever you start a shell:
```
source BuildEnv.sh <YourPureBasicPath>
```

In the opened command shell, navigate to the [`PureBasicIDE`][PureBasicIDE] directory and type `make`. To create a debug version, type `make debug`.

The default is to build the IDE with Gtk3. You can use the Gtk2 subsystem by setting the `PB_GTK=2` environment variable before running the `BuildEnv.sh` script. A QT version can be build by setting `PB_QT=1` instead.

## Building on MacOS

PureBasic for MacOS comes as as single `PureBasic.app` package. To prepare a directory for IDE compilation and testing, some additional steps are needed:

- Copy the `PureBasic.app` into an empty directory
- Ctrl-click (or right-click) on the `PureBasic.app` and select "Show Package Content" from the context menu
- Copy all files and directories from `Contents/Resources` from inside the package outside next to the `PureBasic.app` file
- Use this directory with the `PureBasic.app` and the extracted resources as the `<YourPureBasicPath>` parameter for the `BuildEnv.sh` script

After these steps you can follow the build steps for Linux described above to setup the build environment.

## More information

For more detailed information, see also the following pages on the [project Wiki]:

- [Building on Windows]
- [Building on Linux]
- [Building on macOS]

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
[PureBasicDebugger]: ./PureBasicDebugger/ "Navigate to the 'PureBasicDebugger/' folder"

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
