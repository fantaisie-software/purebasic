
; ICAManagerInternal interface definition
;
Interface ICAManagerInternal
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Save()
  Load()
  put_MarkDirty(a.l)
  get_MarkDirty(a.l)
  put_TuneRequest(a.l)
  GetDefaultUI(a.l)
  SetDefaultUI(a.l)
  get_CAManagerMain(a.l)
  put_BroadcastEventService(a.l)
  get_BroadcastEventService(a.l)
  DisplayDefaultUI(a.l)
  EnableDefaultUIPayTollsButton(a.l)
  UpdateDefaultUIForToll(a.l, b.l)
  put_TuneRequestInt(a.l)
  AddDenialsFor(a.l)
  RemoveDenialsFor(a.l)
  NotifyRequestActivated(a.l)
  NotifyRequestDeactivated(a.l)
  NotifyOfferAdded(a.l, b.l)
  NotifyOfferRemoved(a.l, b.l)
  NotifyPolicyAdded(a.l, b.l)
  NotifyPolicyRemoved(a.l, b.l)
  NotifyRequestDenialAdded(a.l, b.l, c.l)
  NotifyRequestDenialRemoved(a.l, b.l, c.l)
  NotifyDenialTollAdded(a.l, b.l, c.l)
  NotifyDenialTollRemoved(a.l, b.l, c.l)
  NotifyTollDenialAdded(a.l, b.l, c.l)
  NotifyTollDenialRemoved(a.l, b.l, c.l)
  NotifyOfferTollAdded(a.l, b.l, c.l)
  NotifyOfferTollRemoved(a.l, b.l, c.l)
  NotifyTollStateChanged(a.l, b.l)
  NotifyDenialStateChanged(a.l, b.l)
  NotifyComponentDenialAdded(a.l, b.l, c.l)
  NotifyComponentDenialRemoved(a.l, b.l, c.l)
EndInterface

; ICAManagerXProxy interface definition
;
Interface ICAManagerXProxy
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  get_PunkCAManagerProxy(a.l)
  NotifyRequestActivated_XProxy(a.l)
  NotifyRequestDeactivated_XProxy(a.l)
  NotifyOfferAdded_XProxy(a.l, b.l)
  NotifyOfferRemoved_XProxy(a.l, b.l)
  NotifyPolicyAdded_XProxy(a.l, b.l)
  NotifyPolicyRemoved_XProxy(a.l, b.l)
  NotifyRequestDenialAdded_XProxy(a.l, b.l, c.l)
  NotifyRequestDenialRemoved_XProxy(a.l, b.l, c.l)
  NotifyDenialTollAdded_XProxy(a.l, b.l, c.l)
  NotifyDenialTollRemoved_XProxy(a.l, b.l, c.l)
  NotifyTollDenialAdded_XProxy(a.l, b.l, c.l)
  NotifyTollDenialRemoved_XProxy(a.l, b.l, c.l)
  NotifyOfferTollAdded_XProxy(a.l, b.l, c.l)
  NotifyOfferTollRemoved_XProxy(a.l, b.l, c.l)
  NotifyTollStateChanged_XProxy(a.l, b.l)
  NotifyDenialStateChanged_XProxy(a.l, b.l)
  NotifyComponentDenialAdded_XProxy(a.l, b.l, c.l)
  NotifyComponentDenialRemoved_XProxy(a.l, b.l, c.l)
EndInterface

; ICAPolicies interface definition
;
Interface ICAPolicies
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get__NewEnum(a.l)
  get_Count(a.l)
  get_Item(a.p-variant, b.l)
  Add(a.l)
  Remove(a.p-variant)
EndInterface

; ICAPoliciesInternal interface definition
;
Interface ICAPoliciesInternal
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetCAManager(a.l)
  CheckRequest(a.l)
EndInterface

; ICATolls interface definition
;
Interface ICATolls
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get__NewEnum(a.l)
  get_Count(a.l)
  get_Item(a.p-variant, b.l)
  Add(a.l)
  Remove(a.p-variant)
EndInterface

