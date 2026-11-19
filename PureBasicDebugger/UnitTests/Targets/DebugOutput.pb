; Target program for DebuggerEngine.pb: compiled with the debugger and run by the tests.
; Lines marked with "; @Name" are found by TargetLine(), so lines can be added freely.

Debug "Hello"
a.l = 7
Debug a
q.q = 12345678901
Debug q
d.d = 1.5
Debug d
f.f = 0.25
Debug f
s$ = "été €"
Debug s$
Debug "a=" + Str(a * 6)
