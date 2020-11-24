;
; ------------------------------------------------------------
;
;   PureBasic - Database example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

UseSQLiteDatabase()

Procedure CheckDatabaseUpdate(Database, Query$)
   Result = DatabaseUpdate(Database, Query$)
   If Result = 0
      Debug DatabaseError()
   EndIf
   
   ProcedureReturn Result
EndProcedure

DatabaseFile$ = GetTemporaryDirectory()+"Database.sqlite"

If CreateFile(0, DatabaseFile$)
   CloseFile(0)
   
   If OpenDatabase(0, DatabaseFile$, "", "")
   
      CheckDatabaseUpdate(0, "CREATE TABLE food (name CHAR(50), weight INT)")

      CheckDatabaseUpdate(0, "INSERT INTO food (name, weight) VALUES ('apple', '10')")
      CheckDatabaseUpdate(0, "INSERT INTO food (name, weight) VALUES ('pear', '5')")
      CheckDatabaseUpdate(0, "INSERT INTO food (name, weight) VALUES ('banana', '20')")
      
      If DatabaseQuery(0, "SELECT * FROM food WHERE weight > 7")
      
         While NextDatabaseRow(0)
            Debug GetDatabaseString(0, 0)
         Wend
      
         FinishDatabaseQuery(0)
      EndIf
      
      CloseDatabase(0)
   Else
      Debug "Can't open database !"
   EndIf
Else
   Debug "Can't create the database file !"
EndIf
