/*------------------------------------------------------------------------
File        : cpaiebq.i
Purpose     : Fichier Repartition par Banque (Prepaparation des paiements fournisseurs)
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCpaiebq
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field affecte        as decimal    initial ?  decimals 2
    field affecte-EURO   as decimal    initial ?  decimals 2
    field bqjou-cd       as character  initial ? 
    field chrono         as integer    initial ? 
    field daech-deb      as date       initial ? 
    field daech-fin      as date       initial ? 
    field dapaie         as date       initial ? 
    field eapjou-cd      as character  initial ? 
    field etab-cd        as integer    initial ? 
    field gest-cle       as character  initial ? 
    field libpaie-cd     as integer    initial ? 
    field mtmax          as decimal    initial ?  decimals 2
    field mtmax-EURO     as decimal    initial ?  decimals 2
    field mtreparti      as decimal    initial ?  decimals 2
    field mtreparti-EURO as decimal    initial ?  decimals 2
    field order-num      as integer    initial ? 
    field soc-cd         as integer    initial ? 
    field TpMod          as character  initial ? 
    field txmax          as decimal    initial ?  decimals 2
    field txtol          as decimal    initial ?  decimals 2
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
