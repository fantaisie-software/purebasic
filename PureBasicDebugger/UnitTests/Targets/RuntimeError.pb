; Target program for DebuggerEngine.pb: compiled with the debugger and run by the tests.
; Lines marked with "; @Name" are found by TargetLine(), so lines can be added freely.

Dim Values(2)
Index = 5
Values(Index) = 1 ; @Error
Debug "not reached"
