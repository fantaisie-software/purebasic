/* === Copyright Notice ===
 *
 *
 *                  PureBasic source code file
 *
 *
 * This file is part of the PureBasic Software package. It may not
 * be distributed or published in source code or binary form without
 * the expressed permission by Fantaisie Software.
 *
 * By contributing modifications or additions to this file, you grant
 * Fantaisie Software the rights to use, modify and distribute your
 * work in the PureBasic package.
 *
 *
 * Copyright (C) 2000-2010 Fantaisie Software - all rights reserved
 *
 */

#define LIBRARYINFO_Objects  0x00000001 // ExamineObjects() and NextObject() is implemented
#define LIBRARYINFO_Text     0x00000002 // GetObjectText() is implemented
#define LIBRARYINFO_Data     0x00000004 // GetObjectData() and FreeObjectData() is implemented
#define LIBRARYINFO_SwapData 0x00000008 // SwapObjectData() is implemented

typedef struct PB_StructureLibraryInfo
{
  int size;          // must be sizeof this structure (for future compatibility)
  int mask;          // LIBRARYINFO mask (defines the provided information)

  char *LibraryID;   // unique ID string for this library (for internal use)
  char *Name;        // Library Name as displayed to the user
  char *NameShort;   // Library Name as used in ShowLibraryViewer("name")

  char *ListTitles;  // for LIBRARYINFO_Objects: provides a Tab separated list of table headers (for the ListIcon display. format: TITLE1<tab>Size1<tab>TITLE2<tab>Size2)

  int (*ExamineObjects)(void); // start object enumeration (return true if successful, false if not)
  int (*NextObject)(integer *id, char *buffer); // get next object. fill id and **info with unique ID and text for ListIcon line (Tab separated as the title string), return 0 for no more objects
  int (*GetObjectText)(integer id, char *buffer); // get Text info on the given id object (return success or failure)
  int (*GetObjectData)(integer id, void **data, integer *size); // get data representation of the id object (return success or failure)
  void (*FreeObjectData)(void *data); // called after GetObjectData to free the buffer again.
  void (*SwapObjectData)(void *data, integer size); // byteswap the object data for big endian->little endian conversions
} PB_LibraryInfo;

/* Register a library for the Library Viewer:
 * The passed PB_DebuggerLibraryInfo structure must be initialized, and stay persistent during the whole
 * run of the program (the debugger does not store the contained data itself, the library must do that!
 */
void PB_DEBUGGER_RegisterLibrary(PB_LibraryInfo *library);


/* Common format for images in the LibraryViewer on all OS
 *
 */
typedef struct
{
  int Format;         // PB_PixelFormat values (32bit or 24bit only)
  int BytesPerPixel;  // 3 or 4
  int Pitch;
  int Width;
  int Height;         // Following is the image data in top-down format
} PB_LibraryViewer_Image;
