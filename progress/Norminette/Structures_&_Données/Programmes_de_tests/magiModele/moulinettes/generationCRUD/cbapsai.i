/*------------------------------------------------------------------------
File        : cbapsai.i
Purpose     : Entete des saisie de paiement rapide
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCbapsai
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field chrono      as integer    initial ? 
    field cours       as decimal    initial ?  decimals 2
    field dacompta    as date       initial ? 
    field dacrea      as date       initial ? 
    field daech       as date       initial ? 
    field damod       as date       initial ? 
    field dev-cd      as character  initial ? 
    field etab-cd     as integer    initial ? 
    field fg-regl     as logical    initial ? 
    field fg-statut   as logical    initial ? 
    field gest-cle    as character  initial ? 
    field ihcrea      as integer    initial ? 
    field ihmod       as integer    initial ? 
    field jou-cd      as character  initial ? 
    field lib-ecr     as character  initial ? 
    field mt-tot      as decimal    initial ?  decimals 2
    field mt-tot-euro as decimal    initial ?  decimals 2
    field num-int     as integer    initial ? 
    field prd-cd      as integer    initial ? 
    field prd-num     as integer    initial ? 
    field regl-cd     as integer    initial ? 
    field soc-cd      as integer    initial ? 
    field usrid       as character  initial ? 
    field usridmod    as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
