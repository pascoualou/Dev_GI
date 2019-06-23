/*------------------------------------------------------------------------
File        : ilnotfrais.i
Purpose     : Fichier lignes de note de frais
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIlnotfrais
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field ana1-cd     as character  initial ? 
    field ana2-cd     as character  initial ? 
    field ana3-cd     as character  initial ? 
    field ana4-cd     as character  initial ? 
    field etab-cd     as integer    initial ? 
    field fic-num     as integer    initial ? 
    field mtht        as decimal    initial ?  decimals 2
    field mtht-EURO   as decimal    initial ?  decimals 2
    field mtttc       as decimal    initial ?  decimals 2
    field mtttc-EURO  as decimal    initial ?  decimals 2
    field mttva       as decimal    initial ?  decimals 2
    field mttva-EURO  as decimal    initial ?  decimals 2
    field notfrais-cd as integer    initial ? 
    field soc-cd      as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
