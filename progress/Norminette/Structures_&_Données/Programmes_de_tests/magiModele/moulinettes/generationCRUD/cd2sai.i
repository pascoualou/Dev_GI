/*------------------------------------------------------------------------
File        : cd2sai.i
Purpose     : Informations fournisseurs DAS2
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCd2sai
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field adr              as character  initial ? 
    field ana1-cd          as character  initial ? 
    field ana2-cd          as character  initial ? 
    field ana3-cd          as character  initial ? 
    field ana4-cd          as character  initial ? 
    field cp               as character  initial ? 
    field dadeb            as date       initial ? 
    field dafin            as date       initial ? 
    field das2-cd          as integer    initial ? 
    field etab-cd          as integer    initial ? 
    field fg-declarer      as logical    initial ? 
    field fg-edi           as logical    initial ? 
    field fg-existe        as logical    initial ? 
    field fg-valide        as logical    initial ? 
    field fourn-cpt-cd     as character  initial ? 
    field fourn-sscoll-cle as character  initial ? 
    field mt-total         as decimal    initial ?  decimals 2
    field mt-total-EURO    as decimal    initial ?  decimals 2
    field nom              as character  initial ? 
    field num-int          as integer    initial ? 
    field prof-cle         as character  initial ? 
    field siret            as character  initial ? 
    field soc-cd           as integer    initial ? 
    field ville            as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
