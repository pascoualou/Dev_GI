/*------------------------------------------------------------------------
File        : cpardt.i
Purpose     : Fichier parametres encaisst/debit TVA
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttCpardt
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cpt-cd      as character  initial ? 
    field etab-cd     as integer    initial ? 
    field libass-cd   as integer    initial ? 
    field natjou-cd   as integer    initial ? 
    field ordre-num   as integer    initial ? 
    field soc-cd      as integer    initial ? 
    field sscoll-cle  as character  initial ? 
    field taxe-cd     as integer    initial ? 
    field type-declar as logical    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
