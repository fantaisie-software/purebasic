; Target program for DebuggerEngine.pb: compiled with the debugger and run by the tests.
; Lines marked with "; @Name" are found by TargetLine(), so lines can be added freely.

For i = 1 To 3
  Total + i ; @Loop
Next i
Debug Total
CallDebugger ; @CallDebugger
Debug "end"
