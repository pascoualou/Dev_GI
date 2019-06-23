/*------------------------------------------------------------------------
File        : cd2par.i
Purpose     : parametres generaux DAS2
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCd2par
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ana1-cd      as character  initial ? 
    field ana2-cd      as character  initial ? 
    field ana3-cd      as character  initial ? 
    field ana4-cd      as character  initial ? 
    field assiette-cle as character  initial ? 
    field etab-cd      as integer    initial ? 
    field mt-min       as decimal    initial ?  decimals 2
    field mt-min-EURO  as decimal    initial ?  decimals 2
    field prddeb       as character  initial ? 
    field prdfin       as character  initial ? 
    field soc-cd       as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
