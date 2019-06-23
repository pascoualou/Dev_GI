/*------------------------------------------------------------------------
File        : cparct.i
Purpose     : Fichier parametres comptabilisation TVA
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCparct
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cpt-credit  as character  initial ? 
    field cpt-debit   as character  initial ? 
    field etab-cd     as integer    initial ? 
    field fg-ctrlclo  as logical    initial ? 
    field fg-manu     as logical    initial ? 
    field iprorata    as integer    initial ? 
    field jou-cd      as character  initial ? 
    field soc-cd      as integer    initial ? 
    field taxe-defaut as integer    initial ? 
    field type-cle    as character  initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
