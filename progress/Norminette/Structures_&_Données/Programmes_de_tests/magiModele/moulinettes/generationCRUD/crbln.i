/*------------------------------------------------------------------------
File        : crbln.i
Purpose     : Fichier lignes rapprochements bancaires
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCrbln
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field daecr       as date       initial ? 
    field etab-cd     as integer    initial ? 
    field jou-cd      as character  initial ? 
    field lbcom       as character  initial ? 
    field lettre      as character  initial ? 
    field lib         as character  initial ? 
    field libope-cd   as character  initial ? 
    field lig         as integer    initial ? 
    field mt          as decimal    initial ?  decimals 2
    field mt-EURO     as decimal    initial ?  decimals 2
    field num-int     as integer    initial ? 
    field piece-int   as integer    initial ? 
    field pointage    as logical    initial ? 
    field prd-cd      as integer    initial ? 
    field prd-num     as integer    initial ? 
    field ref-num     as character  initial ? 
    field sens        as logical    initial ? 
    field soc-cd      as integer    initial ? 
    field type-cle    as character  initial ? 
    field type-op     as character  initial ? 
    field type-op-int as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
