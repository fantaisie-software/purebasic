; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; Cross-platform help tool: reads the documentation sources (.txt, DocMaker format) directly
; and renders them in a WebViewGadget.
;
; When this file is compiled directly (main file), it runs as a standalone tool (own window,
; HelpTool.ini settings). When included in the IDE, it's embedded in the tools panel via XmlDialogGadget().
;

DeclareModule HelpTool
  #Standalone = #PB_Compiler_IsMainFile

  ; Callbacks used by the IDE to load/run the examples and edit the help sources
  Prototype ProtoOpenCode(File$, Code$, Run) ; File$ is a real file to load, or Code$ is the code to put in a new tab
  Prototype ProtoEditFile(File$, Line)
  Prototype ProtoApplyColors(Gadget)         ; IDE colors/font for the contents tree and the search gadgets
  Prototype.s ProtoColorCode(Code$)          ; IDE syntax highlighting of an example: returns the html code (special characters escaped)
  Global OpenCodeCallback.ProtoOpenCode, EditFileCallback.ProtoEditFile, ApplyColorsCallback.ProtoApplyColors, ColorCodeCallback.ProtoColorCode

  ; Standalone tool
  Declare RunStandalone(HelpLanguage$, HelpOS$)
  Declare CheckSources()
  Declare.s BuildHelp(Source$, Destination$)
  Declare.s BuildHelpZip(Source$, Destination$)

  ; IDE embedding
  Declare Setup(HelpLanguage$, HelpOS$, Source$, UserLibraries$, Examples$)
  Declare SetImages(Back, Forward, Home, Edit, Contents, LoadCode$, RunCode$)
  Declare SetColors(Css$, Color = $008800)
  Declare Create(Window)
  Declare Destroy()
  Declare Resize(Width, Height)
  Declare GadgetEvent(Gadget, Type)
  Declare Timer()
  Declare ShowPage(Name$)
EndDeclareModule


