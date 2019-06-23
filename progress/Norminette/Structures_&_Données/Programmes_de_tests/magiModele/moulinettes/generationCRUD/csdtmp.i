/*------------------------------------------------------------------------
File        : csdtmp.i
Purpose     : Solde des dossiers: fichier temporaire
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCsdtmp
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ana1-cd    as character  initial ? 
    field ana1-ctp   as character  initial ? 
    field ana2-cd    as character  initial ? 
    field ana2-ctp   as character  initial ? 
    field ana3-cd    as character  initial ? 
    field ana3-ctp   as character  initial ? 
    field ana4-cd    as character  initial ? 
    field ana4-ctp   as character  initial ? 
    field bas        as logical    initial ? 
    field coll-cle   as character  initial ? 
    field cpt-cd     as character  initial ? 
    field cpt-ctp    as character  initial ? 
    field etab-cd    as integer    initial ? 
    field mt         as decimal    initial ?  decimals 2
    field mt-EURO    as decimal    initial ?  decimals 2
    field order-num  as integer    initial ? 
    field sens       as logical    initial ? 
    field soc-cd     as integer    initial ? 
    field sscoll-cle as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