; ICATollsInternal interface definition
;
Interface ICATollsInternal
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetCAManager(a.l)
  GetCAManager(a.l)
  SetMustPersist(a.l)
  Save(a.l, b.p-bstr)
  Load(a.l, b.p-bstr)
  NotifyStateChanged(a.l, b.l)
  NotifyTollSelectionChanged(a.l, b.l)
EndInterface

; ICADenials interface definition
;
Interface ICADenials
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get__NewEnum(a.l)
  get_Count(a.l)
  get_Item(a.p-variant, b.l)
  get_AddNew(a.l, b.p-bstr, c.l, d.l, e.l)
  Remove(a.p-variant)
  get_CountDenied(a.l)
  get_CountSelected(a.l)
  PaySelectedTolls()
EndInterface

; ICADenialsInternal interface definition
;
Interface ICADenialsInternal
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetCAManager(a.l)
  NotifyDenialStateChanged(a.l, b.l)
EndInterface

; ICAOffers interface definition
;
Interface ICAOffers
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get__NewEnum(a.l)
  get_Count(a.l)
  get_Item(a.p-variant, b.l)
  get_AddNew(a.l, b.p-bstr, c.l, d.l, e.l)
  Remove(a.p-variant)
EndInterface

; ICAComponents interface definition
;
Interface ICAComponents
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get__NewEnum(a.l)
  get_Count(a.l)
  get_Item(a.p-variant, b.l)
EndInterface

; ICAComponentInternal interface definition
;
Interface ICAComponentInternal
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  RemoveAllDenials()
  get_Description(a.l, b.l)
EndInterface

; ICADefaultDlg interface definition
;
Interface ICADefaultDlg
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  put_AutoSize(a.l)
  get_AutoSize(a.l)
  put_BackColor(a.l)
  get_BackColor(a.l)
  put_BackStyle(a.l)
  get_BackStyle(a.l)
  put_BorderColor(a.l)
  get_BorderColor(a.l)
  put_BorderStyle(a.l)
  get_BorderStyle(a.l)
  put_BorderWidth(a.l)
  get_BorderWidth(a.l)
  put_DrawMode(a.l)
  get_DrawMode(a.l)
  put_DrawStyle(a.l)
  get_DrawStyle(a.l)
  put_DrawWidth(a.l)
  get_DrawWidth(a.l)
  put_FillColor(a.l)
  get_FillColor(a.l)
  put_FillStyle(a.l)
  get_FillStyle(a.l)
  putref_Font(a.l)
  put_Font(a.l)
  get_Font(a.l)
  put_ForeColor(a.l)
  get_ForeColor(a.l)
  put_Enabled(a.l)
  get_Enabled(a.l)
  get_Window(a.l)
  put_TabStop(a.l)
  get_TabStop(a.l)
  put_Text(a.p-bstr)
  get_Text(a.l)
  put_Caption(a.p-bstr)
  get_Caption(a.l)
  put_BorderVisible(a.l)
  get_BorderVisible(a.l)
  put_Appearance(a.l)
  get_Appearance(a.l)
  put_MousePointer(a.l)
  get_MousePointer(a.l)
  putref_MouseIcon(a.l)
  put_MouseIcon(a.l)
  get_MouseIcon(a.l)
  putref_Picture(a.l)
  put_Picture(a.l)
  get_Picture(a.l)
  put_Valid(a.l)
  get_Valid(a.l)
EndInterface

; _ICAResDenialTreeEvents interface definition
;
Interface _ICAResDenialTreeEvents
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
EndInterface

; _ICAManagerEvents interface definition
;
Interface _ICAManagerEvents
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
EndInterface

; _ICARequestEvents interface definition
;
Interface _ICARequestEvents
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
EndInterface

; _ICAPoliciesEvents interface definition
;
Interface _ICAPoliciesEvents
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
EndInterface

; _ICATollsEvents interface definition
;
Interface _ICATollsEvents
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
EndInterface

; _ICADenialsEvents interface definition
;
Interface _ICADenialsEvents
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
EndInterface

