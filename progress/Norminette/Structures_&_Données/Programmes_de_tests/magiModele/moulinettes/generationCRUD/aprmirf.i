/*------------------------------------------------------------------------
File        : aprmirf.i
Purpose     : Table des codes IRF (2044, 2044S & 2072)
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAprmirf
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field annee      as integer    initial ? 
    field cd2044     as character  initial ? 
    field cd2044N-1  as character  initial ? 
    field cd2044S    as character  initial ? 
    field cd2044SN-1 as character  initial ? 
    field cd2072     as character  initial ? 
    field cd2072N-1  as character  initial ? 
    field cdgi       as character  initial ? 
    field divers     as character  initial ? 
    field lb2044S    as character  initial ? 
    field lib2044    as character  initial ? 
    field lib2072    as character  initial ? 
    field ordre      as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
