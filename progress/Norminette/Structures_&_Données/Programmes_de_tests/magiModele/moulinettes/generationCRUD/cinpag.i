/*------------------------------------------------------------------------
File        : cinpag.i
Purpose     : fichier parametre generaux
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCinpag
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field amort       as logical    initial ? 
    field chrono      as character  initial ? 
    field etab-cd     as integer    initial ? 
    field fpiece      as character  initial ? 
    field invest-cle  as character  initial ? 
    field jou-cd      as character  initial ? 
    field lib         as character  initial ? 
    field num-int     as integer    initial ? 
    field soc-cd      as integer    initial ? 
    field txvplafond  as decimal    initial ?  decimals 2
    field txvplancher as decimal    initial ?  decimals 2
    field type-cle    as character  initial ? 
    field type-invest as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
