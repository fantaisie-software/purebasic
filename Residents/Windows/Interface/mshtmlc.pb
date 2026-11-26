
; IHTMLFiltersCollection interface definition
;
Interface IHTMLFiltersCollection Extends IDispatch
  get_length(a.l)
  get__newEnum(a.l)
  item(a.l, b.l)
EndInterface

; IHTMLEventObj interface definition
;
Interface IHTMLEventObj Extends IDispatch
  get_srcElement(a.l)
  get_altKey(a.l)
  get_ctrlKey(a.l)
  get_shiftKey(a.l)
  put_returnValue(a.p-variant)
  get_returnValue(a.l)
  put_cancelBubble(a.l)
  get_cancelBubble(a.l)
  get_fromElement(a.l)
  get_toElement(a.l)
  put_keyCode(a.l)
  get_keyCode(a.l)
  get_button(a.l)
  get_type(a.l)
  get_qualifier(a.l)
  get_reason(a.l)
  get_x(a.l)
  get_y(a.l)
  get_clientX(a.l)
  get_clientY(a.l)
  get_offsetX(a.l)
  get_offsetY(a.l)
  get_screenX(a.l)
  get_screenY(a.l)
  get_srcFilter(a.l)
EndInterface

; IElementBehaviorSite interface definition
;
Interface IElementBehaviorSite Extends IUnknown
  GetElement(a.l)
  RegisterNotification(a.l)
EndInterface

; IElementBehavior interface definition
;
Interface IElementBehavior Extends IUnknown
  Init(a.l)
  Notify(a.l, b.l)
  Detach()
EndInterface

; IElementBehaviorFactory interface definition
;
Interface IElementBehaviorFactory Extends IUnknown
  FindBehavior(a.p-bstr, b.p-bstr, c.l, d.l)
EndInterface

; IElementBehaviorSiteOM interface definition
;
Interface IElementBehaviorSiteOM Extends IUnknown
  RegisterEvent(a.p-unicode, b.l, c.l)
  GetEventCookie(a.p-unicode, b.l)
  FireEvent(a.l, b.l)
  CreateEventObject(a.l)
  RegisterName(a.p-unicode)
  RegisterUrn(a.p-unicode)
EndInterface

; IElementBehaviorRender interface definition
;
Interface IElementBehaviorRender Extends IUnknown
  Draw(a.l, b.l, c.l, d.l)
  GetRenderInfo(a.l)
  HitTestPoint(a.l, b.l, c.l)
EndInterface

; IElementBehaviorSiteRender interface definition
;
Interface IElementBehaviorSiteRender Extends IUnknown
  Invalidate(a.l)
  InvalidateRenderInfo()
  InvalidateStyle()
EndInterface

; IHTMLStyle interface definition
;
Interface IHTMLStyle Extends IDispatch
  put_fontFamily(a.p-bstr)
  get_fontFamily(a.l)
  put_fontStyle(a.p-bstr)
  get_fontStyle(a.l)
  put_fontVariant(a.p-bstr)
  get_fontVariant(a.l)
  put_fontWeight(a.p-bstr)
  get_fontWeight(a.l)
  put_fontSize(a.p-variant)
  get_fontSize(a.l)
  put_font(a.p-bstr)
  get_font(a.l)
  put_color(a.p-variant)
  get_color(a.l)
  put_background(a.p-bstr)
  get_background(a.l)
  put_backgroundColor(a.p-variant)
  get_backgroundColor(a.l)
  put_backgroundImage(a.p-bstr)
  get_backgroundImage(a.l)
  put_backgroundRepeat(a.p-bstr)
  get_backgroundRepeat(a.l)
  put_backgroundAttachment(a.p-bstr)
  get_backgroundAttachment(a.l)
  put_backgroundPosition(a.p-bstr)
  get_backgroundPosition(a.l)
  put_backgroundPositionX(a.p-variant)
  get_backgroundPositionX(a.l)
  put_backgroundPositionY(a.p-variant)
  get_backgroundPositionY(a.l)
  put_wordSpacing(a.p-variant)
  get_wordSpacing(a.l)
  put_letterSpacing(a.p-variant)
  get_letterSpacing(a.l)
  put_textDecoration(a.p-bstr)
  get_textDecoration(a.l)
  put_textDecorationNone(a.l)
  get_textDecorationNone(a.l)
  put_textDecorationUnderline(a.l)
  get_textDecorationUnderline(a.l)
  put_textDecorationOverline(a.l)
  get_textDecorationOverline(a.l)
  put_textDecorationLineThrough(a.l)
  get_textDecorationLineThrough(a.l)
  put_textDecorationBlink(a.l)
  get_textDecorationBlink(a.l)
  put_verticalAlign(a.p-variant)
  get_verticalAlign(a.l)
  put_textTransform(a.p-bstr)
  get_textTransform(a.l)
  put_textAlign(a.p-bstr)
  get_textAlign(a.l)
  put_textIndent(a.p-variant)
  get_textIndent(a.l)
  put_lineHeight(a.p-variant)
  get_lineHeight(a.l)
  put_marginTop(a.p-variant)
  get_marginTop(a.l)
  put_marginRight(a.p-variant)
  get_marginRight(a.l)
  put_marginBottom(a.p-variant)
  get_marginBottom(a.l)
  put_marginLeft(a.p-variant)
  get_marginLeft(a.l)
  put_margin(a.p-bstr)
  get_margin(a.l)
  put_paddingTop(a.p-variant)
  get_paddingTop(a.l)
  put_paddingRight(a.p-variant)
  get_paddingRight(a.l)
  put_paddingBottom(a.p-variant)
  get_paddingBottom(a.l)
  put_paddingLeft(a.p-variant)
  get_paddingLeft(a.l)
  put_padding(a.p-bstr)
  get_padding(a.l)
  put_border(a.p-bstr)
  get_border(a.l)
  put_borderTop(a.p-bstr)
  get_borderTop(a.l)
  put_borderRight(a.p-bstr)
  get_borderRight(a.l)
  put_borderBottom(a.p-bstr)
  get_borderBottom(a.l)
  put_borderLeft(a.p-bstr)
  get_borderLeft(a.l)
  put_borderColor(a.p-bstr)
  get_borderColor(a.l)
  put_borderTopColor(a.p-variant)
  get_borderTopColor(a.l)
  put_borderRightColor(a.p-variant)
  get_borderRightColor(a.l)
  put_borderBottomColor(a.p-variant)
  get_borderBottomColor(a.l)
  put_borderLeftColor(a.p-variant)
  get_borderLeftColor(a.l)
  put_borderWidth(a.p-bstr)
  get_borderWidth(a.l)
  put_borderTopWidth(a.p-variant)
  get_borderTopWidth(a.l)
  put_borderRightWidth(a.p-variant)
  get_borderRightWidth(a.l)
  put_borderBottomWidth(a.p-variant)
  get_borderBottomWidth(a.l)
  put_borderLeftWidth(a.p-variant)
  get_borderLeftWidth(a.l)
  put_borderStyle(a.p-bstr)
  get_borderStyle(a.l)
  put_borderTopStyle(a.p-bstr)
  get_borderTopStyle(a.l)
  put_borderRightStyle(a.p-bstr)
  get_borderRightStyle(a.l)
  put_borderBottomStyle(a.p-bstr)
  get_borderBottomStyle(a.l)
  put_borderLeftStyle(a.p-bstr)
  get_borderLeftStyle(a.l)
  put_width(a.p-variant)
  get_width(a.l)
  put_height(a.p-variant)
  get_height(a.l)
  put_styleFloat(a.p-bstr)
  get_styleFloat(a.l)
  put_clear(a.p-bstr)
  get_clear(a.l)
  put_display(a.p-bstr)
  get_display(a.l)
  put_visibility(a.p-bstr)
  get_visibility(a.l)
  put_listStyleType(a.p-bstr)
  get_listStyleType(a.l)
  put_listStylePosition(a.p-bstr)
  get_listStylePosition(a.l)
  put_listStyleImage(a.p-bstr)
  get_listStyleImage(a.l)
  put_listStyle(a.p-bstr)
  get_listStyle(a.l)
  put_whiteSpace(a.p-bstr)
  get_whiteSpace(a.l)
  put_top(a.p-variant)
  get_top(a.l)
  put_left(a.p-variant)
  get_left(a.l)
  get_position(a.l)
  put_zIndex(a.p-variant)
  get_zIndex(a.l)
  put_overflow(a.p-bstr)
  get_overflow(a.l)
  put_pageBreakBefore(a.p-bstr)
  get_pageBreakBefore(a.l)
  put_pageBreakAfter(a.p-bstr)
  get_pageBreakAfter(a.l)
  put_cssText(a.p-bstr)
  get_cssText(a.l)
  put_pixelTop(a.l)
  get_pixelTop(a.l)
  put_pixelLeft(a.l)
  get_pixelLeft(a.l)
  put_pixelWidth(a.l)
  get_pixelWidth(a.l)
  put_pixelHeight(a.l)
  get_pixelHeight(a.l)
  put_posTop(a.l)
  get_posTop(a.l)
  put_posLeft(a.l)
  get_posLeft(a.l)
  put_posWidth(a.l)
  get_posWidth(a.l)
  put_posHeight(a.l)
  get_posHeight(a.l)
  put_cursor(a.p-bstr)
  get_cursor(a.l)
  put_clip(a.p-bstr)
  get_clip(a.l)
  put_filter(a.p-bstr)
  get_filter(a.l)
  setAttribute(a.p-bstr, b.p-variant, c.l)
  getAttribute(a.p-bstr, b.l, c.l)
  removeAttribute(a.p-bstr, b.l, c.l)
  toString(a.l)
EndInterface

; IHTMLStyle2 interface definition
;
Interface IHTMLStyle2 Extends IDispatch
  put_tableLayout(a.p-bstr)
  get_tableLayout(a.l)
  put_borderCollapse(a.p-bstr)
  get_borderCollapse(a.l)
  put_direction(a.p-bstr)
  get_direction(a.l)
  put_behavior(a.p-bstr)
  get_behavior(a.l)
  setExpression(a.p-bstr, b.p-bstr, c.p-bstr)
  getExpression(a.p-bstr, b.l)
  removeExpression(a.p-bstr, b.l)
  put_position(a.p-bstr)
  get_position(a.l)
  put_unicodeBidi(a.p-bstr)
  get_unicodeBidi(a.l)
  put_bottom(a.p-variant)
  get_bottom(a.l)
  put_right(a.p-variant)
  get_right(a.l)
  put_pixelBottom(a.l)
  get_pixelBottom(a.l)
  put_pixelRight(a.l)
  get_pixelRight(a.l)
  put_posBottom(a.l)
  get_posBottom(a.l)
  put_posRight(a.l)
  get_posRight(a.l)
  put_imeMode(a.p-bstr)
  get_imeMode(a.l)
  put_rubyAlign(a.p-bstr)
  get_rubyAlign(a.l)
  put_rubyPosition(a.p-bstr)
  get_rubyPosition(a.l)
  put_rubyOverhang(a.p-bstr)
  get_rubyOverhang(a.l)
  put_layoutGridChar(a.p-variant)
  get_layoutGridChar(a.l)
  put_layoutGridLine(a.p-variant)
  get_layoutGridLine(a.l)
  put_layoutGridMode(a.p-bstr)
  get_layoutGridMode(a.l)
  put_layoutGridType(a.p-bstr)
  get_layoutGridType(a.l)
  put_layoutGrid(a.p-bstr)
  get_layoutGrid(a.l)
  put_wordBreak(a.p-bstr)
  get_wordBreak(a.l)
  put_lineBreak(a.p-bstr)
  get_lineBreak(a.l)
  put_textJustify(a.p-bstr)
  get_textJustify(a.l)
  put_textJustifyTrim(a.p-bstr)
  get_textJustifyTrim(a.l)
  put_textKashida(a.p-variant)
  get_textKashida(a.l)
  put_textAutospace(a.p-bstr)
  get_textAutospace(a.l)
  put_overflowX(a.p-bstr)
  get_overflowX(a.l)
  put_overflowY(a.p-bstr)
  get_overflowY(a.l)
  put_accelerator(a.p-bstr)
  get_accelerator(a.l)
EndInterface

; IHTMLStyle3 interface definition
;
Interface IHTMLStyle3 Extends IDispatch
  put_layoutFlow(a.p-bstr)
  get_layoutFlow(a.l)
  put_zoom(a.p-variant)
  get_zoom(a.l)
  put_wordWrap(a.p-bstr)
  get_wordWrap(a.l)
  put_textUnderlinePosition(a.p-bstr)
  get_textUnderlinePosition(a.l)
  put_scrollbarBaseColor(a.p-variant)
  get_scrollbarBaseColor(a.l)
  put_scrollbarFaceColor(a.p-variant)
  get_scrollbarFaceColor(a.l)
  put_scrollbar3dLightColor(a.p-variant)
  get_scrollbar3dLightColor(a.l)
  put_scrollbarShadowColor(a.p-variant)
  get_scrollbarShadowColor(a.l)
  put_scrollbarHighlightColor(a.p-variant)
  get_scrollbarHighlightColor(a.l)
  put_scrollbarDarkShadowColor(a.p-variant)
  get_scrollbarDarkShadowColor(a.l)
  put_scrollbarArrowColor(a.p-variant)
  get_scrollbarArrowColor(a.l)
  put_scrollbarTrackColor(a.p-variant)
  get_scrollbarTrackColor(a.l)
  put_writingMode(a.p-bstr)
  get_writingMode(a.l)
  put_textAlignLast(a.p-bstr)
  get_textAlignLast(a.l)
  put_textKashidaSpace(a.p-variant)
  get_textKashidaSpace(a.l)
EndInterface

; IHTMLStyle4 interface definition
;
Interface IHTMLStyle4 Extends IDispatch
  put_textOverflow(a.p-bstr)
  get_textOverflow(a.l)
  put_minHeight(a.p-variant)
  get_minHeight(a.l)
EndInterface

; IHTMLRuleStyle interface definition
;
Interface IHTMLRuleStyle Extends IDispatch
  put_fontFamily(a.p-bstr)
  get_fontFamily(a.l)
  put_fontStyle(a.p-bstr)
  get_fontStyle(a.l)
  put_fontVariant(a.p-bstr)
  get_fontVariant(a.l)
  put_fontWeight(a.p-bstr)
  get_fontWeight(a.l)
  put_fontSize(a.p-variant)
  get_fontSize(a.l)
  put_font(a.p-bstr)
  get_font(a.l)
  put_color(a.p-variant)
  get_color(a.l)
  put_background(a.p-bstr)
  get_background(a.l)
  put_backgroundColor(a.p-variant)
  get_backgroundColor(a.l)
  put_backgroundImage(a.p-bstr)
  get_backgroundImage(a.l)
  put_backgroundRepeat(a.p-bstr)
  get_backgroundRepeat(a.l)
  put_backgroundAttachment(a.p-bstr)
  get_backgroundAttachment(a.l)
  put_backgroundPosition(a.p-bstr)
  get_backgroundPosition(a.l)
  put_backgroundPositionX(a.p-variant)
  get_backgroundPositionX(a.l)
  put_backgroundPositionY(a.p-variant)
  get_backgroundPositionY(a.l)
  put_wordSpacing(a.p-variant)
  get_wordSpacing(a.l)
  put_letterSpacing(a.p-variant)
  get_letterSpacing(a.l)
  put_textDecoration(a.p-bstr)
  get_textDecoration(a.l)
  put_textDecorationNone(a.l)
  get_textDecorationNone(a.l)
  put_textDecorationUnderline(a.l)
  get_textDecorationUnderline(a.l)
  put_textDecorationOverline(a.l)
  get_textDecorationOverline(a.l)
  put_textDecorationLineThrough(a.l)
  get_textDecorationLineThrough(a.l)
  put_textDecorationBlink(a.l)
  get_textDecorationBlink(a.l)
  put_verticalAlign(a.p-variant)
  get_verticalAlign(a.l)
  put_textTransform(a.p-bstr)
  get_textTransform(a.l)
  put_textAlign(a.p-bstr)
  get_textAlign(a.l)
  put_textIndent(a.p-variant)
  get_textIndent(a.l)
  put_lineHeight(a.p-variant)
  get_lineHeight(a.l)
  put_marginTop(a.p-variant)
  get_marginTop(a.l)
  put_marginRight(a.p-variant)
  get_marginRight(a.l)
  put_marginBottom(a.p-variant)
  get_marginBottom(a.l)
  put_marginLeft(a.p-variant)
  get_marginLeft(a.l)
  put_margin(a.p-bstr)
  get_margin(a.l)
  put_paddingTop(a.p-variant)
  get_paddingTop(a.l)
  put_paddingRight(a.p-variant)
  get_paddingRight(a.l)
  put_paddingBottom(a.p-variant)
  get_paddingBottom(a.l)
  put_paddingLeft(a.p-variant)
  get_paddingLeft(a.l)
  put_padding(a.p-bstr)
  get_padding(a.l)
  put_border(a.p-bstr)
  get_border(a.l)
  put_borderTop(a.p-bstr)
  get_borderTop(a.l)
  put_borderRight(a.p-bstr)
  get_borderRight(a.l)
  put_borderBottom(a.p-bstr)
  get_borderBottom(a.l)
  put_borderLeft(a.p-bstr)
  get_borderLeft(a.l)
  put_borderColor(a.p-bstr)
  get_borderColor(a.l)
  put_borderTopColor(a.p-variant)
  get_borderTopColor(a.l)
  put_borderRightColor(a.p-variant)
  get_borderRightColor(a.l)
  put_borderBottomColor(a.p-variant)
  get_borderBottomColor(a.l)
  put_borderLeftColor(a.p-variant)
  get_borderLeftColor(a.l)
  put_borderWidth(a.p-bstr)
  get_borderWidth(a.l)
  put_borderTopWidth(a.p-variant)
  get_borderTopWidth(a.l)
  put_borderRightWidth(a.p-variant)
  get_borderRightWidth(a.l)
  put_borderBottomWidth(a.p-variant)
  get_borderBottomWidth(a.l)
  put_borderLeftWidth(a.p-variant)
  get_borderLeftWidth(a.l)
  put_borderStyle(a.p-bstr)
  get_borderStyle(a.l)
  put_borderTopStyle(a.p-bstr)
  get_borderTopStyle(a.l)
  put_borderRightStyle(a.p-bstr)
  get_borderRightStyle(a.l)
  put_borderBottomStyle(a.p-bstr)
  get_borderBottomStyle(a.l)
  put_borderLeftStyle(a.p-bstr)
  get_borderLeftStyle(a.l)
  put_width(a.p-variant)
  get_width(a.l)
  put_height(a.p-variant)
  get_height(a.l)
  put_styleFloat(a.p-bstr)
  get_styleFloat(a.l)
  put_clear(a.p-bstr)
  get_clear(a.l)
  put_display(a.p-bstr)
  get_display(a.l)
  put_visibility(a.p-bstr)
  get_visibility(a.l)
  put_listStyleType(a.p-bstr)
  get_listStyleType(a.l)
  put_listStylePosition(a.p-bstr)
  get_listStylePosition(a.l)
  put_listStyleImage(a.p-bstr)
  get_listStyleImage(a.l)
  put_listStyle(a.p-bstr)
  get_listStyle(a.l)
  put_whiteSpace(a.p-bstr)
  get_whiteSpace(a.l)
  put_top(a.p-variant)
  get_top(a.l)
  put_left(a.p-variant)
  get_left(a.l)
  get_position(a.l)
  put_zIndex(a.p-variant)
  get_zIndex(a.l)
  put_overflow(a.p-bstr)
  get_overflow(a.l)
  put_pageBreakBefore(a.p-bstr)
  get_pageBreakBefore(a.l)
  put_pageBreakAfter(a.p-bstr)
  get_pageBreakAfter(a.l)
  put_cssText(a.p-bstr)
  get_cssText(a.l)
  put_cursor(a.p-bstr)
  get_cursor(a.l)
  put_clip(a.p-bstr)
  get_clip(a.l)
  put_filter(a.p-bstr)
  get_filter(a.l)
  setAttribute(a.p-bstr, b.p-variant, c.l)
  getAttribute(a.p-bstr, b.l, c.l)
  removeAttribute(a.p-bstr, b.l, c.l)
