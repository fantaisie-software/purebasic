; 
; ReadMe - How to write proper documentation for PureBasic
;

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

I. About writing proper descriptions in the commands

1) Include references to other commands (same library and other libraries, and to
   the reference chapters as well) whenever this makes sense.
   
   Links to other manual sections can be made this way:

     @@FunctionName                        - direct link to the function (any library)
     @Link "DrawImage" "DrawImage()"       - direct link to a command (same library)
     @Link "Image/DrawImage" "DrawImage()" - direct link to a command (other library)
     @LibraryLink "Image" "text"           - link to the start site of a library
     @ReferenceLink "colortable" "text"    - link to a chapter in reference guide

   Use the @@FunctionName notation wherever a link of the form
   @Link "Library/Function" "Function()" is not needed, because it is the shortest form.
   Use the general @Link form only to make links with a different text than the function name.

   The following link form is still supported for compatibility, but should no longer be used:

     @FastLink "DrawImage()"               - direct link to a command (same library) short version

2) For the function syntax line, only include a "Result = " if the function actually returns something.
   The Result part should indicate the type of the return value:

     @Function Result$ = ReplaceString(...
     @Function Result.f = ValF(...
     @Function CloseWindow(...

3) Always include a parameters and returnvalue section. If they are empty, use the
   shortcuts @NoParameters or @NoReturnValue but do not leave them out!

4) Describe ALL parameters to a function with a @Parameter statement, even if their meaning seems obvious.
   Multiple parameters can be described in one go if they belong together, but every
   parameter must be listed somewhere:
  
     @Parameter "x, y, Width, Height"
       Specifies the location and dimensions of the box to draw.

5) Mark optional parameters with @OptionalParameter line, and describe in the text what happens if they
   are left out:

     @OptionalParameter "Depth"
       Specifies the depth for the new image. [...] The default depth is 24-bit.

6) Keep the @Description section short. If there is much extra stuff to say, put it in
   a @Remarks section after parameters and return value.

7) Stuff to put in the @SeeAlso section:

    - commands that are mentioned/linked elsewhere in the page for the current command
      (for example in the @Remarks section). This is for fast access after the user read the whole page.

    - commands that must be used to create a parameter for the current command:
        ImageGadget() -> ImageID()
   
    - all open/close commands that correspond to the current command:
        OpenConsole() -> CloseConsole()
        FreeImage()   -> CreateImage(), LoadImage(), CatchImage()

    - commands that have to be used together with the current command:
        NextDirectoryEntry() -> ExamineDirectory(), FinishDirectory(), DirectoryEntry[Name, Type, etc]()

    - commands that perform a similar/related function as the current command

        Line()  -> LineXY()
        Print() -> PrintN()

    - other commands that the user might want to know about in relation to this command.
      Do not overdo this though: don't list all commands of the current library etc.

8) Order of sections for a function:

    @Function
    @Description
    @Parameter (for each parameter)
    @ReturnValue
    @Remarks (optional)
    @Example (optional, can be more than one)
    image(s) (optional)
    @SeeAlso
    @SupportedOS

  Images should be accompanied by the code that produced the image/screenshot as an example,
  so the user can recreate the same image and experiment with the code.

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

II. About taking screenshots

Screenshots should be taken with the same tool and consistent settings.
Unless things are OS specific, they should be taken under Windows 7.

1) Use 'Greenshot': http://getgreenshot.org/

   To take screenshots of whole windows:
   
     In the preferences of Greenshot under "Capture" -> "Window capture", select
     "Window capture mode" and "Use custom color". Enter #66B2FF as the color to use.
     
   To take screenshots of parts of a window, the "Use interactive window capture mode" 
   is fine.

2) Use Windows 7 with the default theme

3) Use a PB setup with the default preferences settings and color theme

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

III. About the sample codes in the commands (the goal is to have consistent looking
   code sources)

1) Always uses a 2 spaces indent, also before the first statement

      @Code
        If a = 10
          If b = 10
          
          EndIf
        EndIf
      @EndCode


2) Don't use type if not absolutely necessary (no .w, .b) as it makes the code
   a bit harder to read.

      Ok:
      ---
      
        For k = 0 To 10
        
        Next
        
      Wrong:
      ------
      
        For k.w = 0 To 10
        
        Next
  
3) Put spaces between parameters, operations, constants etc.

      Ok:
      ---
      
        If OpenWindow(0, 0, 0, 100, 100, "Test", #PB_Window_SystemMenu | #PB_MaximizeGadget)
        
        EndIf
        
      
      Wrong:
      ------
      
        If OpenWindow(0,0,0,100,100,"Test",#PB_Window_SystemMenu|#PB_MaximizeGadget)
        
        EndIf
  

4) Don't use the 'End', 'FreeXXX()', 'CloseXXX()' statement unless if it's necessary. 
   It makes the code clearer:

      Ok:
      ---
      
      @Code
        OpenConsole()
        
        If ReadFile(0, "C:\Test.txt")
          PrintN(ReadString())
        EndIf
      @EndCode
      
      Wrong:
      ------
      
      @Code
        OpenConsole()
        
        If ReadFile(0, "C:\Test.txt")
          PrintN(ReadString())
          CloseFile(0)
        EndIf
        
        CloseConsole()
        End
      @EndCode


5) The variables, etc. should be mixed-case, without '_'

  Ok: MyVariable
  
  Wrong: my_variable, My_Variable


6) Add more here if needed :p !
