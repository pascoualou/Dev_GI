/*------------------------------------------------------------------------
File        : serviceGestion.i
Purpose     :
Author(s)   :
Notes       :
derniere revue: 2018/05/24 - phm: OK
----------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttServiceGestion
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iNumeroImmeuble as integer   initial ?
    field iNumeroContrat  as integer   initial ?
    field cTypeContrat    as character initial ?
    field cNumeroService  as character initial ?
    field cNomService     as character initial ?

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
