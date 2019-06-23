/*------------------------------------------------------------------------
File        : RqChpEnt.i
Purpose     : Entete des champs: Seuls les infos fixes définissant la base du champ. Les options du champ sont dans RqChpDet
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttRqchpent
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdchp  as character  initial ? 
    field cdcsy  as character  initial ? 
    field cdmsy  as character  initial ? 
    field cdreq  as character  initial ? 
    field dtcsy  as date       initial ? 
    field dtmsy  as date       initial ? 
    field hecsy  as integer    initial ? 
    field hemsy  as integer    initial ? 
    field lbchp  as character  initial ? 
    field lbdiv  as character  initial ? 
    field lbdiv2 as character  initial ? 
    field lbdiv3 as character  initial ? 
    field nochf  as integer    initial ? 
    field nochp  as integer    initial ? 
    field noord  as integer    initial ? 
    field tpchp  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
