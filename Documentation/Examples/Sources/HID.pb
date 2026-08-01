;
; ------------------------------------------------------------
;
;   PureBasic - HID example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

ExamineHIDs()
While NextHID()
  
  Debug HIDInfo(#PB_HID_Product)
  Debug HIDInfo(#PB_HID_Manufacturer)
  Debug HIDInfo(#PB_HID_VendorId)
  Debug HIDInfo(#PB_HID_ProductId)
  Debug HIDInfo(#PB_HID_Path)
  Debug HIDInfo(#PB_HID_SerialNumber)
Wend
