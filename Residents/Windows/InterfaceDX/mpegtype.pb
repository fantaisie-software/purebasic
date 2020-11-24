
; IMpegAudioDecoder interface definition
;
Interface IMpegAudioDecoder
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  get_FrequencyDivider(a.l)
  put_FrequencyDivider(a.l)
  get_DecoderAccuracy(a.l)
  put_DecoderAccuracy(a.l)
  get_Stereo(a.l)
  put_Stereo(a.l)
  get_DecoderWordSize(a.l)
  put_DecoderWordSize(a.l)
  get_IntegerDecode(a.l)
  put_IntegerDecode(a.l)
  get_DualMode(a.l)
  put_DualMode(a.l)
  get_AudioFormat(a.l)
EndInterface
