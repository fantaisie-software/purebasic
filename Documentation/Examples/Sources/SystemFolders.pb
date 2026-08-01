;
; ------------------------------------------------------------
;
;   PureBasic - All system folders in Windows (Windows only)
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

CompilerIf #PB_Compiler_OS <> #PB_OS_Windows
  CompilerError "This example is Windows only"
CompilerEndIf

Import "Shell32.lib"
  SHGetKnownFolderPath(*rfid.Guid, dwFlags, hToken, ppszPath)
EndImport

; Global LibShell32 = OpenLibrary(#PB_Any, "Shell32.dll")
; Prototype SHGetKnownFolderPath(*rfid.Guid, dwFlags, hToken, ppszPath)
; Global SHGetKnownFolderPath.SHGetKnownFolderPath = GetFunction(LibShell32, "SHGetKnownFolderPath")

#KF_FLAG_DEFAULT = $00000000
#KF_FLAG_FORCE_APP_DATA_REDIRECTION = $00080000
#KF_FLAG_RETURN_FILTER_REDIRECTION_TARGET = $00040000
#KF_FLAG_FORCE_PACKAGE_REDIRECTION = $00020000
#KF_FLAG_NO_PACKAGE_REDIRECTION = $00010000
#KF_FLAG_FORCE_APPCONTAINER_REDIRECTION = $00020000
#KF_FLAG_NO_APPCONTAINER_REDIRECTION = $00010000
#KF_FLAG_CREATE = $00008000
#KF_FLAG_DONT_VERIFY = $00004000
#KF_FLAG_DONT_UNEXPAND = $00002000
#KF_FLAG_NO_ALIAS = $00001000
#KF_FLAG_INIT = $00000800
#KF_FLAG_DEFAULT_PATH = $00000400
#KF_FLAG_NOT_PARENT_RELATIVE = $00000200
#KF_FLAG_SIMPLE_IDLIST = $00000100
#KF_FLAG_ALIAS_ONLY = $80000000

Macro DEFINE_KNOWN_FOLDER(ID, l1, w1, w2, b1, b2, b3, b4, b5, b6, b7, b8)
  Global ID.Guid  
  ID\Data1 = l1: ID\Data2 = w1: ID\Data3 = w2
  ID\Data4[0] = b1: ID\Data4[1] = b2: ID\Data4[2] = b3: ID\Data4[3] = b4: ID\Data4[4] = b5: ID\Data4[5] = b6: ID\Data4[6] = b7: ID\Data4[7] = b8 
  ;   DataSection: ID: Data.l l1: Data.w w1, w2: Data.b b1, b2, b3, b4, b5, b6, b7, b8: EndDataSection
EndMacro

; {D20BEEC4-5CA8-4905-AE3B-BF251EA09B53}
DEFINE_KNOWN_FOLDER(FOLDERID_NetworkFolder,             $D20BEEC4, $5CA8, $4905, $AE, $3B, $BF, $25, $1E, $A0, $9B, $53)
; {0AC0837C-BBF8-452A-850D-79D08E667CA7}
DEFINE_KNOWN_FOLDER(FOLDERID_ComputerFolder,            $0AC0837C, $BBF8, $452A, $85, $0D, $79, $D0, $8E, $66, $7C, $A7)
; {4D9F7874-4E0C-4904-967B-40B0D20C3E4B}
DEFINE_KNOWN_FOLDER(FOLDERID_InternetFolder,            $4D9F7874, $4E0C, $4904, $96, $7B, $40, $B0, $D2, $0C, $3E, $4B)
; {82A74AEB-AEB4-465C-A014-D097EE346D63}
DEFINE_KNOWN_FOLDER(FOLDERID_ControlPanelFolder,        $82A74AEB, $AEB4, $465C, $A0, $14, $D0, $97, $EE, $34, $6D, $63)
; {76FC4E2D-D6AD-4519-A663-37BD56068185}
DEFINE_KNOWN_FOLDER(FOLDERID_PrintersFolder,            $76FC4E2D, $D6AD, $4519, $A6, $63, $37, $BD, $56, $06, $81, $85)
; {43668BF8-C14E-49B2-97C9-747784D784B7}
DEFINE_KNOWN_FOLDER(FOLDERID_SyncManagerFolder,         $43668BF8, $C14E, $49B2, $97, $C9, $74, $77, $84, $D7, $84, $B7)
; {0F214138-B1D3-4a90-BBA9-27CBC0C5389A}
DEFINE_KNOWN_FOLDER(FOLDERID_SyncSetupFolder,           $f214138, $b1d3, $4a90, $bb, $a9, $27, $cb, $c0, $c5, $38, $9a)
; {4bfefb45-347d-4006-a5be-ac0cb0567192}
DEFINE_KNOWN_FOLDER(FOLDERID_ConflictFolder,            $4bfefb45, $347d, $4006, $a5, $be, $ac, $0c, $b0, $56, $71, $92)
; {289a9a43-be44-4057-a41b-587a76d7e7f9}
DEFINE_KNOWN_FOLDER(FOLDERID_SyncResultsFolder,         $289a9a43, $be44, $4057, $a4, $1b, $58, $7a, $76, $d7, $e7, $f9)
; {B7534046-3ECB-4C18-BE4E-64CD4CB7D6AC}
DEFINE_KNOWN_FOLDER(FOLDERID_RecycleBinFolder,          $B7534046, $3ECB, $4C18, $BE, $4E, $64, $CD, $4C, $B7, $D6, $AC)
; {6F0CD92B-2E97-45D1-88FF-B0D186B8DEDD}
DEFINE_KNOWN_FOLDER(FOLDERID_ConnectionsFolder,         $6F0CD92B, $2E97, $45D1, $88, $FF, $B0, $D1, $86, $B8, $DE, $DD)
; {FD228CB7-AE11-4AE3-864C-16F3910AB8FE}
DEFINE_KNOWN_FOLDER(FOLDERID_Fonts,                     $FD228CB7, $AE11, $4AE3, $86, $4C, $16, $F3, $91, $0A, $B8, $FE)
; {B4BFCC3A-DB2C-424C-B029-7FE99A87C641}
DEFINE_KNOWN_FOLDER(FOLDERID_Desktop,                   $B4BFCC3A, $DB2C, $424C, $B0, $29, $7F, $E9, $9A, $87, $C6, $41)
; {B97D20BB-F46A-4C97-BA10-5E3608430854}
DEFINE_KNOWN_FOLDER(FOLDERID_Startup,                   $B97D20BB, $F46A, $4C97, $BA, $10, $5E, $36, $08, $43, $08, $54)
; {A77F5D77-2E2B-44C3-A6A2-ABA601054A51}
DEFINE_KNOWN_FOLDER(FOLDERID_Programs,                  $A77F5D77, $2E2B, $44C3, $A6, $A2, $AB, $A6, $01, $05, $4A, $51)
; {625B53C3-AB48-4EC1-BA1F-A1EF4146FC19}
DEFINE_KNOWN_FOLDER(FOLDERID_StartMenu,                 $625B53C3, $AB48, $4EC1, $BA, $1F, $A1, $EF, $41, $46, $FC, $19)
; {AE50C081-EBD2-438A-8655-8A092E34987A}
DEFINE_KNOWN_FOLDER(FOLDERID_Recent,                    $AE50C081, $EBD2, $438A, $86, $55, $8A, $09, $2E, $34, $98, $7A)
; {8983036C-27C0-404B-8F08-102D10DCFD74}
DEFINE_KNOWN_FOLDER(FOLDERID_SendTo,                    $8983036C, $27C0, $404B, $8F, $08, $10, $2D, $10, $DC, $FD, $74)
; {FDD39AD0-238F-46AF-ADB4-6C85480369C7}
DEFINE_KNOWN_FOLDER(FOLDERID_Documents,                 $FDD39AD0, $238F, $46AF, $AD, $B4, $6C, $85, $48, $03, $69, $C7)
; {1777F761-68AD-4D8A-87BD-30B759FA33DD}
DEFINE_KNOWN_FOLDER(FOLDERID_Favorites,                 $1777F761, $68AD, $4D8A, $87, $BD, $30, $B7, $59, $FA, $33, $DD)
; {C5ABBF53-E17F-4121-8900-86626FC2C973}
DEFINE_KNOWN_FOLDER(FOLDERID_NetHood,                   $C5ABBF53, $E17F, $4121, $89, $00, $86, $62, $6F, $C2, $C9, $73)
; {9274BD8D-CFD1-41C3-B35E-B13F55A758F4}
DEFINE_KNOWN_FOLDER(FOLDERID_PrintHood,                 $9274BD8D, $CFD1, $41C3, $B3, $5E, $B1, $3F, $55, $A7, $58, $F4)
; {A63293E8-664E-48DB-A079-DF759E0509F7}
DEFINE_KNOWN_FOLDER(FOLDERID_Templates,                 $A63293E8, $664E, $48DB, $A0, $79, $DF, $75, $9E, $05, $09, $F7)
; {82A5EA35-D9CD-47C5-9629-E15D2F714E6E}
DEFINE_KNOWN_FOLDER(FOLDERID_CommonStartup,             $82A5EA35, $D9CD, $47C5, $96, $29, $E1, $5D, $2F, $71, $4E, $6E)
; {0139D44E-6AFE-49F2-8690-3DAFCAE6FFB8}
DEFINE_KNOWN_FOLDER(FOLDERID_CommonPrograms,            $0139D44E, $6AFE, $49F2, $86, $90, $3D, $AF, $CA, $E6, $FF, $B8)
; {A4115719-D62E-491D-AA7C-E74B8BE3B067}
DEFINE_KNOWN_FOLDER(FOLDERID_CommonStartMenu,           $A4115719, $D62E, $491D, $AA, $7C, $E7, $4B, $8B, $E3, $B0, $67)
; {C4AA340D-F20F-4863-AFEF-F87EF2E6BA25}
DEFINE_KNOWN_FOLDER(FOLDERID_PublicDesktop,             $C4AA340D, $F20F, $4863, $AF, $EF, $F8, $7E, $F2, $E6, $BA, $25)
; {62AB5D82-FDC1-4DC3-A9DD-070D1D495D97}
DEFINE_KNOWN_FOLDER(FOLDERID_ProgramData,               $62AB5D82, $FDC1, $4DC3, $A9, $DD, $07, $0D, $1D, $49, $5D, $97)
; {B94237E7-57AC-4347-9151-B08C6C32D1F7}
DEFINE_KNOWN_FOLDER(FOLDERID_CommonTemplates,           $B94237E7, $57AC, $4347, $91, $51, $B0, $8C, $6C, $32, $D1, $F7)
; {ED4824AF-DCE4-45A8-81E2-FC7965083634}
DEFINE_KNOWN_FOLDER(FOLDERID_PublicDocuments,           $ED4824AF, $DCE4, $45A8, $81, $E2, $FC, $79, $65, $08, $36, $34)
; {3EB685DB-65F9-4CF6-A03A-E3EF65729F3D}
DEFINE_KNOWN_FOLDER(FOLDERID_RoamingAppData,            $3EB685DB, $65F9, $4CF6, $A0, $3A, $E3, $EF, $65, $72, $9F, $3D)
; {F1B32785-6FBA-4FCF-9D55-7B8E7F157091}
DEFINE_KNOWN_FOLDER(FOLDERID_LocalAppData,              $F1B32785, $6FBA, $4FCF, $9D, $55, $7B, $8E, $7F, $15, $70, $91)
; {A520A1A4-1780-4FF6-BD18-167343C5AF16}
DEFINE_KNOWN_FOLDER(FOLDERID_LocalAppDataLow,           $A520A1A4, $1780, $4FF6, $BD, $18, $16, $73, $43, $C5, $AF, $16)
; {352481E8-33BE-4251-BA85-6007CAEDCF9D}
DEFINE_KNOWN_FOLDER(FOLDERID_InternetCache,             $352481E8, $33BE, $4251, $BA, $85, $60, $07, $CA, $ED, $CF, $9D)
; {2B0F765D-C0E9-4171-908E-08A611B84FF6}
DEFINE_KNOWN_FOLDER(FOLDERID_Cookies,                   $2B0F765D, $C0E9, $4171, $90, $8E, $08, $A6, $11, $B8, $4F, $F6)
; {D9DC8A3B-B784-432E-A781-5A1130A75963}
DEFINE_KNOWN_FOLDER(FOLDERID_History,                   $D9DC8A3B, $B784, $432E, $A7, $81, $5A, $11, $30, $A7, $59, $63)
; {1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}
DEFINE_KNOWN_FOLDER(FOLDERID_System,                    $1AC14E77, $02E7, $4E5D, $B7, $44, $2E, $B1, $AE, $51, $98, $B7)
; {D65231B0-B2F1-4857-A4CE-A8E7C6EA7D27}
DEFINE_KNOWN_FOLDER(FOLDERID_SystemX86,                 $D65231B0, $B2F1, $4857, $A4, $CE, $A8, $E7, $C6, $EA, $7D, $27)
; {F38BF404-1D43-42F2-9305-67DE0B28FC23}
DEFINE_KNOWN_FOLDER(FOLDERID_Windows,                   $F38BF404, $1D43, $42F2, $93, $05, $67, $DE, $0B, $28, $FC, $23)
; {5E6C858F-0E22-4760-9AFE-EA3317B67173}
DEFINE_KNOWN_FOLDER(FOLDERID_Profile,                   $5E6C858F, $0E22, $4760, $9A, $FE, $EA, $33, $17, $B6, $71, $73)
; {33E28130-4E1E-4676-835A-98395C3BC3BB}
DEFINE_KNOWN_FOLDER(FOLDERID_Pictures,                  $33E28130, $4E1E, $4676, $83, $5A, $98, $39, $5C, $3B, $C3, $BB)
; {7C5A40EF-A0FB-4BFC-874A-C0F2E0B9FA8E}
DEFINE_KNOWN_FOLDER(FOLDERID_ProgramFilesX86,           $7C5A40EF, $A0FB, $4BFC, $87, $4A, $C0, $F2, $E0, $B9, $FA, $8E)
; {DE974D24-D9C6-4D3E-BF91-F4455120B917}
DEFINE_KNOWN_FOLDER(FOLDERID_ProgramFilesCommonX86,     $DE974D24, $D9C6, $4D3E, $BF, $91, $F4, $45, $51, $20, $B9, $17)
; {6D809377-6AF0-444b-8957-A3773F02200E}
DEFINE_KNOWN_FOLDER(FOLDERID_ProgramFilesX64,           $6d809377, $6af0, $444b, $89, $57, $a3, $77, $3f, $02, $20, $0e )
; {6365D5A7-0F0D-45e5-87F6-0DA56B6A4F7D}
DEFINE_KNOWN_FOLDER(FOLDERID_ProgramFilesCommonX64,     $6365d5a7, $f0d, $45e5, $87, $f6, $d, $a5, $6b, $6a, $4f, $7d )
; {905e63b6-c1bf-494e-b29c-65b732d3d21a}
DEFINE_KNOWN_FOLDER(FOLDERID_ProgramFiles,              $905e63b6, $c1bf, $494e, $b2, $9c, $65, $b7, $32, $d3, $d2, $1a)
; {F7F1ED05-9F6D-47A2-AAAE-29D317C6F066}
DEFINE_KNOWN_FOLDER(FOLDERID_ProgramFilesCommon,        $F7F1ED05, $9F6D, $47A2, $AA, $AE, $29, $D3, $17, $C6, $F0, $66)
; {5cd7aee2-2219-4a67-b85d-6c9ce15660cb}
DEFINE_KNOWN_FOLDER(FOLDERID_UserProgramFiles,          $5cd7aee2, $2219, $4a67, $b8, $5d, $6c, $9c, $e1, $56, $60, $cb)
; {bcbd3057-ca5c-4622-b42d-bc56db0ae516}
DEFINE_KNOWN_FOLDER(FOLDERID_UserProgramFilesCommon,    $bcbd3057, $ca5c, $4622, $b4, $2d, $bc, $56, $db, $0a, $e5, $16)
; {724EF170-A42D-4FEF-9F26-B60E846FBA4F}
DEFINE_KNOWN_FOLDER(FOLDERID_AdminTools,                $724EF170, $A42D, $4FEF, $9F, $26, $B6, $0E, $84, $6F, $BA, $4F)
; {D0384E7D-BAC3-4797-8F14-CBA229B392B5}
DEFINE_KNOWN_FOLDER(FOLDERID_CommonAdminTools,          $D0384E7D, $BAC3, $4797, $8F, $14, $CB, $A2, $29, $B3, $92, $B5)
; {4BD8D571-6D19-48D3-BE97-422220080E43}
DEFINE_KNOWN_FOLDER(FOLDERID_Music,                     $4BD8D571, $6D19, $48D3, $BE, $97, $42, $22, $20, $08, $0E, $43)
; {18989B1D-99B5-455B-841C-AB7C74E4DDFC}
DEFINE_KNOWN_FOLDER(FOLDERID_Videos,                    $18989B1D, $99B5, $455B, $84, $1C, $AB, $7C, $74, $E4, $DD, $FC)
; {C870044B-F49E-4126-A9C3-B52A1FF411E8}
DEFINE_KNOWN_FOLDER(FOLDERID_Ringtones,                 $C870044B, $F49E, $4126, $A9, $C3, $B5, $2A, $1F, $F4, $11, $E8)
; {B6EBFB86-6907-413C-9AF7-4FC2ABF07CC5}
DEFINE_KNOWN_FOLDER(FOLDERID_PublicPictures,            $B6EBFB86, $6907, $413C, $9A, $F7, $4F, $C2, $AB, $F0, $7C, $C5)
; {3214FAB5-9757-4298-BB61-92A9DEAA44FF}
DEFINE_KNOWN_FOLDER(FOLDERID_PublicMusic,               $3214FAB5, $9757, $4298, $BB, $61, $92, $A9, $DE, $AA, $44, $FF)
; {2400183A-6185-49FB-A2D8-4A392A602BA3}
DEFINE_KNOWN_FOLDER(FOLDERID_PublicVideos,              $2400183A, $6185, $49FB, $A2, $D8, $4A, $39, $2A, $60, $2B, $A3)
; {E555AB60-153B-4D17-9F04-A5FE99FC15EC}
DEFINE_KNOWN_FOLDER(FOLDERID_PublicRingtones,           $E555AB60, $153B, $4D17, $9F, $04, $A5, $FE, $99, $FC, $15, $EC)
; {8AD10C31-2ADB-4296-A8F7-E4701232C972}
DEFINE_KNOWN_FOLDER(FOLDERID_ResourceDir,               $8AD10C31, $2ADB, $4296, $A8, $F7, $E4, $70, $12, $32, $C9, $72)
; {2A00375E-224C-49DE-B8D1-440DF7EF3DDC}
DEFINE_KNOWN_FOLDER(FOLDERID_LocalizedResourcesDir,     $2A00375E, $224C, $49DE, $B8, $D1, $44, $0D, $F7, $EF, $3D, $DC)
; {C1BAE2D0-10DF-4334-BEDD-7AA20B227A9D}
DEFINE_KNOWN_FOLDER(FOLDERID_CommonOEMLinks,            $C1BAE2D0, $10DF, $4334, $BE, $DD, $7A, $A2, $0B, $22, $7A, $9D)
; {9E52AB10-F80D-49DF-ACB8-4330F5687855}
DEFINE_KNOWN_FOLDER(FOLDERID_CDBurning,                 $9E52AB10, $F80D, $49DF, $AC, $B8, $43, $30, $F5, $68, $78, $55)
; {0762D272-C50A-4BB0-A382-697DCD729B80}
DEFINE_KNOWN_FOLDER(FOLDERID_UserProfiles,              $0762D272, $C50A, $4BB0, $A3, $82, $69, $7D, $CD, $72, $9B, $80)
; {DE92C1C7-837F-4F69-A3BB-86E631204A23}
DEFINE_KNOWN_FOLDER(FOLDERID_Playlists,                 $DE92C1C7, $837F, $4F69, $A3, $BB, $86, $E6, $31, $20, $4A, $23)
; {15CA69B3-30EE-49C1-ACE1-6B5EC372AFB5}
DEFINE_KNOWN_FOLDER(FOLDERID_SamplePlaylists,           $15CA69B3, $30EE, $49C1, $AC, $E1, $6B, $5E, $C3, $72, $AF, $B5)
; {B250C668-F57D-4EE1-A63C-290EE7D1AA1F}
DEFINE_KNOWN_FOLDER(FOLDERID_SampleMusic,               $B250C668, $F57D, $4EE1, $A6, $3C, $29, $0E, $E7, $D1, $AA, $1F)
; {C4900540-2379-4C75-844B-64E6FAF8716B}
DEFINE_KNOWN_FOLDER(FOLDERID_SamplePictures,            $C4900540, $2379, $4C75, $84, $4B, $64, $E6, $FA, $F8, $71, $6B)
; {859EAD94-2E85-48AD-A71A-0969CB56A6CD}
DEFINE_KNOWN_FOLDER(FOLDERID_SampleVideos,              $859EAD94, $2E85, $48AD, $A7, $1A, $09, $69, $CB, $56, $A6, $CD)
; {69D2CF90-FC33-4FB7-9A0C-EBB0F0FCB43C}
DEFINE_KNOWN_FOLDER(FOLDERID_PhotoAlbums,               $69D2CF90, $FC33, $4FB7, $9A, $0C, $EB, $B0, $F0, $FC, $B4, $3C)
; {DFDF76A2-C82A-4D63-906A-5644AC457385}
DEFINE_KNOWN_FOLDER(FOLDERID_Public,                    $DFDF76A2, $C82A, $4D63, $90, $6A, $56, $44, $AC, $45, $73, $85)
; {df7266ac-9274-4867-8d55-3bd661de872d}
DEFINE_KNOWN_FOLDER(FOLDERID_ChangeRemovePrograms,      $df7266ac, $9274, $4867, $8d, $55, $3b, $d6, $61, $de, $87, $2d)
; {a305ce99-f527-492b-8b1a-7e76fa98d6e4}
DEFINE_KNOWN_FOLDER(FOLDERID_AppUpdates,                $a305ce99, $f527, $492b, $8b, $1a, $7e, $76, $fa, $98, $d6, $e4)
; {de61d971-5ebc-4f02-a3a9-6c82895e5c04}
DEFINE_KNOWN_FOLDER(FOLDERID_AddNewPrograms,            $de61d971, $5ebc, $4f02, $a3, $a9, $6c, $82, $89, $5e, $5c, $04)
; {374DE290-123F-4565-9164-39C4925E467B}
DEFINE_KNOWN_FOLDER(FOLDERID_Downloads,                 $374de290, $123f, $4565, $91, $64, $39, $c4, $92, $5e, $46, $7b)
; {3D644C9B-1FB8-4f30-9B45-F670235F79C0}
DEFINE_KNOWN_FOLDER(FOLDERID_PublicDownloads,           $3d644c9b, $1fb8, $4f30, $9b, $45, $f6, $70, $23, $5f, $79, $c0)
; {7d1d3a04-debb-4115-95cf-2f29da2920da}
DEFINE_KNOWN_FOLDER(FOLDERID_SavedSearches,             $7d1d3a04, $debb, $4115, $95, $cf, $2f, $29, $da, $29, $20, $da)
; {52a4f021-7b75-48a9-9f6b-4b87a210bc8f}
DEFINE_KNOWN_FOLDER(FOLDERID_QuickLaunch,               $52a4f021, $7b75, $48a9, $9f, $6b, $4b, $87, $a2, $10, $bc, $8f)
; {56784854-C6CB-462b-8169-88E350ACB882}
DEFINE_KNOWN_FOLDER(FOLDERID_Contacts,                  $56784854, $c6cb, $462b, $81, $69, $88, $e3, $50, $ac, $b8, $82)
; {A75D362E-50FC-4fb7-AC2C-A8BEAA314493}
DEFINE_KNOWN_FOLDER(FOLDERID_SidebarParts,              $a75d362e, $50fc, $4fb7, $ac, $2c, $a8, $be, $aa, $31, $44, $93)
; {7B396E54-9EC5-4300-BE0A-2482EBAE1A26}
DEFINE_KNOWN_FOLDER(FOLDERID_SidebarDefaultParts,       $7b396e54, $9ec5, $4300, $be, $a, $24, $82, $eb, $ae, $1a, $26)
; {DEBF2536-E1A8-4c59-B6A2-414586476AEA}
DEFINE_KNOWN_FOLDER(FOLDERID_PublicGameTasks,           $debf2536, $e1a8, $4c59, $b6, $a2, $41, $45, $86, $47, $6a, $ea)
; {054FAE61-4DD8-4787-80B6-090220C4B700}
DEFINE_KNOWN_FOLDER(FOLDERID_GameTasks,                 $54fae61, $4dd8, $4787, $80, $b6, $9, $2, $20, $c4, $b7, $0)
; {4C5C32FF-BB9D-43b0-B5B4-2D72E54EAAA4}
DEFINE_KNOWN_FOLDER(FOLDERID_SavedGames,                $4c5c32ff, $bb9d, $43b0, $b5, $b4, $2d, $72, $e5, $4e, $aa, $a4)
; {CAC52C1A-B53D-4edc-92D7-6B2E8AC19434} - deprecated
DEFINE_KNOWN_FOLDER(FOLDERID_Games,                     $cac52c1a, $b53d, $4edc, $92, $d7, $6b, $2e, $8a, $c1, $94, $34)
; {98ec0e18-2098-4d44-8644-66979315a281}
DEFINE_KNOWN_FOLDER(FOLDERID_SEARCH_MAPI,               $98ec0e18, $2098, $4d44, $86, $44, $66, $97, $93, $15, $a2, $81)
; {ee32e446-31ca-4aba-814f-a5ebd2fd6d5e}
DEFINE_KNOWN_FOLDER(FOLDERID_SEARCH_CSC,                $ee32e446, $31ca, $4aba, $81, $4f, $a5, $eb, $d2, $fd, $6d, $5e)
; {bfb9d5e0-c6a9-404c-b2b2-ae6db6af4968}
DEFINE_KNOWN_FOLDER(FOLDERID_Links,                     $bfb9d5e0, $c6a9, $404c, $b2, $b2, $ae, $6d, $b6, $af, $49, $68)
; {f3ce0f7c-4901-4acc-8648-d5d44b04ef8f}
DEFINE_KNOWN_FOLDER(FOLDERID_UsersFiles,                $f3ce0f7c, $4901, $4acc, $86, $48, $d5, $d4, $4b, $04, $ef, $8f)
; {A302545D-DEFF-464b-ABE8-61C8648D939B}
DEFINE_KNOWN_FOLDER(FOLDERID_UsersLibraries,            $a302545d, $deff, $464b, $ab, $e8, $61, $c8, $64, $8d, $93, $9b)
; {190337d1-b8ca-4121-a639-6d472d16972a}
DEFINE_KNOWN_FOLDER(FOLDERID_SearchHome,                $190337d1, $b8ca, $4121, $a6, $39, $6d, $47, $2d, $16, $97, $2a)
; {2C36C0AA-5812-4b87-BFD0-4CD0DFB19B39}
DEFINE_KNOWN_FOLDER(FOLDERID_OriginalImages,            $2C36C0AA, $5812, $4b87, $bf, $d0, $4c, $d0, $df, $b1, $9b, $39)
; {7b0db17d-9cd2-4a93-9733-46cc89022e7c}
DEFINE_KNOWN_FOLDER(FOLDERID_DocumentsLibrary,          $7b0db17d, $9cd2, $4a93, $97, $33, $46, $cc, $89, $02, $2e, $7c)
; {2112AB0A-C86A-4ffe-A368-0DE96E47012E}
DEFINE_KNOWN_FOLDER(FOLDERID_MusicLibrary,              $2112ab0a, $c86a, $4ffe, $a3, $68, $d, $e9, $6e, $47, $1, $2e)
; {A990AE9F-A03B-4e80-94BC-9912D7504104}
DEFINE_KNOWN_FOLDER(FOLDERID_PicturesLibrary,           $a990ae9f, $a03b, $4e80, $94, $bc, $99, $12, $d7, $50, $41, $4)
; {491E922F-5643-4af4-A7EB-4E7A138D8174}
DEFINE_KNOWN_FOLDER(FOLDERID_VideosLibrary,             $491e922f, $5643, $4af4, $a7, $eb, $4e, $7a, $13, $8d, $81, $74)
; {1A6FDBA2-F42D-4358-A798-B74D745926C5}
DEFINE_KNOWN_FOLDER(FOLDERID_RecordedTVLibrary,         $1a6fdba2, $f42d, $4358, $a7, $98, $b7, $4d, $74, $59, $26, $c5)
; {52528A6B-B9E3-4add-B60D-588C2DBA842D}
DEFINE_KNOWN_FOLDER(FOLDERID_HomeGroup,                 $52528a6b, $b9e3, $4add, $b6, $d, $58, $8c, $2d, $ba, $84, $2d)
; {9B74B6A3-0DFD-4f11-9E78-5F7800F2E772}
DEFINE_KNOWN_FOLDER(FOLDERID_HomeGroupCurrentUser,      $9b74b6a3, $dfd, $4f11, $9e, $78, $5f, $78, $0, $f2, $e7, $72)
; {5CE4A5E9-E4EB-479D-B89F-130C02886155}
DEFINE_KNOWN_FOLDER(FOLDERID_DeviceMetadataStore,       $5ce4a5e9, $e4eb, $479d, $b8, $9f, $13, $0c, $02, $88, $61, $55)
; {1B3EA5DC-B587-4786-B4EF-BD1DC332AEAE}
DEFINE_KNOWN_FOLDER(FOLDERID_Libraries,                 $1b3ea5dc, $b587, $4786, $b4, $ef, $bd, $1d, $c3, $32, $ae, $ae)
; {48daf80b-e6cf-4f4e-b800-0e69d84ee384}
DEFINE_KNOWN_FOLDER(FOLDERID_PublicLibraries,           $48daf80b, $e6cf, $4f4e, $b8, $00, $0e, $69, $d8, $4e, $e3, $84)
; {9e3995ab-1f9c-4f13-b827-48b24b6c7174}
DEFINE_KNOWN_FOLDER(FOLDERID_UserPinned,                $9e3995ab, $1f9c, $4f13, $b8, $27, $48, $b2, $4b, $6c, $71, $74)
; {bcb5256f-79f6-4cee-b725-dc34e402fd46}
DEFINE_KNOWN_FOLDER(FOLDERID_ImplicitAppShortcuts,      $bcb5256f, $79f6, $4cee, $b7, $25, $dc, $34, $e4, $2, $fd, $46)
; {008ca0b1-55b4-4c56-b8a8-4de4b299d3be}
DEFINE_KNOWN_FOLDER(FOLDERID_AccountPictures,           $008ca0b1, $55b4, $4c56, $b8, $a8, $4d, $e4, $b2, $99, $d3, $be)
; {0482af6c-08f1-4c34-8c90-e17ec98b1e17}
DEFINE_KNOWN_FOLDER(FOLDERID_PublicUserTiles,           $0482af6c, $08f1, $4c34, $8c, $90, $e1, $7e, $c9, $8b, $1e, $17)
; {1e87508d-89c2-42f0-8a7e-645a0f50ca58}
DEFINE_KNOWN_FOLDER(FOLDERID_AppsFolder,                $1e87508d, $89c2, $42f0, $8a, $7e, $64, $5a, $0f, $50, $ca, $58)
; {F26305EF-6948-40B9-B255-81453D09C785}
DEFINE_KNOWN_FOLDER(FOLDERID_StartMenuAllPrograms,      $f26305ef, $6948, $40b9, $b2, $55, $81, $45, $3d, $9, $c7, $85)
; {A440879F-87A0-4F7D-B700-0207B966194A}
DEFINE_KNOWN_FOLDER(FOLDERID_CommonStartMenuPlaces,     $a440879f, $87a0, $4f7d, $b7, $0, $2, $7, $b9, $66, $19, $4a)
; {A3918781-E5F2-4890-B3D9-A7E54332328C}
DEFINE_KNOWN_FOLDER(FOLDERID_ApplicationShortcuts,      $a3918781, $e5f2, $4890, $b3, $d9, $a7, $e5, $43, $32, $32, $8c)
; {00BCFC5A-ED94-4e48-96A1-3F6217F21990}
DEFINE_KNOWN_FOLDER(FOLDERID_RoamingTiles,              $bcfc5a, $ed94, $4e48, $96, $a1, $3f, $62, $17, $f2, $19, $90)
; {AAA8D5A5-F1D6-4259-BAA8-78E7EF60835E}
DEFINE_KNOWN_FOLDER(FOLDERID_RoamedTileImages,          $aaa8d5a5, $f1d6, $4259, $ba, $a8, $78, $e7, $ef, $60, $83, $5e)
; {b7bede81-df94-4682-a7d8-57a52620b86f}
DEFINE_KNOWN_FOLDER(FOLDERID_Screenshots,               $b7bede81, $df94, $4682, $a7, $d8, $57, $a5, $26, $20, $b8, $6f)
; {AB5FB87B-7CE2-4F83-915D-550846C9537B}
DEFINE_KNOWN_FOLDER(FOLDERID_CameraRoll,                $ab5fb87b, $7ce2, $4f83, $91, $5d, $55, $8, $46, $c9, $53, $7b)
; {A52BBA46-E9E1-435f-B3D9-28DAA648C0F6} - deprecated
; Same GUID as FOLDERID_OneDrive
DEFINE_KNOWN_FOLDER(FOLDERID_SkyDrive,                  $a52bba46, $e9e1, $435f, $b3, $d9, $28, $da, $a6, $48, $c0, $f6)
; {A52BBA46-E9E1-435f-B3D9-28DAA648C0F6}
; Same GUID as FOLDERID_SkyDrive
DEFINE_KNOWN_FOLDER(FOLDERID_OneDrive,                  $a52bba46, $e9e1, $435f, $b3, $d9, $28, $da, $a6, $48, $c0, $f6)
; {24D89E24-2F19-4534-9DDE-6A6671FBB8FE}
DEFINE_KNOWN_FOLDER(FOLDERID_SkyDriveDocuments,         $24d89e24, $2f19, $4534, $9d, $de, $6a, $66, $71, $fb, $b8, $fe)
; {339719B5-8C47-4894-94C2-D8F77ADD44A6}
DEFINE_KNOWN_FOLDER(FOLDERID_SkyDrivePictures,          $339719b5, $8c47, $4894, $94, $c2, $d8, $f7, $7a, $dd, $44, $a6)
; {C3F2459E-80D6-45DC-BFEF-1F769F2BE730}
DEFINE_KNOWN_FOLDER(FOLDERID_SkyDriveMusic,             $c3f2459e, $80d6, $45dc, $bf, $ef, $1f, $76, $9f, $2b, $e7, $30)
; {767E6811-49CB-4273-87C2-20F355E1085B}
DEFINE_KNOWN_FOLDER(FOLDERID_SkyDriveCameraRoll,        $767e6811, $49cb, $4273, $87, $c2, $20, $f3, $55, $e1, $08, $5b)
; {0D4C3DB6-03A3-462F-A0E6-08924C41B5D4}
DEFINE_KNOWN_FOLDER(FOLDERID_SearchHistory,             $0d4c3db6, $03a3, $462f, $a0, $e6, $08, $92, $4c, $41, $b5, $d4)
; {7E636BFE-DFA9-4D5E-B456-D7B39851D8A9}
DEFINE_KNOWN_FOLDER(FOLDERID_SearchTemplates,           $7e636bfe, $dfa9, $4d5e, $b4, $56, $d7, $b3, $98, $51, $d8, $a9)
; {2B20DF75-1EDA-4039-8097-38798227D5B7}
DEFINE_KNOWN_FOLDER(FOLDERID_CameraRollLibrary,         $2b20df75, $1eda, $4039, $80, $97, $38, $79, $82, $27, $d5, $b7)
; {3B193882-D3AD-4eab-965A-69829D1FB59F}
DEFINE_KNOWN_FOLDER(FOLDERID_SavedPictures,             $3b193882, $d3ad, $4eab, $96, $5a, $69, $82, $9d, $1f, $b5, $9f)
; {E25B5812-BE88-4bd9-94B0-29233477B6C3}
DEFINE_KNOWN_FOLDER(FOLDERID_SavedPicturesLibrary,      $e25b5812, $be88, $4bd9, $94, $b0, $29, $23, $34, $77, $b6, $c3)
; {12D4C69E-24AD-4923-BE19-31321C43A767}
DEFINE_KNOWN_FOLDER(FOLDERID_RetailDemo,                $12d4c69e, $24ad, $4923, $be, $19, $31, $32, $1c, $43, $a7, $67)
; {1C2AC1DC-4358-4B6C-9733-AF21156576F0}
DEFINE_KNOWN_FOLDER(FOLDERID_Device,                    $1C2AC1DC, $4358, $4B6C, $97, $33, $AF, $21, $15, $65, $76, $F0)
; {DBE8E08E-3053-4BBC-B183-2A7B2B191E59}
DEFINE_KNOWN_FOLDER(FOLDERID_DevelopmentFiles,          $dbe8e08e, $3053, $4bbc, $b1, $83, $2a, $7b, $2b, $19, $1e, $59)
; {31C0DD25-9439-4F12-BF41-7FF4EDA38722}
DEFINE_KNOWN_FOLDER(FOLDERID_Objects3D,                 $31c0dd25, $9439, $4f12, $bf, $41, $7f, $f4, $ed, $a3, $87, $22)
; {EDC0FE71-98D8-4F4A-B920-C8DC133CB165}
DEFINE_KNOWN_FOLDER(FOLDERID_AppCaptures,               $edc0fe71, $98d8, $4f4a, $b9, $20, $c8, $dc, $13, $3c, $b1, $65)
; {f42ee2d3-909f-4907-8871-4c22fc0bf756}
DEFINE_KNOWN_FOLDER(FOLDERID_LocalDocuments,            $f42ee2d3, $909f, $4907, $88, $71, $4c, $22, $fc, $0b, $f7, $56)
; {0ddd015d-b06c-45d5-8c4c-f59713854639 }
DEFINE_KNOWN_FOLDER(FOLDERID_LocalPictures,             $0ddd015d, $b06c, $45d5, $8c, $4c, $f5, $97, $13, $85, $46, $39)
; {35286a68-3c57-41a1-bbb1-0eae73d76c95}
DEFINE_KNOWN_FOLDER(FOLDERID_LocalVideos,               $35286a68, $3c57, $41a1, $bb, $b1, $0e, $ae, $73, $d7, $6c, $95)
; {a0c69a99-21c8-4671-8703-7934162fcf1d}
DEFINE_KNOWN_FOLDER(FOLDERID_LocalMusic,                $a0c69a99, $21c8, $4671, $87, $03, $79, $34, $16, $2f, $cf, $1d)
; {7d83ee9b-2244-4e70-b1f5-5393042af1e4}
DEFINE_KNOWN_FOLDER(FOLDERID_LocalDownloads,            $7d83ee9b, $2244, $4e70, $b1, $f5, $53, $93, $04, $2a, $f1, $e4)
; {2f8b40c2-83ed-48ee-b383-a1f157ec6f9a}
DEFINE_KNOWN_FOLDER(FOLDERID_RecordedCalls,             $2f8b40c2, $83ed, $48ee, $b3, $83, $a1, $f1, $57, $ec, $6f, $9a)
; {7ad67899-66af-43ba-9156-6aad42e6c596}
DEFINE_KNOWN_FOLDER(FOLDERID_AllAppMods,                $7ad67899, $66af, $43ba, $91, $56, $6a, $ad, $42, $e6, $c5, $96)
; {3db40b20-2a30-4dbe-917e-771dd21dd099}
DEFINE_KNOWN_FOLDER(FOLDERID_CurrentAppMods,            $3db40b20, $2a30, $4dbe, $91, $7e, $77, $1d, $d2, $1d, $d0, $99)
; {B2C5E279-7ADD-439F-B28C-C41FE1BBF672}
DEFINE_KNOWN_FOLDER(FOLDERID_AppDataDesktop,               $b2c5e279, $7add, $439f, $b2, $8c, $c4, $1f, $e1, $bb, $f6, $72)
; {7BE16610-1F7F-44AC-BFF0-83E15F2FFCA1}
DEFINE_KNOWN_FOLDER(FOLDERID_AppDataDocuments,             $7be16610, $1f7f, $44ac, $bf, $f0, $83, $e1, $5f, $2f, $fc, $a1)
; {7CFBEFBC-DE1F-45AA-B843-A542AC536CC9}
DEFINE_KNOWN_FOLDER(FOLDERID_AppDataFavorites,             $7cfbefbc, $de1f, $45aa, $b8, $43, $a5, $42, $ac, $53, $6c, $c9)
; {559D40A3-A036-40FA-AF61-84CB430A4D34}
DEFINE_KNOWN_FOLDER(FOLDERID_AppDataProgramData,           $559d40a3, $a036, $40fa, $af, $61, $84, $cb, $43, $a, $4d, $34)

Procedure.s KnownFolderPath(*id.Guid, Flags = #KF_FLAG_RETURN_FILTER_REDIRECTION_TARGET)
  Protected *p, path.s
  SHGetKnownFolderPath(*id, Flags, 0, @*p)
  If *p
    path = PeekS(*p)
    CoTaskMemFree_(*p)
  EndIf
  ProcedureReturn path
EndProcedure

Procedure.s KnownFolderPathS(Guid.s, Flags = #KF_FLAG_RETURN_FILTER_REDIRECTION_TARGET)
  Protected g.Guid, *p, path.s
  If IIDFromString_(Guid, g) = #S_OK
    SHGetKnownFolderPath(@g, Flags, 0, @*p)
    If *p
      path = PeekS(*p)
      CoTaskMemFree_(*p)
    EndIf
  EndIf
  ProcedureReturn path
EndProcedure

Debug "FOLDERID_AccountPictures: " + KnownFolderPath(FOLDERID_AccountPictures)
Debug "FOLDERID_AddNewPrograms: " + KnownFolderPath(FOLDERID_AddNewPrograms)
Debug "FOLDERID_AdminTools: " + KnownFolderPath(FOLDERID_AdminTools)
Debug "FOLDERID_AllAppMods: " + KnownFolderPath(FOLDERID_AllAppMods)
Debug "FOLDERID_AppCaptures: " + KnownFolderPath(FOLDERID_AppCaptures)
Debug "FOLDERID_AppDataDesktop: " + KnownFolderPath(FOLDERID_AppDataDesktop)
Debug "FOLDERID_AppDataDocuments: " + KnownFolderPath(FOLDERID_AppDataDocuments)
Debug "FOLDERID_AppDataFavorites: " + KnownFolderPath(FOLDERID_AppDataFavorites)
Debug "FOLDERID_AppDataProgramData: " + KnownFolderPath(FOLDERID_AppDataProgramData)
Debug "FOLDERID_ApplicationShortcuts: " + KnownFolderPath(FOLDERID_ApplicationShortcuts)
Debug "FOLDERID_AppsFolder: " + KnownFolderPath(FOLDERID_AppsFolder)
Debug "FOLDERID_AppUpdates: " + KnownFolderPath(FOLDERID_AppUpdates)
Debug "FOLDERID_CameraRoll: " + KnownFolderPath(FOLDERID_CameraRoll)
Debug "FOLDERID_CameraRollLibrary: " + KnownFolderPath(FOLDERID_CameraRollLibrary)
Debug "FOLDERID_CDBurning: " + KnownFolderPath(FOLDERID_CDBurning)
Debug "FOLDERID_ChangeRemovePrograms: " + KnownFolderPath(FOLDERID_ChangeRemovePrograms)
Debug "FOLDERID_CommonAdminTools: " + KnownFolderPath(FOLDERID_CommonAdminTools)
Debug "FOLDERID_CommonOEMLinks: " + KnownFolderPath(FOLDERID_CommonOEMLinks)
Debug "FOLDERID_CommonPrograms: " + KnownFolderPath(FOLDERID_CommonPrograms)
Debug "FOLDERID_CommonStartMenu: " + KnownFolderPath(FOLDERID_CommonStartMenu)
Debug "FOLDERID_CommonStartMenuPlaces: " + KnownFolderPath(FOLDERID_CommonStartMenuPlaces)
Debug "FOLDERID_CommonStartup: " + KnownFolderPath(FOLDERID_CommonStartup)
Debug "FOLDERID_CommonTemplates: " + KnownFolderPath(FOLDERID_CommonTemplates)
Debug "FOLDERID_ComputerFolder: " + KnownFolderPath(FOLDERID_ComputerFolder)
Debug "FOLDERID_ConflictFolder: " + KnownFolderPath(FOLDERID_ConflictFolder)
Debug "FOLDERID_ConnectionsFolder: " + KnownFolderPath(FOLDERID_ConnectionsFolder)
Debug "FOLDERID_Contacts: " + KnownFolderPath(FOLDERID_Contacts)
Debug "FOLDERID_ControlPanelFolder: " + KnownFolderPath(FOLDERID_ControlPanelFolder)
Debug "FOLDERID_Cookies: " + KnownFolderPath(FOLDERID_Cookies)
Debug "FOLDERID_CurrentAppMods: " + KnownFolderPath(FOLDERID_CurrentAppMods)
Debug "FOLDERID_Desktop: " + KnownFolderPath(FOLDERID_Desktop)
Debug "FOLDERID_DevelopmentFiles: " + KnownFolderPath(FOLDERID_DevelopmentFiles)
Debug "FOLDERID_Device: " + KnownFolderPath(FOLDERID_Device)
Debug "FOLDERID_DeviceMetadataStore: " + KnownFolderPath(FOLDERID_DeviceMetadataStore)
Debug "FOLDERID_Documents: " + KnownFolderPath(FOLDERID_Documents)
Debug "FOLDERID_DocumentsLibrary: " + KnownFolderPath(FOLDERID_DocumentsLibrary)
Debug "FOLDERID_Downloads: " + KnownFolderPath(FOLDERID_Downloads)
Debug "FOLDERID_Favorites: " + KnownFolderPath(FOLDERID_Favorites)
Debug "FOLDERID_Fonts: " + KnownFolderPath(FOLDERID_Fonts)
Debug "FOLDERID_Games: " + KnownFolderPath(FOLDERID_Games)
Debug "FOLDERID_GameTasks: " + KnownFolderPath(FOLDERID_GameTasks)
Debug "FOLDERID_History: " + KnownFolderPath(FOLDERID_History)
Debug "FOLDERID_HomeGroup: " + KnownFolderPath(FOLDERID_HomeGroup)
Debug "FOLDERID_HomeGroupCurrentUser: " + KnownFolderPath(FOLDERID_HomeGroupCurrentUser)
Debug "FOLDERID_ImplicitAppShortcuts: " + KnownFolderPath(FOLDERID_ImplicitAppShortcuts)
Debug "FOLDERID_InternetCache: " + KnownFolderPath(FOLDERID_InternetCache)
Debug "FOLDERID_InternetFolder: " + KnownFolderPath(FOLDERID_InternetFolder)
Debug "FOLDERID_Libraries: " + KnownFolderPath(FOLDERID_Libraries)
Debug "FOLDERID_Links: " + KnownFolderPath(FOLDERID_Links)
Debug "FOLDERID_LocalAppData: " + KnownFolderPath(FOLDERID_LocalAppData)
Debug "FOLDERID_LocalAppDataLow: " + KnownFolderPath(FOLDERID_LocalAppDataLow)
Debug "FOLDERID_LocalDocuments: " + KnownFolderPath(FOLDERID_LocalDocuments)
Debug "FOLDERID_LocalDownloads: " + KnownFolderPath(FOLDERID_LocalDownloads)
Debug "FOLDERID_LocalizedResourcesDir: " + KnownFolderPath(FOLDERID_LocalizedResourcesDir)
Debug "FOLDERID_LocalMusic: " + KnownFolderPath(FOLDERID_LocalMusic)
Debug "FOLDERID_LocalPictures: " + KnownFolderPath(FOLDERID_LocalPictures)
Debug "FOLDERID_LocalVideos: " + KnownFolderPath(FOLDERID_LocalVideos)
Debug "FOLDERID_Music: " + KnownFolderPath(FOLDERID_Music)
Debug "FOLDERID_MusicLibrary: " + KnownFolderPath(FOLDERID_MusicLibrary)
Debug "FOLDERID_NetHood: " + KnownFolderPath(FOLDERID_NetHood)
Debug "FOLDERID_NetworkFolder: " + KnownFolderPath(FOLDERID_NetworkFolder)
Debug "FOLDERID_Objects3D: " + KnownFolderPath(FOLDERID_Objects3D)
Debug "FOLDERID_OneDrive: " + KnownFolderPath(FOLDERID_OneDrive)
Debug "FOLDERID_OriginalImages: " + KnownFolderPath(FOLDERID_OriginalImages)
Debug "FOLDERID_PhotoAlbums: " + KnownFolderPath(FOLDERID_PhotoAlbums)
Debug "FOLDERID_Pictures: " + KnownFolderPath(FOLDERID_Pictures)
Debug "FOLDERID_PicturesLibrary: " + KnownFolderPath(FOLDERID_PicturesLibrary)
Debug "FOLDERID_Playlists: " + KnownFolderPath(FOLDERID_Playlists)
Debug "FOLDERID_PrintersFolder: " + KnownFolderPath(FOLDERID_PrintersFolder)
Debug "FOLDERID_PrintHood: " + KnownFolderPath(FOLDERID_PrintHood)
Debug "FOLDERID_Profile: " + KnownFolderPath(FOLDERID_Profile)
Debug "FOLDERID_ProgramData: " + KnownFolderPath(FOLDERID_ProgramData)
Debug "FOLDERID_ProgramFiles: " + KnownFolderPath(FOLDERID_ProgramFiles)
Debug "FOLDERID_ProgramFilesCommon: " + KnownFolderPath(FOLDERID_ProgramFilesCommon)
Debug "FOLDERID_ProgramFilesCommonX64: " + KnownFolderPath(FOLDERID_ProgramFilesCommonX64)
Debug "FOLDERID_ProgramFilesCommonX86: " + KnownFolderPath(FOLDERID_ProgramFilesCommonX86)
Debug "FOLDERID_ProgramFilesX64: " + KnownFolderPath(FOLDERID_ProgramFilesX64)
Debug "FOLDERID_ProgramFilesX86: " + KnownFolderPath(FOLDERID_ProgramFilesX86)
Debug "FOLDERID_Programs: " + KnownFolderPath(FOLDERID_Programs)
Debug "FOLDERID_Public: " + KnownFolderPath(FOLDERID_Public)
Debug "FOLDERID_PublicDesktop: " + KnownFolderPath(FOLDERID_PublicDesktop)
Debug "FOLDERID_PublicDocuments: " + KnownFolderPath(FOLDERID_PublicDocuments)
Debug "FOLDERID_PublicDownloads: " + KnownFolderPath(FOLDERID_PublicDownloads)
Debug "FOLDERID_PublicGameTasks: " + KnownFolderPath(FOLDERID_PublicGameTasks)
Debug "FOLDERID_PublicLibraries: " + KnownFolderPath(FOLDERID_PublicLibraries)
Debug "FOLDERID_PublicMusic: " + KnownFolderPath(FOLDERID_PublicMusic)
Debug "FOLDERID_PublicPictures: " + KnownFolderPath(FOLDERID_PublicPictures)
Debug "FOLDERID_PublicRingtones: " + KnownFolderPath(FOLDERID_PublicRingtones)
Debug "FOLDERID_PublicUserTiles: " + KnownFolderPath(FOLDERID_PublicUserTiles)
Debug "FOLDERID_PublicVideos: " + KnownFolderPath(FOLDERID_PublicVideos)
Debug "FOLDERID_QuickLaunch: " + KnownFolderPath(FOLDERID_QuickLaunch)
Debug "FOLDERID_Recent: " + KnownFolderPath(FOLDERID_Recent)
Debug "FOLDERID_RecordedCalls: " + KnownFolderPath(FOLDERID_RecordedCalls)
Debug "FOLDERID_RecordedTVLibrary: " + KnownFolderPath(FOLDERID_RecordedTVLibrary)
Debug "FOLDERID_RecycleBinFolder: " + KnownFolderPath(FOLDERID_RecycleBinFolder)
Debug "FOLDERID_ResourceDir: " + KnownFolderPath(FOLDERID_ResourceDir)
Debug "FOLDERID_RetailDemo: " + KnownFolderPath(FOLDERID_RetailDemo)
Debug "FOLDERID_Ringtones: " + KnownFolderPath(FOLDERID_Ringtones)
Debug "FOLDERID_RoamedTileImages: " + KnownFolderPath(FOLDERID_RoamedTileImages)
Debug "FOLDERID_RoamingAppData: " + KnownFolderPath(FOLDERID_RoamingAppData)
Debug "FOLDERID_RoamingTiles: " + KnownFolderPath(FOLDERID_RoamingTiles)
Debug "FOLDERID_SampleMusic: " + KnownFolderPath(FOLDERID_SampleMusic)
Debug "FOLDERID_SamplePictures: " + KnownFolderPath(FOLDERID_SamplePictures)
Debug "FOLDERID_SamplePlaylists: " + KnownFolderPath(FOLDERID_SamplePlaylists)
Debug "FOLDERID_SampleVideos: " + KnownFolderPath(FOLDERID_SampleVideos)
Debug "FOLDERID_SavedGames: " + KnownFolderPath(FOLDERID_SavedGames)
Debug "FOLDERID_SavedPictures: " + KnownFolderPath(FOLDERID_SavedPictures)
Debug "FOLDERID_SavedPicturesLibrary: " + KnownFolderPath(FOLDERID_SavedPicturesLibrary)
Debug "FOLDERID_SavedSearches: " + KnownFolderPath(FOLDERID_SavedSearches)
Debug "FOLDERID_Screenshots: " + KnownFolderPath(FOLDERID_Screenshots)
Debug "FOLDERID_SEARCH_CSC: " + KnownFolderPath(FOLDERID_SEARCH_CSC)
Debug "FOLDERID_SEARCH_MAPI: " + KnownFolderPath(FOLDERID_SEARCH_MAPI)
Debug "FOLDERID_SearchHistory: " + KnownFolderPath(FOLDERID_SearchHistory)
Debug "FOLDERID_SearchHome: " + KnownFolderPath(FOLDERID_SearchHome)
Debug "FOLDERID_SearchTemplates: " + KnownFolderPath(FOLDERID_SearchTemplates)
Debug "FOLDERID_SendTo: " + KnownFolderPath(FOLDERID_SendTo)
Debug "FOLDERID_SidebarDefaultParts: " + KnownFolderPath(FOLDERID_SidebarDefaultParts)
Debug "FOLDERID_SidebarParts: " + KnownFolderPath(FOLDERID_SidebarParts)
Debug "FOLDERID_SkyDrive: " + KnownFolderPath(FOLDERID_SkyDrive)
Debug "FOLDERID_SkyDriveCameraRoll: " + KnownFolderPath(FOLDERID_SkyDriveCameraRoll)
Debug "FOLDERID_SkyDriveDocuments: " + KnownFolderPath(FOLDERID_SkyDriveDocuments)
Debug "FOLDERID_SkyDriveMusic: " + KnownFolderPath(FOLDERID_SkyDriveMusic)
Debug "FOLDERID_SkyDrivePictures: " + KnownFolderPath(FOLDERID_SkyDrivePictures)
Debug "FOLDERID_StartMenu: " + KnownFolderPath(FOLDERID_StartMenu)
Debug "FOLDERID_StartMenuAllPrograms: " + KnownFolderPath(FOLDERID_StartMenuAllPrograms)
Debug "FOLDERID_Startup: " + KnownFolderPath(FOLDERID_Startup)
Debug "FOLDERID_SyncManagerFolder: " + KnownFolderPath(FOLDERID_SyncManagerFolder)
Debug "FOLDERID_SyncResultsFolder: " + KnownFolderPath(FOLDERID_SyncResultsFolder)
Debug "FOLDERID_SyncSetupFolder: " + KnownFolderPath(FOLDERID_SyncSetupFolder)
Debug "FOLDERID_System: " + KnownFolderPath(FOLDERID_System)
Debug "FOLDERID_SystemX86: " + KnownFolderPath(FOLDERID_SystemX86)
Debug "FOLDERID_Templates: " + KnownFolderPath(FOLDERID_Templates)
Debug "FOLDERID_UserPinned: " + KnownFolderPath(FOLDERID_UserPinned)
Debug "FOLDERID_UserProfiles: " + KnownFolderPath(FOLDERID_UserProfiles)
Debug "FOLDERID_UserProgramFiles: " + KnownFolderPath(FOLDERID_UserProgramFiles)
Debug "FOLDERID_UserProgramFilesCommon: " + KnownFolderPath(FOLDERID_UserProgramFilesCommon)
Debug "FOLDERID_UsersFiles: " + KnownFolderPath(FOLDERID_UsersFiles)
Debug "FOLDERID_UsersLibraries: " + KnownFolderPath(FOLDERID_UsersLibraries)
Debug "FOLDERID_Videos: " + KnownFolderPath(FOLDERID_Videos)
Debug "FOLDERID_VideosLibrary: " + KnownFolderPath(FOLDERID_VideosLibrary)
Debug "FOLDERID_Windows: " + KnownFolderPath(FOLDERID_Windows)

Debug ""
Debug "BEWARE about FOLDERID_ProgramFiles, FOLDERID_ProgramFilesX86, FOLDERID_ProgramFilesX64"
Debug "---------------------------------------------------------------------------------------"
Debug "OS     App    KNOWNFOLDERID Default Path CSIDL Equivalent"
Debug "32 bit 32 bit FOLDERID_ProgramFiles %SystemDrive%\Program Files CSIDL_PROGRAM_FILES"
Debug "32 bit 32 bit FOLDERID_ProgramFilesX86 %SystemDrive%\Program Files CSIDL_PROGRAM_FILESX86"
Debug "32 bit 32 bit FOLDERID_ProgramFilesX64 (not supported under 32-bit operating systems) Not applicable Not applicable"
Debug "64 bit 64 bit FOLDERID_ProgramFiles %SystemDrive%\Program Files CSIDL_PROGRAM_FILES"
Debug "64 bit 64 bit FOLDERID_ProgramFilesX86 %SystemDrive%\Program Files (x86) CSIDL_PROGRAM_FILESX86"
Debug "64 bit 64 bit FOLDERID_ProgramFilesX64 %SystemDrive%\Program Files None"
Debug "64 bit 32 bit FOLDERID_ProgramFiles %SystemDrive%\Program Files (x86) CSIDL_PROGRAM_FILES"
Debug "64 bit 32 bit FOLDERID_ProgramFilesX86 %SystemDrive%\Program Files (x86) CSIDL_PROGRAM_FILESX86"
Debug "64 bit 32 bit FOLDERID_ProgramFilesX64 (not supported for 32-bit applications) Not applicable Not applicable"

Debug ""
Debug "BEWARE about FOLDERID_ProgramFilesCommon"
Debug "-----------------------------------------"
Debug "OS     App    KNOWNFOLDERID Default Path CSIDL Equivalent"
Debug "32 bit 32 bit FOLDERID_ProgramFilesCommon %ProgramFiles%\Common Files CSIDL_PROGRAM_FILES_COMMON"
Debug "32 bit 32 bit FOLDERID_ProgramFilesCommonX86 %ProgramFiles%\Common Files CSIDL_PROGRAM_FILES_COMMONX86"
Debug "32 bit 32 bit FOLDERID_ProgramFilesCommonX64 (undefined) Not applicable Not applicable"
Debug "64 bit 64 bit FOLDERID_ProgramFilesCommon %ProgramFiles%\Common Files CSIDL_PROGRAM_FILES_COMMON"
Debug "64 bit 64 bit FOLDERID_ProgramFilesCommonX86 %ProgramFiles(x86)%\Common Files CSIDL_PROGRAM_FILES_COMMONX86"
Debug "64 bit 64 bit FOLDERID_ProgramFilesCommonX64 %ProgramFiles%\Common Files None"
Debug "64 bit 32 bit FOLDERID_ProgramFilesCommon %ProgramFiles(x86)%\Common Files CSIDL_PROGRAM_FILES_COMMON"
Debug "64 bit 32 bit FOLDERID_ProgramFilesCommonX86 %ProgramFiles(x86)%\Common Files CSIDL_PROGRAM_FILES_COMMONX86"
Debug "64 bit 32 bit FOLDERID_ProgramFilesCommonX64 %ProgramFiles%\Common Files None"

Debug ""
Debug "BEWARE about FOLDERID_System"
Debug "----------------------------"
Debug "OS     App    KNOWNFOLDERID Default Path CSIDL Equivalent"
Debug "32 bit 32 bit FOLDERID_System %windir%\system32 CSIDL_SYSTEM"
Debug "32 bit 32 bit FOLDERID_SystemX86 %windir%\system32 CSIDL_SYSTEMX86"
Debug "64 bit 64 bit FOLDERID_System %windir%\system32 CSIDL_SYSTEM"
Debug "64 bit 64 bit FOLDERID_SystemX86 %windir%\syswow64 CSIDL_SYSTEMX86"
Debug "64 bit 32 bit FOLDERID_System %windir%\system32 CSIDL_SYSTEM"
Debug "64 bit 32 bit FOLDERID_SystemX86 %windir%\syswow64 CSIDL_SYSTEMX86"

Debug ""
Debug "Path Vista and later"
Debug "----------------------------"
Debug "Environment String Example Path"
Debug "%ALLUSERSPROFILE% C:\ProgramData"
Debug "%APPDATA% C:\Users\username\AppData\Roaming"
Debug "%LOCALAPPDATA% C:\Users\username\AppData\Local"
Debug "%ProgramData% C:\ProgramData"
Debug "%ProgramFiles% C:\Program Files"
Debug "%ProgramFiles(x86)% C:\Program Files (x86)"
Debug "%PUBLIC% C:\Users\Public"
Debug "%SystemDrive% C:"
Debug "%USERPROFILE% C:\Users\username"
Debug "%windir% C:\Windows"

Debug ""
Debug "Path Windows XP and earlier"
Debug "----------------------------"
Debug "Environment String Example Path"
Debug "%ALLUSERSPROFILE% C:\Documents and Settings\All Users"
Debug "%APPDATA% C:\Documents and Settings\username\Application Data"
Debug "%ProgramFiles% C:\Program Files"
Debug "%SystemDrive% C:"
Debug "%USERPROFILE% C:\Documents and Settings\username"
Debug "%windir% C:\Windows"
