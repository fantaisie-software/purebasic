	
all: 
	pbcompiler "Sources - Advanced/Atomic FTP Server/Atomic FTP Server.pb" /QUIET /EXE temporary.exe
	pbcompiler "Sources - Advanced/Atomic Web Server/Atomic Web Server.pb" /QUIET /EXE temporary.exe
	pbcompiler "Sources - Advanced/MoviePlayer/MoviePlayer.pb" /QUIET /EXE temporary.exe
	pbcompiler "Sources - Advanced/OpenGL Cube/OpenGL.pb" /QUIET /EXE temporary.exe
	pbcompiler "Sources - Advanced/QuickSort/QuickSort.pb" /QUIET /EXE temporary.exe
	pbcompiler "Sources - Advanced/Waponez II/Waponez II.pb" /QUIET /EXE temporary.exe
	make --quiet --directory 3D
	make --quiet --directory Sources
	rm -f temporary.exe
