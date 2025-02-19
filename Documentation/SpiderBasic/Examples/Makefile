
EXAMPLES =  2DDrawing.html \
            Array.html \
            CanvasGadget.html \
            Cipher.html \
            Database.html \
            DatabasePersistent.html \
            Date.html \
            Desktop.html \
            Dialog.html \
            DialogComplex.html \
            File.html \
            FilePersistent.html \
            FileStreaming.html \
            Font.html \
            Gadget.html \
            GadgetOverview.html \
            Http.html \
            Image.html \
            InAppPurchase.html \
            InlinedJS.html \
            Joystick.html \
            Json.html \
            Keyboard.html \
            List.html \
            Map.html \
            Math.html \
            Memory.html \
            Menu.html \
            Mouse.html \
            MultiWindows.html \
            OpenFileRequester.html \
            PopupMenu.html \
            RegularExpression.html \
            Requester.html \
            Runtime.html \
            Screen.html \
            Sort.html \
            Sound.html \
            Sprite.html \
            String.html \
            System.html \
            ToolBar.html \
            TouchScreen.html \
            Window.html \
            WindowedScreen.html \
            Xml.html



all: $(EXAMPLES)
	rm -f *.html *.js

%.html : %.sb
	sbcompiler $< /QUIET /OUTPUT $@
