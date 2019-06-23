/*------------------------------------------------------------------------
File        : cfrais.i
Purpose     : Fichier Frais de banques
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCfrais
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field bque-cd    as integer    initial ? 
    field cpt1-cd    as character  initial ? 
    field cpt2-cd    as character  initial ? 
    field cpt3-cd    as character  initial ? 
    field cpttva-cd  as character  initial ? 
    field etab-cd    as integer    initial ? 
    field frais      as logical    initial ? 
    field frais-cd   as character  initial ? 
    field frais-type as logical    initial ? 
    field jou-cd     as character  initial ? 
    field lib        as character  initial ? 
    field soc-cd     as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
