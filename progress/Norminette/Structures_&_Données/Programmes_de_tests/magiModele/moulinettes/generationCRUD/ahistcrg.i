/*------------------------------------------------------------------------
File        : ahistcrg.i
Purpose     : Historique des CRG
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAhistcrg
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field benef        as character  initial ? 
    field cpt-cd       as character  initial ? 
    field dacrea       as date       initial ? 
    field divers       as character  initial ? 
    field dtdeb        as date       initial ? 
    field dtfin        as date       initial ? 
    field etab-cd      as integer    initial ? 
    field fg-local     as logical    initial ? 
    field fg-odrt      as logical    initial ? 
    field fg-valid     as logical    initial ? 
    field ihcrea       as integer    initial ? 
    field mt-crg       as decimal    initial ?  decimals 2
    field mt-prorata   as decimal    initial ?  decimals 2
    field mt-rglp      as decimal    initial ?  decimals 2
    field nomfic       as character  initial ? 
    field num-crg      as integer    initial ? 
    field num-retirage as integer    initial ? 
    field num-rlv      as integer    initial ? 
    field regl-cd      as integer    initial ? 
    field soc-cd       as integer    initial ? 
    field type-crg     as character  initial ? 
    field usrid        as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
