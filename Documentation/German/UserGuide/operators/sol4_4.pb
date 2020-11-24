; Remember to open the console so we can display the results
OpenConsole()

; Create the variables we require
DefType.w student1
DefType.w student2
DefType.w student3
DefType.w student4
DefType.w student5
DefType.f average_mark


; Set up the values for each student mark
student1 = 75
student2 = 34
student3 = 76
student4 = 87
student5 = 45


; Calculate the average
average_mark = (student1 + student2 + student3 + student4 + student5) / 5


; Display the results
PrintN("Student 1 got a mark of "+Str(student1))
PrintN("Student 2 got a mark of "+Str(student2))
PrintN("Student 3 got a mark of "+Str(student3))
PrintN("Student 4 got a mark of "+Str(student4))
PrintN("Student 5 got a mark of "+Str(student5))
PrintN("The average mark was   "+StrF(average_mark))


PrintN("Press return to exit")
Input()
CloseConsole()
End
; ExecutableFormat=
; EOF