EndInterface

; IHTMLRuleStyle2 interface definition
;
Interface IHTMLRuleStyle2 Extends IDispatch
  put_tableLayout(a.p-bstr)
  get_tableLayout(a.l)
  put_borderCollapse(a.p-bstr)
  get_borderCollapse(a.l)
  put_direction(a.p-bstr)
  get_direction(a.l)
  put_behavior(a.p-bstr)
  get_behavior(a.l)
  put_position(a.p-bstr)
  get_position(a.l)
  put_unicodeBidi(a.p-bstr)
  get_unicodeBidi(a.l)
  put_bottom(a.p-variant)
  get_bottom(a.l)
  put_right(a.p-variant)
  get_right(a.l)
  put_pixelBottom(a.l)
  get_pixelBottom(a.l)
  put_pixelRight(a.l)
  get_pixelRight(a.l)
  put_posBottom(a.l)
  get_posBottom(a.l)
  put_posRight(a.l)
  get_posRight(a.l)
  put_imeMode(a.p-bstr)
  get_imeMode(a.l)
  put_rubyAlign(a.p-bstr)
  get_rubyAlign(a.l)
  put_rubyPosition(a.p-bstr)
  get_rubyPosition(a.l)
  put_rubyOverhang(a.p-bstr)
  get_rubyOverhang(a.l)
  put_layoutGridChar(a.p-variant)
  get_layoutGridChar(a.l)
  put_layoutGridLine(a.p-variant)
  get_layoutGridLine(a.l)
  put_layoutGridMode(a.p-bstr)
  get_layoutGridMode(a.l)
  put_layoutGridType(a.p-bstr)
  get_layoutGridType(a.l)
  put_layoutGrid(a.p-bstr)
  get_layoutGrid(a.l)
  put_textAutospace(a.p-bstr)
  get_textAutospace(a.l)
  put_wordBreak(a.p-bstr)
  get_wordBreak(a.l)
  put_lineBreak(a.p-bstr)
  get_lineBreak(a.l)
  put_textJustify(a.p-bstr)
  get_textJustify(a.l)
  put_textJustifyTrim(a.p-bstr)
  get_textJustifyTrim(a.l)
  put_textKashida(a.p-variant)
  get_textKashida(a.l)
  put_overflowX(a.p-bstr)
  get_overflowX(a.l)
  put_overflowY(a.p-bstr)
  get_overflowY(a.l)
  put_accelerator(a.p-bstr)
  get_accelerator(a.l)
EndInterface

; IHTMLRuleStyle3 interface definition
;
Interface IHTMLRuleStyle3 Extends IDispatch
  put_layoutFlow(a.p-bstr)
  get_layoutFlow(a.l)
  put_zoom(a.p-variant)
  get_zoom(a.l)
  put_wordWrap(a.p-bstr)
  get_wordWrap(a.l)
  put_textUnderlinePosition(a.p-bstr)
  get_textUnderlinePosition(a.l)
  put_scrollbarBaseColor(a.p-variant)
  get_scrollbarBaseColor(a.l)
  put_scrollbarFaceColor(a.p-variant)
  get_scrollbarFaceColor(a.l)
  put_scrollbar3dLightColor(a.p-variant)
  get_scrollbar3dLightColor(a.l)
  put_scrollbarShadowColor(a.p-variant)
  get_scrollbarShadowColor(a.l)
  put_scrollbarHighlightColor(a.p-variant)
  get_scrollbarHighlightColor(a.l)
  put_scrollbarDarkShadowColor(a.p-variant)
  get_scrollbarDarkShadowColor(a.l)
  put_scrollbarArrowColor(a.p-variant)
  get_scrollbarArrowColor(a.l)
  put_scrollbarTrackColor(a.p-variant)
  get_scrollbarTrackColor(a.l)
  put_writingMode(a.p-bstr)
  get_writingMode(a.l)
  put_textAlignLast(a.p-bstr)
  get_textAlignLast(a.l)
  put_textKashidaSpace(a.p-variant)
  get_textKashidaSpace(a.l)
EndInterface

; IHTMLRuleStyle4 interface definition
;
Interface IHTMLRuleStyle4 Extends IDispatch
  put_textOverflow(a.p-bstr)
  get_textOverflow(a.l)
  put_minHeight(a.p-variant)
  get_minHeight(a.l)
EndInterface

; DispHTMLStyle interface definition
;
Interface DispHTMLStyle Extends IDispatch
EndInterface

; DispHTMLRuleStyle interface definition
;
Interface DispHTMLRuleStyle Extends IDispatch
EndInterface

; IHTMLRenderStyle interface definition
;
Interface IHTMLRenderStyle Extends IDispatch
  put_textLineThroughStyle(a.p-bstr)
  get_textLineThroughStyle(a.l)
  put_textUnderlineStyle(a.p-bstr)
  get_textUnderlineStyle(a.l)
  put_textEffect(a.p-bstr)
  get_textEffect(a.l)
  put_textColor(a.p-variant)
  get_textColor(a.l)
  put_textBackgroundColor(a.p-variant)
  get_textBackgroundColor(a.l)
  put_textDecorationColor(a.p-variant)
  get_textDecorationColor(a.l)
  put_renderingPriority(a.l)
  get_renderingPriority(a.l)
  put_defaultTextSelection(a.p-bstr)
  get_defaultTextSelection(a.l)
  put_textDecoration(a.p-bstr)
  get_textDecoration(a.l)
EndInterface

; DispHTMLRenderStyle interface definition
;
Interface DispHTMLRenderStyle Extends IDispatch
EndInterface

; IHTMLCurrentStyle interface definition
;
Interface IHTMLCurrentStyle Extends IDispatch
  get_position(a.l)
  get_styleFloat(a.l)
  get_color(a.l)
  get_backgroundColor(a.l)
  get_fontFamily(a.l)
  get_fontStyle(a.l)
  get_fontVariant(a.l)
  get_fontWeight(a.l)
  get_fontSize(a.l)
  get_backgroundImage(a.l)
  get_backgroundPositionX(a.l)
  get_backgroundPositionY(a.l)
  get_backgroundRepeat(a.l)
  get_borderLeftColor(a.l)
  get_borderTopColor(a.l)
  get_borderRightColor(a.l)
  get_borderBottomColor(a.l)
  get_borderTopStyle(a.l)
  get_borderRightStyle(a.l)
  get_borderBottomStyle(a.l)
  get_borderLeftStyle(a.l)
  get_borderTopWidth(a.l)
  get_borderRightWidth(a.l)
  get_borderBottomWidth(a.l)
  get_borderLeftWidth(a.l)
  get_left(a.l)
  get_top(a.l)
  get_width(a.l)
  get_height(a.l)
  get_paddingLeft(a.l)
  get_paddingTop(a.l)
  get_paddingRight(a.l)
  get_paddingBottom(a.l)
  get_textAlign(a.l)
  get_textDecoration(a.l)
  get_display(a.l)
  get_visibility(a.l)
  get_zIndex(a.l)
  get_letterSpacing(a.l)
  get_lineHeight(a.l)
  get_textIndent(a.l)
  get_verticalAlign(a.l)
  get_backgroundAttachment(a.l)
  get_marginTop(a.l)
  get_marginRight(a.l)
  get_marginBottom(a.l)
  get_marginLeft(a.l)
  get_clear(a.l)
  get_listStyleType(a.l)
  get_listStylePosition(a.l)
  get_listStyleImage(a.l)
  get_clipTop(a.l)
  get_clipRight(a.l)
  get_clipBottom(a.l)
  get_clipLeft(a.l)
  get_overflow(a.l)
  get_pageBreakBefore(a.l)
  get_pageBreakAfter(a.l)
  get_cursor(a.l)
  get_tableLayout(a.l)
  get_borderCollapse(a.l)
  get_direction(a.l)
  get_behavior(a.l)
  getAttribute(a.p-bstr, b.l, c.l)
  get_unicodeBidi(a.l)
  get_right(a.l)
  get_bottom(a.l)
  get_imeMode(a.l)
  get_rubyAlign(a.l)
  get_rubyPosition(a.l)
  get_rubyOverhang(a.l)
  get_textAutospace(a.l)
  get_lineBreak(a.l)
  get_wordBreak(a.l)
  get_textJustify(a.l)
  get_textJustifyTrim(a.l)
  get_textKashida(a.l)
  get_blockDirection(a.l)
  get_layoutGridChar(a.l)
  get_layoutGridLine(a.l)
  get_layoutGridMode(a.l)
  get_layoutGridType(a.l)
  get_borderStyle(a.l)
  get_borderColor(a.l)
  get_borderWidth(a.l)
  get_padding(a.l)
  get_margin(a.l)
  get_accelerator(a.l)
  get_overflowX(a.l)
  get_overflowY(a.l)
  get_textTransform(a.l)
EndInterface

; IHTMLCurrentStyle2 interface definition
;
Interface IHTMLCurrentStyle2 Extends IDispatch
  get_layoutFlow(a.l)
  get_wordWrap(a.l)
  get_textUnderlinePosition(a.l)
  get_hasLayout(a.l)
  get_scrollbarBaseColor(a.l)
  get_scrollbarFaceColor(a.l)
  get_scrollbar3dLightColor(a.l)
  get_scrollbarShadowColor(a.l)
  get_scrollbarHighlightColor(a.l)
  get_scrollbarDarkShadowColor(a.l)
  get_scrollbarArrowColor(a.l)
  get_scrollbarTrackColor(a.l)
  get_writingMode(a.l)
  get_zoom(a.l)
  get_filter(a.l)
  get_textAlignLast(a.l)
  get_textKashidaSpace(a.l)
  get_isBlock(a.l)
EndInterface

; IHTMLCurrentStyle3 interface definition
;
Interface IHTMLCurrentStyle3 Extends IDispatch
  get_textOverflow(a.l)
  get_minHeight(a.l)
  get_wordSpacing(a.l)
  get_whiteSpace(a.l)
EndInterface

; DispHTMLCurrentStyle interface definition
;
Interface DispHTMLCurrentStyle Extends IDispatch
EndInterface

; IHTMLElement interface definition
;
Interface IHTMLElement Extends IDispatch
  setAttribute(a.p-bstr, b.p-variant, c.l)
  getAttribute(a.p-bstr, b.l, c.l)
  removeAttribute(a.p-bstr, b.l, c.l)
  put_className(a.p-bstr)
  get_className(a.l)
  put_id(a.p-bstr)
  get_id(a.l)
  get_tagName(a.l)
  get_parentElement(a.l)
  get_style(a.l)
  put_onhelp(a.p-variant)
  get_onhelp(a.l)
  put_onclick(a.p-variant)
  get_onclick(a.l)
  put_ondblclick(a.p-variant)
  get_ondblclick(a.l)
  put_onkeydown(a.p-variant)
  get_onkeydown(a.l)
  put_onkeyup(a.p-variant)
  get_onkeyup(a.l)
  put_onkeypress(a.p-variant)
  get_onkeypress(a.l)
  put_onmouseout(a.p-variant)
  get_onmouseout(a.l)
  put_onmouseover(a.p-variant)
  get_onmouseover(a.l)
  put_onmousemove(a.p-variant)
  get_onmousemove(a.l)
  put_onmousedown(a.p-variant)
  get_onmousedown(a.l)
  put_onmouseup(a.p-variant)
  get_onmouseup(a.l)
  get_document(a.l)
  put_title(a.p-bstr)
  get_title(a.l)
  put_language(a.p-bstr)
  get_language(a.l)
  put_onselectstart(a.p-variant)
  get_onselectstart(a.l)
  scrollIntoView(a.p-variant)
  contains(a.l, b.l)
  get_sourceIndex(a.l)
  get_recordNumber(a.l)
  put_lang(a.p-bstr)
  get_lang(a.l)
  get_offsetLeft(a.l)
  get_offsetTop(a.l)
  get_offsetWidth(a.l)
  get_offsetHeight(a.l)
  get_offsetParent(a.l)
  put_innerHTML(a.p-bstr)
  get_innerHTML(a.l)
  put_innerText(a.p-bstr)
  get_innerText(a.l)
  put_outerHTML(a.p-bstr)
  get_outerHTML(a.l)
  put_outerText(a.p-bstr)
  get_outerText(a.l)
  insertAdjacentHTML(a.p-bstr, b.p-bstr)
  insertAdjacentText(a.p-bstr, b.p-bstr)
  get_parentTextEdit(a.l)
  get_isTextEdit(a.l)
  click()
  get_filters(a.l)
  put_ondragstart(a.p-variant)
  get_ondragstart(a.l)
  toString(a.l)
  put_onbeforeupdate(a.p-variant)
  get_onbeforeupdate(a.l)
  put_onafterupdate(a.p-variant)
  get_onafterupdate(a.l)
  put_onerrorupdate(a.p-variant)
  get_onerrorupdate(a.l)
  put_onrowexit(a.p-variant)
  get_onrowexit(a.l)
  put_onrowenter(a.p-variant)
  get_onrowenter(a.l)
  put_ondatasetchanged(a.p-variant)
  get_ondatasetchanged(a.l)
  put_ondataavailable(a.p-variant)
  get_ondataavailable(a.l)
  put_ondatasetcomplete(a.p-variant)
  get_ondatasetcomplete(a.l)
  put_onfilterchange(a.p-variant)
  get_onfilterchange(a.l)
  get_children(a.l)
  get_all(a.l)
EndInterface

; IHTMLRect interface definition
;
Interface IHTMLRect Extends IDispatch
  put_left(a.l)
  get_left(a.l)
  put_top(a.l)
  get_top(a.l)
  put_right(a.l)
  get_right(a.l)
  put_bottom(a.l)
  get_bottom(a.l)
EndInterface

; IHTMLRectCollection interface definition
;
Interface IHTMLRectCollection Extends IDispatch
  get_length(a.l)
  get__newEnum(a.l)
  item(a.l, b.l)
EndInterface

; IHTMLDOMNode interface definition
;
Interface IHTMLDOMNode Extends IDispatch
  get_nodeType(a.l)
  get_parentNode(a.l)
  hasChildNodes(a.l)
  get_childNodes(a.l)
  get_attributes(a.l)
  insertBefore(a.l, b.p-variant, c.l)
  removeChild(a.l, b.l)
  replaceChild(a.l, b.l, c.l)
  cloneNode(a.l, b.l)
  removeNode(a.l, b.l)
  swapNode(a.l, b.l)
  replaceNode(a.l, b.l)
  appendChild(a.l, b.l)
  get_nodeName(a.l)
  put_nodeValue(a.p-variant)
  get_nodeValue(a.l)
  get_firstChild(a.l)
  get_lastChild(a.l)
  get_previousSibling(a.l)
  get_nextSibling(a.l)
EndInterface

; IHTMLDOMNode2 interface definition
;
Interface IHTMLDOMNode2 Extends IDispatch
  get_ownerDocument(a.l)
EndInterface

; IHTMLDOMAttribute interface definition
;
Interface IHTMLDOMAttribute Extends IDispatch
  get_nodeName(a.l)
  put_nodeValue(a.p-variant)
  get_nodeValue(a.l)
  get_specified(a.l)
EndInterface

; IHTMLDOMAttribute2 interface definition
;
Interface IHTMLDOMAttribute2 Extends IDispatch
  get_name(a.l)
  put_value(a.p-bstr)
  get_value(a.l)
  get_expando(a.l)
  get_nodeType(a.l)
  get_parentNode(a.l)
  get_childNodes(a.l)
  get_firstChild(a.l)
  get_lastChild(a.l)
  get_previousSibling(a.l)
  get_nextSibling(a.l)
  get_attributes(a.l)
  get_ownerDocument(a.l)
  insertBefore(a.l, b.p-variant, c.l)
  replaceChild(a.l, b.l, c.l)
  removeChild(a.l, b.l)
  appendChild(a.l, b.l)
  hasChildNodes(a.l)
  cloneNode(a.l, b.l)
EndInterface

; IHTMLDOMTextNode interface definition
;
Interface IHTMLDOMTextNode Extends IDispatch
  put_data(a.p-bstr)
  get_data(a.l)
  toString(a.l)
  get_length(a.l)
  splitText(a.l, b.l)
EndInterface

; IHTMLDOMTextNode2 interface definition
;
Interface IHTMLDOMTextNode2 Extends IDispatch
  substringData(a.l, b.l, c.l)
  appendData(a.p-bstr)
  insertData(a.l, b.p-bstr)
  deleteData(a.l, b.l)
  replaceData(a.l, b.l, c.p-bstr)
EndInterface

; IHTMLDOMImplementation interface definition
;
Interface IHTMLDOMImplementation Extends IDispatch
  hasFeature(a.p-bstr, b.p-variant, c.l)
EndInterface

; DispHTMLDOMAttribute interface definition
;
Interface DispHTMLDOMAttribute Extends IDispatch
EndInterface

; DispHTMLDOMTextNode interface definition
;
Interface DispHTMLDOMTextNode Extends IDispatch
EndInterface

; DispHTMLDOMImplementation interface definition
;
Interface DispHTMLDOMImplementation Extends IDispatch
EndInterface

; IHTMLAttributeCollection interface definition
;
Interface IHTMLAttributeCollection Extends IDispatch
  get_length(a.l)
  get__newEnum(a.l)
  item(a.l, b.l)
EndInterface

; IHTMLAttributeCollection2 interface definition
;
Interface IHTMLAttributeCollection2 Extends IDispatch
  getNamedItem(a.p-bstr, b.l)
  setNamedItem(a.l, b.l)
  removeNamedItem(a.p-bstr, b.l)
EndInterface

; IHTMLDOMChildrenCollection interface definition
;
Interface IHTMLDOMChildrenCollection Extends IDispatch
  get_length(a.l)
  get__newEnum(a.l)
  item(a.l, b.l)
EndInterface

; DispHTMLAttributeCollection interface definition
;
Interface DispHTMLAttributeCollection Extends IDispatch
EndInterface

; DispDOMChildrenCollection interface definition
;
Interface DispDOMChildrenCollection Extends IDispatch
EndInterface

; HTMLElementEvents2 interface definition
;
Interface HTMLElementEvents2 Extends IDispatch
EndInterface

; HTMLElementEvents interface definition
;
Interface HTMLElementEvents Extends IDispatch
EndInterface

; IHTMLElementCollection interface definition
;
Interface IHTMLElementCollection Extends IDispatch
  toString(a.l)
  put_length(a.l)
  get_length(a.l)
  get__newEnum(a.l)
  item(a.p-variant, b.p-variant, c.l)
  tags(a.p-variant, b.l)
EndInterface

