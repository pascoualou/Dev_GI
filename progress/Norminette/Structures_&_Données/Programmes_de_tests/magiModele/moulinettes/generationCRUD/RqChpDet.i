/*------------------------------------------------------------------------
File        : RqChpDet.i
Purpose     : Détails du champ : chaque enregistrement correspond à une colonne du browse correspondant
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttRqchpdet
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdchp  as character  initial ? 
    field cdcsy  as character  initial ? 
    field cddet  as character  initial ? 
    field cdmsy  as character  initial ? 
    field cdreq  as character  initial ? 
    field dtcsy  as date       initial ? 
    field dtmsy  as date       initial ? 
    field hecsy  as integer    initial ? 
    field hemsy  as integer    initial ? 
    field lbdiv  as character  initial ? 
    field lbdiv2 as character  initial ? 
    field lbdiv3 as character  initial ? 
    field nochp  as integer    initial ? 
    field vldet  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
