/*------------------------------------------------------------------------
File        : cblock.i
Purpose     : 
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCblock
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field act-cle    as character  initial ? 
    field coll-cle   as character  initial ? 
    field cpt-cd     as character  initial ? 
    field daAlerte   as date       initial ? 
    field dacre      as date       initial ? 
    field daech-prev as date       initial ? 
    field daech-reel as date       initial ? 
    field dapenalite as date       initial ? 
    field darelan    as date       initial ? 
    field etab-cd    as integer    initial ? 
    field fg-alerte  as logical    initial ? 
    field frais      as decimal    initial ?  decimals 2
    field frais-EURO as decimal    initial ?  decimals 2
    field hcre       as integer    initial ? 
    field ind-cle    as character  initial ? 
    field ind2-cle   as character  initial ? 
    field jou-cd     as character  initial ? 
    field lib        as character  initial ? 
    field lig        as integer    initial ? 
    field mtpenalite as decimal    initial ?  decimals 2
    field noact      as character  initial ? 
    field noeve      as character  initial ? 
    field ori-cle    as character  initial ? 
    field piece-int  as integer    initial ? 
    field pos        as integer    initial ? 
    field prd-cd     as integer    initial ? 
    field prd-num    as integer    initial ? 
    field ref-num    as character  initial ? 
    field relan-niv  as integer    initial ? 
    field relan-num  as integer    initial ? 
    field relance-cd as integer    initial ? 
    field rgt-cd     as character  initial ? 
    field scen-cle   as character  initial ? 
    field soc-cd     as integer    initial ? 
    field type-cle   as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
