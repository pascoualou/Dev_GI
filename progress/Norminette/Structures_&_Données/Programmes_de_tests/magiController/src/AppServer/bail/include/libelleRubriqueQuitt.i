/*------------------------------------------------------------------------
File        : libelleRubriqueQuitt.i
Purpose     :
Author(s)   : GGA 2018/07/20
Notes       :
derniere revue: 2018/07/24 - phm: OK
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttLibelleRubriqueQuitt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field iCodeRubrique     as integer
    field iCodeLibelle      as integer
    field iTypeLibelle      as integer
    field cLibelleRubrique  as character

    field dtTimestamp as datetime
    field CRUD        as character
    field rRowid      as rowid
.
