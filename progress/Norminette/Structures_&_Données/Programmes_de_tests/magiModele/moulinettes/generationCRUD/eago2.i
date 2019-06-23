/*------------------------------------------------------------------------
File        : eago2.i
Purpose     : Stockage du texte par tranches de 5 lignes de 75 caractères (max 999 lig)
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttEago2
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy  as character  initial ? 
    field cddev  as character  initial ? 
    field cdmsy  as character  initial ? 
    field dtcsy  as date       initial ? 
    field dtmsy  as date       initial ? 
    field hecsy  as integer    initial ? 
    field hemsy  as integer    initial ? 
    field lbdiv  as character  initial ? 
    field lbdiv2 as character  initial ? 
    field lbdiv3 as character  initial ? 
    field lign1  as character  initial ? 
    field lign2  as character  initial ? 
    field lign3  as character  initial ? 
    field lign4  as character  initial ? 
    field lign5  as character  initial ? 
    field noadd  as integer    initial ? 
    field nogrp  as integer    initial ? 
    field noint  as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