; _ICAOffersEvents interface definition
;
Interface _ICAOffersEvents
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
EndInterface

; _ICAComponentsEvents interface definition
;
Interface _ICAComponentsEvents
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
EndInterface

; ICAManager interface definition
;
Interface ICAManager
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Policies(a.l)
  get_ActiveRequest(a.l)
  get_Offers(a.l)
  get_PaidTolls(a.l)
  put_UseDefaultUI(a.l)
  get_UseDefaultUI(a.l)
  get_DenialsFor(a.l, b.l)
EndInterface

; ICARequest interface definition
;
Interface ICARequest
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_RequestedItem(a.l)
  get_CAManager(a.l)
  get_ScheduleEntry(a.l)
  get_Denials(a.l)
  get_Components(a.l)
  get_Check(a.l)
  get_ResolveDenials(a.l)
  get_CountDeniedComponents(a.l)
EndInterface

; ICAPolicy interface definition
;
Interface ICAPolicy
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  get_Name(a.l)
  CheckRequest(a.l)
  put_CAManager(a.l)
  get_OkToPersist(a.l)
  get_OkToRemove(a.l)
  get_OkToRemoveDenial(a.l, b.l)
  get_OkToRemoveOffer(a.l, b.l)
EndInterface

; ICAToll interface definition
;
Interface ICAToll
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  put_CAManager(a.l)
  Select(a.l)
  PayToll()
  get_Refundable(a.l)
  RefundToll()
  get_TolledObject(a.l)
  get_Denials(a.l)
  get_Policy(a.l)
  get_Description(a.l, b.l)
  get_TimePaid(a.l)
  get_State(a.l)
EndInterface

; ICADenial interface definition
;
Interface ICADenial
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_DeniedObject(a.l)
  get_Policy(a.l)
  get_Description(a.l, b.l)
  put_Description(a.l, b.p-bstr)
  get_State(a.l)
  put_State(a.l)
  get_Tolls(a.l)
  NotifyTollStateChanged(a.l, b.l)
EndInterface

; ICAOffer interface definition
;
Interface ICAOffer
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_CAManager(a.l)
  put_CAManager(a.l)
  get_Policy(a.l)
  get_Description(a.l, b.l)
  put_Description(a.l, b.p-bstr)
  get_StartTime(a.l)
  get_EndTime(a.l)
  get_Tolls(a.l)
  NotifyTollStateChanged(a.l, b.l)
EndInterface

; ICAComponent interface definition
;
Interface ICAComponent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Component(a.l)
  get_Denials(a.l)
  get_Request(a.l)
EndInterface

; ICAResDenialTree interface definition
;
Interface ICAResDenialTree
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_CAManager(a.l)
  put_CAManager(a.l)
  get_DisplayFields(a.l)
  put_DisplayFields(a.l)
  UpdateView(a.l)
  NotifyRequestActivated(a.l)
  NotifyRequestDeactivated(a.l)
  NotifyOfferAdded(a.l, b.l)
  NotifyOfferRemoved(a.l, b.l)
  NotifyPolicyAdded(a.l, b.l)
  NotifyPolicyRemoved(a.l, b.l)
  NotifyRequestDenialAdded(a.l, b.l, c.l)
  NotifyRequestDenialRemoved(a.l, b.l, c.l)
  NotifyDenialTollAdded(a.l, b.l, c.l)
  NotifyDenialTollRemoved(a.l, b.l, c.l)
  NotifyTollDenialAdded(a.l, b.l, c.l)
  NotifyTollDenialRemoved(a.l, b.l, c.l)
  NotifyOfferTollAdded(a.l, b.l, c.l)
  NotifyOfferTollRemoved(a.l, b.l, c.l)
  NotifyTollStateChanged(a.l, b.l)
  NotifyDenialStateChanged(a.l, b.l)
  NotifyComponentDenialAdded(a.l, b.l, c.l)
  NotifyComponentDenialRemoved(a.l, b.l, c.l)
EndInterface

; _ICADefaultDlgEvents interface definition
;
Interface _ICADefaultDlgEvents
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
EndInterface
