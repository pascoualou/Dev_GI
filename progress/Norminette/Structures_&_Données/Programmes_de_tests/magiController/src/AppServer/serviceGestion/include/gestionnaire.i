/*------------------------------------------------------------------------
File        : gestionnaire.i
Purpose     : 
Author(s)   : 
Notes       :
derniere revue: 2018/05/24 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttGestionnaire
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroImmeuble     as integer
    field iNumeroContrat      as integer
    field cTypeContrat        as character
    field cNumeroGestionnaire as character
    field cNomGestionnaire    as character

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
