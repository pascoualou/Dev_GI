/*------------------------------------------------------------------------
File        : GL_HONORAIRE.i
Purpose     : Liste des éléments financiers de type honoraires
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttGl_honoraire
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cdcsy        as character  initial ? 
    field cdmsy        as character  initial ? 
    field dtcsy        as date       initial ? 
    field dtmsy        as date       initial ? 
    field hecsy        as integer    initial ? 
    field hemsy        as integer    initial ? 
    field nobareme     as integer    initial ? 
    field nofinance    as integer    initial ? 
    field nohonoraire  as integer    initial ? 
    field totalht      as decimal    initial ?  decimals 2
    field totalttc     as decimal    initial ?  decimals 2
    field tphonoraire1 as integer    initial ? 
    field tphonoraire2 as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
