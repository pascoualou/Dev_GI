/*------------------------------------------------------------------------
File        : itaxe.i
Purpose     : Liste des differents taux de taxes.
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttItaxe
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cpt-cd     as character  initial ? 
    field cptabt-ach as character  initial ? 
    field cptabt-ven as character  initial ? 
    field cptinv-ach as character  initial ? 
    field cptpro-ach as character  initial ? 
    field cptpro-ven as character  initial ? 
    field cpttva-ach as character  initial ? 
    field cpttva-ven as character  initial ? 
    field dacrea     as date       initial ? 
    field damod      as date       initial ? 
    field etab-cd    as integer    initial ? 
    field ihcrea     as integer    initial ? 
    field ihmod      as integer    initial ? 
    field lib        as character  initial ? 
    field libass-cd  as integer    initial ? 
    field port-emb   as logical    initial ? 
    field soc-cd     as integer    initial ? 
    field taux       as decimal    initial ?  decimals 8
    field taxe-cd    as integer    initial ? 
    field ttaxe      as integer    initial ? 
    field ttaxe2     as integer    initial ? 
    field type       as logical    initial ? 
    field usrid      as character  initial ? 
    field usridmod   as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
