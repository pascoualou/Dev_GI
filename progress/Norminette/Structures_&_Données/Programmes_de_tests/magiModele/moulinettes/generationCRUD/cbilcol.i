/*------------------------------------------------------------------------
File        : cbilcol.i
Purpose     : Detail colonne des bilans
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCbilcol
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field bilan-cd    as character  initial ? 
    field colonne-num as character  initial ? 
    field etab-cd     as integer    initial ? 
    field lib1        as character  initial ? 
    field lib2        as character  initial ? 
    field lib3        as character  initial ? 
    field libpays-cd  as character  initial ? 
    field longueur    as integer    initial ? 
    field sign-deb    as logical    initial ? 
    field soc-cd      as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
