/*------------------------------------------------------------------------
File        : itcgen.i
Purpose     : Transfert compta - parametres compta generale
Author(s)   : generation automatique le 01/31/18
Notes       :
------------------------------------------------------------------------*/
&if defined(nomTable)   = 0 &then &scoped-define nomTable ttItcgen
&endif
&if defined(serialName) = 0 &then &scoped-define serialName {&nomTable}
&endif
define temp-table {&nomTable} no-undo serialize-name '{&serialName}'
    field cod-op     as character  initial ? 
    field cpt-cd     as character  initial ? 
    field cpt-ctp    as character  initial ? 
    field etab-cd    as integer    initial ? 
    field jou-cd     as character  initial ? 
    field libass-cd  as integer    initial ? 
    field nature-cd  as character  initial ? 
    field rgt-cd     as character  initial ? 
    field soc-cd     as integer    initial ? 
    field sscoll-cle as character  initial ? 
    field taxe-cd    as integer    initial ? 
    field type-cd    as integer    initial ? 
    field dtTimestamp as datetime  initial ?
    field CRUD        as character initial ?
    field rRowid      as rowid
.
