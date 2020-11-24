OpenConsole()

width.l = 3
length.l = 2
height.l = 2

area.l = width * length
volume.l = height * area
volume2.l = width * length * height
PrintN("Plan view area = "+Str(area))
PrintN("Volume = "+Str(volume)+" and should be the same as Volume2 = "+Str(volume2))

total_cost.f = 13.67
quantity.l = 9
price_each.f = total_cost / quantity
price_each / 1.175
PrintN("Price of each item (excluding UK VAT) = "+StrF(price_each))

PrintN("Press return to exit")
Input()
CloseConsole()
End
; ExecutableFormat=
; EOF