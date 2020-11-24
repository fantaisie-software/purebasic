XIncludeFile "common.pbi"

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  #LibName$ = "expat.lib"
CompilerElse
  #LibName$ = "-lpbexpat"
CompilerEndIf

ImportC #LibName$
  ApiC(pb_XML_DefaultCurrent, (arg1))
  ApiC(pb_XML_ErrorString, (arg1))
  ApiC(pb_XML_ExpatVersion, ())
  ApiC(pb_XML_ExpatVersionInfo, ())
  ApiC(pb_XML_ExternalEntityParserCreate, (arg1, arg2))
  ApiC(pb_XML_FreeContentModel, (arg1, arg2))
  ApiC(pb_XML_GetBase, (arg1))
  ApiC(pb_XML_GetBuffer, (arg1, arg2))
  ApiC(pb_XML_GetCurrentByteCount, (arg1))
  ApiC(pb_XML_GetCurrentByteIndex, (arg1))
  ApiC(pb_XML_GetCurrentColumnNumber, (arg1))
  ApiC(pb_XML_GetCurrentLineNumber, (arg1))
  ApiC(pb_XML_GetErrorCode, (arg1))
  ApiC(pb_XML_GetFeatureList, ())
  ApiC(pb_XML_GetIdAttributeIndex, (arg1))
  ApiC(pb_XML_GetInputContext, (arg1, arg2, arg3))
  ApiC(pb_XML_GetParsingStatus, (arg1, arg2))
  ApiC(pb_XML_GetSpecifiedAttributeCount, (arg1))
  ApiC(pb_XML_MemFree, (arg1, arg2))
  ApiC(pb_XML_MemMalloc, (arg1, arg2))
  ApiC(pb_XML_MemRealloc, (arg1, arg2, arg3))
  ApiC(pb_XML_Parse, (arg1, arg2, arg3, arg4))
  ApiC(pb_XML_ParseBuffer, (arg1, arg2, arg3))
  ApiC(pb_XML_ParserCreate, (arg1))
  ApiC(pb_XML_ParserCreate_MM, (arg1, arg2, arg3))
  ApiC(pb_XML_ParserCreateNS, (arg1, arg2))
  ApiC(pb_XML_ParserFree, (arg1))
  ApiC(pb_XML_ParserReset, (arg1, arg2))
  ApiC(pb_XML_ResumeParser, (arg1))
  ApiC(pb_XML_SetAttlistDeclHandler, (arg1, arg2))
  ApiC(pb_XML_SetBase, (arg1, arg2))
  ApiC(pb_XML_SetCdataSectionHandler, (arg1, arg2, arg3))
  ApiC(pb_XML_SetCharacterDataHandler, (arg1, arg2))
  ApiC(pb_XML_SetCommentHandler, (arg1, arg2))
  ApiC(pb_XML_SetDefaultHandler, (arg1, arg2))
  ApiC(pb_XML_SetDefaultHandlerExpand, (arg1, arg2))
  ApiC(pb_XML_SetDoctypeDeclHandler, (arg1, arg2, arg3))
  ApiC(pb_XML_SetElementDeclHandler, (arg1, arg2))
  ApiC(pb_XML_SetElementHandler, (arg1, arg2, arg3))
  ApiC(pb_XML_SetEncoding, (arg1, arg2))
  ApiC(pb_XML_SetEndCdataSectionHandler, (arg1, arg2))
  ApiC(pb_XML_SetEndDoctypeDeclHandler, (arg1, arg2))
  ApiC(pb_XML_SetEndElementHandler, (arg1, arg2))
  ApiC(pb_XML_SetEndNamespaceDeclHandler, (arg1, arg2))
  ApiC(pb_XML_SetEntityDeclHandler, (arg1, arg2))
  ApiC(pb_XML_SetExternalEntityRefHandler, (arg1, arg2))
  ApiC(pb_XML_SetExternalEntityRefHandlerArg, (arg1, arg2))
  ApiC(pb_XML_SetNamespaceDeclHandler, (arg1, arg2))
  ApiC(pb_XML_SetNotationDeclHandler, (arg1, arg2))
  ApiC(pb_XML_SetNotStandaloneHandler, (arg1, arg2))
  ApiC(pb_XML_SetParamEntityParsing, (arg1, arg2))
  ApiC(pb_XML_SetProcessingInstructionHandler, (arg1, arg2))
  ApiC(pb_XML_SetReturnNSTriplet, (arg1, arg2))
  ApiC(pb_XML_SetSkippedEntityHandler, (arg1, arg2))
  ApiC(pb_XML_SetStartCdataSectionHandler, (arg1, arg2))
  ApiC(pb_XML_SetStartDoctypeDeclHandler, (arg1, arg2))
  ApiC(pb_XML_SetStartElementHandler, (arg1, arg2))
  ApiC(pb_XML_SetStartNamespaceDeclHandler, (arg1, arg2))
  ApiC(pb_XML_SetUnknownEncodingHandler, (arg1, arg2, arg3))
  ApiC(pb_XML_SetUnparsedEntityDeclHandler, (arg1, arg2))
  ApiC(pb_XML_SetUserData, (arg1, arg2))
  ApiC(pb_XML_SetXmlDeclHandler, (arg1, arg2))
  ApiC(pb_XML_StopParser, (arg1, arg2))
  ApiC(pb_XML_UseForeignDTD, (arg1, arg2))
  ApiC(pb_XML_UseParserAsHandlerArg, (arg1))
EndImport