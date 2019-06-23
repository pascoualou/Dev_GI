/*------------------------------------------------------------------------
File        : aentrefa.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttAentrefa
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ana1-cd          as character  initial ? 
    field ana2-cd          as character  initial ? 
    field ana3-cd          as character  initial ? 
    field ana3sub-cd       as character  initial ? 
    field ana4-cd          as character  initial ? 
    field cdlib            as integer    initial ? 
    field cdrub            as integer    initial ? 
    field dacompta         as date       initial ? 
    field daecr            as date       initial ? 
    field divers           as character  initial ? 
    field etab-cd          as integer    initial ? 
    field fgfac            as logical    initial ? 
    field fourn-cpt-cd     as character  initial ? 
    field fourn-sscoll-cle as character  initial ? 
    field jou-cd           as character  initial ? 
    field lib              as character  initial ? 
    field lig              as integer    initial ? 
    field mtdepttc         as decimal    initial ?  decimals 2
    field mtrefac          as decimal    initial ?  decimals 2
    field num-int          as integer    initial ? 
    field piece-compta     as integer    initial ? 
    field piece-int        as integer    initial ? 
    field pos              as integer    initial ? 
    field prd-cd           as integer    initial ? 
    field prd-num          as integer    initial ? 
    field sens             as logical    initial ? 
    field soc-cd           as integer    initial ? 
    field type-cle         as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