; IHTMLElement2 interface definition
;
Interface IHTMLElement2 Extends IDispatch
  get_scopeName(a.l)
  setCapture(a.l)
  releaseCapture()
  put_onlosecapture(a.p-variant)
  get_onlosecapture(a.l)
  componentFromPoint(a.l, b.l, c.l)
  doScroll(a.p-variant)
  put_onscroll(a.p-variant)
  get_onscroll(a.l)
  put_ondrag(a.p-variant)
  get_ondrag(a.l)
  put_ondragend(a.p-variant)
  get_ondragend(a.l)
  put_ondragenter(a.p-variant)
  get_ondragenter(a.l)
  put_ondragover(a.p-variant)
  get_ondragover(a.l)
  put_ondragleave(a.p-variant)
  get_ondragleave(a.l)
  put_ondrop(a.p-variant)
  get_ondrop(a.l)
  put_onbeforecut(a.p-variant)
  get_onbeforecut(a.l)
  put_oncut(a.p-variant)
  get_oncut(a.l)
  put_onbeforecopy(a.p-variant)
  get_onbeforecopy(a.l)
  put_oncopy(a.p-variant)
  get_oncopy(a.l)
  put_onbeforepaste(a.p-variant)
  get_onbeforepaste(a.l)
  put_onpaste(a.p-variant)
  get_onpaste(a.l)
  get_currentStyle(a.l)
  put_onpropertychange(a.p-variant)
  get_onpropertychange(a.l)
  getClientRects(a.l)
  getBoundingClientRect(a.l)
  setExpression(a.p-bstr, b.p-bstr, c.p-bstr)
  getExpression(a.p-bstr, b.l)
  removeExpression(a.p-bstr, b.l)
  put_tabIndex(a.l)
  get_tabIndex(a.l)
  focus()
  put_accessKey(a.p-bstr)
  get_accessKey(a.l)
  put_onblur(a.p-variant)
  get_onblur(a.l)
  put_onfocus(a.p-variant)
  get_onfocus(a.l)
  put_onresize(a.p-variant)
  get_onresize(a.l)
  blur()
  addFilter(a.l)
  removeFilter(a.l)
  get_clientHeight(a.l)
  get_clientWidth(a.l)
  get_clientTop(a.l)
  get_clientLeft(a.l)
  attachEvent(a.p-bstr, b.l, c.l)
  detachEvent(a.p-bstr, b.l)
  get_readyState(a.l)
  put_onreadystatechange(a.p-variant)
  get_onreadystatechange(a.l)
  put_onrowsdelete(a.p-variant)
  get_onrowsdelete(a.l)
  put_onrowsinserted(a.p-variant)
  get_onrowsinserted(a.l)
  put_oncellchange(a.p-variant)
  get_oncellchange(a.l)
  put_dir(a.p-bstr)
  get_dir(a.l)
  createControlRange(a.l)
  get_scrollHeight(a.l)
  get_scrollWidth(a.l)
  put_scrollTop(a.l)
  get_scrollTop(a.l)
  put_scrollLeft(a.l)
  get_scrollLeft(a.l)
  clearAttributes()
  mergeAttributes(a.l)
  put_oncontextmenu(a.p-variant)
  get_oncontextmenu(a.l)
  insertAdjacentElement(a.p-bstr, b.l, c.l)
  applyElement(a.l, b.p-bstr, c.l)
  getAdjacentText(a.p-bstr, b.l)
  replaceAdjacentText(a.p-bstr, b.p-bstr, c.l)
  get_canHaveChildren(a.l)
  addBehavior(a.p-bstr, b.l, c.l)
  removeBehavior(a.l, b.l)
  get_runtimeStyle(a.l)
  get_behaviorUrns(a.l)
  put_tagUrn(a.p-bstr)
  get_tagUrn(a.l)
  put_onbeforeeditfocus(a.p-variant)
  get_onbeforeeditfocus(a.l)
  get_readyStateValue(a.l)
  getElementsByTagName(a.p-bstr, b.l)
EndInterface

; IHTMLElement3 interface definition
;
Interface IHTMLElement3 Extends IDispatch
  mergeAttributes(a.l, b.l)
  get_isMultiLine(a.l)
  get_canHaveHTML(a.l)
  put_onlayoutcomplete(a.p-variant)
  get_onlayoutcomplete(a.l)
  put_onpage(a.p-variant)
  get_onpage(a.l)
  put_inflateBlock(a.l)
  get_inflateBlock(a.l)
  put_onbeforedeactivate(a.p-variant)
  get_onbeforedeactivate(a.l)
  setActive()
  put_contentEditable(a.p-bstr)
  get_contentEditable(a.l)
  get_isContentEditable(a.l)
  put_hideFocus(a.l)
  get_hideFocus(a.l)
  put_disabled(a.l)
  get_disabled(a.l)
  get_isDisabled(a.l)
  put_onmove(a.p-variant)
  get_onmove(a.l)
  put_oncontrolselect(a.p-variant)
  get_oncontrolselect(a.l)
  fireEvent(a.p-bstr, b.l, c.l)
  put_onresizestart(a.p-variant)
  get_onresizestart(a.l)
  put_onresizeend(a.p-variant)
  get_onresizeend(a.l)
  put_onmovestart(a.p-variant)
  get_onmovestart(a.l)
  put_onmoveend(a.p-variant)
  get_onmoveend(a.l)
  put_onmouseenter(a.p-variant)
  get_onmouseenter(a.l)
  put_onmouseleave(a.p-variant)
  get_onmouseleave(a.l)
  put_onactivate(a.p-variant)
  get_onactivate(a.l)
  put_ondeactivate(a.p-variant)
  get_ondeactivate(a.l)
  dragDrop(a.l)
  get_glyphMode(a.l)
EndInterface

; IHTMLElement4 interface definition
;
Interface IHTMLElement4 Extends IDispatch
  put_onmousewheel(a.p-variant)
  get_onmousewheel(a.l)
  normalize()
  getAttributeNode(a.p-bstr, b.l)
  setAttributeNode(a.l, b.l)
  removeAttributeNode(a.l, b.l)
  put_onbeforeactivate(a.p-variant)
  get_onbeforeactivate(a.l)
  put_onfocusin(a.p-variant)
  get_onfocusin(a.l)
  put_onfocusout(a.p-variant)
  get_onfocusout(a.l)
EndInterface

; IHTMLElementRender interface definition
;
Interface IHTMLElementRender Extends IUnknown
  DrawToDC(a.l)
  SetDocumentPrinter(a.p-bstr, b.l)
EndInterface

; IHTMLUniqueName interface definition
;
Interface IHTMLUniqueName Extends IDispatch
  get_uniqueNumber(a.l)
  get_uniqueID(a.l)
EndInterface

; IHTMLDatabinding interface definition
;
Interface IHTMLDatabinding Extends IDispatch
  put_dataFld(a.p-bstr)
  get_dataFld(a.l)
  put_dataSrc(a.p-bstr)
  get_dataSrc(a.l)
  put_dataFormatAs(a.p-bstr)
  get_dataFormatAs(a.l)
EndInterface

; IHTMLDocument interface definition
;
Interface IHTMLDocument Extends IDispatch
  get_Script(a.l)
EndInterface

; IHTMLElementDefaults interface definition
;
Interface IHTMLElementDefaults Extends IDispatch
  get_style(a.l)
  put_tabStop(a.l)
  get_tabStop(a.l)
  put_viewInheritStyle(a.l)
  get_viewInheritStyle(a.l)
  put_viewMasterTab(a.l)
  get_viewMasterTab(a.l)
  put_scrollSegmentX(a.l)
  get_scrollSegmentX(a.l)
  put_scrollSegmentY(a.l)
  get_scrollSegmentY(a.l)
  put_isMultiLine(a.l)
  get_isMultiLine(a.l)
  put_contentEditable(a.p-bstr)
  get_contentEditable(a.l)
  put_canHaveHTML(a.l)
  get_canHaveHTML(a.l)
  putref_viewLink(a.l)
  get_viewLink(a.l)
  put_frozen(a.l)
  get_frozen(a.l)
EndInterface

; DispHTMLDefaults interface definition
;
Interface DispHTMLDefaults Extends IDispatch
EndInterface

; IHTCDefaultDispatch interface definition
;
Interface IHTCDefaultDispatch Extends IDispatch
  get_element(a.l)
  createEventObject(a.l)
  get_defaults(a.l)
  get_document(a.l)
EndInterface

; IHTCPropertyBehavior interface definition
;
Interface IHTCPropertyBehavior Extends IDispatch
  fireChange()
  put_value(a.p-variant)
  get_value(a.l)
EndInterface

; IHTCMethodBehavior interface definition
;
Interface IHTCMethodBehavior Extends IDispatch
EndInterface

; IHTCEventBehavior interface definition
;
Interface IHTCEventBehavior Extends IDispatch
  fire(a.l)
EndInterface

; IHTCAttachBehavior interface definition
;
Interface IHTCAttachBehavior Extends IDispatch
  fireEvent(a.l)
  detachEvent()
EndInterface

; IHTCAttachBehavior2 interface definition
;
Interface IHTCAttachBehavior2 Extends IDispatch
  fireEvent(a.p-variant)
EndInterface

; IHTCDescBehavior interface definition
;
Interface IHTCDescBehavior Extends IDispatch
  get_urn(a.l)
  get_name(a.l)
EndInterface

; DispHTCDefaultDispatch interface definition
;
Interface DispHTCDefaultDispatch Extends IDispatch
EndInterface

; DispHTCPropertyBehavior interface definition
;
Interface DispHTCPropertyBehavior Extends IDispatch
EndInterface

; DispHTCMethodBehavior interface definition
;
Interface DispHTCMethodBehavior Extends IDispatch
EndInterface

; DispHTCEventBehavior interface definition
;
Interface DispHTCEventBehavior Extends IDispatch
EndInterface

; DispHTCAttachBehavior interface definition
;
Interface DispHTCAttachBehavior Extends IDispatch
EndInterface

; DispHTCDescBehavior interface definition
;
Interface DispHTCDescBehavior Extends IDispatch
EndInterface

; IHTMLUrnCollection interface definition
;
Interface IHTMLUrnCollection Extends IDispatch
  get_length(a.l)
  item(a.l, b.l)
EndInterface

; IHTMLGenericElement interface definition
;
Interface IHTMLGenericElement Extends IDispatch
  get_recordset(a.l)
  namedRecordset(a.p-bstr, b.l, c.l)
EndInterface

; DispHTMLGenericElement interface definition
;
Interface DispHTMLGenericElement Extends IDispatch
EndInterface

; IHTMLStyleSheetRule interface definition
;
Interface IHTMLStyleSheetRule Extends IDispatch
  put_selectorText(a.p-bstr)
  get_selectorText(a.l)
  get_style(a.l)
  get_readOnly(a.l)
EndInterface

; IHTMLStyleSheetRulesCollection interface definition
;
Interface IHTMLStyleSheetRulesCollection Extends IDispatch
  get_length(a.l)
  item(a.l, b.l)
EndInterface

; IHTMLStyleSheetPage interface definition
;
Interface IHTMLStyleSheetPage Extends IDispatch
  get_selector(a.l)
  get_pseudoClass(a.l)
EndInterface

; IHTMLStyleSheetPagesCollection interface definition
;
Interface IHTMLStyleSheetPagesCollection Extends IDispatch
  get_length(a.l)
  item(a.l, b.l)
EndInterface

; IHTMLStyleSheetsCollection interface definition
;
Interface IHTMLStyleSheetsCollection Extends IDispatch
  get_length(a.l)
  get__newEnum(a.l)
  item(a.l, b.l)
EndInterface

; IHTMLStyleSheet interface definition
;
Interface IHTMLStyleSheet Extends IDispatch
  put_title(a.p-bstr)
  get_title(a.l)
  get_parentStyleSheet(a.l)
  get_owningElement(a.l)
  put_disabled(a.l)
  get_disabled(a.l)
  get_readOnly(a.l)
  get_imports(a.l)
  put_href(a.p-bstr)
  get_href(a.l)
  get_type(a.l)
  get_id(a.l)
  addImport(a.p-bstr, b.l, c.l)
  addRule(a.p-bstr, b.p-bstr, c.l, d.l)
  removeImport(a.l)
  removeRule(a.l)
  put_media(a.p-bstr)
  get_media(a.l)
  put_cssText(a.p-bstr)
  get_cssText(a.l)
  get_rules(a.l)
EndInterface

; IHTMLStyleSheet2 interface definition
;
Interface IHTMLStyleSheet2 Extends IDispatch
  get_pages(a.l)
  addPageRule(a.p-bstr, b.p-bstr, c.l, d.l)
EndInterface

; DispHTMLStyleSheet interface definition
;
Interface DispHTMLStyleSheet Extends IDispatch
EndInterface

; HTMLLinkElementEvents2 interface definition
;
Interface HTMLLinkElementEvents2 Extends IDispatch
EndInterface

; HTMLLinkElementEvents interface definition
;
Interface HTMLLinkElementEvents Extends IDispatch
EndInterface

; IHTMLLinkElement interface definition
;
Interface IHTMLLinkElement Extends IDispatch
  put_href(a.p-bstr)
  get_href(a.l)
  put_rel(a.p-bstr)
  get_rel(a.l)
  put_rev(a.p-bstr)
  get_rev(a.l)
  put_type(a.p-bstr)
  get_type(a.l)
  get_readyState(a.l)
  put_onreadystatechange(a.p-variant)
  get_onreadystatechange(a.l)
  put_onload(a.p-variant)
  get_onload(a.l)
  put_onerror(a.p-variant)
  get_onerror(a.l)
  get_styleSheet(a.l)
  put_disabled(a.l)
  get_disabled(a.l)
  put_media(a.p-bstr)
  get_media(a.l)
EndInterface

; IHTMLLinkElement2 interface definition
;
Interface IHTMLLinkElement2 Extends IDispatch
  put_target(a.p-bstr)
  get_target(a.l)
EndInterface

; IHTMLLinkElement3 interface definition
;
Interface IHTMLLinkElement3 Extends IDispatch
  put_charset(a.p-bstr)
  get_charset(a.l)
  put_hreflang(a.p-bstr)
  get_hreflang(a.l)
EndInterface

; DispHTMLLinkElement interface definition
;
Interface DispHTMLLinkElement Extends IDispatch
EndInterface

; IHTMLTxtRange interface definition
;
Interface IHTMLTxtRange Extends IDispatch
  get_htmlText(a.l)
  put_text(a.p-bstr)
  get_text(a.l)
  parentElement(a.l)
  duplicate(a.l)
  inRange(a.l, b.l)
  isEqual(a.l, b.l)
  scrollIntoView(a.l)
  collapse(a.l)
  expand(a.p-bstr, b.l)
  move(a.p-bstr, b.l, c.l)
  moveStart(a.p-bstr, b.l, c.l)
  moveEnd(a.p-bstr, b.l, c.l)
  select()
  pasteHTML(a.p-bstr)
  moveToElementText(a.l)
  setEndPoint(a.p-bstr, b.l)
  compareEndPoints(a.p-bstr, b.l, c.l)
  findText(a.p-bstr, b.l, c.l, d.l)
  moveToPoint(a.l, b.l)
  getBookmark(a.l)
  moveToBookmark(a.p-bstr, b.l)
  queryCommandSupported(a.p-bstr, b.l)
  queryCommandEnabled(a.p-bstr, b.l)
  queryCommandState(a.p-bstr, b.l)
  queryCommandIndeterm(a.p-bstr, b.l)
  queryCommandText(a.p-bstr, b.l)
  queryCommandValue(a.p-bstr, b.l)
  execCommand(a.p-bstr, b.l, c.p-variant, d.l)
  execCommandShowHelp(a.p-bstr, b.l)
EndInterface

; IHTMLTextRangeMetrics interface definition
;
Interface IHTMLTextRangeMetrics Extends IDispatch
  get_offsetTop(a.l)
  get_offsetLeft(a.l)
  get_boundingTop(a.l)
  get_boundingLeft(a.l)
  get_boundingWidth(a.l)
  get_boundingHeight(a.l)
EndInterface

; IHTMLTextRangeMetrics2 interface definition
;
Interface IHTMLTextRangeMetrics2 Extends IDispatch
  getClientRects(a.l)
  getBoundingClientRect(a.l)
EndInterface

; IHTMLTxtRangeCollection interface definition
;
Interface IHTMLTxtRangeCollection Extends IDispatch
  get_length(a.l)
  get__newEnum(a.l)
  item(a.l, b.l)
EndInterface

; HTMLFormElementEvents2 interface definition
;
Interface HTMLFormElementEvents2 Extends IDispatch
EndInterface

; HTMLFormElementEvents interface definition
;
Interface HTMLFormElementEvents Extends IDispatch
EndInterface

; IHTMLFormElement interface definition
;
Interface IHTMLFormElement Extends IDispatch
  put_action(a.p-bstr)
  get_action(a.l)
  put_dir(a.p-bstr)
  get_dir(a.l)
  put_encoding(a.p-bstr)
  get_encoding(a.l)
  put_method(a.p-bstr)
  get_method(a.l)
  get_elements(a.l)
  put_target(a.p-bstr)
  get_target(a.l)
  put_name(a.p-bstr)
  get_name(a.l)
  put_onsubmit(a.p-variant)
  get_onsubmit(a.l)
  put_onreset(a.p-variant)
  get_onreset(a.l)
  submit()
  reset()
  put_length(a.l)
  get_length(a.l)
  get__newEnum(a.l)
  item(a.p-variant, b.p-variant, c.l)
  tags(a.p-variant, b.l)
EndInterface

; IHTMLFormElement2 interface definition
;
Interface IHTMLFormElement2 Extends IDispatch
  put_acceptCharset(a.p-bstr)
  get_acceptCharset(a.l)
  urns(a.p-variant, b.l)
EndInterface

; IHTMLFormElement3 interface definition
;
Interface IHTMLFormElement3 Extends IDispatch
  namedItem(a.p-bstr, b.l)
EndInterface

; IHTMLSubmitData interface definition
;
Interface IHTMLSubmitData Extends IDispatch
  appendNameValuePair(a.p-bstr, b.p-bstr)
  appendNameFilePair(a.p-bstr, b.p-bstr)
  appendItemSeparator()
EndInterface

; DispHTMLFormElement interface definition
;
Interface DispHTMLFormElement Extends IDispatch
EndInterface

; HTMLControlElementEvents2 interface definition
;
Interface HTMLControlElementEvents2 Extends IDispatch
EndInterface

; HTMLControlElementEvents interface definition
;
Interface HTMLControlElementEvents Extends IDispatch
EndInterface

; IHTMLControlElement interface definition
;
Interface IHTMLControlElement Extends IDispatch
  put_tabIndex(a.l)
  get_tabIndex(a.l)
  focus()
  put_accessKey(a.p-bstr)
  get_accessKey(a.l)
  put_onblur(a.p-variant)
  get_onblur(a.l)
  put_onfocus(a.p-variant)
  get_onfocus(a.l)
  put_onresize(a.p-variant)
  get_onresize(a.l)
  blur()
  addFilter(a.l)
  removeFilter(a.l)
  get_clientHeight(a.l)
  get_clientWidth(a.l)
  get_clientTop(a.l)
  get_clientLeft(a.l)
EndInterface

; IHTMLTextElement interface definition
;
Interface IHTMLTextElement Extends IDispatch
EndInterface

; DispHTMLTextElement interface definition
;
Interface DispHTMLTextElement Extends IDispatch
EndInterface

; HTMLTextContainerEvents2 interface definition
;
Interface HTMLTextContainerEvents2 Extends IDispatch
EndInterface

; HTMLTextContainerEvents interface definition
;
Interface HTMLTextContainerEvents Extends IDispatch
EndInterface

; IHTMLTextContainer interface definition
;
Interface IHTMLTextContainer Extends IDispatch
  createControlRange(a.l)
  get_scrollHeight(a.l)
  get_scrollWidth(a.l)
  put_scrollTop(a.l)
  get_scrollTop(a.l)
  put_scrollLeft(a.l)
  get_scrollLeft(a.l)
  put_onscroll(a.p-variant)
  get_onscroll(a.l)
EndInterface

; IHTMLControlRange interface definition
;
Interface IHTMLControlRange Extends IDispatch
  select()
  add(a.l)
  remove(a.l)
  item(a.l, b.l)
  scrollIntoView(a.p-variant)
  queryCommandSupported(a.p-bstr, b.l)
  queryCommandEnabled(a.p-bstr, b.l)
  queryCommandState(a.p-bstr, b.l)
  queryCommandIndeterm(a.p-bstr, b.l)
  queryCommandText(a.p-bstr, b.l)
  queryCommandValue(a.p-bstr, b.l)
  execCommand(a.p-bstr, b.l, c.p-variant, d.l)
  execCommandShowHelp(a.p-bstr, b.l)
  commonParentElement(a.l)
  get_length(a.l)
EndInterface

; IHTMLControlRange2 interface definition
;
Interface IHTMLControlRange2 Extends IDispatch
  addElement(a.l)
EndInterface

; HTMLImgEvents2 interface definition
;
Interface HTMLImgEvents2 Extends IDispatch
EndInterface

