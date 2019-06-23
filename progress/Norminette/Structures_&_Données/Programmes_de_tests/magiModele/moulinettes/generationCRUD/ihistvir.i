/*------------------------------------------------------------------------
File        : ihistvir.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIhistvir
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field bque      as character  initial ? 
    field cpt       as character  initial ? 
    field dacrea    as date       initial ? 
    field fic-nom   as character  initial ? 
    field guichet   as character  initial ? 
    field MsgId     as character  initial ? 
    field nblig-cpt as integer    initial ? 
    field nblig-sup as integer    initial ? 
    field nblig-tot as integer    initial ? 
    field soc-cd    as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
