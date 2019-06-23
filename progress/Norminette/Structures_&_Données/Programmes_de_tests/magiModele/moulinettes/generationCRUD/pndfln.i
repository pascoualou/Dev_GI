/*------------------------------------------------------------------------
File        : pndfln.i
Purpose     : Fichier lignes notes de frais
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttPndfln
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field affair-num       as integer    initial ? 
    field ana1-cd          as character  initial ? 
    field ana2-cd          as character  initial ? 
    field ana3-cd          as character  initial ? 
    field ana4-cd          as character  initial ? 
    field analytique       as logical    initial ? 
    field coll-cle         as character  initial ? 
    field cpt-cd           as character  initial ? 
    field dev-cd           as character  initial ? 
    field devetr-cd        as character  initial ? 
    field etab-cd          as integer    initial ? 
    field lib              as character  initial ? 
    field libndf-cd        as integer    initial ? 
    field lig              as integer    initial ? 
    field mt               as decimal    initial ?  decimals 2
    field mt-EURO          as decimal    initial ?  decimals 2
    field mt1              as decimal    initial ?  decimals 2
    field mt1-EURO         as decimal    initial ?  decimals 2
    field mt2              as decimal    initial ?  decimals 2
    field mt2-EURO         as decimal    initial ?  decimals 2
    field mtdev            as decimal    initial ?  decimals 2
    field mtdev1           as decimal    initial ?  decimals 2
    field mtdev2           as decimal    initial ?  decimals 2
    field num-int          as integer    initial ? 
    field sens             as logical    initial ? 
    field signe            as character  initial ? 
    field soc-cd           as integer    initial ? 
    field sscoll-cle       as character  initial ? 
    field taux             as decimal    initial ?  decimals 8
    field taxe-cd          as integer    initial ? 
    field tiers-cpt-cd     as character  initial ? 
    field tiers-sscoll-cle as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