; HTMLImgEvents interface definition
;
Interface HTMLImgEvents Extends IDispatch
EndInterface

; IHTMLImgElement interface definition
;
Interface IHTMLImgElement Extends IDispatch
  put_isMap(a.l)
  get_isMap(a.l)
  put_useMap(a.p-bstr)
  get_useMap(a.l)
  get_mimeType(a.l)
  get_fileSize(a.l)
  get_fileCreatedDate(a.l)
  get_fileModifiedDate(a.l)
  get_fileUpdatedDate(a.l)
  get_protocol(a.l)
  get_href(a.l)
  get_nameProp(a.l)
  put_border(a.p-variant)
  get_border(a.l)
  put_vspace(a.l)
  get_vspace(a.l)
  put_hspace(a.l)
  get_hspace(a.l)
  put_alt(a.p-bstr)
  get_alt(a.l)
  put_src(a.p-bstr)
  get_src(a.l)
  put_lowsrc(a.p-bstr)
  get_lowsrc(a.l)
  put_vrml(a.p-bstr)
  get_vrml(a.l)
  put_dynsrc(a.p-bstr)
  get_dynsrc(a.l)
  get_readyState(a.l)
  get_complete(a.l)
  put_loop(a.p-variant)
  get_loop(a.l)
  put_align(a.p-bstr)
  get_align(a.l)
  put_onload(a.p-variant)
  get_onload(a.l)
  put_onerror(a.p-variant)
  get_onerror(a.l)
  put_onabort(a.p-variant)
  get_onabort(a.l)
  put_name(a.p-bstr)
  get_name(a.l)
  put_width(a.l)
  get_width(a.l)
  put_height(a.l)
  get_height(a.l)
  put_start(a.p-bstr)
  get_start(a.l)
EndInterface

; IHTMLImgElement2 interface definition
;
Interface IHTMLImgElement2 Extends IDispatch
  put_longDesc(a.p-bstr)
  get_longDesc(a.l)
EndInterface

; IHTMLImageElementFactory interface definition
;
Interface IHTMLImageElementFactory Extends IDispatch
  create(a.p-variant, b.p-variant, c.l)
EndInterface

; DispHTMLImg interface definition
;
Interface DispHTMLImg Extends IDispatch
EndInterface

; IHTMLBodyElement interface definition
;
Interface IHTMLBodyElement Extends IDispatch
  put_background(a.p-bstr)
  get_background(a.l)
  put_bgProperties(a.p-bstr)
  get_bgProperties(a.l)
  put_leftMargin(a.p-variant)
  get_leftMargin(a.l)
  put_topMargin(a.p-variant)
  get_topMargin(a.l)
  put_rightMargin(a.p-variant)
  get_rightMargin(a.l)
  put_bottomMargin(a.p-variant)
  get_bottomMargin(a.l)
  put_noWrap(a.l)
  get_noWrap(a.l)
  put_bgColor(a.p-variant)
  get_bgColor(a.l)
  put_text(a.p-variant)
  get_text(a.l)
  put_link(a.p-variant)
  get_link(a.l)
  put_vLink(a.p-variant)
  get_vLink(a.l)
  put_aLink(a.p-variant)
  get_aLink(a.l)
  put_onload(a.p-variant)
  get_onload(a.l)
  put_onunload(a.p-variant)
  get_onunload(a.l)
  put_scroll(a.p-bstr)
  get_scroll(a.l)
  put_onselect(a.p-variant)
  get_onselect(a.l)
  put_onbeforeunload(a.p-variant)
  get_onbeforeunload(a.l)
  createTextRange(a.l)
EndInterface

; IHTMLBodyElement2 interface definition
;
Interface IHTMLBodyElement2 Extends IDispatch
  put_onbeforeprint(a.p-variant)
  get_onbeforeprint(a.l)
  put_onafterprint(a.p-variant)
  get_onafterprint(a.l)
EndInterface

; DispHTMLBody interface definition
;
Interface DispHTMLBody Extends IDispatch
EndInterface

; IHTMLFontElement interface definition
;
Interface IHTMLFontElement Extends IDispatch
  put_color(a.p-variant)
  get_color(a.l)
  put_face(a.p-bstr)
  get_face(a.l)
  put_size(a.p-variant)
  get_size(a.l)
EndInterface

; DispHTMLFontElement interface definition
;
Interface DispHTMLFontElement Extends IDispatch
EndInterface

; HTMLAnchorEvents2 interface definition
;
Interface HTMLAnchorEvents2 Extends IDispatch
EndInterface

; HTMLAnchorEvents interface definition
;
Interface HTMLAnchorEvents Extends IDispatch
EndInterface

; IHTMLAnchorElement interface definition
;
Interface IHTMLAnchorElement Extends IDispatch
  put_href(a.p-bstr)
  get_href(a.l)
  put_target(a.p-bstr)
  get_target(a.l)
  put_rel(a.p-bstr)
  get_rel(a.l)
  put_rev(a.p-bstr)
  get_rev(a.l)
  put_urn(a.p-bstr)
  get_urn(a.l)
  put_Methods(a.p-bstr)
  get_Methods(a.l)
  put_name(a.p-bstr)
  get_name(a.l)
  put_host(a.p-bstr)
  get_host(a.l)
  put_hostname(a.p-bstr)
  get_hostname(a.l)
  put_pathname(a.p-bstr)
  get_pathname(a.l)
  put_port(a.p-bstr)
  get_port(a.l)
  put_protocol(a.p-bstr)
  get_protocol(a.l)
  put_search(a.p-bstr)
  get_search(a.l)
  put_hash(a.p-bstr)
  get_hash(a.l)
  put_onblur(a.p-variant)
  get_onblur(a.l)
  put_onfocus(a.p-variant)
  get_onfocus(a.l)
  put_accessKey(a.p-bstr)
  get_accessKey(a.l)
  get_protocolLong(a.l)
  get_mimeType(a.l)
  get_nameProp(a.l)
  put_tabIndex(a.l)
  get_tabIndex(a.l)
  focus()
  blur()
EndInterface

; IHTMLAnchorElement2 interface definition
;
Interface IHTMLAnchorElement2 Extends IDispatch
  put_charset(a.p-bstr)
  get_charset(a.l)
  put_coords(a.p-bstr)
  get_coords(a.l)
  put_hreflang(a.p-bstr)
  get_hreflang(a.l)
  put_shape(a.p-bstr)
  get_shape(a.l)
  put_type(a.p-bstr)
  get_type(a.l)
EndInterface

; DispHTMLAnchorElement interface definition
;
Interface DispHTMLAnchorElement Extends IDispatch
EndInterface

; HTMLLabelEvents2 interface definition
;
Interface HTMLLabelEvents2 Extends IDispatch
EndInterface

; HTMLLabelEvents interface definition
;
Interface HTMLLabelEvents Extends IDispatch
EndInterface

; IHTMLLabelElement interface definition
;
Interface IHTMLLabelElement Extends IDispatch
  put_htmlFor(a.p-bstr)
  get_htmlFor(a.l)
  put_accessKey(a.p-bstr)
  get_accessKey(a.l)
EndInterface

; IHTMLLabelElement2 interface definition
;
Interface IHTMLLabelElement2 Extends IDispatch
  get_form(a.l)
EndInterface

; DispHTMLLabelElement interface definition
;
Interface DispHTMLLabelElement Extends IDispatch
EndInterface

; IHTMLListElement interface definition
;
Interface IHTMLListElement Extends IDispatch
EndInterface

; IHTMLListElement2 interface definition
;
Interface IHTMLListElement2 Extends IDispatch
  put_compact(a.l)
  get_compact(a.l)
EndInterface

; DispHTMLListElement interface definition
;
Interface DispHTMLListElement Extends IDispatch
EndInterface

; IHTMLUListElement interface definition
;
Interface IHTMLUListElement Extends IDispatch
  put_compact(a.l)
  get_compact(a.l)
  put_type(a.p-bstr)
  get_type(a.l)
EndInterface

; DispHTMLUListElement interface definition
;
Interface DispHTMLUListElement Extends IDispatch
EndInterface

; IHTMLOListElement interface definition
;
Interface IHTMLOListElement Extends IDispatch
  put_compact(a.l)
  get_compact(a.l)
  put_start(a.l)
  get_start(a.l)
  put_type(a.p-bstr)
  get_type(a.l)
EndInterface

; DispHTMLOListElement interface definition
;
Interface DispHTMLOListElement Extends IDispatch
EndInterface

; IHTMLLIElement interface definition
;
Interface IHTMLLIElement Extends IDispatch
  put_type(a.p-bstr)
  get_type(a.l)
  put_value(a.l)
  get_value(a.l)
EndInterface

; DispHTMLLIElement interface definition
;
Interface DispHTMLLIElement Extends IDispatch
EndInterface

; IHTMLBlockElement interface definition
;
Interface IHTMLBlockElement Extends IDispatch
  put_clear(a.p-bstr)
  get_clear(a.l)
EndInterface

; IHTMLBlockElement2 interface definition
;
Interface IHTMLBlockElement2 Extends IDispatch
  put_cite(a.p-bstr)
  get_cite(a.l)
  put_width(a.p-bstr)
  get_width(a.l)
EndInterface

; DispHTMLBlockElement interface definition
;
Interface DispHTMLBlockElement Extends IDispatch
EndInterface

; IHTMLDivElement interface definition
;
Interface IHTMLDivElement Extends IDispatch
  put_align(a.p-bstr)
  get_align(a.l)
  put_noWrap(a.l)
  get_noWrap(a.l)
EndInterface

; DispHTMLDivElement interface definition
;
Interface DispHTMLDivElement Extends IDispatch
EndInterface

; IHTMLDDElement interface definition
;
Interface IHTMLDDElement Extends IDispatch
  put_noWrap(a.l)
  get_noWrap(a.l)
EndInterface

; DispHTMLDDElement interface definition
;
Interface DispHTMLDDElement Extends IDispatch
EndInterface

; IHTMLDTElement interface definition
;
Interface IHTMLDTElement Extends IDispatch
  put_noWrap(a.l)
  get_noWrap(a.l)
EndInterface

; DispHTMLDTElement interface definition
;
Interface DispHTMLDTElement Extends IDispatch
EndInterface

; IHTMLBRElement interface definition
;
Interface IHTMLBRElement Extends IDispatch
  put_clear(a.p-bstr)
  get_clear(a.l)
EndInterface

; DispHTMLBRElement interface definition
;
Interface DispHTMLBRElement Extends IDispatch
EndInterface

; IHTMLDListElement interface definition
;
Interface IHTMLDListElement Extends IDispatch
  put_compact(a.l)
  get_compact(a.l)
EndInterface

; DispHTMLDListElement interface definition
;
Interface DispHTMLDListElement Extends IDispatch
EndInterface

; IHTMLHRElement interface definition
;
Interface IHTMLHRElement Extends IDispatch
  put_align(a.p-bstr)
  get_align(a.l)
  put_color(a.p-variant)
  get_color(a.l)
  put_noShade(a.l)
  get_noShade(a.l)
  put_width(a.p-variant)
  get_width(a.l)
  put_size(a.p-variant)
  get_size(a.l)
EndInterface

; DispHTMLHRElement interface definition
;
Interface DispHTMLHRElement Extends IDispatch
EndInterface

; IHTMLParaElement interface definition
;
Interface IHTMLParaElement Extends IDispatch
  put_align(a.p-bstr)
  get_align(a.l)
EndInterface

; DispHTMLParaElement interface definition
;
Interface DispHTMLParaElement Extends IDispatch
EndInterface

; IHTMLElementCollection2 interface definition
;
Interface IHTMLElementCollection2 Extends IDispatch
  urns(a.p-variant, b.l)
EndInterface

; IHTMLElementCollection3 interface definition
;
Interface IHTMLElementCollection3 Extends IDispatch
  namedItem(a.p-bstr, b.l)
EndInterface

; DispHTMLElementCollection interface definition
;
Interface DispHTMLElementCollection Extends IDispatch
EndInterface

; IHTMLHeaderElement interface definition
;
Interface IHTMLHeaderElement Extends IDispatch
  put_align(a.p-bstr)
  get_align(a.l)
EndInterface

; DispHTMLHeaderElement interface definition
;
Interface DispHTMLHeaderElement Extends IDispatch
EndInterface

; HTMLSelectElementEvents2 interface definition
;
Interface HTMLSelectElementEvents2 Extends IDispatch
EndInterface

; HTMLSelectElementEvents interface definition
;
Interface HTMLSelectElementEvents Extends IDispatch
EndInterface

; IHTMLSelectElement interface definition
;
Interface IHTMLSelectElement Extends IDispatch
  put_size(a.l)
  get_size(a.l)
  put_multiple(a.l)
  get_multiple(a.l)
  put_name(a.p-bstr)
  get_name(a.l)
  get_options(a.l)
  put_onchange(a.p-variant)
  get_onchange(a.l)
  put_selectedIndex(a.l)
  get_selectedIndex(a.l)
  get_type(a.l)
  put_value(a.p-bstr)
  get_value(a.l)
  put_disabled(a.l)
  get_disabled(a.l)
  get_form(a.l)
  add(a.l, b.p-variant)
  remove(a.l)
  put_length(a.l)
  get_length(a.l)
  get__newEnum(a.l)
  item(a.p-variant, b.p-variant, c.l)
  tags(a.p-variant, b.l)
EndInterface

; IHTMLSelectElement2 interface definition
;
Interface IHTMLSelectElement2 Extends IDispatch
  urns(a.p-variant, b.l)
EndInterface

; IHTMLSelectElement4 interface definition
;
Interface IHTMLSelectElement4 Extends IDispatch
  namedItem(a.p-bstr, b.l)
EndInterface

; DispHTMLSelectElement interface definition
;
Interface DispHTMLSelectElement Extends IDispatch
EndInterface

; IHTMLSelectionObject interface definition
;
Interface IHTMLSelectionObject Extends IDispatch
  createRange(a.l)
  empty()
  clear()
  get_type(a.l)
EndInterface

; IHTMLSelectionObject2 interface definition
;
Interface IHTMLSelectionObject2 Extends IDispatch
  createRangeCollection(a.l)
  get_typeDetail(a.l)
EndInterface

; IHTMLOptionElement interface definition
;
Interface IHTMLOptionElement Extends IDispatch
  put_selected(a.l)
  get_selected(a.l)
  put_value(a.p-bstr)
  get_value(a.l)
  put_defaultSelected(a.l)
  get_defaultSelected(a.l)
  put_index(a.l)
  get_index(a.l)
  put_text(a.p-bstr)
  get_text(a.l)
  get_form(a.l)
EndInterface

; IHTMLOptionElement3 interface definition
;
Interface IHTMLOptionElement3 Extends IDispatch
  put_label(a.p-bstr)
  get_label(a.l)
EndInterface

; IHTMLOptionElementFactory interface definition
;
Interface IHTMLOptionElementFactory Extends IDispatch
  create(a.p-variant, b.p-variant, c.p-variant, d.p-variant, e.l)
EndInterface

; DispHTMLOptionElement interface definition
;
Interface DispHTMLOptionElement Extends IDispatch
EndInterface

; HTMLButtonElementEvents2 interface definition
;
Interface HTMLButtonElementEvents2 Extends IDispatch
EndInterface

; HTMLButtonElementEvents interface definition
;
Interface HTMLButtonElementEvents Extends IDispatch
EndInterface

; HTMLInputTextElementEvents2 interface definition
;
Interface HTMLInputTextElementEvents2 Extends IDispatch
EndInterface

; HTMLOptionButtonElementEvents2 interface definition
;
Interface HTMLOptionButtonElementEvents2 Extends IDispatch
EndInterface

; HTMLInputFileElementEvents2 interface definition
;
Interface HTMLInputFileElementEvents2 Extends IDispatch
EndInterface

; HTMLInputImageEvents2 interface definition
;
Interface HTMLInputImageEvents2 Extends IDispatch
EndInterface

; HTMLInputTextElementEvents interface definition
;
Interface HTMLInputTextElementEvents Extends IDispatch
EndInterface

; HTMLOptionButtonElementEvents interface definition
;
Interface HTMLOptionButtonElementEvents Extends IDispatch
EndInterface

; HTMLInputFileElementEvents interface definition
;
Interface HTMLInputFileElementEvents Extends IDispatch
EndInterface

; HTMLInputImageEvents interface definition
;
Interface HTMLInputImageEvents Extends IDispatch
EndInterface

; IHTMLInputElement interface definition
;
Interface IHTMLInputElement Extends IDispatch
  put_type(a.p-bstr)
  get_type(a.l)
  put_value(a.p-bstr)
  get_value(a.l)
  put_name(a.p-bstr)
  get_name(a.l)
  put_status(a.l)
  get_status(a.l)
  put_disabled(a.l)
  get_disabled(a.l)
  get_form(a.l)
  put_size(a.l)
  get_size(a.l)
  put_maxLength(a.l)
  get_maxLength(a.l)
  select()
  put_onchange(a.p-variant)
  get_onchange(a.l)
  put_onselect(a.p-variant)
  get_onselect(a.l)
  put_defaultValue(a.p-bstr)
  get_defaultValue(a.l)
  put_readOnly(a.l)
  get_readOnly(a.l)
  createTextRange(a.l)
  put_indeterminate(a.l)
  get_indeterminate(a.l)
  put_defaultChecked(a.l)
  get_defaultChecked(a.l)
  put_checked(a.l)
  get_checked(a.l)
  put_border(a.p-variant)
  get_border(a.l)
  put_vspace(a.l)
  get_vspace(a.l)
  put_hspace(a.l)
  get_hspace(a.l)
  put_alt(a.p-bstr)
  get_alt(a.l)
  put_src(a.p-bstr)
  get_src(a.l)
  put_lowsrc(a.p-bstr)
  get_lowsrc(a.l)
  put_vrml(a.p-bstr)
  get_vrml(a.l)
  put_dynsrc(a.p-bstr)
  get_dynsrc(a.l)
  get_readyState(a.l)
  get_complete(a.l)
  put_loop(a.p-variant)
  get_loop(a.l)
  put_align(a.p-bstr)
  get_align(a.l)
  put_onload(a.p-variant)
  get_onload(a.l)
  put_onerror(a.p-variant)
  get_onerror(a.l)
  put_onabort(a.p-variant)
  get_onabort(a.l)
  put_width(a.l)
  get_width(a.l)
  put_height(a.l)
  get_height(a.l)
  put_start(a.p-bstr)
  get_start(a.l)
EndInterface

; IHTMLInputElement2 interface definition
;
Interface IHTMLInputElement2 Extends IDispatch
  put_accept(a.p-bstr)
  get_accept(a.l)
  put_useMap(a.p-bstr)
  get_useMap(a.l)
EndInterface

; IHTMLInputButtonElement interface definition
;
Interface IHTMLInputButtonElement Extends IDispatch
  get_type(a.l)
  put_value(a.p-bstr)
  get_value(a.l)
  put_name(a.p-bstr)
  get_name(a.l)
  put_status(a.p-variant)
  get_status(a.l)
  put_disabled(a.l)
  get_disabled(a.l)
  get_form(a.l)
  createTextRange(a.l)
EndInterface

; IHTMLInputHiddenElement interface definition
;
Interface IHTMLInputHiddenElement Extends IDispatch
  get_type(a.l)
  put_value(a.p-bstr)
  get_value(a.l)
  put_name(a.p-bstr)
  get_name(a.l)
  put_status(a.p-variant)
  get_status(a.l)
  put_disabled(a.l)
  get_disabled(a.l)
  get_form(a.l)
  createTextRange(a.l)
EndInterface

; IHTMLInputTextElement interface definition
;
Interface IHTMLInputTextElement Extends IDispatch
  get_type(a.l)
  put_value(a.p-bstr)
  get_value(a.l)
  put_name(a.p-bstr)
  get_name(a.l)
  put_status(a.p-variant)
  get_status(a.l)
  put_disabled(a.l)
  get_disabled(a.l)
  get_form(a.l)
  put_defaultValue(a.p-bstr)
  get_defaultValue(a.l)
  put_size(a.l)
  get_size(a.l)
  put_maxLength(a.l)
  get_maxLength(a.l)
  select()
  put_onchange(a.p-variant)
  get_onchange(a.l)
  put_onselect(a.p-variant)
  get_onselect(a.l)
  put_readOnly(a.l)
  get_readOnly(a.l)
  createTextRange(a.l)
