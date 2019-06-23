/*------------------------------------------------------------------------
File        : cbapln.i
Purpose     : Lignes des saisie de paiement rapide
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCbapln
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field affair-num as integer    initial ? 
    field analytique as logical    initial ? 
    field cpt-cd     as character  initial ? 
    field cpt-ctp    as character  initial ? 
    field etab-cd    as integer    initial ? 
    field fg-ana100  as logical    initial ? 
    field lig        as integer    initial ? 
    field mt         as decimal    initial ?  decimals 2
    field mt-EURO    as decimal    initial ?  decimals 2
    field mtdev      as decimal    initial ?  decimals 2
    field num-int    as integer    initial ? 
    field sens       as logical    initial ? 
    field soc-cd     as integer    initial ? 
    field sscoll-cle as character  initial ? 
    field sscoll-ctp as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
