/*------------------------------------------------------------------------
File        : irelln.i
Purpose     : Lettres de relances a editer
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIrelln
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cli-cle   as character  initial ? 
    field daecr     as date       initial ? 
    field darel     as date       initial ? 
    field edi       as logical    initial ? 
    field etab-cd   as integer    initial ? 
    field jou-cd    as character  initial ? 
    field piece-int as integer    initial ? 
    field prd-cd    as integer    initial ? 
    field prd-num   as integer    initial ? 
    field ref-num   as character  initial ? 
    field rel-num   as integer    initial ? 
    field soc-cd    as integer    initial ? 
    field type-cle  as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