EndInterface

; IHTMLInputFileElement interface definition
;
Interface IHTMLInputFileElement Extends IDispatch
  get_type(a.l)
  put_name(a.p-bstr)
  get_name(a.l)
  put_status(a.p-variant)
  get_status(a.l)
  put_disabled(a.l)
  get_disabled(a.l)
  get_form(a.l)
  put_size(a.l)
  get_size(a.l)
  put_maxLength(a.l)
  get_maxLength(a.l)
  select()
  put_onchange(a.p-variant)
  get_onchange(a.l)
  put_onselect(a.p-variant)
  get_onselect(a.l)
  put_value(a.p-bstr)
  get_value(a.l)
EndInterface

; IHTMLOptionButtonElement interface definition
;
Interface IHTMLOptionButtonElement Extends IDispatch
  put_value(a.p-bstr)
  get_value(a.l)
  get_type(a.l)
  put_name(a.p-bstr)
  get_name(a.l)
  put_checked(a.l)
  get_checked(a.l)
  put_defaultChecked(a.l)
  get_defaultChecked(a.l)
  put_onchange(a.p-variant)
  get_onchange(a.l)
  put_disabled(a.l)
  get_disabled(a.l)
  put_status(a.l)
  get_status(a.l)
  put_indeterminate(a.l)
  get_indeterminate(a.l)
  get_form(a.l)
EndInterface

; IHTMLInputImage interface definition
;
Interface IHTMLInputImage Extends IDispatch
  get_type(a.l)
  put_disabled(a.l)
  get_disabled(a.l)
  put_border(a.p-variant)
  get_border(a.l)
  put_vspace(a.l)
  get_vspace(a.l)
  put_hspace(a.l)
  get_hspace(a.l)
  put_alt(a.p-bstr)
  get_alt(a.l)
  put_src(a.p-bstr)
  get_src(a.l)
  put_lowsrc(a.p-bstr)
  get_lowsrc(a.l)
  put_vrml(a.p-bstr)
  get_vrml(a.l)
  put_dynsrc(a.p-bstr)
  get_dynsrc(a.l)
  get_readyState(a.l)
  get_complete(a.l)
  put_loop(a.p-variant)
  get_loop(a.l)
  put_align(a.p-bstr)
  get_align(a.l)
  put_onload(a.p-variant)
  get_onload(a.l)
  put_onerror(a.p-variant)
  get_onerror(a.l)
  put_onabort(a.p-variant)
  get_onabort(a.l)
  put_name(a.p-bstr)
  get_name(a.l)
  put_width(a.l)
  get_width(a.l)
  put_height(a.l)
  get_height(a.l)
  put_start(a.p-bstr)
  get_start(a.l)
EndInterface

; DispHTMLInputElement interface definition
;
Interface DispHTMLInputElement Extends IDispatch
EndInterface

; IHTMLTextAreaElement interface definition
;
Interface IHTMLTextAreaElement Extends IDispatch
  get_type(a.l)
  put_value(a.p-bstr)
  get_value(a.l)
  put_name(a.p-bstr)
  get_name(a.l)
  put_status(a.p-variant)
  get_status(a.l)
  put_disabled(a.l)
  get_disabled(a.l)
  get_form(a.l)
  put_defaultValue(a.p-bstr)
  get_defaultValue(a.l)
  select()
  put_onchange(a.p-variant)
  get_onchange(a.l)
  put_onselect(a.p-variant)
  get_onselect(a.l)
  put_readOnly(a.l)
  get_readOnly(a.l)
  put_rows(a.l)
  get_rows(a.l)
  put_cols(a.l)
  get_cols(a.l)
  put_wrap(a.p-bstr)
  get_wrap(a.l)
  createTextRange(a.l)
EndInterface

; DispHTMLTextAreaElement interface definition
;
Interface DispHTMLTextAreaElement Extends IDispatch
EndInterface

; DispHTMLRichtextElement interface definition
;
Interface DispHTMLRichtextElement Extends IDispatch
EndInterface

; IHTMLButtonElement interface definition
;
Interface IHTMLButtonElement Extends IDispatch
  get_type(a.l)
  put_value(a.p-bstr)
  get_value(a.l)
  put_name(a.p-bstr)
  get_name(a.l)
  put_status(a.p-variant)
  get_status(a.l)
  put_disabled(a.l)
  get_disabled(a.l)
  get_form(a.l)
  createTextRange(a.l)
EndInterface

; DispHTMLButtonElement interface definition
;
Interface DispHTMLButtonElement Extends IDispatch
EndInterface

; HTMLMarqueeElementEvents2 interface definition
;
Interface HTMLMarqueeElementEvents2 Extends IDispatch
EndInterface

; HTMLMarqueeElementEvents interface definition
;
Interface HTMLMarqueeElementEvents Extends IDispatch
EndInterface

; IHTMLMarqueeElement interface definition
;
Interface IHTMLMarqueeElement Extends IDispatch
  put_bgColor(a.p-variant)
  get_bgColor(a.l)
  put_scrollDelay(a.l)
  get_scrollDelay(a.l)
  put_direction(a.p-bstr)
  get_direction(a.l)
  put_behavior(a.p-bstr)
  get_behavior(a.l)
  put_scrollAmount(a.l)
  get_scrollAmount(a.l)
  put_loop(a.l)
  get_loop(a.l)
  put_vspace(a.l)
  get_vspace(a.l)
  put_hspace(a.l)
  get_hspace(a.l)
  put_onfinish(a.p-variant)
  get_onfinish(a.l)
  put_onstart(a.p-variant)
  get_onstart(a.l)
  put_onbounce(a.p-variant)
  get_onbounce(a.l)
  put_width(a.p-variant)
  get_width(a.l)
  put_height(a.p-variant)
  get_height(a.l)
  put_trueSpeed(a.l)
  get_trueSpeed(a.l)
  start()
  stop()
EndInterface

; DispHTMLMarqueeElement interface definition
;
Interface DispHTMLMarqueeElement Extends IDispatch
EndInterface

; IHTMLHtmlElement interface definition
;
Interface IHTMLHtmlElement Extends IDispatch
  put_version(a.p-bstr)
  get_version(a.l)
EndInterface

; IHTMLHeadElement interface definition
;
Interface IHTMLHeadElement Extends IDispatch
  put_profile(a.p-bstr)
  get_profile(a.l)
EndInterface

; IHTMLTitleElement interface definition
;
Interface IHTMLTitleElement Extends IDispatch
  put_text(a.p-bstr)
  get_text(a.l)
EndInterface

; IHTMLMetaElement interface definition
;
Interface IHTMLMetaElement Extends IDispatch
  put_httpEquiv(a.p-bstr)
  get_httpEquiv(a.l)
  put_content(a.p-bstr)
  get_content(a.l)
  put_name(a.p-bstr)
  get_name(a.l)
  put_url(a.p-bstr)
  get_url(a.l)
  put_charset(a.p-bstr)
  get_charset(a.l)
EndInterface

; IHTMLMetaElement2 interface definition
;
Interface IHTMLMetaElement2 Extends IDispatch
  put_scheme(a.p-bstr)
  get_scheme(a.l)
EndInterface

; IHTMLBaseElement interface definition
;
Interface IHTMLBaseElement Extends IDispatch
  put_href(a.p-bstr)
  get_href(a.l)
  put_target(a.p-bstr)
  get_target(a.l)
EndInterface

; IHTMLIsIndexElement interface definition
;
Interface IHTMLIsIndexElement Extends IDispatch
  put_prompt(a.p-bstr)
  get_prompt(a.l)
  put_action(a.p-bstr)
  get_action(a.l)
EndInterface

; IHTMLIsIndexElement2 interface definition
;
Interface IHTMLIsIndexElement2 Extends IDispatch
  get_form(a.l)
EndInterface

; IHTMLNextIdElement interface definition
;
Interface IHTMLNextIdElement Extends IDispatch
  put_n(a.p-bstr)
  get_n(a.l)
EndInterface

; DispHTMLHtmlElement interface definition
;
Interface DispHTMLHtmlElement Extends IDispatch
EndInterface

; DispHTMLHeadElement interface definition
;
Interface DispHTMLHeadElement Extends IDispatch
EndInterface

; DispHTMLTitleElement interface definition
;
Interface DispHTMLTitleElement Extends IDispatch
EndInterface

; DispHTMLMetaElement interface definition
;
Interface DispHTMLMetaElement Extends IDispatch
EndInterface

; DispHTMLBaseElement interface definition
;
Interface DispHTMLBaseElement Extends IDispatch
EndInterface

; DispHTMLIsIndexElement interface definition
;
Interface DispHTMLIsIndexElement Extends IDispatch
EndInterface

; DispHTMLNextIdElement interface definition
;
Interface DispHTMLNextIdElement Extends IDispatch
EndInterface

; IHTMLBaseFontElement interface definition
;
Interface IHTMLBaseFontElement Extends IDispatch
  put_color(a.p-variant)
  get_color(a.l)
  put_face(a.p-bstr)
  get_face(a.l)
  put_size(a.l)
  get_size(a.l)
EndInterface

; DispHTMLBaseFontElement interface definition
;
Interface DispHTMLBaseFontElement Extends IDispatch
EndInterface

; IHTMLUnknownElement interface definition
;
Interface IHTMLUnknownElement Extends IDispatch
EndInterface

; DispHTMLUnknownElement interface definition
;
Interface DispHTMLUnknownElement Extends IDispatch
EndInterface

; IOmHistory interface definition
;
Interface IOmHistory Extends IDispatch
  get_length(a.l)
  back(a.l)
  forward(a.l)
  go(a.l)
EndInterface

; IHTMLMimeTypesCollection interface definition
;
Interface IHTMLMimeTypesCollection Extends IDispatch
  get_length(a.l)
EndInterface

; IHTMLPluginsCollection interface definition
;
Interface IHTMLPluginsCollection Extends IDispatch
  get_length(a.l)
  refresh(a.l)
EndInterface

; IHTMLOpsProfile interface definition
;
Interface IHTMLOpsProfile Extends IDispatch
  addRequest(a.p-bstr, b.p-variant, c.l)
  clearRequest()
  doRequest(a.p-variant, b.p-variant, c.p-variant, d.p-variant, e.p-variant, f.p-variant)
  getAttribute(a.p-bstr, b.l)
  setAttribute(a.p-bstr, b.p-bstr, c.p-variant, d.l)
  commitChanges(a.l)
  addReadRequest(a.p-bstr, b.p-variant, c.l)
  doReadRequest(a.p-variant, b.p-variant, c.p-variant, d.p-variant, e.p-variant, f.p-variant)
  doWriteRequest(a.l)
EndInterface

; IOmNavigator interface definition
;
Interface IOmNavigator Extends IDispatch
  get_appCodeName(a.l)
  get_appName(a.l)
  get_appVersion(a.l)
  get_userAgent(a.l)
  javaEnabled(a.l)
  taintEnabled(a.l)
  get_mimeTypes(a.l)
  get_plugins(a.l)
  get_cookieEnabled(a.l)
  get_opsProfile(a.l)
  toString(a.l)
  get_cpuClass(a.l)
  get_systemLanguage(a.l)
  get_browserLanguage(a.l)
  get_userLanguage(a.l)
  get_platform(a.l)
  get_appMinorVersion(a.l)
  get_connectionSpeed(a.l)
  get_onLine(a.l)
  get_userProfile(a.l)
EndInterface

; IHTMLLocation interface definition
;
Interface IHTMLLocation Extends IDispatch
  put_href(a.p-bstr)
  get_href(a.l)
  put_protocol(a.p-bstr)
  get_protocol(a.l)
  put_host(a.p-bstr)
  get_host(a.l)
  put_hostname(a.p-bstr)
  get_hostname(a.l)
  put_port(a.p-bstr)
  get_port(a.l)
  put_pathname(a.p-bstr)
  get_pathname(a.l)
  put_search(a.p-bstr)
  get_search(a.l)
  put_hash(a.p-bstr)
  get_hash(a.l)
  reload(a.l)
  replace(a.p-bstr)
  assign(a.p-bstr)
  toString(a.l)
EndInterface

; IHTMLBookmarkCollection interface definition
;
Interface IHTMLBookmarkCollection Extends IDispatch
  get_length(a.l)
  get__newEnum(a.l)
  item(a.l, b.l)
EndInterface

; IHTMLDataTransfer interface definition
;
Interface IHTMLDataTransfer Extends IDispatch
  setData(a.p-bstr, b.l, c.l)
  getData(a.p-bstr, b.l)
  clearData(a.p-bstr, b.l)
  put_dropEffect(a.p-bstr)
  get_dropEffect(a.l)
  put_effectAllowed(a.p-bstr)
  get_effectAllowed(a.l)
EndInterface

; IHTMLEventObj2 interface definition
;
Interface IHTMLEventObj2 Extends IDispatch
  setAttribute(a.p-bstr, b.p-variant, c.l)
  getAttribute(a.p-bstr, b.l, c.l)
  removeAttribute(a.p-bstr, b.l, c.l)
  put_propertyName(a.p-bstr)
  get_propertyName(a.l)
  putref_bookmarks(a.l)
  get_bookmarks(a.l)
  putref_recordset(a.l)
  get_recordset(a.l)
  put_dataFld(a.p-bstr)
  get_dataFld(a.l)
  putref_boundElements(a.l)
  get_boundElements(a.l)
  put_repeat(a.l)
  get_repeat(a.l)
  put_srcUrn(a.p-bstr)
  get_srcUrn(a.l)
  putref_srcElement(a.l)
  get_srcElement(a.l)
  put_altKey(a.l)
  get_altKey(a.l)
  put_ctrlKey(a.l)
  get_ctrlKey(a.l)
  put_shiftKey(a.l)
  get_shiftKey(a.l)
  putref_fromElement(a.l)
  get_fromElement(a.l)
  putref_toElement(a.l)
  get_toElement(a.l)
  put_button(a.l)
  get_button(a.l)
  put_type(a.p-bstr)
  get_type(a.l)
  put_qualifier(a.p-bstr)
  get_qualifier(a.l)
  put_reason(a.l)
  get_reason(a.l)
  put_x(a.l)
  get_x(a.l)
  put_y(a.l)
  get_y(a.l)
  put_clientX(a.l)
  get_clientX(a.l)
  put_clientY(a.l)
  get_clientY(a.l)
  put_offsetX(a.l)
  get_offsetX(a.l)
  put_offsetY(a.l)
  get_offsetY(a.l)
  put_screenX(a.l)
  get_screenX(a.l)
  put_screenY(a.l)
  get_screenY(a.l)
  putref_srcFilter(a.l)
  get_srcFilter(a.l)
  get_dataTransfer(a.l)
EndInterface

; IHTMLEventObj3 interface definition
;
Interface IHTMLEventObj3 Extends IDispatch
  get_contentOverflow(a.l)
  put_shiftLeft(a.l)
  get_shiftLeft(a.l)
  put_altLeft(a.l)
  get_altLeft(a.l)
  put_ctrlLeft(a.l)
  get_ctrlLeft(a.l)
  get_imeCompositionChange(a.l)
  get_imeNotifyCommand(a.l)
  get_imeNotifyData(a.l)
  get_imeRequest(a.l)
  get_imeRequestData(a.l)
  get_keyboardLayout(a.l)
  get_behaviorCookie(a.l)
  get_behaviorPart(a.l)
  get_nextPage(a.l)
EndInterface

; IHTMLEventObj4 interface definition
;
Interface IHTMLEventObj4 Extends IDispatch
  get_wheelDelta(a.l)
EndInterface

; DispCEventObj interface definition
;
Interface DispCEventObj Extends IDispatch
EndInterface

; HTMLWindowEvents2 interface definition
;
Interface HTMLWindowEvents2 Extends IDispatch
EndInterface

; HTMLWindowEvents interface definition
;
Interface HTMLWindowEvents Extends IDispatch
EndInterface

; IHTMLDocument2 interface definition
;
Interface IHTMLDocument2 Extends IHTMLDocument
  get_all(a.l)
  get_body(a.l)
  get_activeElement(a.l)
  get_images(a.l)
  get_applets(a.l)
  get_links(a.l)
  get_forms(a.l)
  get_anchors(a.l)
  put_title(a.p-bstr)
  get_title(a.l)
  get_scripts(a.l)
  put_designMode(a.p-bstr)
  get_designMode(a.l)
  get_selection(a.l)
  get_readyState(a.l)
  get_frames(a.l)
  get_embeds(a.l)
  get_plugins(a.l)
  put_alinkColor(a.p-variant)
  get_alinkColor(a.l)
  put_bgColor(a.p-variant)
  get_bgColor(a.l)
  put_fgColor(a.p-variant)
  get_fgColor(a.l)
  put_linkColor(a.p-variant)
  get_linkColor(a.l)
  put_vlinkColor(a.p-variant)
  get_vlinkColor(a.l)
  get_referrer(a.l)
  get_location(a.l)
  get_lastModified(a.l)
  put_URL(a.p-bstr)
  get_URL(a.l)
  put_domain(a.p-bstr)
  get_domain(a.l)
  put_cookie(a.p-bstr)
  get_cookie(a.l)
  put_expando(a.l)
  get_expando(a.l)
  put_charset(a.p-bstr)
  get_charset(a.l)
  put_defaultCharset(a.p-bstr)
  get_defaultCharset(a.l)
  get_mimeType(a.l)
  get_fileSize(a.l)
  get_fileCreatedDate(a.l)
  get_fileModifiedDate(a.l)
  get_fileUpdatedDate(a.l)
  get_security(a.l)
  get_protocol(a.l)
  get_nameProp(a.l)
  write(a.l)
  writeln(a.l)
  open(a.p-bstr, b.p-variant, c.p-variant, d.p-variant, e.l)
  close()
  clear()
  queryCommandSupported(a.p-bstr, b.l)
  queryCommandEnabled(a.p-bstr, b.l)
  queryCommandState(a.p-bstr, b.l)
  queryCommandIndeterm(a.p-bstr, b.l)
  queryCommandText(a.p-bstr, b.l)
  queryCommandValue(a.p-bstr, b.l)
  execCommand(a.p-bstr, b.l, c.p-variant, d.l)
  execCommandShowHelp(a.p-bstr, b.l)
  createElement(a.p-bstr, b.l)
  put_onhelp(a.p-variant)
  get_onhelp(a.l)
  put_onclick(a.p-variant)
  get_onclick(a.l)
  put_ondblclick(a.p-variant)
  get_ondblclick(a.l)
  put_onkeyup(a.p-variant)
  get_onkeyup(a.l)
  put_onkeydown(a.p-variant)
  get_onkeydown(a.l)
  put_onkeypress(a.p-variant)
  get_onkeypress(a.l)
  put_onmouseup(a.p-variant)
  get_onmouseup(a.l)
  put_onmousedown(a.p-variant)
  get_onmousedown(a.l)
  put_onmousemove(a.p-variant)
  get_onmousemove(a.l)
  put_onmouseout(a.p-variant)
  get_onmouseout(a.l)
  put_onmouseover(a.p-variant)
  get_onmouseover(a.l)
  put_onreadystatechange(a.p-variant)
  get_onreadystatechange(a.l)
  put_onafterupdate(a.p-variant)
  get_onafterupdate(a.l)
  put_onrowexit(a.p-variant)
  get_onrowexit(a.l)
  put_onrowenter(a.p-variant)
  get_onrowenter(a.l)
  put_ondragstart(a.p-variant)
  get_ondragstart(a.l)
  put_onselectstart(a.p-variant)
  get_onselectstart(a.l)
  elementFromPoint(a.l, b.l, c.l)
  get_parentWindow(a.l)
  get_styleSheets(a.l)
  put_onbeforeupdate(a.p-variant)
  get_onbeforeupdate(a.l)
  put_onerrorupdate(a.p-variant)
  get_onerrorupdate(a.l)
  toString(a.l)
  createStyleSheet(a.p-bstr, b.l, c.l)
