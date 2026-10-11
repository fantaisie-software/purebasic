; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; Cross-platform help tool: reads the documentation sources (.txt, DocMaker format) directly
; and renders them in a WebViewGadget.
;
; When this file is compiled directly (main file), it runs as a standalone tool (own window,
; PBHelp.ini settings). When included in the IDE, it's embedded in the tools panel via XmlDialogGadget().
;

DeclareModule pbhelp
  #Standalone = #PB_Compiler_IsMainFile

  ; Callbacks used by the IDE to load/run the examples and edit the help sources
  Prototype ProtoOpenCode(File$, Code$, Run) ; File$ is a real file to load, or Code$ is the code to put in a new tab
  Prototype ProtoEditFile(File$, Line)
  Prototype ProtoApplyColors(Gadget) ; IDE colors/font for the contents tree and the search gadgets
  Prototype.s ProtoColorCode(Code$)  ; IDE syntax highlighting of an example: returns the html code (special characters escaped)
  Global OpenCodeCallback.ProtoOpenCode, EditFileCallback.ProtoEditFile, ApplyColorsCallback.ProtoApplyColors, ColorCodeCallback.ProtoColorCode

  Declare init(lg.s,os.s)
  Declare affiche(page.s)
  Declare.s PbtoHtml(nom.s)
  Declare CheckFile()
  Declare listfilemef()
  Declare.s inithelp(source.s,destination.s)
  Declare.s inithelpzip(source.s,destination.s)

  ; IDE embedding
  Declare setup(lg.s, os.s, source.s, userlibsource.s, examplesource.s)
  Declare setimages(back, forward, home, edit, index, open.s, run.s)
  Declare setcolors(css.s, userlibcolor=$008800)
  Declare create(window)
  Declare destroy()
  Declare resize(width, height)
  Declare gadgetevent(gadget, type)
  Declare timer()
  Declare show(page.s)
EndDeclareModule

Module pbhelp
EnableExplicit

Declare affiche(page.s)
Declare initui()
Declare packinfo(nzip)
Declare.s cvhtml(txt.s,lf=0)

#EventJsMessage = #PB_Event_FirstCustomValue + 500 ; WebView callback actions are deferred to the event loop
#ForceIEMode    = #False ; Windows: #True to test the degraded mode (WebGadget/Internet Explorer) even if WebView2 is available

Structure spage
  titre.s
  nom.s
  fichier.s
  pos.l     ; position
  src.s     ; source
  nav.s     ; navigation
  List sp.i()
  sommaire.w
  userlib.s
  libdest.s
EndStructure

Structure sbalise
  hbalise.s
  html.b    ; si 1: le text est du html
  param.b   ; 1: parametre fct  2: parametre opt  3 :fin parametre  
  titre.b   ; titre niveau
  pre.w     ; balise <pre>:1, </pre>:-1
EndStructure

