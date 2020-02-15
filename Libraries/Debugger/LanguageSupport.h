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

/*
 * Language support for the Debugger (and Compiler)
 *
 * - Uses the same Language file format as the IDE
 * - Independent from the Debugger, can be used anywhere
 */

typedef struct
{
  const char *Key;
  const char *Value;
} PB_LanguageItem;

// Set the default language values.
//
// Table is a string table, in pairs "key", "value", must be a static buffer (will not be copied)
// Spechial keys:
//    "_GROUP_" to start a new group
//    "_END_"   to end the language table
//
// This function can be called multiple times (even after a language file is loaded)
// If a group name already exists, the group content is overwritten, else it is added.
// (Used by the debugger for the libraries debugger strings)
//
void PB_Language_SetDefault(char **Table);

// Used by the debugger mainly (PB_DEBUGGER_GetLanguage())
// Set the default strings for one group only, table ends with 2 null pointers
//
void PB_Language_SetDefaultGroup(char *GroupName, char **Table);

// Load the given language
//
// The function first tries "CatalogPath/Language/DefaultFile", and if this does not
// succeed, searches the entire Catalog path for a matching file (like the IDE)
//
int PB_Language_Load(const char *Language, const char *AppID, const char *CatalogPath, const char *DefaultFile);

// get the language entry in Group with Key (case insensitive)
// returns a debug string if no entry found
//
char *PB_Language_GetKey(const char *Group, const char *Key);

// simple wrapper for the compiler
//
char *PB_Language_GetIndex(char *Group, int Index);

#define Language(Group, Key)        PB_Language_GetKey(Group, Key)
#define LanguageIndex(Group, Index) PB_Language_GetIndex(Group, Index)
