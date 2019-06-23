/*------------------------------------------------------------------------
File        : ifrais.i
Purpose     : Liste des frais fixes.
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttIfrais
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field etab-cd    as integer    initial ? 
    field frais-cd   as integer    initial ? 
    field libfrais   as character  initial ? 
    field mtht       as decimal    initial ?  decimals 2
    field mtht-EURO  as decimal    initial ?  decimals 2
    field seuil      as decimal    initial ?  decimals 2
    field seuil-EURO as decimal    initial ?  decimals 2
    field soc-cd     as integer    initial ? 
    field typeseuil  as logical    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