Global NewMap balise.sbalise()
Global NewList osspe.s()
Global NewMap mosspe.s()
Global NewList page.spage()
Global NewMap ULdest.s()
Global NewMap *pid.spage()
Global NewList pilepage.s()
Global event,etype,nzip,Archive
Global.s g=Chr(34),Rep,RepL,RepUL,fic,mot,html,style,langue,os,apage,erreur,helpsource
Global.s txt,lien,ht,*page.spage,*pagesel.spage, pacceuil
Global.s couleurs
Global couleurul=$008800 ; couleur des bibliotheques utilisateur dans le sommaire
Global.s dos,repex ; dos: dossier du fichier de la page courante, repex: dossier des exemples (IDE)
Global editiondate.q
Global NewList jsmessages.s()
Global iemode ; Windows: WebView2 indisponible, affichage degrade dans un WebGadget (Internet Explorer)
; ---------- pref
Global waide,waidex,waidey,waidedx,waidedy
; ---------- UI
Global gonglet,gsommaire,grec,grecliste,gweb,gacc,gprec,gsuiv,glangue,gos,gediter,gsep,gdialog,groot,gsommairevisible=-1
Global imgprec,imgsuiv,imgacc,imgediter,imgsommaire
Global.s icoouvrir="&#128194;",icoexecuter="&#9654;" ; boutons des exemples (remplacés par les icônes de l'IDE)
; ---------- traduction
Global.s listlg,    _Sommairec,_Valeurr,_Aucune,_Remarques,_Exemple,_Voiraussi,_OSSupportes,_Syntaxe,_Description,_Generalites,_Parametres,_tester,_ouvrir,_executer
Global.s _Aide,_Sommaire,_Recherche,_acceuil,_prec,_suiv,_editer,_sommairevisible
Global.s _Deprecie,_Deprecietxt,_Indexcommandes,_Constantes,_Fonctionsos

listlg="English,French,German";,Italian,Spanish,Russian"

Procedure initlang()
  Protected nl
  nl= CountString(Left(listlg,FindString(listlg,langue)),",")+1  
  Macro lg(lg):StringField(lg,nl,","):EndMacro
  
  _Sommairec  =lg("Command index,Sommaire des commandes,Übersicht über die Bestellungen,Riepilogo dell'ordine,Resumen del pedido,Сводка заказов")
  _Valeurr=lg("Return value,Valeur de retour,Rückgabewert,Valore di ritorno,Valor de retorno,Возвращаемое значение")
  _Aucune=lg("None,Aucune,Keine,Nessuno,Ninguno,Нет")
  _Remarques=lg("Remarks,Remarques,Bemerkungen,Osservazioni,Observaciones,Примечания")
  _Exemple=lg("Example,Exemple,Beispiel,Esempio,Ejemplo,Пример")
  _Voiraussi=lg("See also,Voir aussi,Siehe auch,Vedi anche,Véase también,См. также")
  _OSSupportes=lg("Supported OS,OS Supportés,Unterstützte OS,Sistemi operativi supportati,SO soportados,Поддерживаемые ОС")
  _Syntaxe=lg("Syntax,Syntaxe,Syntax,Sintassi,Sintaxis,Синтаксис")
  _Description=lg("Description,Description,Beschreibung,Descrizione,Descripción,Описание")
  _Generalites=lg("General,Généralités,Allgemeines,Generale,General,Общие")
  _Parametres=lg("Parameters,Paramètres,Parameter,Parametri,Parámetros,Параметры")
  _Deprecie=lg("Deprecated,Dépréciée,Veraltet")
  _Deprecietxt=lg("This function is deprecated and may be removed in a future version. It should not be used in newly written code.,"+
                  "Cette fonction est dépréciée et sera peut-être supprimée dans une future version. Elle ne doit pas être utilisée dans du nouveau code.,"+
                  "Diese Funktion ist veraltet und könnte in späteren Versionen entfernt werden. Sie sollte in neuem Code nicht mehr verwendet werden.")
  _Indexcommandes=lg("Commands Index,Index des commandes,Befehlsindex")
  _Constantes=lg("PureBasic Constants,Constantes PureBasic,PureBasic-Konstanten")
  _Fonctionsos=lg("Platform-dependant Functions,Fonctions dépendantes de la plateforme,Plattformabhängige Funktionen")
  ; ui
  _Aide=lg("Help,Aide,Hilfe,Aiuto,Ayuda,Справка")
  _Sommaire=lg("Contents,Sommaire,Inhaltsverzeichnis,Contenuto,Contenido,Содержание")
  _Recherche=lg("Search,Recherche,Suche,Ricerca,Búsqueda,Поиск")
  _acceuil=lg("Home,Accueil,Startseite")
  _prec=lg("Back,Précédent,Zurück")
  _suiv=lg("Forward,Suivant,Vorwärts")
  _editer=lg("Edit help source,Editer la source de l'aide,Hilfequelle bearbeiten")
  _sommairevisible=lg("Show/hide the index,Afficher/masquer le sommaire,Inhaltsverzeichnis ein-/ausblenden")
  ; ui mode edition
  _tester=lg("Test,Tester,testen")
  _ouvrir=lg("Open,Ouvrir,öffnen")
  _executer=lg("Run,Executer,ausführen")
EndProcedure

; couleurs de la page (variables CSS), remplacées par celles du thème de l'IDE (setcolors())
couleurs=":root {color-scheme: light; --bg:#fed; --text:#000; --titlebg:#ff8; --codebg:#edc; --tablebg:#fff; --optbg:#eee; --border:#0002;"+
         " --notebg:#f80; --link:#00f; --constant:#a00; --function:#088; --keyword:#088; --userlib:#080;}"
style="body {background-color: var(--bg); color: var(--text); font-family: Arial, Helvetica, sans-serif; font-size: 10pt;margin-left:30px}"+
      "h2 {position: sticky;z-index: 10;font-size:20pt; font-weight: normal; top:0; text-align: center; background-color:var(--titlebg);padding: 5px; margin:-8px -8px 8px -30px; box-shadow: 0px 5px 5px #00000088;}"+
      "h3 {margin-left:-20px;}"+
      "a, a:visited, a:active {font-size: 10pt; color: var(--link);}"+
      ".nav, .nav a {color: var(--link); font-size: 13px;}"+
      ".cst {color: var(--constant);} .fct {color: var(--function);} .kw {color: var(--keyword); font-weight: bold;} .ul {color: var(--userlib);}"+
      ".opt {background-color: var(--optbg);}"+
      ".note {background-color: var(--notebg);} div.note {font-size: 16px;}"+
      ".deprecated {padding: 5px; margin: 5px 0px 10px; border: 1px solid var(--border);} .deprecated b {color: #e00;}"+
      ".found {background-color: #ff0; color: #000;}"+
      "img {box-shadow: 2px 2px 5px #0008;}"+
      "button img {box-shadow: none; width: 16px; height: 16px; vertical-align: middle;}"+
      "pre {overflow: auto; font-family:consolas, Courier, monospace; font-size: 9pt;}"+
      "pre.ex {position: relative; min-height: 26px; padding: 5px 65px 5px 5px; background-color:var(--codebg);border-style: solid; border-width:1px; border-color:var(--border);}"+
      "button {box-shadow: 2px 2px 2px #0008;}"+
      ".butcode {display: flex; position: absolute; top:4px; right:5px; gap:5px; z-index: 1;}"+
      "table {box-shadow: 2px 2px 3px #0008;background-color: var(--tablebg);}"+
      "table, th, td {border-collapse: collapse;padding:2px 10px 2px;font-size: 10pt;border-color:var(--border);}"+
      "table.param {width:100%;  border-spacing: 0px; border-style: none; }"+
      "table.param td { border-width: 1px; padding: 6px; border-style: solid;  vertical-align: top;}"

;==================================================================================================================================================

Procedure WMid(add,pos,txt.s); write mid by ref
PokeS(add+(pos-1)*2,txt,-1,#PB_String_NoZero ) 
EndProcedure

Procedure.s RMid(add,pos,length); read mid by ref
ProcedureReturn PeekS(add+(pos-1)*2,length) 
EndProcedure

Procedure FindStringRev(t.s,find.s,p=0,mode=#PB_String_CaseSensitive); reverse
  Protected l=Len(find)
  If p=0:p=Len(t):EndIf
  Repeat
    If p=0 Or rMid(@t,p,L)=find:Break:EndIf
    p-1
  ForEver
  ProcedureReturn p
EndProcedure

Procedure.s Stringparse(t.s,before.s,after.s,pi=0,contain.s="",*pos.integer=0)
  Protected pf
  If contain>""
    pi=FindString(t,contain,pi):If pi=0:ProcedureReturn :EndIf
    pi=FindStringRev(t,before,pi)
  Else
    pi=FindString(t,before,pi+1)
  EndIf
  If pi=0:ProcedureReturn:EndIf 
  pf=FindString(t,after,pi+1):If pf=0:pf=Len(t):EndIf
  pi+Len(before)
  If *pos:*pos\i=pf:EndIf
  ProcedureReturn rMid(@t,pi,pf-pi)
EndProcedure

Procedure WriteTextFile(name.s,txt.s,format=#PB_UTF8)
  Protected n
  If FileSize(name)>=0:DeleteFile(name):EndIf
  n=CreateFile(-1,name,format):If n=0:Debug "WriteTextFile !!!":ProcedureReturn 0:EndIf
  WriteString(n,txt)
  CloseFile(n)
  ProcedureReturn 1
EndProcedure

Procedure.s ReadTextFile(name.s,option=#PB_UTF8,errormessage.b=1)
  Protected txt.s,n,f
  n=ReadFile(-1,name,option|#PB_File_SharedRead):If n=0:If errormessage:MessageRequester("Error loading :","file : "+name):EndIf: ProcedureReturn "":EndIf
  f=ReadStringFormat(n)
  txt=ReadString(n,option|#PB_File_IgnoreEOL)
  CloseFile(n)   
  ProcedureReturn txt
EndProcedure

Procedure FileList(List Files.s(), Dir.s,Lext.s="",relatif=1,recursive.b=1,dirlist.b=0,init=1)
  Protected d, name.s, sep.s="/",isdir
  Static pos
  
  If Right(Dir, 1) <> sep:Dir + sep:EndIf
  If init:ClearList(Files()):Lext.s=","+LCase(Lext)+",":pos=Len(dir)*relatif+1:EndIf
  
  D = ExamineDirectory(#PB_Any, Dir,""):If d=0:ProcedureReturn:EndIf
  While NextDirectoryEntry(D)
    name=DirectoryEntryName(D)
    If name="." Or name="..":Continue:EndIf
    isdir=Bool(DirectoryEntryType(D)= #PB_DirectoryEntry_Directory)
    If dirlist
      If isdir:AddElement(Files()):Files() = Mid(Dir + name,pos):EndIf
    Else
      If isdir=0 And(Lext=",," Or FindString(Lext,","+LCase(GetExtensionPart(name))+",")):AddElement(Files()):Files() = Mid(Dir + name,pos):EndIf
    EndIf
    If isdir And recursive:FileList(files(),dir+name,Lext,relatif,recursive,dirlist,0):EndIf
  Wend
  FinishDirectory(D)
EndProcedure

;----------- pack
Structure szip
  nom.s
  tailled.l
EndStructure

Procedure packinfo(nzip)
  Global NewMap zipfiles.szip()
  Protected nom.s
  
    If ExaminePack(nzip)
      While NextPackEntry(nzip)
        If PackEntryType(nzip)=#PB_Packer_File
          nom=PackEntryName(nzip)
          AddMapElement(zipfiles(),nom)
          zipfiles()\nom=nom
          zipfiles()\tailled=PackEntrySize(nzip,#PB_Packer_UncompressedSize)      
        EndIf
      Wend
EndIf
EndProcedure

Procedure.s _ReadTextFile(name.s,option=#PB_UTF8,errormessage.b=1) ; lecture depuis disque ou zip
  Protected *mem,ret.s
  If Archive
    If FindMapElement(zipfiles(),name)=0:Debug name:If errormessage:MessageRequester("Error loading :","file : "+name):EndIf:ProcedureReturn"":EndIf
    With zipfiles(name)
      *mem = AllocateMemory(\tailled+2) ; +2: zero de fin de chaine pour PeekS()
      UncompressPackMemory(nzip,*mem,\tailled,name)
    EndWith
    ret=PeekS(*mem, -1, option)
    FreeMemory(*mem)
    ProcedureReturn ret
  Else
    ProcedureReturn ReadTextFile(rep+name,option,errormessage)
  EndIf
EndProcedure

Procedure _ReadBinaryFile(name.s) ; lecture depuis disque ou zip
  Protected *mem,n,length
  
  If Archive
    If FindMapElement(zipfiles(),name)=0:ProcedureReturn 0:EndIf
    With zipfiles(name)
      length = \tailled
      *mem = AllocateMemory(length)
      UncompressPackMemory(nzip,*mem,length,name)      
    EndWith
  Else
    n=ReadFile(-1,rep+name):If n=0:ProcedureReturn 0:EndIf
    length = Lof(n)
    *mem = AllocateMemory(length)
    ReadData(n, *mem, length)
    CloseFile(n)   
  EndIf
  ProcedureReturn *mem
EndProcedure

Procedure _FileList(List Files.s(), Dir.s,Lext.s="",recursive.b=1,dirlist.b=0,init=1) ; liste fichiers depuis disque ou zip
  Protected dirl,fn.s
  If Archive
    ClearList(Files()):Lext.s=","+LCase(Lext)+","
    dirl=Len(dir)
    ForEach zipfiles()
      fn=zipfiles()\nom
      If Left(fn,dirl)=dir And(Lext=",," Or FindString(Lext,","+LCase(GetExtensionPart(fn))+",")):AddElement(Files()):Files()=Mid(fn,dirl+1):EndIf
    Next
  Else
    FileList(Files(),rep+dir,Lext,recursive)
  EndIf
EndProcedure
;==================================================================================================================================================

Procedure initbalise() ; definition des balises PB (correspondance HTML)
  Macro defbalise(mhtml,mparam,mtitre,nom,code)
    AddMapElement(balise(),nom):balise()\hbalise=code:balise()\html=mhtml:balise()\param=mparam:balise()\titre=mtitre
    If FindString(code,"<pre"):balise()\pre=1:ElseIf FindString(code,"</pre"):balise()\pre=-1:EndIf
  EndMacro
  ; le html contient les sous balises:
  ; $p1 : 1er  parametre de la balise PB 
  ; $p2 : 2eme parametre de la balise PB 
  ; $lg : ligne complete
  ; $ex : code d'exemple
  ; $im : image
  ; $ose :os specifique exemple
  
  defbalise(0,0,0,"linebreak","<br>")
  defbalise(0,0,0,"red","<font color=Red>$p1</font>")
  defbalise(0,0,0,"green","<font color=Green>$p1</font>")
  defbalise(0,0,0,"blue","<font color=Blue>$p1</font>")
  defbalise(0,0,0,"orange","<font color=Orange>$p1</font>")
  defbalise(0,0,0,"bold","<b>$p1</b>")
  defbalise(0,0,0,"underline","<u>$p1</u>")
  defbalise(0,0,0,"constantcolor","<font class='cst'>$p1</font>")
  defbalise(0,0,0,"functioncolor","<font class='fct'>$p1</font>")
  defbalise(1,0,0,"formatif","$lg")
  defbalise(2,0,0,"formatelse","")
  defbalise(0,0,0,"formatendif","")
  defbalise(1,0,0,"html","")
  defbalise(0,0,0,"endhtml","")
  defbalise(0,0,0,"code","<pre class='ex'><div class='butcode'><button title='"+_ouvrir+"' onclick='jsmessage("+g+"co:$ex"+g+")'>"+icoouvrir+"</button><button title='"+_executer+"' onclick='jsmessage("+g+"cr:$ex"+g+")'>"+icoexecuter+"</button></div>")
  defbalise(0,0,0,"endcode","</pre>")
  defbalise(0,0,0,"os","")
  defbalise(0,0,0,"endos","")
  defbalise(0,0,0,"fixedfont","<pre>")
  defbalise(0,0,0,"endfixedfont","</pre>")
  defbalise(0,0,1,"indent","<blockquote>")
  defbalise(0,0,1,"endindent","</blockquote>")        
  defbalise(0,0,0,"keyword","<font class='kw'>$p1</font>")
  defbalise(0,0,0,"image","$im<br>")
  defbalise(0,0,0,"examplefile","$ose<button title='"+_ouvrir+"' onclick='jsmessage("+g+"fo:$lg"+g+")'>"+icoouvrir+"</button> <button title='"+_executer+"' onclick='jsmessage("+g+"fr:$lg"+g+")'>"+icoexecuter+"</button> $lg")
  
  defbalise(0,0,1,"library","")
  defbalise(0,0,1,"section","<h3>$lg</h3>")   
  defbalise(0,0,1,"overview","<h3>"+_Generalites+"</h3>")
  defbalise(0,0,1,"commandlist","<h3>"+_Sommairec+"</h3>")
  defbalise(0,3,1,"returnvalue","<h3>"+_Valeurr+"</h3>")
  defbalise(0,3,1,"noreturnvalue","<h3>"+_Valeurr+"</h3>"+_Aucune+".")
  defbalise(0,3,1,"remarks","<h3>"+_Remarques+"</h3>")
  defbalise(0,0,1,"example","<h3>"+_Exemple+"</h3>")
  defbalise(0,0,1,"seealso","<h3>"+_Voiraussi+"</h3>")
  ;defbalise(0,0,1,"supportedos","<h3>"+_OSSupportes+"</h3>")
  defbalise(0,0,1,"supportedos","")
  defbalise(0,0,1,"function","<h3>"+_Syntaxe+"</h3><pre>$p1")
  defbalise(0,0,1,"syntax","<h3>"+_Syntaxe+"</h3><pre>")
  defbalise(0,0,1,"description","</pre><h3>"+_Description+"</h3>")
  defbalise(0,0,0,"deprecated","<div class='deprecated'><b>"+_Deprecie+"</b><br>"+_Deprecietxt+"</div>")
  defbalise(0,1,1,"parameter","")
  defbalise(0,2,1,"optionalparameter","")
  defbalise(0,3,1,"noparameters","")
  
  defbalise(0,0,0,"internetlink" ,"<a href='$p1'>$p2</a>")
  defbalise(0,0,0,"link"         ,"<a href='#' onclick='jsmessage("+g+"lk:$p1"+g+")'>$p2</a>")
  defbalise(0,0,0,"librarylink"  ,"<a href='#' onclick='jsmessage("+g+"lk:lib_$p1"+g+")'>$p2 </a>")
  defbalise(0,0,0,"fastlink"     ,"<a href='#' onclick='jsmessage("+g+"lk:$p1"+g+")'>$p1 </a>")
  defbalise(0,0,0,"referencelink","<a href='#' onclick='jsmessage("+g+"lk:$p1"+g+")'>$p2 </a>")
  defbalise(0,0,0,"mainguidelink","<a href='#' onclick='jsmessage("+g+"lk:$p1"+g+")'>$p2 </a>")
EndProcedure

Procedure.s imagetohtml(name.s) ; retourne la chaine base64 de l'image
  Protected txt.s,n,sf,*mem,dossierimage.s,ret.s
  *mem=_ReadBinaryFile("HelpPictures/"+name)
  If *mem=0:*mem=_ReadBinaryFile(RepL+"Reference/Images/"+name):EndIf
  If *mem=0:ProcedureReturn "":EndIf
  ret.s="<img src ='Data:image/"+GetExtensionPart(name)+";base64,"+Base64Encoder(*mem, MemorySize(*mem)) +"' />"
  FreeMemory(*mem)
  ProcedureReturn ret
EndProcedure

Procedure.s link(ref.s,txt.s="$")
  ref=LCase(ref)
  ProcedureReturn "<a href='#' onclick='jsmessage("+g+"lk:"+ref+g+")'>"+ReplaceString(txt,"$",*pid(ref)\titre)+"</a>"
EndProcedure

Procedure.s ExtrairePage(che.s,userlib.b=0) ; extrait les pages depuis le fichier (les lib sont ventilées par fcts)
  Protected.s t,nom,tit,lib,fct,listfct,page,fic,l,navigation,prefix,uld
  Protected np,n,niv,pos,p,pi,pf,ppi,ppf=1,fin
  Protected.spage *pp
  NewList fct.s()
  
  fic=GetFilePart(che,#PB_FileSystem_NoExtension)
  If userlib
    t=ReadTextFile(repul+che,#PB_UTF8)
  Else
    t=_ReadTextFile(RepL+che,#PB_UTF8)
  EndIf
  
  pi=FindString(t,"@Title ")
  If pi=0:pi=FindString(t,"@Library "):prefix="lib_":EndIf
  If pi=0:ProcedureReturn:EndIf ; pas un fichier d'aide (ex: readme dans le dossier userlib)
  pi=FindString(t," ",pi)+1
  pf=FindString(t,#LF$,pi)
  tit=Trim(rMid(@t,pi,pf-pi))
  ppf=pf+1
  
  Repeat
    ppi=ppf:ppf=FindString(t,"@Function ",ppi+1):If ppf=0:ppf=Len(t)+1:fin=1:EndIf
    page=Mid(t,ppi,ppf-ppi)
    AddElement(page())
    
    If np=0
      nom=prefix+LCase(fic)
      *pp=page()
    Else
      l=Left(page,FindString(page,#LF$)):l=ReplaceString(l,"(d)",""):l=ReplaceString(l,"(.d)",""); bug math
      pf=FindString(l,"(")
      pi=FindStringRev(l," ",pf)
      fct=Mid(l,pi+1,pf-pi-1)
      If FindString(fct,"."):Debug "!!!!!!!!!!!! "+fct:EndIf
      tit=fct
      nom=LCase(fct)
      p=FindString(page,"@LibraryDestination"):If p:uld=Stringparse(page,"tion",#LF$,p):page=ReplaceString(page,"@LibraryDestination"+uld+#LF$,""):ULdest(nom)=LCase(Trim(uld)):Else:uld="":EndIf
      AddElement(fct()):fct()=nom
    EndIf
    
    With page()
      \titre=tit
      \fichier=che
      \pos=ppi
      \src=page
      \nom=nom
      If userlib:\userlib=fic:\libdest=uld:EndIf
      *pid(\nom)=page()
    EndWith
   ; Debug "------------------------------------------":Debug page
    np+1
  Until fin
  
  If np
    ;---------------------------------------- ajout de la liste des fcts pour les lib
    ForEach ULdest():If ULdest()=LCase(fic):AddElement(fct()):fct()=MapKey(ULdest()):EndIf:Next
    SortList(fct(),#PB_Sort_Ascending)
    ForEach fct()
      listfct+"@@"+fct()+#LF$
      AddElement(*pp\sp()):*pp\sp()=*pid(fct())
    Next
      ;If userlib:Debug listfct:EndIf
    *pp\src=ReplaceString(*pp\src,"@CommandList","@CommandList"+#LF$+listfct)
    ;---------------------------------------- navigation
    ForEach fct()
      navigation=""
      n+1
      If n>1 :navigation+"< "+link(Mid(StringField(listfct,n-1,#LF$),3)):EndIf
      navigation+" | "+link("lib_"+fic,"$ Index")+" | "
      If n<np-1:navigation+link(Mid(StringField(listfct,n+1,#LF$),3))+" >":EndIf
      *pid(fct())\nav=navigation
     Next 
   EndIf
   ;Debug "---------" +*pp\titre+"    "+ListSize(*pp\sp())
EndProcedure

Procedure.s iehtml(ht.s) ; mode IE: pas de variables CSS, ni de callback javascript
  Protected.s v,nom,valeur
  Protected i
  ; variables CSS remplacees par leur valeur
  For i=1 To CountString(couleurs,";")+1
    v=Trim(StringField(couleurs,i,";"))
    If Left(v,2)="--"
      nom=Trim(StringField(v,1,":"))
      valeur=Trim(RemoveString(StringField(v,2,":"),"}"))
      ht=ReplaceString(ht,"var("+nom+")",valeur)
    EndIf
  Next
  ; jsmessage() est transmis par une url 'pbhelp:', interceptee par le callback de navigation
  ht=ReplaceString(ht,"onclick='jsmessage(","onclick='return jsmessage(")
  ht=ReplaceString(ht,"<head>","<head><meta http-equiv='X-UA-Compatible' content='IE=edge'>"+
                                "<script>function jsmessage(m) {window.location.href='pbhelp:'+encodeURIComponent(m); return false;}</script>",#PB_String_CaseSensitive,1,1)
  ProcedureReturn "<!DOCTYPE html>"+ht
EndProcedure

Procedure sethtml(ht.s)
  ht=ReplaceString(ht,"<head>","<head><meta charset='utf-8'>",#PB_String_CaseSensitive,1,1) ; encodage explicite (accents, umlauts)
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    If iemode:SetGadgetItemText(gweb, #PB_Web_HtmlCode, iehtml(ht)):ProcedureReturn:EndIf
  CompilerEndIf
  ; boutons precedent/suivant de la souris et Alt+fleches: notre historique, pas celui du WebView (qui revient sur une ancienne page, parfois vide)
  ht=ReplaceString(ht,"<head>","<head><script>"+
                   "function nav(e,s) {e.preventDefault(); jsmessage('lk:'+s);}"+
                   "window.addEventListener('mousedown', function(e) {if (e.button==3 || e.button==4) e.preventDefault();});"+
                   "window.addEventListener('mouseup', function(e) {if (e.button==3) nav(e,'-'); else if (e.button==4) nav(e,'+');});"+
                   "window.addEventListener('keydown', function(e) {if ((e.altKey && e.key=='ArrowLeft') || e.key=='BrowserBack') nav(e,'-'); else if ((e.altKey && e.key=='ArrowRight') || e.key=='BrowserForward') nav(e,'+');});"+
                   "</script>",#PB_String_CaseSensitive,1,1)
  SetGadgetItemText(gweb, #PB_WebView_HtmlCode, ht)
EndProcedure

Procedure ajoutepage(nom.s,titre.s,src.s)
  LastElement(page()):AddElement(page())
  page()\nom=nom
  page()\titre=titre
  page()\src=src
  *pid(nom)=page()
EndProcedure

Procedure pagesgenerees() ; pages construites a partir des autres pages (comme le fait DocMaker)
  Protected.s t,t1,t2,l,c,info,listeos,fct,colw,coll,colm,lib,lettre,cst,src
  Protected p,ap,pp,*sp.spage
  NewList liste.s()
  NewMap cstpages.s()
  NewMap vu.i()

  ;------------------------------------------------------------------------------ OSSpecificFunctions (convertion format PB)
  ClearList(osspe())
  ClearMap(mosspe())
  t=RemoveString(_ReadTextFile("OSSpecificFunctions.txt"),#CR$)+#LF$
  Repeat
    ap=p:p=FindString(t,#LF$,p+1):If p=0:Break:EndIf
    l=Trim(Trim(rMid(@t,ap+1,p-ap-1)),#TAB$):c=rmid(@l,1,1)
    If Len(l)>0 And c<>";"
      pp=FindString(l+":",":")
      t1=Trim(Left(l,pp-1))
      t2=Trim(Mid(l,pp+1))
      Select LCase(t1)
        Case "#library"
        Case "#startgroup":info=t2
        Case "#endgroup"
          Default:If t2>"":info=t2:EndIf:AddElement(osspe()):osspe()= t1+#TAB$+ReplaceString(info,"-",#TAB$):mosspe(LCase(t1))=info
      EndSelect
    EndIf
  ForEver

  Macro oscolor(os,col)
    col="bgcolor="
    If FindString(listeos,"("+os+")"):col+"#fb0":ElseIf FindString(listeos,os):col+"#0f0":Else:col+"#f00":EndIf
  EndMacro

  SortList(osspe(),#PB_Sort_Ascending|#PB_Sort_NoCase)
  t="@<table border=1>"+#LF$
  ForEach osspe()
    fct    =StringField(osspe(),1,#TAB$)
    listeos=StringField(osspe(),2,#TAB$)
    info   =StringField(osspe(),3,#TAB$)
    oscolor("Windows",colw)
    oscolor("Linux",coll)
    oscolor("MacOS",colm)
    t+" @<tr> @<td> "+"@@"+fct+" @</td> "+
      "@<td "+colw+"> windows @</td> "+
      "@<td "+coll+"> Linux @</td> "+
      "@<td "+colm+"> Mac @</td> "+
      "@<td> "+info+" @</td> @</tr>"+#LF$
  Next
  t+"@</table>"

  ;------------------------------------------------------------------------------ index des commandes et constantes PureBasic
  ForEach page()
    If page()\userlib<>"":Continue:EndIf
    If Left(page()\nom,4)="lib_" ; fonctions des bibliotheques, par ordre alphabetique
      lib=page()\titre
      ForEach page()\sp():*sp=page()\sp()
        If *sp\userlib="":AddElement(liste()):liste()=*sp\titre+#TAB$+*sp\nom+#TAB$+lib:EndIf
      Next
    EndIf
    p=0:src=page()\src
    Repeat ; constantes #PB_xxx citees (@#PB_xxx), avec les pages qui les citent
      p=FindString(src,"@#PB_",p+1):If p=0:Break:EndIf
      pp=p+1
      Repeat:pp+1:c=rMid(@src,pp,1):Until c="" Or FindString("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_",c)=0
      cst=rMid(@src,p+1,pp-p-1)
      If FindMapElement(vu(),cst+#TAB$+page()\nom)=0
        vu(cst+#TAB$+page()\nom)=1
        If FindMapElement(cstpages(),cst):cstpages()+", ":Else:AddMapElement(cstpages(),cst):EndIf
        cstpages()+"@@"+page()\nom
      EndIf
    ForEver
  Next

  ajoutepage("osspecific",_Fonctionsos,t)

  SortList(liste(),#PB_Sort_Ascending|#PB_Sort_NoCase)
  t="":lettre=""
  ForEach liste()
    If UCase(Left(liste(),1))<>lettre:lettre=UCase(Left(liste(),1)):t+"@Section "+lettre+#LF$:EndIf
    t+"@@"+StringField(liste(),2,#TAB$)+" - "+StringField(liste(),3,#TAB$)+#LF$
  Next
  ajoutepage("commandindex",_Indexcommandes,t)

  ClearList(liste())
  ForEach cstpages():AddElement(liste()):liste()=MapKey(cstpages()):Next
  SortList(liste(),#PB_Sort_Ascending|#PB_Sort_NoCase)
  t="":lettre=""
  ForEach liste()
    If UCase(Mid(liste(),5,1))<>lettre:lettre=UCase(Mid(liste(),5,1)):t+"@Section "+lettre+#LF$:EndIf ; #PB_x
    t+"@"+liste()+" : "+cstpages(liste())+#LF$
  Next
  ajoutepage("pbconstants",_Constantes,t)
EndProcedure

Procedure initFichier(enableUI=1)
  Protected.s tt,libext,txt,lien ,mtxt,ul
  Protected p,ap,pp,num,niv,*p.spage,*sp.spage
  NewList so.s()
  
  ClearMap(*pid())
  ClearList(page())
  apage=""
  repl=langue+"/"
  
  initbalise()
  
  NewList fl.s()
  NewList lib.s()
  ;------- lecture userlib
  If RepUL<>"" And FileSize(RepUL)=-2
    fileList(fl(),RepuL,"txt",1,1):ForEach fl():ExtrairePage(fl(),1):Next:CopyList(fl(),lib())
  EndIf
  ;------- lecture des sources
  _fileList(fl(),RepL,"txt",1,1):ForEach fl():ExtrairePage(fl()):Next
  ;------------------------------------------------------------------------------ sommaire (acceuil)
  If FindMapElement(*pid(),"reference")=0 ; source de l'aide introuvable
    If enableUI
      ClearGadgetItems(gsommaire)
      sethtml("<html><head><style>"+couleurs+style+"</style></head><body><h2>"+_Aide+"</h2>"+
              "Help source not found: <b>"+cvhtml(rep+RepL)+"</b></body></html>")
    EndIf
    ProcedureReturn
  EndIf
  pagesgenerees() ; avant le sommaire, qui y fait reference
  ForEach page():If page()\nom="reference":Break:EndIf:Next
  ForEach lib():libext=GetFilePart(lib(),#PB_FileSystem_NoExtension):ul+"@Link lib_"+LCase(libext)+" "+g+libext+g+#LF$:Next
  If ul="":page()\src=ReplaceString(page()\src,"@Section User library"+#LF$,""):EndIf ; pas de lib utilisateur: pas de section vide
  page()\src=ReplaceString(page()\src,"$userlib"+#LF$,ul)
  
  tt=page()\src
  Repeat
    p=FindString(tt,"@",p+1):If p=0:Break:EndIf
    Select Stringparse(tt,"@"," ",p-1)
      Case "Section":AddElement(so()):so()=Stringparse(tt,"Section ",#LF$,p)
      Case "Link":AddElement(so()):so()=Stringparse(tt," "+g,g+#LF$,p)+#TAB$+Stringparse(tt,"Link "," "+g,p)
    EndSelect
  ForEver
 
  ; -----------  remplissage du treegadget gsommaire
  Macro ajoutesommaire(niv,txt,page,ul=0)
    If ul 
      If *sp\userlib=*p\userlib
        If *sp\libdest:mtxt=txt+" ("+*sp\libdest+")":Else:mtxt=txt:EndIf
      Else
        mtxt=txt+" ("+*sp\userlib+")"
      EndIf
    Else
      mtxt=txt
    EndIf
    AddGadgetItem(gsommaire,-1,mtxt,0,niv)
    SetGadgetItemData(gsommaire,num,page)
    If ul:SetGadgetItemColor(gsommaire,num,#PB_Gadget_FrontColor,couleurul):EndIf ; sinon couleur du gadget (theme de l'IDE)
    num+1
  EndMacro
  
  If enableUI
    ClearGadgetItems(gsommaire)
    HideGadget(gsommaire,1)
    ForEach so()
      txt=StringField(so(),1,#TAB$)
      lien=StringField(so(),2,#TAB$)
      *p=0
      If lien="":niv=0:Else:niv=1:If FindMapElement(*pid(),lien):*p=*pid():*p\sommaire=num:EndIf:EndIf
      ajoutesommaire(niv,txt,*p)
      If *p
        ForEach *p\sp():*sp=*p\sp()
          If *sp\sommaire=0:*sp\sommaire=num:EndIf
          ajoutesommaire(niv+1,*sp\titre,*sp,Bool(*sp\userlib))
        Next
      EndIf
    Next
    HideGadget(gsommaire,0)
  EndIf

  If enableUI:affiche("reference"):EndIf
EndProcedure

Procedure.s cvhtml(txt.s,lf=0)
  txt=ReplaceString(txt,"<","&lt;")
  txt=ReplaceString(txt,">","&gt;")
  If lf:txt=ReplaceString(txt,#LF$,"<br>"+#LF$):EndIf
  ProcedureReturn txt.s
EndProcedure
      
Procedure.s surligne(ht.s,rec.s) ; surligne la recherche dans le texte du body, sans toucher aux balises html (liens) ni a la casse
  ; un seul passage (FindString() repart de la longueur de la chaine a chaque appel: trop lent sur les grosses pages)
  Protected.s res,lht,lrec
  Protected *c.Character,*deb,pos,pc,lr,dansbalise
  rec=cvhtml(rec):lr=Len(rec)
  If lr=0:ProcedureReturn ht:EndIf
  pos=FindString(ht,"<body"):If pos=0:ProcedureReturn ht:EndIf
  lht=LCase(ht):lrec=LCase(rec) ; recherche sans la casse, mais le texte d'origine est conserve
  *deb=@lht
  *c=*deb+(pos-1)*SizeOf(Character)
  pc=1 ; debut de la partie pas encore recopiee
  While *c\c
    If *c\c='<'
      dansbalise=1
    ElseIf *c\c='>'
      dansbalise=0
    ElseIf dansbalise=0 And CompareMemoryString(*c,@lrec,#PB_String_CaseSensitive,lr)=#PB_String_Equal ; rec ne contient pas de '<' (cvhtml): ne deborde pas sur une balise
      pos=(*c-*deb)/SizeOf(Character)+1
      If pos>pc:res+rMid(@ht,pc,pos-pc):EndIf
      res+"<font class='found'>"+rMid(@ht,pos,lr)+"</font>"
      pc=pos+lr
      *c+(lr-1)*SizeOf(Character)
    EndIf
    *c+SizeOf(Character)
  Wend
  ProcedureReturn res+PeekS(@ht+(pc-1)*SizeOf(Character))
EndProcedure

Procedure.s PbtoHtml(nom.s) ; convertion format PB -> html
  #sep=" .,;:()[]{}>@/"+#LF$+Chr(34)+Chr(160)
  Protected.s l,ht,balise,hb,hl,p1,p2,tc,ac,c,param,popt,che,       cl,tt,att,sub,ref,rec,img,fctlink,t,tit,nav,boss,lt
  Protected tablg,tabfin,ap,p,pp,pi,pf,pb,ptt,codehtml,ajoutebr,btitre,abtitre,preformate,exdeb,exnum,time,ajouteok,i
  *page=*pid(LCase(nom))
  t=*page\src
  If Right(t,1)<>#LF$:t+#LF$:EndIf ; les balises lues jusqu'a la fin de ligne ($lg) en ont besoin (ex: @ExampleFile en fin de fichier)
  tit=*page\titre
  nav=*page\nav
  
  Macro ajerreur(t)
    tt+"<font class='note'>"+t+"</font>"
    erreur+t+#LF$
  EndMacro

  Macro lireparam(sep=#sep)
    While rMid(@t,p,1)=" ":p+1:Wend:If rMid(@t,p,1)=g:cl=g:Else:cl=sep:EndIf:pi=p:p+1
    While FindString(cl,rMid(@t,p,1))=0:p+1:Wend
    If cl=g:p+1:param=rMid(@t,pi+1,p-pi-2):Else:param=rMid(@t,pi,p-pi):EndIf
    ;Debug "-"+param+"_"
  EndMacro
  
  Macro ajoute(mtxt,type=0)
    txt=mtxt
    Select type
      Case 0 ; text
        txt=cvhtml(txt,Bool(ajoutebr And preformate=0))
      Case 1 ; balise
      Case 2 ; html
        pp=0
        Repeat
          pp=FindString(txt,"<img",pp+1):If pp=0:Break:EndIf
          che=Stringparse(txt,"src=",">",pp)
          img=imagetohtml(GetFilePart(che))
          If img<>"":txt=ReplaceString(txt,"src="+che+">",img):pp+Len(img)-Len(che):Else:ajerreur("image not found:* "+che):EndIf
        ForEver
        pp=0
        Repeat
          pp=FindString(txt,"<a",pp+1):If pp=0:Break:EndIf
          che=Stringparse(txt,"href=",">",pp)
          If FindString(che,"#")=0
            txt=ReplaceString(txt,"href="+che+">","href='#' onclick='jsmessage("+g+"lk:"+LCase(GetFilePart(che,#PB_FileSystem_NoExtension))+g+")'>")
          EndIf
        ForEver
    EndSelect
    tt+txt
  EndMacro
    
  erreur=""
  
  ;----------------------- suppression commentaires
  Repeat
    p=FindString(t,#LF$+";"):If p=0 And rmid(@t,1,1)<>";":Break:EndIf
    t=Left(t,p)+Mid(t,FindString(t+#LF$,#LF$,p+1)+1)
  ForEver
  
  time=ElapsedMilliseconds()
  ;tt=Space(Len(t)*2)
  p=1
  Repeat
    ap=p:pp=FindString(t,"@",p):If pp=0:ajoute(Mid(t,p),0):Break:Else:p=pp:EndIf
    pb=p:p+1:balise="":c=rMid(@t,p,1)
    Repeat:p+1:balise+c:c=rMid(@t,p,1):Until (FindString(#sep,c) And balise+c<>"</") Or c=""
    c=rMid(@t,pb+1,1)
    If c="@" Or c="#" ; @@Fonction et @#Constante: comme DocMaker, seulement lettres, chiffres et '_' (ex: "@@RGB-Funktion", "@@SetGadgetText!")
      p=pb+2
      While rMid(@t,p,1)<>"" And FindString("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_",rMid(@t,p,1)):p+1:Wend
      balise=rMid(@t,pb+1,p-pb-1)
    EndIf
    ;----------------------- suppression saut ligne autour des balises "titre" (+@indent)
    abtitre=btitre
    If FindString("#@<",c):btitre=0:EndIf
    If FindMapElement(balise(),LCase(balise)):btitre=balise()\titre:EndIf
    If abtitre And rMid(@t,ap,1)=#LF$:ap+1:EndIf
    If btitre And rMid(@t,pb-1,1)=#LF$:pb-1:EndIf
    If pb>ap:ajoute(rMid(@t,ap,pb-ap),0):EndIf ; pb<ap si 2 balises "titre" se suivent (longueur negative: PeekS lirait jusqu'a la fin)
    
    ajoutebr=1
    Select  c
      Case "#"
        ajoute("<font class='cst'>"+balise+"</font>",1)
      Case "@"
        ref=LCase(Mid(balise,2))
        If *pid(ref)
          fctlink=*pid(ref)\titre:If *pid(ref)\userlib:fctlink="<font class='ul'>"+fctlink+"</font>":EndIf
          ajoute("<a href='#' onclick='jsmessage("+g+"lk:"+ref+g+")'>"+fctlink+"</a>",1)
        Else
          ajerreur("ref not found: "+ref)
        EndIf
      Case "<"
        ajoutebr=0
        pi=p:p=FindString(t,">",p)
        ajoute("<"+Mid(balise,2)+" "+ Mid(t,pi,p-pi)+">",1):p+1
      Default      
        If FindMapElement(balise(),LCase(balise))
          preformate+balise()\pre:If preformate<0:preformate=0:EndIf ; @Description sans @Syntax/@Function avant (ex: pages Reference): sinon les sauts de ligne sont ignores
          ht=""
          Select balise()\param
            Case 1,2
              tablg+1
              If tablg=1:ht="<h3>"+_Parametres+"</h3><table class='param'>"+#LF$:EndIf
              If tablg>1:ht="</td></tr>":EndIf
              If balise()\param=2:popt=" class='opt'":Else: popt="":EndIf
              ht+"<tr"+popt+"><td width='10%'><i>$p1</i></td><td width='90%'>"
            Case 3
              If tablg:ht="</td></tr></table>":tablg=0:EndIf
          EndSelect
          If balise="ExampleFile" And exdeb=0:exdeb=1:ht="<h3>"+_Exemple+"</h3>":EndIf
         
          codehtml= balise()\html
          ht+balise()\hbalise
          If FindString(ht,"$")
            If FindString(ht,"$ose"):lireparam(" "+#LF$):If param="All" Or param=os:ht=ReplaceString(ht,"$ose",""):Else:ht="":p=FindString(t,#LF$,p):EndIf:EndIf
            If FindString(ht,"$p1"):lireparam():ht=ReplaceString(ht,"$p1",cvhtml(param)):EndIf
            If FindString(ht,"$p2"):lireparam():ht=ReplaceString(ht,"$p2",cvhtml(param)):EndIf
            If FindString(ht,"$im"):lireparam(" "+#LF$):img=imagetohtml(param):If img<>"":ht=ReplaceString(ht,"$im",img):Else:ajerreur("image Not found: "+param):EndIf:EndIf
            If FindString(ht,"$ex"):p+1:ht=ReplaceString(ht,"$ex",""+exnum):exnum+1:EndIf
            If FindString(ht,"$lg"):pi=p:p=FindString(t,#LF$,p):ht=ReplaceString(ht,"$lg",Mid(t,pi,p-pi)):EndIf
          EndIf
          If LCase(balise)="os"
            ; comme DocMaker: le bloc d'un autre OS est ignore jusqu'au prochain @OS, @EndOS, @CommandList, @SupportedOS ou @Function
            pi=p:p=FindString(t+#LF$,#LF$,p)
            If LCase(Trim(Mid(t,pi,p-pi)))<>LCase(os)
              lt=LCase(t):pf=0
              For i=1 To 5:pp=FindString(lt,#LF$+StringField("@os ,@endos,@commandlist,@supportedos,@function ",i,","),p):If pp And (pf=0 Or pp<pf):pf=pp:EndIf:Next
              If pf:p=pf:Else:p=Len(t)+1:EndIf
            EndIf
          EndIf
          ajoute(ht,1)
          If balise="Code":ap=p:p=FindString(t,"@EndCode",p,#PB_String_NoCase)-1:If p=-1:ajerreur("missing : @EndCode"):Break:Else:ajoutebr=0:If ColorCodeCallback:ajoute(ColorCodeCallback(rMid(@t,ap,p-ap)),1):Else:ajoute(rMid(@t,ap,p-ap),0):EndIf:EndIf:EndIf
          If balise="FormatIf":ap=p:p=FindString(t,"@FormatEndIf",p,#PB_String_NoCase)-1:If p=-1:ajerreur("missing : @FormatEndIf"):Break:Else:ajoute(rMid(@t,ap,p-ap),2):EndIf:EndIf
          If balise="HTML":ap=p:p=FindString(t,"@EndHTML",p,#PB_String_NoCase)-1:If p=-1:ajerreur("missing : @EndHTML"):Break:Else:ajoutebr=0:ajoute(rMid(@t,ap,p-ap),2):EndIf:EndIf
        Else
          ;ajerreur("unmanaged tag: @"+balise)
          ajoute("@"+balise,0)
        EndIf
    EndSelect      
    If p<ap:ajerreur("undefined error (maybe line feed missing)"):Break:EndIf
  ForEver 
  
  If erreur:tt="<font class='note'>"+ReplaceString(erreur,#LF$,"<br>")+"</font>"+tt:EndIf

  If FindMapElement(mosspe(),nom):boss="<div class='note'>"+mosspe()+"</div>":EndIf
  t="<html><head><title>$titrepage</title><style>"+couleurs+style+"</style></head><body><h2>"+boss+tit+"<br>"+
    "<font class='nav'>"+nav+"</font></h2>"
  t+#LF$+tt+"</body></html>"
  If IsGadget(grec):t=surligne(t,GetGadgetText(grec)):EndIf
  ;ClearDebugOutput():Debug "________________________________________________":Debug t
  ProcedureReturn  t
EndProcedure

Procedure pref(sens) ; sens: 0 lecture  /  1 ecriture
  
  Macro lectur_ecriture_long(key,val,var,def)
    If sens:WritePreferenceLong (key,val):Else:var=ReadPreferenceLong (key, def):EndIf
  EndMacro
  
  OpenPreferences(GetCurrentDirectory()+"PBHelp.ini")
  
  lectur_ecriture_long("pX", WindowX(waide),waidex,50)
  lectur_ecriture_long("py", WindowY(waide),waidey,50)
  lectur_ecriture_long("dX", WindowWidth(waide),waidedx,800)
  lectur_ecriture_long("dy", WindowHeight(waide),waidedy,600)
  If sens=0:helpsource=ReadPreferenceString("helpsource",""):EndIf
  
  Debug helpsource
  ClosePreferences()
EndProcedure

Procedure CheckFile()
  Protected i,lerr.s
  
  pref(0):rep=helpsource+"/"
  
  os="Windows"
  For i=1 To 3
    langue=StringField(listlg,i,",") :lerr+ "§================§":lerr+ langue:lerr+ "§================§"
    initlang() 
    initFichier(0)
    ForEach page()
      PbtoHtml(page()\nom)
      If erreur
        lerr+ "-------"+page()\fichier+"---"+page()\nom+"§"
        lerr+ erreur
      EndIf 
    Next
    lerr+ "§=============================="+ListSize(page())
  Next
  Debug ReplaceString(lerr,"§",#LF$)
  MessageRequester("Script Error",ReplaceString(lerr,"§",#LF$))
EndProcedure

Procedure.s htmltopb(t.s) ; temporaire, sert à lire le sommaire html, le convertir au format PB
  Protected.s c,l,tt,r,txt,lien,balise,attr
  Protected pi,pf,pl,p
  
  t=ReplaceString(t,#CR$,"")
  t=ReplaceString(t,#TAB$,"")
  Repeat
    pi=pf+1
    pf=FindString(t,#LF$,pi):If pf=0:Break:EndIf
    l=Trim(Mid(t,pi,pf-pi))
    c=RMid(@l,1,1):pl=1
    If c="<"
      Repeat:pl+1:c=rMid(@l,pl,1):Until FindString(" >",c)
      balise=LCase(rMid(@l,2,pl-2))
      attr=RMid(@l,pl,FindString(l,">")-pl)
      txt=Stringparse(l,">","<")
      Select balise
        Case "table","tr","td","/table","/tr","/td":tt+"@<"+balise+attr+">"+#LF$
        Case "b":tt+"@Section "+txt+#LF$
        Case "a":
          If FindString(l,"href")
            If FindString(l,"/index"):lien="lib_"+Stringparse(l,"/","/"):Else:lien=Stringparse(l,g,"."):EndIf
          tt+"@Link "+lien+" "+g+txt+g+#LF$
          EndIf
      EndSelect
    EndIf
  ForEver
  tt=ReplaceString(tt,"<table","<table style='all: unset;'")
  ;Debug tt:End
  ProcedureReturn tt
EndProcedure

Procedure filemef(source.s,destination.s) ; conversion d'un fichier source de la doc (DocMaker) au format de l'aide
  #sep=" .,;:()[]{}>@/"+#LF$+Chr(34)+Chr(160)
  Protected n,p,pre,text,atext,ok,indent,file,format
  Protected.s t,tt,c1,c,balise,fl

  file=ReadFile(#PB_Any,source):If file=0:ProcedureReturn #False:EndIf
  format=ReadStringFormat(file):If format=#PB_Ascii:format=#PB_UTF8:EndIf ; sources sans BOM: UTF-8
  ok=1
  Repeat
    t=(ReadString(file,format))
    c1=Left(t,1)
    If pre=0 And LCase(Left(LTrim(t),13))="@examplefile ":t=LTrim(t):c1="@":EndIf ; souvent indente: reste une ligne a part (lue jusqu'a la fin de ligne)
    If Trim(t)="@LineBreak":c1=" ":EndIf
    If c1="@"
      p=1:balise="":c="":Repeat:p+1:balise+c:c=rMid(@t,p,1):Until (FindString(#sep,c) And balise+c<>"</") Or c="":balise=LCase(balise)
      Select balise
        Case "code","fixedfont","function","syntax":pre=1
        Case "endcode","endfixedfont","description":pre=0
        Case "formatif":t="@HTML":pre=1
        Case "formatelse":ok=0
        Case "formatendif":t="@EndHTML":ok=1:pre=0
      EndSelect
    EndIf
    atext=text:text=Bool(FindString("@;",c1)=0)
    If pre=0:t=Trim(t):EndIf
    If LCase(Trim(t))="@indent":t+#LF$:EndIf
    If LCase(Trim(t))="@endindent":t=#LF$+t:EndIf
    If pre Or text=0 Or atext=0:t=#LF$+t:Else:t=" "+Trim(t):EndIf
    t=ReplaceString(t,"@LineBreak",#LF$)
    If ok:tt+t:EndIf
  Until Eof(file)
  CloseFile(file)
  tt=ReplaceString(tt," "+#LF$,#LF$)
  Debug "=====lg: "+Len(tt)+#TAB$+"  lines: "+CountString(tt,#LF$)+#TAB$+""+source
  ;Debug tt
  If ok=0:Debug " !!! @formatendif missing !!!":EndIf
  ProcedureReturn WriteTextFile(destination,tt)
EndProcedure

Procedure listfilemef()
  Protected t.s,ch.s,p,i
  MessageRequester("!!!","ATTENTION, n'executer qu'une fois !")
  NewList fl.s()
  
  pref(0):rep=helpsource+"/"

  os="Windows"
  For i=1 To 3
    langue=StringField(listlg,i,",") :Debug #LF$+"================":Debug langue:Debug "================"
    ;--------------------- conversion des fichiers au nvx format (sans formatif et linebreak)
    initlang() 
    initbalise()
    ;filemef("Reference\general_rules.txt")
    ;filemef("Reference\variables.txt")
    ;filemef("Reference\ascii.txt")
    FileList(fl(),rep+langue,"txt",1,1):ForEach fl():filemef(rep+langue+"/"+fl(),rep+langue+"/"+fl()):Next
    
    ;--------------------- conversion reference.html au format pb (.txt) insertion "User library" et renommage ascii.txt->asciitable.txt
    ch=rep+langue+"/Reference/reference.html"
    t="@Title "+_acceuil+#LF$+htmltopb(ReadTextFile(ch))
    p=FindString(t,"lib_texture")
    p=FindString(t,"@Section",p)
    t=InsertString(t,"@Section User library"+#LF$+"$userlib"+#LF$,p)
    t=ReplaceString(t,"@Link ascii","@Link asciitable")
    ch=ReplaceString(ch,".html",".txt")
    WriteTextFile(ch,t)
    ;DeleteFile(rep+langue+"\Reference\asciitable.txt")
    Debug RenameFile(rep+langue+"\Reference\ascii.txt",rep+langue+"\Reference\asciitable.txt")
  Next
EndProcedure

Procedure createpath(dir.s) ; cree le dossier et ses parents
  dir=RTrim(ReplaceString(dir,"\","/"),"/")
  If dir="" Or FileSize(dir)=-2:ProcedureReturn #True:EndIf
  createpath(GetPathPart(dir))
  ProcedureReturn CreateDirectory(dir)
EndProcedure

Procedure.s inithelp(source.s,destination.s) ; --init: construit le dossier de l'aide depuis les sources de la doc. Retourne les erreurs
  Protected i,ch.s,fic.s,t.s,errors.s
  NewList fl.s()

  source=ReplaceString(source,"\","/"):If Right(source,1)<>"/":source+"/":EndIf
  destination=ReplaceString(destination,"\","/"):If Right(destination,1)<>"/":destination+"/":EndIf
  If FileSize(source)<>-2:ProcedureReturn "Help source not found: "+source+#LF$:EndIf
  If createpath(destination)=0:ProcedureReturn "Can't create: "+destination+#LF$:EndIf

  For i=1 To CountString(listlg,",")+1
    langue=StringField(listlg,i,",")
    If FileSize(source+langue)<>-2:Continue:EndIf
    initlang()
    initbalise()
    ;--------------------- conversion des fichiers au nvx format (sans formatif et linebreak), ascii.txt -> asciitable.txt
    FileList(fl(),source+langue,"txt",1,1)
    ForEach fl()
      fic=fl()
      If LCase(fic)="reference/ascii.txt":fic=GetPathPart(fic)+"asciitable.txt":EndIf
      createpath(GetPathPart(destination+langue+"/"+fic))
      If filemef(source+langue+"/"+fl(),destination+langue+"/"+fic)=0:errors+"Can't convert: "+source+langue+"/"+fl()+#LF$:EndIf
    Next
    ;--------------------- conversion reference.html au format pb (.txt) avec insertion "User library"
    ch=source+langue+"/Reference/reference.html"
    If FileSize(ch)>0
      t="@Title "+_acceuil+#LF$+htmltopb(ReadTextFile(ch,#PB_UTF8,0))
      t=InsertString(t,"@Section User library"+#LF$+"$userlib"+#LF$,FindString(t,"@Section",FindString(t,"lib_texture")))
      t=ReplaceString(t,"@Link ascii","@Link asciitable")
      If WriteTextFile(destination+langue+"/Reference/reference.txt",t)=0:errors+"Can't write: "+destination+langue+"/Reference/reference.txt"+#LF$:EndIf
    Else
      errors+"Not found: "+ch+#LF$
    EndIf
    ;--------------------- images
    ch=source+langue+"/Reference/Images"
    If FileSize(ch)=-2 And CopyDirectory(ch,destination+langue+"/Reference/Images","",#PB_FileSystem_Recursive|#PB_FileSystem_Force)=0
      errors+"Can't copy: "+ch+#LF$
    EndIf
  Next

  If FileSize(source+"HelpPictures")=-2 And CopyDirectory(source+"HelpPictures",destination+"HelpPictures","",#PB_FileSystem_Recursive|#PB_FileSystem_Force)=0
    errors+"Can't copy: "+source+"HelpPictures"+#LF$
  EndIf
  If CopyFile(source+"OSSpecificFunctions.txt",destination+"OSSpecificFunctions.txt")=0
    errors+"Can't copy: "+source+"OSSpecificFunctions.txt"+#LF$
  EndIf
  ProcedureReturn errors
EndProcedure

Procedure.s inithelpzip(source.s,destination.s) ; --initzip: comme inithelp(), mais dans l'archive .zip 'destination'. Retourne les erreurs
  Protected.s temp,errors
  Protected pack
  NewList fl.s()

  ; l'aide est construite dans un dossier temporaire, puis compressee (chemins relatifs avec '/', a la racine de l'archive)
  temp=GetTemporaryDirectory()+"PBHelp_"+Str(ElapsedMilliseconds())+"/"
  errors=inithelp(source,temp)
  If FileSize(temp)=-2
    UseZipPacker()
    createpath(GetPathPart(destination))
    pack=CreatePack(#PB_Any,destination,#PB_PackerPlugin_Zip)
    If pack
      FileList(fl(),temp,"",1,1)
      ForEach fl()
        If AddPackFile(pack,temp+fl(),fl())=0:errors+"Can't add to the archive: "+fl()+#LF$:EndIf
      Next
      ClosePack(pack)
    Else
      errors+"Can't create: "+destination+#LF$
    EndIf
    DeleteDirectory(temp,"",#PB_FileSystem_Recursive|#PB_FileSystem_Force)
  EndIf
  ProcedureReturn errors
EndProcedure

;_____________________________________________________________________________________________________________________interface

Global hostwindow,gxml ; hostwindow: fenetre qui contient l'aide (pour les evenements differes)

Macro dossier:If *page\userlib:dos=repul:Else:dos=rep+RepL:EndIf:EndMacro

Procedure affiche(page.s)
  Protected pilepos
  Debug page
  If Len(page)<>1 And FindMapElement(*pid(),page)=0:MessageRequester("PB Help", "not found : "+page):ProcedureReturn :EndIf
  Select page
    Case "-":If ListIndex(pilepage())<=0:ProcedureReturn:EndIf:PreviousElement(pilepage()):page=pilepage()
    Case "+":If ListIndex(pilepage())>=ListSize(pilepage())-1:ProcedureReturn:EndIf:NextElement(pilepage()):page=pilepage()
    Default:
      While NextElement(pilepage()):DeleteElement(pilepage()):Wend
      AddElement(pilepage()):pilepage()=page
  EndSelect
  If page=apage:ProcedureReturn:Else:apage=page:EndIf
  ht=PbtoHtml(page)
  sethtml(ht)
  pilepos=ListIndex(pilepage())
  DisableGadget(gprec,Bool(pilepos=0))
  DisableGadget(gsuiv,Bool(pilepos=ListSize(pilepage())-1))

  HideGadget(gediter,Bool(Archive And *page\userlib=""))

  If *pid(page)
    CompilerIf #Standalone ; dans l'IDE, ne pas voler le focus de l'editeur
      SetActiveGadget(gsommaire)
    CompilerEndIf
    SetGadgetState(gsommaire,*pid(page)\sommaire)
  EndIf
EndProcedure

Procedure.s examplefile(name.s) ; IDE: chemin du vrai fichier d'exemple (pour que les chemins relatifs des donnees fonctionnent)
  Protected.s dir
  Protected i
  For i=1 To 2
    If i=1:dir=rep:Else:dir=repex:EndIf
    If dir="" Or (i=1 And Archive):Continue:EndIf
    If FileSize(dir+"Examples/Sources/"+name)>0:ProcedureReturn dir+"Examples/Sources/"+name:EndIf
    If FileSize(dir+"Examples/3D/"+name)>0:ProcedureReturn dir+"Examples/3D/"+name:EndIf
    If i=2
      If FileSize(dir+"Sources/"+name)>0:ProcedureReturn dir+"Sources/"+name:EndIf
      If FileSize(dir+"3D/"+name)>0:ProcedureReturn dir+"3D/"+name:EndIf
    EndIf
  Next
  ProcedureReturn ""
EndProcedure

Procedure jsaction(message.s)
  message=Mid(message,3,Len(message)-4)
  Protected.s che,ficnom,s,t,type=Left(message,2), val=Trim(Mid(message,4))
  Protected p,pi,i


  If type="lk"  ; ------------------------ link
    affiche(LCase(val))
  Else          ; ------------------------ example
    Select Mid(type,1,1)
      Case "c" ;----- code
        s=*page\src
        For i=0 To Val(val):p=FindString(s,"@Code",p+1):Next
        ;t=PeekS(Ascii(Stringparse(s,"@Code","@EndCode",p-5)), -1, #PB_UTF8)
        t=Stringparse(s,"@Code","@EndCode",p-5) ; !sos! bug caractere :exemple openxmldialog
        ficnom=*page\nom+"_ex"+val+".pb"
      Case "f" ;----- fichier
        CompilerIf Not #Standalone
          che=examplefile(val)
        CompilerEndIf
        If che=""
          t=_ReadTextFile("Examples/Sources/"+val,#PB_UTF8,0)
          If t="":t=_ReadTextFile("Examples/3D/"+val,#PB_UTF8,0):EndIf
        EndIf
        ficnom=val
    EndSelect

    CompilerIf #Standalone
      If t<>""
        che=GetTemporaryDirectory()+ficnom
        WriteTextFile(che, t)
        Select Mid(type,2,1)
          Case "o":RunProgram(#PB_Compiler_Home+"PureBasic", g+che+g,GetTemporaryDirectory(),#PB_Program_Hide)
          Case "r":RunProgram(g+#PB_Compiler_Home+"Compilers\pbcompiler"+g, g+che+g, GetTemporaryDirectory(),#PB_Program_Hide)
        EndSelect
      EndIf
    CompilerElse ; IDE: charge dans un nouvel onglet (et execute si demande)
      If OpenCodeCallback And (che<>"" Or t<>"")
        OpenCodeCallback(che, t, Bool(Mid(type,2,1)="r"))
      EndIf
    CompilerEndIf
  EndIf
EndProcedure

Procedure jsmessage(message.s)
  ; le javascript est bloque pendant le callback: l'action est differee dans la boucle d'evenements
  LastElement(jsmessages()):AddElement(jsmessages()):jsmessages()=message
  PostEvent(#EventJsMessage, hostwindow, 0)
EndProcedure

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  Procedure webviewdisponible() ; WebView2 utilisable ? (teste une seule fois, dans une fenetre invisible)
    Static resultat=-1
    Protected ancienneliste,fenetre,gadget
    If resultat=-1
      resultat=1
      ancienneliste=UseGadgetList(0)
      fenetre=OpenWindow(#PB_Any,0,0,10,10,"",#PB_Window_Invisible)
      If fenetre
        gadget=WebViewGadget(#PB_Any,0,0,10,10)
        If gadget:FreeGadget(gadget):Else:resultat=0:EndIf
        CloseWindow(fenetre)
      EndIf
      If ancienneliste:UseGadgetList(ancienneliste):EndIf
    EndIf
    ProcedureReturn resultat
  EndProcedure

  Procedure navigation(gadget,url.s) ; mode IE: les appels a jsmessage() arrivent sous la forme d'une url 'pbhelp:'
    If LCase(Left(url,7))="pbhelp:"
      jsmessage("["+g+URLDecoder(Mid(url,8))+g+"]") ; meme format que le callback du WebView
      ProcedureReturn #False
    EndIf
    ProcedureReturn #True
  EndProcedure
CompilerEndIf

Procedure jsprocess()
  Protected message.s
  While FirstElement(jsmessages())
    message=jsmessages():DeleteElement(jsmessages())
    jsaction(message)
  Wend
EndProcedure

Procedure recherche()
  Protected txt.s, n
  NewList result.s()

  If etype= #PB_EventType_Change
    txt=GetGadgetText(grec)
    If apage<>"":ht=PbtoHtml(apage):sethtml(ht):EndIf ; met a jour (ou efface) le surlignage de la page affichee
    If Len(txt)<3:ProcedureReturn:EndIf
    ForEach page()
      If FindString(page()\src,txt,1,#PB_String_NoCase)
        AddElement(result())
        result()=page()\nom
      EndIf
    Next
    HideGadget(grecliste,1)
    ClearGadgetItems(grecliste)
    SortList(result(),#PB_Sort_Ascending)
    ForEach result()
      AddGadgetItem(grecliste,-1,*pid(result())\titre)
      SetGadgetItemData(grecliste,n,*pid(result()))
      n+1
    Next
    HideGadget(grecliste,0)
  EndIf
EndProcedure

Procedure initui()
  initlang()
  Protected xml.s,x,i

  Protected.s onglets = "        <tab text='"+_Sommaire+"'>"+
                        "          <Tree name='sommaire' flags='#PB_Tree_AlwaysShowSelection'/>"+
                        "          </tab>"+
                        "        <tab text='"+_Recherche+"'>"+
                        "          <vbox expand='item:2'>"+
                        "            <String name='rec'/>"+
                        "            <ListView name='recliste'/>"+
                        "            </vbox>"+
                        "          </tab>"
  CompilerIf #Standalone
    Macro bouton(nom,texte):"            <button name='"+nom+"' text='"+texte+"' />":EndMacro
    xml = "<window id='#PB_Any' name='aide' text='PureBasic' minwidth='500' minheight='400' flags='#PB_Window_ScreenCentered | #PB_Window_SystemMenu | #PB_Window_SizeGadget'>"+
          "  <hbox>"+
          "    <splitter name='sep' flags='#PB_Splitter_Vertical' firstmin='20' secondmin='auto'>"+
          "      <panel name='onglet' maxwidth='150'>"+
          onglets+
          "        </panel>"+
          "      <container margin='0'>"+
          "        <vbox expand='item:2'>"+
          "          <hbox expand='no'>"+
          bouton("prec", "&#9664;")+
          bouton("suiv", "&#9654;")+
          bouton("acc", "&#8962;")+
          "            <combobox name='langue' width='100' />"+ ; !sos!  tu peux aligner sur la droite : langue, os , editer ?
          "            <combobox name='os' width='100' />"+
          bouton("editer", "&#9998;")+
          "            </hbox>"+
          "          <WebView name='Web' />"+
          "          </vbox>"+
          "        </container>"+
          "      </splitter>"+
          "    </hbox>"+
          "  </window>"
  CompilerElse ; IDE: la barre de boutons est au dessus, le sommaire (masque par defaut) a gauche de la page
    Protected taille=28 ; taille des boutons: icone + marge
    If IsImage(imgprec):taille=DesktopUnscaledX(ImageWidth(imgprec))+12:EndIf
    Macro bouton(nom,flags):"      <buttonimage name='"+nom+"' width='"+taille+"' height='"+taille+"' flags='"+flags+"' />":EndMacro
    xml = "<window id='#PB_Any' name='aide' margin='0'>"+
          "  <vbox expand='item:2'>"+
          "    <hbox expand='no'>"+
          bouton("sommairevisible", "#PB_Button_Toggle")+
          bouton("prec", "")+
          bouton("suiv", "")+
          bouton("acc", "")+
          bouton("editer", "")+
          "      </hbox>"+
          "    <splitter name='sep' flags='#PB_Splitter_Vertical' firstmin='0' secondmin='auto'>"+
          "      <panel name='onglet' invisible='yes'>"+
          onglets+
          "        </panel>"+
          "      <WebView name='Web' />"+
          "      </splitter>"+
          "    </vbox>"+
          "  </window>"
  CompilerEndIf
  UndefineMacro bouton

  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    iemode=Bool(#ForceIEMode Or webviewdisponible()=0)
    If iemode ; WebView2 indisponible: WebGadget (Internet Explorer), affichage degrade
      xml=ReplaceString(xml,"<WebView name='Web' />","<web name='Web' />")
      UseDialogWebGadget()
    EndIf
  CompilerEndIf
  UseDialogWebViewGadget()
  ;xml=ReplaceString(xml,">",">"+#LF$)
  ;Protected.s g=Chr(34),c,ac,nxml=GetClipboardText():Repeat :axml=xml:xml=ReplaceString(xml,g+" ",g):Until axml=xml:For i=1 To Len(xml):ac=c:c=Mid(xml,i,1):If c="<":nxml+Space(pos*2):pos+1:ElseIf c="/":pos-1:If ac="<":pos-1:EndIf:EndIf:nxml+c:Next:Debug nxml:end
  x=ParseXML(-1, xml):gxml=x
  gdialog=CreateDialog(-1)
  CompilerIf #Standalone
    OpenXMLDialog(gdialog, x, "aide")
    waide=DialogWindow(gdialog)
  CompilerElse
    XmlDialogGadget(gdialog, x, "aide")
    groot=DialogGadget(gdialog,"aide")
  CompilerEndIf
  gonglet=DialogGadget(gdialog,"onglet")
  gsommaire=DialogGadget(gdialog,"sommaire"):DisableGadget(gsommaire,0)
  grec=DialogGadget(gdialog,"rec")
  grecliste=DialogGadget(gdialog,"recliste")

  gprec=DialogGadget(gdialog,"prec")
  gsuiv=DialogGadget(gdialog,"suiv")
  gacc=DialogGadget(gdialog,"acc")
  gediter=DialogGadget(gdialog,"editer")

  CompilerIf #Standalone
    glangue=DialogGadget(gdialog,"langue"):For i=1 To 3:AddGadgetItem(glangue,-1,StringField(listlg,i,",")):Next:SetGadgetText(glangue,langue)
    gos=DialogGadget(gdialog,"os"):AddGadgetItem(gos,-1,"Windows"):AddGadgetItem(gos,-1,"MacOS"):AddGadgetItem(gos,-1,"Linux"):SetGadgetText(gos,os)
  CompilerElse ; la langue et l'OS sont ceux de l'IDE
    glangue=-1
    gos=-1
    gsommairevisible=DialogGadget(gdialog,"sommairevisible")
    GadgetToolTip(gsommairevisible,_sommairevisible)
    If IsImage(imgsommaire):SetGadgetAttribute(gsommairevisible,#PB_Button_Image, ImageID(imgsommaire)):EndIf
    If IsImage(imgprec)  :SetGadgetAttribute(gprec,  #PB_Button_Image, ImageID(imgprec))  :EndIf
    If IsImage(imgsuiv)  :SetGadgetAttribute(gsuiv,  #PB_Button_Image, ImageID(imgsuiv))  :EndIf
    If IsImage(imgacc)   :SetGadgetAttribute(gacc,   #PB_Button_Image, ImageID(imgacc))   :EndIf
    If IsImage(imgediter):SetGadgetAttribute(gediter,#PB_Button_Image, ImageID(imgediter)):EndIf
    If ApplyColorsCallback
      ApplyColorsCallback(gsommaire)
      ApplyColorsCallback(grec)
      ApplyColorsCallback(grecliste)
    EndIf
    RefreshDialog(gdialog)
  CompilerEndIf
  GadgetToolTip(gprec,_prec)
  GadgetToolTip(gsuiv,_suiv)
  GadgetToolTip(gacc,_acceuil)
  GadgetToolTip(gediter,_editer)

  gweb=DialogGadget(gdialog,"web")
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    If iemode
      SetGadgetAttribute(gweb, #PB_Web_NavigationCallback, @navigation())
    Else
      BindWebViewCallback(gweb, "jsmessage", @jsmessage())
    EndIf
  CompilerElse
    BindWebViewCallback(gweb, "jsmessage", @jsmessage())
  CompilerEndIf

  gsep=DialogGadget(gdialog,"sep")
  CompilerIf #Standalone
    SetGadgetState(gsep,150)
  CompilerElse
    SetGadgetState(gsep,0) ; sommaire masque par defaut
  CompilerEndIf

  If Archive And IsGadget(glangue)
    HideGadget(glangue,1)
    HideGadget(gos,1)
  EndIf

  CompilerIf #Standalone
    ResizeWindow(waide,waidex, waidey, waidedx, waidedy)
  CompilerEndIf
EndProcedure

Procedure opensource(source.s) ; ouvre la source de l'aide: dossier, ou archive .zip
  If Archive:ClosePack(nzip):Archive=0:EndIf
  If LCase(GetExtensionPart(source))="zip" And FileSize(source)>0
    rep=Left(source,Len(source)-4)
    UseZipPacker():nzip=OpenPack(-1, source)
    If nzip:archive=1:packinfo(nzip):EndIf
  Else
    rep=source
  EndIf
  If Right(rep,1)<>"/" And Right(rep,1)<>"\":rep+"/":EndIf
EndProcedure

Procedure editer() ; edition de la source de la page courante
  Protected t.s
  If *page=0 Or *page\fichier="":ProcedureReturn:EndIf
  dossier
  CompilerIf #Standalone
    RunProgram("notepad++.exe",g+dos+*page\fichier+g +" -p"+*page\pos,"")
  CompilerElse ; IDE: ouvre le fichier dans un onglet, a la ligne de la page
    If EditFileCallback
      t=ReadTextFile(dos+*page\fichier,#PB_UTF8,0)
      EditFileCallback(dos+*page\fichier, CountString(Left(t,*page\pos),#LF$)+1)
    EndIf
  CompilerEndIf
EndProcedure

Global sommairevisible,splitpos,largeurbarre=-1 ; IDE: sommaire affiche, position du separateur, largeur de sa barre (-1: pas encore mesuree)

Procedure setsplit(pos) ; IDE: position du separateur
  Protected w,h
  SetGadgetState(gsep, pos)
  CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
    ; Cocoa: SetGadgetState() ne relayoute pas le contenu des panneaux du dialog, un redimensionnement le force
    w=GadgetWidth(groot):h=GadgetHeight(groot)
    ResizeGadget(groot, #PB_Ignore, #PB_Ignore, w, h-1)
    ResizeGadget(groot, #PB_Ignore, #PB_Ignore, w, h)
  CompilerEndIf
EndProcedure

Procedure mesurebarre() ; IDE: largeur de la barre du separateur, en coordonnees ecran (independant du parent reel des gadgets du splitter)
  Protected l=GadgetX(gweb,#PB_Gadget_ScreenCoordinate)-GadgetX(gsep,#PB_Gadget_ScreenCoordinate)-GetGadgetState(gsep)
  If l>0 And l<40:largeurbarre=l:EndIf ; sinon la taille n'est pas encore allouee (GTK)
EndProcedure

Procedure placesommaire() ; IDE: sommaire masque: la barre du separateur est placee juste a gauche de la zone visible
  Protected l
  If sommairevisible Or IsGadget(gsep)=0:ProcedureReturn:EndIf
  If GetGadgetState(gsep)<>0:SetGadgetState(gsep,0):EndIf
  mesurebarre()
  l=largeurbarre:If l<0:l=8:EndIf
  ResizeGadget(gsep, -l, #PB_Ignore, GadgetWidth(groot)+l, #PB_Ignore) ; le dialog place le splitter sur toute la largeur de la racine
EndProcedure

Procedure affichesommaire(visible) ; IDE: affiche/masque le sommaire a gauche de la page
  If IsGadget(gsep)=0:ProcedureReturn:EndIf
  sommairevisible=visible
  SetGadgetState(gsommairevisible,visible)
  If visible
    SetGadgetAttribute(gsep,#PB_Splitter_FirstMinimumSize,20)
    HideGadget(gonglet,0)
    RefreshDialog(gdialog) ; replace le splitter dans la zone visible
    If splitpos<=0 ; premier affichage: un tiers de la largeur, sans etre trop etroit
      splitpos=GadgetWidth(groot)/3
      If splitpos<150:splitpos=GadgetWidth(groot)/2:EndIf
    EndIf
    setsplit(splitpos)
  Else
    If GetGadgetState(gsep)>0:splitpos=GetGadgetState(gsep):EndIf
    SetGadgetAttribute(gsep,#PB_Splitter_FirstMinimumSize,0)
    HideGadget(gonglet,1)
    placesommaire()
  EndIf
EndProcedure

Procedure timer() ; recharge l'aide si la source de la page courante a ete modifiee
  Protected memnom.s,l
  If sommairevisible=0 And IsGadget(gsep) ; la largeur de la barre n'est connue qu'une fois le splitter affiche (GTK, Cocoa)
    l=largeurbarre:mesurebarre()
    If largeurbarre<>l:placesommaire():EndIf
  EndIf
  If *page And *page\fichier<>""
    dossier
    If GetFileDate(dos+*page\fichier,#PB_Date_Modified)-editiondate>=2
      editiondate=Date()
      memnom=*page\nom
      initFichier()
      affiche(memnom)
    EndIf
  EndIf
EndProcedure

Procedure gadgetevent(gadget, type)
  etype=type
  If etype=#PB_EventType_Change Or etype =#PB_EventType_LeftClick
    Select gadget
      Case gsommaire
        If GetGadgetState(gsommaire)>=0 And etype=#PB_EventType_Change; Or etype =#PB_EventType_LeftClick
          *pagesel=GetGadgetItemData(gsommaire,GetGadgetState(gsommaire)):If *pagesel:affiche(*pagesel\nom):EndIf
        EndIf
      Case gsommairevisible:affichesommaire(GetGadgetState(gsommairevisible))
      Case gacc:affiche("reference")
      Case gprec:affiche("-")
      Case gsuiv:affiche("+")

      Case gonglet:SetActiveGadget(grec)
      Case grec:recherche()
      Case grecliste
        If GetGadgetState(grecliste)>=0
          *pagesel=GetGadgetItemData(grecliste,GetGadgetState(grecliste)):affiche(*pagesel\nom)
        EndIf

      Case gediter:editer()
      Case glangue:langue=GetGadgetText(glangue):initlang():initFichier()
      Case gos:os=GetGadgetText(gos)
    EndSelect
  EndIf
EndProcedure

Procedure init(language.s,operatingsys.s) ; outil autonome
  Protected Event

  langue=language
  os=operatingsys

  pref(0)

  ; chemin dossier de l'aide (issu de PBHelp.ini), ou archive
  If FileSize(helpsource)<>-2 And LCase(GetExtensionPart(helpsource))<>"zip"
    helpsource="C:\Users\shadoko\Desktop\git-pb\pbaidenv.zip"; chemin archive de l'aide (GetCurrentDirectory()+"PureBasicHelp")
  EndIf
  opensource(helpsource)

  repUL="C:\PureBasic-code\outils\helplib/" ; chemin dossier lib (GetCurrentDirectory()+"PureLibraries/Userlibraries")

  initui()
  hostwindow=waide
  BindEvent(#EventJsMessage, @jsprocess(), hostwindow)
  AddWindowTimer(waide,0,1000)
  initFichier()
  *pagesel=*page
  editiondate=Date()

  Repeat
    Event = WaitWindowEvent()
    If EventWindow()=waide
      If Event=#PB_Event_Gadget:gadgetevent(EventGadget(),EventType()):EndIf
      If Event=#PB_Event_Timer:timer():EndIf
    EndIf
  Until Event = #PB_Event_CloseWindow
  pref(1)
EndProcedure

;_____________________________________________________________________________________________________________________IDE

Procedure setup(lg.s, operatingsys.s, source.s, userlibsource.s, examplesource.s)
  langue=lg
  os=operatingsys
  helpsource=source
  opensource(helpsource)
  repUL=userlibsource
  repex=examplesource
EndProcedure

Procedure setimages(back, forward, home, edit, index, open.s, run.s) ; open, run: images png en base64
  imgprec=back
  imgsuiv=forward
  imgacc=home
  imgediter=edit
  imgsommaire=index
  If open<>"":icoouvrir="<img src='data:image/png;base64,"+open+"'>":EndIf
  If run<>"" :icoexecuter="<img src='data:image/png;base64,"+run+"'>":EndIf
EndProcedure

Procedure setcolors(css.s, userlibcolor=$008800) ; css: ":root {--bg:...}" (voir 'couleurs'), userlibcolor: bibliotheques utilisateur dans le sommaire
  couleurs=css
  couleurul=userlibcolor
EndProcedure

Procedure create(window) ; cree l'aide dans la liste de gadgets courante
  hostwindow=window
  ClearList(pilepage())
  initui()
  BindEvent(#EventJsMessage, @jsprocess(), hostwindow)
  initFichier()
  *pagesel=*page
  editiondate=Date()
EndProcedure

Procedure destroy()
  UnbindEvent(#EventJsMessage, @jsprocess(), hostwindow)
  ClearList(jsmessages())
  If IsDialog(gdialog):FreeDialog(gdialog):EndIf
  If IsXML(gxml):FreeXML(gxml):EndIf
  gdialog=0:gxml=0:groot=0:gsommairevisible=-1:sommairevisible=0:*page=0:*pagesel=0
EndProcedure

Procedure resize(width, height)
  If IsGadget(groot)
    ResizeGadget(groot, 0, 0, width, height) ; relayoute le dialog, qui replace le splitter sur toute la largeur
    placesommaire()
  EndIf
EndProcedure

Procedure show(page.s) ; affiche une page si elle existe (aide contextuelle F1)
  page=LCase(page)
  If FindMapElement(*pid(),page)=0:ProcedureReturn #False:EndIf
  affiche(page)
  ProcedureReturn #True
EndProcedure

DisableExplicit
EndModule


CompilerIf #PB_Compiler_IsMainFile

  ;pbhelp::CheckFile()
  ;pbhelp::listfilemef()

  ; HelpTool --init <helpsourcepath> <helpdestinationpath>
  ;   builds the help folder used by the help tool from the documentation sources (the 'Documentation' folder)
  ; HelpTool --initzip <helpsourcepath> <helpdestinationzip>
  ;   same, but builds a zip archive (ie: 'Help/Help.zip', the default help source of the IDE)
  If ProgramParameter(0)="--init" Or ProgramParameter(0)="--initzip"
    If CountProgramParameters()<>3
      Errors$ = "Usage: HelpTool --init <helpsourcepath> <helpdestinationpath>"+#LF$+
                "       HelpTool --initzip <helpsourcepath> <helpdestinationzip>"+#LF$
    ElseIf ProgramParameter(0)="--initzip"
      Errors$ = pbhelp::inithelpzip(ProgramParameter(1), ProgramParameter(2))
    Else
      Errors$ = pbhelp::inithelp(ProgramParameter(1), ProgramParameter(2))
    EndIf
    If Errors$ <> ""
      If OpenConsole()
        ConsoleError(RTrim(Errors$, #LF$))
      EndIf
      End 1
    EndIf
    End
  EndIf

  pbhelp::init("French","Windows")

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

    If pbhelp::show(Name$)
      ProcedureReturn #True
    EndIf

    pbhelp::show("reference")
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
    pbhelp::timer()
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

    pbhelp::OpenCodeCallback = @HelpTool_OpenCode()
    pbhelp::EditFileCallback = @HelpTool_EditFile()
    pbhelp::ColorCodeCallback = @HelpTool_ColorCode()
    ; User libraries in the contents tree: same color as in the help pages, when the tree uses the IDE colors
    If (*Entry\IsSeparateWindow = 0 Or NoIndependentToolsColors = 0) And ToolsPanelUseColors
      UserLibColor = Colors(#COLOR_CustomKeyword)\DisplayValue
    Else
      UserLibColor = $008800
    EndIf
    If *Entry\IsSeparateWindow = 0 Or NoIndependentToolsColors = 0
      pbhelp::ApplyColorsCallback = @ToolsPanel_ApplyColors()
    Else
      pbhelp::ApplyColorsCallback = 0
    EndIf
    pbhelp::setcolors(HelpTool_ThemeColors(), UserLibColor)
    pbhelp::setimages(#IMAGE_Help_Back, #IMAGE_Help_Forward, #IMAGE_Help_Home, #IMAGE_Help_Edit, #IMAGE_Help_Index, HelpTool_ImageBase64(#IMAGE_Help_LoadCode), HelpTool_ImageBase64(#IMAGE_Help_RunCode))
    pbhelp::setup(HelpTool_Language(Source$), OS$, Source$, PureBasicPath$ + "PureLibraries" + #Separator + "UserLibraries" + #Separator, PureBasicPath$ + "Examples" + #Separator)

    If *Entry\IsSeparateWindow
      pbhelp::create(*Entry\ToolWindowID)
    Else
      pbhelp::create(#WINDOW_Main)
    EndIf

    ; Reload the help when its source is modified (help edition)
    AddWindowTimer(#WINDOW_Main, #TIMER_HelpTool, 1000)
    BindEvent(#PB_Event_Timer, @HelpTool_Timer(), #WINDOW_Main, #TIMER_HelpTool)

    HelpToolOpen = #True

  EndProcedure

  Procedure Help_DestroyFunction(*Entry.ToolsPanelEntry)

    RemoveWindowTimer(#WINDOW_Main, #TIMER_HelpTool)
    UnbindEvent(#PB_Event_Timer, @HelpTool_Timer(), #WINDOW_Main, #TIMER_HelpTool)
    pbhelp::destroy()

    HelpToolOpen = #False

  EndProcedure


  Procedure Help_ResizeHandler(*Entry.ToolsPanelEntry, PanelWidth, PanelHeight)

    pbhelp::resize(PanelWidth, PanelHeight)

  EndProcedure

  Procedure Help_EventHandler(*Entry.ToolsPanelEntry, EventGadgetID)

    pbhelp::gadgetevent(EventGadgetID, EventType())

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
