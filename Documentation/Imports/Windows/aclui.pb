XIncludeFile "common.pbi"

Import "aclui.lib"
       Api(CreateSecurityPage, (arg1), 4)
       Api(EditSecurity, (arg1, arg2), 8)
EndImport
