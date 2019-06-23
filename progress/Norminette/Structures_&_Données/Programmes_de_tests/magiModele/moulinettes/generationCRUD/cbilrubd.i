/*------------------------------------------------------------------------
File        : cbilrubd.i
Purpose     : cbilrubd
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCbilrubd
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field bilan-cd    as character  initial ? 
    field colonne-num as integer    initial ? 
    field cpt-rub     as character  initial ? 
    field etab-cd     as integer    initial ? 
    field lettre-cle  as character  initial ? 
    field libpays-cd  as character  initial ? 
    field num-int     as integer    initial ? 
    field ordre-cle   as character  initial ? 
    field sens        as character  initial ? 
    field sequence    as character  initial ? 
    field soc-cd      as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