EndInterface

; IHTMLFramesCollection2 interface definition
;
Interface IHTMLFramesCollection2 Extends IDispatch
  item(a.l, b.l)
  get_length(a.l)
EndInterface

; IHTMLWindow2 interface definition
;
Interface IHTMLWindow2 Extends IHTMLFramesCollection2
  get_frames(a.l)
  put_defaultStatus(a.p-bstr)
  get_defaultStatus(a.l)
  put_status(a.p-bstr)
  get_status(a.l)
  setTimeout(a.p-bstr, b.l, c.l, d.l)
  clearTimeout(a.l)
  alert(a.p-bstr)
  confirm(a.p-bstr, b.l)
  prompt(a.p-bstr, b.p-bstr, c.l)
  get_Image(a.l)
  get_location(a.l)
  get_history(a.l)
  close()
  put_opener(a.p-variant)
  get_opener(a.l)
  get_navigator(a.l)
  put_name(a.p-bstr)
  get_name(a.l)
  get_parent(a.l)
  open(a.p-bstr, b.p-bstr, c.p-bstr, d.l, e.l)
  get_self(a.l)
  get_top(a.l)
  get_window(a.l)
  navigate(a.p-bstr)
  put_onfocus(a.p-variant)
  get_onfocus(a.l)
  put_onblur(a.p-variant)
  get_onblur(a.l)
  put_onload(a.p-variant)
  get_onload(a.l)
  put_onbeforeunload(a.p-variant)
  get_onbeforeunload(a.l)
  put_onunload(a.p-variant)
  get_onunload(a.l)
  put_onhelp(a.p-variant)
  get_onhelp(a.l)
  put_onerror(a.p-variant)
  get_onerror(a.l)
  put_onresize(a.p-variant)
  get_onresize(a.l)
  put_onscroll(a.p-variant)
  get_onscroll(a.l)
  get_document(a.l)
  get_event(a.l)
  get__newEnum(a.l)
  showModalDialog(a.p-bstr, b.l, c.l, d.l)
  showHelp(a.p-bstr, b.p-variant, c.p-bstr)
  get_screen(a.l)
  get_Option(a.l)
  focus()
  get_closed(a.l)
  blur()
  scroll(a.l, b.l)
  get_clientInformation(a.l)
  setInterval(a.p-bstr, b.l, c.l, d.l)
  clearInterval(a.l)
  put_offscreenBuffering(a.p-variant)
  get_offscreenBuffering(a.l)
  execScript(a.p-bstr, b.p-bstr, c.l)
  toString(a.l)
  scrollBy(a.l, b.l)
  scrollTo(a.l, b.l)
  moveTo(a.l, b.l)
  moveBy(a.l, b.l)
  resizeTo(a.l, b.l)
  resizeBy(a.l, b.l)
  get_external(a.l)
EndInterface

; IHTMLWindow3 interface definition
;
Interface IHTMLWindow3 Extends IDispatch
  get_screenLeft(a.l)
  get_screenTop(a.l)
  attachEvent(a.p-bstr, b.l, c.l)
  detachEvent(a.p-bstr, b.l)
  setTimeout(a.l, b.l, c.l, d.l)
  setInterval(a.l, b.l, c.l, d.l)
  print()
  put_onbeforeprint(a.p-variant)
  get_onbeforeprint(a.l)
  put_onafterprint(a.p-variant)
  get_onafterprint(a.l)
  get_clipboardData(a.l)
  showModelessDialog(a.p-bstr, b.l, c.l, d.l)
EndInterface

; IHTMLFrameBase interface definition
;
Interface IHTMLFrameBase Extends IDispatch
  put_src(a.p-bstr)
  get_src(a.l)
  put_name(a.p-bstr)
  get_name(a.l)
  put_border(a.p-variant)
  get_border(a.l)
  put_frameBorder(a.p-bstr)
  get_frameBorder(a.l)
  put_frameSpacing(a.p-variant)
  get_frameSpacing(a.l)
  put_marginWidth(a.p-variant)
  get_marginWidth(a.l)
  put_marginHeight(a.p-variant)
  get_marginHeight(a.l)
  put_noResize(a.l)
  get_noResize(a.l)
  put_scrolling(a.p-bstr)
  get_scrolling(a.l)
EndInterface

; IHTMLScreen interface definition
;
Interface IHTMLScreen Extends IDispatch
  get_colorDepth(a.l)
  put_bufferDepth(a.l)
  get_bufferDepth(a.l)
  get_width(a.l)
  get_height(a.l)
  put_updateInterval(a.l)
  get_updateInterval(a.l)
  get_availHeight(a.l)
  get_availWidth(a.l)
  get_fontSmoothingEnabled(a.l)
EndInterface

; IHTMLScreen2 interface definition
;
Interface IHTMLScreen2 Extends IDispatch
  get_logicalXDPI(a.l)
  get_logicalYDPI(a.l)
  get_deviceXDPI(a.l)
  get_deviceYDPI(a.l)
EndInterface

; IHTMLWindow4 interface definition
;
Interface IHTMLWindow4 Extends IDispatch
  createPopup(a.l, b.l)
  get_frameElement(a.l)
EndInterface

; DispHTMLScreen interface definition
;
Interface DispHTMLScreen Extends IDispatch
EndInterface

; DispHTMLWindow2 interface definition
;
Interface DispHTMLWindow2 Extends IDispatch
EndInterface

; DispHTMLWindowProxy interface definition
;
Interface DispHTMLWindowProxy Extends IDispatch
EndInterface

; HTMLDocumentEvents2 interface definition
;
Interface HTMLDocumentEvents2 Extends IDispatch
EndInterface

; HTMLDocumentEvents interface definition
;
Interface HTMLDocumentEvents Extends IDispatch
EndInterface

; IHTMLDocument3 interface definition
;
Interface IHTMLDocument3 Extends IDispatch
  releaseCapture()
  recalc(a.l)
  createTextNode(a.p-bstr, b.l)
  get_documentElement(a.l)
  get_uniqueID(a.l)
  attachEvent(a.p-bstr, b.l, c.l)
  detachEvent(a.p-bstr, b.l)
  put_onrowsdelete(a.p-variant)
  get_onrowsdelete(a.l)
  put_onrowsinserted(a.p-variant)
  get_onrowsinserted(a.l)
  put_oncellchange(a.p-variant)
  get_oncellchange(a.l)
  put_ondatasetchanged(a.p-variant)
  get_ondatasetchanged(a.l)
  put_ondataavailable(a.p-variant)
  get_ondataavailable(a.l)
  put_ondatasetcomplete(a.p-variant)
  get_ondatasetcomplete(a.l)
  put_onpropertychange(a.p-variant)
  get_onpropertychange(a.l)
  put_dir(a.p-bstr)
  get_dir(a.l)
  put_oncontextmenu(a.p-variant)
  get_oncontextmenu(a.l)
  put_onstop(a.p-variant)
  get_onstop(a.l)
  createDocumentFragment(a.l)
  get_parentDocument(a.l)
  put_enableDownload(a.l)
  get_enableDownload(a.l)
  put_baseUrl(a.p-bstr)
  get_baseUrl(a.l)
  get_childNodes(a.l)
  put_inheritStyleSheets(a.l)
  get_inheritStyleSheets(a.l)
  put_onbeforeeditfocus(a.p-variant)
  get_onbeforeeditfocus(a.l)
  getElementsByName(a.p-bstr, b.l)
  getElementById(a.p-bstr, b.l)
  getElementsByTagName(a.p-bstr, b.l)
EndInterface

; IHTMLDocument4 interface definition
;
Interface IHTMLDocument4 Extends IDispatch
  focus()
  hasFocus(a.l)
  put_onselectionchange(a.p-variant)
  get_onselectionchange(a.l)
  get_namespaces(a.l)
  createDocumentFromUrl(a.p-bstr, b.p-bstr, c.l)
  put_media(a.p-bstr)
  get_media(a.l)
  createEventObject(a.l, b.l)
  fireEvent(a.p-bstr, b.l, c.l)
  createRenderStyle(a.p-bstr, b.l)
  put_oncontrolselect(a.p-variant)
  get_oncontrolselect(a.l)
  get_URLUnencoded(a.l)
EndInterface

; IHTMLDocument5 interface definition
;
Interface IHTMLDocument5 Extends IDispatch
  put_onmousewheel(a.p-variant)
  get_onmousewheel(a.l)
  get_doctype(a.l)
  get_implementation(a.l)
  createAttribute(a.p-bstr, b.l)
  createComment(a.p-bstr, b.l)
  put_onfocusin(a.p-variant)
  get_onfocusin(a.l)
  put_onfocusout(a.p-variant)
  get_onfocusout(a.l)
  put_onactivate(a.p-variant)
  get_onactivate(a.l)
  put_ondeactivate(a.p-variant)
  get_ondeactivate(a.l)
  put_onbeforeactivate(a.p-variant)
  get_onbeforeactivate(a.l)
  put_onbeforedeactivate(a.p-variant)
  get_onbeforedeactivate(a.l)
  get_compatMode(a.l)
EndInterface

; DispHTMLDocument interface definition
;
Interface DispHTMLDocument Extends IDispatch
EndInterface

; DWebBridgeEvents interface definition
;
Interface DWebBridgeEvents Extends IDispatch
EndInterface

; IWebBridge interface definition
;
Interface IWebBridge Extends IDispatch
  put_URL(a.p-bstr)
  get_URL(a.l)
  put_Scrollbar(a.l)
  get_Scrollbar(a.l)
  put_embed(a.l)
  get_embed(a.l)
  get_event(a.l)
  get_readyState(a.l)
  AboutBox()
EndInterface

; IWBScriptControl interface definition
;
Interface IWBScriptControl Extends IDispatch
  raiseEvent(a.p-bstr, b.p-variant)
  bubbleEvent()
  setContextMenu(a.p-variant)
  put_selectableContent(a.l)
  get_selectableContent(a.l)
  get_frozen(a.l)
  put_scrollbar(a.l)
  get_scrollbar(a.l)
  get_version(a.l)
  get_visibility(a.l)
  put_onvisibilitychange(a.p-variant)
  get_onvisibilitychange(a.l)
EndInterface

; IHTMLEmbedElement interface definition
;
Interface IHTMLEmbedElement Extends IDispatch
  put_hidden(a.p-bstr)
  get_hidden(a.l)
  get_palette(a.l)
  get_pluginspage(a.l)
  put_src(a.p-bstr)
  get_src(a.l)
  put_units(a.p-bstr)
  get_units(a.l)
  put_name(a.p-bstr)
  get_name(a.l)
  put_width(a.p-variant)
  get_width(a.l)
  put_height(a.p-variant)
  get_height(a.l)
EndInterface

; DispHTMLEmbed interface definition
;
Interface DispHTMLEmbed Extends IDispatch
EndInterface

; HTMLMapEvents2 interface definition
;
Interface HTMLMapEvents2 Extends IDispatch
EndInterface

; HTMLMapEvents interface definition
;
Interface HTMLMapEvents Extends IDispatch
EndInterface

; IHTMLAreasCollection interface definition
;
Interface IHTMLAreasCollection Extends IDispatch
  put_length(a.l)
  get_length(a.l)
  get__newEnum(a.l)
  item(a.p-variant, b.p-variant, c.l)
  tags(a.p-variant, b.l)
  add(a.l, b.p-variant)
  remove(a.l)
EndInterface

; IHTMLAreasCollection2 interface definition
;
Interface IHTMLAreasCollection2 Extends IDispatch
  urns(a.p-variant, b.l)
EndInterface

; IHTMLAreasCollection3 interface definition
;
Interface IHTMLAreasCollection3 Extends IDispatch
  namedItem(a.p-bstr, b.l)
EndInterface

; IHTMLMapElement interface definition
;
Interface IHTMLMapElement Extends IDispatch
  get_areas(a.l)
  put_name(a.p-bstr)
  get_name(a.l)
EndInterface

; DispHTMLAreasCollection interface definition
;
Interface DispHTMLAreasCollection Extends IDispatch
EndInterface

; DispHTMLMapElement interface definition
;
Interface DispHTMLMapElement Extends IDispatch
EndInterface

; HTMLAreaEvents2 interface definition
;
Interface HTMLAreaEvents2 Extends IDispatch
EndInterface

; HTMLAreaEvents interface definition
;
Interface HTMLAreaEvents Extends IDispatch
EndInterface

; IHTMLAreaElement interface definition
;
Interface IHTMLAreaElement Extends IDispatch
  put_shape(a.p-bstr)
  get_shape(a.l)
  put_coords(a.p-bstr)
  get_coords(a.l)
  put_href(a.p-bstr)
  get_href(a.l)
  put_target(a.p-bstr)
  get_target(a.l)
  put_alt(a.p-bstr)
  get_alt(a.l)
  put_noHref(a.l)
  get_noHref(a.l)
  put_host(a.p-bstr)
  get_host(a.l)
  put_hostname(a.p-bstr)
  get_hostname(a.l)
  put_pathname(a.p-bstr)
  get_pathname(a.l)
  put_port(a.p-bstr)
  get_port(a.l)
  put_protocol(a.p-bstr)
  get_protocol(a.l)
  put_search(a.p-bstr)
  get_search(a.l)
  put_hash(a.p-bstr)
  get_hash(a.l)
  put_onblur(a.p-variant)
  get_onblur(a.l)
  put_onfocus(a.p-variant)
  get_onfocus(a.l)
  put_tabIndex(a.l)
  get_tabIndex(a.l)
  focus()
  blur()
EndInterface

; DispHTMLAreaElement interface definition
;
Interface DispHTMLAreaElement Extends IDispatch
EndInterface

; IHTMLTableCaption interface definition
;
Interface IHTMLTableCaption Extends IDispatch
  put_align(a.p-bstr)
  get_align(a.l)
  put_vAlign(a.p-bstr)
  get_vAlign(a.l)
EndInterface

; DispHTMLTableCaption interface definition
;
Interface DispHTMLTableCaption Extends IDispatch
EndInterface

; IHTMLCommentElement interface definition
;
Interface IHTMLCommentElement Extends IDispatch
  put_text(a.p-bstr)
  get_text(a.l)
  put_atomic(a.l)
  get_atomic(a.l)
EndInterface

; IHTMLCommentElement2 interface definition
;
Interface IHTMLCommentElement2 Extends IDispatch
  put_data(a.p-bstr)
  get_data(a.l)
  get_length(a.l)
  substringData(a.l, b.l, c.l)
  appendData(a.p-bstr)
  insertData(a.l, b.p-bstr)
  deleteData(a.l, b.l)
  replaceData(a.l, b.l, c.p-bstr)
EndInterface

; DispHTMLCommentElement interface definition
;
Interface DispHTMLCommentElement Extends IDispatch
EndInterface

; IHTMLPhraseElement interface definition
;
Interface IHTMLPhraseElement Extends IDispatch
EndInterface

; IHTMLPhraseElement2 interface definition
;
Interface IHTMLPhraseElement2 Extends IDispatch
  put_cite(a.p-bstr)
  get_cite(a.l)
  put_dateTime(a.p-bstr)
  get_dateTime(a.l)
EndInterface

; IHTMLSpanElement interface definition
;
Interface IHTMLSpanElement Extends IDispatch
EndInterface

; DispHTMLPhraseElement interface definition
;
Interface DispHTMLPhraseElement Extends IDispatch
EndInterface

; DispHTMLSpanElement interface definition
;
Interface DispHTMLSpanElement Extends IDispatch
EndInterface

; HTMLTableEvents2 interface definition
;
Interface HTMLTableEvents2 Extends IDispatch
EndInterface

; HTMLTableEvents interface definition
;
Interface HTMLTableEvents Extends IDispatch
EndInterface

; IHTMLTableSection interface definition
;
Interface IHTMLTableSection Extends IDispatch
  put_align(a.p-bstr)
  get_align(a.l)
  put_vAlign(a.p-bstr)
  get_vAlign(a.l)
  put_bgColor(a.p-variant)
  get_bgColor(a.l)
  get_rows(a.l)
  insertRow(a.l, b.l)
  deleteRow(a.l)
EndInterface

; IHTMLTable interface definition
;
Interface IHTMLTable Extends IDispatch
  put_cols(a.l)
  get_cols(a.l)
  put_border(a.p-variant)
  get_border(a.l)
  put_frame(a.p-bstr)
  get_frame(a.l)
  put_rules(a.p-bstr)
  get_rules(a.l)
  put_cellSpacing(a.p-variant)
  get_cellSpacing(a.l)
  put_cellPadding(a.p-variant)
  get_cellPadding(a.l)
  put_background(a.p-bstr)
  get_background(a.l)
  put_bgColor(a.p-variant)
  get_bgColor(a.l)
  put_borderColor(a.p-variant)
  get_borderColor(a.l)
  put_borderColorLight(a.p-variant)
  get_borderColorLight(a.l)
  put_borderColorDark(a.p-variant)
  get_borderColorDark(a.l)
  put_align(a.p-bstr)
  get_align(a.l)
  refresh()
  get_rows(a.l)
  put_width(a.p-variant)
  get_width(a.l)
  put_height(a.p-variant)
  get_height(a.l)
  put_dataPageSize(a.l)
  get_dataPageSize(a.l)
  nextPage()
  previousPage()
  get_tHead(a.l)
  get_tFoot(a.l)
  get_tBodies(a.l)
  get_caption(a.l)
  createTHead(a.l)
  deleteTHead()
  createTFoot(a.l)
  deleteTFoot()
  createCaption(a.l)
  deleteCaption()
  insertRow(a.l, b.l)
  deleteRow(a.l)
  get_readyState(a.l)
  put_onreadystatechange(a.p-variant)
  get_onreadystatechange(a.l)
EndInterface

; IHTMLTable2 interface definition
;
Interface IHTMLTable2 Extends IDispatch
  firstPage()
  lastPage()
  get_cells(a.l)
  moveRow(a.l, b.l, c.l)
EndInterface

; IHTMLTable3 interface definition
;
Interface IHTMLTable3 Extends IDispatch
  put_summary(a.p-bstr)
  get_summary(a.l)
EndInterface

; IHTMLTableCol interface definition
;
Interface IHTMLTableCol Extends IDispatch
  put_span(a.l)
  get_span(a.l)
  put_width(a.p-variant)
  get_width(a.l)
  put_align(a.p-bstr)
  get_align(a.l)
  put_vAlign(a.p-bstr)
  get_vAlign(a.l)
EndInterface

; IHTMLTableCol2 interface definition
;
Interface IHTMLTableCol2 Extends IDispatch
  put_ch(a.p-bstr)
  get_ch(a.l)
  put_chOff(a.p-bstr)
  get_chOff(a.l)
EndInterface

; IHTMLTableSection2 interface definition
;
Interface IHTMLTableSection2 Extends IDispatch
  moveRow(a.l, b.l, c.l)
EndInterface

; IHTMLTableSection3 interface definition
;
Interface IHTMLTableSection3 Extends IDispatch
  put_ch(a.p-bstr)
  get_ch(a.l)
  put_chOff(a.p-bstr)
  get_chOff(a.l)
EndInterface

; IHTMLTableRow interface definition
;
Interface IHTMLTableRow Extends IDispatch
  put_align(a.p-bstr)
  get_align(a.l)
  put_vAlign(a.p-bstr)
  get_vAlign(a.l)
  put_bgColor(a.p-variant)
  get_bgColor(a.l)
  put_borderColor(a.p-variant)
  get_borderColor(a.l)
  put_borderColorLight(a.p-variant)
  get_borderColorLight(a.l)
  put_borderColorDark(a.p-variant)
  get_borderColorDark(a.l)
  get_rowIndex(a.l)
  get_sectionRowIndex(a.l)
  get_cells(a.l)
  insertCell(a.l, b.l)
  deleteCell(a.l)
