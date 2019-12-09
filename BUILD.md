# Build Instructions

Welcome to __[PureBasic OpenSource Projects]__!

For now, to be able to compile the sources, you will need Windows, as it's the only supported OS (will change soon).
That said, you can try to compile on Linux/OSX as the makefile contains all the required info to do so.

# 1. Install UnxUtils

[UnxUtils] is a collection of the most important GNU utilities ported to Windows.
You can download it here:

- https://sourceforge.net/projects/unxutils/

Don't forget to add `<UnxUtilsInstallPath>\usr\local\wbin` to your [PATH].

# 2. Install VisualStudio C++ 2013 Community Edition

The project contains some C source code which requires Visual Studio to compile.
The recommended version is VS 2013, which is also available as _Community Edition_ for free:

- [MS Visual Studio 2013 download page]

You could also try using a more recent version, but we use the 2013 version here.

# 3. Install the Windows Platform SDK

We use an old SDK version (7.0) but a newer version might also work.

- [Windows SDK for Windows 7 download page]

# 4. Tune the launch script

Create a copy of "`Window-x64.cmd`" or "`Window-x86.cmd`" and edit it:

- Set `PUREBASIC_HOME` to a working PureBasic installation.
- Check all the other paths to see if they match you local system.


# 5. Launch the makefile

- Double-click on `Window-x64.cmd` and go in PureBasicIDE directory.
- Type: `make`.

If all is setup correctly, it should compile all the dependencies and the IDE.
A 'Build' directory will be created with all temporary files in it.

Once you have successfully launched the `make` once, you can then use
PureBasic to open the "`PureBasic IDE.pbp`" project file and
run it from PureBasic itself (be sure to adjust the constants in 'Compilers Options.../Contants')

- The `#BUILD_DIRECTORY` constant must point to the Build/x64/ide/ folder created before by the 'make'
- The `#PureBasicPath` constant must point to a full PureBasic installation.

Don't hesitate to [drop a word] to improve this build guide, as right now it's very slim!

Have fun hacking,

[The Fantaisie Software Team]

<!-----------------------------------------------------------------------------
                               REFERENCE LINKS
------------------------------------------------------------------------------>

[drop a word]: https://github.com/fantaisie-software/purebasic/issues/new "Open an Issue and talk to us!"

[The Fantaisie Software Team]: https://www.purebasic.com/support.php "More info about the Fantaisie Software Team"
[PureBasic OpenSource Projects]: https://github.com/fantaisie-software/purebasic

<!-- 3rd party websites -->

[UnxUtils]: http://unxutils.sourceforge.net "Visit UnxUtils website"

<!-- references -->

[PATH]: https://en.wikipedia.org/wiki/PATH_(variable) "See Wikipedia page on 'PATH (variable)'"

<!-- download links -->

[MS Visual Studio 2013 download page]: https://visualstudio.microsoft.com/vs/older-downloads/#visual-studio-2013-and-other-products "Go to the download page of MSVS 2013"
[Windows SDK for Windows 7 download page]: https://www.microsoft.com/en-us/download/details.aspx?id=8279

<!-- EOF -->
