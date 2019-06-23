/*------------------------------------------------------------------------
File        : tacheService.i
Purpose     : 
Author(s)   : GGA  -  2017/08/17
Notes       :
derniere revue: 2018/05/19 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttTacheService
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cTypeContrat    as character initial ?
    field iNumeroContrat  as int64     initial ?
    field cTypeTache      as character initial ?
    field iService        as integer   initial ?
    field cLibelleService as character initial ?
    field cLibelleAdresse as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
&if defined(nomTableListe)   = 0 &then &scoped-define nomTableListe ttListeService
&endif
&if defined(serialNameListe) = 0 &then &scoped-define serialNameListe {&nomTableListe}
&endif
define temp-table {&nomTableListe} no-undo serialize-name '{&serialNameListe}'
    field iNocon          as integer   initial ?
    field iNorol          as integer   initial ?
    field cNoree          as character initial ?
    field cLibelleAdresse as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
