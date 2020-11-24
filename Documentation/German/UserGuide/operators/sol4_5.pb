; This example is shorter, but you need to make sure that the
; variables are all of the corerct type and that the output
; is formatted correctly

; As always - open a console so we can display the results
OpenConsole()

; Create the variables, one for each piece of information
; about the member
DefType.s forename, surname
DefType.l house_number
DefType.s street_name, city
DefType.l membership_number

; Fill in the members details
forename = "Amanda"
surname = "Huggankiss"
membership_number = 23456
house_number = 69
street_name = "Boulevard"
city = "Springfield"

; Print the member information out in the required format
PrintN(forename + " " + surname + " : " + Str(membership_number))
PrintN(Str(house_number) + " " + street_name)
PrintN(city)

PrintN("Press return to exit")
Input()
CloseConsole()
End
; ExecutableFormat=
; EOF