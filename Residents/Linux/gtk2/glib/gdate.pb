Enumeration   ; GDateDMY
  #G_DATE_DAY = 0
  #G_DATE_MONTH = 1
  #G_DATE_YEAR = 2
EndEnumeration

Enumeration   ; GDateWeekday
  #G_DATE_BAD_WEEKDAY = 0
  #G_DATE_MONDAY = 1
  #G_DATE_TUESDAY = 2
  #G_DATE_WEDNESDAY = 3
  #G_DATE_THURSDAY = 4
  #G_DATE_FRIDAY = 5
  #G_DATE_SATURDAY = 6
  #G_DATE_SUNDAY = 7
EndEnumeration

Enumeration   ; GDateMonth
  #G_DATE_BAD_MONTH = 0
  #G_DATE_JANUARY = 1
  #G_DATE_FEBRUARY = 2
  #G_DATE_MARCH = 3
  #G_DATE_APRIL = 4
  #G_DATE_MAY = 5
  #G_DATE_JUNE = 6
  #G_DATE_JULY = 7
  #G_DATE_AUGUST = 8
  #G_DATE_SEPTEMBER = 9
  #G_DATE_OCTOBER = 10
  #G_DATE_NOVEMBER = 11
  #G_DATE_DECEMBER = 12
EndEnumeration

#G_DATE_BAD_JULIAN = 0
#G_DATE_BAD_DAY = 0
#G_DATE_BAD_YEAR = 0
Structure GDate
  julian_days.l  ; julian_days:32.l
  packed_flags.l
  ; julian:1
  ; dmy:1
  ; day:6
  ; month:4
  ;year:16.l
EndStructure