EndInterface

; IHTMLTableRow2 interface definition
;
Interface IHTMLTableRow2 Extends IDispatch
  put_height(a.p-variant)
  get_height(a.l)
EndInterface

; IHTMLTableRow3 interface definition
;
Interface IHTMLTableRow3 Extends IDispatch
  put_ch(a.p-bstr)
  get_ch(a.l)
  put_chOff(a.p-bstr)
  get_chOff(a.l)
EndInterface

; IHTMLTableRowMetrics interface definition
;
Interface IHTMLTableRowMetrics Extends IDispatch
  get_clientHeight(a.l)
  get_clientWidth(a.l)
  get_clientTop(a.l)
  get_clientLeft(a.l)
EndInterface

; IHTMLTableCell interface definition
;
Interface IHTMLTableCell Extends IDispatch
  put_rowSpan(a.l)
  get_rowSpan(a.l)
  put_colSpan(a.l)
  get_colSpan(a.l)
  put_align(a.p-bstr)
  get_align(a.l)
  put_vAlign(a.p-bstr)
  get_vAlign(a.l)
  put_bgColor(a.p-variant)
  get_bgColor(a.l)
  put_noWrap(a.l)
  get_noWrap(a.l)
  put_background(a.p-bstr)
  get_background(a.l)
  put_borderColor(a.p-variant)
  get_borderColor(a.l)
  put_borderColorLight(a.p-variant)
  get_borderColorLight(a.l)
  put_borderColorDark(a.p-variant)
  get_borderColorDark(a.l)
  put_width(a.p-variant)
  get_width(a.l)
  put_height(a.p-variant)
  get_height(a.l)
  get_cellIndex(a.l)
EndInterface

; IHTMLTableCell2 interface definition
;
Interface IHTMLTableCell2 Extends IDispatch
  put_abbr(a.p-bstr)
  get_abbr(a.l)
  put_axis(a.p-bstr)
  get_axis(a.l)
  put_ch(a.p-bstr)
  get_ch(a.l)
  put_chOff(a.p-bstr)
  get_chOff(a.l)
  put_headers(a.p-bstr)
  get_headers(a.l)
  put_scope(a.p-bstr)
  get_scope(a.l)
EndInterface

; DispHTMLTable interface definition
;
Interface DispHTMLTable Extends IDispatch
EndInterface

; DispHTMLTableCol interface definition
;
Interface DispHTMLTableCol Extends IDispatch
EndInterface

; DispHTMLTableSection interface definition
;
Interface DispHTMLTableSection Extends IDispatch
EndInterface

; DispHTMLTableRow interface definition
;
Interface DispHTMLTableRow Extends IDispatch
EndInterface

; DispHTMLTableCell interface definition
;
Interface DispHTMLTableCell Extends IDispatch
EndInterface

; HTMLScriptEvents2 interface definition
;
Interface HTMLScriptEvents2 Extends IDispatch
EndInterface

; HTMLScriptEvents interface definition
;
Interface HTMLScriptEvents Extends IDispatch
EndInterface

; IHTMLScriptElement interface definition
;
Interface IHTMLScriptElement Extends IDispatch
  put_src(a.p-bstr)
  get_src(a.l)
  put_htmlFor(a.p-bstr)
  get_htmlFor(a.l)
  put_event(a.p-bstr)
  get_event(a.l)
  put_text(a.p-bstr)
  get_text(a.l)
  put_defer(a.l)
  get_defer(a.l)
  get_readyState(a.l)
  put_onerror(a.p-variant)
  get_onerror(a.l)
  put_type(a.p-bstr)
  get_type(a.l)
EndInterface

; IHTMLScriptElement2 interface definition
;
Interface IHTMLScriptElement2 Extends IDispatch
  put_charset(a.p-bstr)
  get_charset(a.l)
EndInterface

; DispHTMLScriptElement interface definition
;
Interface DispHTMLScriptElement Extends IDispatch
EndInterface

; IHTMLNoShowElement interface definition
;
Interface IHTMLNoShowElement Extends IDispatch
EndInterface

; DispHTMLNoShowElement interface definition
;
Interface DispHTMLNoShowElement Extends IDispatch
EndInterface

; HTMLObjectElementEvents2 interface definition
;
Interface HTMLObjectElementEvents2 Extends IDispatch
EndInterface

; HTMLObjectElementEvents interface definition
;
Interface HTMLObjectElementEvents Extends IDispatch
EndInterface

; IHTMLObjectElement interface definition
;
Interface IHTMLObjectElement Extends IDispatch
  get_object(a.l)
  get_classid(a.l)
  get_data(a.l)
  putref_recordset(a.l)
  get_recordset(a.l)
  put_align(a.p-bstr)
  get_align(a.l)
  put_name(a.p-bstr)
  get_name(a.l)
  put_codeBase(a.p-bstr)
  get_codeBase(a.l)
  put_codeType(a.p-bstr)
  get_codeType(a.l)
  put_code(a.p-bstr)
  get_code(a.l)
  get_BaseHref(a.l)
  put_type(a.p-bstr)
  get_type(a.l)
  get_form(a.l)
  put_width(a.p-variant)
  get_width(a.l)
  put_height(a.p-variant)
  get_height(a.l)
  get_readyState(a.l)
  put_onreadystatechange(a.p-variant)
  get_onreadystatechange(a.l)
  put_onerror(a.p-variant)
  get_onerror(a.l)
  put_altHtml(a.p-bstr)
  get_altHtml(a.l)
  put_vspace(a.l)
  get_vspace(a.l)
  put_hspace(a.l)
  get_hspace(a.l)
EndInterface

; IHTMLObjectElement2 interface definition
;
Interface IHTMLObjectElement2 Extends IDispatch
  namedRecordset(a.p-bstr, b.l, c.l)
  put_classid(a.p-bstr)
  get_classid(a.l)
  put_data(a.p-bstr)
  get_data(a.l)
EndInterface

; IHTMLObjectElement3 interface definition
;
Interface IHTMLObjectElement3 Extends IDispatch
  put_archive(a.p-bstr)
  get_archive(a.l)
  put_alt(a.p-bstr)
  get_alt(a.l)
  put_declare(a.l)
  get_declare(a.l)
  put_standby(a.p-bstr)
  get_standby(a.l)
  put_border(a.p-variant)
  get_border(a.l)
  put_useMap(a.p-bstr)
  get_useMap(a.l)
EndInterface

; IHTMLParamElement interface definition
;
Interface IHTMLParamElement Extends IDispatch
  put_name(a.p-bstr)
  get_name(a.l)
  put_value(a.p-bstr)
  get_value(a.l)
  put_type(a.p-bstr)
  get_type(a.l)
  put_valueType(a.p-bstr)
  get_valueType(a.l)
EndInterface

; DispHTMLObjectElement interface definition
;
Interface DispHTMLObjectElement Extends IDispatch
EndInterface

; DispHTMLParamElement interface definition
;
Interface DispHTMLParamElement Extends IDispatch
EndInterface

; HTMLFrameSiteEvents2 interface definition
;
Interface HTMLFrameSiteEvents2 Extends IDispatch
EndInterface

; HTMLFrameSiteEvents interface definition
;
Interface HTMLFrameSiteEvents Extends IDispatch
EndInterface

; IHTMLFrameBase2 interface definition
;
Interface IHTMLFrameBase2 Extends IDispatch
  get_contentWindow(a.l)
  put_onload(a.p-variant)
  get_onload(a.l)
  put_onreadystatechange(a.p-variant)
  get_onreadystatechange(a.l)
  get_readyState(a.l)
  put_allowTransparency(a.l)
  get_allowTransparency(a.l)
EndInterface

; IHTMLFrameBase3 interface definition
;
Interface IHTMLFrameBase3 Extends IDispatch
  put_longDesc(a.p-bstr)
  get_longDesc(a.l)
EndInterface

; DispHTMLFrameBase interface definition
;
Interface DispHTMLFrameBase Extends IDispatch
EndInterface

; IHTMLFrameElement interface definition
;
Interface IHTMLFrameElement Extends IDispatch
  put_borderColor(a.p-variant)
  get_borderColor(a.l)
EndInterface

; IHTMLFrameElement2 interface definition
;
Interface IHTMLFrameElement2 Extends IDispatch
  put_height(a.p-variant)
  get_height(a.l)
  put_width(a.p-variant)
  get_width(a.l)
EndInterface

; DispHTMLFrameElement interface definition
;
Interface DispHTMLFrameElement Extends IDispatch
EndInterface

; IHTMLIFrameElement interface definition
;
Interface IHTMLIFrameElement Extends IDispatch
  put_vspace(a.l)
  get_vspace(a.l)
  put_hspace(a.l)
  get_hspace(a.l)
  put_align(a.p-bstr)
  get_align(a.l)
EndInterface

; IHTMLIFrameElement2 interface definition
;
Interface IHTMLIFrameElement2 Extends IDispatch
  put_height(a.p-variant)
  get_height(a.l)
  put_width(a.p-variant)
  get_width(a.l)
EndInterface

; DispHTMLIFrame interface definition
;
Interface DispHTMLIFrame Extends IDispatch
EndInterface

; IHTMLDivPosition interface definition
;
Interface IHTMLDivPosition Extends IDispatch
  put_align(a.p-bstr)
  get_align(a.l)
EndInterface

; IHTMLFieldSetElement interface definition
;
Interface IHTMLFieldSetElement Extends IDispatch
  put_align(a.p-bstr)
  get_align(a.l)
EndInterface

; IHTMLFieldSetElement2 interface definition
;
Interface IHTMLFieldSetElement2 Extends IDispatch
  get_form(a.l)
EndInterface

; IHTMLLegendElement interface definition
;
Interface IHTMLLegendElement Extends IDispatch
  put_align(a.p-bstr)
  get_align(a.l)
EndInterface

; IHTMLLegendElement2 interface definition
;
Interface IHTMLLegendElement2 Extends IDispatch
  get_form(a.l)
EndInterface

; DispHTMLDivPosition interface definition
;
Interface DispHTMLDivPosition Extends IDispatch
EndInterface

; DispHTMLFieldSetElement interface definition
;
Interface DispHTMLFieldSetElement Extends IDispatch
EndInterface

; DispHTMLLegendElement interface definition
;
Interface DispHTMLLegendElement Extends IDispatch
EndInterface

; IHTMLSpanFlow interface definition
;
Interface IHTMLSpanFlow Extends IDispatch
  put_align(a.p-bstr)
  get_align(a.l)
EndInterface

; DispHTMLSpanFlow interface definition
;
Interface DispHTMLSpanFlow Extends IDispatch
EndInterface

; IHTMLFrameSetElement interface definition
;
Interface IHTMLFrameSetElement Extends IDispatch
  put_rows(a.p-bstr)
  get_rows(a.l)
  put_cols(a.p-bstr)
  get_cols(a.l)
  put_border(a.p-variant)
  get_border(a.l)
  put_borderColor(a.p-variant)
  get_borderColor(a.l)
  put_frameBorder(a.p-bstr)
  get_frameBorder(a.l)
  put_frameSpacing(a.p-variant)
  get_frameSpacing(a.l)
  put_name(a.p-bstr)
  get_name(a.l)
  put_onload(a.p-variant)
  get_onload(a.l)
  put_onunload(a.p-variant)
  get_onunload(a.l)
  put_onbeforeunload(a.p-variant)
  get_onbeforeunload(a.l)
EndInterface

; IHTMLFrameSetElement2 interface definition
;
Interface IHTMLFrameSetElement2 Extends IDispatch
  put_onbeforeprint(a.p-variant)
  get_onbeforeprint(a.l)
  put_onafterprint(a.p-variant)
  get_onafterprint(a.l)
EndInterface

; DispHTMLFrameSetSite interface definition
;
Interface DispHTMLFrameSetSite Extends IDispatch
EndInterface

; IHTMLBGsound interface definition
;
Interface IHTMLBGsound Extends IDispatch
  put_src(a.p-bstr)
  get_src(a.l)
  put_loop(a.p-variant)
  get_loop(a.l)
  put_volume(a.p-variant)
  get_volume(a.l)
  put_balance(a.p-variant)
  get_balance(a.l)
EndInterface

; DispHTMLBGsound interface definition
;
Interface DispHTMLBGsound Extends IDispatch
EndInterface

; IHTMLFontNamesCollection interface definition
;
Interface IHTMLFontNamesCollection Extends IDispatch
  get_length(a.l)
  get__newEnum(a.l)
  item(a.l, b.l)
EndInterface

; IHTMLFontSizesCollection interface definition
;
Interface IHTMLFontSizesCollection Extends IDispatch
  get_length(a.l)
  get__newEnum(a.l)
  get_forFont(a.l)
  item(a.l, b.l)
EndInterface

; IHTMLOptionsHolder interface definition
;
Interface IHTMLOptionsHolder Extends IDispatch
  get_document(a.l)
  get_fonts(a.l)
  put_execArg(a.p-variant)
  get_execArg(a.l)
  put_errorLine(a.l)
  get_errorLine(a.l)
  put_errorCharacter(a.l)
  get_errorCharacter(a.l)
  put_errorCode(a.l)
  get_errorCode(a.l)
  put_errorMessage(a.p-bstr)
  get_errorMessage(a.l)
  put_errorDebug(a.l)
  get_errorDebug(a.l)
  get_unsecuredWindowOfDocument(a.l)
  put_findText(a.p-bstr)
  get_findText(a.l)
  put_anythingAfterFrameset(a.l)
  get_anythingAfterFrameset(a.l)
  sizes(a.p-bstr, b.l)
  openfiledlg(a.p-variant, b.p-variant, c.p-variant, d.p-variant, e.l)
  savefiledlg(a.p-variant, b.p-variant, c.p-variant, d.p-variant, e.l)
  choosecolordlg(a.p-variant, b.l)
  showSecurityInfo()
  isApartmentModel(a.l, b.l)
  getCharset(a.p-bstr, b.l)
  get_secureConnectionInfo(a.l)
EndInterface

; HTMLStyleElementEvents2 interface definition
;
Interface HTMLStyleElementEvents2 Extends IDispatch
EndInterface

; HTMLStyleElementEvents interface definition
;
Interface HTMLStyleElementEvents Extends IDispatch
EndInterface

; IHTMLStyleElement interface definition
;
Interface IHTMLStyleElement Extends IDispatch
  put_type(a.p-bstr)
  get_type(a.l)
  get_readyState(a.l)
  put_onreadystatechange(a.p-variant)
  get_onreadystatechange(a.l)
  put_onload(a.p-variant)
  get_onload(a.l)
  put_onerror(a.p-variant)
  get_onerror(a.l)
  get_styleSheet(a.l)
  put_disabled(a.l)
  get_disabled(a.l)
  put_media(a.p-bstr)
  get_media(a.l)
EndInterface

; DispHTMLStyleElement interface definition
;
Interface DispHTMLStyleElement Extends IDispatch
EndInterface

; IHTMLStyleFontFace interface definition
;
Interface IHTMLStyleFontFace Extends IDispatch
  put_fontsrc(a.p-bstr)
  get_fontsrc(a.l)
EndInterface

; ICSSFilterSite interface definition
;
Interface ICSSFilterSite Extends IUnknown
  GetElement(a.l)
  FireOnFilterChangeEvent()
EndInterface

; IMarkupPointer interface definition
;
Interface IMarkupPointer Extends IUnknown
  OwningDoc(a.l)
  Gravity(a.l)
  SetGravity(a.l)
  Cling(a.l)
  SetCling(a.l)
  Unposition()
  IsPositioned(a.l)
  GetContainer(a.l)
  MoveAdjacentToElement(a.l, b.l)
  MoveToPointer(a.l)
  MoveToContainer(a.l, b.l)
  Left(a.l, b.l, c.l, d.l, e.l)
  Right(a.l, b.l, c.l, d.l, e.l)
  CurrentScope(a.l)
  IsLeftOf(a.l, b.l)
  IsLeftOfOrEqualTo(a.l, b.l)
  IsRightOf(a.l, b.l)
  IsRightOfOrEqualTo(a.l, b.l)
  IsEqualTo(a.l, b.l)
  MoveUnit(a.l)
  FindText(a.l, b.l, c.l, d.l)
EndInterface

; IMarkupContainer interface definition
;
Interface IMarkupContainer Extends IUnknown
  OwningDoc(a.l)
EndInterface

; IMarkupContainer2 interface definition
;
Interface IMarkupContainer2 Extends IMarkupContainer
  CreateChangeLog(a.l, b.l, c.l, d.l)
  RegisterForDirtyRange(a.l, b.l)
  UnRegisterForDirtyRange(a.l)
  GetAndClearDirtyRange(a.l, b.l, c.l)
  GetVersionNumber()
  GetMasterElement(a.l)
EndInterface

; IHTMLChangeLog interface definition
;
Interface IHTMLChangeLog Extends IUnknown
  GetNextChange(a.l, b.l, c.l)
EndInterface

; IHTMLChangeSink interface definition
;
Interface IHTMLChangeSink Extends IUnknown
  Notify()
EndInterface

