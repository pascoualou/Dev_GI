/*------------------------------------------------------------------------
File        : crbsai.i
Purpose     : Fichier entete rapprochements bancaires
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCrbsai
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cpt-cd      as character  initial ? 
    field dacrea      as date       initial ? 
    field dadeb       as date       initial ? 
    field dafin       as date       initial ? 
    field dev-cd      as character  initial ? 
    field etab-cd     as integer    initial ? 
    field ihcrea      as integer    initial ? 
    field jou-cd      as character  initial ? 
    field lettre      as character  initial ? 
    field NomFic      as character  initial ? 
    field nomprog     as character  initial ? 
    field num-int     as integer    initial ? 
    field situ        as logical    initial ? 
    field soc-cd      as integer    initial ? 
    field type-rappro as character  initial ? 
    field usrid       as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