Module HelpTool
  EnableExplicit

  #EventJsMessage   = #PB_Event_FirstCustomValue + 500 ; WebView callback actions are deferred to the event loop
  #ForceIEMode      = #False ; Windows: #True to test the degraded mode (WebGadget/Internet Explorer) even if WebView2 is available
  #Languages$       = "English,French,German"
  #TagSeparators$   = " .,;:()[]{}>@/" + #LF$ + #DQUOTE$ + Chr(160)
  #IdentifierChars$ = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"
  #IEMessageScheme$ = "helptool:" ; IE mode: jsmessage() calls are sent as a navigation to this url scheme

  Structure HelpPage
    Title$
    Name$            ; lowercase: function name, 'lib_' + library file name, or file name
    File$            ; source file, relative to the language (or user library) folder. Empty for the generated pages
    Position.l       ; position of the page in its source file
    Source$          ; page source (DocMaker format)
    Navigation$      ; library function: links to the previous/next functions and to the library index
    List SubPages.i() ; library: its functions (*HelpPage)
    ContentsItem.w   ; item in the contents tree
    UserLib$         ; user library: its name
    LibDestination$  ; user library function: library where it is listed (@LibraryDestination)
  EndStructure

  Structure HelpTag
    Html$            ; html code. $p1, $p2: tag parameters, $lg: rest of the line, $ex: example number, $im: image, $ose: example OS
    ParameterType.b  ; 1: parameter, 2: optional parameter, 3: end of the parameters
    IsTitle.b        ; title tag: the line feeds around it are removed
    Preformatted.w   ; 1: opens a <pre> block, -1: closes it
  EndStructure

  Declare DisplayPage(Name$)

  Global NewMap Tags.HelpTag()
  Global NewList Pages.HelpPage()
  Global NewMap *PageMap.HelpPage()      ; pages by name
  Global NewMap UserLibDestination$()    ; user library function -> library where it is listed
  Global NewList OSSpecificList$()       ; platform-dependant functions: "Function TAB OS TAB Info"
  Global NewMap OSSpecific$()            ; platform-dependant functions: function -> info
  Global NewMap PackFiles()              ; help archive: file -> uncompressed size
  Global NewMap PackTexts$()             ; help archive: text files preloaded by LoadHelp() (see PreloadPackTexts())
  Global NewList History$()
  Global NewList JsMessages$()

  Global Language$, OS$
  Global HelpSource$                     ; help folder, or .zip archive
  Global HelpPath$                       ; help folder (or archive path without the extension), with a final separator
  Global LanguagePath$                   ; language folder ("English/"), relative to HelpPath$
  Global UserLibPath$                    ; user libraries help folder
  Global ExamplesPath$                   ; IDE: examples folder
  Global IsArchive, Pack
  Global *CurrentPage.HelpPage, CurrentPageName$
  Global LastReloadDate.q
  Global IEMode                          ; Windows: WebView2 not available, degraded display in a WebGadget (Internet Explorer)

  ; Page rendering state (see PageToHtml())
  Global RenderHtml$, RenderErrors$, RenderLineBreaks, RenderPreformatted

  ; User interface
  Global HostWindow, Dialog, DialogXML   ; HostWindow: window which contains the help (for the deferred events)
  Global GadgetPanel, GadgetContents, GadgetSearch, GadgetSearchList, GadgetWeb, GadgetHome, GadgetBack, GadgetForward
  Global GadgetLanguage, GadgetOS, GadgetEdit, GadgetSplitter, GadgetRoot, GadgetShowContents = -1
  Global ImageBack, ImageForward, ImageHome, ImageEdit, ImageContents
  Global LoadCodeIcon$ = "&#128194;", RunCodeIcon$ = "&#9654;" ; example buttons (replaced by the IDE icons)
  Global ContentsVisible, SplitterPosition, SplitterBarWidth = -1 ; IDE: contents tree displayed, splitter position, width of its bar (-1: not measured yet)
  Global StandaloneWindow, StandaloneX, StandaloneY, StandaloneWidth, StandaloneHeight

  ; Translations (see InitLanguage())
  Global Text_CommandList$, Text_ReturnValue$, Text_None$, Text_Remarks$, Text_Example$, Text_SeeAlso$, Text_Syntax$, Text_Description$
  Global Text_Overview$, Text_Parameters$, Text_Deprecated$, Text_DeprecatedInfo$, Text_CommandIndex$, Text_Constants$, Text_OSFunctions$
  Global Text_Help$, Text_Contents$, Text_Search$, Text_Home$, Text_Back$, Text_Forward$, Text_Edit$, Text_ShowContents$, Text_Load$, Text_Run$

  ; Page colors (CSS variables), replaced by the IDE theme ones (SetColors())
  Global UserLibColor = $008800 ; user libraries in the contents tree
  Global PageColors$ = ":root {color-scheme: light; --bg:#fed; --text:#000; --titlebg:#ff8; --codebg:#edc; --tablebg:#fff; --optbg:#eee; --border:#0002;" +
                       " --notebg:#f80; --link:#00f; --constant:#a00; --function:#088; --keyword:#088; --userlib:#080;}"

  ; '.nav' is a block: as inline text after the 20pt title, WebKitGTK misses the clicks on its links in a narrow page
  Global PageStyle$ = "body {background-color: var(--bg); color: var(--text); font-family: Arial, Helvetica, sans-serif; font-size: 10pt;margin-left:30px}" +
                      "h2 {position: sticky;z-index: 10;font-size:20pt; font-weight: normal; top:0; text-align: center; background-color:var(--titlebg);padding: 5px; margin:-8px -8px 8px -30px; box-shadow: 0px 5px 5px #00000088;}" +
                      "h3 {margin-left:-20px;}" +
                      "a, a:visited, a:active {font-size: 10pt; color: var(--link);}" +
                      ".nav, .nav a {color: var(--link); font-size: 13px;} .nav {display: block;}" +
                      ".cst {color: var(--constant);} .fct {color: var(--function);} .kw {color: var(--keyword); font-weight: bold;} .ul {color: var(--userlib);}" +
                      ".opt {background-color: var(--optbg);}" +
                      ".note {background-color: var(--notebg);} div.note {font-size: 16px;}" +
                      ".deprecated {padding: 5px; margin: 5px 0px 10px; border: 1px solid var(--border);} .deprecated b {color: #e00;}" +
                      ".found {background-color: #ff0; color: #000;}" +
                      "img {box-shadow: 2px 2px 5px #0008;}" +
                      "button img {box-shadow: none; width: 16px; height: 16px; vertical-align: middle;}" +
                      "pre {overflow: auto; font-family:consolas, Courier, monospace; font-size: 9pt;}" +
                      "pre.ex {position: relative; min-height: 26px; padding: 5px 65px 5px 5px; background-color:var(--codebg);border-style: solid; border-width:1px; border-color:var(--border);}" +
                      "button {box-shadow: 2px 2px 2px #0008;}" +
                      ".butcode {display: flex; position: absolute; top:4px; right:5px; gap:5px; z-index: 1;}" +
                      "table {box-shadow: 2px 2px 3px #0008;background-color: var(--tablebg);}" +
                      "table, th, td {border-collapse: collapse;padding:2px 10px 2px;font-size: 10pt;border-color:var(--border);}" +
                      "table.param {width:100%;  border-spacing: 0px; border-style: none; }" +
                      "table.param td { border-width: 1px; padding: 6px; border-style: solid;  vertical-align: top;}"


  ;- ----- Translations

  Procedure.s Translate(English$, French$, German$)
    Select Language$
      Case "French"
        ProcedureReturn French$
      Case "German"
        ProcedureReturn German$
      Default
        ProcedureReturn English$
    EndSelect
  EndProcedure


  Procedure InitLanguage()
    ; Pages
    Text_CommandList$    = Translate("Command index", "Sommaire des commandes", "Befehlsübersicht")
    Text_ReturnValue$    = Translate("Return value", "Valeur de retour", "Rückgabewert")
    Text_None$           = Translate("None", "Aucune", "Keine")
    Text_Remarks$        = Translate("Remarks", "Remarques", "Bemerkungen")
    Text_Example$        = Translate("Example", "Exemple", "Beispiel")
    Text_SeeAlso$        = Translate("See also", "Voir aussi", "Siehe auch")
    Text_Syntax$         = Translate("Syntax", "Syntaxe", "Syntax")
    Text_Description$    = Translate("Description", "Description", "Beschreibung")
    Text_Overview$       = Translate("General", "Généralités", "Allgemeines")
    Text_Parameters$     = Translate("Parameters", "Paramètres", "Parameter")
    Text_Deprecated$     = Translate("Deprecated", "Dépréciée", "Veraltet")
    Text_DeprecatedInfo$ = Translate("This function is deprecated and may be removed in a future version. It should not be used in newly written code.",
                                     "Cette fonction est dépréciée et sera peut-être supprimée dans une future version. Elle ne doit pas être utilisée dans du nouveau code.",
                                     "Diese Funktion ist veraltet und könnte in späteren Versionen entfernt werden. Sie sollte in neuem Code nicht mehr verwendet werden.")
    Text_CommandIndex$   = Translate("Commands Index", "Index des commandes", "Befehlsindex")
    Text_Constants$      = Translate("PureBasic Constants", "Constantes PureBasic", "PureBasic-Konstanten")
    Text_OSFunctions$    = Translate("Platform-dependant Functions", "Fonctions dépendantes de la plateforme", "Plattformabhängige Funktionen")

    ; User interface
    Text_Help$           = Translate("Help", "Aide", "Hilfe")
    Text_Contents$       = Translate("Contents", "Sommaire", "Inhaltsverzeichnis")
    Text_Search$         = Translate("Search", "Recherche", "Suche")
    Text_Home$           = Translate("Home", "Accueil", "Startseite")
    Text_Back$           = Translate("Back", "Précédent", "Zurück")
    Text_Forward$        = Translate("Forward", "Suivant", "Vorwärts")
    Text_Edit$           = Translate("Edit help source", "Editer la source de l'aide", "Hilfequelle bearbeiten")
    Text_ShowContents$   = Translate("Show/hide the index", "Afficher/masquer le sommaire", "Inhaltsverzeichnis ein-/ausblenden")
    Text_Load$           = Translate("Open", "Ouvrir", "öffnen")
    Text_Run$            = Translate("Run", "Executer", "ausführen")
  EndProcedure


  ;- ----- Strings and files

  ; Mid() reading directly in the string buffer: no copy of the (big) source string
  ;
  Procedure.s PeekMid(*String, Position, Length)
    ProcedureReturn PeekS(*String + (Position - 1) * SizeOf(Character), Length)
  EndProcedure


  Procedure FindStringReverse(String$, StringToFind$, StartPosition = 0)
    Protected Length = Len(StringToFind$), Position = StartPosition

    If Position = 0
      Position = Len(String$)
    EndIf
    While Position > 0 And PeekMid(@String$, Position, Length) <> StringToFind$
      Position - 1
    Wend

    ProcedureReturn Position
  EndProcedure


  ; Returns the text between Before$ and After$, searched after StartPosition (up to the end of the string if After$ isn't found)
  ;
  Procedure.s ExtractBetween(String$, Before$, After$, StartPosition = 0)
    Protected Start, Stop

    Start = FindString(String$, Before$, StartPosition + 1)
    If Start = 0
      ProcedureReturn ""
    EndIf

    Stop = FindString(String$, After$, Start + 1)
    If Stop = 0
      Stop = Len(String$)
    EndIf
    Start + Len(Before$)

    ProcedureReturn PeekMid(@String$, Start, Stop - Start)
  EndProcedure


  Procedure WriteTextFile(FileName$, Text$)
    Protected File

    If FileSize(FileName$) >= 0
      DeleteFile(FileName$)
    EndIf

    File = CreateFile(#PB_Any, FileName$, #PB_UTF8)
    If File = 0
      ProcedureReturn #False
    EndIf
    WriteString(File, Text$)
    CloseFile(File)

    ProcedureReturn #True
  EndProcedure


  Procedure.s ReadTextFile(FileName$, ShowError = #True)
    Protected File, Text$

    File = ReadFile(#PB_Any, FileName$, #PB_UTF8 | #PB_File_SharedRead)
    If File
      ReadStringFormat(File) ; skip the BOM
      Text$ = ReadString(File, #PB_UTF8 | #PB_File_IgnoreEOL)
      CloseFile(File)
    ElseIf ShowError
      MessageRequester(Text_Help$, "Can't load the file: " + FileName$)
    EndIf

    ProcedureReturn Text$
  EndProcedure


  ; Extensions$: ",ext1,ext2," (",," for all the files)
  ;
  Procedure MatchExtension(FileName$, Extensions$)
    If Extensions$ = ",," Or FindString(Extensions$, "," + LCase(GetExtensionPart(FileName$)) + ",")
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure


  Procedure ListFilesRecursive(List Files$(), Directory$, SubDirectory$, Extensions$)
    Protected Directory, Name$

    Directory = ExamineDirectory(#PB_Any, Directory$ + SubDirectory$, "")
    If Directory
      While NextDirectoryEntry(Directory)
        Name$ = DirectoryEntryName(Directory)
        If DirectoryEntryType(Directory) = #PB_DirectoryEntry_Directory
          If Name$ <> "." And Name$ <> ".."
            ListFilesRecursive(Files$(), Directory$, SubDirectory$ + Name$ + "/", Extensions$)
          EndIf
        ElseIf MatchExtension(Name$, Extensions$)
          AddElement(Files$())
          Files$() = SubDirectory$ + Name$
        EndIf
      Wend
      FinishDirectory(Directory)
    EndIf
  EndProcedure


  ; List the files of a directory and its sub-directories, relative to Directory$ ('/' separator)
  ; Extensions$: "txt,html" (empty for all the files)
  ;
  Procedure ListFiles(List Files$(), Directory$, Extensions$ = "")
    ClearList(Files$())
    If Right(Directory$, 1) <> "/" And Right(Directory$, 1) <> "\"
      Directory$ + "/"
    EndIf
    ListFilesRecursive(Files$(), Directory$, "", "," + LCase(Extensions$) + ",")
  EndProcedure


  Procedure MakePath(Path$) ; creates the directory and its parents
    Path$ = RTrim(ReplaceString(Path$, "\", "/"), "/")
    If Path$ = "" Or FileSize(Path$) = -2
      ProcedureReturn #True
    EndIf

    MakePath(GetPathPart(Path$))
    ProcedureReturn CreateDirectory(Path$)
  EndProcedure


  Procedure.s EscapeHtml(Text$, ConvertLineFeeds = #False)
    Text$ = ReplaceString(Text$, "<", "&lt;")
    Text$ = ReplaceString(Text$, ">", "&gt;")
    If ConvertLineFeeds
      Text$ = ReplaceString(Text$, #LF$, "<br>" + #LF$)
    EndIf
    ProcedureReturn Text$
  EndProcedure


  ;- ----- Help source (folder or .zip archive)

  Procedure ReadPackFiles()
    ClearMap(PackFiles())
    If ExaminePack(Pack)
      While NextPackEntry(Pack)
        If PackEntryType(Pack) = #PB_Packer_File
          PackFiles(PackEntryName(Pack)) = PackEntrySize(Pack, #PB_Packer_UncompressedSize)
        EndIf
      Wend
    EndIf
  EndProcedure


  Procedure OpenSource(Source$)
    If IsArchive
      ClosePack(Pack)
      IsArchive = #False
    EndIf

    If LCase(GetExtensionPart(Source$)) = "zip" And FileSize(Source$) > 0
      HelpPath$ = Left(Source$, Len(Source$) - 4)
      UseZipPacker()
      Pack = OpenPack(#PB_Any, Source$)
      If Pack
        IsArchive = #True
        ReadPackFiles()
      EndIf
    Else
      HelpPath$ = Source$
    EndIf

    If Right(HelpPath$, 1) <> "/" And Right(HelpPath$, 1) <> "\"
      HelpPath$ + "/"
    EndIf
  EndProcedure


  ; Name$: file to uncompress, or empty for the current pack entry
  ;
  Procedure.s UncompressPackText(Length, Name$ = "")
    Protected *Buffer, Text$

    *Buffer = AllocateMemory(Length + 2) ; +2: string end for PeekS()
    If *Buffer
      If Name$
        UncompressPackMemory(Pack, *Buffer, Length, Name$)
      Else
        UncompressPackMemory(Pack, *Buffer, Length)
      EndIf
      Text$ = PeekS(*Buffer, -1, #PB_UTF8)
      If Left(Text$, 1) = Chr($FEFF) ; skip the BOM, like ReadStringFormat() does for the files
        Text$ = Mid(Text$, 2)
      EndIf
      FreeMemory(*Buffer)
    EndIf

    ProcedureReturn Text$
  EndProcedure


  ; Uncompresses in one pass the .txt files of Directory$ and of the archive root: a search by
  ; name reopens the archive and reads it from its start, so it's very slow for many files
  ;
  Procedure PreloadPackTexts(Directory$)
    Protected Name$, Length

    ClearMap(PackTexts$())
    If IsArchive And ExaminePack(Pack)
      Length = Len(Directory$)
      While NextPackEntry(Pack)
        Name$ = PackEntryName(Pack)
        If PackEntryType(Pack) = #PB_Packer_File And LCase(GetExtensionPart(Name$)) = "txt" And (Left(Name$, Length) = Directory$ Or FindString(Name$, "/") = 0)
          PackTexts$(Name$) = UncompressPackText(PackEntrySize(Pack, #PB_Packer_UncompressedSize))
        EndIf
      Wend
    EndIf
  EndProcedure


  ; Name$ is relative to the help root
  ;
  Procedure.s ReadHelpFile(Name$, ShowError = #True)
    If IsArchive = #False
      ProcedureReturn ReadTextFile(HelpPath$ + Name$, ShowError)
    EndIf

    If FindMapElement(PackTexts$(), Name$) ; preloaded
      ProcedureReturn PackTexts$()
    EndIf

    If FindMapElement(PackFiles(), Name$) = 0
      If ShowError
        MessageRequester(Text_Help$, "Can't load the file: " + Name$)
      EndIf
      ProcedureReturn ""
    EndIf

    ProcedureReturn UncompressPackText(PackFiles(), Name$)
  EndProcedure


  Procedure ReadHelpBinaryFile(Name$)
    Protected *Buffer, File, Length

    If IsArchive
      If FindMapElement(PackFiles(), Name$)
        Length = PackFiles()
        *Buffer = AllocateMemory(Length)
        If *Buffer
          UncompressPackMemory(Pack, *Buffer, Length, Name$)
        EndIf
      EndIf

    Else
      File = ReadFile(#PB_Any, HelpPath$ + Name$)
      If File
        Length = Lof(File)
        *Buffer = AllocateMemory(Length)
        If *Buffer
          ReadData(File, *Buffer, Length)
        EndIf
        CloseFile(File)
      EndIf
    EndIf

    ProcedureReturn *Buffer
  EndProcedure


  Procedure ListHelpFiles(List Files$(), Directory$, Extensions$)
    Protected Length, Name$

    If IsArchive = #False
      ListFiles(Files$(), HelpPath$ + Directory$, Extensions$)
      ProcedureReturn
    EndIf

    ClearList(Files$())
    Extensions$ = "," + LCase(Extensions$) + ","
    Length = Len(Directory$)
    ForEach PackFiles()
      Name$ = MapKey(PackFiles())
      If Left(Name$, Length) = Directory$ And MatchExtension(Name$, Extensions$)
        AddElement(Files$())
        Files$() = Mid(Name$, Length + 1)
      EndIf
    Next
  EndProcedure


  ;- ----- Help pages

  Procedure.s JsCall(Message$)
    ProcedureReturn "jsmessage(" + #DQUOTE$ + Message$ + #DQUOTE$ + ")"
  EndProcedure


  Procedure AddTag(Name$, ParameterType, IsTitle, Html$)
    Protected *Tag.HelpTag = AddMapElement(Tags(), Name$)

    *Tag\Html$         = Html$
    *Tag\ParameterType = ParameterType
    *Tag\IsTitle       = IsTitle
    If FindString(Html$, "<pre")
      *Tag\Preformatted = 1
    ElseIf FindString(Html$, "</pre")
      *Tag\Preformatted = -1
    EndIf
  EndProcedure


  ; DocMaker tags and their html code
  ;
  Procedure InitTags()
    Protected LoadButton$, RunButton$

    ClearMap(Tags())

    AddTag("linebreak",     0, 0, "<br>")
    AddTag("red",           0, 0, "<font color=Red>$p1</font>")
    AddTag("green",         0, 0, "<font color=Green>$p1</font>")
    AddTag("blue",          0, 0, "<font color=Blue>$p1</font>")
    AddTag("orange",        0, 0, "<font color=Orange>$p1</font>")
    AddTag("bold",          0, 0, "<b>$p1</b>")
    AddTag("underline",     0, 0, "<u>$p1</u>")
    AddTag("constantcolor", 0, 0, "<font class='cst'>$p1</font>")
    AddTag("functioncolor", 0, 0, "<font class='fct'>$p1</font>")
    AddTag("formatif",      0, 0, "$lg")
    AddTag("formatelse",    0, 0, "")
    AddTag("formatendif",   0, 0, "")
    AddTag("html",          0, 0, "")
    AddTag("endhtml",       0, 0, "")
    LoadButton$ = "<button title='" + Text_Load$ + "' onclick='" + JsCall("co:$ex") + "'>" + LoadCodeIcon$ + "</button>"
    RunButton$  = "<button title='" + Text_Run$  + "' onclick='" + JsCall("cr:$ex") + "'>" + RunCodeIcon$  + "</button>"
    AddTag("code",          0, 0, "<pre class='ex'><div class='butcode'>" + LoadButton$ + RunButton$ + "</div>")
    AddTag("endcode",       0, 0, "</pre>")
    AddTag("os",            0, 0, "")
    AddTag("endos",         0, 0, "")
    AddTag("fixedfont",     0, 0, "<pre>")
    AddTag("endfixedfont",  0, 0, "</pre>")
    AddTag("indent",        0, 1, "<blockquote>")
    AddTag("endindent",     0, 1, "</blockquote>")
    AddTag("keyword",       0, 0, "<font class='kw'>$p1</font>")
    AddTag("image",         0, 0, "$im<br>")
    LoadButton$ = "<button title='" + Text_Load$ + "' onclick='" + JsCall("fo:$lg") + "'>" + LoadCodeIcon$ + "</button>"
    RunButton$  = "<button title='" + Text_Run$  + "' onclick='" + JsCall("fr:$lg") + "'>" + RunCodeIcon$  + "</button>"
    AddTag("examplefile",   0, 0, "$ose" + LoadButton$ + " " + RunButton$ + " $lg")

    AddTag("library",           0, 1, "")
    AddTag("section",           0, 1, "<h3>$lg</h3>")
    AddTag("overview",          0, 1, "<h3>" + Text_Overview$ + "</h3>")
    AddTag("commandlist",       0, 1, "<h3>" + Text_CommandList$ + "</h3>")
    AddTag("returnvalue",       3, 1, "<h3>" + Text_ReturnValue$ + "</h3>")
    AddTag("noreturnvalue",     3, 1, "<h3>" + Text_ReturnValue$ + "</h3>" + Text_None$ + ".")
    AddTag("remarks",           3, 1, "<h3>" + Text_Remarks$ + "</h3>")
    AddTag("example",           0, 1, "<h3>" + Text_Example$ + "</h3>")
    AddTag("seealso",           0, 1, "<h3>" + Text_SeeAlso$ + "</h3>")
    AddTag("supportedos",       0, 1, "")
    AddTag("function",          0, 1, "<h3>" + Text_Syntax$ + "</h3><pre>$p1")
    AddTag("syntax",            0, 1, "<h3>" + Text_Syntax$ + "</h3><pre>")
    AddTag("description",       0, 1, "</pre><h3>" + Text_Description$ + "</h3>")
    AddTag("deprecated",        0, 0, "<div class='deprecated'><b>" + Text_Deprecated$ + "</b><br>" + Text_DeprecatedInfo$ + "</div>")
    AddTag("parameter",         1, 1, "")
    AddTag("optionalparameter", 2, 1, "")
    AddTag("noparameters",      3, 1, "")

    AddTag("internetlink",  0, 0, "<a href='$p1'>$p2</a>")
    AddTag("link",          0, 0, "<a href='#' onclick='" + JsCall("lk:$p1") + "'>$p2</a>")
    AddTag("librarylink",   0, 0, "<a href='#' onclick='" + JsCall("lk:lib_$p1") + "'>$p2 </a>")
    AddTag("fastlink",      0, 0, "<a href='#' onclick='" + JsCall("lk:$p1") + "'>$p1 </a>")
    AddTag("referencelink", 0, 0, "<a href='#' onclick='" + JsCall("lk:$p1") + "'>$p2 </a>")
    AddTag("mainguidelink", 0, 0, "<a href='#' onclick='" + JsCall("lk:$p1") + "'>$p2 </a>")
  EndProcedure


  Procedure FindPage(Name$)
    If FindMapElement(*PageMap(), Name$)
      ProcedureReturn *PageMap()
    EndIf
    ProcedureReturn 0
  EndProcedure


  Procedure.s ImageToHtml(Name$) ; the image is embedded in base64
    Protected *Buffer, Html$

    *Buffer = ReadHelpBinaryFile("HelpPictures/" + Name$)
    If *Buffer = 0
      *Buffer = ReadHelpBinaryFile(LanguagePath$ + "Reference/Images/" + Name$)
    EndIf

    If *Buffer
      Html$ = "<img src ='Data:image/" + GetExtensionPart(Name$) + ";base64," + Base64Encoder(*Buffer, MemorySize(*Buffer)) + "' />"
      FreeMemory(*Buffer)
    EndIf

    ProcedureReturn Html$
  EndProcedure


  ; Text$: link text, '$' is replaced by the page title
  ;
  Procedure.s PageLink(Name$, Text$ = "$")
    Protected *Page.HelpPage, Title$

    Name$ = LCase(Name$)
    *Page = FindPage(Name$)
    If *Page
      Title$ = *Page\Title$
    EndIf

    ProcedureReturn "<a href='#' onclick='" + JsCall("lk:" + Name$) + "'>" + ReplaceString(Text$, "$", Title$) + "</a>"
  EndProcedure


  ; Extracts the pages of a source file: a library file is split in one page per function
  ;
  Procedure ExtractPages(File$, IsUserLib = #False)
    Protected Text$, Page$, BaseName$, Name$, Title$, Prefix$, Line$, Function$, FunctionList$, Navigation$, Destination$
    Protected PageCount, Index, Position, Start, Stop, PageStart, PageEnd, IsLastPage
    Protected *LibraryPage.HelpPage, *Page.HelpPage
    NewList Functions$()

    BaseName$ = GetFilePart(File$, #PB_FileSystem_NoExtension)
    If IsUserLib
      Text$ = ReadTextFile(UserLibPath$ + File$)
    Else
      Text$ = ReadHelpFile(LanguagePath$ + File$)
    EndIf

    Start = FindString(Text$, "@Title ")
    If Start = 0
      Start = FindString(Text$, "@Library ")
      Prefix$ = "lib_"
    EndIf
    If Start = 0 ; not a help file (ie: a readme in the user libraries folder)
      ProcedureReturn
    EndIf

    Start = FindString(Text$, " ", Start) + 1
    Stop  = FindString(Text$, #LF$, Start)
    Title$ = Trim(PeekMid(@Text$, Start, Stop - Start))
    PageEnd = Stop + 1

    Repeat
      PageStart = PageEnd
      PageEnd = FindString(Text$, "@Function ", PageStart + 1)
      If PageEnd = 0
        PageEnd = Len(Text$) + 1
        IsLastPage = #True
      EndIf
      Page$ = Mid(Text$, PageStart, PageEnd - PageStart)

      AddElement(Pages())
      If PageCount = 0 ; file header (or the whole file)
        Name$ = Prefix$ + LCase(BaseName$)
        *LibraryPage = @Pages()

      Else ; function: '@Function Result = Name(Parameters)'
        Line$ = Left(Page$, FindString(Page$, #LF$))
        Line$ = ReplaceString(Line$, "(d)", "")
        Line$ = ReplaceString(Line$, "(.d)", "") ; Math library
        Stop  = FindString(Line$, "(")
        Start = FindStringReverse(Line$, " ", Stop)
        Function$ = Mid(Line$, Start + 1, Stop - Start - 1)
        If FindString(Function$, ".")
          Debug "HelpTool: invalid function name: " + Function$
        EndIf
        Title$ = Function$
        Name$  = LCase(Function$)

        Position = FindString(Page$, "@LibraryDestination")
        If Position
          Destination$ = ExtractBetween(Page$, "tion", #LF$, Position)
          Page$ = ReplaceString(Page$, "@LibraryDestination" + Destination$ + #LF$, "")
          UserLibDestination$(Name$) = LCase(Trim(Destination$))
        Else
          Destination$ = ""
        EndIf

        AddElement(Functions$())
        Functions$() = Name$
      EndIf

      Pages()\Title$    = Title$
      Pages()\File$     = File$
      Pages()\Position  = PageStart
      Pages()\Source$   = Page$
      Pages()\Name$     = Name$
      If IsUserLib
        Pages()\UserLib$        = BaseName$
        Pages()\LibDestination$ = Destination$
      EndIf
      *PageMap(Name$) = @Pages()

      PageCount + 1
    Until IsLastPage

    ; Function list of the library, with the user library functions listed in it
    ForEach UserLibDestination$()
      If UserLibDestination$() = LCase(BaseName$)
        AddElement(Functions$())
        Functions$() = MapKey(UserLibDestination$())
      EndIf
    Next
    SortList(Functions$(), #PB_Sort_Ascending)
    ForEach Functions$()
      FunctionList$ + "@@" + Functions$() + #LF$
      AddElement(*LibraryPage\SubPages())
      *LibraryPage\SubPages() = FindPage(Functions$())
    Next
    *LibraryPage\Source$ = ReplaceString(*LibraryPage\Source$, "@CommandList", "@CommandList" + #LF$ + FunctionList$)

    ; Navigation between the functions
    ForEach Functions$()
      Index + 1
      Navigation$ = ""
      If Index > 1
        Navigation$ + "< " + PageLink(Mid(StringField(FunctionList$, Index - 1, #LF$), 3))
      EndIf
      Navigation$ + " | " + PageLink("lib_" + BaseName$, "$ Index") + " | "
      If Index < PageCount - 1
        Navigation$ + PageLink(Mid(StringField(FunctionList$, Index + 1, #LF$), 3)) + " >"
      EndIf

      *Page = FindPage(Functions$())
      If *Page
        *Page\Navigation$ = Navigation$
      EndIf
    Next
  EndProcedure


  Procedure.s IEHtml(Html$) ; IE mode: no CSS variables, no javascript callback
    Protected Variable$, Name$, Value$, i

    ; CSS variables are replaced by their value
    For i = 1 To CountString(PageColors$, ";") + 1
      Variable$ = Trim(StringField(PageColors$, i, ";"))
      If Left(Variable$, 2) = "--"
        Name$  = Trim(StringField(Variable$, 1, ":"))
        Value$ = Trim(RemoveString(StringField(Variable$, 2, ":"), "}"))
        Html$  = ReplaceString(Html$, "var(" + Name$ + ")", Value$)
      EndIf
    Next i

    ; jsmessage() is sent as a navigation to a 'helptool:' url, caught by the navigation callback
    Html$ = ReplaceString(Html$, "onclick='jsmessage(", "onclick='return jsmessage(")
    Html$ = ReplaceString(Html$, "<head>", "<head><meta http-equiv='X-UA-Compatible' content='IE=edge'>" +
                                           "<script>function jsmessage(m) {window.location.href='" + #IEMessageScheme$ + "'+encodeURIComponent(m); return false;}</script>", #PB_String_CaseSensitive, 1, 1)

    ProcedureReturn "<!DOCTYPE html>" + Html$
  EndProcedure


  Procedure SetPageHtml(Html$)
    Html$ = ReplaceString(Html$, "<head>", "<head><meta charset='utf-8'>", #PB_String_CaseSensitive, 1, 1) ; explicit encoding (accents, umlauts)

    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      If IEMode
        SetGadgetItemText(GadgetWeb, #PB_Web_HtmlCode, IEHtml(Html$))
        ProcedureReturn
      EndIf
    CompilerEndIf

    ; Mouse back/forward buttons and Alt+arrows: use our history, not the WebView one (which goes back to an old page, sometimes empty)
    Html$ = ReplaceString(Html$, "<head>", "<head><script>" +
                                           "function nav(e,s) {e.preventDefault(); jsmessage('lk:'+s);}" +
                                           "window.addEventListener('mousedown', function(e) {if (e.button==3 || e.button==4) e.preventDefault();});" +
                                           "window.addEventListener('mouseup', function(e) {if (e.button==3) nav(e,'-'); else if (e.button==4) nav(e,'+');});" +
                                           "window.addEventListener('keydown', function(e) {if ((e.altKey && e.key=='ArrowLeft') || e.key=='BrowserBack') nav(e,'-'); else if ((e.altKey && e.key=='ArrowRight') || e.key=='BrowserForward') nav(e,'+');});" +
                                           "</script>", #PB_String_CaseSensitive, 1, 1)
    SetGadgetItemText(GadgetWeb, #PB_WebView_HtmlCode, Html$)
  EndProcedure


  Procedure AddGeneratedPage(Name$, Title$, Source$)
    LastElement(Pages())
    AddElement(Pages())
    Pages()\Name$   = Name$
    Pages()\Title$  = Title$
    Pages()\Source$ = Source$
    *PageMap(Name$) = @Pages()
  EndProcedure


  Procedure.s OSColor(OSList$, OSName$)
    If FindString(OSList$, "(" + OSName$ + ")")
      ProcedureReturn "bgcolor=#fb0"
    ElseIf FindString(OSList$, OSName$)
      ProcedureReturn "bgcolor=#0f0"
    Else
      ProcedureReturn "bgcolor=#f00"
    EndIf
  EndProcedure


  ; Pages built from the other pages (like DocMaker does)
  ;
  Procedure CreateGeneratedPages()
    Protected Text$, Line$, Key$, Value$, Info$, OSList$, Function$, Library$, Letter$, Constant$, Source$, Char$
    Protected Position, LineStart, Separator, ConstantEnd, *SubPage.HelpPage
    NewList Entries$()
    NewMap ConstantPages$()
    NewMap Seen()

    ; Platform-dependant functions (OSSpecificFunctions.txt)
    ClearList(OSSpecificList$())
    ClearMap(OSSpecific$())
    Text$ = RemoveString(ReadHelpFile("OSSpecificFunctions.txt"), #CR$) + #LF$
    Repeat
      LineStart = Position
      Position = FindString(Text$, #LF$, Position + 1)
      If Position = 0
        Break
      EndIf

      Line$ = Trim(Trim(PeekMid(@Text$, LineStart + 1, Position - LineStart - 1)), #TAB$)
      If Len(Line$) > 0 And Left(Line$, 1) <> ";"
        Separator = FindString(Line$ + ":", ":")
        Key$   = Trim(Left(Line$, Separator - 1))
        Value$ = Trim(Mid(Line$, Separator + 1))
        Select LCase(Key$)
          Case "#library", "#endgroup"
          Case "#startgroup"
            Info$ = Value$
          Default ; 'Function: OS - Info', or 'Function' in a group
            If Value$ <> ""
              Info$ = Value$
            EndIf
            AddElement(OSSpecificList$())
            OSSpecificList$() = Key$ + #TAB$ + ReplaceString(Info$, "-", #TAB$)
            OSSpecific$(LCase(Key$)) = Info$
        EndSelect
      EndIf
    ForEver

    SortList(OSSpecificList$(), #PB_Sort_Ascending | #PB_Sort_NoCase)
    Text$ = "@<table border=1>" + #LF$
    ForEach OSSpecificList$()
      Function$ = StringField(OSSpecificList$(), 1, #TAB$)
      OSList$   = StringField(OSSpecificList$(), 2, #TAB$)
      Info$     = StringField(OSSpecificList$(), 3, #TAB$)
      Text$ + " @<tr> @<td> " + "@@" + Function$ + " @</td> " +
              "@<td " + OSColor(OSList$, "Windows") + "> windows @</td> " +
              "@<td " + OSColor(OSList$, "Linux") + "> Linux @</td> " +
              "@<td " + OSColor(OSList$, "MacOS") + "> Mac @</td> " +
              "@<td> " + Info$ + " @</td> @</tr>" + #LF$
    Next
    Text$ + "@</table>"

    ; Command index, and the PureBasic constants with the pages which use them
    ForEach Pages()
      If Pages()\UserLib$ <> ""
        Continue
      EndIf

      If Left(Pages()\Name$, 4) = "lib_"
        Library$ = Pages()\Title$
        ForEach Pages()\SubPages()
          *SubPage = Pages()\SubPages()
          If *SubPage\UserLib$ = ""
            AddElement(Entries$())
            Entries$() = *SubPage\Title$ + #TAB$ + *SubPage\Name$ + #TAB$ + Library$
          EndIf
        Next
      EndIf

      ; '@#PB_xxx' constants
      Position = 0
      Source$ = Pages()\Source$
      Repeat
        Position = FindString(Source$, "@#PB_", Position + 1)
        If Position = 0
          Break
        EndIf

        ConstantEnd = Position + 1
        Repeat
          ConstantEnd + 1
          Char$ = PeekMid(@Source$, ConstantEnd, 1)
        Until Char$ = "" Or FindString(#IdentifierChars$, Char$) = 0
        Constant$ = PeekMid(@Source$, Position + 1, ConstantEnd - Position - 1)

        If FindMapElement(Seen(), Constant$ + #TAB$ + Pages()\Name$) = 0
          Seen(Constant$ + #TAB$ + Pages()\Name$) = 1
          If FindMapElement(ConstantPages$(), Constant$)
            ConstantPages$() + ", "
          Else
            AddMapElement(ConstantPages$(), Constant$)
          EndIf
          ConstantPages$() + "@@" + Pages()\Name$
        EndIf
      ForEver
    Next

    AddGeneratedPage("osspecific", Text_OSFunctions$, Text$)

    SortList(Entries$(), #PB_Sort_Ascending | #PB_Sort_NoCase)
    Text$ = ""
    Letter$ = ""
    ForEach Entries$()
      If UCase(Left(Entries$(), 1)) <> Letter$
        Letter$ = UCase(Left(Entries$(), 1))
        Text$ + "@Section " + Letter$ + #LF$
      EndIf
      Text$ + "@@" + StringField(Entries$(), 2, #TAB$) + " - " + StringField(Entries$(), 3, #TAB$) + #LF$
    Next
    AddGeneratedPage("commandindex", Text_CommandIndex$, Text$)

    ClearList(Entries$())
    ForEach ConstantPages$()
      AddElement(Entries$())
      Entries$() = MapKey(ConstantPages$())
    Next
    SortList(Entries$(), #PB_Sort_Ascending | #PB_Sort_NoCase)
    Text$ = ""
    Letter$ = ""
    ForEach Entries$()
      If UCase(Mid(Entries$(), 5, 1)) <> Letter$ ; '#PB_x'
        Letter$ = UCase(Mid(Entries$(), 5, 1))
        Text$ + "@Section " + Letter$ + #LF$
      EndIf
      Text$ + "@" + Entries$() + " : " + ConstantPages$(Entries$()) + #LF$
    Next
    AddGeneratedPage("pbconstants", Text_Constants$, Text$)
  EndProcedure


  ; *Parent: parent page of a sub-item (library function)
  ;
  Procedure AddContentsItem(Level, Text$, *Page.HelpPage, *Parent.HelpPage = 0)
    Protected Item, IsUserLib

    IsUserLib = Bool(*Parent And *Page\UserLib$ <> "")
    If IsUserLib
      If *Page\UserLib$ = *Parent\UserLib$
        If *Page\LibDestination$
          Text$ + " (" + *Page\LibDestination$ + ")"
        EndIf
      Else
        Text$ + " (" + *Page\UserLib$ + ")"
      EndIf
    EndIf

    Item = CountGadgetItems(GadgetContents)
    AddGadgetItem(GadgetContents, -1, Text$, 0, Level)
    SetGadgetItemData(GadgetContents, Item, *Page)
    If IsUserLib ; else the gadget color (IDE theme)
      SetGadgetItemColor(GadgetContents, Item, #PB_Gadget_FrontColor, UserLibColor)
    EndIf
  EndProcedure


  ; Loads all the help pages, and fills the contents tree
  ;
  Procedure LoadHelp(EnableUI = #True)
    Protected Text$, Title$, Link$, UserLibLinks$, Position, Level, *Page.HelpPage, *SubPage.HelpPage, *Reference.HelpPage
    NewList Files$()
    NewList UserLibFiles$()
    NewList Contents$()

    ClearMap(*PageMap())
    ClearList(Pages())
    CurrentPageName$ = ""
    LanguagePath$ = Language$ + "/"

    InitTags()

    ; User libraries
    If UserLibPath$ <> "" And FileSize(UserLibPath$) = -2
      ListFiles(Files$(), UserLibPath$, "txt")
      ForEach Files$()
        ExtractPages(Files$(), #True)
      Next
      CopyList(Files$(), UserLibFiles$())
    EndIf

    ; Help sources
    PreloadPackTexts(LanguagePath$)
    ListHelpFiles(Files$(), LanguagePath$, "txt")
    ForEach Files$()
      ExtractPages(Files$())
    Next

    *Reference = FindPage("reference") ; home page, with the contents
    If *Reference = 0
      If EnableUI
        ClearGadgetItems(GadgetContents)
        SetPageHtml("<html><head><style>" + PageColors$ + PageStyle$ + "</style></head><body><h2>" + Text_Help$ + "</h2>" +
                    "Help source not found: <b>" + EscapeHtml(HelpPath$ + LanguagePath$) + "</b></body></html>")
      EndIf
      ProcedureReturn
    EndIf

    CreateGeneratedPages() ; before the contents, which links to them
    ClearMap(PackTexts$()) ; all read: the page sources are in Pages()

    ForEach UserLibFiles$()
      Title$ = GetFilePart(UserLibFiles$(), #PB_FileSystem_NoExtension)
      UserLibLinks$ + "@Link lib_" + LCase(Title$) + " " + #DQUOTE$ + Title$ + #DQUOTE$ + #LF$
    Next
    If UserLibLinks$ = "" ; no user library: no empty section
      *Reference\Source$ = ReplaceString(*Reference\Source$, "@Section User library" + #LF$, "")
    EndIf
    *Reference\Source$ = ReplaceString(*Reference\Source$, "$userlib" + #LF$, UserLibLinks$)

    ; Contents: '@Section Title' and '@Link Page "Title"'
    Text$ = *Reference\Source$
    Repeat
      Position = FindString(Text$, "@", Position + 1)
      If Position = 0
        Break
      EndIf

      Select ExtractBetween(Text$, "@", " ", Position - 1)
        Case "Section"
          AddElement(Contents$())
          Contents$() = ExtractBetween(Text$, "Section ", #LF$, Position)
        Case "Link"
          AddElement(Contents$())
          Contents$() = ExtractBetween(Text$, " " + #DQUOTE$, #DQUOTE$ + #LF$, Position) + #TAB$ + ExtractBetween(Text$, "Link ", " " + #DQUOTE$, Position)
      EndSelect
    ForEver

    If EnableUI
      ClearGadgetItems(GadgetContents)
      HideGadget(GadgetContents, #True)
      ForEach Contents$()
        Title$ = StringField(Contents$(), 1, #TAB$)
        Link$  = StringField(Contents$(), 2, #TAB$)
        *Page = 0
        If Link$ = "" ; section
          Level = 0
        Else
          Level = 1
          *Page = FindPage(Link$)
          If *Page
            *Page\ContentsItem = CountGadgetItems(GadgetContents)
          EndIf
        EndIf
        AddContentsItem(Level, Title$, *Page)

        If *Page
          ForEach *Page\SubPages()
            *SubPage = *Page\SubPages()
            If *SubPage\ContentsItem = 0
              *SubPage\ContentsItem = CountGadgetItems(GadgetContents)
            EndIf
            AddContentsItem(Level + 1, *SubPage\Title$, *SubPage, *Page)
          Next
        EndIf
      Next
      HideGadget(GadgetContents, #False)

      DisplayPage("reference")
    EndIf
  EndProcedure


  ; Highlights the search in the body text, without touching the html tags (links) and the case.
  ; Done in a single pass (FindString() goes through the whole string on each call: too slow on big pages)
  ;
  Procedure.s HighlightSearch(Html$, Search$)
    Protected Result$, LowerHtml$, LowerSearch$, *Start, *Cursor.Character, Position, Copied, Length, InTag

    Search$ = EscapeHtml(Search$)
    Length = Len(Search$)
    If Length = 0
      ProcedureReturn Html$
    EndIf

    Position = FindString(Html$, "<body")
    If Position = 0
      ProcedureReturn Html$
    EndIf

    LowerHtml$   = LCase(Html$) ; case insensitive search, but the original text is kept
    LowerSearch$ = LCase(Search$)
    *Start = @LowerHtml$
    *Cursor = *Start + (Position - 1) * SizeOf(Character)
    Copied = 1 ; start of the part not yet copied
    While *Cursor\c
      If *Cursor\c = '<'
        InTag = #True
      ElseIf *Cursor\c = '>'
        InTag = #False
      ElseIf InTag = #False And CompareMemoryString(*Cursor, @LowerSearch$, #PB_String_CaseSensitive, Length) = #PB_String_Equal ; Search$ has no '<' (escaped): can't overlap a tag
        Position = (*Cursor - *Start) / SizeOf(Character) + 1
        If Position > Copied
          Result$ + PeekMid(@Html$, Copied, Position - Copied)
        EndIf
        Result$ + "<font class='found'>" + PeekMid(@Html$, Position, Length) + "</font>"
        Copied = Position + Length
        *Cursor + (Length - 1) * SizeOf(Character)
      EndIf
      *Cursor + SizeOf(Character)
    Wend

    ProcedureReturn Result$ + PeekS(@Html$ + (Copied - 1) * SizeOf(Character))
  EndProcedure


  ;- ----- Page rendering (DocMaker format -> html)

  Procedure AddError(Message$)
    RenderHtml$   + "<font class='note'>" + Message$ + "</font>"
    RenderErrors$ + Message$ + #LF$
  EndProcedure


  Procedure AppendText(Text$)
    RenderHtml$ + EscapeHtml(Text$, Bool(RenderLineBreaks And RenderPreformatted = 0))
  EndProcedure


  Procedure AppendHtml(Html$)
    RenderHtml$ + Html$
  EndProcedure


  ; Html from a @FormatIf or @HTML block: the images are embedded and the links go through jsmessage()
  ;
  Procedure AppendBlockHtml(Html$)
    Protected Position, Path$, Image$

    Position = 0
    Repeat
      Position = FindString(Html$, "<img", Position + 1)
      If Position = 0
        Break
      EndIf

      Path$  = ExtractBetween(Html$, "src=", ">", Position)
      Image$ = ImageToHtml(GetFilePart(Path$))
      If Image$ <> ""
        Html$ = ReplaceString(Html$, "src=" + Path$ + ">", Image$)
        Position + Len(Image$) - Len(Path$)
      Else
        AddError("image not found:* " + Path$)
      EndIf
    ForEver

    Position = 0
    Repeat
      Position = FindString(Html$, "<a", Position + 1)
      If Position = 0
        Break
      EndIf

      Path$ = ExtractBetween(Html$, "href=", ">", Position)
      If FindString(Path$, "#") = 0
        Html$ = ReplaceString(Html$, "href=" + Path$ + ">", "href='#' onclick='" + JsCall("lk:" + LCase(GetFilePart(Path$, #PB_FileSystem_NoExtension))) + "'>")
      EndIf
    ForEver

    RenderHtml$ + Html$
  EndProcedure


  ; Reads a tag parameter: a word up to one of the Separators$, or a quoted string
  ;
  Procedure.s ReadTagParameter(*Text, *Position.Integer, Separators$ = #TagSeparators$)
    Protected Position = *Position\i, Start, IsQuoted, Parameter$

    While PeekMid(*Text, Position, 1) = " "
      Position + 1
    Wend

    If PeekMid(*Text, Position, 1) = #DQUOTE$
      IsQuoted = #True
      Separators$ = #DQUOTE$
    EndIf

    Start = Position
    Position + 1
    While PeekMid(*Text, Position, 1) <> "" And FindString(Separators$, PeekMid(*Text, Position, 1)) = 0
      Position + 1
    Wend

    If IsQuoted
      Position + 1
      Parameter$ = PeekMid(*Text, Start + 1, Position - Start - 2)
    Else
      Parameter$ = PeekMid(*Text, Start, Position - Start)
    EndIf

    *Position\i = Position
    ProcedureReturn Parameter$
  EndProcedure


  Procedure.s PageToHtml(Name$)
    Protected Text$, LowerText$, Tag$, TagHtml$, Parameter$, Char$, Link$, LinkName$, Image$, OSNote$, Html$, *Page.HelpPage
    Protected Position, TextStart, TagStart, ParameterStart, Found, BlockEnd, i
    Protected ParameterCount, ExampleNumber, ExampleTitleDone, IsTitle, WasTitle

    *CurrentPage = FindPage(LCase(Name$))
    If *CurrentPage = 0
      ProcedureReturn ""
    EndIf

    Text$ = *CurrentPage\Source$
    If Right(Text$, 1) <> #LF$ ; the tags read up to the end of the line ($lg) need it (ie: @ExampleFile at the end of the file)
      Text$ + #LF$
    EndIf

    RenderHtml$ = ""
    RenderErrors$ = ""
    RenderLineBreaks = #False
    RenderPreformatted = 0

    ; Remove the comments
    Repeat
      Position = FindString(Text$, #LF$ + ";")
      If Position = 0 And Left(Text$, 1) <> ";"
        Break
      EndIf
      Text$ = Left(Text$, Position) + Mid(Text$, FindString(Text$ + #LF$, #LF$, Position + 1) + 1)
    ForEver

    Position = 1
    Repeat
      TextStart = Position
      TagStart = FindString(Text$, "@", Position)
      If TagStart = 0
        AppendText(Mid(Text$, Position))
        Break
      EndIf

      ; Tag name: up to the next separator ('@</td>' is a closing html tag)
      Position = TagStart + 1
      Tag$ = ""
      Char$ = PeekMid(@Text$, Position, 1)
      Repeat
        Position + 1
        Tag$ + Char$
        Char$ = PeekMid(@Text$, Position, 1)
      Until (FindString(#TagSeparators$, Char$) And Tag$ + Char$ <> "</") Or Char$ = ""

      Char$ = PeekMid(@Text$, TagStart + 1, 1)
      If Char$ = "@" Or Char$ = "#" ; @@Function and @#Constant: like DocMaker, only letters, digits and '_' (ie: "@@RGB-Funktion", "@@SetGadgetText!")
        Position = TagStart + 2
        While PeekMid(@Text$, Position, 1) <> "" And FindString(#IdentifierChars$, PeekMid(@Text$, Position, 1))
          Position + 1
        Wend
        Tag$ = PeekMid(@Text$, TagStart + 1, Position - TagStart - 1)
      EndIf

      ; Remove the line feeds around the title tags (and @Indent)
      WasTitle = IsTitle
      If FindString("#@<", Char$)
        IsTitle = #False
      EndIf
      If FindMapElement(Tags(), LCase(Tag$))
        IsTitle = Tags()\IsTitle
      EndIf
      If WasTitle And PeekMid(@Text$, TextStart, 1) = #LF$
        TextStart + 1
      EndIf
      If IsTitle And PeekMid(@Text$, TagStart - 1, 1) = #LF$
        TagStart - 1
      EndIf
      If TagStart > TextStart ; TagStart < TextStart when 2 title tags follow each other (PeekS() would read up to the end with a negative length)
        AppendText(PeekMid(@Text$, TextStart, TagStart - TextStart))
      EndIf

      RenderLineBreaks = #True
      Select Char$
        Case "#" ; constant
          AppendHtml("<font class='cst'>" + Tag$ + "</font>")

        Case "@" ; link to a function
          LinkName$ = LCase(Mid(Tag$, 2))
          *Page = FindPage(LinkName$)
          If *Page
            Link$ = *Page\Title$
            If *Page\UserLib$
              Link$ = "<font class='ul'>" + Link$ + "</font>"
            EndIf
            AppendHtml("<a href='#' onclick='" + JsCall("lk:" + LinkName$) + "'>" + Link$ + "</a>")
          Else
            AddError("ref not found: " + LinkName$)
          EndIf

        Case "<" ; html tag
          RenderLineBreaks = #False
          ParameterStart = Position
          Position = FindString(Text$, ">", Position)
          AppendHtml("<" + Mid(Tag$, 2) + " " + Mid(Text$, ParameterStart, Position - ParameterStart) + ">")
          Position + 1

        Default
          If FindMapElement(Tags(), LCase(Tag$)) = 0 ; unknown tag
            AppendText("@" + Tag$)

          Else
            RenderPreformatted + Tags()\Preformatted
            If RenderPreformatted < 0 ; @Description without @Syntax/@Function before (ie: Reference pages): the line feeds would be ignored
              RenderPreformatted = 0
            EndIf

            TagHtml$ = ""
            Select Tags()\ParameterType
              Case 1, 2
                ParameterCount + 1
                If ParameterCount = 1
                  TagHtml$ = "<h3>" + Text_Parameters$ + "</h3><table class='param'>" + #LF$
                Else
                  TagHtml$ = "</td></tr>"
                EndIf
                If Tags()\ParameterType = 2
                  TagHtml$ + "<tr class='opt'>"
                Else
                  TagHtml$ + "<tr>"
                EndIf
                TagHtml$ + "<td width='10%'><i>$p1</i></td><td width='90%'>"

              Case 3
                If ParameterCount
                  TagHtml$ = "</td></tr></table>"
                  ParameterCount = 0
                EndIf
            EndSelect

            If Tag$ = "ExampleFile" And ExampleTitleDone = #False
              ExampleTitleDone = #True
              TagHtml$ = "<h3>" + Text_Example$ + "</h3>"
            EndIf

            TagHtml$ + Tags()\Html$
            If FindString(TagHtml$, "$")
              If FindString(TagHtml$, "$ose") ; example OS
                Parameter$ = ReadTagParameter(@Text$, @Position, " " + #LF$)
                If Parameter$ = "All" Or Parameter$ = OS$
                  TagHtml$ = ReplaceString(TagHtml$, "$ose", "")
                Else
                  TagHtml$ = ""
                  Position = FindString(Text$, #LF$, Position)
                EndIf
              EndIf
              If FindString(TagHtml$, "$p1")
                TagHtml$ = ReplaceString(TagHtml$, "$p1", EscapeHtml(ReadTagParameter(@Text$, @Position)))
              EndIf
              If FindString(TagHtml$, "$p2")
                TagHtml$ = ReplaceString(TagHtml$, "$p2", EscapeHtml(ReadTagParameter(@Text$, @Position)))
              EndIf
              If FindString(TagHtml$, "$im")
                Parameter$ = ReadTagParameter(@Text$, @Position, " " + #LF$)
                Image$ = ImageToHtml(Parameter$)
                If Image$ <> ""
                  TagHtml$ = ReplaceString(TagHtml$, "$im", Image$)
                Else
                  AddError("image Not found: " + Parameter$)
                EndIf
              EndIf
              If FindString(TagHtml$, "$ex")
                Position + 1
                TagHtml$ = ReplaceString(TagHtml$, "$ex", Str(ExampleNumber))
                ExampleNumber + 1
              EndIf
              If FindString(TagHtml$, "$lg")
                ParameterStart = Position
                Position = FindString(Text$, #LF$, Position)
                TagHtml$ = ReplaceString(TagHtml$, "$lg", Mid(Text$, ParameterStart, Position - ParameterStart))
              EndIf
            EndIf

            If LCase(Tag$) = "os"
              ; Like DocMaker: the block of another OS is skipped up to the next @OS, @EndOS, @CommandList, @SupportedOS or @Function
              ParameterStart = Position
              Position = FindString(Text$ + #LF$, #LF$, Position)
              If LCase(Trim(Mid(Text$, ParameterStart, Position - ParameterStart))) <> LCase(OS$)
                LowerText$ = LCase(Text$)
                BlockEnd = 0
                For i = 1 To 5
                  Found = FindString(LowerText$, #LF$ + StringField("@os ,@endos,@commandlist,@supportedos,@function ", i, ","), Position)
                  If Found And (BlockEnd = 0 Or Found < BlockEnd)
                    BlockEnd = Found
                  EndIf
                Next i
                If BlockEnd
                  Position = BlockEnd
                Else
                  Position = Len(Text$) + 1
                EndIf
              EndIf
            EndIf

            AppendHtml(TagHtml$)

            ; Blocks
            If Tag$ = "Code"
              TextStart = Position
              Position = FindString(Text$, "@EndCode", Position, #PB_String_NoCase) - 1
              If Position = -1
                AddError("missing : @EndCode")
                Break
              EndIf
              RenderLineBreaks = #False
              If ColorCodeCallback
                AppendHtml(ColorCodeCallback(PeekMid(@Text$, TextStart, Position - TextStart)))
              Else
                AppendText(PeekMid(@Text$, TextStart, Position - TextStart))
              EndIf
            EndIf

            If Tag$ = "FormatIf"
              TextStart = Position
              Position = FindString(Text$, "@FormatEndIf", Position, #PB_String_NoCase) - 1
              If Position = -1
                AddError("missing : @FormatEndIf")
                Break
              EndIf
              AppendBlockHtml(PeekMid(@Text$, TextStart, Position - TextStart))
            EndIf

            If Tag$ = "HTML"
              TextStart = Position
              Position = FindString(Text$, "@EndHTML", Position, #PB_String_NoCase) - 1
              If Position = -1
                AddError("missing : @EndHTML")
                Break
              EndIf
              RenderLineBreaks = #False
              AppendBlockHtml(PeekMid(@Text$, TextStart, Position - TextStart))
            EndIf
          EndIf
      EndSelect

      If Position < TextStart
        AddError("undefined error (maybe line feed missing)")
        Break
      EndIf
    ForEver

    If RenderErrors$
      RenderHtml$ = "<font class='note'>" + ReplaceString(RenderErrors$, #LF$, "<br>") + "</font>" + RenderHtml$
    EndIf

    If FindMapElement(OSSpecific$(), *CurrentPage\Name$)
      OSNote$ = "<div class='note'>" + OSSpecific$() + "</div>"
    EndIf

    Html$ = "<html><head><title>" + EscapeHtml(*CurrentPage\Title$) + "</title><style>" + PageColors$ + PageStyle$ + "</style></head><body>" +
            "<h2>" + OSNote$ + *CurrentPage\Title$ + "<br><font class='nav'>" + *CurrentPage\Navigation$ + "</font></h2>" + #LF$ +
            RenderHtml$ + "</body></html>"
    RenderHtml$ = ""

    If IsGadget(GadgetSearch)
      Html$ = HighlightSearch(Html$, GetGadgetText(GadgetSearch))
    EndIf

    ProcedureReturn Html$
  EndProcedure


  ;- ----- Help building (from the documentation sources)

  ; Converts reference.html (contents of the html help) to the help format
  ;
  Procedure.s ContentsHtmlToSource(Html$)
    Protected Line$, Tag$, Attributes$, Text$, Link$, Result$, Char$
    Protected LineStart, LineEnd, Position

    Html$ = RemoveString(Html$, #CR$)
    Html$ = RemoveString(Html$, #TAB$)
    Repeat
      LineStart = LineEnd + 1
      LineEnd = FindString(Html$, #LF$, LineStart)
      If LineEnd = 0
        Break
      EndIf

      Line$ = Trim(Mid(Html$, LineStart, LineEnd - LineStart))
      If Left(Line$, 1) = "<"
        Position = 1
        Repeat
          Position + 1
          Char$ = PeekMid(@Line$, Position, 1)
        Until Char$ = "" Or FindString(" >", Char$)
        Tag$        = LCase(PeekMid(@Line$, 2, Position - 2))
        Attributes$ = PeekMid(@Line$, Position, FindString(Line$, ">") - Position)
        Text$       = ExtractBetween(Line$, ">", "<")

        Select Tag$
          Case "table", "tr", "td", "/table", "/tr", "/td"
            Result$ + "@<" + Tag$ + Attributes$ + ">" + #LF$

          Case "b"
            Result$ + "@Section " + Text$ + #LF$

          Case "a"
            If FindString(Line$, "href")
              If FindString(Line$, "/index") ; library index: 'Library/index.html'
                Link$ = "lib_" + ExtractBetween(Line$, "/", "/")
              Else
                Link$ = ExtractBetween(Line$, #DQUOTE$, ".")
              EndIf
              Result$ + "@Link " + Link$ + " " + #DQUOTE$ + Text$ + #DQUOTE$ + #LF$
            EndIf
        EndSelect
      EndIf
    ForEver

    ProcedureReturn ReplaceString(Result$, "<table", "<table style='all: unset;'")
  EndProcedure


  ; Converts a documentation source file (DocMaker format) to the help format: the lines are joined, and the
  ; @FormatIf blocks become @HTML blocks (without their @FormatElse part)
  ;
  Procedure ConvertSourceFile(Source$, Destination$)
    Protected File, Format, IsPreformatted, IsText, WasText, IsEnabled, Position
    Protected Line$, FirstChar$, Char$, Tag$, Result$

    File = ReadFile(#PB_Any, Source$)
    If File = 0
      ProcedureReturn #False
    EndIf

    Format = ReadStringFormat(File)
    If Format = #PB_Ascii ; sources without BOM: UTF-8
      Format = #PB_UTF8
    EndIf

    IsEnabled = #True
    Repeat
      Line$ = ReadString(File, Format)
      FirstChar$ = Left(Line$, 1)
      If IsPreformatted = #False And LCase(Left(LTrim(Line$), 13)) = "@examplefile " ; often indented: stays on its own line (read up to the end of the line)
        Line$ = LTrim(Line$)
        FirstChar$ = "@"
      EndIf
      If Trim(Line$) = "@LineBreak"
        FirstChar$ = " "
      EndIf

      If FirstChar$ = "@"
        Position = 1
        Tag$ = ""
        Char$ = ""
        Repeat
          Position + 1
          Tag$ + Char$
          Char$ = PeekMid(@Line$, Position, 1)
        Until (FindString(#TagSeparators$, Char$) And Tag$ + Char$ <> "</") Or Char$ = ""

        Select LCase(Tag$)
          Case "code", "fixedfont", "function", "syntax"
            IsPreformatted = #True
          Case "endcode", "endfixedfont", "description"
            IsPreformatted = #False
          Case "formatif"
            Line$ = "@HTML"
            IsPreformatted = #True
          Case "formatelse"
            IsEnabled = #False
          Case "formatendif"
            Line$ = "@EndHTML"
            IsEnabled = #True
            IsPreformatted = #False
        EndSelect
      EndIf

      WasText = IsText
      IsText = Bool(FindString("@;", FirstChar$) = 0)
      If IsPreformatted = #False
        Line$ = Trim(Line$)
      EndIf
      If LCase(Trim(Line$)) = "@indent"
        Line$ + #LF$
      EndIf
      If LCase(Trim(Line$)) = "@endindent"
        Line$ = #LF$ + Line$
      EndIf

      If IsPreformatted Or IsText = #False Or WasText = #False
        Line$ = #LF$ + Line$
      Else
        Line$ = " " + Trim(Line$) ; text lines are joined
      EndIf
      Line$ = ReplaceString(Line$, "@LineBreak", #LF$)

      If IsEnabled
        Result$ + Line$
      EndIf
    Until Eof(File)
    CloseFile(File)

    Result$ = ReplaceString(Result$, " " + #LF$, #LF$)
    If IsEnabled = #False
      Debug "HelpTool: @FormatEndIf missing in " + Source$
    EndIf

    ProcedureReturn WriteTextFile(Destination$, Result$)
  EndProcedure


  ; --init: builds the help folder from the documentation sources. Returns the errors
  ;
  Procedure.s BuildHelp(Source$, Destination$)
    Protected File$, Path$, Text$, Errors$, i
    NewList Files$()

    Source$ = ReplaceString(Source$, "\", "/")
    If Right(Source$, 1) <> "/"
      Source$ + "/"
    EndIf
    Destination$ = ReplaceString(Destination$, "\", "/")
    If Right(Destination$, 1) <> "/"
      Destination$ + "/"
    EndIf

    If FileSize(Source$) <> -2
      ProcedureReturn "Help source not found: " + Source$ + #LF$
    EndIf
    If MakePath(Destination$) = 0
      ProcedureReturn "Can't create: " + Destination$ + #LF$
    EndIf

    For i = 1 To CountString(#Languages$, ",") + 1
      Language$ = StringField(#Languages$, i, ",")
      If FileSize(Source$ + Language$) <> -2
        Continue
      EndIf
      InitLanguage()

      ; Source files (ascii.txt is renamed asciitable.txt)
      ListFiles(Files$(), Source$ + Language$, "txt")
      ForEach Files$()
        File$ = Files$()
        If LCase(File$) = "reference/ascii.txt"
          File$ = GetPathPart(File$) + "asciitable.txt"
        EndIf
        MakePath(GetPathPart(Destination$ + Language$ + "/" + File$))
        If ConvertSourceFile(Source$ + Language$ + "/" + Files$(), Destination$ + Language$ + "/" + File$) = 0
          Errors$ + "Can't convert: " + Source$ + Language$ + "/" + Files$() + #LF$
        EndIf
      Next

      ; Contents (home page), with the user libraries section
      Path$ = Source$ + Language$ + "/Reference/reference.html"
      If FileSize(Path$) > 0
        Text$ = "@Title " + Text_Home$ + #LF$ + ContentsHtmlToSource(ReadTextFile(Path$, #False))
        Text$ = InsertString(Text$, "@Section User library" + #LF$ + "$userlib" + #LF$, FindString(Text$, "@Section", FindString(Text$, "lib_texture")))
        Text$ = ReplaceString(Text$, "@Link ascii", "@Link asciitable")
        If WriteTextFile(Destination$ + Language$ + "/Reference/reference.txt", Text$) = 0
          Errors$ + "Can't write: " + Destination$ + Language$ + "/Reference/reference.txt" + #LF$
        EndIf
      Else
        Errors$ + "Not found: " + Path$ + #LF$
      EndIf

      ; Images
      Path$ = Source$ + Language$ + "/Reference/Images"
      If FileSize(Path$) = -2 And CopyDirectory(Path$, Destination$ + Language$ + "/Reference/Images", "", #PB_FileSystem_Recursive | #PB_FileSystem_Force) = 0
        Errors$ + "Can't copy: " + Path$ + #LF$
      EndIf
    Next i

    If FileSize(Source$ + "HelpPictures") = -2 And CopyDirectory(Source$ + "HelpPictures", Destination$ + "HelpPictures", "", #PB_FileSystem_Recursive | #PB_FileSystem_Force) = 0
      Errors$ + "Can't copy: " + Source$ + "HelpPictures" + #LF$
    EndIf
    If CopyFile(Source$ + "OSSpecificFunctions.txt", Destination$ + "OSSpecificFunctions.txt") = 0
      Errors$ + "Can't copy: " + Source$ + "OSSpecificFunctions.txt" + #LF$
    EndIf

    ProcedureReturn Errors$
  EndProcedure


  ; --initzip: like BuildHelp(), but in the 'Destination$' .zip archive. Returns the errors
  ;
  Procedure.s BuildHelpZip(Source$, Destination$)
    Protected TempPath$, Errors$, Pack
    NewList Files$()

    ; The help is built in a temporary folder, then compressed (relative paths with '/', at the archive root)
    TempPath$ = GetTemporaryDirectory() + "HelpTool_" + Str(ElapsedMilliseconds()) + "/"
    Errors$ = BuildHelp(Source$, TempPath$)
    If FileSize(TempPath$) = -2
      UseZipPacker()
      MakePath(GetPathPart(Destination$))
      Pack = CreatePack(#PB_Any, Destination$, #PB_PackerPlugin_Zip)
      If Pack
        ListFiles(Files$(), TempPath$)
        ForEach Files$()
          If AddPackFile(Pack, TempPath$ + Files$(), Files$()) = 0
            Errors$ + "Can't add to the archive: " + Files$() + #LF$
          EndIf
        Next
        ClosePack(Pack)
      Else
        Errors$ + "Can't create: " + Destination$ + #LF$
      EndIf
      DeleteDirectory(TempPath$, "", #PB_FileSystem_Recursive | #PB_FileSystem_Force)
    EndIf

    ProcedureReturn Errors$
  EndProcedure


  ;- ----- User interface

  Procedure.s PageDirectory(*Page.HelpPage) ; folder of the page source file
    If *Page\UserLib$
      ProcedureReturn UserLibPath$
    EndIf
    ProcedureReturn HelpPath$ + LanguagePath$
  EndProcedure


  ; Name$: page name, or "-"/"+" to go back/forward in the history
  ;
  Procedure DisplayPage(Name$)
    Protected *Page.HelpPage, HistoryPosition

    If Len(Name$) <> 1 And FindPage(Name$) = 0
      MessageRequester(Text_Help$, "Page not found: " + Name$)
      ProcedureReturn
    EndIf

    Select Name$
      Case "-"
        If ListIndex(History$()) <= 0
          ProcedureReturn
        EndIf
        PreviousElement(History$())
        Name$ = History$()

      Case "+"
        If ListIndex(History$()) >= ListSize(History$()) - 1
          ProcedureReturn
        EndIf
        NextElement(History$())
        Name$ = History$()

      Default ; a new page drops the forward history
        While NextElement(History$())
          DeleteElement(History$())
        Wend
        AddElement(History$())
        History$() = Name$
    EndSelect

    If Name$ = CurrentPageName$
      ProcedureReturn
    EndIf
    CurrentPageName$ = Name$

    SetPageHtml(PageToHtml(Name$))
    HistoryPosition = ListIndex(History$())
    DisableGadget(GadgetBack, Bool(HistoryPosition = 0))
    DisableGadget(GadgetForward, Bool(HistoryPosition = ListSize(History$()) - 1))
    HideGadget(GadgetEdit, Bool(IsArchive And *CurrentPage And *CurrentPage\UserLib$ = ""))

    *Page = FindPage(Name$)
    If *Page
      CompilerIf #Standalone ; in the IDE, don't steal the focus from the editor
        SetActiveGadget(GadgetContents)
      CompilerEndIf
      SetGadgetState(GadgetContents, *Page\ContentsItem)
    EndIf
  EndProcedure


  Procedure.s FindExampleFile(Name$) ; IDE: path of the real example file (so the relative paths to its data are working)
    Protected Path$, i

    For i = 1 To 2
      If i = 1
        Path$ = HelpPath$
      Else
        Path$ = ExamplesPath$
      EndIf
      If Path$ = "" Or (i = 1 And IsArchive)
        Continue
      EndIf

      If FileSize(Path$ + "Examples/Sources/" + Name$) > 0
        ProcedureReturn Path$ + "Examples/Sources/" + Name$
      EndIf
      If FileSize(Path$ + "Examples/3D/" + Name$) > 0
        ProcedureReturn Path$ + "Examples/3D/" + Name$
      EndIf
      If i = 2
        If FileSize(Path$ + "Sources/" + Name$) > 0
          ProcedureReturn Path$ + "Sources/" + Name$
        EndIf
        If FileSize(Path$ + "3D/" + Name$) > 0
          ProcedureReturn Path$ + "3D/" + Name$
        EndIf
      EndIf
    Next i

    ProcedureReturn ""
  EndProcedure


  ; Message$: '["xy:Value"]' (json parameters of the WebView callback)
  ;   lk: link to a page
  ;   co, cr: load/run the example code number 'Value' of the page
  ;   fo, fr: load/run the example file 'Value'
  ;
  Procedure HandleJsMessage(Message$)
    Protected Type$, Value$, File$, Code$, FileName$, Source$, Position, i

    Message$ = Mid(Message$, 3, Len(Message$) - 4)
    Type$  = Left(Message$, 2)
    Value$ = Trim(Mid(Message$, 4))

    If Type$ = "lk"
      DisplayPage(LCase(Value$))
      ProcedureReturn
    EndIf

    Select Left(Type$, 1)
      Case "c" ; code in the page
        Source$ = *CurrentPage\Source$
        For i = 0 To Val(Value$)
          Position = FindString(Source$, "@Code", Position + 1)
        Next i
        Code$ = ExtractBetween(Source$, "@Code", "@EndCode", Position - 5)
        FileName$ = *CurrentPage\Name$ + "_ex" + Value$ + ".pb"

      Case "f" ; example file
        CompilerIf Not #Standalone
          File$ = FindExampleFile(Value$)
        CompilerEndIf
        If File$ = ""
          Code$ = ReadHelpFile("Examples/Sources/" + Value$, #False)
          If Code$ = ""
            Code$ = ReadHelpFile("Examples/3D/" + Value$, #False)
          EndIf
        EndIf
        FileName$ = Value$
    EndSelect

    CompilerIf #Standalone
      If Code$ <> ""
        File$ = GetTemporaryDirectory() + FileName$
        WriteTextFile(File$, Code$)
        Select Mid(Type$, 2, 1)
          Case "o"
            RunProgram(#PB_Compiler_Home + "PureBasic", #DQUOTE$ + File$ + #DQUOTE$, GetTemporaryDirectory(), #PB_Program_Hide)
          Case "r"
            RunProgram(#DQUOTE$ + #PB_Compiler_Home + "Compilers\pbcompiler" + #DQUOTE$, #DQUOTE$ + File$ + #DQUOTE$, GetTemporaryDirectory(), #PB_Program_Hide)
        EndSelect
      EndIf

    CompilerElse ; IDE: loaded in a new tab (and run if asked)
      If OpenCodeCallback And (File$ <> "" Or Code$ <> "")
        OpenCodeCallback(File$, Code$, Bool(Mid(Type$, 2, 1) = "r"))
      EndIf
    CompilerEndIf
  EndProcedure


  Procedure OnJsMessage(Message$)
    ; The javascript is blocked during the callback: the action is deferred to the event loop
    LastElement(JsMessages$())
    AddElement(JsMessages$())
    JsMessages$() = Message$
    PostEvent(#EventJsMessage, HostWindow, 0)
  EndProcedure


  Procedure ProcessJsMessages()
    Protected Message$

    While FirstElement(JsMessages$())
      Message$ = JsMessages$()
      DeleteElement(JsMessages$())
      HandleJsMessage(Message$)
    Wend
  EndProcedure


  CompilerIf #PB_Compiler_OS = #PB_OS_Windows

    Procedure IsWebViewAvailable() ; WebView2 usable? (tested only once, in an invisible window)
      Static Result = -1
      Protected OldGadgetList, Window, Gadget

      If Result = -1
        Result = #True
        OldGadgetList = UseGadgetList(0)
        Window = OpenWindow(#PB_Any, 0, 0, 10, 10, "", #PB_Window_Invisible)
        If Window
          Gadget = WebViewGadget(#PB_Any, 0, 0, 10, 10)
          If Gadget
            FreeGadget(Gadget)
          Else
            Result = #False
          EndIf
          CloseWindow(Window)
        EndIf
        If OldGadgetList
          UseGadgetList(OldGadgetList)
        EndIf
      EndIf

      ProcedureReturn Result
    EndProcedure


    Procedure IENavigationCallback(Gadget, Url$) ; IE mode: the jsmessage() calls come as a 'helptool:' url
      If LCase(Left(Url$, Len(#IEMessageScheme$))) = #IEMessageScheme$
        OnJsMessage("[" + #DQUOTE$ + URLDecoder(Mid(Url$, Len(#IEMessageScheme$) + 1)) + #DQUOTE$ + "]") ; same format as the WebView callback
        ProcedureReturn #False
      EndIf
      ProcedureReturn #True
    EndProcedure

  CompilerEndIf


  Procedure SearchPages()
    Protected Search$, Item
    NewList Results$()

    Search$ = GetGadgetText(GadgetSearch)
    If CurrentPageName$ <> "" ; updates (or removes) the highlighting in the displayed page
      SetPageHtml(PageToHtml(CurrentPageName$))
    EndIf
    If Len(Search$) < 3
      ProcedureReturn
    EndIf

    ForEach Pages()
      If FindString(Pages()\Source$, Search$, 1, #PB_String_NoCase)
        AddElement(Results$())
        Results$() = Pages()\Name$
      EndIf
    Next
    SortList(Results$(), #PB_Sort_Ascending)

    HideGadget(GadgetSearchList, #True)
    ClearGadgetItems(GadgetSearchList)
    ForEach Results$()
      AddGadgetItem(GadgetSearchList, -1, *PageMap(Results$())\Title$)
      SetGadgetItemData(GadgetSearchList, Item, *PageMap(Results$()))
      Item + 1
    Next
    HideGadget(GadgetSearchList, #False)
  EndProcedure


  Procedure CreateUserInterface()
    Protected Xml$, Tabs$, ButtonSize, i

    InitLanguage()

    Tabs$ = "        <tab text='" + Text_Contents$ + "'>" +
            "          <tree name='contents' flags='#PB_Tree_AlwaysShowSelection'/>" +
            "          </tab>" +
            "        <tab text='" + Text_Search$ + "'>" +
            "          <vbox expand='item:2'>" +
            "            <string name='search'/>" +
            "            <listview name='searchlist'/>" +
            "            </vbox>" +
            "          </tab>"

    CompilerIf #Standalone
      Xml$ = "<window id='#PB_Any' name='help' text='PureBasic' minwidth='500' minheight='400' flags='#PB_Window_ScreenCentered | #PB_Window_SystemMenu | #PB_Window_SizeGadget'>" +
             "  <hbox>" +
             "    <splitter name='splitter' flags='#PB_Splitter_Vertical' firstmin='20' secondmin='auto'>" +
             "      <panel name='panel' maxwidth='150'>" +
             Tabs$ +
             "        </panel>" +
             "      <container margin='0'>" +
             "        <vbox expand='item:2'>" +
             "          <hbox expand='no'>" +
             "            <button name='back' text='&#9664;' />" +
             "            <button name='forward' text='&#9654;' />" +
             "            <button name='home' text='&#8962;' />" +
             "            <combobox name='language' width='100' />" +
             "            <combobox name='os' width='100' />" +
             "            <button name='edit' text='&#9998;' />" +
             "            </hbox>" +
             "          <webview name='web' />" +
             "          </vbox>" +
             "        </container>" +
             "      </splitter>" +
             "    </hbox>" +
             "  </window>"

    CompilerElse ; IDE: the button bar is on top, the contents (hidden by default) on the left of the page
      ButtonSize = 28 ; icon + margin
      If IsImage(ImageBack)
        ButtonSize = DesktopUnscaledX(ImageWidth(ImageBack)) + 12
      EndIf
      Xml$ = "<window id='#PB_Any' name='help' margin='0'>" +
             "  <vbox expand='item:2'>" +
             "    <hbox expand='no'>" +
             "      <buttonimage name='showcontents' width='" + ButtonSize + "' height='" + ButtonSize + "' flags='#PB_Button_Toggle' />" +
             "      <buttonimage name='back' width='" + ButtonSize + "' height='" + ButtonSize + "' />" +
             "      <buttonimage name='forward' width='" + ButtonSize + "' height='" + ButtonSize + "' />" +
             "      <buttonimage name='home' width='" + ButtonSize + "' height='" + ButtonSize + "' />" +
             "      <buttonimage name='edit' width='" + ButtonSize + "' height='" + ButtonSize + "' />" +
             "      </hbox>" +
             "    <splitter name='splitter' flags='#PB_Splitter_Vertical' firstmin='0' secondmin='auto'>" +
             "      <panel name='panel' invisible='yes'>" +
             Tabs$ +
             "        </panel>" +
             "      <webview name='web' />" +
             "      </splitter>" +
             "    </vbox>" +
             "  </window>"
    CompilerEndIf

    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      IEMode = Bool(#ForceIEMode Or IsWebViewAvailable() = #False)
      If IEMode ; WebView2 not available: WebGadget (Internet Explorer), degraded display
        Xml$ = ReplaceString(Xml$, "<webview name='web' />", "<web name='web' />")
        UseDialogWebGadget()
      EndIf
    CompilerEndIf
    UseDialogWebViewGadget()

    DialogXML = ParseXML(#PB_Any, Xml$)
    Dialog = CreateDialog(#PB_Any)
    CompilerIf #Standalone
      OpenXMLDialog(Dialog, DialogXML, "help")
      StandaloneWindow = DialogWindow(Dialog)
    CompilerElse
      XmlDialogGadget(Dialog, DialogXML, "help")
      GadgetRoot = DialogGadget(Dialog, "help")
    CompilerEndIf

    GadgetPanel      = DialogGadget(Dialog, "panel")
    GadgetContents   = DialogGadget(Dialog, "contents")
    GadgetSearch     = DialogGadget(Dialog, "search")
    GadgetSearchList = DialogGadget(Dialog, "searchlist")
    GadgetBack       = DialogGadget(Dialog, "back")
    GadgetForward    = DialogGadget(Dialog, "forward")
    GadgetHome       = DialogGadget(Dialog, "home")
    GadgetEdit       = DialogGadget(Dialog, "edit")
    DisableGadget(GadgetContents, #False)

    CompilerIf #Standalone
      GadgetLanguage = DialogGadget(Dialog, "language")
      For i = 1 To CountString(#Languages$, ",") + 1
        AddGadgetItem(GadgetLanguage, -1, StringField(#Languages$, i, ","))
      Next i
      SetGadgetText(GadgetLanguage, Language$)

      GadgetOS = DialogGadget(Dialog, "os")
      AddGadgetItem(GadgetOS, -1, "Windows")
      AddGadgetItem(GadgetOS, -1, "MacOS")
      AddGadgetItem(GadgetOS, -1, "Linux")
      SetGadgetText(GadgetOS, OS$)

    CompilerElse ; the language and the OS are the IDE ones
      GadgetLanguage = -1
      GadgetOS = -1
      GadgetShowContents = DialogGadget(Dialog, "showcontents")
      GadgetToolTip(GadgetShowContents, Text_ShowContents$)
      If IsImage(ImageContents) : SetGadgetAttribute(GadgetShowContents, #PB_Button_Image, ImageID(ImageContents)) : EndIf
      If IsImage(ImageBack)     : SetGadgetAttribute(GadgetBack,         #PB_Button_Image, ImageID(ImageBack))     : EndIf
      If IsImage(ImageForward)  : SetGadgetAttribute(GadgetForward,      #PB_Button_Image, ImageID(ImageForward))  : EndIf
      If IsImage(ImageHome)     : SetGadgetAttribute(GadgetHome,         #PB_Button_Image, ImageID(ImageHome))     : EndIf
      If IsImage(ImageEdit)     : SetGadgetAttribute(GadgetEdit,         #PB_Button_Image, ImageID(ImageEdit))     : EndIf
      If ApplyColorsCallback
        ApplyColorsCallback(GadgetContents)
        ApplyColorsCallback(GadgetSearch)
        ApplyColorsCallback(GadgetSearchList)
      EndIf
      RefreshDialog(Dialog)
    CompilerEndIf

    GadgetToolTip(GadgetBack, Text_Back$)
    GadgetToolTip(GadgetForward, Text_Forward$)
    GadgetToolTip(GadgetHome, Text_Home$)
    GadgetToolTip(GadgetEdit, Text_Edit$)

    GadgetWeb = DialogGadget(Dialog, "web")
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      If IEMode
        SetGadgetAttribute(GadgetWeb, #PB_Web_NavigationCallback, @IENavigationCallback())
      Else
        BindWebViewCallback(GadgetWeb, "jsmessage", @OnJsMessage())
      EndIf
    CompilerElse
      BindWebViewCallback(GadgetWeb, "jsmessage", @OnJsMessage())
    CompilerEndIf

    GadgetSplitter = DialogGadget(Dialog, "splitter")
    CompilerIf #Standalone
      SetGadgetState(GadgetSplitter, 150)
      If IsArchive ; the archive has only one language
        HideGadget(GadgetLanguage, #True)
        HideGadget(GadgetOS, #True)
      EndIf
      ResizeWindow(StandaloneWindow, StandaloneX, StandaloneY, StandaloneWidth, StandaloneHeight)
    CompilerElse
      SetGadgetState(GadgetSplitter, 0) ; contents hidden by default
    CompilerEndIf
  EndProcedure


  Procedure EditCurrentPage() ; edits the source of the current page
    Protected File$, Text$

    If *CurrentPage = 0 Or *CurrentPage\File$ = ""
      ProcedureReturn
    EndIf
    File$ = PageDirectory(*CurrentPage) + *CurrentPage\File$

    CompilerIf #Standalone
      RunProgram("notepad++.exe", #DQUOTE$ + File$ + #DQUOTE$ + " -p" + *CurrentPage\Position, "")
    CompilerElse ; IDE: opens the file in a tab, at the page line
      If EditFileCallback
        Text$ = ReadTextFile(File$, #False)
        EditFileCallback(File$, CountString(Left(Text$, *CurrentPage\Position), #LF$) + 1)
      EndIf
    CompilerEndIf
  EndProcedure


  Procedure SetSplitterPosition(Position) ; IDE
    Protected Width, Height

    SetGadgetState(GadgetSplitter, Position)
    CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
      ; Cocoa: SetGadgetState() doesn't layout the dialog panels content again, a resize forces it
      Width  = GadgetWidth(GadgetRoot)
      Height = GadgetHeight(GadgetRoot)
      ResizeGadget(GadgetRoot, #PB_Ignore, #PB_Ignore, Width, Height - 1)
      ResizeGadget(GadgetRoot, #PB_Ignore, #PB_Ignore, Width, Height)
    CompilerEndIf
  EndProcedure


  Procedure MeasureSplitterBar() ; IDE: splitter bar width, in screen coordinates (independent of the real parent of the splitter gadgets)
    Protected Width = GadgetX(GadgetWeb, #PB_Gadget_ScreenCoordinate) - GadgetX(GadgetSplitter, #PB_Gadget_ScreenCoordinate) - GetGadgetState(GadgetSplitter)

    If Width > 0 And Width < 40 ; else the size isn't allocated yet (GTK)
      SplitterBarWidth = Width
    EndIf
  EndProcedure


  Procedure PlaceHiddenContents() ; IDE: hidden contents: the splitter bar is placed just on the left of the visible area
    Protected Width

    If ContentsVisible Or IsGadget(GadgetSplitter) = 0
      ProcedureReturn
    EndIf

    If GetGadgetState(GadgetSplitter) <> 0
      SetGadgetState(GadgetSplitter, 0)
    EndIf
    MeasureSplitterBar()
    Width = SplitterBarWidth
    If Width < 0
      Width = 8
    EndIf
    ResizeGadget(GadgetSplitter, -Width, #PB_Ignore, GadgetWidth(GadgetRoot) + Width, #PB_Ignore) ; the dialog puts the splitter on the whole root width
  EndProcedure


  Procedure ShowContents(Visible) ; IDE: shows/hides the contents on the left of the page
    If IsGadget(GadgetSplitter) = 0
      ProcedureReturn
    EndIf

    ContentsVisible = Visible
    SetGadgetState(GadgetShowContents, Visible)
    If Visible
      SetGadgetAttribute(GadgetSplitter, #PB_Splitter_FirstMinimumSize, 20)
      HideGadget(GadgetPanel, #False)
      RefreshDialog(Dialog) ; puts the splitter back in the visible area
      If SplitterPosition <= 0 ; first display: a third of the width, without being too narrow
        SplitterPosition = GadgetWidth(GadgetRoot) / 3
        If SplitterPosition < 150
          SplitterPosition = GadgetWidth(GadgetRoot) / 2
        EndIf
      EndIf
      SetSplitterPosition(SplitterPosition)
    Else
      If GetGadgetState(GadgetSplitter) > 0
        SplitterPosition = GetGadgetState(GadgetSplitter)
      EndIf
      SetGadgetAttribute(GadgetSplitter, #PB_Splitter_FirstMinimumSize, 0)
      HideGadget(GadgetPanel, #True)
      PlaceHiddenContents()
    EndIf
  EndProcedure


  Procedure Timer() ; reloads the help if the source of the current page has been modified
    Protected Name$, Width

    If ContentsVisible = #False And IsGadget(GadgetSplitter) ; the splitter bar width is only known once the splitter is displayed (GTK, Cocoa)
      Width = SplitterBarWidth
      MeasureSplitterBar()
      If SplitterBarWidth <> Width
        PlaceHiddenContents()
      EndIf
    EndIf

    If *CurrentPage And *CurrentPage\File$ <> ""
      If GetFileDate(PageDirectory(*CurrentPage) + *CurrentPage\File$, #PB_Date_Modified) - LastReloadDate >= 2
        LastReloadDate = Date()
        Name$ = *CurrentPage\Name$
        LoadHelp()
        DisplayPage(Name$)
      EndIf
    EndIf
  EndProcedure


  Procedure GadgetEvent(Gadget, Type)
    Protected *Page.HelpPage

    If Type <> #PB_EventType_Change And Type <> #PB_EventType_LeftClick
      ProcedureReturn
    EndIf

    Select Gadget
      Case GadgetContents
        If GetGadgetState(GadgetContents) >= 0 And Type = #PB_EventType_Change
          *Page = GetGadgetItemData(GadgetContents, GetGadgetState(GadgetContents))
          If *Page
            DisplayPage(*Page\Name$)
          EndIf
        EndIf

      Case GadgetShowContents
        ShowContents(GetGadgetState(GadgetShowContents))

      Case GadgetHome
        DisplayPage("reference")

      Case GadgetBack
        DisplayPage("-")

      Case GadgetForward
        DisplayPage("+")

      Case GadgetPanel
        SetActiveGadget(GadgetSearch)

      Case GadgetSearch
        If Type = #PB_EventType_Change
          SearchPages()
        EndIf

      Case GadgetSearchList
        If GetGadgetState(GadgetSearchList) >= 0
          *Page = GetGadgetItemData(GadgetSearchList, GetGadgetState(GadgetSearchList))
          DisplayPage(*Page\Name$)
        EndIf

      Case GadgetEdit
        EditCurrentPage()

      Case GadgetLanguage
        Language$ = GetGadgetText(GadgetLanguage)
        InitLanguage()
        LoadHelp()

      Case GadgetOS
        OS$ = GetGadgetText(GadgetOS)
    EndSelect
  EndProcedure


  ;- ----- Standalone tool

  Procedure StandalonePreferences(Save)
    If Save
      If CreatePreferences(GetCurrentDirectory() + "HelpTool.ini")
        WritePreferenceLong("X", WindowX(StandaloneWindow))
        WritePreferenceLong("Y", WindowY(StandaloneWindow))
        WritePreferenceLong("Width", WindowWidth(StandaloneWindow))
        WritePreferenceLong("Height", WindowHeight(StandaloneWindow))
        WritePreferenceString("HelpSource", HelpSource$)
        ClosePreferences()
      EndIf
    Else
      OpenPreferences(GetCurrentDirectory() + "HelpTool.ini") ; default values if it doesn't exist
      StandaloneX      = ReadPreferenceLong("X", 50)
      StandaloneY      = ReadPreferenceLong("Y", 50)
      StandaloneWidth  = ReadPreferenceLong("Width", 800)
      StandaloneHeight = ReadPreferenceLong("Height", 600)
      HelpSource$      = ReadPreferenceString("HelpSource", "")
      ClosePreferences()
    EndIf
  EndProcedure


  Procedure RunStandalone(HelpLanguage$, HelpOS$)
    Protected Event

    Language$ = HelpLanguage$
    OS$ = HelpOS$

    StandalonePreferences(#False)
    If FileSize(HelpSource$) <> -2 And LCase(GetExtensionPart(HelpSource$)) <> "zip"
      HelpSource$ = #PB_Compiler_Home + "Help/Help.zip"
    EndIf
    OpenSource(HelpSource$)
    UserLibPath$ = #PB_Compiler_Home + "PureLibraries/UserLibraries/"

    CreateUserInterface()
    HostWindow = StandaloneWindow
    BindEvent(#EventJsMessage, @ProcessJsMessages(), HostWindow)
    AddWindowTimer(StandaloneWindow, 0, 1000)
    LoadHelp()
    LastReloadDate = Date()

    Repeat
      Event = WaitWindowEvent()
      If EventWindow() = StandaloneWindow
        Select Event
          Case #PB_Event_Gadget
            GadgetEvent(EventGadget(), EventType())
          Case #PB_Event_Timer
            Timer()
        EndSelect
      EndIf
    Until Event = #PB_Event_CloseWindow

    StandalonePreferences(#True)
  EndProcedure


  ; Checks the help sources of all the languages, and displays the errors
  ;
  Procedure CheckSources()
    Protected Errors$, i

    StandalonePreferences(#False)
    OpenSource(HelpSource$)
    OS$ = "Windows"

    For i = 1 To CountString(#Languages$, ",") + 1
      Language$ = StringField(#Languages$, i, ",")
      Errors$ + "==== " + Language$ + " ====" + #LF$
      InitLanguage()
      LoadHelp(#False)
      ForEach Pages()
        PageToHtml(Pages()\Name$)
        If RenderErrors$
          Errors$ + "---- " + Pages()\File$ + " - " + Pages()\Name$ + #LF$ + RenderErrors$
        EndIf
      Next
      Errors$ + "==== " + Str(ListSize(Pages())) + " pages" + #LF$
    Next i

    Debug Errors$
    MessageRequester("Help sources check", Errors$)
  EndProcedure


  ;- ----- IDE embedding

  Procedure Setup(HelpLanguage$, HelpOS$, Source$, UserLibraries$, Examples$)
    Language$ = HelpLanguage$
    OS$ = HelpOS$
    HelpSource$ = Source$
    OpenSource(HelpSource$)
    UserLibPath$ = UserLibraries$
    ExamplesPath$ = Examples$
  EndProcedure


  Procedure SetImages(Back, Forward, Home, Edit, Contents, LoadCode$, RunCode$) ; LoadCode$, RunCode$: png images in base64
    ImageBack     = Back
    ImageForward  = Forward
    ImageHome     = Home
    ImageEdit     = Edit
    ImageContents = Contents
    If LoadCode$ <> ""
      LoadCodeIcon$ = "<img src='data:image/png;base64," + LoadCode$ + "'>"
    EndIf
    If RunCode$ <> ""
      RunCodeIcon$ = "<img src='data:image/png;base64," + RunCode$ + "'>"
    EndIf
  EndProcedure


  Procedure SetColors(Css$, Color = $008800) ; Css$: ":root {--bg:...}" (see PageColors$), Color: user libraries in the contents
    PageColors$ = Css$
    UserLibColor = Color
  EndProcedure


  Procedure Create(Window) ; creates the help in the current gadget list
    HostWindow = Window
    ClearList(History$())
    CreateUserInterface()
    BindEvent(#EventJsMessage, @ProcessJsMessages(), HostWindow)
    LoadHelp()
    LastReloadDate = Date()
  EndProcedure


  Procedure Destroy()
    UnbindEvent(#EventJsMessage, @ProcessJsMessages(), HostWindow)
    ClearList(JsMessages$())
    If IsDialog(Dialog)
      FreeDialog(Dialog)
    EndIf
    If IsXML(DialogXML)
      FreeXML(DialogXML)
    EndIf
    Dialog = 0
    DialogXML = 0
    GadgetRoot = 0
    GadgetShowContents = -1
    ContentsVisible = #False
    *CurrentPage = 0
  EndProcedure


  Procedure Resize(Width, Height)
    If IsGadget(GadgetRoot)
      ResizeGadget(GadgetRoot, 0, 0, Width, Height) ; layouts the dialog again, which puts the splitter on the whole width
      PlaceHiddenContents()
    EndIf
  EndProcedure


  Procedure ShowPage(Name$) ; displays a page if it exists (F1 contextual help)
    Name$ = LCase(Name$)
    If FindPage(Name$) = 0
      ProcedureReturn #False
    EndIf
    DisplayPage(Name$)
    ProcedureReturn #True
  EndProcedure

EndModule


CompilerIf #PB_Compiler_IsMainFile

  ; HelpTool --init <helpsourcepath> <helpdestinationpath>
  ;   builds the help folder used by the help tool from the documentation sources (the 'Documentation' folder)
  ; HelpTool --initzip <helpsourcepath> <helpdestinationzip>
  ;   same, but builds a zip archive (ie: 'Help/Help.zip', the default help source of the IDE)
  ;
  ; HelpTool::CheckSources() checks the help sources of all the languages for errors
  ;
  If ProgramParameter(0) = "--init" Or ProgramParameter(0) = "--initzip"
    If CountProgramParameters() <> 3
      Errors$ = "Usage: HelpTool --init <helpsourcepath> <helpdestinationpath>" + #LF$ +
                "       HelpTool --initzip <helpsourcepath> <helpdestinationzip>" + #LF$
    ElseIf ProgramParameter(0) = "--initzip"
      Errors$ = HelpTool::BuildHelpZip(ProgramParameter(1), ProgramParameter(2))
    Else
      Errors$ = HelpTool::BuildHelp(ProgramParameter(1), ProgramParameter(2))
    EndIf
    If Errors$ <> ""
      If OpenConsole()
        ConsoleError(RTrim(Errors$, #LF$))
      EndIf
      End 1
    EndIf
    End
  EndIf

  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      HelpTool::RunStandalone("English", "Windows")
    CompilerCase #PB_OS_Linux
      HelpTool::RunStandalone("English", "Linux")
    CompilerDefault
      HelpTool::RunStandalone("English", "MacOS")
  CompilerEndSelect

CompilerElse

  UsePNGImageEncoder()

  Global HelpToolSource$, Backup_HelpToolSource$


  Procedure.s HelpTool_DefaultSource()
    ProcedureReturn PureBasicPath$ + "Help" + #Separator + "Help.zip"
  EndProcedure


  Procedure.s HelpTool_Language(Source$)
    Select UCase(CurrentLanguage$)
      Case "FRANCAIS"
        Language$ = "French"
      Case "DEUTSCH"
        Language$ = "German"
      Default
        Language$ = "English"
    EndSelect

    ; Fallback to english if the help isn't available in the IDE language
    If Right(Source$, 1) <> "/" And Right(Source$, 1) <> "\"
      Source$ + #Separator
    EndIf
    If FileSize(Source$) = -2 And FileSize(Source$ + Language$) <> -2
      Language$ = "English"
    EndIf

    ProcedureReturn Language$
  EndProcedure


  Procedure.s HelpTool_ImageBase64(Image)
    If IsImage(Image)
      *Buffer = EncodeImage(Image, #PB_ImagePlugin_PNG)
      If *Buffer
        Result$ = Base64Encoder(*Buffer, MemorySize(*Buffer))
        FreeMemory(*Buffer)
      EndIf
    EndIf

    ProcedureReturn Result$
  EndProcedure


  Procedure.s HelpTool_HtmlColor(Color)
    ProcedureReturn "#" + RSet(Hex(Red(Color)), 2, "0") + RSet(Hex(Green(Color)), 2, "0") + RSet(Hex(Blue(Color)), 2, "0")
  EndProcedure


  ; Mix Color1 with Color2 (Ratio = 0.0 -> Color1, 1.0 -> Color2)
  ;
  Procedure HelpTool_MixColor(Color1, Color2, Ratio.f)
    ProcedureReturn RGB(Red(Color1)   + (Red(Color2)   - Red(Color1))   * Ratio,
                        Green(Color1) + (Green(Color2) - Green(Color1)) * Ratio,
                        Blue(Color1)  + (Blue(Color2)  - Blue(Color1))  * Ratio)
  EndProcedure


  ; Examples syntax highlighting, with the IDE highlighting engine
  ;
  Global *HelpTool_HtmlBuffer, HelpTool_HtmlSize, HelpTool_HtmlLength

  Procedure HelpTool_HtmlWrite(*Text.Ascii, Length, Escape)
    If HelpTool_HtmlLength + Length * 5 > HelpTool_HtmlSize ; worst case: every char escaped as "&amp;"
      HelpTool_HtmlSize = (HelpTool_HtmlLength + Length * 5) * 2
      *HelpTool_HtmlBuffer = ReAllocateMemory(*HelpTool_HtmlBuffer, HelpTool_HtmlSize, #PB_Memory_NoClear)
    EndIf

    *Output = *HelpTool_HtmlBuffer + HelpTool_HtmlLength
    *TextEnd = *Text + Length
    While *Text < *TextEnd
      If Escape And *Text\a = '<'
        PokeS(*Output, "&lt;", -1, #PB_Ascii|#PB_String_NoZero) : *Output + 4
      ElseIf Escape And *Text\a = '>'
        PokeS(*Output, "&gt;", -1, #PB_Ascii|#PB_String_NoZero) : *Output + 4
      ElseIf Escape And *Text\a = '&'
        PokeS(*Output, "&amp;", -1, #PB_Ascii|#PB_String_NoZero) : *Output + 5
      Else
        PokeA(*Output, *Text\a) : *Output + 1
      EndIf
      *Text + 1
    Wend
    HelpTool_HtmlLength = *Output - *HelpTool_HtmlBuffer
  EndProcedure

  Procedure HelpTool_HtmlWriteTag(Tag$)
    *Tag = Ascii(Tag$)
    HelpTool_HtmlWrite(*Tag, MemorySize(*Tag) - 1, #False)
    FreeMemory(*Tag)
  EndProcedure

  ; The buffer is UTF-8, written byte by byte, so a token can't split a multi-byte character
  ;
  Procedure HelpTool_ColorCodeCallback(*StringStart, Length, *Color, IsBold, TextChanged)
    Style = *Color
    If Style >= #STYLE_FirstIssue ; issue highlighting in comments (ie: 'TODO')
      Style = 3
    EndIf

    If Style > 1 And Style <= 16
      HelpTool_HtmlWriteTag("<span class='s" + Str(Style) + "'>")
      HelpTool_HtmlWrite(*StringStart, Length, #True)
      HelpTool_HtmlWriteTag("</span>")
    Else
      HelpTool_HtmlWrite(*StringStart, Length, #True)
    EndIf
  EndProcedure

  Procedure.s HelpTool_ColorCode(Code$)
    *Buffer = UTF8(Code$)
    If *Buffer
      HelpTool_HtmlLength = 0
      HighlightingEngine(*Buffer, MemorySize(*Buffer) - 1, 0, @HelpTool_ColorCodeCallback(), #False, #True) ; no case correction
      FreeMemory(*Buffer)
      If *HelpTool_HtmlBuffer
        Result$ = PeekS(*HelpTool_HtmlBuffer, HelpTool_HtmlLength, #PB_UTF8|#PB_ByteLength)
      EndIf
    EndIf

    ProcedureReturn Result$
  EndProcedure

  DataSection
    HelpTool_StyleColors: ; Color for the Scintilla styles 1 to 16 (see SetUpHighlightingColors())
    Data.l #COLOR_NormalText, #COLOR_BasicKeyword, #COLOR_Comment, #COLOR_Constant, #COLOR_String, #COLOR_PureKeyword, #COLOR_ASMKeyword, #COLOR_Operator
    Data.l #COLOR_Structure, #COLOR_Number, #COLOR_Pointer, #COLOR_Separator, #COLOR_Label, #COLOR_CustomKeyword, #COLOR_Module, #COLOR_BadBrace
  EndDataSection


  ; Build the help page colors (CSS variables) from the current editor color scheme
  ;
  Procedure.s HelpTool_ThemeColors()
    Background = Colors(#COLOR_GlobalBackground)\DisplayValue
    Text       = Colors(#COLOR_NormalText)\DisplayValue

    ; Title bar: current line color when it's used, or a darker/lighter shade of the background
    If Colors(#COLOR_CurrentLine)\Enabled And Colors(#COLOR_CurrentLine)\DisplayValue <> Background
      TitleBackground = Colors(#COLOR_CurrentLine)\DisplayValue
    Else
      TitleBackground = HelpTool_MixColor(Background, Text, 0.12)
    EndIf

    ; Tables are a bit brighter than the page on light themes (like the original white), and a bit lighter on dark themes
    If (Red(Background) + Green(Background) + Blue(Background)) / 3 >= 128
      TableBackground = HelpTool_MixColor(Background, $FFFFFF, 0.7)
      ColorScheme$ = "light"
    Else
      TableBackground = HelpTool_MixColor(Background, Text, 0.06)
      ColorScheme$ = "dark"
    EndIf

    ; 'color-scheme' is needed, or the webview uses the OS theme for the scrollbars and buttons (dark scrollbars on a light page)
    Css$ = ":root {color-scheme: " + ColorScheme$ + "; "
    Css$ + "--bg:"       + HelpTool_HtmlColor(Background) + "; "
    Css$ + "--text:"     + HelpTool_HtmlColor(Text) + "; "
    Css$ + "--titlebg:"  + HelpTool_HtmlColor(TitleBackground) + "; "
    Css$ + "--codebg:"   + HelpTool_HtmlColor(HelpTool_MixColor(Background, Text, 0.07)) + "; "
    Css$ + "--tablebg:"  + HelpTool_HtmlColor(TableBackground) + "; "
    Css$ + "--optbg:"    + HelpTool_HtmlColor(HelpTool_MixColor(TableBackground, Text, 0.07)) + "; "
    Css$ + "--border:"   + HelpTool_HtmlColor(HelpTool_MixColor(Background, Text, 0.25)) + "; "
    Css$ + "--notebg:"   + HelpTool_HtmlColor(HelpTool_MixColor(Background, RGB(255, 136, 0), 0.5)) + "; " ; orange note (platform-specific functions, errors), readable with the theme text color
    Css$ + "--link:"     + HelpTool_HtmlColor(Colors(#COLOR_BasicKeyword)\DisplayValue) + "; "
    Css$ + "--constant:" + HelpTool_HtmlColor(Colors(#COLOR_Constant)\DisplayValue) + "; "
    Css$ + "--function:" + HelpTool_HtmlColor(Colors(#COLOR_PureKeyword)\DisplayValue) + "; "
    Css$ + "--keyword:"  + HelpTool_HtmlColor(Colors(#COLOR_BasicKeyword)\DisplayValue) + "; "
    Css$ + "--userlib:"  + HelpTool_HtmlColor(Colors(#COLOR_CustomKeyword)\DisplayValue) + ";}"

    ; Examples syntax highlighting (see HelpTool_ColorCode()): one class per Scintilla style (see SetUpHighlightingColors())
    If EnableColoring
      Restore HelpTool_StyleColors
      For Style = 1 To 16
        Read.l ColorIndex
        Css$ + " pre.ex .s" + Str(Style) + " {color:" + HelpTool_HtmlColor(Colors(ColorIndex)\DisplayValue) + ";"
        If EnableKeywordBolding And (Style = 2 Or Style = 14)
          Css$ + " font-weight:bold;"
        EndIf
        Css$ + "}"
      Next Style
    EndIf

    ProcedureReturn Css$
  EndProcedure


  ; Called by the help when 'Load' or 'Run' is clicked on an example
  ;
  Procedure HelpTool_OpenCode(File$, Code$, Run)

    If File$ ; Real example file: load it directly, so relative paths to its data are working
      If LoadSourceFile(File$) = 0
        ProcedureReturn
      EndIf

    Else ; Code snippet: put it in a new source
      TempFile$ = GetTemporaryDirectory() + "PB_HelpExample.pb"
      File = CreateFile(#PB_Any, TempFile$, #PB_UTF8)
      If File = 0
        ProcedureReturn
      EndIf
      WriteStringFormat(File, #PB_UTF8)
      WriteString(File, Trim(Code$, #LF$))
      CloseFile(File)

      NewSource("", #False)
      LoadTempFile(TempFile$)
      DeleteFile(TempFile$)
      UpdateSourceStatus(1)
      HistoryEvent(*ActiveSource, #HISTORY_Create)
    EndIf

    If Run And *ActiveSource And *ActiveSource <> *ProjectInfo
      ForceDebugger = 0   ; use the source file setting
      ForceNoDebugger = 0
      CompileRun(#False)
    EndIf

  EndProcedure


  ; Called by the help when 'Edit' is clicked, to edit the help source of the current page
  ;
  Procedure HelpTool_EditFile(File$, Line)
    If LoadSourceFile(File$) And *ActiveSource And IsEqualFile(*ActiveSource\FileName$, File$)
      ChangeActiveLine(Line, -5)
    EndIf
  EndProcedure


  ; Display the given help page in the tool, opening the tool if needed (Page$ is a page name or a path as used
  ; in the html help, ie: "2DDrawing/Box.html"). Displays the home page and returns #False if the page doesn't exist
  ;
  Procedure HelpTool_DisplayPage(Page$)
    ActivateTool("HelpTool") ; switches to the tool, or opens it in its own window if it's not in the tools panel
    If HelpToolOpen = #False
      ProcedureReturn #False
    EndIf

    Page$ = ReplaceString(Page$, "\", "/")
    Name$ = LCase(GetFilePart(Page$, #PB_FileSystem_NoExtension))
    If Name$ = ""
      Name$ = "reference"
    ElseIf Name$ = "index" ; library index page: "2DDrawing/index.html"
      Name$ = "lib_" + LCase(GetFilePart(RTrim(GetPathPart(Page$), "/")))
    EndIf

    If HelpTool::ShowPage(Name$)
      ProcedureReturn #True
    EndIf

    HelpTool::ShowPage("reference")
    ProcedureReturn #False
  EndProcedure


  CompilerIf #CompileWindows = 0 ; Windows has its own version, which also handles the API, ASM and user libraries help (WindowsHelp.pb)

    Procedure DisplayHelp(CurrentWord$)
      If CurrentWord$ = ""
        Page$ = ""
      ElseIf CheckPureBasicKeyWords(CurrentWord$) <> ""
        Page$ = CheckPureBasicKeyWords(CurrentWord$)
      Else
        Page$ = CurrentWord$ ; command name, which is the page name in the help tool
      EndIf

      HelpTool_DisplayPage(Page$)
    EndProcedure

  CompilerEndIf


  Procedure HelpTool_Timer()
    HelpTool::Timer()
  EndProcedure


  Procedure Help_CreateFunction(*Entry.ToolsPanelEntry)

    Source$ = HelpToolSource$
    If Source$ = ""
      Source$ = HelpTool_DefaultSource()
    EndIf

    CompilerIf #CompileWindows
      OS$ = "Windows"
    CompilerElseIf #CompileLinux
      OS$ = "Linux"
    CompilerElse
      OS$ = "MacOS"
    CompilerEndIf

    HelpTool::OpenCodeCallback = @HelpTool_OpenCode()
    HelpTool::EditFileCallback = @HelpTool_EditFile()
    HelpTool::ColorCodeCallback = @HelpTool_ColorCode()
    ; User libraries in the contents tree: same color as in the help pages, when the tree uses the IDE colors
    If (*Entry\IsSeparateWindow = 0 Or NoIndependentToolsColors = 0) And ToolsPanelUseColors
      UserLibColor = Colors(#COLOR_CustomKeyword)\DisplayValue
    Else
      UserLibColor = $008800
    EndIf
    If *Entry\IsSeparateWindow = 0 Or NoIndependentToolsColors = 0
      HelpTool::ApplyColorsCallback = @ToolsPanel_ApplyColors()
    Else
      HelpTool::ApplyColorsCallback = 0
    EndIf
    HelpTool::SetColors(HelpTool_ThemeColors(), UserLibColor)
    HelpTool::SetImages(#IMAGE_Help_Back, #IMAGE_Help_Forward, #IMAGE_Help_Home, #IMAGE_Help_Edit, #IMAGE_Help_Index, HelpTool_ImageBase64(#IMAGE_Help_LoadCode), HelpTool_ImageBase64(#IMAGE_Help_RunCode))
    HelpTool::Setup(HelpTool_Language(Source$), OS$, Source$, PureBasicPath$ + "PureLibraries" + #Separator + "UserLibraries" + #Separator, PureBasicPath$ + "Examples" + #Separator)

    If *Entry\IsSeparateWindow
      HelpTool::Create(*Entry\ToolWindowID)
    Else
      HelpTool::Create(#WINDOW_Main)
    EndIf

    ; Reload the help when its source is modified (help edition)
    AddWindowTimer(#WINDOW_Main, #TIMER_HelpTool, 1000)
    BindEvent(#PB_Event_Timer, @HelpTool_Timer(), #WINDOW_Main, #TIMER_HelpTool)

    HelpToolOpen = #True

  EndProcedure

  Procedure Help_DestroyFunction(*Entry.ToolsPanelEntry)

    RemoveWindowTimer(#WINDOW_Main, #TIMER_HelpTool)
    UnbindEvent(#PB_Event_Timer, @HelpTool_Timer(), #WINDOW_Main, #TIMER_HelpTool)
    HelpTool::Destroy()

    HelpToolOpen = #False

  EndProcedure


  Procedure Help_ResizeHandler(*Entry.ToolsPanelEntry, PanelWidth, PanelHeight)

    HelpTool::Resize(PanelWidth, PanelHeight)

  EndProcedure

  Procedure Help_EventHandler(*Entry.ToolsPanelEntry, EventGadgetID)

    HelpTool::GadgetEvent(EventGadgetID, EventType())

  EndProcedure


  Procedure Help_PreferenceLoad(*Entry.ToolsPanelEntry)

    PreferenceGroup("HelpTool")
    HelpToolSource$ = ReadPreferenceString("HelpSource", "")

  EndProcedure


  Procedure Help_PreferenceSave(*Entry.ToolsPanelEntry)

    PreferenceComment("")
    PreferenceGroup("HelpTool")
    WritePreferenceString("HelpSource", HelpToolSource$)

  EndProcedure


  Procedure Help_PreferenceStart(*Entry.ToolsPanelEntry)

    ; Use the backup variable during the PReferences changing
    Backup_HelpToolSource$ = HelpToolSource$

  EndProcedure


  Procedure Help_PreferenceApply(*Entry.ToolsPanelEntry)

    ; put the backup variable back
    HelpToolSource$ = Backup_HelpToolSource$

  EndProcedure



  Procedure Help_PreferenceCreate(*Entry.ToolsPanelEntry)

    y = 10

    TextGadget(#GADGET_Preferences_HelpSourceText, 10, y, 300, 25, Language("Help","HelpSource"))
    GetRequiredSize(#GADGET_Preferences_HelpSourceText, @Width, @Height)
    ResizeGadget(#GADGET_Preferences_HelpSourceText, 10, y, 300, Height)
    y + Height + 5

    ButtonGadget(#GADGET_Preferences_HelpSourceBrowse, 0, 0, 0, 0, "...")
    GetRequiredSize(#GADGET_Preferences_HelpSourceBrowse, @Width, @Height)
    StringGadget(#GADGET_Preferences_HelpSource, 10, y, 300-Width-5, Height, Backup_HelpToolSource$)
    ResizeGadget(#GADGET_Preferences_HelpSourceBrowse, 310-Width, y, Width, Height)

  EndProcedure


  Procedure Help_PreferenceDestroy(*Entry.ToolsPanelEntry)

    Backup_HelpToolSource$ = GetGadgetText(#GADGET_Preferences_HelpSource)

  EndProcedure


  Procedure Help_PreferenceEvents(*Entry.ToolsPanelEntry, EventGadgetID)

    If EventGadgetID = #GADGET_Preferences_HelpSourceBrowse
      Path$ = GetGadgetText(#GADGET_Preferences_HelpSource)
      If Path$ = ""
        Path$ = HelpTool_DefaultSource()
      EndIf
      If LCase(GetExtensionPart(Path$)) = "zip" ; help archive: start in its folder
        Path$ = GetPathPart(Path$)
      EndIf

      Path$ = PathRequester(Language("Help","HelpSource"), Path$)
      If Path$
        SetGadgetText(#GADGET_Preferences_HelpSource, Path$)
      EndIf
    EndIf

  EndProcedure

  Procedure Help_PreferenceChanged(*Entry.ToolsPanelEntry, IsConfigOpen)

    If IsConfigOpen
      If HelpToolSource$ <> GetGadgetText(#GADGET_Preferences_HelpSource)
        ProcedureReturn 1
      EndIf

    Else
      If HelpToolSource$ <> Backup_HelpToolSource$
        ProcedureReturn 1
      EndIf

    EndIf

    ProcedureReturn 0
  EndProcedure


  ;- Initialisation code
  ; This will make this Tool available to the editor
  ;
  Help_VT.ToolsPanelFunctions

  Help_VT\CreateFunction      = @Help_CreateFunction()
  Help_VT\DestroyFunction     = @Help_DestroyFunction()
  Help_VT\ResizeHandler       = @Help_ResizeHandler()
  Help_VT\EventHandler        = @Help_EventHandler()
  Help_VT\PreferenceLoad      = @Help_PreferenceLoad()
  Help_VT\PreferenceSave      = @Help_PreferenceSave()
  Help_VT\PreferenceStart     = @Help_PreferenceStart()
  Help_VT\PreferenceApply     = @Help_PreferenceApply()
  Help_VT\PreferenceCreate    = @Help_PreferenceCreate()
  Help_VT\PreferenceDestroy   = @Help_PreferenceDestroy()
  Help_VT\PreferenceEvents    = @Help_PreferenceEvents()
  Help_VT\PreferenceChanged   = @Help_PreferenceChanged()


  AddElement(AvailablePanelTools())

  AvailablePanelTools()\FunctionsVT          = @Help_VT
  AvailablePanelTools()\NeedPreferences      = 1 ; the help source is stored in the "HelpTool" group
  AvailablePanelTools()\NeedConfiguration    = 1
  AvailablePanelTools()\PreferencesWidth     = 320
  AvailablePanelTools()\PreferencesHeight    = 80
  AvailablePanelTools()\NeedDestroyFunction  = 1
  AvailablePanelTools()\ToolID$              = "HelpTool"
  AvailablePanelTools()\PanelTitle$          = "HelpToolShort"
  AvailablePanelTools()\ToolName$            = "HelpToolLong"

CompilerEndIf