; IActiveIMMApp interface definition
;
Interface IActiveIMMApp Extends IUnknown
  AssociateContext(a.l, b.l, c.l)
  ConfigureIMEA(a.l, b.l, c.l, d.l)
  ConfigureIMEW(a.l, b.l, c.l, d.l)
  CreateContext(a.l)
  DestroyContext(a.l)
  EnumRegisterWordA(a.l, b.l, c.l, d.l, e.l, f.l)
  EnumRegisterWordW(a.l, b.p-unicode, c.l, d.p-unicode, e.l, f.l)
  EscapeA(a.l, b.l, c.l, d.l, e.l)
  EscapeW(a.l, b.l, c.l, d.l, e.l)
  GetCandidateListA(a.l, b.l, c.l, d.l, e.l)
  GetCandidateListW(a.l, b.l, c.l, d.l, e.l)
  GetCandidateListCountA(a.l, b.l, c.l)
  GetCandidateListCountW(a.l, b.l, c.l)
  GetCandidateWindow(a.l, b.l, c.l)
  GetCompositionFontA(a.l, b.l)
  GetCompositionFontW(a.l, b.l)
  GetCompositionStringA(a.l, b.l, c.l, d.l, e.l)
  GetCompositionStringW(a.l, b.l, c.l, d.l, e.l)
  GetCompositionWindow(a.l, b.l)
  GetContext(a.l, b.l)
  GetConversionListA(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  GetConversionListW(a.l, b.l, c.p-unicode, d.l, e.l, f.l, g.l)
  GetConversionStatus(a.l, b.l, c.l)
  GetDefaultIMEWnd(a.l, b.l)
  GetDescriptionA(a.l, b.l, c.l, d.l)
  GetDescriptionW(a.l, b.l, c.p-unicode, d.l)
  GetGuideLineA(a.l, b.l, c.l, d.l, e.l)
  GetGuideLineW(a.l, b.l, c.l, d.p-unicode, e.l)
  GetIMEFileNameA(a.l, b.l, c.l, d.l)
  GetIMEFileNameW(a.l, b.l, c.p-unicode, d.l)
  GetOpenStatus(a.l)
  GetProperty(a.l, b.l, c.l)
  GetRegisterWordStyleA(a.l, b.l, c.l, d.l)
  GetRegisterWordStyleW(a.l, b.l, c.l, d.l)
  GetStatusWindowPos(a.l, b.l)
  GetVirtualKey(a.l, b.l)
  InstallIMEA(a.l, b.l, c.l)
  InstallIMEW(a.p-unicode, b.p-unicode, c.l)
  IsIME(a.l)
  IsUIMessageA(a.l, b.l, c.l, d.l)
  IsUIMessageW(a.l, b.l, c.l, d.l)
  NotifyIME(a.l, b.l, c.l, d.l)
  RegisterWordA(a.l, b.l, c.l, d.l)
  RegisterWordW(a.l, b.p-unicode, c.l, d.p-unicode)
  ReleaseContext(a.l, b.l)
  SetCandidateWindow(a.l, b.l)
  SetCompositionFontA(a.l, b.l)
  SetCompositionFontW(a.l, b.l)
  SetCompositionStringA(a.l, b.l, c.l, d.l, e.l, f.l)
  SetCompositionStringW(a.l, b.l, c.l, d.l, e.l, f.l)
  SetCompositionWindow(a.l, b.l)
  SetConversionStatus(a.l, b.l, c.l)
  SetOpenStatus(a.l, b.l)
  SetStatusWindowPos(a.l, b.l)
  SimulateHotKey(a.l, b.l)
  UnregisterWordA(a.l, b.l, c.l, d.l)
  UnregisterWordW(a.l, b.p-unicode, c.l, d.p-unicode)
  Activate(a.l)
  Deactivate()
  OnDefWindowProc(a.l, b.l, c.l, d.l, e.l)
  FilterClientWindows(a.l, b.l)
  GetCodePageA(a.l, b.l)
  GetLangId(a.l, b.l)
  AssociateContextEx(a.l, b.l, c.l)
  DisableIME(a.l)
  GetImeMenuItemsA(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  GetImeMenuItemsW(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  EnumInputContext(a.l, b.l)
EndInterface

; ISegmentList interface definition
;
Interface ISegmentList Extends IUnknown
  CreateIterator(a.l)
  GetType(a.l)
  IsEmpty(a.l)
EndInterface

; ISegmentListIterator interface definition
;
Interface ISegmentListIterator Extends IUnknown
  Current(a.l)
  First()
  IsDone()
  Advance()
EndInterface

; IHTMLCaret interface definition
;
Interface IHTMLCaret Extends IUnknown
  MoveCaretToPointer(a.l, b.l, c.l)
  MoveCaretToPointerEx(a.l, b.l, c.l, d.l)
  MoveMarkupPointerToCaret(a.l)
  MoveDisplayPointerToCaret(a.l)
  IsVisible(a.l)
  Show(a.l)
  Hide()
  InsertText(a.l, b.l)
  ScrollIntoView()
  GetLocation(a.l, b.l)
  GetCaretDirection(a.l)
  SetCaretDirection(a.l)
EndInterface

; ISegment interface definition
;
Interface ISegment Extends IUnknown
  GetPointers(a.l, b.l)
EndInterface

; IElementSegment interface definition
;
Interface IElementSegment Extends ISegment
  GetElement(a.l)
  SetPrimary(a.l)
  IsPrimary(a.l)
EndInterface

; IHighlightSegment interface definition
;
Interface IHighlightSegment Extends ISegment
EndInterface

; IHighlightRenderingServices interface definition
;
Interface IHighlightRenderingServices Extends IUnknown
  AddSegment(a.l, b.l, c.l, d.l)
  MoveSegmentToPointers(a.l, b.l, c.l)
  RemoveSegment(a.l)
EndInterface

; ILineInfo interface definition
;
Interface ILineInfo Extends IUnknown
  get_x(a.l)
  get_baseLine(a.l)
  get_textDescent(a.l)
  get_textHeight(a.l)
  get_lineDirection(a.l)
EndInterface

; IDisplayPointer interface definition
;
Interface IDisplayPointer Extends IUnknown
  MoveToPoint(a.l, b.l, c.l, d.l, e.l)
  MoveUnit(a.l, b.l)
  PositionMarkupPointer(a.l)
  MoveToPointer(a.l)
  SetPointerGravity(a.l)
  GetPointerGravity(a.l)
  SetDisplayGravity(a.l)
  GetDisplayGravity(a.l)
  IsPositioned(a.l)
  Unposition()
  IsEqualTo(a.l, b.l)
  IsLeftOf(a.l, b.l)
  IsRightOf(a.l, b.l)
  IsAtBOL(a.l)
  MoveToMarkupPointer(a.l, b.l)
  ScrollIntoView()
  GetLineInfo(a.l)
  GetFlowElement(a.l)
  QueryBreaks(a.l)
EndInterface

; IDisplayServices interface definition
;
Interface IDisplayServices Extends IUnknown
  CreateDisplayPointer(a.l)
  TransformRect(a.l, b.l, c.l, d.l)
  TransformPoint(a.l, b.l, c.l, d.l)
  GetCaret(a.l)
  GetComputedStyle(a.l, b.l)
  ScrollRectIntoView(a.l, b.l)
  HasFlowLayout(a.l, b.l)
EndInterface

; IHtmlDlgSafeHelper interface definition
;
Interface IHtmlDlgSafeHelper Extends IDispatch
  choosecolordlg(a.p-variant, b.l)
  getCharset(a.p-bstr, b.l)
  get_Fonts(a.l)
  get_BlockFormats(a.l)
EndInterface

; IBlockFormats interface definition
;
Interface IBlockFormats Extends IDispatch
  get__NewEnum(a.l)
  get_Count(a.l)
  Item(a.l, b.l)
EndInterface

; IFontNames interface definition
;
Interface IFontNames Extends IDispatch
  get__NewEnum(a.l)
  get_Count(a.l)
  Item(a.l, b.l)
EndInterface

; ICSSFilter interface definition
;
Interface ICSSFilter Extends IUnknown
  SetSite(a.l)
  OnAmbientPropertyChange(a.l)
EndInterface

; ISecureUrlHost interface definition
;
Interface ISecureUrlHost Extends IUnknown
  ValidateSecureUrl(a.l, b.l, c.l)
EndInterface

; IMarkupServices interface definition
;
Interface IMarkupServices Extends IUnknown
  CreateMarkupPointer(a.l)
  CreateMarkupContainer(a.l)
  CreateElement(a.l, b.l, c.l)
  CloneElement(a.l, b.l)
  InsertElement(a.l, b.l, c.l)
  RemoveElement(a.l)
  Remove(a.l, b.l)
  Copy(a.l, b.l, c.l)
  Move(a.l, b.l, c.l)
  InsertText(a.l, b.l, c.l)
  ParseString(a.l, b.l, c.l, d.l, e.l)
  ParseGlobal(a.l, b.l, c.l, d.l, e.l)
  IsScopedElement(a.l, b.l)
  GetElementTagId(a.l, b.l)
  GetTagIDForName(a.p-bstr, b.l)
  GetNameForTagID(a.l, b.l)
  MovePointersToRange(a.l, b.l, c.l)
  MoveRangeToPointers(a.l, b.l, c.l)
  BeginUndoUnit(a.l)
  EndUndoUnit()
EndInterface

; IMarkupServices2 interface definition
;
Interface IMarkupServices2 Extends IMarkupServices
  ParseGlobalEx(a.l, b.l, c.l, d.l, e.l, f.l)
  ValidateElements(a.l, b.l, c.l, d.l, e.l, f.l)
  SaveSegmentsToClipboard(a.l, b.l)
EndInterface

; IHTMLChangePlayback interface definition
;
Interface IHTMLChangePlayback Extends IUnknown
  ExecChange(a.l, b.l)
EndInterface

; IMarkupPointer2 interface definition
;
Interface IMarkupPointer2 Extends IMarkupPointer
  IsAtWordBreak(a.l)
  GetMarkupPosition(a.l)
  MoveToMarkupPosition(a.l, b.l)
  MoveUnitBounded(a.l, b.l)
  IsInsideURL(a.l, b.l)
  MoveToContent(a.l, b.l)
EndInterface

; IMarkupTextFrags interface definition
;
Interface IMarkupTextFrags Extends IUnknown
  GetTextFragCount(a.l)
  GetTextFrag(a.l, b.l, c.l)
  RemoveTextFrag(a.l)
  InsertTextFrag(a.l, b.p-bstr, c.l)
  FindTextFragFromMarkupPointer(a.l, b.l, c.l)
EndInterface

; IXMLGenericParse interface definition
;
Interface IXMLGenericParse Extends IUnknown
  SetGenericParse(a.l)
EndInterface

; IHTMLEditHost interface definition
;
Interface IHTMLEditHost Extends IUnknown
  SnapRect(a.l, b.l, c.l)
EndInterface

; IHTMLEditHost2 interface definition
;
Interface IHTMLEditHost2 Extends IHTMLEditHost
  PreDrag()
EndInterface

; ISequenceNumber interface definition
;
Interface ISequenceNumber Extends IUnknown
  GetSequenceNumber(a.l, b.l)
EndInterface

; IIMEServices interface definition
;
Interface IIMEServices Extends IUnknown
  GetActiveIMM(a.l)
EndInterface

; ISelectionServicesListener interface definition
;
Interface ISelectionServicesListener Extends IUnknown
  BeginSelectionUndo()
  EndSelectionUndo()
  OnSelectedElementExit(a.l, b.l, c.l, d.l)
  OnChangeType(a.l, b.l)
  GetTypeDetail(a.l)
EndInterface

; ISelectionServices interface definition
;
Interface ISelectionServices Extends IUnknown
  SetSelectionType(a.l, b.l)
  GetMarkupContainer(a.l)
  AddSegment(a.l, b.l, c.l)
  AddElementSegment(a.l, b.l)
  RemoveSegment(a.l)
  GetSelectionServicesListener(a.l)
EndInterface

; IHTMLEditDesigner interface definition
;
Interface IHTMLEditDesigner Extends IUnknown
  PreHandleEvent(a.l, b.l)
  PostHandleEvent(a.l, b.l)
  TranslateAccelerator(a.l, b.l)
  PostEditorEventNotify(a.l, b.l)
EndInterface

; IHTMLEditServices interface definition
;
Interface IHTMLEditServices Extends IUnknown
  AddDesigner(a.l)
  RemoveDesigner(a.l)
  GetSelectionServices(a.l, b.l)
  MoveToSelectionAnchor(a.l)
  MoveToSelectionEnd(a.l)
  SelectRange(a.l, b.l, c.l)
EndInterface

; IHTMLEditServices2 interface definition
;
Interface IHTMLEditServices2 Extends IHTMLEditServices
  MoveToSelectionAnchorEx(a.l)
  MoveToSelectionEndEx(a.l)
  FreezeVirtualCaretPos(a.l)
  UnFreezeVirtualCaretPos(a.l)
EndInterface

; IHTMLComputedStyle interface definition
;
Interface IHTMLComputedStyle Extends IUnknown
  get_bold(a.l)
  get_italic(a.l)
  get_underline(a.l)
  get_overline(a.l)
  get_strikeOut(a.l)
  get_subScript(a.l)
  get_superScript(a.l)
  get_explicitFace(a.l)
  get_fontWeight(a.l)
  get_fontSize(a.l)
  get_fontName(a.l)
  get_hasBgColor(a.l)
  get_textColor(a.l)
  get_backgroundColor(a.l)
  get_preFormatted(a.l)
  get_direction(a.l)
  get_blockDirection(a.l)
  get_OL(a.l)
  IsEqual(a.l, b.l)
EndInterface

; HTMLNamespaceEvents interface definition
;
Interface HTMLNamespaceEvents Extends IDispatch
EndInterface

; IHTMLNamespace interface definition
;
Interface IHTMLNamespace Extends IDispatch
  get_name(a.l)
  get_urn(a.l)
  get_tagNames(a.l)
  get_readyState(a.l)
  put_onreadystatechange(a.p-variant)
  get_onreadystatechange(a.l)
  doImport(a.p-bstr)
  attachEvent(a.p-bstr, b.l, c.l)
  detachEvent(a.p-bstr, b.l)
EndInterface

; IHTMLNamespaceCollection interface definition
;
Interface IHTMLNamespaceCollection Extends IDispatch
  get_length(a.l)
  item(a.p-variant, b.l)
  add(a.p-bstr, b.p-bstr, c.p-variant, d.l)
EndInterface

; IHTMLPainter interface definition
;
Interface IHTMLPainter Extends IUnknown
  Draw(a.l, b.l, c.l, d.l, e.l)
  OnResize(a.l)
  GetPainterInfo(a.l)
  HitTestPoint(a.l, b.l, c.l)
EndInterface

; IHTMLPaintSite interface definition
;
Interface IHTMLPaintSite Extends IUnknown
  InvalidatePainterInfo()
  InvalidateRect(a.l)
  InvalidateRegion(a.l)
  GetDrawInfo(a.l, b.l)
  TransformGlobalToLocal(a.l, b.l)
  TransformLocalToGlobal(a.l, b.l)
  GetHitTestCookie(a.l)
EndInterface

; IHTMLPainterEventInfo interface definition
;
Interface IHTMLPainterEventInfo Extends IUnknown
  GetEventInfoFlags(a.l)
  GetEventTarget(a.l)
  SetCursor(a.l)
  StringFromPartID(a.l, b.l)
EndInterface

; IHTMLPainterOverlay interface definition
;
Interface IHTMLPainterOverlay Extends IUnknown
  OnMove(a.l)
EndInterface

; IHTMLIPrintCollection interface definition
;
Interface IHTMLIPrintCollection Extends IDispatch
  get_length(a.l)
  get__newEnum(a.l)
  item(a.l, b.l)
EndInterface

; IEnumPrivacyRecords interface definition
;
Interface IEnumPrivacyRecords Extends IUnknown
  Reset()
  GetSize(a.l)
  GetPrivacyImpacted(a.l)
  Next(a.l, b.l, c.l, d.l)
EndInterface

; IHTMLDialog interface definition
;
Interface IHTMLDialog Extends IDispatch
  put_dialogTop(a.p-variant)
  get_dialogTop(a.l)
  put_dialogLeft(a.p-variant)
  get_dialogLeft(a.l)
  put_dialogWidth(a.p-variant)
  get_dialogWidth(a.l)
  put_dialogHeight(a.p-variant)
  get_dialogHeight(a.l)
  get_dialogArguments(a.l)
  get_menuArguments(a.l)
  put_returnValue(a.p-variant)
  get_returnValue(a.l)
  close()
  toString(a.l)
EndInterface

; IHTMLDialog2 interface definition
;
Interface IHTMLDialog2 Extends IDispatch
  put_status(a.p-bstr)
  get_status(a.l)
  put_resizable(a.p-bstr)
  get_resizable(a.l)
EndInterface

; IHTMLDialog3 interface definition
;
Interface IHTMLDialog3 Extends IDispatch
  put_unadorned(a.p-bstr)
  get_unadorned(a.l)
  put_dialogHide(a.p-bstr)
  get_dialogHide(a.l)
EndInterface

; IHTMLModelessInit interface definition
;
Interface IHTMLModelessInit Extends IDispatch
  get_parameters(a.l)
  get_optionString(a.l)
  get_moniker(a.l)
  get_document(a.l)
EndInterface

; IHTMLPopup interface definition
;
Interface IHTMLPopup Extends IDispatch
  show(a.l, b.l, c.l, d.l, e.l)
  hide()
  get_document(a.l)
  get_isOpen(a.l)
EndInterface

; DispHTMLPopup interface definition
;
Interface DispHTMLPopup Extends IDispatch
EndInterface

; IHTMLAppBehavior interface definition
;
Interface IHTMLAppBehavior Extends IDispatch
  put_applicationName(a.p-bstr)
  get_applicationName(a.l)
  put_version(a.p-bstr)
  get_version(a.l)
  put_icon(a.p-bstr)
  get_icon(a.l)
  put_singleInstance(a.p-bstr)
  get_singleInstance(a.l)
  put_minimizeButton(a.p-bstr)
  get_minimizeButton(a.l)
  put_maximizeButton(a.p-bstr)
  get_maximizeButton(a.l)
  put_border(a.p-bstr)
  get_border(a.l)
  put_borderStyle(a.p-bstr)
  get_borderStyle(a.l)
  put_sysMenu(a.p-bstr)
  get_sysMenu(a.l)
  put_caption(a.p-bstr)
  get_caption(a.l)
  put_windowState(a.p-bstr)
  get_windowState(a.l)
  put_showInTaskBar(a.p-bstr)
  get_showInTaskBar(a.l)
  get_commandLine(a.l)
EndInterface

; IHTMLAppBehavior2 interface definition
;
Interface IHTMLAppBehavior2 Extends IDispatch
  put_contextMenu(a.p-bstr)
  get_contextMenu(a.l)
  put_innerBorder(a.p-bstr)
  get_innerBorder(a.l)
  put_scroll(a.p-bstr)
  get_scroll(a.l)
  put_scrollFlat(a.p-bstr)
  get_scrollFlat(a.l)
  put_selection(a.p-bstr)
  get_selection(a.l)
EndInterface

; IHTMLAppBehavior3 interface definition
;
Interface IHTMLAppBehavior3 Extends IDispatch
  put_navigable(a.p-bstr)
  get_navigable(a.l)
EndInterface

; DispHTMLAppBehavior interface definition
;
Interface DispHTMLAppBehavior Extends IDispatch
EndInterface

; DispIHTMLInputButtonElement interface definition
;
Interface DispIHTMLInputButtonElement Extends IDispatch
EndInterface

; DispIHTMLInputTextElement interface definition
;
Interface DispIHTMLInputTextElement Extends IDispatch
EndInterface

; DispIHTMLInputFileElement interface definition
;
Interface DispIHTMLInputFileElement Extends IDispatch
EndInterface

; DispIHTMLOptionButtonElement interface definition
;
Interface DispIHTMLOptionButtonElement Extends IDispatch
EndInterface

; DispIHTMLInputImage interface definition
;
Interface DispIHTMLInputImage Extends IDispatch
EndInterface

; IElementNamespace interface definition
;
Interface IElementNamespace Extends IUnknown
  AddTag(a.p-bstr, b.l)
EndInterface

; IElementNamespaceTable interface definition
;
Interface IElementNamespaceTable Extends IUnknown
  AddNamespace(a.p-bstr, b.p-bstr, c.l, d.l)
EndInterface

; IElementNamespaceFactory interface definition
;
Interface IElementNamespaceFactory Extends IUnknown
  Create(a.l)
EndInterface

; IElementNamespaceFactory2 interface definition
;
Interface IElementNamespaceFactory2 Extends IElementNamespaceFactory
  CreateWithImplementation(a.l, b.p-bstr)
EndInterface

; IElementNamespaceFactoryCallback interface definition
;
Interface IElementNamespaceFactoryCallback Extends IUnknown
  Resolve(a.p-bstr, b.p-bstr, c.p-bstr, d.l)
EndInterface

; IElementBehaviorSiteOM2 interface definition
;
Interface IElementBehaviorSiteOM2 Extends IElementBehaviorSiteOM
  GetDefaults(a.l)
EndInterface

; IElementBehaviorCategory interface definition
;
Interface IElementBehaviorCategory Extends IUnknown
  GetCategory(a.l)
EndInterface

; IElementBehaviorSiteCategory interface definition
;
Interface IElementBehaviorSiteCategory Extends IUnknown
  GetRelatedBehaviors(a.l, b.p-unicode, c.l)
EndInterface

; IElementBehaviorSubmit interface definition
;
Interface IElementBehaviorSubmit Extends IUnknown
  GetSubmitInfo(a.l)
  Reset()
EndInterface

; IElementBehaviorFocus interface definition
;
Interface IElementBehaviorFocus Extends IUnknown
  GetFocusRect(a.l)
EndInterface

; IElementBehaviorLayout interface definition
;
Interface IElementBehaviorLayout Extends IUnknown
  GetSize(a.l, b.l, c.l, d.l, e.l)
  GetLayoutInfo(a.l)
  GetPosition(a.l, b.l)
  MapSize(a.l, b.l)
EndInterface

; IElementBehaviorLayout2 interface definition
;
Interface IElementBehaviorLayout2 Extends IUnknown
  GetTextDescent(a.l)
EndInterface

; IElementBehaviorSiteLayout interface definition
;
Interface IElementBehaviorSiteLayout Extends IUnknown
  InvalidateLayoutInfo()
  InvalidateSize()
  GetMediaResolution(a.l)
EndInterface

; IElementBehaviorSiteLayout2 interface definition
;
Interface IElementBehaviorSiteLayout2 Extends IUnknown
  GetFontInfo(a.l)
EndInterface

; IHostBehaviorInit interface definition
;
Interface IHostBehaviorInit Extends IUnknown
  PopulateNamespaceTable()
EndInterface
